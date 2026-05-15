#!/usr/bin/env bash
set -euo pipefail

ISSUE_NUMBER="${1:-}"
REPO="${REPO:-maxlee0218-lgtm/warehouse-rebuild}"
MODE="${CODEX_MODE:-auto-edit}"

if [[ -z "$ISSUE_NUMBER" ]]; then
  echo "Usage: bash scripts/run_codex_issue.sh <issue_number>"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI is not installed or not in PATH."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed or not in PATH."
  exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "ERROR: Codex CLI is not installed or not in PATH."
  echo "Install example: npm install -g @openai/codex"
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[1/5] Pull latest from origin/main"
git pull origin main

TASK_FILE=".codex_task_issue_${ISSUE_NUMBER}.md"

echo "[2/5] Fetch GitHub Issue #${ISSUE_NUMBER} from ${REPO}"
{
  echo "# Codex Task from GitHub Issue #${ISSUE_NUMBER}"
  echo
  gh issue view "$ISSUE_NUMBER" --repo "$REPO" --comments
  echo
  echo "---"
  echo
  echo "# Execution Requirements"
  echo
  echo "You are running inside the local repository. Execute the GitHub Issue task exactly."
  echo
  echo "Hard safety rules:"
  echo "1. Do not modify any production database."
  echo "2. Do not run DROP / DELETE / UPDATE / INSERT / TRUNCATE / INSERT OVERWRITE against any database."
  echo "3. Database SQL must be read-only: SELECT / SHOW / DESC / EXPLAIN only."
  echo "4. Write conclusions into repository files, not only terminal output."
  echo "5. Commit all file changes."
  echo "6. Push to origin/main if the local commit succeeds."
  echo "7. Reply to the GitHub Issue with commit hash, changed files, conclusions, blockers, and next suggested node."
} > "$TASK_FILE"

echo "[3/5] Created task file: $TASK_FILE"
echo "[4/5] Launch Codex CLI in mode: $MODE"

if [[ "$MODE" == "full-auto" ]]; then
  codex --full-auto < "$TASK_FILE"
elif [[ "$MODE" == "auto-edit" ]]; then
  codex --auto-edit < "$TASK_FILE"
else
  codex < "$TASK_FILE"
fi

echo "[5/5] Codex CLI finished. Review git status:"
git status --short

echo
echo "Next checks:"
echo "  git log --oneline -3"
echo "  gh issue view ${ISSUE_NUMBER} --repo ${REPO} --comments"
