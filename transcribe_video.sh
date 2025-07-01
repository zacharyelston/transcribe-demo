#!/bin/bash

# Video Transcription Script
# Uses VLC to extract audio and Whisper to transcribe

# Import utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
CONFIG_DIR="${SCRIPT_DIR}/config"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Load utilities
if [ -f "${LIB_DIR}/utils.sh" ]; then
    source "${LIB_DIR}/utils.sh"
else
    echo "Error: Utilities not found at ${LIB_DIR}/utils.sh"
    exit 1
fi

# Display usage information
usage() {
    echo "Video Transcription Tool"
    echo ""
    echo "Usage: $0 <input_mp4_file> [output_directory] [config_file]"
    echo ""
    echo "Arguments:"
    echo "  input_mp4_file     : Path to the MP4 video file"
    echo "  output_directory   : Optional. Directory to save outputs (default: ./output)"
    echo "  config_file        : Optional. Path to config file (default: ./config/default.conf)"
    echo ""
    echo "Example:"
    echo "  $0 video.mp4 ./my_transcripts ./config/custom.conf"
}

# Main function
main() {
    # Process arguments
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi
    
    local input_file="$1"
    local dest_dir="${2:-${OUTPUT_DIR}}"
    local config_file="${3:-${CONFIG_DIR}/default.conf}"
    
    # Load configuration
    load_config "$config_file" || exit 1
    
    # Check input file
    check_file "$input_file" || exit 1
    
    # Ensure output directory exists
    ensure_directory "$dest_dir" || exit 1
    
    # Check dependencies
    check_vlc || exit 1
    check_command "whisper" "pip install openai-whisper" || exit 1
    
    # Prepare file paths
    local basename=$(get_basename "$input_file" .mp4)
    local audio_file="$dest_dir/${basename}_audio.wav"
    
    # Extract audio
    log_message "INFO" "Extracting audio from $input_file..."
    
    $VLC_PATH -I dummy "$input_file" \
        --sout "#transcode{acodec=$AUDIO_FORMAT,channels=$AUDIO_CHANNELS,samplerate=$AUDIO_SAMPLE_RATE}:std{access=file,mux=wav,dst='$audio_file'}" \
        vlc://quit
    
    # Wait for VLC to finish
    sleep 2
    
    # Check if audio file was created
    if [ ! -f "$audio_file" ]; then
        log_message "ERROR" "Failed to extract audio"
        exit 1
    fi
    
    log_message "INFO" "Audio extracted successfully: $audio_file"
    
    # Transcribe audio
    log_message "INFO" "Transcribing audio with Whisper (model: $WHISPER_MODEL)..."
    
    local whisper_args=("$audio_file" "--model" "$WHISPER_MODEL" "--output_dir" "$dest_dir")
    
    # Add language if specified
    if [ -n "$LANGUAGE" ]; then
        whisper_args+=("--language" "$LANGUAGE")
    fi
    
    # Add output formats
    whisper_args+=("--output_format" "$OUTPUT_FORMATS")
    
    # Run whisper
    whisper "${whisper_args[@]}"
    
    # Check if transcription was successful
    if [ $? -eq 0 ]; then
        log_message "INFO" "Transcription complete!"
        log_message "INFO" "Audio file: $audio_file"
        log_message "INFO" "Transcript saved to: $dest_dir/${basename}_audio.txt"
        
        # Clean up if configured
        if [ "$CLEANUP_TEMP_FILES" -eq 1 ]; then
            log_message "INFO" "Cleaning up temporary files..."
            rm "$audio_file"
        fi
        
        return 0
    else
        log_message "ERROR" "Transcription failed"
        return 1
    fi
}

# Run the main function
main "$@"
