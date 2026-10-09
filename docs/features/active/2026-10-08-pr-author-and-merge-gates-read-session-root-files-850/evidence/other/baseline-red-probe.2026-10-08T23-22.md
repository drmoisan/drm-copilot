# P0-T17 stop diagnosis: deny reason of the failing SET-PRA row (read-only probe)

Timestamp: 2026-10-08T23-22
Command: sh SCRATCH/run-ps.sh SCRATCH/probe-deny.ps1 (dot-sources PRA, replaces the six seams the failing row mocks with identical functions, and evaluates the row's command)
EXIT_CODE: 0
Output Summary:

## Full output

```text
DECISION=deny
REASON=EPIC_BASE_BRANCH_MISMATCH: `gh pr create` must pass `--base epic/enforcement-hook-precision-integration` (`epic_context.integration_branch`) under `epic_mode`; the command does not carry a matching `--base` argument.
```
