# Transcribe Demo

A collection of shell scripts for audio and video transcription with various output formats.

## Features

- Extract audio from video files
- Transcribe audio to text in multiple formats (SRT, VTT, TXT)
- Batch processing capability
- Customizable audio quality settings
- Optional timestamp generation
- Detailed logging

## Scripts

- `transcribe_video.sh`: Main script for transcribing video files
- `extract_audio_for_macwhisper.sh`: Helper script to extract audio for processing
- `lib/utils.sh`: Utility functions and shared code
- `config/default.conf`: Configuration settings

## Requirements

- Mac environment
- VLC for media processing
- MacWhisper for transcription

## Installation

Run the included install script to set up dependencies:

```bash
./install.sh
```

## Usage

```bash
./transcribe_video.sh --input video.mp4 --format srt,vtt,txt
```

See individual script help text for detailed usage information.

## License

MIT