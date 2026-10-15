# Feature Audit (#609)

- Timestamp: 2026-10-01T23-21
- Head: `4a45810410fcc5df12d68dee5f3a718d9b2f49d6`; baseline `origin/main` (`1b1e349f`)
- Work mode: `full-bug`; AC source: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md` (`user-story.md` absent by design)
- Overall outcome: PARTIAL. Implementation is complete and consistent with the spec. Six criteria are PASS and verified. Eleven criteria depend on CI job `shell-coverage` (Shell Coverage (Bats + kcov)) on the pushed head, which has not been read. One of those (AC-6) also needs fail-before evidence that CI pass-after cannot supply.

## Verification Performed by the Reviewer

- `git diff origin/main...HEAD`: fix at line 88, mirror hunk, six bats cases plus helper, fixture.
- `cmp` canonical vs mirror: exit 0.
- `wc -l`: library 497, bats 495.
- Non-documentation write set: exactly the four planned files.
- `poetry run pytest` on the three planned test files: 83 passed (baseline 82 + 1 new fixture node).
- `shfmt -d` and `shellcheck` run directly on the changed `.sh` file: no output.
- Not run (operator rule Option A): bats, kcov, `shell-qc.sh`, `sh`-wrapped scripts, `report-lane-assertion.sh`.

## Acceptance Criteria Evaluation

| AC | Criterion (abbreviated) | Verdict | Evidence / gap |
|---|---|---|---|
| AC-1 | Repro `999:998\n101:202` gives identical header in bash entry point and Python authority | PARTIAL | Python side verified (`repro-python`: `1 derived`; fixture node passes). Bash side not run locally (`repro-bash-after` is NOT-RUN). CI must show bats case `edges-parity: a newline-separated value matches the single-line control` as `ok`, and the parity case `the bash lane reproduces every lane-assertion corpus fixture` as `ok` (it includes `edges_newline_separated`). |
| AC-2 | `pla_parse_edges` normalizes `\n \r \v \f` before `read -ra tokens` | PASS | Line 88: `read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"`; the unnormalized statement `read -ra tokens <<<"$text"` is gone (reviewer read the file). Already checked. |
| AC-3 | Bats test: newline-separated value matches single-line control | PARTIAL | Case present (`edges-parity: a newline-separated value ...`), not executed locally. CI must report it `ok`. |
| AC-4 | Bats test: tab-separated value matches control | PARTIAL | Case present, not executed locally. CI must report it `ok`. |
| AC-5 | Bats tests: CR-separated and CRLF-separated match control; CRLF-terminated final token kept | PARTIAL | Cases `a CR-separated value ...` and `a CRLF-terminated final token is kept` present (the latter passes `$'999:998\r\n101:202\r\n'` and `$'101:202\r\n'`). CI must report both `ok`. |
| AC-6 | New bats tests fail on unmodified library and pass after fix; evidence under `evidence/` | UNVERIFIED (treated as PARTIAL) | Only a fail-before exception dossier exists; the plan states a dossier alone does not satisfy this criterion. CI supplies pass-after only. A fail-first observation needs an operator-run of the bats file against the pre-fix library (commit `1524e2d2`, which has the cases without the fix), expecting exactly four `not ok` (newline, CR, CRLF-terminated, mixed). |
| AC-7 | Fixture exists, follows sibling schema, `expected_stdout` equals authority output | PASS | Key set and order match the sibling; node `test_reference_reproduces_every_corpus_fixture[edges_newline_separated]` is in the 83 passing tests (reviewer-run). Already checked. |
| AC-8 | `bats tests/shell/parallel_lane_assertion_parity.bats` passes incl. new record | PARTIAL | Not run locally. CI must show no `not ok` in that suite. |
| AC-9 | `poetry run pytest ...bash_parity.py` passes incl. new record | PASS | Reviewer-run: 83 passed across the three planned files, including the parity file. Already checked. |
| AC-10 | Optional CRLF fixture: derived from authority, or else CRLF bats test remains the coverage | PASS | Else-branch taken: no `edges_crlf_separated.json` in the diff; CRLF cases exist in the bats file. Already checked. |
| AC-11 | Mirror byte-identical; `cmp`, membership bats, push-down contract test | PARTIAL | `cmp` exit 0 and push-down pytest pass are reviewer-verified. `tests/shell/parallel_bash_manifest_membership.bats` not run locally. CI must show it green. |
| AC-12 | Existing suites remain green (bats unit, `test_parallel_lane_assertion.py`, two parity suites) | PARTIAL | Pytest pieces pass (reviewer). Bats unit (all 16 pre-existing plus 6 new, `1..22`) and bats parity await CI. |
| AC-13 | Diagnostic exits 0, output format unchanged; unchanged `expected_stdout` for pre-existing fixtures | PARTIAL | `git diff` shows no change to any pre-existing fixture file; the Python reference test over all fixtures passes. The bash-lane exit-0 and header assertions in the new cases await CI. |
| AC-14 | Line coverage of the library does not regress and is >= 85% | PARTIAL | All values `PENDING-CI`. See `policy-audit` section 8 for the exact CI values required (job green on `4a458104`; `Bash coverage (lines):` >= 85.0; per-file `line-rate` >= 0.85 and >= pre-change; hits >= 1 on line 88). The pre-change per-file value must come from a CI run on main. |
| AC-15 | Library at or under 500 lines | PASS | 497 lines (reviewer `wc -l`). Already checked. |
| AC-16 | No edits to `parallel-cohorts.sh`, `compute-cohorts.sh`, `report-lane-assertion.sh`, completed #599 spec, parity-test headers | PASS | Name-only diff against the merge-base shows none of these. Already checked. |
| AC-17 | `shell-qc.sh format` and `check` pass with zero findings on changed shell files | PARTIAL | Reviewer-run `shfmt -d` and `shellcheck` directly on the changed `.sh` file: no output. The prescribed `shell-qc.sh` run is withheld; CI step that runs `shell-qc.sh check` must be green. |

## Check-Off Actions

- Newly checked by this review: none. Every criterion evaluated PASS (AC-2, 7, 9, 10, 15, 16) was already checked. No criterion evaluated PARTIAL or UNVERIFIED was checked.
- No change to `spec.md` by this review.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md`
- Total AC items: 17
- Checked off (delivered): 6
- Remaining (unchecked): 11
- Items remaining: AC-1 (issue reproduction identical header), AC-3 (newline bats case), AC-4 (tab bats case), AC-5 (CR/CRLF bats cases), AC-6 (fail-before and pass-after), AC-8 (bats parity suite), AC-11 (mirror guards incl. membership bats), AC-12 (existing suites green), AC-13 (exit 0, format unchanged), AC-14 (coverage non-regression and >= 85%), AC-17 (shell-qc format and check)

## What CI Must Show to Close the Remaining Criteria

All readings are from job `Shell Coverage (Bats + kcov)` (`.github/workflows/_shell-coverage.yml`, called from `.github/workflows/ci.yml`) on head `4a45810410fcc5df12d68dee5f3a718d9b2f49d6`:

1. Job conclusion success on that exact head SHA. (AC-1, 3, 4, 5, 8, 11, 12, 13, 17)
2. The bats TAP or log shows the six `edges-parity:` cases, the parity case `the bash lane reproduces every lane-assertion corpus fixture`, and the membership suite with no `not ok`. (AC-1, 3, 4, 5, 8, 11, 12, 13)
3. The `shell-qc.sh check` step (shfmt diff plus shellcheck) reports no finding. (AC-17)
4. Log line `Bash coverage (lines): NN.N%` with NN.N >= 85.0; in `artifacts/pester/kcov/cov.xml`, the `parallel-lane-assertion.sh` class `line-rate` >= 0.85 and >= the value on main, and `hits` >= 1 at `number="88"`. (AC-14)
5. Fail-before for AC-6 is not obtainable from CI on this head; it needs one operator-run of `bats --tap tests/shell/parallel_lane_assertion.bats` at commit `1524e2d2` (cases added, fix absent) showing exactly four `not ok` titles, or an explicit operator decision to accept the Python-lane pin plus the dossier as sufficient and amend the criterion through the spec owner.

## Deviation Review (D1, D3, D4, D5)

D3 (shell-qc not run after the probe), D4 (bats not run), and D5 (`sh`-wrapped scripts not run) are recorded in evidence with the exact operator-run commands and the CI authority. They are consistent with Option A and do not introduce a fabricated value. D1 is not separately described in the artifacts this review read beyond the tool-availability overlay; it is not a verdict input.
