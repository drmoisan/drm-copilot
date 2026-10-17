# CI fail-before run, remediation cycle 1 (P1-T18) [expect-fail]

Timestamp: 2026-10-16T07-02
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38862518700
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Job `poshqc / PowerShell hook suites (Linux)` concluded failure on headSha 3c6b38fb5736f5493a5a828ac2e18ac3b8525029, as expected before the cycle 1 fix. Run conclusion failure. F1 run: COUNT_MATCHED=68, COUNT_PASSED=46, COUNT_FAILED=22, COUNT_SKIPPED=0. F2 run: COUNT_MATCHED=22, COUNT_FAILED=22. Unfiltered run: COUNT_MATCHED=6357, COUNT_FAILED=22; the unfiltered FAILED set is exactly the 22 F2 testcases (baseline failed set empty). Each of the 16 failing U27 MESSAGE lines contains `but got $true`; each of the 6 `(issue #937 RI-` MESSAGE lines contains 'allow'. No deviation.

## Run

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38862518700
- databaseId: 38862518700
- headSha: 3c6b38fb5736f5493a5a828ac2e18ac3b8525029
- P1-T17 commit (`git rev-parse HEAD` reported at handoff and re-checked at resume): 3c6b38fb5736f5493a5a828ac2e18ac3b8525029 (match)
- status: completed
- Run conclusion: failure
- Source: SCRATCH/ci-c1failbefore-run.json (saved by the orchestrator; event workflow_dispatch)

## poshqc job conclusions

| Job | Conclusion |
|---|---|
| poshqc / PowerShell hook suites (Linux) | failure |
| poshqc / PowerShell QC | failure |

All other 15 jobs in SCRATCH/ci-c1failbefore-run.json concluded success: security-scan / Security Scanning; docs-validation / Documentation Validation; NPM Audit Gate / npm audit (extensions/drm-copilot), (.), (packages/mcp-server); build-check / Build Package; quality-checks7 / Code Quality & Tests (3.10), (3.11), (3.12), (3.13); drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest), (ubuntu-latest); root-typescript-tests / Root TypeScript Tests (ubuntu-latest), (windows-latest); shell-coverage / Shell Coverage (Bats + kcov).

## Acceptance check

- Run conclusion `failure`: met.
- Job `poshqc / PowerShell hook suites (Linux)` concludes `failure`: met.
- F1 run prints COUNT_MATCHED=68, COUNT_FAILED=22, COUNT_PASSED=46: met.
- F2 run prints COUNT_MATCHED=22 and COUNT_FAILED=22: met.
- Unfiltered FAILED set equals the 22 F2 testcases plus the baseline failed set (empty per ci-baseline-run.2026-10-16T06-12.md, COUNT_FAILED=0): met. The unfiltered FAILED lines are identical, line for line, to the F2 FAILED lines (COUNT_FAILED=22 in both). COUNT_MATCHED rose from 6335 at the c1 baseline to 6357 (+22 new testcases: 16 U27 and 6 gate rows).
- MESSAGE line of each of the 16 failing U27 testcases contains `but got $true`: met.
- MESSAGE line of each of the 6 `(issue #937 RI-` testcases contains 'allow': met.
- U30 with its completed RI-3 assertions passed on both surfaces, as the plan predicts: met.
- Deviations: none (no missing expected failure, no unexpected extra failure).

## F1 JUnit check

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1failbefore-linux/pester-junit-linux-hooks.xml "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" "(issue #937)" "(issue #937 RI-"
EXIT_CODE: 0

Printed output (verbatim):

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
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc	Expected $false, because leading-space-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute	Expected $false, because leading-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute	Expected $false, because trailing-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive	Expected $false, because file-uri-drive is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc	Expected $false, because file-uri-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward	Expected $false, because tilde-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash	Expected $false, because tilde-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash	Expected $false, because root-relative-backslash is not a local path and must not resolve to the session root, but got $true.
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
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc	Expected $false, because leading-space-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute	Expected $false, because leading-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute	Expected $false, because trailing-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive	Expected $false, because file-uri-drive is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc	Expected $false, because file-uri-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward	Expected $false, because tilde-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash	Expected $false, because tilde-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash	Expected $false, because root-relative-backslash is not a local path and must not resolve to the session root, but got $true.
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies a Write to a file: URI path in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies a Write to a home-relative path in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)	Expected strings to be the same, because denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies an apply_patch file: URI marker in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies an apply_patch home-relative marker in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)	Expected strings to be the same, because denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=68
COUNT_PASSED=46
COUNT_FAILED=22
COUNT_SKIPPED=0
```

## F2 JUnit check

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1failbefore-linux/pester-junit-linux-hooks.xml "for leading-space-" "for trailing-space-" "for file-uri-" "for tilde-" "for root-relative-" "(issue #937 RI-"
EXIT_CODE: 0

Printed output (verbatim):

```
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc	Expected $false, because leading-space-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute	Expected $false, because leading-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute	Expected $false, because trailing-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive	Expected $false, because file-uri-drive is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc	Expected $false, because file-uri-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward	Expected $false, because tilde-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash	Expected $false, because tilde-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash	Expected $false, because root-relative-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc	Expected $false, because leading-space-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute	Expected $false, because leading-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute	Expected $false, because trailing-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive	Expected $false, because file-uri-drive is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc	Expected $false, because file-uri-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward	Expected $false, because tilde-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash	Expected $false, because tilde-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash	Expected $false, because root-relative-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies a Write to a file: URI path in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies a Write to a home-relative path in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)	Expected strings to be the same, because denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies an apply_patch file: URI marker in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies an apply_patch home-relative marker in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)	Expected strings to be the same, because denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=22
COUNT_PASSED=0
COUNT_FAILED=22
COUNT_SKIPPED=0
```

## Unfiltered JUnit check

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-c1failbefore-linux/pester-junit-linux-hooks.xml
EXIT_CODE: 0

Printed output (verbatim; with no filters the script prints only FAILED and MESSAGE lines plus the counts):

```
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc	Expected $false, because leading-space-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute	Expected $false, because leading-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute	Expected $false, because trailing-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive	Expected $false, because file-uri-drive is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc	Expected $false, because file-uri-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward	Expected $false, because tilde-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash	Expected $false, because tilde-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash	Expected $false, because root-relative-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc	Expected $false, because leading-space-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute	Expected $false, because leading-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute	Expected $false, because trailing-space-absolute is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive	Expected $false, because file-uri-drive is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc	Expected $false, because file-uri-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward	Expected $false, because tilde-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash	Expected $false, because tilde-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash	Expected $false, because root-relative-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies a Write to a file: URI path in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies a Write to a home-relative path in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)	Expected strings to be the same, because denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies an apply_patch file: URI marker in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)	Expected strings to be the same, because denies an apply_patch home-relative marker in epic scope (issue #937 RI-4) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)	Expected strings to be the same, because denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=6357
COUNT_PASSED=6335
COUNT_FAILED=22
COUNT_SKIPPED=0
```
