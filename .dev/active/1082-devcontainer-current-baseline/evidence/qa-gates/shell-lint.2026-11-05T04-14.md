Timestamp: 2026-11-05T04-14
Started: 2026-11-05T04:14:49.3429964Z
Command: docker exec -u vscode 1a90d86c1591 bash SCRATCH/issue-1082-shell-final.sh lint
EXIT_CODE: 1
Output Summary:

```text

In .devcontainer/post-create.sh line 29:
source "$WORKSPACE_DIR/.devcontainer/lib/workspace.sh"
       ^-- SC1091 (info): Not following: .devcontainer/lib/workspace.sh was not specified as input (see shellcheck -x).

For more information:
  https://www.shellcheck.net/wiki/SC1091 -- Not following: .devcontainer/lib/...
```

Raw output: SCRATCH/issue-1082-shell-lint.log
