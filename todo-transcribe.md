# Todo-Transcribe: Meeting Transcription Pipeline with Zealot

## Overview

This document outlines the plan for implementing a containerized meeting transcription pipeline using Zealot for development automation. The pipeline will:

1. Process meeting video files
2. Generate high-quality transcriptions
3. Extract meeting notes and action items
4. Maintain a clean, containerized development environment

## Design Philosophy: Built for Clarity

Following our core design principle of "clarity over complexity," we will:

- Create simple, focused components with clear interfaces
- Use modular architecture for easy testing and maintenance
- Apply SOLID principles throughout the codebase
- Avoid premature optimization and unnecessary abstractions
- Document thoroughly as we develop

## Development Structure

### Directory Structure

```
transcribe-demo/
├── config/                      # Configuration files
│   ├── default.yaml             # Default configuration
│   ├── development.yaml         # Development environment config
│   └── zealot/                  # Zealot configuration files
│       ├── dev_stages.yaml      # Development stage definitions
│       ├── test_scenarios.yaml  # Test scenario definitions
│       └── review_checklist.yaml # Code review guidelines
├── docker/
│   ├── Dockerfile               # Main application Dockerfile
│   ├── Dockerfile.dev           # Development environment Dockerfile
│   └── docker-compose.yml       # Docker Compose services definition
├── src/
│   ├── core/                    # Core application logic
│   ├── processors/              # Video/audio processing modules
│   ├── transcribers/            # Transcription engines
│   ├── extractors/              # Meeting notes/action extractors
│   └── utils/                   # Common utilities
├── tests/
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── fixtures/                # Test fixtures
├── zealot_loop.py               # Zealot development loop script
├── run.py                       # Main application entry point
└── README.md                    # Project documentation
```

## Zealot Development Loop

The Zealot development loop will:

1. Read configuration from YAML files in the `config/zealot` directory
2. Execute development stages based on configurations
3. Generate code, tests, and documentation
4. Provide review and feedback

### Stage Definitions in `dev_stages.yaml`:

```yaml
stages:
  - name: plan
    description: "Generate detailed implementation plan"
    input: 
      - component_name
      - feature_description
    output:
      - implementation_plan.md
      - interface_definitions.py
  
  - name: develop
    description: "Implement the component based on the plan"
    input:
      - implementation_plan.md
      - interface_definitions.py
    output:
      - component_code.py
      - component_tests.py
  
  - name: test
    description: "Execute tests and validate implementation"
    input:
      - component_code.py
      - component_tests.py
    output:
      - test_results.json
      - coverage_report.xml
  
  - name: review
    description: "Review code quality and suggest improvements"
    input:
      - component_code.py
      - test_results.json
      - coverage_report.xml
    output:
      - review_notes.md
      - refactoring_suggestions.md
```

## Docker Development Environment

All development and testing will be done in Docker containers to ensure consistency and clean environments.

### Docker Compose Services:

1. **zealot-dev**: Development environment with code mounted as volume
2. **zealot-test**: Testing environment for isolated testing
3. **whisper**: Containerized Whisper service for transcription
4. **postgres**: Database for storing transcription data

## Implementation Phases

### Phase 1: Environment Setup

1. Create Docker environment with all necessary dependencies
2. Set up Zealot configuration for development loop
3. Implement basic configuration management
4. Create test fixtures and sample meeting videos

### Phase 2: Video Processing

1. Design video input processing module
2. Implement video metadata extraction
3. Create audio extraction pipeline
4. Build audio optimization for transcription

### Phase 3: Whisper Integration

1. Create Whisper CLI wrapper
2. Implement model configuration management
3. Build transcription optimization
4. Add error handling and retry logic

### Phase 4: Transcript Analysis

1. Implement transcript parsing
2. Create topic identification algorithm
3. Build action item extraction
4. Develop meeting notes formatting

### Phase 5: Integration and Testing

1. Connect all components in main pipeline
2. Implement end-to-end testing
3. Create performance benchmarks
4. Add documentation and examples

## Zealot Loop Script

```python
#!/usr/bin/env python3

import os
import sys
import yaml
import argparse
import subprocess
from pathlib import Path

def load_config(config_path):
    """Load configuration from YAML file."""
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def run_zealot(stage, component, config):
    """Run a Zealot development stage."""
    print(f"Running Zealot for stage: {stage} on component: {component}")
    
    # Create workspace directory
    workspace_dir = Path(f".zealot_workspace/{component}/{stage}")
    workspace_dir.mkdir(parents=True, exist_ok=True)
    
    # Prepare input files based on stage configuration
    stage_config = next((s for s in config['stages'] if s['name'] == stage), None)
    if not stage_config:
        print(f"Error: Stage {stage} not found in configuration")
        sys.exit(1)
    
    # Build the Docker command
    docker_cmd = [
        "docker", "run", "--rm",
        "-v", f"{os.path.abspath('.')}:/app",
        "-w", "/app",
        "--env", "ZEALOT_STAGE=" + stage,
        "--env", "ZEALOT_COMPONENT=" + component,
        "zealot-dev:latest",
        "python", "-m", "zealot.runner",
        "--stage", stage,
        "--component", component
    ]
    
    # Execute the Zealot process in the Docker container
    result = subprocess.run(docker_cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print("Zealot execution failed:")
        print(result.stderr)
        sys.exit(1)
    
    print(result.stdout)
    print(f"Zealot {stage} completed successfully for {component}")
    
    # Process outputs according to stage configuration
    # TODO: Handle stage outputs based on configuration

def main():
    parser = argparse.ArgumentParser(description="Zealot Development Loop")
    parser.add_argument("stage", choices=["plan", "develop", "test", "review"], 
                        help="Development stage to execute")
    parser.add_argument("component", help="Component to work on")
    parser.add_argument("--config", default="config/zealot/dev_stages.yaml",
                        help="Path to Zealot configuration file")
    
    args = parser.parse_args()
    
    # Load configuration
    try:
        config = load_config(args.config)
    except Exception as e:
        print(f"Error loading configuration: {e}")
        sys.exit(1)
    
    # Run the requested Zealot stage
    run_zealot(args.stage, args.component, config)

if __name__ == "__main__":
    main()
```

## Docker Configuration

### `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Whisper
RUN pip install --no-cache-dir \
    openai-whisper \
    torch \
    torchaudio \
    pydantic \
    pyyaml \
    pytest \
    pytest-cov

# Copy application files
COPY . .

# Set up the application
RUN pip install --no-cache-dir -e .

# Default command
CMD ["python", "run.py"]
```

### `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - ./input:/app/input
      - ./output:/app/output
    environment:
      - CONFIG_FILE=/app/config/default.yaml
    command: python run.py

  zealot-dev:
    build:
      context: .
      dockerfile: docker/Dockerfile.dev
    volumes:
      - .:/app
    environment:
      - ZEALOT_MODE=development

  zealot-test:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - ./tests:/app/tests
      - ./output:/app/output
    environment:
      - CONFIG_FILE=/app/config/test.yaml
    command: python -m pytest tests/

  whisper:
    image: onerahmet/openai-whisper-asr-webservice:latest
    environment:
      - ASR_MODEL=base
      - ASR_ENGINE=openai_whisper
    ports:
      - "9000:9000"
    volumes:
      - ./input:/tmp
```

## Workflow Automation Script

```bash
#!/bin/bash
# run.sh - Script to execute the meeting transcription pipeline

# Setup environment
docker compose build

# Process a meeting file
process_meeting() {
  local meeting_file="$1"
  echo "Processing meeting file: $meeting_file"
  
  # Run the pipeline in Docker
  docker compose run --rm app python run.py --input "$meeting_file"
}

# Main execution loop
if [ "$1" = "watch" ]; then
  # Watch mode - monitor input directory for new files
  echo "Watching input directory for new meeting files..."
  inotifywait -m -e close_write -e moved_to --format '%w%f' ./input/ | while read file
  do
    if [[ "$file" =~ \.(mp4|webm|mkv)$ ]]; then
      process_meeting "$file"
    fi
  done
else
  # One-time process mode
  if [ -z "$1" ]; then
    echo "Usage: $0 <meeting_file.mp4> or $0 watch"
    exit 1
  fi
  
  process_meeting "$1"
fi
```

## Zealot Development Loop Usage

To use the Zealot development loop:

1. Build the Docker images:
   ```bash
   docker compose build
   ```

2. Run a development stage:
   ```bash
   python zealot_loop.py plan video_processor
   python zealot_loop.py develop video_processor
   python zealot_loop.py test video_processor
   python zealot_loop.py review video_processor
   ```

3. Execute the complete pipeline:
   ```bash
   ./run.sh meeting_recording.mp4
   ```

4. Monitor a directory for new meeting files:
   ```bash
   ./run.sh watch
   ```

## Next Steps

1. Set up the Docker environment
2. Create initial configuration files
3. Implement the Zealot development loop script
4. Build the first component (video processing) using the Zealot loop
5. Test the containerized workflow with sample meeting files
