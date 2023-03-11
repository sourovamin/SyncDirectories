#!/bin/bash

# Sync Directories
#
# This script synchronizes two folders: source and replica
#
# Usage:
#     ./sync.sh src_dir dst_dir log_file(optional)
#
# Arguments:
#     <src_dir>: The directory to be replicated
#     <dst_dir>: The identical destination directory
#     <log_files>: The file where all the operations logged in, default: ../sync.log
#
# Examples:
#     ./sync.sh path/src_dir path/dst_dir path/log_file.log
#     ./sync.sh path/src_dir path/dst_dir
#
# Author: Hossain Amin
# Date: 2023-03-11

# Get the values from command arguments
src_dir="$1"
dst_dir="$2"
log_file="$3"

# Set the log file path if not provided
if [ -z "$log_file" ]; then
  log_file="../sync.log"
fi

# Function to log messages to the log file and console
log() {
  message="$(date "+%Y-%m-%d %H:%M:%S"): $1"
  echo "$message" | tee -a "$log_file"
}

# Check if src_dir argument is provided and is valid
if [ -z "$1" ]; then
  log "Eoorr: Source directory not provided\nUsage: $0 src_dir dst_dir log_file(optional)"
  exit 2
  if [ ! -d "$1" ]; then
    log "Error: Source Directory $1 is invalid"
    exit 3
  fi
  if [ ! -r "$1" ]; then
    log "Error: Source Directory $1 access denied"
    exit 4
  fi
fi

# Check if dst_dir argument is provided and is valid
if [ -z "$2" ]; then
  log "Eoorr: Destination directory not provided\nUsage: $0 src_dir dst_dir log_file(optional)"
  exit 2
  if [ ! -d "$2" ]; then
    log "Error: Destination Directory $1 is invalid"
    exit 3
  fi
  if [ ! -w "$1" ]; then
    log "Error: Destination Directory $1 access denied"
    exit 4
  fi
fi

# Function to synchronize directories
sync_dirs() {
  # Loop through each file and subdirectory in the source directory
  for file in "$1"/*
  do
    # Get the filename or subdirectory name
    filename=$(basename "$file")
  
    # Check if the file or subdirectory exists in the destination directory
    if [ -e "$2/$filename" ]; then
      # Check if it is a file or a directory
      if [ -f "$file" ]; then
        # Check if the file is different from the file in the destination directory
        if ! cmp -s "$file" "$2/$filename"; then
          # If the file is different, sync the content
          cp "$file" "$2/$filename"
          log "Sync $file content to $2/$filename"
        fi
      else
        # If it is a directory, synchronize the directory recursively
        sync_dirs "$file" "$2/$filename"
      fi
    else
      # If the file or subdirectory does not exist, copy it to the destination directory
      # Check if it is file, and copy the file
      if [ -f "$file" ]; then
        cp "$file" "$2/$filename"
        log "Copied $file to create $2/$filename"
      else
        # If it is a directory log the creation and recursively do the sync operations
        mkdir "$2/$filename"
        log "Directory created: $2/$filename"
        sync_dirs "$file" "$2/$filename"
      fi
    fi
  done

  # Loop through each file and subdirectory in the destination directory for remove operation
  for file in "$2"/*
  do
    # Get the filename or subdirectory name
    filename=$(basename "$file")
  
    # Check if the file or subdirectory exists in the source directory
    if [ ! -e "$1/$filename" ]; then
      # If the file or subdirectory does not exist in the source directory, delete it from the destination directory
      for d_file in "$file"/*
      do
        log "Deleted $d_file from destination directory"
      done
      rm -rf "$file"
    fi
  done
}

# Call the sync_dirs function to synchronize the directories
sync_dirs "$src_dir" "$dst_dir"