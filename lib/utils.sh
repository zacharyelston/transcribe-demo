#!/bin/bash
# Common utility functions for transcription scripts

# Ensure the lib directory is in the path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load configuration
load_config() {
    local config_file="${1:-${PROJECT_ROOT}/config/default.conf}"
    
    if [ -f "$config_file" ]; then
        source "$config_file"
        echo "Loaded configuration from $config_file"
    else
        echo "Error: Configuration file not found: $config_file" >&2
        return 1
    fi
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local package="$2"
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' command not found" >&2
        if [ -n "$package" ]; then
            echo "Please install it using: $package" >&2
        fi
        return 1
    fi
    
    return 0
}

# Check if Whisper CLI is installed
check_whisper() {
    if ! check_command "${WHISPER_CLI_PATH}" "Please install Whisper CLI"; then
        return 1
    fi
    
    return 0
}

# Create directory if it doesn't exist
ensure_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        if [ $? -ne 0 ]; then
            echo "Error: Could not create directory '$dir'" >&2
            return 1
        fi
    fi
    
    return 0
}

# Check if a file exists
check_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    return 0
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
            echo -e "\033[32m[${timestamp}] [INFO] ${message}\033[0m"
            ;;
        WARNING)
            echo -e "\033[33m[${timestamp}] [WARNING] ${message}\033[0m"
            ;;
        ERROR)
            echo -e "\033[31m[${timestamp}] [ERROR] ${message}\033[0m" >&2
            ;;
        *)
            echo "[${timestamp}] ${message}"
            ;;
    esac
}

# Execute whisper command with error handling
execute_whisper() {
    local params="$@"
    "${WHISPER_CLI_PATH}" $params
    local status=$?
    
    if [ $status -ne 0 ]; then
        log_message "ERROR" "Whisper command failed with status $status"
        return $status
    fi
    
    return 0
}