# Runbook Body Builder Dry Run (Issue #1074)

Timestamp: 2026-11-04T15-47
Task: [P5-T2]
Command: sh SCRATCH/issue-1074-dryrun.sh (PowerShell 7 script SCRATCH/issue-1074-dryrun.ps1: extracts the runbook's `# Block B` and `# Block C` PowerShell blocks and its two `jq` filter blocks, copies SCRATCH/issue-1074-ruleset-15241672.backup.json to SCRATCH/stage/ruleset-15241672.backup.json, runs only the builder blocks and the jq filters in SCRATCH/stage, and compares each built body with the source)
EXIT_CODE: 0
Output Summary:
- Input files: `SCRATCH/issue-1074-ruleset-15241672.backup.json` (the P0-T3 read-only GET), staged as `SCRATCH/stage/ruleset-15241672.backup.json`. Outputs: `SCRATCH/stage/ruleset-15241672.single-gate.json`, `SCRATCH/stage/ruleset-15241672.rollback.json`, `SCRATCH/stage/jq-single-gate.json`, `SCRATCH/stage/jq-rollback.json`.
- No PUT line and no `gh` command was executed; the script refuses to run a builder block that contains `gh api` or `--method`.
- The saved GET contains `bypass_actors`, so the builder ran on it directly. Additional guard check: on a SCRATCH copy with `bypass_actors` removed, Block B threw `bypass_actors absent: the token lacks write access to the ruleset`, and the jq filter exited 5 with the same error.
- PowerShell single-gate body vs source: `name`, `target`, `enforcement`, `conditions`, `bypass_actors` equal; other rules (`deletion`, `non_fast_forward`, `pull_request`, 3 rules) equal; exactly one `required_status_checks` rule; its other parameters (`strict_required_status_checks_policy`, `do_not_enforce_on_create`) equal; contexts are exactly one entry, `CI Required Gate` with `integration_id` 15368; top-level keys are exactly `name,target,enforcement,bypass_actors,conditions,rules`.
- PowerShell rollback body vs source: the six fields equal, including all 20 required contexts; top-level keys are the six writable fields.
- jq: on PATH and run. jq single-gate body and jq rollback body pass the same comparisons as the PowerShell bodies, and each is equal (canonical JSON comparison) to the corresponding PowerShell body.
- Result: every comparison equal.
