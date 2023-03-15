# SyncDirectories

The shell scripts (sync.ps1 for powershell, sync.sh for shell) synchronizes two folders: source and replica.
It maintains a full, identical copy of source directory at replica directory and logs all the operations.

## Usage
PowerShell
```
pwsh sync.ps1 src_dir dst_dir log_file(optional)
```

Shell
```
./sync.sh src_dir dst_dir log_file(optional)
```

## Arguments
```
- `src_dir`: The directory to be replicated
- `dst_dir`: The identical destination directory
- `log_file`: The file where all the operations logged in, default: `../sync.log`
```

## Examples
PowerShell
```
pwsh sync.ps1 path/src_dir path/dst_dir path/log_file.log
pwsh sync.ps1 path/src_dir path/dst_dir
```

Shell
```
./sync.sh path/src_dir path/dst_dir path/log_file.log
./sync.sh path/src_dir path/dst_dir
```
