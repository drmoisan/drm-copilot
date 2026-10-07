# Remediation Preflight, Round 1

Timestamp: 2026-10-02T05-20
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/remediation-plan.2026-10-02T05-08.md
Signal: PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: FURTHER ROUNDS LIKELY (one confirming round after the delta below is applied)

## Verified citations (against the tree)

- pyproject.toml line 116 (addopts, LCOV reporter only), line 120 (source), lines 119-127 (coverage.run, no branch entry): confirmed. Also present and not mentioned in the plan: line 121 `data_file = "artifacts/.coverage"`.
- `branch = true`: zero matches in pyproject.toml. No .coveragerc, setup.cfg, tox.ini, or pytest.ini exists.
- .gitignore line 6 `/artifacts` covers artifacts/python/.
- HEAD is 7efd9d8f3044568bd1da627425309e93f5724e46. `git diff --name-only origin/main...HEAD -- '*.py'` lists exactly tests/scripts/dev_tools/test_poshqc_bundled_parity.py.
- coverage 7.13.2, pytest-cov 7.0.0 (poetry.lock); Poetry 2.3.2 (supports -C).
- Rule files named in P0-T1 all exist.

## Warnings G4 on P1-T2 and P1-T3

Not defects. pytest-cov declares `--cov` with an optional value, and a following token that begins with `--` is not consumed. No change required. Rewriting to `--cov=src --cov=scripts.dev_tools` would alter the measured set relative to the configured `source` and is not recommended.

## Defects

D1 (P0-T2, unsatisfiable acceptance). `git status --porcelain` is required to be empty, but the tree is already not clean: the plan file is untracked (`??`), P0-T1 writes an untracked artifact before P0-T2 runs, and the preflight record is untracked. The condition cannot pass.

D2 (P1-T4, command cannot yield the asserted lines). `coverage json` writes compact single-line JSON unless `--pretty-print` is given (coverage/jsonreport.py line 105: `indent=(4 if self.config.json_pretty_print else None)`). The Grep for `"totals"` with 14 following lines then returns the whole file as one line, or nothing usable. Verified field order in 7.13.2: covered_lines, num_statements, percent_covered, percent_covered_display, missing_lines, excluded_lines, percent_statements_covered, percent_statements_covered_display, num_branches, num_partial_branches, covered_branches (11th field), missing_branches, percent_branches_covered, percent_branches_covered_display.

D3 (P1-T5, second regular expression can never match). The LCOV BRDA record is `BRDA:{line},0,{branch},{hit}` where `{branch}` is `fr.arc_description(line, dst)`, an English description string (coverage/lcovreport.py line 144, coverage/parser.py line 404), and `{hit}` is `1`, `0`, or `-`. The pattern `^BRDA:[0-9]+,[0-9]+,[0-9]+,[1-9][0-9]*$` requires a numeric third field, so it returns zero matches whatever the run produced, and the covered-branch comparison is always `NOT EQUAL`. Because the plan records `NOT EQUAL` as observed and does not stop, the check cannot fail and cannot confirm. Additionally, `$` after the hit field may not match if the file carries CRLF line endings on Windows; a whitespace-tolerant end is required.

D4 (P2-T1/P2-T3, checkoff ordering). P2-T1 checks off tasks before P2-T2 to P2-T5 are complete, and P2-T3 requires a clean status afterward. The check-offs of P2-T1 to P2-T5 necessarily occur after P2-T5 and leave the plan file modified and unpushed, which the plan neither states nor accepts.

D5 (P1-T2/P1-T3, timeout unspecified). "A timeout long enough" is not a value. The Bash tool maximum is 600000 ms; the plan should state `timeout 600000` and say that a run that exceeds it is re-run in the background and its output read on completion.

D6 (P1-T3, acceptance with no mismatch branch). "EXIT_CODE equals the Run A EXIT_CODE" has no stated handling when it differs (for example a nondeterministic test). State that a mismatch is recorded as observed with both values and reported.

D7 (P2-T3, commit trailer). The commit command carries no co-author trailer line required by the session attribution instruction.

D8 (P1-T2/P1-T3, output capture). The full coverage table for `src` plus `scripts/dev_tools` is long; if tool output is truncated the `TOTAL` row may be lost. State that when the printed output lacks a `TOTAL` row the run is repeated with the output redirected to a file under the session scratchpad and the header and `TOTAL` rows are read from that file.

## Delta

1. P0-T2: replace the acceptance sentence with: "Acceptance: the recorded HEAD hash begins with `7efd9d8f`; `git status --porcelain --untracked-files=no` prints nothing; and every `??` line in the full `git status --porcelain` output is a path under `<FEATURE>/`. If any condition differs, stop and report the difference." Run both status forms and record both outputs.
2. P1-T4: change the command to `poetry -C <ROOT> run coverage json --pretty-print -o artifacts/python/coverage.json`, and change the Grep instruction to content mode with `-A 14` after the literal `"totals"` (no multiline mode needed).
3. P1-T5: replace the second regular expression with `^BRDA:.*,1\s*$` (covered branches, hit value `1`). Add: the first regular expression `^BRDA:` counts all branch records and is compared with `num_branches`; the third observation, the count of `^BRDA:.*,(0|-)\s*$`, is recorded and the covered plus uncovered counts must equal the first count. State that the third BRDA field is a description string and not an integer.
4. P2-T1 to P2-T5: state that P2-T1 checks off P0 and P1 tasks only, that the P2-T1 to P2-T5 check-offs are written to disk after P2-T5 passes, and that the resulting plan-file edit is reported to the caller as an uncommitted modification. P2-T3's empty-status acceptance is evaluated immediately after the commit and before those check-offs.
5. P1-T2 and P1-T3: add "run with a 600000 ms timeout; if exceeded, re-run in the background and read the result on completion" and the output-capture fallback from D8.
6. P1-T3: append "A mismatch is recorded as observed with both values and reported."
7. P2-T3: append a second `-m` argument carrying the line `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

Delta prose checked against tonality policy: no hyperbole, humor, or figurative language.
