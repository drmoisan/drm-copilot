# Feature Audit (#609, review pass 1, R5 reaudit)

- Timestamp: 2026-10-02T04-00
- Head: `6a7f5eb565485f151d56269e25282082f5b951f0`; baseline `origin/main` (`1b1e349f`)
- Work mode: `full-bug`; AC source: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md` (`user-story.md` absent by design)
- Supersedes: `feature-audit.2026-10-01T23-21.md`
- Overall outcome: PASS. All 17 criteria are verified against evidence and checked in `spec.md`. Blocking count: 0.

## Evidence Basis

- Reviewer re-checks: `git diff origin/main...HEAD` (fix at line 88, mirror, six bats cases plus helper, fixture); `cmp` canonical versus mirror exit 0; `wc -l` library 497 and bats 495; non-documentation write set is the four planned files; `validate_evidence_locations.py --root .` exit 0.
- CI evidence read (not re-derived locally), each with Timestamp, Command, EXIT_CODE, Output Summary:
  - `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`: run 36960130609, head `54ccddd5`, success; bats `1..507`, no `not ok`, `edges-parity:` cases `ok 119`-`ok 124`, `Bash coverage (lines): 93.7%`.
  - `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md`: run 36960736942, head `5e854239`; library `line-rate` 0.989 versus main 0.989; line 88 `hits="1"`.
  - `evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md`: run 36961456506, commit `1524e2d2`, conclusion failure; four expected `edges-parity:` `not ok` plus the corpus fixture `not ok`.
- Reviewer spot-check with `gh run view`: run 36960736942 `success` on head `5e85423931fe483c4fad5daa338b9dbb3a14edb6`; run 36960130609 `success` on `54ccddd5`; run 36961456506 `failure` on `1524e2d2ffed91dba96dfbd37181e246818b0e95` (workflow_dispatch, branch `tmp/609-fail-first`). In run 36960736942 the steps `Run shell-qc check (shfmt diff + shellcheck)` and `Run shell-qc test with coverage` are `success`.
- Currency: `git diff --name-only 757d99f1..HEAD` lists documentation only, so the library, mirror, bats file, and fixture at HEAD equal the CI-tested content.

## Acceptance Criteria Evaluation

| AC | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| AC-1 | Repro `999:998\n101:202` gives identical header from bash and Python | PASS | CI `ok 119` (newline case) and the corpus parity case including `edges_newline_separated`; Python side via fixture `expected_stdout`. |
| AC-2 | `pla_parse_edges` normalizes `\n \r \v \f` before `read -ra tokens` | PASS | Line 88 (reviewer read the diff). |
| AC-3 | Bats: newline-separated matches control | PASS | `ok 119` in CI. |
| AC-4 | Bats: tab-separated matches control | PASS | `ok 120` in CI. |
| AC-5 | Bats: CR and CRLF match control; CRLF-terminated final token kept | PASS | `ok 121`, `ok 122` in CI. |
| AC-6 | New bats tests fail on unmodified library, pass after fix | PASS | `bats-unit-before.2026-10-02T03-53.md`: four expected `not ok` (119, 121, 122, 124) at `1524e2d2`; same cases `ok` at `5e854239`. Tab and undeclared-only pass before by design (boundary guards). |
| AC-7 | Fixture exists, sibling schema, `expected_stdout` equals authority | PASS | Fixture read; pytest node in the prior reviewer-run 83 passed; no source change since. |
| AC-8 | `parallel_lane_assertion_parity.bats` passes incl. new record | PASS | No `not ok` in CI bats `1..507`; the corpus case fails without the fix and passes with it. |
| AC-9 | pytest bash-parity passes incl. new record | PASS | Reviewer-run in the prior pass: 83 passed; no Python or fixture change since. |
| AC-10 | Optional CRLF fixture or CRLF bats coverage | PASS | Else-branch: no CRLF fixture; CRLF bats case `ok 122`. |
| AC-11 | Mirror byte-identical; `cmp`, membership bats, push-down pytest | PASS | `cmp` exit 0 (re-run); membership bats inside green CI job; pytest in the 83. |
| AC-12 | Existing suites remain green | PASS | CI bats `1..507` with no `not ok`; pytest pieces green. |
| AC-13 | Exit 0, output format unchanged | PASS | Helper asserts status 0 in six cases (green); no pre-existing fixture file changed in the diff. |
| AC-14 | Line coverage no regression, >= 85% | PASS | Per-file 0.989 versus baseline 0.989; merged 93.7%; line 88 hits 1. |
| AC-15 | Library <= 500 lines | PASS | 497 (re-run). |
| AC-16 | No edits to excluded files | PASS | Name-only diff shows none of them. |
| AC-17 | `shell-qc.sh format` and `check` zero findings on changed shell files | PASS | CI `Run shell-qc check (shfmt diff + shellcheck)` success. CI runs `check` (shfmt diff plus shellcheck), which covers the format finding set for the changed `.sh` file; the prior pass's direct `shfmt -d` and `shellcheck` runs also printed nothing. |

## Check-Off Actions

- `spec.md` has 17 of 17 criteria checked, matching the verdicts above. Newly checked by this review: none (all were already checked by the executor with evidence). No criterion was checked without a PASS here, and no spec text was edited.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md`
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none

## Non-Blocking Observations

- Stale pre-CI evidence (`ac-gaps`, `ac-status-summary`, `coverage-comparison`, `fail-before-exception`, and the "Gaps left unchecked" section of `ci-shell-coverage`) still describe AC-6 and AC-14 as open. They are point-in-time records, are not read by any gate, and are superseded by the three CI artifacts; see `policy-audit.2026-10-02T04-00.md` section 16. The `ac-gaps` and `ac-status-summary` files contradict the current 17/17 state but do not block.
- Head `6a7f5eb5` CI was pending at review time; the delta from the green head is documentation only. Re-read CI before merge.
- The prior `remediation-inputs.2026-10-01T23-21.md` (RR-1, RR-2) is closed by this evidence. No new remediation inputs are required.
