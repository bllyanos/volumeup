# VolumeUp Technical Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Core Components](#core-components)
6. [Development Environment Setup](#development-environment-setup)
7. [Build and Deployment](#build-and-deployment)
8. [Testing](#testing)
9. [Docker Integration](#docker-integration)
10. [Error Handling](#error-handling)
11. [CLI Interface](#cli-interface)
12. [File Operations](#file-operations)
13. [Security Considerations](#security-considerations)
14. [Performance Considerations](#performance-considerations)
15. [Troubleshooting](#troubleshooting)
16. [Contributing Guidelines](#contributing-guidelines)

## Project Overview

VolumeUp is a Ruby-based CLI tool for backing up and restoring Docker volumes. It provides a simple interface for managing Docker volume data through compressed tar archives.

### Key Features
- **Volume Backup**: Create compressed backups of Docker volumes
- **Volume Restore**: Restore volumes from backup files
- **Volume Listing**: List and categorize Docker volumes
- **Custom Naming**: Assign custom names to backup files
- **Force Operations**: Overwrite existing volumes when restoring

### Target Users
- DevOps engineers managing Docker environments
- System administrators handling container data
- Developers working with persistent container storage

## Architecture

### High-Level Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CLI Interface │    │   Core Managers  │    │  Docker Engine  │
│   (Thor-based)  │───▶│  Backup/Restore  │───▶│   (Docker API)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Error Handling │    │  File Operations │    │ Temporary       │
│  & Validation   │    │  & Compression   │    │ Containers      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Design Patterns
- **Command Pattern**: CLI commands are implemented using Thor
- **Manager Pattern**: Separate managers for backup and restore operations
- **Template Method**: Common container operations abstracted
- **Error Handling**: Custom exception hierarchy for different error types

## Technology Stack

### Core Technologies
- **Ruby 2.7+**: Primary programming language
- **Thor**: CLI framework for command-line interface
- **Docker API**: Ruby gem for Docker interaction
- **Bundler**: Dependency management

### Key Dependencies
```ruby
# Core dependencies
gem 'thor', '~> 1.2'           # CLI framework
gem 'docker-api', '~> 2.0'     # Docker API client
gem 'colorize', '~> 0.8'       # Terminal colors
gem 'tty-progressbar', '~> 0.18' # Progress bars
gem 'base64', '~> 0.1'         # Base64 encoding

# Development dependencies
gem 'rspec', '~> 3.12'         # Testing framework
gem 'pry', '~> 0.14'           # Debugging
gem 'rake', '~> 13.0'          # Build tasks
```

### External Dependencies
- **Docker Engine**: Must be running and accessible
- **Alpine Linux**: Used for temporary containers
- **tar/gzip**: For compression and archiving

## Project Structure

```
volumeup/
├── bin/                    # Executable scripts
│   └── volumeup           # Main CLI entry point
├── lib/                   # Source code
│   ├── volumeup.rb        # Main module and error definitions
│   └── volumeup/          # Core classes
│       ├── cli.rb         # CLI interface (Thor-based)
│       ├── backup_manager.rb    # Backup operations
│       ├── restore_manager.rb   # Restore operations
│       └── version.rb     # Version information
├── spec/                  # Test files
│   ├── spec_helper.rb     # Test configuration
│   └── volumeup_spec.rb   # Main test suite
├── pkg/                   # Built gems
├── Gemfile                # Dependencies
├── volumeup.gemspec       # Gem specification
├── Rakefile              # Build tasks
├── install.sh            # Installation script
├── uninstall.sh          # Uninstallation script
└── README.md             # User documentation
```

## Core Components

### 1. VolumeUp Module (`lib/volumeup.rb`)
```ruby
module VolumeUp
  class Error < StandardError; end
  class VolumeNotFoundError < Error; end
  class BackupError < Error; end
  class RestoreError < Error; end
end
```

**Purpose**: Defines the main module and custom exception hierarchy.

**Key Features**:
- Custom error classes for different failure scenarios
- Centralized error handling
- Clear error categorization

### 2. CLI Interface (`lib/volumeup/cli.rb`)
```ruby
class CLI < Thor
  desc "backup VOLUME_NAME BACKUP_PATH", "Backup a Docker volume"
  option :name, aliases: :n, desc: "Custom name for backup file"
  option :verbose, aliases: :v, type: :boolean, desc: "Enable verbose output"
  
  def backup(volume_name, backup_path)
    # Implementation
  end
end
```

**Purpose**: Command-line interface using Thor framework.

**Commands**:
- `backup`: Create volume backups
- `restore`: Restore volumes from backups
- `list`: List Docker volumes
- `version`: Show version information

**Options**:
- `--name/-n`: Custom backup filename
- `--force/-f`: Force operations
- `--verbose/-v`: Verbose output
- `--all/-a`: Show all volumes

### 3. Backup Manager (`lib/volumeup/backup_manager.rb`)
```ruby
class BackupManager
  def backup_volume(volume_name, backup_path, custom_name = nil)
    validate_volume_exists(volume_name)
    backup_filename = generate_backup_filename(volume_name, custom_name)
    # ... backup process
  end
end
```

**Purpose**: Handles all backup operations.

**Key Methods**:
- `backup_volume()`: Main backup method
- `validate_volume_exists()`: Volume validation
- `create_temp_container()`: Container creation
- `create_backup()`: Archive creation
- `cleanup_temp_container()`: Resource cleanup

**Backup Process**:
1. Validate source volume exists
2. Generate backup filename with timestamp
3. Create temporary Alpine container
4. Mount volume as read-only
5. Create compressed tar archive
6. Copy archive to host
7. Clean up temporary resources

### 4. Restore Manager (`lib/volumeup/restore_manager.rb`)
```ruby
class RestoreManager
  def restore_volume(backup_file, volume_name, force = false)
    validate_backup_file(backup_file)
    validate_volume_does_not_exist(volume_name) unless force
    # ... restore process
  end
end
```

**Purpose**: Handles all restore operations.

**Key Methods**:
- `restore_volume()`: Main restore method
- `validate_backup_file()`: Backup file validation
- `create_volume()`: Target volume creation
- `restore_backup()`: Archive extraction
- `cleanup_temp_container()`: Resource cleanup

**Restore Process**:
1. Validate backup file exists and is readable
2. Check if target volume exists (unless force)
3. Create target volume
4. Create temporary Alpine container
5. Mount target volume
6. Copy backup to container
7. Extract archive to volume
8. Clean up temporary resources

## Development Environment Setup

### Prerequisites
```bash
# Required software
ruby >= 2.7
bundler >= 2.0
docker >= 20.0
git
```

### Setup Steps
```bash
# 1. Clone repository
git clone <repository-url>
cd volumeup

# 2. Install dependencies
bundle install

# 3. Verify Docker is running
docker ps

# 4. Run tests
bundle exec rspec

# 5. Build gem
bundle exec rake build
```

### Development Tools
```bash
# Run with bundler (development mode)
bundle exec bin/volumeup --help

# Interactive debugging
bundle exec pry

# Code formatting (if configured)
bundle exec rubocop

# Test coverage (if configured)
bundle exec rspec --format documentation
```

## Build and Deployment

### Gem Building
```bash
# Build the gem
bundle exec rake build

# This creates: pkg/volumeup-0.1.0.gem
```

### Installation Methods

#### 1. Automated Installation
```bash
# Full installation with verification
./install.sh

# Force reinstall
./install.sh --force

# Quiet mode
./install.sh --quiet
```

#### 2. Manual Installation
```bash
# Install dependencies
bundle install

# Build gem
bundle exec rake build

# Install gem system-wide
gem install pkg/volumeup-0.1.0.gem
```

#### 3. Development Installation
```bash
# Run directly without installation
bundle exec bin/volumeup --help
```

### Uninstallation
```bash
# Automated uninstall
./uninstall.sh

# Manual uninstall
gem uninstall volumeup
```

## Testing

### Test Structure
```ruby
# spec/volumeup_spec.rb
RSpec.describe VolumeUp do
  it "has a version number" do
    expect(VolumeUp::VERSION).not_to be nil
  end
  
  it "defines custom error classes" do
    expect(VolumeUp::Error).to be < StandardError
    expect(VolumeUp::VolumeNotFoundError).to be < VolumeUp::Error
    expect(VolumeUp::BackupError).to be < VolumeUp::Error
    expect(VolumeUp::RestoreError).to be < VolumeUp::Error
  end
end
```

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/volumeup_spec.rb

# Run with coverage (if configured)
bundle exec rspec --coverage
```

### Test Configuration
```ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
```

## Docker Integration

### Docker API Usage
```ruby
# Volume operations
volumes = Docker::Volume.all
volume = Docker::Volume.create(volume_name)

# Container operations
container = Docker::Container.create(
  'Image' => 'alpine:latest',
  'Cmd' => ['sleep', '3600'],
  'Volumes' => { "/backup_volume" => {} },
  'HostConfig' => {
    'Binds' => ["#{volume_name}:/backup_volume:ro"]
  }
)
```

### Container Lifecycle
1. **Creation**: Temporary Alpine containers for operations
2. **Mounting**: Volume mounting with appropriate permissions
3. **Execution**: Command execution within containers
4. **Cleanup**: Automatic container removal

### Volume Mounting
```ruby
# Read-only mount for backup
'Binds' => ["#{volume_name}:/backup_volume:ro"]

# Read-write mount for restore
'Binds' => ["#{volume_name}:/restore_volume"]
```

## Error Handling

### Error Hierarchy
```ruby
VolumeUp::Error                    # Base error class
├── VolumeUp::VolumeNotFoundError  # Volume doesn't exist
├── VolumeUp::BackupError         # Backup operation failed
└── VolumeUp::RestoreError        # Restore operation failed
```

### Error Scenarios
- **Volume not found**: When specified volume doesn't exist
- **Backup file issues**: File not found, not readable, or corrupted
- **Volume conflicts**: Target volume already exists
- **Docker connectivity**: Docker daemon not accessible
- **Permission issues**: Insufficient permissions for operations
- **Resource cleanup**: Failed container cleanup

### Error Handling Pattern
```ruby
begin
  # Operation
rescue VolumeUp::Error => e
  say e.message, :red
  exit 1
rescue => e
  say "Unexpected error: #{e.message}", :red
  exit 1
end
```

## CLI Interface

### Command Structure
```bash
volumeup COMMAND [OPTIONS] [ARGUMENTS]
```

### Available Commands

#### Backup Command
```bash
volumeup backup VOLUME_NAME BACKUP_PATH [OPTIONS]
```
- **VOLUME_NAME**: Name of Docker volume to backup
- **BACKUP_PATH**: Directory to store backup file
- **Options**:
  - `--name/-n`: Custom backup filename
  - `--verbose/-v`: Enable verbose output

#### Restore Command
```bash
volumeup restore BACKUP_FILE VOLUME_NAME [OPTIONS]
```
- **BACKUP_FILE**: Path to backup file (.tar.gz)
- **VOLUME_NAME**: Name for restored volume
- **Options**:
  - `--force/-f`: Force restore (overwrite existing)
  - `--verbose/-v`: Enable verbose output

#### List Command
```bash
volumeup list [OPTIONS]
```
- **Options**:
  - `--all/-a`: Show all volumes (including auto-generated)
  - `--verbose/-v`: Enable verbose output

#### Version Command
```bash
volumeup version
```

### CLI Features
- **Colored output**: Success (green), warnings (yellow), errors (red)
- **Progress indicators**: Visual feedback for long operations
- **Help system**: Built-in help with `--help` flag
- **Error handling**: Clear error messages with exit codes

## File Operations

### Backup File Format
- **Format**: Compressed tar archive (.tar.gz)
- **Naming**: `{volume_name}_{timestamp}.tar.gz`
- **Custom naming**: `{custom_name}_{timestamp}.tar.gz`
- **Timestamp format**: `YYYYMMDD_HHMMSS`

### File Operations Flow
```ruby
# Backup process
1. Create temporary container
2. Mount volume as read-only
3. Execute: tar -czf /tmp/backup.tar.gz -C /backup_volume .
4. Copy file from container to host
5. Move to final location
6. Clean up temporary files

# Restore process
1. Validate backup file
2. Create target volume
3. Create temporary container
4. Mount target volume
5. Copy backup to container
6. Execute: tar -xzf /tmp/backup.tar.gz -C /restore_volume
7. Clean up temporary files
```

### File Validation
```ruby
def validate_backup_file(backup_file)
  unless File.exist?(backup_file)
    raise RestoreError, "Backup file '#{backup_file}' not found"
  end
  
  unless File.readable?(backup_file)
    raise RestoreError, "Backup file '#{backup_file}' is not readable"
  end
end
```

## Security Considerations

### Container Security
- **Minimal base image**: Uses Alpine Linux for temporary containers
- **Read-only mounts**: Backup operations use read-only volume mounts
- **Temporary containers**: Containers are automatically cleaned up
- **Limited permissions**: Containers run with minimal required permissions

### File System Security
- **Path validation**: Validates file paths and permissions
- **Temporary files**: Uses secure temporary file locations
- **Cleanup**: Ensures temporary files are removed

### Docker Security
- **Volume isolation**: Each operation uses isolated containers
- **Resource limits**: Containers have limited lifetime
- **API access**: Uses Docker API with appropriate permissions

## Performance Considerations

### Backup Performance
- **Compression**: Uses gzip compression for smaller files
- **Streaming**: Direct file operations without intermediate storage
- **Parallel operations**: Can handle multiple volumes (with scripting)

### Restore Performance
- **Direct extraction**: Extracts directly to target volume
- **Memory efficiency**: Uses streaming operations
- **Cleanup**: Immediate cleanup of temporary resources

### Resource Management
- **Container lifecycle**: Automatic cleanup prevents resource leaks
- **Temporary files**: Minimal temporary file usage
- **Memory usage**: Efficient memory usage for large volumes

## Troubleshooting

### Common Issues

#### 1. Docker Connection Issues
```bash
# Check Docker daemon
docker ps

# Check Docker API access
docker version

# Restart Docker service (if needed)
sudo systemctl restart docker
```

#### 2. Permission Issues
```bash
# Check file permissions
ls -la backup_file.tar.gz

# Check Docker permissions
docker run --rm hello-world

# Add user to docker group (if needed)
sudo usermod -aG docker $USER
```

#### 3. Volume Not Found
```bash
# List all volumes
docker volume ls

# Check volume details
docker volume inspect volume_name

# Verify volume exists
volumeup list
```

#### 4. Backup File Issues
```bash
# Check file exists
ls -la backup_file.tar.gz

# Check file integrity
file backup_file.tar.gz

# Test extraction
tar -tzf backup_file.tar.gz
```

### Debug Mode
```bash
# Enable verbose output
volumeup backup my_volume ./backups --verbose

# Check logs
journalctl -u docker.service

# Debug with pry (development)
bundle exec pry
```

### Performance Issues
- **Large volumes**: Consider splitting large volumes
- **Network storage**: Check network performance for remote volumes
- **Disk space**: Ensure sufficient disk space for backups
- **Memory usage**: Monitor memory usage for large operations

## Contributing Guidelines

### Code Style
- **Ruby style**: Follow Ruby community conventions
- **Indentation**: Use 2 spaces for indentation
- **Line length**: Keep lines under 80 characters
- **Naming**: Use descriptive variable and method names

### Testing Requirements
- **Test coverage**: Maintain high test coverage
- **Test cases**: Add tests for new features
- **Edge cases**: Test error conditions and edge cases
- **Integration tests**: Test Docker integration

### Documentation
- **Code comments**: Document complex logic
- **README updates**: Update user documentation
- **Technical docs**: Update this technical guide
- **API docs**: Document public interfaces

### Pull Request Process
1. **Fork repository**: Create feature branch
2. **Write tests**: Add tests for new functionality
3. **Update docs**: Update relevant documentation
4. **Run tests**: Ensure all tests pass
5. **Submit PR**: Create pull request with description

### Development Workflow
```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes
# Edit files

# 3. Run tests
bundle exec rspec

# 4. Build and test
bundle exec rake build
gem install pkg/volumeup-0.1.0.gem

# 5. Test installation
volumeup version

# 6. Commit changes
git add .
git commit -m "Add new feature"

# 7. Push and create PR
git push origin feature/new-feature
```

### Release Process
1. **Update version**: Update version in `lib/volumeup/version.rb`
2. **Update changelog**: Document changes
3. **Run tests**: Ensure all tests pass
4. **Build gem**: `bundle exec rake build`
5. **Test installation**: Test gem installation
6. **Create tag**: Git tag for release
7. **Publish**: Publish to RubyGems (if applicable)

---

This technical guide provides comprehensive information for new engineers working on VolumeUp, covering all aspects from architecture to deployment. The guide is designed to be accessible to engineers regardless of their Ruby experience level.
