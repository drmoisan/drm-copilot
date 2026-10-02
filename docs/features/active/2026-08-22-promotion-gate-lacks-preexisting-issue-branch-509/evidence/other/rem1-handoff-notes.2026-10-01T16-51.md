# Remediation Cycle 1 Handoff Notes (Issue #509)

Timestamp: 2026-10-01T16-51
Task: [P4-T18]
Plan: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/remediation-plan.2026-09-30T15-25.md` (v1.2)
Branch: `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` (local worktree branch `worktree-agent-a554484c9146de973`)

## Fix summary

- R1 / AC-2 (Blocker): `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (744 lines) was split into the kept file (AC-6, AC-7, AC-9 grid; 462 lines), the new `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` (AC-8, AC-11, AC-16; 177 lines), and the non-collected support module `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py` (187 lines). All 39 collected node names are preserved (empty `diff` of the sorted listings). Helpers were renamed to descriptive public names, which also closes review finding N4.
- R2 (Major): the two `globals()`-registered tests in `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` are now ordinary functions `test_valid_adoption_completes_without_potential_to_issue_receipt` (79-column `def` line) and `test_adoption_error_fails_closed_before_local_execution_overrides` (80 columns). No `noqa` was added; the `globals()` block was removed.
- N2 (Minor): the invariant sentence in `scripts/dev_tools/_orchestrator_state_issue_adoption.py` line 24 and line 19 of both `OrchestratorStateIssueAdoption.psm1` copies now states that messages interpolate only non-blank `waived_tools` entries and the route id. Documentation-only; the PowerShell pair remains byte-identical (hash `993acecd...f322`).

## Supplementary-input verification (merge commit `0aff3f47`)

| Task | Check | Result |
| --- | --- | --- |
| P0-T15 | Four document pairs byte-identical at baseline | PASS |
| P0-T16 | Post-merge TypeScript coverage run exits 0 with the three `coverageThreshold` entries at lines 77, 83, 87 honored | PASS |
| P4-T6 | Full Python suite merge-verification result (`RB_FULL_FAILED` with #510 set aside is empty) | PASS (no merge-verification failure node IDs) |
| P4-T10 | Bundle-parity and resource-contract tests (75 passed, including the three named `PASSED` lines) | PASS |
| P4-T11 | Four document pairs byte-identical after the cycle and equal to `RB_DOC_PAIR_HASHES` | PASS |
| P4-T12 | Final TypeScript coverage run exits 0; 246 suites / 3550 tests; thresholds honored | PASS |

## Diff-scope anchor

The diff-scope gate (P4-T15) was anchored to the merge commit `0aff3f47802bd57cb41e22a2dd61d8cdf91aa070` rather than the earlier start commit `3e9fd8d7`, because `3e9fd8d7...HEAD` also lists the #523 files that the integration merge brought in under `.claude/rules/`, `.claude/skills/`, `.agents/skills/`, and `extensions/drm-copilot/src/`, which are not this cycle's changes. Anchoring to the merge commit measures only this cycle's commits.

## Commit SHAs

| Phase | Commit | Subject |
| --- | --- | --- |
| Phase 0 | `caf599b44d60c115976a77849a62b92101988d79` | docs(509): record remediation cycle 1 baseline evidence |
| Phase 1 | `b35d5fc99c6aa6163a357969ce4a187319a0da58` | test(509): split issue-adoption unit tests below 500 lines |
| Phase 2 | `8e97750d970da48235f0c436495c5bd02579d4f3` | test(509): declare issue-adoption regression tests without globals() |
| Phase 3 | `5acd4973c62c7c34cf6db48ab8498b3fa5dc62ee` | docs(509): correct the issue-adoption message-interpolation invariant |

The Phase 4 commit SHA is recorded in `evidence/other/remediation-p4-commit.<timestamp>.md`, written after the Phase 4 push.

## Rename record

`docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/test-renames.2026-10-01T16-38.md`

## Artifacts written by this cycle (feature folder `evidence/`)

- `remediation-baseline/`: `phase0-instructions-read.2026-10-01T16-24.md`, `phase0-requirements-read.2026-10-01T16-25.md`, `git-baseline.2026-10-01T16-25.md`, `file-line-counts.2026-10-01T16-25.md`, `py-node-names.2026-10-01T16-26.md`, `py-adoption-node-names.txt`, `py-adoption-coverage.2026-10-01T16-26.md`, `py-adoption-coverage.json`, `py-black.2026-10-01T16-27.md`, `py-ruff.2026-10-01T16-27.md`, `py-ruff-repo.2026-10-01T16-27.md`, `py-pyright.2026-10-01T16-27.md`, `py-pytest-coverage.2026-10-01T16-28.md`, `py-full-coverage.json`, `ps-bundle-hash.2026-10-01T16-29.md`, `ps-format.2026-10-01T16-29.md`, `ps-analyze.2026-10-01T16-29.md`, `doc-pair-identity.2026-10-01T16-31.md`, `ts-coverage.2026-10-01T16-32.md`, `ts-coverage-output.txt`
- `regression-testing/`: `split-black.2026-10-01T16-35.md`, `split-ruff.2026-10-01T16-35.md`, `split-pyright.2026-10-01T16-35.md`, `split-line-counts.2026-10-01T16-36.md`, `py-split-node-names.2026-10-01T16-36.md`, `py-adoption-node-names-after.txt`, `py-split-tests.2026-10-01T16-36.md`, `r2-black.2026-10-01T16-37.md`, `r2-ruff.2026-10-01T16-37.md`, `r2-pyright.2026-10-01T16-37.md`, `r2-tests.2026-10-01T16-38.md`, `r2-no-dynamic-registration.2026-10-01T16-38.md`, `n2-docstring-diff.2026-10-01T16-40.md`
- `qa-gates/`: `rem1-py-black.2026-10-01T16-41.md`, `rem1-py-ruff.2026-10-01T16-41.md`, `rem1-py-pyright.2026-10-01T16-41.md`, `rem1-py-adoption-coverage.2026-10-01T16-42.md`, `rem1-py-adoption-coverage.json`, `rem1-py-module-coverage.2026-10-01T16-43.md`, `rem1-py-module-coverage.json`, `rem1-py-pytest-coverage.2026-10-01T16-44.md`, `rem1-py-full-coverage.json`, `rem1-py-coverage-delta.2026-10-01T16-44.md`, `rem1-ps-format.2026-10-01T16-45.md`, `rem1-ps-analyze.2026-10-01T16-45.md`, `rem1-ps-bundle.2026-10-01T16-47.md`, `rem1-doc-pair-identity.2026-10-01T16-47.md`, `rem1-ts-coverage.2026-10-01T16-47.md`, `rem1-ts-coverage-output.txt`, `rem1-file-size-gate.2026-10-01T16-48.md`, `rem1-no-temp-files.2026-10-01T16-49.md`, `rem1-diff-scope.2026-10-01T16-49.md`
- `other/`: `remediation-p0-commit-message.2026-10-01T16-33.txt`, `remediation-p0-commit.2026-10-01T16-33.md`, `remediation-p1-commit-message.2026-10-01T16-37.txt`, `remediation-p1-commit.2026-10-01T16-37.md`, `test-renames.2026-10-01T16-38.md`, `remediation-p2-commit-message.2026-10-01T16-39.txt`, `remediation-p2-commit.2026-10-01T16-39.md`, `remediation-p3-commit-message.2026-10-01T16-40.txt`, `remediation-p3-commit.2026-10-01T16-41.md`, `rem1-spec-ac-checkoff.2026-10-01T16-50.md`, `rem1-plan-checkoff.2026-10-01T16-50.md`, this file, and the Phase 4 commit message and commit record written by P4-T19.

## Open follow-ups

- N1 (runtime-specific whitespace definitions in the three blank-string helpers) and N3 (redundant `waived is None` operand at `_orchestrator_state_issue_adoption.py` line 323) remain open follow-ups; neither was in scope for this cycle.
- The sentence "Messages interpolate only validated tool names and the route id." at `spec.md` line 230 was intentionally left unchanged, because spec prose is out of scope for this remediation. It is a follow-up for the orchestrator.

## Environment note

`extensions/drm-copilot/node_modules` was absent in this worktree; `npm --prefix extensions/drm-copilot ci` was run before P0-T16 (gitignored output; no tracked file changed).

## Orchestrator instructions

- (a) Commit the Phase 4 commit-record artifact (`evidence/other/remediation-p4-commit.<timestamp>.md`) and the remediation plan's final checklist state (the P4-T19 check-off) with the next orchestrator commit.
- (b) Dispatch `ci.yml` on the pushed head before PR authoring (remediation-inputs, "Constraints for the Remediation Plan"). Dispatch `_poshqc.yml` only if P4-T9 returned `BLOCKED: POWERSHELL ANALYZE MCP FAILURE`; P4-T9 returned MCP status `success`, so `_poshqc.yml` dispatch is not required by this plan.
