# Video Transcription Tools

A collection of command-line scripts for extracting audio from video files and transcribing them using Whisper AI.

## Scripts

### `transcribe_video.sh`

Extracts audio from a video file and transcribes it using OpenAI's Whisper model.

```bash
./transcribe_video.sh <input_mp4_file> [destination_directory]
```

Features:
- Extracts audio using VLC
- Transcribes using Whisper AI (base model)
- Saves both audio and transcript files

### `extract_audio_for_macwhisper.sh`

Extracts audio from a video file for use with the MacWhisper app.

```bash
./extract_audio_for_macwhisper.sh <input_mp4_file> [destination_directory]
```

Features:
- Extracts audio using VLC
- Formats audio for optimal transcription (16-bit PCM, 16kHz)
- Automatically opens MacWhisper with the audio file (if installed)

## Requirements

- VLC: For audio extraction (`/Applications/VLC.app`)
- Whisper: For transcription (`pip install openai-whisper`)
- MacWhisper: Optional GUI app for manual transcription

## Installation

1. Clone this repository
2. Make scripts executable:

```bash
chmod +x transcribe_video.sh extract_audio_for_macwhisper.sh
```

## Potential Improvements

- Add support for more video formats (currently only MP4)
- Implement batch processing for multiple files
- Add options for different Whisper models (tiny, small, medium, large)
- Add language selection options
- Implement error handling for large files
- Add timestamp generation in transcripts
