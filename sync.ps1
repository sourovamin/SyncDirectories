# Sync Directories
#
# This script synchronizes two folders: source and replica
#
# Usage:
#     pwsh sync.ps1 src_dir dst_dir log_file(optional)
#
# Arguments:
#     <src_dir>: The directory to be replicated
#     <dst_dir>: The identical destination directory
#     <log_files>: The file where all the operations logged in, default: ../sync.log
#
# Examples:
#     pwsh sync.ps1 path/src_dir path/dst_dir path/log_file.log
#     pwsh sync.ps1 path/src_dir path/dst_dir
#
# Author: Hossain Amin
# Date: 2023-03-15

# Get the values from command arguments
param (
  $src_dir,
  $dst_dir,
  $log_file = "..\sync.log"
)

# Function to log messages to the log file and console
function log($msg) {
  $message = "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): $msg"
  Write-Output $message | Tee-Object -FilePath $log_file -Append
}

# Check if src_dir argument is provided
if ($src_dir -eq $null -or $src_dir -eq "") {
  log "Error: Source directory is not provided`nUsage: pwsh $($MyInvocation.MyCommand.Name) src_dir dst_dir log_file(optional)"
  exit 2
}

# Check if src_dir is a valid directory
if (-not (Test-Path $src_dir -PathType Container)) {
  log "Error: Provided source directory, $src_dir is not a valid directory"
  exit 3
}

# Check if dst_dir argument is provided
if ($dst_dir -eq $null -or $dst_dir -eq "") {
  log "Error: Destination directory is not provided`nUsage: pwsh $($MyInvocation.MyCommand.Name) src_dir dst_dir log_file(optional)"
  exit 2
}

# Check if dst_dir is a valid directory
if (-not (Test-Path $dst_dir -PathType Container)) {
  log "Error: Provided destination directory, $dst_dir is not a valid directory"
  exit 3
}

# Function to synchronize directories
function sync_dirs($src, $dst) {
  # Loop through each file and subdirectory in the source directory
  Get-ChildItem $src | ForEach-Object {
    # Get the filename or subdirectory name
    $filename = $_.Name

    # Check if the file or subdirectory exists in the destination directory
    if (Test-Path "$dst\$filename") {
      # Check if it is a file or a directory
      if ($_.PSIsContainer -eq $false) {
        # Check if the file is different from the file in the destination directory
        if ((Get-FileHash $_.FullName -Algorithm SHA256).Hash -ne (Get-FileHash "$dst\$filename" -Algorithm SHA256).Hash) {
          # If the file is different, sync the content
          Copy-Item $_.FullName "$dst\$filename" -Force
          log "Sync $($_.FullName) content to $dst\$filename"
        }
      }
      else {
        # If it is a directory, synchronize the directory recursively
        sync_dirs $_.FullName "$dst\$filename"
      }
    }
    else {
      # If the file or subdirectory does not exist, copy it to the destination directory
      # Check if it is file, and copy the file
      if ($_.PSIsContainer -eq $false) {
        Copy-Item $_.FullName "$dst\$filename"
        log "Copied $($_.FullName) to create $dst\$filename"
      }
      else {
        # If it is a directory log the creation and recursively do the sync operations
        New-Item -ItemType Directory -Path "$dst\$filename"
        log "Directory created: $dst\$filename"
        sync_dirs $_.FullName "$dst\$filename"
      }
    }
  }

  # Loop through each file and subdirectory in the destination directory for remove operation
  Get-ChildItem -Path $dst | ForEach-Object {
    # Get the filename or subdirectory name
    $filename = $_.Name
      
    # Check if the file or subdirectory exists in the source directory
    if (!(Test-Path "$src/$filename")) {
      # If the file or subdirectory does not exist in the source directory
      # Log the deletation process
      Get-ChildItem -Path $_.FullName | ForEach-Object {
        log "Deleted $($_.FullName) from destination directory"
      }
      # delete files from the destination directory recursively
      Remove-Item -Recurse -Force $_.FullName
    }
  }

}

# Call the sync_dirs function to synchronize the directories
sync_dirs $src_dir $dst_dir