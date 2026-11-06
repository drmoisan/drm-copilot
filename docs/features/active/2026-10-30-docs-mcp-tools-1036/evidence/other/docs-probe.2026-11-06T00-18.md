# Docs Round-Trip Probe ([P8-T12])

Timestamp: 2026-11-06T00-18
Command: sh SCRATCH/issue-1036-docs-probe.sh, which runs the PowerShell 7 helper SCRATCH/issue-1036-docs-probe.ps1 from the worktree root. For each tool the helper executes `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <subcommand> -Json -Profile examples/docs/v1/docs-profile.example.json <options>`, with the options of the tool's spec `### Example invocations` input in declarative-table order (`update_docs_ledger` as the `sync-refs` dry run; `validate_docs_artifacts` with `-Mode profile -Revision <HEAD full revision>`). It checks that stdout is one JSON object whose sorted keys are exactly `command, exit_code, findings, ok, result`, whose `exit_code` equals the process exit code and whose `command` equals the subcommand, and for `generate_docs_reference` it compares the sorted `result` keys with `mode, output_directory, pages, summary, unrendered`. `git status --porcelain` is captured before and after.
EXIT_CODE: 0
Output Summary:
PROBE: run_docs_check | exit=3 | envelope=valid
PROBE: run_docs_inventory | exit=0 | envelope=valid
PROBE: run_docs_coverage | exit=1 | envelope=valid
PROBE: update_docs_ledger | exit=1 | envelope=valid
PROBE: generate_docs_reference | exit=1 | envelope=valid | result-keys=match
PROBE: validate_docs_artifacts | exit=0 | envelope=valid

- `git status --porcelain` before and after: identical (11 lines each; all are this feature's untracked evidence files). No probe run changed the tree.
- PowerShell version: 7.6.9.
- No `envelope=invalid`, `result-keys=differs` or `result-keys=null` line, and the status is unchanged, so no BLOCKED outcome is recorded.
- Observations for the orchestrator: the exit codes are the docs commands' own results for the example profile run against this repository (the example profile describes an example repository, so findings are expected). `run_docs_check` returned exit 3 inside a valid envelope; the probe asserts envelope validity only and did not classify that finding. The `check` run took about six minutes of wall time on this host, because the example profile's documentation root is `docs`. Confirmation F4 (Windows quoting and non-ASCII stdout through `pwsh -File`): all six stdout documents parsed as JSON; no quoting or encoding defect was observed for these inputs.
