# Feature Audit: general-instructions-first (Issue #122)

## Scope and Baseline

- **Base branch:** `development`
- **Feature folder:** `docs/features/active/2026-04-05-general-instructions-first-122`
- **Work mode marker:** `minor-audit`
- **Authoritative acceptance-criteria source:** `docs/features/active/2026-04-05-general-instructions-first-122/issue.md` under the exact heading `## Acceptance Criteria`
- **Minor-audit integrity:** `spec.md` absent = `True`; `user-story.md` absent = `True`
- **Primary evidence sources:**
  - `artifacts/pr_context.summary.txt` refreshed against `development`
  - `artifacts/pr_context.appendix.txt`
  - Feature evidence under `docs/features/active/2026-04-05-general-instructions-first-122/evidence/`

## Acceptance Criteria Inventory (Authoritative)

Source: `docs/features/active/2026-04-05-general-instructions-first-122/issue.md`

1. The sync command emits discovered instruction files whose basenames start with `general` before language-specific instruction files in generated `AGENTS.md` output.
2. Ordering remains deterministic within the `general` group and within the remaining language-specific group.
3. The bundled template at `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` remains byte-identical to `scripts/dev-tools/sync-agents-from-instructions.ps1`.
4. Pester tests cover the ordering rule and pass.
5. Running the sync script regenerates `AGENTS.md` with the expected grouped order.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. `general*` basenames emit before language-specific instruction files in generated `AGENTS.md` output | PASS | `evidence/qa-gates/final-agents-regeneration.2026-04-05T13-27.md` confirms the generated source list places `general-code-change` and `general-unit-test` immediately after `.github/copilot-instructions.md` and before language-specific entries. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/sync-agents-from-instructions.ps1` | The refreshed `development` diff is empty, so this acceptance evidence is already present in the base branch. |
| 2. Ordering remains deterministic within the `general` and remaining groups | PASS | `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1` includes a deterministic grouped-order scenario; `evidence/qa-gates/final-poshqc-test.2026-04-05T13-26.md` confirms it passed. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | The test explicitly asserts `general-code-change` before `general-unit-test`, then `csharp`, `powershell`, `python`, `typescript`. |
| 3. Bundled template remains byte-identical to the root script | PASS | The existing parity scenario remains present and passed in the final Pester run; the feature evidence and regenerated output both rely on matching root/bundled behavior. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | No drift is indicated in the refreshed no-op diff against `development`. |
| 4. Pester tests cover the ordering rule and pass | PASS | `evidence/regression-testing/regression-general-first-order.2026-04-05T13-23.md` captures the red failure before the fix; `evidence/qa-gates/final-poshqc-test.2026-04-05T13-26.md` captures the final green pass. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."` | Regression-first workflow requirement is satisfied. |
| 5. Running the sync script regenerates `AGENTS.md` with the expected grouped order | PASS | `evidence/qa-gates/final-agents-regeneration.2026-04-05T13-27.md` records successful regeneration with grouped order. | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/sync-agents-from-instructions.ps1` | The generated output is already incorporated in `development`. |

## Summary

**Overall feature readiness:** PASS

The feature folder satisfies all five acceptance criteria using only the exact `## Acceptance Criteria` section in `issue.md`, and minor-audit integrity is preserved because `spec.md` and `user-story.md` are absent. Relative to `development`, the refreshed branch comparison is empty, so the ready-to-merge gate passes and no remediation is required.

**Branch note:** The pass result means the feature is already present in `development`. A new PR to that base would be a no-op unless additional commits are added later.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-04-05-general-instructions-first-122/issue.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: none

## Check-off Notes

No source-file checkbox edits were required during this review because all five acceptance criteria were already checked in `issue.md` and this review confirmed each one as PASS.
