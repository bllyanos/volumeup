#!/bin/bash

# VolumeUp Docker Volume Backup Manager - Uninstallation Script
# This script removes VolumeUp gem from the system

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

# Function to show help
show_help() {
    echo "VolumeUp Uninstallation Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -y, --yes      Skip confirmation prompt"
    echo "  -q, --quiet    Quiet mode (minimal output)"
    echo
    echo "This script will:"
    echo "  1. Check if VolumeUp is installed"
    echo "  2. Remove the VolumeUp gem and executable"
    echo "  3. Confirm successful removal"
}

# Function to uninstall VolumeUp
uninstall_volumeup() {
    print_status "Checking if VolumeUp is installed..."
    
    if gem list volumeup | grep -q volumeup; then
        print_status "VolumeUp is installed. Proceeding with uninstallation..."
        
        # Uninstall the gem
        gem uninstall volumeup -q
        print_success "VolumeUp gem uninstalled successfully"
        
        # Verify removal
        if ! command_exists volumeup; then
            print_success "VolumeUp has been completely removed from your system"
        else
            print_warning "VolumeUp executable still exists. You may need to restart your shell."
        fi
    else
        print_warning "VolumeUp is not installed on this system"
    fi
}

# Main function
main() {
    local skip_confirmation=false
    local quiet_mode=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -y|--yes)
                skip_confirmation=true
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
    
    echo -e "${BLUE}VolumeUp Docker Volume Backup Manager - Uninstallation Script${NC}"
    echo "======================================================================"
    echo
    
    # Confirmation prompt unless skipped
    if [ "$skip_confirmation" = false ]; then
        echo -e "${YELLOW}This will remove VolumeUp from your system.${NC}"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Uninstallation cancelled"
            exit 0
        fi
    fi
    
    # Run uninstallation
    uninstall_volumeup
    
    echo
    echo -e "${GREEN}✅ VolumeUp has been successfully removed!${NC}"
}

# Run main function with all arguments
main "$@"
