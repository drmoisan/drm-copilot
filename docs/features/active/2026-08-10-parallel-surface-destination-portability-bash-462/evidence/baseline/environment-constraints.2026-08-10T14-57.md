# Binding Environment Constraints — Issue #462

Timestamp: 2026-08-10T14-57

Task: [P0-T2]
Command: (documentation task; no command executed)
EXIT_CODE: 0

This artifact restates the three binding environment constraints from the plan's
"Binding Environment Constraints" section so that they cannot be reintroduced during
execution. Each is a verified fact about this win32 host, not a caution.

## Constraint 1 — Bash verification is CI-only

shfmt, shellcheck, bats, and kcov cannot be executed on this win32 host. Per
`.claude/rules/shell.md`, the shell toolchain runs under WSL locally and on
`ubuntu-latest` in CI. Verified precedent: issues #393 and #394.

Every shell verification in this plan is therefore a CI dispatch, spelled out exactly as:

```
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25
gh run list --workflow=_shell-coverage.yml --branch drm-copilot-wt-2026-08-10T09-25 --limit 1 --json databaseId,url,headSha,status,conclusion
gh run watch <run-id>
gh run view <run-id> --json conclusion,url,headSha
gh run view <run-id> --log | grep "Bash coverage (lines)"
```

Rules:

- No local bats, shfmt, shellcheck, or kcov run may be attempted or recorded.
- A shell stage is recorded as passed only when a dispatched run exists, its URL and
  conclusion are captured, and the printed `Bash coverage (lines): NN.N%` line is read.
- The workflow has no coverage-threshold gate: a low-coverage run still concludes
  `success`. The >= 85% threshold must be enforced by reading the printed coverage line,
  never inferred from the run conclusion.
- From [P1-T6] onward each dispatch must show two green steps: the `check` step
  (`bash scripts/bash/shell-qc.sh check`) and the coverage step
  (`bash scripts/bash/shell-qc.sh test --coverage`).

## Constraint 2 — `poetry run python -c` with a multi-line string is silent

On this host, `poetry run python -c` given a multi-line string produces no output and
exits 0 without executing the code (verified 2026-08-10). A command that returns no
output has not run; that must never be read as success.

Permitted inline Python forms:

- single-line `poetry run python -c "..."`
- plain `python -c "import sys; sys.path.insert(0,'.'); ..."`
- a committed script file invoked normally

Prohibited form: any multi-line `poetry run python -c` string.

## Constraint 3 — `validate_orchestrator_state.py` has no `__main__` guard

`scripts/dev_tools/validate_orchestrator_state.py` defines no `__main__` guard, so
`python -m scripts.dev_tools.validate_orchestrator_state ...` exits 0 without validating
anything, including for a missing file. That CLI form must never be used as evidence.
No task in this plan uses it. Repairing the defect is out of scope for #462 and is
recorded in the plan's Open Questions section as a residual gap.

Output Summary: All three binding constraints recorded, with the CI dispatch command
sequence spelled out in full. No command was executed for this task.
