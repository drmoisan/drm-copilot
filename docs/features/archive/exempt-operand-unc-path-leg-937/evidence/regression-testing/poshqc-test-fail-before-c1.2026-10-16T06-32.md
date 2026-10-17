# Local Fail-Before Test Run, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T06-32
Task: P1-T16 [expect-fail] (remediation-plan.2026-10-16T03-39.md)
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE scan_folders=["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: ok=false, as expected (the latest poshqc-test-baseline.*.md records LocalOkBaseline: true, so the local flag is discriminating). Summary (verbatim): "Command exited with code 22." Supplementary read of the JUnit file this run wrote: COUNT_MATCHED=6357, COUNT_PASSED=6335, COUNT_FAILED=22, COUNT_SKIPPED=0; the 22 failed testcases are exactly the 16 new U27 testcases (8 labels on each of .claude/hooks and .codex/hooks) and the 6 new (issue #937 RI-4) and (issue #937 RI-5) gate testcases. The code under test is the unfixed cycle 0 code.

## Baseline reference

- Latest `FEATURE/evidence/remediation-baseline/poshqc-test-baseline.*.md`: `poshqc-test-baseline.2026-10-16T05-51.md`, `LocalOkBaseline: true`.

## Supplementary observation (read-only; not a plan command)

Command: `poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml` (file time 2026-10-16T06-32, written by this run), `MESSAGE` lines omitted.

```text
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
FAILED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
FAILED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
FAILED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
FAILED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
COUNT_MATCHED=6357
COUNT_PASSED=6335
COUNT_FAILED=22
COUNT_SKIPPED=0
```

## Acceptance

`LocalOkBaseline: true` and `ok` is false (`EXIT_CODE: 1`). Met. P1-T18 remains the authoritative CI fail-before evidence.
