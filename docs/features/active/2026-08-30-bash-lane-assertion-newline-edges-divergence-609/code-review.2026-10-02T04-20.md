# Code Review: bash lane assertion newline edges divergence (#609)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent
**Review pass:** 2 (corrected structure; supersedes `code-review.2026-10-02T04-00.md` and `code-review.2026-10-01T23-21.md`)
**Feature Folder:** `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609`
**Base Branch:** `origin/main` (merge base `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`)
**Head Branch:** `bug/bash-lane-assertion-newline-edges-divergence-609` (PR #815), local HEAD `c9f006ad5f1fb3eea4233895bb9bd722e18535a5`
**Review Type:** Re-review with CI evidence

---

## Executive Summary

The branch changes one statement in `.claude/lib/bash/parallel-lane-assertion.sh` (line 88) so that newline, CR, VT, and FF are replaced with spaces before `read -ra tokens`. Without the change, `read` consumed one newline-terminated record only and CR, VT, and FF were not separators, so the bash lane diverged from Python `str.split()` on newline-separated edge text. The bundled mirror is byte-identical. The bats file gains a helper and six `edges-parity:` cases, and a JSON corpus fixture is added.

Behavior is confirmed by CI: bats `1..507` with no `not ok` on PR head `5e854239` (run 36960736942), and the fail-first run at commit `1524e2d2` (run 36961456506) shows the four expected failures. The source files are byte-unchanged between those CI heads and the review head (`git diff --name-only 757d99f1..HEAD` lists documentation only).

**What changed:**
- Library line 88: `read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"`; comment extended by two lines (497 lines total).
- Mirror: identical hunk, `cmp` exit 0.
- `tests/shell/parallel_lane_assertion.bats`: +37 lines (495 total).
- `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`: new corpus fixture.

**Top risks:**
1. Python-only whitespace (`\x1c`-`\x1f`, `\x85`, `\xa0`, Unicode spaces) still differs between lanes. Recorded follow-up; the comment does not claim full equivalence.
2. The library and bats file are 3 and 5 lines under the 500-line limit; later edits need planning against the limit.
3. CI on the review head was not re-read after the documentation-only head delta.

**PR readiness recommendation:** **Go.** Blocking findings: 0.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/bash/parallel-lane-assertion.sh` | line 88 | The pass-1 residual R-1 (reliance on `$'...'` inside a double-quoted pattern expansion) is closed. The expansion works on CI bash. | No action. | The four fail-first cases pass after the fix, which shows the expansion behaves as intended. | CI run 36960736942 bats `ok 119`, `121`, `122`, `124`; fail-first run 36961456506 at `1524e2d2`. |
| Info | `.claude/lib/bash/parallel-lane-assertion.sh` | lines 84-88 (comment) | Python-only whitespace (`\x1c`-`\x1f`, `\x85`, `\xa0`, Unicode spaces) still differs between lanes. | Track under the existing follow-up; no change in this PR. | Outside the spec; the comment names only newline, CR, VT, and FF. | `evidence/other/follow-ups.2026-09-29T18-45.md`. |
| Info | `.claude/lib/bash/parallel-lane-assertion.sh`, `tests/shell/parallel_lane_assertion.bats` | whole files | Line counts are 497 and 495 against a 500-line limit. | Plan any later edit against the limit. | Margins of 3 and 5 lines. | `wc -l` (reviewer run). |
| Info | `tests/shell/parallel_lane_assertion.bats` | file-scope `EDGES_MERGED_HEADER`, `EDGES_SPLIT_HEADER` | Helper-header variables are shell globals set at file scope. | No action. | Bats re-evaluates the file per test, so there is no cross-test leakage. | Bats execution model; CI green. |
| Info | `tests/shell/parallel_lane_assertion.bats` | helper `edges_header_is` | The helper asserts only the first output line. | No action. | The spec limits the assertion to the header line; the corpus fixture covers full output. | `spec.md`; fixture `expected_stdout`. |
| Info | `tests/shell/parallel_lane_assertion.bats` | cases 120 (tab) and 123 (undeclared-only) | These two cases pass on the unfixed library by design. | No action. | They are boundary guards; the four fail-first cases (119, 121, 122, 124) discriminate. | `evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md`. |
| Info | `tests/shell/parallel_lane_assertion.bats` | whole file | `shfmt -d` reports whole-file differences on the `.bats` file. | No action in this PR. | Pre-existing 4-space convention; `shell-qc.sh` does not format `.bats` files. | `shell_qc_lib.sh` discovers `*.sh` only. |
| Info | `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/` | `ac-gaps.2026-09-29T18-45.md`, `ac-status-summary.2026-09-29T18-45.md` | Stale pre-CI evidence still lists AC-6 and AC-14 as open. | Optionally add a superseding status summary with a new timestamp; do not edit the old files. | Point-in-time records that no gate reads; `spec.md` (17 of 17) and the CI artifacts agree. | `policy-audit.2026-10-02T04-20.md` Section 8. |

No Blocker or Major findings. Blocking count: 0.

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- Correctness: `read -ra` without `-d` consumes one newline-terminated record and splits on default IFS. Replacing newline, CR, VT, and FF with spaces first aligns the bash separator set with Python `str.split()` for ASCII. CI confirms: the newline case (ok 119) fails without the fix and passes with it, and the corpus fixture `edges_newline_separated` passes after the fix.
- Invariants preserved: `read -ra` is retained, so tokens are not pathname-expanded; no new command, so no new exit-status effect under `set -euo pipefail`; the downstream shape and integer-lexis checks and output format are unchanged.
- Sibling regions: the other `read -ra` sites read internally built space-joined lists and do not need normalization. Line 88 is the only operator-text site.
- Mirror: byte-identical (`cmp` exit 0). Both byte-equality guards are covered: the push-down contract pytest (pass-1 reviewer run, 83 passed) and `parallel_bash_manifest_membership.bats` (inside the green CI bats run).

#### Maintainability

- The comment accurately states why the normalization exists and does not overstate equivalence.
- Scope discipline: no unrelated edits or formatting churn; no change to `report-lane-assertion.sh`, `parallel-cohorts.sh`, `compute-cohorts.sh`, or the parity test headers.

#### Error handling and logging

- The diagnostic remains advisory and exits 0; the new cases assert `status = 0`.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `tests/shell/parallel_lane_assertion.bats` — six `edges-parity:` cases: newline (119), tab (120), CR (121), CRLF-terminated final token (122), undeclared-only vertices (123), mixed separators (124). Each includes a single-line `101:202` control and asserts `"$status:${lines[0]}"`. ANSI-C quoting keeps the file ASCII; no temporary files, sleeps, or clock use.
- `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json` — key set and order follow the sibling fixture; `expected_stdout` is Python-authority output (1 derived component, two informational lines); `divergence` is `null`. In the fail-first CI run the corpus test reported 1 derived versus 2 derived on the unfixed library, and it passes after the fix, which shows the fixture discriminates.
- `evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md` — run 36961456506, commit `1524e2d2`, four expected `not ok` plus the corpus fixture.
- `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md` — run 36960130609 success, `1..507`, 93.7% merged lines.
- `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` — per-file 0.989 versus 0.989 baseline; line 88 `hits="1"`.

### Quality assessment

- **Determinism:** fixed literal inputs; no randomness, clock, or I/O.
- **Isolation:** one separator class per case, each with a control.
- **Diagnostics:** the status-and-header comparison names both values on failure.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff contains one parameter expansion, tests, a JSON fixture, and Markdown. |
| Unsafe command construction | PASS | `read -ra` retained; no `eval`, no unquoted expansion added. |
| Input validation at boundaries | PASS | Downstream shape and integer-lexis checks unchanged. |
| Error handling remains explicit | PASS | No error path added or removed. |
| Behavior preservation | PASS | No pre-existing fixture changed; bats `1..507` with no `not ok`. |

---

## Research Log

No external research was required. CI results were read through the evidence artifacts and spot-checked with `gh run view` in pass 1 (run 36960736942 success on head `5e854239`; run 36960130609 success on `54ccddd5`; run 36961456506 failure on `1524e2d2`, the expected fail-first outcome).

---

## Verdict

The change is ready for normal PR flow. The fix is minimal, matches the spec, preserves behavior, and is confirmed by CI for both the fail-first and pass-after states. Blocking findings: 0. Re-read CI on the final head before merge; the delta from the green head is documentation only.
