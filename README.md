# Backup Script

## Description
This is a mini script for archiving directory backups without pretensions. It compresses and encrypts directories while saving an MD5 checksum for each backup.

## Features
- Compresses folders to `.tar.gz`.
- Encrypts the archive using GPG.
- Saves an MD5 checksum for each encrypted backup.

## Requirements
- tar
- gpg
- md5sum

## Usage
Run the script with the desired folder to backup, and specify an output directory if needed.

- **`-d <directory>`**: Specify a specific directory to back up. If no directory is provided, the script will back up **all directories** in the current working directory, excluding the base directory itself.
- **`-o <output_directory>`**: Define a custom output directory where the backups will be saved. If not specified, the script will use a default directory called `./backups` in the current path.
- **`-e <directory>`**: Excluding from backup-archive, by default ./scripts, ./.git and ./backups are excluded

### Example Usage:

1. **Back up all directories in the current path and store them in the default output directory (`./backups`)**:
   ```bash
   ./01_backups_archive.sh
   ```

2. **Back up a specific directory**:
   ```bash
   ./01_backups_archive.sh -d specific_folder
   ```

3. **Back up a specific directory and set a custom output directory**:
   ```bash
   ./01_backups_archive.sh -d specific_folder -o /path/to/output
   ```

4. **Back up all directories in the current path and set a custom output directory**:
   ```bash
   ./01_backups_archive.sh -o /path/to/output
   ```

5. **Back up all directories in the current and exclude ./nobackup directory**:
   ```bash
   ./01_backups_archive.sh -e nobackup
   ```

### Important Notes:
- The script will prompt for a GPG password to encrypt each backup.
- Each encrypted backup is stored with a `.gpg` extension, and an accompanying `.md5` file is generated for checksum verification.
- Logs are created in the base directory with the format: `YYYYMMDD-HHMM.backup-archiver.log`.
- scripts directory is excluded

### Test
Create 5 example folders

```bash
    ./scripts/create_test_folders.sh
```
