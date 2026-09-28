# Phase 0 — Findings and Requirements Read

Timestamp: 2026-09-08T05-02

Task: [P0-T2] of `remediation-plan.2026-09-08T05-00.md`

Resolved work mode: `full-bug` (marker `- Work Mode: full-bug` at `issue.md:12`).
AC source: `spec.md` only. `user-story.md` is present in the feature folder and is not an
acceptance-criteria source under this mode.

## Paths read (seven)

1. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
2. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/issue.md`
3. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-inputs.2026-09-08T05-00.md`
4. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/code-review.2026-09-08T05-00.md`
5. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/feature-audit.2026-09-08T05-00.md`
6. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/policy-audit.2026-09-08T05-00.md`
7. `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md`

## What each supplied

- `spec.md` — the acceptance-criteria source. `## Acceptance Criteria` begins at line 614 and
  carried 38 checkbox items at the audit commit, 36 `[x]` and 2 `[ ]`. Also supplied the
  `## Test Strategy`, `## Assumptions, Constraints, Dependencies`, `## Proposed Fix`,
  `## Risks & Mitigations`, and `## Rollout & Follow-up` sections that Phase 1 amends.
- `issue.md` — the work-mode marker and the 2026-09-06 observation provenance (line 27 records
  the data source as the TaskMaster checkout).
- `remediation-inputs.2026-09-08T05-00.md` — the six blocking findings R1 through R6, the eight
  advisory findings F7 through F14, and the acceptance-criteria reconciliation naming AC-1,
  AC-14, AC-15, AC-31, AC-32.
- `code-review.2026-09-08T05-00.md` — findings F1 through F14 with locations and remediations.
  F1 and F2 are the two reproduced data-loss defects; F4 is the content-blind header filter.
- `feature-audit.2026-09-08T05-00.md` — the per-criterion evaluation table and the AC source
  resolution that this plan's Phase 8 reconciles against.
- `policy-audit.2026-09-08T05-00.md` — the branch-diff scope (217 files, 4626 insertions,
  153 deletions), the language table (bash/bats and Markdown in scope; no Python, TypeScript,
  PowerShell, or C# changes), and the coverage gate finding P12.
- `evidence/qa-gates/shell-qc-test-coverage.2026-09-08T04-30.md` — the coverage baseline used
  by P0-T7: repo-wide 92.9%, `scripts/bash/cleanup_worktrees_dirt_lib.sh` 82.63% (138/167),
  and the 29-entry uncovered-line list.

## Findings this plan closes

| ID | Severity | Subject |
|---|---|---|
| R1 | FAIL (data loss) | Rung 1 ignores the porcelain Y column; an `MM` entry is labelled `STAGED_TREE_IS_COMMIT` |
| R2 | FAIL (data loss) | The ` -> ` split is unconditional instead of `R`/`C`-only |
| R5 | blocking-PARTIAL | The diff header filter is content-blind |
| R4 | FAIL (pinning) | `STAGED_TREE_IS_COMMIT` pinned in one of five material directions |
| R3 | FAIL (coverage) | `cleanup_worktrees_dirt_lib.sh` at 82.63%, below the 85% line floor |
| R6a | blocking-PARTIAL | Report-mode exit code 0 -> 128, undocumented and unpinned |
| R6b | blocking-PARTIAL | `DISPOSABLE_SESSION_ARTIFACT` cannot fire against a drm-copilot checkout |

Output Summary: All seven paths were read. The resolved work mode is `full-bug` and the
acceptance-criteria source is `spec.md` only. The six blocking findings and the five
acceptance criteria named for reconciliation match the Findings table and Scope Boundary of
the remediation plan; no additional blocking finding was discovered in these documents.
