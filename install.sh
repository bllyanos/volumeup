#!/bin/bash

# VolumeUp Docker Volume Backup Manager - Installation Script
# This script builds and installs VolumeUp as a system-wide gem

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists ruby; then
        print_error "Ruby is not installed. Please install Ruby first."
        exit 1
    fi
    
    if ! command_exists gem; then
        print_error "RubyGems is not installed. Please install RubyGems first."
        exit 1
    fi
    
    if ! command_exists bundle; then
        print_error "Bundler is not installed. Installing Bundler..."
        gem install bundler
    fi
    
    if ! command_exists docker; then
        print_warning "Docker is not installed. VolumeUp requires Docker to function."
    fi
    
    print_success "Prerequisites check completed"
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    if [ -f "Gemfile" ]; then
        bundle install
        print_success "Dependencies installed successfully"
    else
        print_error "Gemfile not found. Are you in the correct directory?"
        exit 1
    fi
}

# Function to build the gem
build_gem() {
    print_status "Building VolumeUp gem..."
    
    if [ -f "volumeup.gemspec" ]; then
        bundle exec rake build
        print_success "Gem built successfully"
    else
        print_error "volumeup.gemspec not found. Are you in the correct directory?"
        exit 1
    fi
}

# Function to install the gem
install_gem() {
    print_status "Installing VolumeUp gem..."
    
    # Check if gem is already installed
    if gem list volumeup | grep -q volumeup; then
        print_warning "VolumeUp is already installed. Uninstalling previous version..."
        echo "y" | gem uninstall volumeup
    fi
    
    # Install the gem
    if [ -f "pkg/volumeup-0.1.0.gem" ]; then
        gem install pkg/volumeup-0.1.0.gem
        print_success "VolumeUp gem installed successfully"
    else
        print_error "Built gem not found. Please run the build step first."
        exit 1
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if command_exists volumeup; then
        print_success "VolumeUp is now available system-wide!"
        echo
        print_status "Testing VolumeUp..."
        volumeup version
        echo
        print_success "Installation completed successfully!"
        echo
        echo -e "${GREEN}Usage examples:${NC}"
        echo "  volumeup list                                    # List all Docker volumes"
        echo "  volumeup backup my_volume ./backups             # Backup a volume"
        echo "  volumeup restore backup.tar.gz my_volume        # Restore a volume"
        echo "  volumeup --help                                 # Show all commands"
    else
        print_error "Installation verification failed. VolumeUp command not found."
        print_warning "You may need to restart your shell or run: source ~/.bashrc"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "VolumeUp Installation Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Force reinstall even if already installed"
    echo "  -q, --quiet    Quiet mode (minimal output)"
    echo
    echo "This script will:"
    echo "  1. Check prerequisites (Ruby, Bundler, Docker)"
    echo "  2. Install dependencies from Gemfile"
    echo "  3. Build the VolumeUp gem"
    echo "  4. Install the gem system-wide"
    echo "  5. Verify the installation"
}

# Main function
main() {
    local force_install=false
    local quiet_mode=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                force_install=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Set quiet mode if requested
    if [ "$quiet_mode" = true ]; then
        exec >/dev/null 2>&1
    fi
    
    echo -e "${BLUE}VolumeUp Docker Volume Backup Manager - Installation Script${NC}"
    echo "=================================================================="
    echo
    
    # Check if we're in the right directory
    if [ ! -f "volumeup.gemspec" ] || [ ! -f "Gemfile" ]; then
        print_error "This script must be run from the VolumeUp project root directory."
        print_error "Please cd to the directory containing volumeup.gemspec and Gemfile"
        exit 1
    fi
    
    # Run installation steps
    check_prerequisites
    install_dependencies
    build_gem
    install_gem
    verify_installation
    
    echo
    echo -e "${GREEN}🎉 VolumeUp has been successfully installed!${NC}"
    echo -e "${BLUE}You can now use 'volumeup' command from anywhere in your system.${NC}"
}

# Run main function with all arguments
main "$@"
