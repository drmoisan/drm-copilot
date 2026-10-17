# Feature Audit (Re-audit) - Issue #887 (also resolves #888)

- Work mode: minor-audit (AC source: `issue.md` `## Acceptance Criteria`, AC-1 to AC-18)
- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887, head b5e58fc60 (PR #919)
- Baseline: origin/main; coverage baseline `evidence/baseline/ci-coverage-main.2026-10-12T14-33.md`
- Timestamp: 2026-10-12T15-30
- Supersedes: `feature-audit.2026-10-12T15-00.md` (not edited)

## Acceptance criteria evaluation

Evidence root: `docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/evidence/`.

AC-1 to AC-15 and AC-18: unchanged from 15-00, PASS. Verified by git that no `scripts/` or `tests/` file changed after the 15-00 review baseline commit 59fa06a04, so the earlier evidence (`regression-testing/pass-after-fix.2026-10-12T15-08.md`, 142 tests, 0 failures; `qa-gates/*`) still describes the code at HEAD.

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 to AC-15 | PASS | As in `feature-audit.2026-10-12T15-00.md`; code unchanged. |
| AC-16 | PASS | Local format, analyze, and test summaries pass (`qa-gates/poshqc-format.2026-10-12T15-14.md`, `poshqc-analyze.2026-10-12T15-14.md`, `poshqc-test.2026-10-12T14-48.md`). CI clause: `qa-gates/ci-poshqc-job.2026-10-12T15-17.md` records PR run 38294481892, headSha 59fa06a04 (equal to the code at HEAD), run completed, job `poshqc / PowerShell QC` conclusion success. |
| AC-17 | PASS | Coverage clause: CI artifact per-file line coverage HostTooling.psm1 95.24, HostBootstrapWorkspace.psm1 100.00, HostBootstrap.psm1 100.00, publish-sideloaded-extension.ps1 100.00 (`qa-gates/ci-coverage-perfile.2026-10-12T15-18.md`); the reviewer independently re-read the LINE counters in the downloaded artifact and they match (40/2, 64/0, 154/0, 32/0). Regression clause: changed-line coverage 100.00 for all four, uncovered none, and `qa-gates/coverage-delta.2026-10-12T15-19.md` verdict PASS versus baseline. Exclusion clause: `qa-gates/coverage-exclusion-check.2026-10-12T14-51.md`. |
| AC-18 | PASS | `qa-gates/line-counts.2026-10-12T14-49.md`; maximum 462 lines. |

Re-evaluation of AC-16 and AC-17: both moved from PENDING-CI to PASS. One limit on AC-16: the CI run is on headSha 59fa06a04, not on b5e58fc60; the later commit changed documentation only, so the CI result applies to the same code. Verified with git.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-10-11-host-tools-manifest-and-bootstrap-behavior-887/issue.md`
- Total AC items: 18
- Checked off (delivered): 18 (all eighteen already `[x]` in `issue.md`; the b5e58fc60 diff changed only AC-16 and AC-17 from `[ ]` to `[x]`)
- Remaining (unchecked): 0
- Items remaining: none
- Newly checked off by this review: none (the reviewer did not modify `issue.md`; the check-offs of AC-16 and AC-17 were made by the executor and are supported by the evidence above).

## Re-evaluation of 15-00 findings

| ID | 15-00 severity | Status | Severity now |
|---|---|---|---|
| FA-1 | non-blocking | RESOLVED: AC-16 and AC-17 are no longer pending CI. | closed |
| FA-2 | non-blocking | Unchanged. The `## Evidence Checklist` in `issue.md` (baseline, targeted verification, end-state) is still unchecked; not an acceptance criterion under minor-audit. | non-blocking |
| FA-3 | BLOCKING | RESOLVED. This is the same item as PA-2. The CI `PowerShell QC` coverage artifact shows >= 85% line coverage for each changed file (95.24 / 100.00 / 100.00 / 100.00), no regression, repo-wide 90.33%. Evidence: `qa-gates/ci-poshqc-job.2026-10-12T15-17.md`, `qa-gates/ci-coverage-perfile.2026-10-12T15-18.md`, `qa-gates/coverage-delta.2026-10-12T15-19.md`, `other/reduced-audit-handoff.2026-10-12T15-19.md`. | closed |

## Plan state

P2-T10 to P2-T13 are evidenced by the new files. The plan file changed in b5e58fc60; the reviewer did not edit it.

## Findings

| ID | Severity | Description |
|---|---|---|
| FA-2 | non-blocking | Evidence Checklist in `issue.md` is unchecked; not an AC. |
| FA-3 | resolved (was BLOCKING) | PowerShell coverage evidence gap closed by CI run 38294481892. |

BLOCKING findings: 0.

## Verdict

OVERALL VERDICT: PASS. 18 of 18 acceptance criteria are verified PASS. BLOCKING count: 0. The previously blocking PowerShell coverage finding (PA-2/FA-3) is resolved by the CI evidence. Non-blocking items remain (PA-1, PA-3, CR-1 to CR-3, FA-2) and do not gate merge. No remediation-inputs artifact is required.
