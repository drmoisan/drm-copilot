# CI fail-before run (P1-T13) [expect-fail]

Timestamp: 2026-10-16T02-20
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38838282195
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Job `poshqc / PowerShell hook suites (Linux)` concluded failure on headSha 01fdeaf6a0771d2d0c19e6a1d0fc1a69ac65b97b, as expected before the fix. Run conclusion failure. Filtered JUnit check: COUNT_MATCHED=46, COUNT_PASSED=4 (the four `U28 keeps` testcases), COUNT_FAILED=42, COUNT_SKIPPED=0. Unfiltered FAILED set is exactly the 42 expected testcases (6335 testcases total; baseline failed set empty). Each of the 6 `(issue #937)` MESSAGE lines contains 'allow'; each of the 36 U27/U29/U30/U31 MESSAGE lines contains `but got $true`. No deviation.

## Run

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38838282195
- databaseId: 38838282195
- headSha: 01fdeaf6a0771d2d0c19e6a1d0fc1a69ac65b97b
- P1-T12 commit (`git rev-parse HEAD` reported at handoff and re-checked): 01fdeaf6a0771d2d0c19e6a1d0fc1a69ac65b97b (match)
- status: completed
- Run conclusion: failure
- Source: SCRATCH/ci-failbefore-run.json (saved by the orchestrator; event workflow_dispatch)

## poshqc job conclusions

| Job | Conclusion |
|---|---|
| poshqc / PowerShell hook suites (Linux) | failure |
| poshqc / PowerShell QC | failure |

All other jobs in SCRATCH/ci-failbefore-run.json concluded success: docs-validation / Documentation Validation; build-check / Build Package; shell-coverage / Shell Coverage (Bats + kcov); NPM Audit Gate / npm audit (packages/mcp-server); NPM Audit Gate / npm audit (.); NPM Audit Gate / npm audit (extensions/drm-copilot); quality-checks7 / Code Quality & Tests (3.10), (3.11), (3.12), (3.13); drm-copilot-extension-tests (windows-latest), (ubuntu-latest); root-typescript-tests (ubuntu-latest), (windows-latest); security-scan / Security Scanning.

## Acceptance check

- Run conclusion `failure`: met.
- Job `poshqc / PowerShell hook suites (Linux)` concludes `failure`: met.
- Filtered run prints COUNT_MATCHED=46, COUNT_FAILED=42, COUNT_PASSED=4; the 4 PASSED lines are the `U28 keeps` testcases: met.
- Unfiltered FAILED set equals the 42 expected testcases plus the baseline failed set (empty per ci-baseline-run.2026-10-16T01-32.md): met (unfiltered COUNT_FAILED=42; filtering out the five expected-failing substrings leaves no FAILED line).
- MESSAGE lines for the 6 `(issue #937)` testcases contain 'allow': met.
- MESSAGE lines for the 36 failing U27, U29, U30, U31 testcases contain `but got $true`: met.

## Filtered JUnit check

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-failbefore-linux/pester-junit-linux-hooks.xml "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" "(issue #937)"
EXIT_CODE: 0

Printed output (verbatim):

```
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash	Expected $false, because unc-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward	Expected $false, because unc-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first	Expected $false, because unc-mixed-backslash-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first	Expected $false, because unc-mixed-forward-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash	Expected $false, because bare-double-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward	Expected $false, because bare-double-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash	Expected $false, because extended-length-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward	Expected $false, because extended-length-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc	Expected $false, because extended-length-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash	Expected $false, because device-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward	Expected $false, because device-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash	Expected $false, because nt-object-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward	Expected $false, because nt-object-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative	Expected $false, because drive-relative is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter	Expected $false, because bare-drive-letter is not a local path and must not resolve to the session root, but got $true.
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
FAILED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
MESSAGE	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid	Expected $false, because one non-local path makes the whole call unresolvable, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
MESSAGE	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path	Expected $false, because a UNC path is not a local path, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
MESSAGE	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path	Expected $false, because an extended-length marker path is not a local path, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash	Expected $false, because unc-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward	Expected $false, because unc-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first	Expected $false, because unc-mixed-backslash-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first	Expected $false, because unc-mixed-forward-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash	Expected $false, because bare-double-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward	Expected $false, because bare-double-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash	Expected $false, because extended-length-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward	Expected $false, because extended-length-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc	Expected $false, because extended-length-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash	Expected $false, because device-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward	Expected $false, because device-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash	Expected $false, because nt-object-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward	Expected $false, because nt-object-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative	Expected $false, because drive-relative is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter	Expected $false, because bare-drive-letter is not a local path and must not resolve to the session root, but got $true.
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
FAILED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
MESSAGE	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid	Expected $false, because one non-local path makes the whole call unresolvable, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
MESSAGE	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path	Expected $false, because a UNC path is not a local path, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
MESSAGE	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path	Expected $false, because an extended-length marker path is not a local path, but got $true.
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)	Expected strings to be the same, because denies a Write to a UNC path in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)	Expected strings to be the same, because denies a Write to an extended-length path in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)	Expected strings to be the same, because denies a Write to a drive-relative path in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)	Expected strings to be the same, because denies an apply_patch UNC file marker in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)	Expected strings to be the same, because denies an apply_patch extended-length file marker in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)	Expected strings to be the same, because denies an apply_patch drive-relative file marker in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=46
COUNT_PASSED=4
COUNT_FAILED=42
COUNT_SKIPPED=0
```

## Unfiltered JUnit check

Command: poetry run python -I SCRATCH/junit_status.py SCRATCH/ci-failbefore-linux/pester-junit-linux-hooks.xml
EXIT_CODE: 0

Printed output (verbatim; with no filters the script prints only FAILED and MESSAGE lines plus the counts):

```
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash	Expected $false, because unc-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward	Expected $false, because unc-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first	Expected $false, because unc-mixed-backslash-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first	Expected $false, because unc-mixed-forward-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash	Expected $false, because bare-double-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward	Expected $false, because bare-double-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash	Expected $false, because extended-length-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward	Expected $false, because extended-length-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc	Expected $false, because extended-length-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash	Expected $false, because device-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward	Expected $false, because device-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash	Expected $false, because nt-object-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward	Expected $false, because nt-object-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative	Expected $false, because drive-relative is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter
MESSAGE	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter	Expected $false, because bare-drive-letter is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
MESSAGE	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid	Expected $false, because one non-local path makes the whole call unresolvable, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
MESSAGE	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path	Expected $false, because a UNC path is not a local path, but got $true.
FAILED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
MESSAGE	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path	Expected $false, because an extended-length marker path is not a local path, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash	Expected $false, because unc-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward	Expected $false, because unc-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first	Expected $false, because unc-mixed-backslash-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first	Expected $false, because unc-mixed-forward-first is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash	Expected $false, because bare-double-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward	Expected $false, because bare-double-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash	Expected $false, because extended-length-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward	Expected $false, because extended-length-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc	Expected $false, because extended-length-unc is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash	Expected $false, because device-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward	Expected $false, because device-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash	Expected $false, because nt-object-backslash is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward	Expected $false, because nt-object-forward is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative	Expected $false, because drive-relative is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter
MESSAGE	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter	Expected $false, because bare-drive-letter is not a local path and must not resolve to the session root, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
MESSAGE	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid	Expected $false, because one non-local path makes the whole call unresolvable, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
MESSAGE	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path	Expected $false, because a UNC path is not a local path, but got $true.
FAILED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
MESSAGE	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path	Expected $false, because an extended-length marker path is not a local path, but got $true.
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)	Expected strings to be the same, because denies a Write to a UNC path in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)	Expected strings to be the same, because denies a Write to an extended-length path in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)	Expected strings to be the same, because denies a Write to a drive-relative path in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)	Expected strings to be the same, because denies an apply_patch UNC file marker in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)	Expected strings to be the same, because denies an apply_patch extended-length file marker in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)	Expected strings to be the same, because denies an apply_patch drive-relative file marker in epic scope (issue #937) in epic scope, but they were different. Expected length: 4 Actual length:   5 Strings differ at index 0. Expected: 'deny' But was:  'allow'            ^
COUNT_MATCHED=6335
COUNT_PASSED=6293
COUNT_FAILED=42
COUNT_SKIPPED=0
```
