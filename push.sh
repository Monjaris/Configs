#!/bin/bash
# ========================
# PUSH TO THE GITHUB REPO
# ========================

REPO_URL="https://github.com/Monjaris/Configs.git"
BRANCH="main"

# init git if missing
if [ ! -d ".git" ]; then
    echo ":: [git] initializing repository"
    git init
    git branch -M "$BRANCH"
fi

# add remote if missing
if ! git remote | grep -q "^origin$"; then
    echo ":: [git] adding origin remote"
    git remote add origin "$REPO_URL"
fi

# update remote URL in case it's stale
git remote set-url origin "$REPO_URL"

# stage all files
echo ":: [git] staging files"
git add .

# commit only if changes exist
if ! git diff --cached --quiet; then
    COMMIT_MSG="update configs: $(date '+%Y-%m-%d %H:%M')"
    echo ":: [git] committing"
    git commit -m "$COMMIT_MSG"
else
    echo ":: [git] nothing to commit"
fi

# push
echo ":: [git] pushing to $BRANCH"
git push -u origin "$BRANCH"

echo -e "\nUpdate & push finished."
