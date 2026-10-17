# CI Pass-After Run, Cycle 2 (issue #937)

Timestamp: 2026-10-16T12-27
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38898218767
EXIT_CODE: 0
Output Summary: Run 38898218767 (workflow_dispatch, ci.yml) on headSha 72554509671c82e39885469359a77659aecb67a7 (equals the P4-T10 commit and the reported HEAD) concluded success; all 17 jobs concluded success, including poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux). Linux JUnit: TESTCASES=6374 (T + 17 = 6357 + 17), FAILED=0. F1 COUNT_MATCHED=84 COUNT_PASSED=84; F2 COUNT_MATCHED=14 COUNT_PASSED=14; FM COUNT_MATCHED=64 COUNT_PASSED=64; FOLD COUNT_MATCHED=109 (X - 56 = 165 - 56) COUNT_FAILED=0; FNEW COUNT_MATCHED=67 COUNT_PASSED=67; FINV COUNT_MATCHED=27 (= I) COUNT_FAILED=0 COUNT_SKIPPED=0; unfiltered COUNT_FAILED=0.

Task: P4-T11 (remediation-plan.2026-10-16T08-40.md), stage `c2final`. The `gh` steps were run by the orchestrator (handoff); the run JSON was saved as `SCRATCH/ci-c2final-run.json` and the artifacts were downloaded to `SCRATCH/ci-c2final-linux/` and `SCRATCH/ci-c2final-windows/`. `J` = `SCRATCH/ci-c2final-linux/pester-junit-linux-hooks.xml`. This run is provisional evidence for AC-15, which is checked off at S9 against the PR head.

## Run identity (from SCRATCH/ci-c2final-run.json)

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38898218767
- databaseId: 38898218767
- headSha: 72554509671c82e39885469359a77659aecb67a7
- Reported HEAD (`git rev-parse HEAD` at handoff and at resume): 72554509671c82e39885469359a77659aecb67a7 (match)
- status: completed
- conclusion: success

## Baseline values (from remediation-baseline/ci-baseline-run-c2.2026-10-16T10-33.md)

- T (Linux TESTCASES at the c2 baseline): 6357
- X (FOLD COUNT_MATCHED at the c2 baseline): 165
- I (FINV COUNT_MATCHED at the c2 baseline): 27
- Jobs that did not conclude `success` at the c2 baseline (pre-existing): none (all 17 jobs concluded success).

## Acceptance check

| Condition | Expected | Observed | Result |
|---|---|---|---|
| poshqc / PowerShell QC | success | success | PASS |
| poshqc / PowerShell hook suites (Linux) | success | success | PASS |
| Every job successful at the c2 baseline is successful here | 17 of 17 | 17 of 17 | PASS |
| F1 | COUNT_MATCHED=84, COUNT_PASSED=84 | 84, 84 | PASS |
| F2 | COUNT_MATCHED=14, COUNT_PASSED=14 | 14, 14 | PASS |
| FM | COUNT_MATCHED=64, COUNT_PASSED=64 | 64, 64 | PASS |
| FOLD | COUNT_MATCHED=109 (X - 56), COUNT_FAILED=0 | 109, 0 | PASS |
| FNEW | COUNT_MATCHED=67, COUNT_PASSED=67 | 67, 67 | PASS |
| FINV | COUNT_MATCHED=27 (I), COUNT_FAILED=0, COUNT_SKIPPED=0 | 27, 0, 0 | PASS |
| Unfiltered | COUNT_FAILED=0 | 0 | PASS |
| junit_totals TESTCASES | 6374 (T + 17) | 6374 | PASS |

## Jobs

| Job | Conclusion |
|---|---|
| poshqc / PowerShell QC | success |
| build-check / Build Package | success |
| docs-validation / Documentation Validation | success |
| poshqc / PowerShell hook suites (Linux) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| security-scan / Security Scanning | success |
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (.) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |

## Command: poetry run python -I SCRATCH/run_json.py SCRATCH/ci-c2final-run.json

EXIT_CODE: 0

```text
databaseId=38898218767
headSha=72554509671c82e39885469359a77659aecb67a7
url=https://github.com/drmoisan/drm-copilot/actions/runs/38898218767
status=completed
conclusion=success
JOB	poshqc / PowerShell QC	success
JOB	build-check / Build Package	success
JOB	docs-validation / Documentation Validation	success
JOB	poshqc / PowerShell hook suites (Linux)	success
JOB	quality-checks7 / Code Quality & Tests (3.11)	success
JOB	NPM Audit Gate / npm audit (extensions/drm-copilot)	success
JOB	quality-checks7 / Code Quality & Tests (3.13)	success
JOB	security-scan / Security Scanning	success
JOB	shell-coverage / Shell Coverage (Bats + kcov)	success
JOB	quality-checks7 / Code Quality & Tests (3.12)	success
JOB	quality-checks7 / Code Quality & Tests (3.10)	success
JOB	root-typescript-tests / Root TypeScript Tests (windows-latest)	success
JOB	drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
JOB	drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
JOB	NPM Audit Gate / npm audit (.)	success
JOB	NPM Audit Gate / npm audit (packages/mcp-server)	success
JOB	root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
```

## Command: poetry run python -I SCRATCH/junit_totals.py J

EXIT_CODE: 0

```text
ROOT_TAG=testsuites
ROOT_TESTS=6374
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=6374
FAILED=0
SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" "U32 keeps" "(issue #937)" "(issue #937 RI-" (F1)

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
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.claude/hooks).U32 keeps a relative path-leg input with a later colon on the session root
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
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U32 keeps a relative path-leg input with a later colon on the session root
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)
COUNT_MATCHED=84
COUNT_PASSED=84
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "for http-uri" "for smb-uri" "for vscode-remote-uri" "for scheme-plus-uri" "(issue #937 RI-7)" (F2)

EXIT_CODE: 0

```text
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)
COUNT_MATCHED=14
COUNT_PASSED=14
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" (FM)

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
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
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
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
COUNT_MATCHED=64
COUNT_PASSED=64
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "gate-targets.Tests.ps1" (FOLD)

EXIT_CODE: 0

```text
PASSED	discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED	preimplementation gate targets (.claude/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.claude/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.claude/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.claude/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.claude/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.claude/hooks).U06 denies an unbalanced segment
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for cd
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for pushd
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for popd
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for chdir
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for Set-Location
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for sl
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for Push-Location
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for Pop-Location
PASSED	preimplementation gate targets (.claude/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED	preimplementation gate targets (.claude/hooks).U09 denies a substitution-bearing git segment
PASSED	preimplementation gate targets (.claude/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.claude/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.claude/hooks).U11c gives git-relocation for an env-drive assignment
PASSED	preimplementation gate targets (.claude/hooks).U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U13 collects every value of a repeated -C selector
PASSED	preimplementation gate targets (.claude/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.claude/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED	preimplementation gate targets (.claude/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets (.claude/hooks).U17 gives selector-missing-value for a trailing -C
PASSED	preimplementation gate targets (.claude/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED	preimplementation gate targets (.claude/hooks).U19 resolves a chained command to the session root and the selector
PASSED	preimplementation gate targets (.claude/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED	preimplementation gate targets (.claude/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED	preimplementation gate targets (.claude/hooks).U22 gives none for no epic scope
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved target result
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for an ambiguous target
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved selector target
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for a non-epic target
PASSED	preimplementation gate targets (.claude/hooks).U22 gives evaluate for all-epic targets
PASSED	preimplementation gate targets (.claude/hooks).U23 resolves a target equal to the session root once
PASSED	preimplementation gate targets (.claude/hooks).U24 gives git-command-word-missing for a token array without git
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome none for a none verdict
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome deny for a deny verdict
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome deny for a failing session-root scope
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome deny for a failing non-session-root target
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome allow for an evaluation with no failure
PASSED	preimplementation gate targets (.claude/hooks).U26 gives the exact deny reason for target-ambiguous
PASSED	preimplementation gate targets (.claude/hooks).U26 gives the exact deny reason for target-unresolvable (fall-through)
PASSED	preimplementation gate targets (.codex/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.codex/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.codex/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.codex/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.codex/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.codex/hooks).U06 denies an unbalanced segment
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for cd
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for pushd
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for popd
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for chdir
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for Set-Location
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for sl
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for Push-Location
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for Pop-Location
PASSED	preimplementation gate targets (.codex/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED	preimplementation gate targets (.codex/hooks).U09 denies a substitution-bearing git segment
PASSED	preimplementation gate targets (.codex/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.codex/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.codex/hooks).U11c gives git-relocation for an env-drive assignment
PASSED	preimplementation gate targets (.codex/hooks).U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U13 collects every value of a repeated -C selector
PASSED	preimplementation gate targets (.codex/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.codex/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED	preimplementation gate targets (.codex/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets (.codex/hooks).U17 gives selector-missing-value for a trailing -C
PASSED	preimplementation gate targets (.codex/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED	preimplementation gate targets (.codex/hooks).U19 resolves a chained command to the session root and the selector
PASSED	preimplementation gate targets (.codex/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED	preimplementation gate targets (.codex/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED	preimplementation gate targets (.codex/hooks).U22 gives none for no epic scope
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved target result
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for an ambiguous target
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved selector target
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for a non-epic target
PASSED	preimplementation gate targets (.codex/hooks).U22 gives evaluate for all-epic targets
PASSED	preimplementation gate targets (.codex/hooks).U23 resolves a target equal to the session root once
PASSED	preimplementation gate targets (.codex/hooks).U24 gives git-command-word-missing for a token array without git
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome none for a none verdict
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome deny for a deny verdict
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome deny for a failing session-root scope
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome deny for a failing non-session-root target
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome allow for an evaluation with no failure
PASSED	preimplementation gate targets (.codex/hooks).U26 gives the exact deny reason for target-ambiguous
PASSED	preimplementation gate targets (.codex/hooks).U26 gives the exact deny reason for target-unresolvable (fall-through)
COUNT_MATCHED=109
COUNT_PASSED=109
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "gate-targets.PathNotLocal.Tests.ps1" (FNEW)

EXIT_CODE: 0

```text
PASSED	discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 complies with the baseline isolation form for every closure seam
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
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.claude/hooks).U32 keeps a relative path-leg input with a later colon on the session root
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
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U32 keeps a relative path-leg input with a later colon on the session root
COUNT_MATCHED=67
COUNT_PASSED=67
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "U01 " "U02 " "U03 " "U04 " "U05 " "U14 " "U16 " "coverage remediation (" "surface parity (issue #738)" (FINV)

EXIT_CODE: 0

```text
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
COUNT_MATCHED=27
COUNT_PASSED=27
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J (no filters)

EXIT_CODE: 0

```text
COUNT_MATCHED=6374
COUNT_PASSED=6374
COUNT_FAILED=0
COUNT_SKIPPED=0
```

No `FAILED` or `MESSAGE` lines were printed by any run.
