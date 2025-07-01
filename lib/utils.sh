#!/bin/bash
# Common utility functions for transcription scripts

# Ensure the lib directory is in the path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_FILE="${PROJECT_ROOT}/logs/transcription.log"

# Load configuration
load_config() {
    local config_file="${1:-${PROJECT_ROOT}/config/default.conf}"
    
    if [ -f "$config_file" ]; then
        source "$config_file"
        log_message "INFO" "Loaded configuration from $config_file"
    else
        log_message "ERROR" "Configuration file not found: $config_file"
        exit 1
    fi
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local package="$2"
    
    if ! command -v "$cmd" &> /dev/null; then
        log_message "ERROR" "'$cmd' command not found. Please install it using: $package"
        exit 1
    fi
}

# Check if VLC is installed
check_vlc() {
    if [ ! -f "${VLC_PATH}" ]; then
        log_message "ERROR" "VLC not found at ${VLC_PATH}. Please ensure VLC is installed"
        exit 1
    fi
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        if [ $? -ne 0 ]; then
            log_message "ERROR" "Could not create directory '$dir'"
            exit 1
        fi
    fi
}

# Check if a file exists
check_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        log_message "ERROR" "File not found: $file"
        exit 1
    fi
}

# Extract basename from file path (without extension)
get_basename() {
    local file="$1"
    local ext="${2:-.mp4}"
    
    basename "$file" "$ext"
}

# Log message with timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO)
            echo -e "\033[32m[${timestamp}] [INFO] ${message}\033[0m" | tee -a $LOG_FILE
            ;;
        WARNING)
            echo -e "\033[33m[${timestamp}] [WARNING] ${message}\033[0m" | tee -a $LOG_FILE
            ;;
        ERROR)
            echo -e "\033[31m[${timestamp}] [ERROR] ${message}\033[0m" | tee -a $LOG_FILE >&2
            ;;
        *)
            echo "[${timestamp}] ${message}" | tee -a $LOG_FILE
            ;;
    esac
}

# Batch process files
batch_process() {
    local files=("$@")
    for file in "${files[@]}"; do
        transcribe_video "$file"
    done
}

# Transcribe video
transcribe_video() {
    local file="$1"
    local format="${2:-srt}"
    local quality="${3:-high}"
    local timestamp="${4:-false}"
    
    check_file "$file"
    check_command "ffmpeg" "apt-get install ffmpeg"
    
    local basename=$(get_basename "$file")
    local output="${OUTPUT_DIR}/${basename}.${format}"
    
    log_message "INFO" "Transcribing video: $file"
    
    ffmpeg -i "$file" -vn -ar 44100 -ac 2 -ab "${quality}k" -f "$format" "$output"
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to transcribe video: $file"
        exit 1
    fi
    
    if [ "$timestamp" = "true" ]; then
        add_timestamps "$output"
    fi
    
    log_message "INFO" "Transcription completed: $output"
}

# Add timestamps to transcript
add_timestamps() {
    local file="$1"
    
    check_file "$file"
    
    # Add timestamps using your preferred method
    # This is just a placeholder
    sed -i 's/^/[00:00:00] /' "$file"
    
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to add timestamps to transcript: $file"
        exit 1
    fi
    
    log_message "INFO" "Added timestamps to transcript: $file"
}