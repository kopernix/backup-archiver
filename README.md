# Backup Script

## Description
This is a mini script for archiving directory backups without pretensions. It compresses and encrypts directories while saving an MD5 checksum for each backup.

## Features
- Compresses folders to `.tar.gz`.
- Encrypts the archive using GPG.
- Saves an MD5 checksum for each encrypted backup.

## Usage
Run the script with the desired folder to backup, and specify an output directory if needed.

### Example
```bash
./01_backups_archive.sh -d folder_to_backup -o /path/to/output
