#!/bin/bash

# Installation script for transcription tools
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color definitions
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Transcription Tools Installer${NC}"
echo "Setting up your environment..."

# Make scripts executable
echo -e "${YELLOW}Making scripts executable...${NC}"
chmod +x "${SCRIPT_DIR}/transcribe_video.sh"
chmod +x "${SCRIPT_DIR}/extract_audio_for_macwhisper.sh"
chmod +x "${SCRIPT_DIR}/lib/utils.sh"

# Check if directories exist, create them if not
echo -e "${YELLOW}Setting up directory structure...${NC}"
mkdir -p "${SCRIPT_DIR}/input"
mkdir -p "${SCRIPT_DIR}/output"

# Check for VLC
echo -e "${YELLOW}Checking for VLC...${NC}"
if [ ! -d "/Applications/VLC.app" ]; then
    echo -e "${RED}VLC not found!${NC}"
    echo -e "Please install VLC from ${GREEN}https://www.videolan.org/vlc/${NC}"
else
    echo -e "${GREEN}VLC found.${NC}"
fi

# Check for Whisper
echo -e "${YELLOW}Checking for Whisper...${NC}"
if ! command -v whisper &> /dev/null; then
    echo -e "${RED}Whisper not found!${NC}"
    echo -e "Would you like to install Whisper using pip? (y/n)"
    read -r install_whisper
    if [[ $install_whisper =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installing Whisper...${NC}"
        pip install openai-whisper
    else
        echo -e "You can install Whisper later using: ${GREEN}pip install openai-whisper${NC}"
    fi
else
    echo -e "${GREEN}Whisper found.${NC}"
fi

# Check for MacWhisper
echo -e "${YELLOW}Checking for MacWhisper...${NC}"
if [ ! -d "/Applications/MacWhisper.app" ]; then
    echo -e "${YELLOW}MacWhisper not found.${NC}"
    echo -e "MacWhisper is optional. You can get it from: ${GREEN}https://goodsnooze.gumroad.com/l/macwhisper${NC}"
else
    echo -e "${GREEN}MacWhisper found.${NC}"
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo -e "You can now use the transcription tools:"
echo -e "  - ${BLUE}./transcribe_video.sh${NC} <video_file> - Transcribe video using Whisper"
echo -e "  - ${BLUE}./extract_audio_for_macwhisper.sh${NC} <video_file> - Extract audio for MacWhisper"
echo ""
echo -e "Place your videos in the ${YELLOW}input/${NC} directory for organization."
echo -e "Transcripts and audio files will be saved to the ${YELLOW}output/${NC} directory."
