#!/bin/bash
################################################################################
# generate_backup_script.sh
#
# This script interactively gathers backup parameters, lets you choose a method
# (scp, rsync, or tar+scp), and generates a standalone backup script that you can
# run directly or schedule via cron.
################################################################################

# Function: create_and_write_script
# Accepts parameters to create a standalone backup script
create_and_write_script() {
  local method="$1"
  local src="$2"
  local ruser="$3"
  local rhost="$4"
  local rdest="$5"
  local outfile="$6"

  # Write the chosen backup commands to $outfile
  # We'll put a simple header and the command(s) needed.
  cat <<EOF > "$outfile"
#!/bin/bash
################################################################################
# Auto-Generated Backup Script
#
# Method: $method
# Source: $src
# Destination: $ruser@$rhost:$rdest
################################################################################

EOF

  # Add method-specific commands
  if [[ "$method" == "rsync" ]]; then
    cat <<EOF >> "$outfile"
# Using rsync to mirror local files to remote:
rsync -avz --delete --progress "$src" "$ruser@$rhost:$rdest"
EOF

  elif [[ "$method" == "scp" ]]; then
    cat <<EOF >> "$outfile"
# Using scp to copy local files/folders to remote:
scp -r "$src" "$ruser@$rhost:$rdest"
EOF

  elif [[ "$method" == "tar+scp" ]]; then
    cat <<EOF >> "$outfile"
# Using tar to compress the source, then scp to transfer:
timestamp=\$(date +'%Y%m%d_%H%M%S')
tar_name="backup_\${timestamp}.tar.gz"

# Create tar.gz from the source
tar -czf "\$tar_name" -C "\$(dirname "$src")" "\$(basename "$src")"

# Transfer the tar.gz to the remote
scp "\$tar_name" "$ruser@$rhost:$rdest"

# (Optional) remove the local tar file after successful transfer
# rm -f "\$tar_name"
EOF

  else
    echo "Unknown method. Exiting." >> "$outfile"
  fi

  # Make the generated script executable
  chmod +x "$outfile"
}

# Welcome message
clear
echo "############################################"
echo "#   Interactive Backup Script Generator    #"
echo "############################################"
echo
echo "This tool will help you create a backup script for one of the following methods:"
echo "  1) rsync"
echo "  2) scp"
echo "  3) tar + scp"
echo

# Prompt for method
read -p "Select backup method (1=rsync, 2=scp, 3=tar+scp): " method_choice

# Convert numeric choice to a label we can use
case "$method_choice" in
  1) METHOD="rsync" ;;
  2) METHOD="scp" ;;
  3) METHOD="tar+scp" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# Gather backup parameters
echo
read -p "Enter the LOCAL path you want to back up (e.g., /home/user/data): " SRC
read -p "Enter the REMOTE username (e.g., vagrant): " RUSER
read -p "Enter the REMOTE host or IP (e.g., 192.168.1.146): " RHOST
read -p "Enter the REMOTE path to store the backup (e.g., /home/vagrant/backups): " RDEST

# Prompt for output script name
echo
read -p "Enter a filename for the new backup script (e.g., my_backup_script.sh): " OUTFILE

# Create the script
create_and_write_script "$METHOD" "$SRC" "$RUSER" "$RHOST" "$RDEST" "$OUTFILE"

echo
echo "A new script '$OUTFILE' has been created with the following settings:"
echo "  Method: $METHOD"
echo "  Source: $SRC"
echo "  Destination: $RUSER@$RHOST:$RDEST"
echo
echo "You can run it manually anytime via:"
echo "  ./$OUTFILE"
echo

# (Optional) ask if user wants to run it now
read -p "Do you want to run the generated script now? (y/n): " run_now
if [[ "$run_now" =~ ^[Yy]$ ]]; then
  echo "Running ./$OUTFILE ..."
  ./"$OUTFILE"
fi

# (Optional) ask if user wants to schedule the script in cron
echo
read -p "Would you like to schedule this backup script via cron? (y/n): " cron_choice
if [[ "$cron_choice" =~ ^[Yy]$ ]]; then
  read -p "Enter cron schedule (e.g., '0 2 * * *' for daily 2 AM): " cron_schedule
  full_path="$(realpath "$OUTFILE")"
  # Append to current user's crontab
  (
    crontab -l 2>/dev/null
    echo "$cron_schedule $full_path"
  ) | crontab -
  echo "Cron job added: $cron_schedule $full_path"
fi

echo
echo "Done! Your backup script is ready at: $OUTFILE"
echo "------------------------------------------------------------------"
