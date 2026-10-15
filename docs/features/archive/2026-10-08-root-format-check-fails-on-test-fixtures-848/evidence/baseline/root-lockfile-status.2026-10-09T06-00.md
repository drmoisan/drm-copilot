# Baseline: lockfile status after npm ci

Timestamp: 2026-10-09T06-00
Command: git status --porcelain -- package-lock.json ; git diff --name-only origin/main -- package-lock.json
EXIT_CODE: 0
Output Summary: both commands exited 0 and printed no output; the install did not modify package-lock.json.
