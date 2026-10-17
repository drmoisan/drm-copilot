# PoshQC Test Fail-Before, Remediation Cycle 2 (issue #937 RI-7)

Timestamp: 2026-10-16T11-00
Task: P2-T12 [expect-fail] (remediation-plan.2026-10-16T08-40.md)
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = WORKTREE, scan_folders = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"])
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: MCP ok = false (mapped to EXIT_CODE 1), the expected fail-before result. The latest poshqc-test-baseline-c2 artifact (2026-10-16T10-04) records LocalOkBaseline: true, so the local flag is discriminating. Supplementary read of the JUnit file this run wrote: COUNT_MATCHED=6374, COUNT_FAILED=14; the 14 failing testcases are exactly the 8 new U27 rows (http-uri, smb-uri, vscode-remote-uri, scheme-plus-uri on both surfaces) and the 6 (issue #937 RI-7) gate rows. P2-T14 remains the authoritative CI fail-before evidence.

MCP summary (verbatim): "Command exited with code 14."

## Supplementary: poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml (PASSED lines omitted)

This read is a supplementary micro-check of the file the MCP run wrote; it is not a plan-required command. MESSAGE lines are recorded verbatim.

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
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an http URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an http URI path in epic scope (issue #937 RI-7) in epic scope, but they were different.  Expected length: 4  Actual length:   5  Strings differ at index 0.  Expected: 'deny'  But was:  'allow'             ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an smb URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to an smb URI path in epic scope (issue #937 RI-7) in epic scope, but they were different.  Expected length: 4  Actual length:   5  Strings differ at index 0.  Expected: 'deny'  But was:  'allow'             ^
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)
MESSAGE	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies a Write to a vscode-remote URI path in epic scope (issue #937 RI-7) in epic scope, but they were different.  Expected length: 4  Actual length:   5  Strings differ at index 0.  Expected: 'deny'  But was:  'allow'             ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch http URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch http URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different.  Expected length: 4  Actual length:   5  Strings differ at index 0.  Expected: 'deny'  But was:  'allow'             ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch smb URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch smb URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different.  Expected length: 4  Actual length:   5  Strings differ at index 0.  Expected: 'deny'  But was:  'allow'             ^
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)
MESSAGE	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7)	Expected strings to be the same, because denies an apply_patch vscode-remote URI marker in epic scope (issue #937 RI-7) in epic scope, but they were different.  Expected length: 4  Actual length:   5  Strings differ at index 0.  Expected: 'deny'  But was:  'allow'             ^
COUNT_MATCHED=6374
COUNT_PASSED=6360
COUNT_FAILED=14
COUNT_SKIPPED=0
```

## Acceptance

- LocalOkBaseline is true and `ok` is false (`EXIT_CODE: 1`): met.
