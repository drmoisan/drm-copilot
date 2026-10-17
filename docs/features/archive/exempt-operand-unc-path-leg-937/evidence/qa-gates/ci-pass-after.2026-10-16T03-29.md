# CI pass-after evidence (P3-T10)

Timestamp: 2026-10-16T03-29
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38844097853
EXIT_CODE: 0
Output Summary: Job `poshqc / PowerShell hook suites (Linux)` concluded success on headSha fd138e1ca59604664df87e14b44df5e1a15cb7c2; job `poshqc / PowerShell QC` concluded success; run conclusion success; all 17 jobs concluded success. Issue #937 rows: COUNT_MATCHED=46, COUNT_PASSED=46, COUNT_FAILED=0. Invariant rows: COUNT_MATCHED=29, COUNT_FAILED=0, COUNT_SKIPPED=0. Unfiltered: 6335 matched, 6335 passed, COUNT_FAILED=0.

## Run

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38844097853
- databaseId: 38844097853
- headSha: fd138e1ca59604664df87e14b44df5e1a15cb7c2
- P3-T9 head (`git rev-parse HEAD`, re-checked at resume): fd138e1ca59604664df87e14b44df5e1a15cb7c2 (match)
- status: completed
- Run conclusion: success
- Source: SCRATCH/ci-final-run.json (saved by the orchestrator; event workflow_dispatch), read with `poetry run python -I SCRATCH/run_json.py SCRATCH/ci-final-run.json` (EXIT_CODE 0)

## Jobs (name | conclusion)

| Job | Conclusion |
|---|---|
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| docs-validation / Documentation Validation | success |
| poshqc / PowerShell hook suites (Linux) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| security-scan / Security Scanning | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| poshqc / PowerShell QC | success |
| build-check / Build Package | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| NPM Audit Gate / npm audit (.) | success |

## Pre-existing non-success jobs

Source: `evidence/baseline/ci-baseline-run.2026-10-16T01-32.md` (latest `ci-baseline-run.*.md`). Every one of its 17 jobs concluded `success`, so the pre-existing list is empty: none. Every baseline-success job also concludes `success` here.

## JUnit check 1: issue #937 rows

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-final-linux/pester-junit-linux-hooks.xml "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" "(issue #937)"
EXIT_CODE: 0

```
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
COUNT_MATCHED=46
COUNT_PASSED=46
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## JUnit check 2: invariant rows (AC-10, AC-11)

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-final-linux/pester-junit-linux-hooks.xml "U01 " "U02 " "U03 " "U04 " "U05 " "U14 " "U16 " "C1bCoverage.Tests.ps1" "targets.Parity.Tests.ps1"
EXIT_CODE: 0

```
PASSED	discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED	discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED	enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps all four surface copies of the targets module byte-identical by SHA256 hash
PASSED	enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every surface copy of the targets module under the 500-line cap
PASSED	enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every line of every surface copy at or under 120 characters (issue #903, #732 CR-4)
PASSED	preimplementation gate targets (.claude/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.claude/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.claude/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.claude/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.claude/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.claude/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.claude/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets (.codex/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.codex/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.codex/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.codex/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.codex/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.codex/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.codex/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).removes one trailing slash from a rooted path
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).removes one trailing slash from a backslash-spelled drive path
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).keeps the bare POSIX root unchanged
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).keeps a bare drive root unchanged
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).resolves a segment without -C to a session root given with a trailing slash
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).removes one trailing slash from a rooted path
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).removes one trailing slash from a backslash-spelled drive path
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).keeps the bare POSIX root unchanged
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).keeps a bare drive root unchanged
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).resolves a segment without -C to a session root given with a trailing slash
COUNT_MATCHED=29
COUNT_PASSED=29
COUNT_FAILED=0
COUNT_SKIPPED=0
```

Composition of the 29 matches: 14 U01 to U05, U14, and U16 rows (7 per surface), 3 Parity suite rows, 10 C1bCoverage suite rows (`coverage remediation` describe, 5 per surface), and 2 discovery-guard rows whose names contain the two suite filenames. COUNT_MATCHED=29 meets the minimum of 20.

## JUnit check 3: unfiltered

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-final-linux/pester-junit-linux-hooks.xml
EXIT_CODE: 0

```
COUNT_MATCHED=6335
COUNT_PASSED=6335
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Acceptance

| Condition | Observed | Result |
|---|---|---|
| `poshqc / PowerShell QC` concludes success | success | met |
| `poshqc / PowerShell hook suites (Linux)` concludes success | success | met |
| Every baseline-success job concludes success | 17 of 17 success | met |
| Check 1 prints COUNT_MATCHED=46, COUNT_PASSED=46, COUNT_FAILED=0 | 46 / 46 / 0 | met |
| Check 2 prints COUNT_FAILED=0, COUNT_SKIPPED=0, COUNT_MATCHED >= 20 | 0 / 0 / 29 | met |
| Check 3 prints COUNT_FAILED=0 | 0 | met |

This run is provisional evidence for AC-15; AC-15 is checked off at S9 against the PR head.
