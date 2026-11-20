# CI Fail-Before and RI-8 Move Proof, Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-27
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38892084649
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Run 38892084649 (workflow_dispatch, ci.yml) on headSha 96b20936d33255021353cf0627416f98f0ab80d5 (equals the P2-T13 commit and the reported HEAD) concluded failure. Job poshqc / PowerShell hook suites (Linux) concluded failure, as expected; job poshqc / PowerShell QC also concluded failure; all 15 other jobs concluded success. Linux JUnit: TESTCASES=6374 (T + 17 = 6357 + 17), FAILED=14. F2 COUNT_MATCHED=14 COUNT_FAILED=14; F1 COUNT_MATCHED=84 COUNT_PASSED=70 COUNT_FAILED=14; the unfiltered FAILED set is exactly the 14 F2 testcases (baseline failed set empty). The 8 failing U27 messages contain "but got $true"; the 6 failing (issue #937 RI-7) messages contain "'allow'". Move proof: FM COUNT_MATCHED=64 COUNT_PASSED=56 COUNT_FAILED=8 and cmp of the passed FM name sets against c2baseline exits 0; FOLD COUNT_MATCHED=109 (X - 56 = 165 - 56) COUNT_FAILED=0; FNEW COUNT_MATCHED=67 COUNT_PASSED=59 COUNT_FAILED=8; FDISC COUNT_MATCHED=1 COUNT_PASSED=1. No deviation from the P2-T14 acceptance conditions.

Task: P2-T14 [expect-fail] (remediation-plan.2026-10-16T08-40.md), stage `c2failbefore`. The `gh` steps were run by the orchestrator (handoff); the run JSON was saved as `SCRATCH/ci-c2failbefore-run.json` and the Linux artifact was downloaded to `SCRATCH/ci-c2failbefore-linux/`. `J` = `SCRATCH/ci-c2failbefore-linux/pester-junit-linux-hooks.xml`. The executor ran the helper steps through `sh SCRATCH/c2_p2t14.sh SCRATCH` from the worktree root.

## Values carried from the c2 baseline

Source: `FEATURE/evidence/remediation-baseline/ci-baseline-run-c2.2026-10-16T10-33.md` (the lexicographically greatest `ci-baseline-run-c2.*.md`).

- T (TESTCASES) = 6357
- X (FOLD COUNT_MATCHED) = 165
- I (FINV COUNT_MATCHED) = 27
- Baseline failed set: empty

## Run identity (from SCRATCH/ci-c2failbefore-run.json)

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38892084649
- databaseId: 38892084649
- headSha: 96b20936d33255021353cf0627416f98f0ab80d5
- Reported HEAD (`git rev-parse HEAD` at handoff and at resume): 96b20936d33255021353cf0627416f98f0ab80d5 (match)
- status: completed
- conclusion: failure
- poshqc / PowerShell hook suites (Linux): failure
- poshqc / PowerShell QC: failure (this job runs every suite on windows-latest, including the 14 expect-fail rows; it is not an acceptance condition of this task and is expected to return to success at P4-T11)

## Acceptance check

| Condition | Expected | Observed | Result |
|---|---|---|---|
| Run conclusion | failure | failure | met |
| Linux hook job conclusion | failure | failure | met |
| F2 COUNT_MATCHED / COUNT_FAILED | 14 / 14 | 14 / 14 | met |
| F1 COUNT_MATCHED / COUNT_FAILED / COUNT_PASSED | 84 / 14 / 70 | 84 / 14 / 70 | met |
| Unfiltered FAILED set | 14 F2 testcases plus baseline failed set (empty) | the 14 F2 testcases | met |
| U27 failure messages contain `but got $true` | 8 | 8 | met |
| RI-7 gate failure messages contain `'allow'` | 6 | 6 | met |
| FM COUNT_MATCHED / COUNT_PASSED / COUNT_FAILED | 64 / 56 / 8 | 64 / 56 / 8 | met |
| `cmp SCRATCH/fm-c2baseline.txt SCRATCH/fm-c2failbefore.txt` exit | 0 | 0 | met |
| FOLD COUNT_MATCHED / COUNT_FAILED | X - 56 = 109 / 0 | 109 / 0 | met |
| FNEW COUNT_MATCHED / COUNT_PASSED / COUNT_FAILED | 67 / 59 / 8 | 67 / 59 / 8 | met |
| FDISC COUNT_MATCHED / COUNT_PASSED | 1 / 1 | 1 / 1 | met |
| TESTCASES | T + 17 = 6374 | 6374 | met |

## Jobs

| Job | Conclusion |
|---|---|
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| security-scan / Security Scanning | success |
| build-check / Build Package | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| poshqc / PowerShell QC | failure |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| NPM Audit Gate / npm audit (.) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| poshqc / PowerShell hook suites (Linux) | failure |
| docs-validation / Documentation Validation | success |

## Command: poetry run python -I SCRATCH/run_json.py SCRATCH/ci-c2failbefore-run.json

EXIT_CODE: 0

```text
databaseId=38892084649
headSha=96b20936d33255021353cf0627416f98f0ab80d5
url=https://github.com/drmoisan/drm-copilot/actions/runs/38892084649
status=completed
conclusion=failure
JOB	shell-coverage / Shell Coverage (Bats + kcov)	success
JOB	quality-checks7 / Code Quality & Tests (3.11)	success
JOB	security-scan / Security Scanning	success
JOB	build-check / Build Package	success
JOB	drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	success
JOB	root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	success
JOB	root-typescript-tests / Root TypeScript Tests (windows-latest)	success
JOB	NPM Audit Gate / npm audit (packages/mcp-server)	success
JOB	quality-checks7 / Code Quality & Tests (3.10)	success
JOB	poshqc / PowerShell QC	failure
JOB	NPM Audit Gate / npm audit (extensions/drm-copilot)	success
JOB	quality-checks7 / Code Quality & Tests (3.12)	success
JOB	drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	success
JOB	NPM Audit Gate / npm audit (.)	success
JOB	quality-checks7 / Code Quality & Tests (3.13)	success
JOB	poshqc / PowerShell hook suites (Linux)	failure
JOB	docs-validation / Documentation Validation	success
```

## Command: poetry run python -I SCRATCH/junit_totals.py J

EXIT_CODE: 0

```text
ROOT_TAG=testsuites
ROOT_TESTS=6374
ROOT_FAILURES=14
ROOT_ERRORS=0
TESTCASES=6374
FAILED=14
SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "for http-uri" "for smb-uri" "for vscode-remote-uri" "for scheme-plus-uri" "(issue #937 RI-7)" (F2)

EXIT_CODE: 0

```text
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an http URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an smb URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch http URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch smb URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=14
COUNT_PASSED=0
COUNT_FAILED=14
COUNT_SKIPPED=0
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
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
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
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
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
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an http URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an smb URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch http URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch smb URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=84
COUNT_PASSED=70
COUNT_FAILED=14
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
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
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
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U32 keeps a relative path-leg input with a later colon on the session root
COUNT_MATCHED=67
COUNT_PASSED=59
COUNT_FAILED=8
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "PathNotLocal.Tests.ps1 complies" (FDISC)

EXIT_CODE: 0

```text
PASSED	discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 complies with the baseline isolation form for every closure seam
COUNT_MATCHED=1
COUNT_PASSED=1
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J (no filters)

EXIT_CODE: 0

```text
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an http URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an smb URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch http URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch smb URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=6374
COUNT_PASSED=6360
COUNT_FAILED=14
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" > SCRATCH/fm-c2failbefore-raw.txt (FM)

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
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
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
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for http-uri	Expected $false, because http-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for smb-uri	Expected $false, because smb-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for vscode-remote-uri	Expected $false, because vscode-remote-uri is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for scheme-plus-uri	Expected $false, because scheme-plus-uri is not a local path and must not resolve to the session root, but got $true.
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
COUNT_MATCHED=64
COUNT_PASSED=56
COUNT_FAILED=8
COUNT_SKIPPED=0
```

## Command: grep "^PASSED" SCRATCH/fm-c2failbefore-raw.txt | cut -f2 | tr -d '\r' | sort > SCRATCH/fm-c2failbefore.txt; wc -l < SCRATCH/fm-c2failbefore.txt

EXIT_CODE: 0

```text
56
```

## Command: cmp SCRATCH/fm-c2baseline.txt SCRATCH/fm-c2failbefore.txt

EXIT_CODE: 0

```text
(no output)
```
