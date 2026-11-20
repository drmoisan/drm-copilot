# QA Gate: Acceptance Criteria Status (Issue #973)

Timestamp: 2026-10-17T14-01
Command: reconciliation of the checkboxes under `## Acceptance Criteria` in FEATURE/spec.md (document order AC-1 to AC-26) against the evidence artifacts
EXIT_CODE: 0

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/spec.md` (work mode `full-bug`; `## Acceptance Criteria` only)
- Total AC items: 26
- Checked off (delivered): 23 (AC-1 to AC-23)
- Remaining (unchecked): 3
- Items remaining:
  - AC-24 (pending-CI, verified at S9 by [P5-T4]): the first CI run on the item's pull request logs `code=true reason=NON_ALLOWLISTED_PATH:` (not `NO_FULL_GREEN_RUN`) in `Change scope` with summary `base=<merge base sha>`, `CI full run` succeeds, and every required context reports success.
  - AC-25 (pending-CI, verified at S9 by [P5-T5]): a later docs-only evidence commit logs `code=false reason=DOCS_ONLY_SINCE_<green head sha>` and every required context reports success.
  - AC-26 (post-merge, verified by [P5-T6]): the first docs-only pull request into `main` after merge logs `code=false reason=DOCS_ONLY_SINCE_MERGE_BASE_<sha>`, the heavy jobs are skipped, and every required context reports success.

| AC | Status | Evidence |
|---|---|---|
| AC-1 to AC-17 | checked | `FEATURE/evidence/regression-testing/pass-after.2026-10-17T13-33.md` (rows per AC listed there) |
| AC-18, AC-19 | checked | `FEATURE/evidence/qa-gates/python-contract-tests.2026-10-17T13-57.md`; `FEATURE/evidence/other/brief-copy.2026-10-17T13-35.md` |
| AC-20 | checked | README token search in [P3-T3]; README section reviewed in `FEATURE/evidence/qa-gates/self-review.2026-10-17T13-59.md` |
| AC-21 | checked | `FEATURE/evidence/qa-gates/ps-tests.2026-10-17T13-39.md`; `FEATURE/evidence/qa-gates/coverage-delta.2026-10-17T13-39.md` |
| AC-22 | checked | `FEATURE/evidence/qa-gates/file-sizes.2026-10-17T13-40.md` |
| AC-23 | checked | `FEATURE/evidence/regression-testing/isolation-shuffle-seed-973.2026-10-17T13-40.md`, `isolation-shuffle-seed-9731.2026-10-17T13-41.md`, `isolation-shuffle-seed-97301.2026-10-17T13-41.md`, `ps-tests-full-run.2026-10-17T13-56.md` |
| AC-24, AC-25 | unchecked, pending-CI | orchestrator-owned S9 gates [P5-T4], [P5-T5] |
| AC-26 | unchecked, post-merge | orchestrator-owned [P5-T6] in the archive-move pull request |

Output Summary: total 26; AC-1 to AC-23 checked with evidence on disk; AC-24 and AC-25 unchecked and pending-CI; AC-26 unchecked and post-merge.
