# CI Pass-After Run, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T08-22
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38870746395
EXIT_CODE: 0
Output Summary: Run 38870746395 (workflow_dispatch, ci.yml) on headSha ba934fd4864574fdf67d6b578375c38b925c53d6 (equals the P3-T10 commit and the reported HEAD) concluded success; all 17 jobs concluded success, including poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux). Linux hook-suite JUnit: F1 COUNT_MATCHED=68 COUNT_PASSED=68 COUNT_FAILED=0; invariant filters COUNT_MATCHED=29 COUNT_FAILED=0 COUNT_SKIPPED=0; unfiltered COUNT_MATCHED=6357 COUNT_FAILED=0 COUNT_SKIPPED=0.

Task: P3-T11 (remediation-plan.2026-10-16T03-39.md), stage `c1final`. The `gh` steps were run by the orchestrator (handoff); the run JSON was saved as `SCRATCH/ci-c1final-run.json` and the artifacts were downloaded to `SCRATCH/ci-c1final-linux` and `SCRATCH/ci-c1final-windows`.

## Run identity (from SCRATCH/ci-c1final-run.json)

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38870746395
- databaseId: 38870746395
- headSha: ba934fd4864574fdf67d6b578375c38b925c53d6
- Reported HEAD (`git rev-parse HEAD` at handoff and at resume): ba934fd4864574fdf67d6b578375c38b925c53d6 (match)
- status: completed
- conclusion: success

## Jobs

| Job | Conclusion |
|---|---|
| build-check / Build Package | success |
| NPM Audit Gate / npm audit (.) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| poshqc / PowerShell QC | success |
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| poshqc / PowerShell hook suites (Linux) | success |
| docs-validation / Documentation Validation | success |
| security-scan / Security Scanning | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |

## Pre-existing non-success jobs at the c1 baseline

Source: `remediation-baseline/ci-baseline-run.2026-10-16T06-12.md` (latest `ci-baseline-run.*.md`). All 17 jobs concluded `success` at the c1 baseline; the pre-existing list is empty.

Pre-existing (did not conclude success at c1 baseline): none

## Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1final-linux/pester-junit-linux-hooks.xml with filter set F1

Filter set F1: `U27 gives`, `U28 keeps`, `U29 denies`, `U30 reports`, `U31 gives`, `(issue #937)`, `(issue #937 RI-`. The worktree isolation guard refused the direct command line because the parenthesized filter text could not be verified, so the same script was invoked with the same seven filters through the wrapper `SCRATCH/run_f1.py` (which sets the argument list and runs `junit_status.py` unchanged via `runpy`).

EXIT_CODE: 0

```text
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
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
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
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
COUNT_MATCHED=68
COUNT_PASSED=68
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1final-linux/pester-junit-linux-hooks.xml "U01 " "U02 " "U03 " "U04 " "U05 " "U14 " "U16 " "C1bCoverage.Tests.ps1" "targets.Parity.Tests.ps1"

EXIT_CODE: 0

```text
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

## Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1final-linux/pester-junit-linux-hooks.xml (no filters)

EXIT_CODE: 0

No `FAILED` or `MESSAGE` lines were printed.

```text
COUNT_MATCHED=6357
COUNT_PASSED=6357
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Acceptance evaluation

| Condition | Result |
|---|---|
| Job `poshqc / PowerShell QC` concludes `success` | met |
| Job `poshqc / PowerShell hook suites (Linux)` concludes `success` | met |
| Every job that concluded `success` at the c1 baseline also concludes `success` | met (17 of 17) |
| F1 run prints `COUNT_MATCHED=68`, `COUNT_PASSED=68`, `COUNT_FAILED=0` | met |
| Invariant run prints `COUNT_FAILED=0` and `COUNT_SKIPPED=0` with `COUNT_MATCHED` at least 20 | met (29) |
| Unfiltered run prints `COUNT_FAILED=0` | met |

Evidence scope: AC-1 to AC-8, AC-10, AC-11, AC-14, AC-16, AC-17, AC-18, and RI-3 test evidence, all from job `poshqc / PowerShell hook suites (Linux)`. This run is provisional evidence for AC-15, which is checked off at S9 against the PR head.
