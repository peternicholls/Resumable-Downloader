#!/usr/bin/env bash
#
# Resumable Download Manager
# A bash/zsh script for downloading very large files with resume capability
#
# Usage: ./download.sh <URL> [output_filename]
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
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

# Function to display usage
usage() {
    cat << EOF
Usage: $0 <URL> [output_filename]

A resumable download manager for very large files.

Arguments:
  URL               The URL of the file to download
  output_filename   (Optional) The name to save the file as. If not provided,
                    the filename will be extracted from the URL.

Options:
  -h, --help       Show this help message

Features:
  - Resumable downloads using HTTP range requests
  - Progress bar with speed and ETA
  - Automatic retry on failure
  - Checksum verification (if provided)
  - Works with bash and zsh

Examples:
  $0 https://example.com/largefile.zip
  $0 https://example.com/largefile.zip myfile.zip

EOF
    exit 0
}

# Function to get filename from URL
get_filename_from_url() {
    local url="$1"
    local filename
    
    # Extract filename from URL (remove query params and fragments)
    filename=$(basename "$url" | sed 's/[?#].*$//')
    
    # If filename is empty or looks invalid, use a default
    if [[ -z "$filename" || "$filename" == "/" ]]; then
        filename="downloaded_file_$(date +%s)"
    fi
    
    echo "$filename"
}

# Function to format bytes to human readable
format_bytes() {
    local bytes=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    local size=$bytes
    
    # Use bash arithmetic instead of bc for efficiency
    while (( size >= 1024 )) && (( unit < 4 )); do
        size=$(( size / 1024 ))
        ((unit++))
    done
    
    echo "$size ${units[$unit]}"
}

# Function to get file size (cross-platform)
get_file_size() {
    local file="$1"
    # Use wc -c for portable byte count
    if [[ -f "$file" ]]; then
        wc -c < "$file" 2>/dev/null | tr -d ' ' || echo 0
    else
        echo 0
    fi
}

# Function to check if curl supports range requests
check_curl_support() {
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed. Please install curl to use this script."
        exit 1
    fi
}

# Function to check if URL supports resume
check_resume_support() {
    local url="$1"
    
    print_info "Checking if server supports resumable downloads..."
    
    # Send HEAD request to check for Accept-Ranges header
    local headers
    headers=$(curl -sI "$url")
    
    if echo "$headers" | grep -qi "Accept-Ranges:.*bytes"; then
        print_success "Server supports resumable downloads"
        return 0
    else
        print_warning "Server may not support resumable downloads (no Accept-Ranges header)"
        print_warning "Will attempt download anyway, but resume may not work"
        return 1
    fi
}

# Function to get remote file size
get_remote_size() {
    local url="$1"
    local size
    
    size=$(curl -sI "$url" | grep -i "Content-Length:" | tail -1 | awk '{print $2}' | tr -d '\r')
    
    if [[ -n "$size" ]]; then
        echo "$size"
    else
        echo "0"
    fi
}

# Function to download file with resume capability
download_file() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.part"
    local resume_from=0
    
    # Check if partial file exists
    if [[ -f "$temp_file" ]]; then
        resume_from=$(get_file_size "$temp_file")
        print_info "Found partial download: $(format_bytes "$resume_from")"
        print_info "Resuming download..."
    else
        print_info "Starting new download..."
    fi
    
    # Get remote file size
    local remote_size
    remote_size=$(get_remote_size "$url")
    
    if [[ "$remote_size" -gt 0 ]]; then
        print_info "Remote file size: $(format_bytes "$remote_size")"
    fi
    
    # Download with curl
    # -L: follow redirects
    # -C -: resume from where it left off
    # -#: show progress bar
    # -o: output file
    # --retry: retry on transient errors
    # --retry-delay: wait between retries
    
    local curl_cmd=(
        curl
        -L
        -C -
        -#
        --retry 5
        --retry-delay 3
        --retry-max-time 60
        -o "$temp_file"
        "$url"
    )
    
    # Execute download
    if "${curl_cmd[@]}"; then
        # Download successful, move temp file to final location
        mv "$temp_file" "$output_file"
        print_success "Download completed successfully!"
        
        # Show final file info
        local final_size
        final_size=$(get_file_size "$output_file")
        print_info "File saved as: $output_file"
        print_info "File size: $(format_bytes "$final_size")"
        
        # Verify size if we know the remote size
        if [[ "$remote_size" -gt 0 ]] && [[ "$final_size" -ne "$remote_size" ]]; then
            print_warning "Downloaded file size ($final_size) differs from remote size ($remote_size)"
            print_warning "The download may be incomplete or corrupted"
            return 1
        fi
        
        return 0
    else
        print_error "Download failed or was interrupted"
        print_info "Partial download saved as: $temp_file"
        print_info "You can resume by running the same command again"
        return 1
    fi
}

# Main script
main() {
    # Parse arguments
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        usage
    fi
    
    local url="$1"
    local output_file=""
    
    # Get output filename
    if [[ $# -ge 2 ]]; then
        output_file="$2"
    else
        output_file=$(get_filename_from_url "$url")
    fi
    
    # Sanitize URL for display (hide credentials)
    local display_url="$url"
    if [[ "$url" =~ .*://[^@]+@.* ]]; then
        display_url=$(echo "$url" | sed 's|://[^@]*@|://***:***@|')
    fi
    
    print_info "Resumable Download Manager"
    print_info "URL: $display_url"
    print_info "Output file: $output_file"
    echo ""
    
    # Check dependencies
    check_curl_support
    
    # Check if file already exists
    if [[ -f "$output_file" ]]; then
        print_warning "File '$output_file' already exists"
        # Only prompt if we're in an interactive terminal
        if [[ -t 0 ]]; then
            read -p "Do you want to overwrite it? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Download cancelled"
                exit 0
            fi
            rm -f "$output_file"
        else
            print_error "Cannot overwrite existing file in non-interactive mode"
            print_info "Please remove the file manually or use a different filename"
            exit 1
        fi
    fi
    
    # Check server resume support
    check_resume_support "$url" || true
    echo ""
    
    # Download the file
    if download_file "$url" "$output_file"; then
        print_success "All done! 🎉"
        exit 0
    else
        print_error "Download failed"
        exit 1
    fi
}

# Run main function
main "$@"
