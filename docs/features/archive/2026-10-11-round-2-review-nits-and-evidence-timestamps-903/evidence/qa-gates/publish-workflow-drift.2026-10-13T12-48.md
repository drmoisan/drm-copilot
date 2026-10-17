# P11-T10 #899 drift check for publish-mcp-npm.yml

Timestamp: 2026-10-13T12-48
Command: git fetch origin main; git diff --stat HEAD origin/main -- ":(glob)*/workflows/publish-mcp-npm.yml"; git status --porcelain -- ":(glob)*/workflows/publish-mcp-npm.yml"
EXIT_CODE: 0
Output Summary:
- `git fetch origin main`: exit 0; `origin/main` is fd81a43b4.
- `git diff --stat HEAD origin/main -- ":(glob)*/workflows/publish-mcp-npm.yml"`: exit 0, empty output. The workflow file is identical between the branch HEAD (523d1123c) and `origin/main`.
- `git status --porcelain -- ":(glob)*/workflows/publish-mcp-npm.yml"`: exit 0, empty output. There is no working-tree change to the workflow file.
- Pathspec non-vacuity check: `git ls-files -- ":(glob)*/workflows/publish-mcp-npm.yml"` lists the tracked workflow file at repository depth two, so the empty diff is not caused by a pathspec that matches nothing. The last `origin/main` commit touching the file is 9a6e0aa7e (#723).
- No `RECHECK-ON-MERGE` marker is needed: #899 has not changed `publish-mcp-npm.yml` on `origin/main` as of this check. No workflow edit was made.
