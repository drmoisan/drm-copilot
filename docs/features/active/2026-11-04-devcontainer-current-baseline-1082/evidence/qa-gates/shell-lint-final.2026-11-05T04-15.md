Timestamp: 2026-11-05T04-15
Started: 2026-11-05T04:15:09.1738200Z
Command: docker exec -u vscode 1a90d86c1591 bash SCRATCH/issue-1082-shell-final.sh lint
EXIT_CODE: 1
Output Summary:

```text

In .claude/lib/bash/parallel-mutation-cli.sh line 147:
		printf '%s\n' "$PM_ERROR" >&2
                               ^-------^ SC2153 (info): Possible misspelling: PM_ERROR may not be assigned. Did you mean PC_ERRORS?

For more information:
  https://www.shellcheck.net/wiki/SC2153 -- Possible misspelling: PM_ERROR ma...
```

Raw output: SCRATCH/issue-1082-shell-lint-final.log
