# Remediation Inputs: epic-orchestrate (#275) — Cycle 2

- Entry timestamp: 2026-07-03T00-15
- Source audit artifacts:
  - `docs/features/active/2026-07-02-epic-orchestrate-275/policy-audit.2026-07-03T00-15.md`
  - `docs/features/active/2026-07-02-epic-orchestrate-275/code-review.2026-07-03T00-15.md`
  - `docs/features/active/2026-07-02-epic-orchestrate-275/feature-audit.2026-07-03T00-15.md`
- Base branch: `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
- Head commit under review: `4921aaa0da408f089b7bc83a84c9938243fde5ac` (branch `drm-copilot-wt-2026-07-02-19-03`), containing the original implementation (`25a4a364`) and remediation cycle 1 (`4921aaa`)

## Why remediation is triggered

Remediation cycle 1 (`remediation-plan.2026-07-02T23-00.md`) resolved both prior Blocking findings and 2 of 3 Major/Minor findings, all independently re-verified by this re-audit. One Major finding was only partially resolved:

- Policy audit `2026-07-03T00-15`, Section 8, Gap #1 (Major): `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` is 513 lines, still 13 lines over the mandatory 500-line file-size cap in `general-code-change.md`, after being reduced from 739 (post-original-implementation) via a partial split in remediation cycle 1.
- Feature audit `2026-07-03T00-15`: AC14 and the generic "Toolchain pass completed" closing item remain PARTIAL, tied to this same residual gap (both original Blocking sub-findings under AC14 — production file size, TypeScript coverage artifact — are now resolved).

This is a small, narrowly-scoped cycle compared to cycle 1: one fix, no coverage or toolchain regressions to address (all coverage/toolchain metrics already pass cleanly in all three languages, independently re-verified this pass).

## Enumerated Fix List

1. **Residual file-size limit violation — `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`**
   - **File(s):** `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (513 lines; must return to ≤ 500 lines).
   - **Expected behavior:** Relocate additional cohesive test content into a sibling test file, following the same convention already used twice in this feature (`test_validate_epic_orchestrator_state.py`, `test_validate_orchestration_artifacts_dispatch.py`). The remediation-cycle-1 evidence (`evidence/qa-gates/python-test-split.2026-07-02T23-35.md`) identifies the pre-existing `orchestrator-state` dispatch tests (not the epic-orchestrator-state ones already relocated) as the next candidate for relocation, since they share less fixture cohesion with the remaining content than the epic-specific tests did. Do not weaken, remove, or skip any existing test in the process. If, after a genuine attempt, ≤ 500 lines is still not achievable without breaking shared-fixture cohesion, stop and request an explicit, documented, user-approved exception rather than declaring partial compliance sufficient — do not repeat the "as close as achievable" self-granted leniency from remediation cycle 1's plan, since this re-audit has already determined that leniency does not satisfy the policy's hard cap.
   - **Verification command(s):** `wc -l tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (must report ≤ 500); `wc -l tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` (confirm still present and unweakened, or note if further split into a third sibling file); `poetry run pytest tests/scripts/dev_tools -q` (must continue to report 1192 passed + 19 skipped, or more if the split adds test count, zero failures); `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` and `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` (must remain clean).

## Do Not Do

- Do not weaken, remove, or skip any existing passing test to make the file-size extraction easier.
- Do not change any test's assertions or the production code under test — this is a structural test-file reorganization only.
- Do not expand scope beyond the 1 fix above (e.g., do not address the carried-forward worktree-removal-gate design note or the broken "Merge-Conflict Remediation" cross-reference in this cycle — both are non-blocking and may be tracked as a separate, later follow-up at the requester's discretion; do not fold them into this narrowly-scoped cycle without explicit instruction).
- Do not mark `spec.md`'s AC14 checkbox or the "Toolchain pass completed" generic closing item as `[x]` until this fix has been independently re-verified by a subsequent feature-review pass.
- Do not re-run or regenerate the PowerShell/TypeScript coverage artifacts as part of this fix — they are already passing and unaffected by a Python-only test-file reorganization; re-verifying them is optional evidence hygiene, not required for this fix.

## Acceptance Criteria Affected

- `spec.md` AC14 (all four toolchains pass with no coverage regression) — blocked on this fix only; both original Blocking sub-findings under this AC are already resolved.
- `spec.md` Generic closing item "Toolchain pass completed" — blocked on the same fix.
- No other acceptance criterion (spec.md AC1-13, or any `user-story.md` item) is affected by this cycle; all are independently verified PASS as of `feature-audit.2026-07-03T00-15.md`, including AC2 and `user-story.md` item 2, which are now checked off.

## Next Step

Hand off to `atomic-planner` per `remediation-handoff-atomic-planner` to author `remediation-plan.2026-07-03T00-15.md`, then route through the standard preflight → execution → reaudit chain. On reaudit, re-run `feature-review` to produce new `code-review`, `feature-audit`, and `policy-audit` artifacts at the exit timestamp, and re-evaluate AC14/Generic-6 for check-off in `spec.md`. Given the narrow scope of this cycle (one file, one policy rule), this is expected to be a materially shorter cycle than cycle 1.
