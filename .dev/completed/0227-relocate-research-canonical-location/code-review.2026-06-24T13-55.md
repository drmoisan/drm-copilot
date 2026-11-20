# Code Review — relocate-research-canonical-location (Issue #227)

- **Timestamp:** 2026-06-24T13-55
- **Base branch (resolved):** origin/main @ ea94a068e0a071940858a0694c47e204244c09af
- **Head:** d200d8961843f8b9d040f6c847b8ae186035dc90
- **Scope:** full branch diff vs merge-base.

## Executive Summary

The change relocates the canonical research output path from the untracked `artifacts/research/` to two git-tracked roots (`docs/features/<feature>/research/` and `docs/research/`) across the Claude, Codex, and GitHub Copilot ecosystems and their bundled extension copies. The implementation is consistent and minimal:

- `Test-IsUnderResearchRoot` in `validate-task-researcher-output.ps1` was rewritten to accept the two roots using a forward-slash-normalized prefix-and-segment check; the filename regex was left unchanged as required by the spec invariant.
- `enforce-evidence-locations.ps1` and `validate_evidence_locations.py` add `artifacts/research/` to their forbidden-prefix sets, keeping the existing exclusion-only model intact.
- Three hard-coded error messages and the hook docstring were updated to name both new roots.
- Tests in all three test files were updated and extended for new-root acceptance and old-path rejection.
- Root files and their bundled mirrors are byte-identical; Codex translations carry the equivalent text.

The change follows the design principles in general-code-change.md (simplicity, separation of pure logic from I/O, fail-fast error messages with specific guidance). Toolchain stages (format, lint, type, test) pass. No source-code behavioral defects were identified.

One coverage threshold is not met: `enforce-evidence-locations.ps1` modified-file line coverage is 81.5%, below the uniform 85% threshold. The uncovered region is the pre-existing entry-point execution block, not the changed line. This is recorded as a Blocking coverage finding in the policy audit and remediation inputs.

A second observation is a low-severity whitespace artifact: a trailing blank line with a mixed line ending was added at the end of `validate-task-researcher-output.ps1`. It is byte-identical in the bundled mirror, passes Invoke-Formatter, and has no behavioral effect.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | .claude/hooks/enforce-evidence-locations.ps1 | entry-point block, lines 146-154 | Modified-file line coverage 81.5% is below the uniform 85% threshold. Uncovered lines are the dot-source-guarded entry-point execution block; the changed forbidden-prefix line is itself covered. | Add a process-level/integration test that executes the script as a process to cover the entry-point dispatch block, or refactor the entry-point wiring so the dispatch is exercised by the unit tests. Until then the threshold remains unmet. | quality-tiers.md and general-unit-test.md set a uniform 85% line floor for modified files; the file does not meet it. | coverage-delta.2026-06-24T13-09.md (81.5%, 22/27); reviewer Pester re-run (uncovered lines 146,148,149,152,154) |
| Low | .claude/hooks/validate-task-researcher-output.ps1 | end of file (after `exit 0`) | A trailing blank line with a mixed line ending (`\n\r\n`) was added by the diff. No behavioral effect; byte-identical in the bundled mirror; passes Invoke-Formatter. | Remove the trailing blank line for cleanliness on the next edit. Not required for merge. | Minor whitespace hygiene; not a policy violation. | `tail -c 40` shows `exit 0\n\r\n`; git diff shows a `+` blank line after `exit 0` |
| Info | .claude/hooks/validate-task-researcher-output.ps1 | Test-IsUnderResearchRoot (lines 66-83) | Dual-root acceptance logic correctly normalizes separators and requires a `/research/` segment for feature paths, distinguishing research files from spec.md/plan files under docs/features/. Case-insensitive comparisons used throughout. | None. Implementation matches the spec acceptance/rejection matrix. | Confirms the enforcement was not weakened by accepting two roots. | spec.md "Hook acceptance/rejection logic"; tests pass 32/32 including negative cases |
| Info | scripts/dev_tools/validate_evidence_locations.py | _FORBIDDEN_PREFIX_TO_CANONICAL (line 38) | Single-line addition of `artifacts/research/` with a canonical suggestion naming both new roots. Pure dict-data change; 100% line and branch coverage retained. | None. | Minimal, well-scoped, fully tested. | final-python.2026-06-24T13-09.md; reviewer pytest 100% coverage |
| Info | extensions/.../codex-and-agents-customizations/.codex/agents/task-researcher.toml | embedded frontmatter, body, stop hook | Write allowlist updated to the two-root glob form; body prose and stop-hook text updated to name both roots. Translation is consistent with the Claude source. | None. | Codex translation completeness confirmed. | git diff of task-researcher.toml |

## Typed-Python Review

`scripts/dev_tools/validate_evidence_locations.py` change is a one-line addition to a typed module-level dict `_FORBIDDEN_PREFIX_TO_CANONICAL: dict[str, str]`. Pyright reports 0 errors/warnings. No `Any`, no untyped escape hatch, no new function. The test addition `test_artifacts_research_is_forbidden` uses `MagicMock(spec=Path)` consistently with the existing test style, asserts exactly one violation, and verifies the canonical suggestion names both roots. No determinism, I/O-boundary, or typing concerns.

## Test Quality Notes

- The PowerShell test files add positive cases for both new roots, a negative case for the retired `artifacts/research/` path (asserting the new message text), a negative case for a feature path lacking a `/research/` segment, and a negative case for a non-conforming filename under a valid root. This matches the spec Test Strategy.
- The `enforce-evidence-locations.Tests.ps1` change converts the former allow-test for `artifacts/research/` into a block-test asserting `EVIDENCE_LOCATION_BLOCKED`, and adds allow-tests for the two new roots.
- Tests are deterministic, isolated, and follow Arrange-Act-Assert. No temporary files are created. No banned timing APIs.
