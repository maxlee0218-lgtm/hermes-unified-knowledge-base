#!/bin/bash
# Auto-sync script for LLM Wiki
# Runs from cron or systemd timer

WIKI_DIR="/root/wiki"
cd "$WIKI_DIR" || exit 1

# Check if git repo
if [ ! -d .git ]; then
    echo "Not a git repo: $WIKI_DIR"
    exit 1
fi

# Check for changes
if git diff --quiet && git diff --cached --quiet; then
    exit 0
fi

# Auto-commit with timestamp
git add -A
git commit -m "sync: auto-update $(date '+%Y-%m-%d %H:%M:%S')"

# Push if remote exists
if git remote get-url origin >/dev/null 2>&1; then
    git push origin main
fi
