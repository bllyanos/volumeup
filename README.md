# VolumeUp

A Docker volume backup manager that allows you to easily backup and restore Docker volumes via CLI.

## Features

- **Backup volumes**: Create compressed backups of Docker volumes
- **Restore volumes**: Restore volumes from backup files
- **Custom naming**: Assign custom names to backup files
- **Volume listing**: List all available Docker volumes
- **Force restore**: Overwrite existing volumes when restoring

## Installation

### Quick Install (Recommended)

Use the provided installation script for the easiest setup:

```bash
# Clone the repository
git clone <repository-url>
cd volumeup

# Run the installation script
./install.sh

# Or with options
./install.sh --force    # Force reinstall
./install.sh --quiet    # Quiet mode
./install.sh --help     # Show help
```

The installation script will:
- Check prerequisites (Ruby, Bundler, Docker)
- Install dependencies from Gemfile
- Build the VolumeUp gem
- Install the gem system-wide
- Verify the installation

### Manual Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd volumeup
```

2. Install dependencies:
```bash
bundle install
```

3. Build and install the gem:
```bash
bundle exec rake build
gem install pkg/volumeup-0.1.0.gem
```

### Using the executable directly

You can also run the tool directly without installing:

```bash
bundle exec bin/volumeup --help
```

### Uninstallation

To remove VolumeUp from your system:

```bash
# Using the uninstall script
./uninstall.sh

# Or manually
gem uninstall volumeup
```

## Usage

### List Docker volumes

```bash
# List only manually created volumes (default)
volumeup list

# List all volumes including auto-generated ones
volumeup list --all
```

### Backup a volume

```bash
# Basic backup
volumeup backup my_volume /path/to/backup/directory

# Backup with custom name
volumeup backup my_volume /path/to/backup/directory --name my_custom_backup

# Verbose output
volumeup backup my_volume /path/to/backup/directory --verbose
```

### Restore a volume

```bash
# Basic restore
volumeup restore /path/to/backup/my_volume_20240101_120000.tar.gz my_volume

# Force restore (overwrite existing volume)
volumeup restore /path/to/backup/my_volume_20240101_120000.tar.gz my_volume --force

# Verbose output
volumeup restore /path/to/backup/my_volume_20240101_120000.tar.gz my_volume --verbose
```

### Show version

```bash
volumeup version
```

## Examples

### Complete backup and restore workflow

```bash
# 1. List manually created volumes
volumeup list

# 2. Backup a volume
volumeup backup postgres_data ./backups --name postgres_backup_$(date +%Y%m%d)

# 3. Restore the volume (with a new name)
volumeup restore ./backups/postgres_backup_20240101.tar.gz postgres_data_restored
```

### Backup multiple volumes

```bash
# Backup multiple volumes with timestamps
for volume in postgres_data redis_data app_data; do
  volumeup backup $volume ./backups --name ${volume}_$(date +%Y%m%d_%H%M%S)
done
```

## Requirements

- Ruby 2.7 or higher
- Docker daemon running
- Docker API access

## How it works

### Backup Process

1. Validates that the source volume exists
2. Creates a temporary Alpine Linux container with the volume mounted as read-only
3. Uses `tar` to create a compressed archive of the volume contents
4. Copies the archive to the specified backup location
5. Cleans up the temporary container

### Restore Process

1. Validates that the backup file exists and is readable
2. Checks if the target volume already exists (unless `--force` is used)
3. Creates the target volume
4. Creates a temporary Alpine Linux container with the volume mounted
5. Extracts the backup archive into the volume
6. Cleans up the temporary container

## Error Handling

The tool provides clear error messages for common issues:

- Volume not found
- Backup file not found or not readable
- Volume already exists (when restoring without `--force`)
- Docker daemon not accessible
- Permission issues

## Development

### Running tests

```bash
bundle exec rspec
```

### Building the gem

```bash
bundle exec rake build
```

### Installation Scripts

The project includes convenient installation scripts:

- **`install.sh`** - Automated installation script with options:
  - `--help` - Show help message
  - `--force` - Force reinstall even if already installed
  - `--quiet` - Quiet mode (minimal output)

- **`uninstall.sh`** - Automated uninstallation script with options:
  - `--help` - Show help message
  - `--yes` - Skip confirmation prompt
  - `--quiet` - Quiet mode (minimal output)

## License

MIT License - see LICENSE file for details.
