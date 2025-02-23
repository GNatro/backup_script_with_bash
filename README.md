
# Interactive Backup Script Generator

This repository contains a **Bash script** that interactively collects backup parameters (local source path, remote user, remote host, and remote destination path) and supports three backup methods:

1.  **rsync**
2.  **scp**
3.  **tar + scp** (tar the files locally, then transfer the tarball via scp)

After you select a method and provide the required information, the script **generates a standalone backup script** that you can run anytime. Additionally, you can choose to schedule the backup with cron so it runs automatically.

----------

## Features

-   **Interactive Prompts**: Collects backup details (source, destination, etc.) step-by-step.
-   **Multiple Methods**: Choose from `rsync`, `scp`, or `tar+scp` for your backup.
-   **Script Generation**: Creates a **separate backup script** (e.g., `my_backup_script.sh`) with the commands tailored to your chosen method and inputs.
-   **Immediate Execution Option**: Optionally run the newly created backup script right away.
-   **Cron Integration**: Optionally add a cron entry to schedule the backup script (e.g., daily at 2 AM).

----------

## Prerequisites

1.  **Bash Shell**: The script runs in a Unix-like environment (Linux, macOS, etc.).
2.  **SSH Setup**:
    -   Ensure you have SSH installed.
    -   If you want **passwordless backups** (especially for cron), set up SSH key-based authentication with the remote server.
3.  **Permissions**: Make the script executable (`chmod +x`).

## Usage

1.  **Clone or Download** this repository.
2.  **Make the script executable**:
    
    bash
    
    CopyEdit
    
    `chmod +x generate_backup_script.sh` 
    
3.  **Run the script**:
    
    bash
    
    CopyEdit
    
    `./generate_backup_script.sh`

1.  **Answer the prompts**:
    -   **Backup method** (1 = rsync, 2 = scp, 3 = tar+scp).
    -   **Local source path** (e.g., `/home/user/myfolder`).
    -   **Remote user** (e.g., `vagrant`).
    -   **Remote host/IP** (e.g., `192.168.1.146`).
    -   **Remote destination path** (e.g., `/home/vagrant/backups`).
    -   **Filename** for the generated script (e.g., `my_backup_script.sh`).
2.  **Optional**:
    -   Run the newly generated script immediately.
    -   Schedule the generated script in **cron**.

----------
