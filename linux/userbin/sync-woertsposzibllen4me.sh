#!/bin/bash
WSL_SOURCE="/home/avario/woertsposzibllen4me"
WIN_DEST="/mnt/c/Users/ville/woertsposzibllen4me"

# Check if src directory exists
if [ ! -d "$WSL_SOURCE/src" ]; then
    echo "Error: $WSL_SOURCE/src directory not found"
    exit 1
fi

# Initial sync of src only
echo "Starting src/ sync from WSL to Windows..."
rsync -av "$WSL_SOURCE/src/" "$WIN_DEST/src/"
echo "Initial src/ sync complete"

# Watch for changes in src directory only
inotifywait -m -r -e close_write "$WSL_SOURCE/src" |
while read path action file; do
    rsync -av "$WSL_SOURCE/src/" "$WIN_DEST/src/" > /dev/null 2>&1 &
    echo "$(date '+%H:%M:%S'): Synced src/$file"
done
