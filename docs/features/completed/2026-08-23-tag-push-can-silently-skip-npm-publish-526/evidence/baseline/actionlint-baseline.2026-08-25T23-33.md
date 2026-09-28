# Actionlint Baseline (P0-T6)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `pwsh ./scripts/dev-tools/run-actionlint.ps1`

EXIT_CODE: 0

## Observed Output

```
Running actionlint...
```

The script emitted its banner line and no diagnostics. The exit code was captured explicitly rather
than inferred, by reading `$LASTEXITCODE` immediately after the invocation:

```
ACTIONLINT_EXIT_CODE=0
```

## Findings

- Workflow-YAML diagnostics reported: 0
- Files failing the lint: 0

Output Summary: `pwsh ./scripts/dev-tools/run-actionlint.ps1` exited 0 with no workflow-YAML
diagnostics against the baseline commit `afbf51dfe6508319a2d673603d31825077d8cddb`. This establishes
the clean pre-change baseline the task requires: every `.github/workflows/` file in the repository
currently passes actionlint, so any non-zero actionlint result recorded later by P4-T6, P5-T6, or
P7-T5 is attributable to the workflow changes this plan makes — the `pull_request` trigger and
ref-guard edits to `.github/workflows/publish-mcp-npm.yml` and the new
`.github/workflows/verify-published-releases.yml` — and not to pre-existing debt. AC25 depends on
this attribution.
