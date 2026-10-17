# Acceptance criteria evidence map (P3-T13)

Timestamp: 2026-10-16T03-33
Command: manual mapping of spec.md AC-1 to AC-15 against the plan AC-MAPPING table and the latest evidence artifacts
EXIT_CODE: 0
Output Summary: 15 ACs mapped. AC-1 to AC-13 meet their mapped evidence and are checked off in spec.md. AC-14 stays unchecked: its mapped coverage-delta artifact records one unmet condition (report line_pct 90.41 below baseline 90.42, caused by an unmodified module). AC-15 stays unchecked: CI-dependent, pending S9.

AC source: `docs/features/active/exempt-operand-unc-path-leg-937/spec.md` (Work Mode full-bug). Evidence names below are the latest file matching each `<name>.*.md`.

| AC | Implementation | Tests | Evidence artifacts | Status |
|---|---|---|---|---|
| AC-1 | P2-T1, P2-T2, P2-T3 | U27 UNC, mixed, and bare-separator labels on both surfaces | regression-testing/ps-fail-before.2026-10-16T02-20.md; qa-gates/ci-pass-after.2026-10-16T03-29.md; other/targets-mirror-identity.2026-10-16T02-24.md | met; checked |
| AC-2 | P2-T1, P2-T2 | U27 extended-length, device, NT-object labels | ps-fail-before.2026-10-16T02-20.md; ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-3 | P2-T1, P2-T2 | U27 `drive-relative`, `bare-drive-letter` | ps-fail-before.2026-10-16T02-20.md; ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-4 | P2-T1 | U28 | ps-fail-before.2026-10-16T02-20.md (U28 passing); ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-5 | P2-T2 | U29, U30 | ps-fail-before.2026-10-16T02-20.md; ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-6 | P2-T2 | U31 | ps-fail-before.2026-10-16T02-20.md; ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-7 | P2-T2 | three Claude gate rows (issue #937) | ps-fail-before.2026-10-16T02-20.md; ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-8 | P2-T2 | three Codex gate rows (issue #937) | ps-fail-before.2026-10-16T02-20.md; ci-pass-after.2026-10-16T03-29.md | met; checked |
| AC-9 | P1-T1 to P1-T7 | all 42 expect-fail testcases | ps-fail-before.2026-10-16T02-20.md (COUNT_FAILED=42, ExpectedExitCode 1); regression-testing/poshqc-test-fail-before.2026-10-16T01-56.md | met; checked |
| AC-10 | P2-T6 | U01 to U05, U14, U16, C1bCoverage suite | other/targets-additions-only.2026-10-16T02-24.md; qa-gates/invariants-diff.2026-10-16T03-06.md; ci-pass-after.2026-10-16T03-29.md (check 2: 29 matched, 0 failed) | met; checked |
| AC-11 | P2-T3 | Parity suite | targets-mirror-identity.2026-10-16T02-24.md; other/targets-size-check.2026-10-16T02-24.md; qa-gates/targets-eol-parity.2026-10-16T03-05.md; ci-pass-after.2026-10-16T03-29.md (3 Parity rows passed) | met; checked |
| AC-12 | P2-T3 | two Python push-down contract test files | qa-gates/python-contract-after-fix.2026-10-16T02-44.md; qa-gates/python-contract-final.2026-10-16T03-05.md (23 passed each) | met; checked |
| AC-13 | Scope section | none (diff check) | qa-gates/scope-diff.2026-10-16T03-07.md | met; checked |
| AC-14 | P3-T1 to P3-T5 loop | `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks` | qa-gates/poshqc-format-final.2026-10-16T02-46.md; qa-gates/poshqc-analyze-final.2026-10-16T02-48.md; qa-gates/poshqc-test-final.2026-10-16T03-05.md; ci-pass-after.2026-10-16T03-29.md; qa-gates/coverage-final.2026-10-16T03-32.md; qa-gates/coverage-delta.2026-10-16T03-32.md | gap; unchecked |
| AC-15 | P3-T9 push | CI jobs `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)` | ci-pass-after.2026-10-16T03-29.md (provisional: both jobs success on fd138e1ca59604664df87e14b44df5e1a15cb7c2) | CI-dependent: pending S9; unchecked |

## AC-9 phrase check

`spec.md` AC-9 does not contain the phrase `session root returned`, so the P3-T13 AC-9 exclusion does not apply.

## Gaps for unchecked ACs

- AC-14: format (no change), analyze (ok=true), and test (ok=true) passed, all Pester tests in both hook folders passed in CI (6335 of 6335), and the changed executable lines 40, 228, and 229 are instrumented and covered in both targets copies. The mapped artifact `coverage-delta.2026-10-16T03-32.md` nevertheless records one unmet acceptance condition: the report-level `line_pct` is 90.41 against a baseline of 90.42. The 2-line difference is in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (lines 116 and 335 covered at baseline, uncovered at final), a file this branch does not modify. The plan requires a mapped artifact to meet all of its conditions before the AC is checked off, so AC-14 is left unchecked pending a caller decision.
- AC-15: CI-dependent. Checked off at S9 against the PR head by the item's orchestrator run.
