# SyncDirectories

This shell script sync.sh synchronizes two folders: source and replica.
It maintains a full, identical copy of source directory at replica directory and logs all the operations.

## Usage
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
```
./sync.sh path/src_dir path/dst_dir path/log_file.log
./sync.sh path/src_dir path/dst_dir
```
