# Feature Audit: bash lane assertion newline edges divergence (#609)

---

**Audit Date:** 2026-10-02
**Review pass:** 2 (corrected structure; supersedes `feature-audit.2026-10-02T04-00.md` and `feature-audit.2026-10-01T23-21.md`)
**Feature Folder:** `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609`
**Base Branch:** `origin/main`
**Head Branch:** `bug/bash-lane-assertion-newline-edges-divergence-609` (PR #815)
**Work Mode:** `full-bug`
**Audit Type:** Re-audit with CI evidence

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`)
- **Head branch/commit:** `bug/bash-lane-assertion-newline-edges-divergence-609`, local HEAD `c9f006ad5f1fb3eea4233895bb9bd722e18535a5`
- **Merge base:** `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9` (origin/main equals the merge-base; the branch is up to date)
- **Evidence sources:**
  - Branch diff: `git diff origin/main...HEAD` (51 files; four non-documentation files)
  - CI evidence: `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md` (run 36960130609, head `54ccddd5`, success; bats `1..507`; `edges-parity:` cases ok 119-124; `Bash coverage (lines): 93.7%`)
  - CI evidence: `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` (run 36960736942, head `5e854239`; per-file `line-rate` 0.989 versus main 0.989; line 88 `hits="1"`)
  - CI evidence: `evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md` (run 36961456506, commit `1524e2d2`, failure; four expected `edges-parity:` `not ok` plus the corpus fixture)
  - Reviewer checks: `cmp` canonical versus mirror exit 0; `wc -l` library 497 and bats 495; write set is the four planned files; `validate_evidence_locations.py --root .` exit 0; `gh run view` spot-check of the three runs in pass 1
- **Currency:** `git diff --name-only 757d99f1..HEAD` lists documentation only, so the library, mirror, bats file, and fixture at HEAD equal the CI-tested content.
- **Feature folder used:** `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`, AC-1 to AC-17)
- **Work mode resolution note:** `issue.md` carries `full-bug`, so `spec.md` is the sole AC source; `user-story.md` is absent by design.
- **Scope note:** PR-context artifacts were not regenerated in this pass; scope is the full `origin/main...HEAD` diff read directly with git.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md` — only source

### Acceptance criteria

1. AC-1: Repro `999:998\n101:202` gives an identical header from the bash entry point and the Python authority.
2. AC-2: `pla_parse_edges` normalizes `\n \r \v \f` before `read -ra tokens`.
3. AC-3: Bats test: a newline-separated value matches the single-line control.
4. AC-4: Bats test: a tab-separated value matches the control.
5. AC-5: Bats tests: CR-separated and CRLF-separated values match the control; a CRLF-terminated final token is kept.
6. AC-6: New bats tests fail on the unmodified library and pass after the fix, with evidence under `evidence/`.
7. AC-7: Fixture exists, follows the sibling schema, and `expected_stdout` equals the authority output.
8. AC-8: `bats tests/shell/parallel_lane_assertion_parity.bats` passes including the new record.
9. AC-9: `poetry run pytest ...bash_parity.py` passes including the new record.
10. AC-10: Optional CRLF fixture is derived from the authority, otherwise the CRLF bats test remains the coverage.
11. AC-11: Mirror byte-identical; `cmp`, membership bats, and push-down contract test.
12. AC-12: Existing suites remain green (bats unit, `test_parallel_lane_assertion.py`, two parity suites).
13. AC-13: Diagnostic exits 0 and output format is unchanged; pre-existing fixtures keep `expected_stdout`.
14. AC-14: Line coverage of the library does not regress and is >= 85%.
15. AC-15: Library at or under 500 lines.
16. AC-16: No edits to `parallel-cohorts.sh`, `compute-cohorts.sh`, `report-lane-assertion.sh`, the completed #599 spec, or the parity-test headers.
17. AC-17: `shell-qc.sh format` and `check` pass with zero findings on changed shell files.

Criterion text above is abbreviated; the authoritative wording is in `spec.md`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Repro gives identical header from bash and Python | PASS | CI `ok 119` (newline case) and the corpus parity case including `edges_newline_separated`; Python side via fixture `expected_stdout`. | CI job `shell-coverage`; `git diff origin/main...HEAD` | |
| 2 | `pla_parse_edges` normalizes `\n \r \v \f` | PASS | Line 88: `read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"`; the unnormalized statement is gone. | `git diff origin/main...HEAD -- .claude/lib/bash/parallel-lane-assertion.sh` | |
| 3 | Bats: newline-separated matches control | PASS | `ok 119` in CI. | CI bats TAP | |
| 4 | Bats: tab-separated matches control | PASS | `ok 120` in CI. | CI bats TAP | Passes before the fix by design (boundary guard). |
| 5 | Bats: CR and CRLF match control; CRLF-terminated final token kept | PASS | `ok 121`, `ok 122` in CI. | CI bats TAP | |
| 6 | New bats tests fail on unmodified library, pass after fix | PASS | `bats-unit-before.2026-10-02T03-53.md`: four expected `not ok` (119, 121, 122, 124) at `1524e2d2`; the same cases `ok` at `5e854239`. | `gh run view 36961456506`; `gh run view 36960736942` | Tab (120) and undeclared-only (123) pass before by design. |
| 7 | Fixture exists, sibling schema, `expected_stdout` equals authority | PASS | Fixture read; `test_reference_reproduces_every_corpus_fixture[edges_newline_separated]` is in the 83 pytest passes (pass-1 run); no source change since. | `poetry run pytest` on the three planned files | |
| 8 | Parity bats suite passes incl. new record | PASS | No `not ok` in CI bats `1..507`; the corpus case fails without the fix and passes with it. | CI bats TAP | |
| 9 | pytest bash-parity passes incl. new record | PASS | 83 passed (pass-1 run); no Python or fixture change since. | `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py ...` | |
| 10 | Optional CRLF fixture or CRLF bats coverage | PASS | Else-branch: no CRLF fixture in the diff; CRLF bats case `ok 122`. | `git diff --name-only origin/main...HEAD` | |
| 11 | Mirror byte-identical; `cmp`, membership bats, push-down pytest | PASS | `cmp` exit 0; membership bats inside the green CI job; push-down pytest in the 83. | `cmp` on both library paths | |
| 12 | Existing suites remain green | PASS | CI bats `1..507` with no `not ok`; pytest pieces green. | CI job `shell-coverage` | |
| 13 | Exit 0, output format unchanged | PASS | Helper asserts status 0 in six green cases; no pre-existing fixture file changed in the diff. | `git diff --name-status origin/main...HEAD` | |
| 14 | Line coverage no regression, >= 85% | PASS | Per-file 0.989 versus baseline 0.989; merged 93.7%; line 88 `hits="1"`. | `gh run download` of artifact `shell-coverage` for runs 36960736942 and 36958806659 | No branch gate applies to bash. |
| 15 | Library <= 500 lines | PASS | 497 lines. | `wc -l` | |
| 16 | No edits to excluded files | PASS | Name-only diff shows none of them. | `git diff --name-only origin/main...HEAD` | |
| 17 | `shell-qc.sh format` and `check` zero findings on changed shell files | PASS | CI step `Run shell-qc check (shfmt diff + shellcheck)` success in run 36960736942; pass-1 direct `shfmt -d` and `shellcheck` on the changed `.sh` file printed nothing. | CI step log | CI runs `check`, which covers the shfmt diff and shellcheck finding set for the changed `.sh` file. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 17 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Blocking findings:** 0.

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Re-read CI on the final PR head before merge; the delta from the last CI-green head `5e854239` is documentation only.
2. Optional hygiene: add a superseding status summary with a new timestamp for the stale pre-CI evidence (`ac-gaps`, `ac-status-summary`, `coverage-comparison`, `fail-before-exception`). These point-in-time records contradict the current 17 of 17 state but are read by no gate.
3. The prior `remediation-inputs.2026-10-01T23-21.md` items (RR-1, RR-2) are closed by this evidence; no new remediation inputs are required.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are checkbox items and not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 17 AC items in `spec.md` were already checked `[x]` by the executor with evidence. The reviewer evaluated all 17 as PASS, so no source-file change was made during this review.

### AC Status Summary

- Source: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md`
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md` | 17 | 17 | 0 | Checkbox-backed; authoritative for `full-bug` |
