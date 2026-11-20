# Remediation Inputs: Issue #509 feature review (2026-09-30T15-25)

- Feature folder: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509`
- Base branch: `origin/epic/orchestrator-state-contract-correctness-integration` (merge base `815a962f0575ad10919c8014185e444727991eb5`)
- Head: `bug/promotion-gate-lacks-preexisting-issue-branch-exec-509` at `8920a1f6482ce2f831fd01acec475a590b19031d`
- Work mode: `full-bug` (AC source `spec.md`)

## Source Review Artifacts

- policy-audit: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/policy-audit.2026-09-30T15-25.md`
- code-review: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/code-review.2026-09-30T15-25.md`
- feature-audit: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/feature-audit.2026-09-30T15-25.md`
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-09-30 15:20:11 UTC, Head SHA `8920a1f6`)

## Remediation-Required Findings

### R1 (Blocker, AC-2 FAIL): test file exceeds 500 lines

- File: `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (744 lines)
- Policy: `.claude/rules/general-code-change.md` File Size Limit; `spec.md` AC-2.
- Required fix: split the file so each resulting test file is under 500 lines. Suggested division: (a) AC-6 positive and AC-7 negative schema cases; (b) AC-8 waivable-set cases, the AC-9 fixed-grid invariant, AC-11 presence gating, and the AC-16 case-variant test. Move the shared message builders (`e8dup`, `e8cannot`, `e8notreq`, `e8receipt`, `e9`, constants `E1`-`E8INCLUDE`) and the `_adoption`/`_state`/`_resolve` helpers into a test-support module under `tests/scripts/dev_tools/` (no `test_` prefix), consistent with the existing `validate_orchestrator_state_test_support.py` precedent. Preserve all 39 test node names or record each rename in the plan.
- Verification: `wc -l` over every added or modified code file in the diff (all under 500); Black, Ruff, Pyright on the new files; `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools._orchestrator_state_routing --cov=scripts.dev_tools._orchestrator_state_route_gates --cov=scripts.dev_tools._orchestrator_state_promotion_tools --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing` with `_orchestrator_state_issue_adoption.py` still at 100% line and branch and the same 39 behaviors passing.
- On success: check off AC-2 in `spec.md` and plan tasks P8-T17 and P8-T22.

### R2 (Major, blocking PARTIAL): tests registered through `globals()`

- File: `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`, lines 150-205.
- Policy: simplicity first (`.claude/rules/general-code-change.md` Design Principles); descriptive `test_...` function names (`.claude/rules/python.md` Pytest Rules). Precedent: #512 / PR #799 resolved an equivalent E501 conflict by shortening the test name.
- Required fix: replace the private functions `_valid_adoption_completes_without_receipt` and `_adoption_error_fails_closed_before_overrides` and the `globals()[...] = ...` block with two ordinary `def test_...() -> None:` functions whose names fit within 88 columns (for example `test_valid_adoption_completes_without_potential_to_issue_receipt` and `test_adoption_error_fails_closed_before_local_execution_overrides`). Do not add `# noqa`. Update the test names cited in `plan.2026-09-29T15-26.md` (lines 353-354) and add a new evidence record rather than editing historical evidence files.
- Verification: `poetry run ruff check .` exit 0; `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` 4 passed; `grep -n "globals()" tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py` returns no match.

## Non-Blocking Findings (may be deferred)

- N1 (Minor): runtime-specific whitespace definitions in the blank-string helpers (`_is_non_blank_string`, `isNonBlankString`, `Test-AdoptionNonBlankString`) can diverge for U+001C-U+001F and U+FEFF. Add corpus fixtures and align, or document; a follow-up potential entry is acceptable.
- N2 (Minor): module docstring and PowerShell help state that messages interpolate only validated tool names; the duplicate and cannot-be-waived messages interpolate raw non-blank strings. Reword.
- N3 (Nit): `_orchestrator_state_issue_adoption.py` line 323 redundant `waived is None` operand.
- N4 (Nit): unprefixed terse helper names in the unit test file; address during R1.

## Constraints for the Remediation Plan

- Do not edit `.claude/hooks/**`, #769 files, `validate_orchestrator_state.py`, `orchestrator-state-core.ts`, `OrchestratorStateCompletion.psm1`, or `config/orchestration-routing.json` (AC-19).
- No production file change is required; R1 and R2 are test-only. The PowerShell and TypeScript coverage evidence remains valid if no PowerShell or TypeScript file changes.
- Evidence for the remediation cycle goes under `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/{baseline,qa-gates,regression-testing}/`.
- After the fix, push and dispatch `ci.yml` on the new head before PR authoring.

## Remediation Plan Target

- Planned path: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/remediation-plan.2026-09-30T15-25.md`, to be authored by the atomic planner through the `remediation-handoff-atomic-planner` workflow. This review agent does not author plans.
