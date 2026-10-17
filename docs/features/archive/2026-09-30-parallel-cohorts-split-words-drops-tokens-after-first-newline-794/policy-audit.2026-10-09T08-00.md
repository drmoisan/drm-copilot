# Policy Audit: Issue #794 (pcoh_split_words separator handling)

- Branch: bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794
- Scope: full branch diff `origin/main...HEAD` (HEAD 0872bf33)
- Work mode: full-bug (spec.md is the AC source)
- Changed code languages: Bash only (`.claude/lib/bash/parallel-cohorts.sh`, bundled mirror, `tests/shell/parallel_cohorts.bats`). No TypeScript, Python, PowerShell, or C# files changed.

## Rejected Scope Narrowing

None. The caller prompt requested the full branch diff.

## Verdict Summary

| Policy | Verdict | Blocking |
|---|---|---|
| General code change | PASS | no |
| General unit test | PASS | no |
| Bash toolchain (format, lint) | PASS | no |
| Coverage (bash, kcov) | PASS | no |
| Evidence Location Compliance | PASS | no |
| Tonality | PASS | no |

Blocking findings (FAIL + blocking PARTIAL): 0

## General code change

- File size: library 340 lines, bundled mirror 340 lines, bats 350 lines; all under 500. Verified with `wc -l`.
- Fail-fast: the fix lengthens tokenization only; malformed tokens after a newline now reach existing integer validation (spec decision 7), verified by bats row "malformed token after a newline".
- No new suppressions: `grep "shellcheck disable"` in the diff added lines returns 0; the file retains its 2 pre-existing directives (lines 21, 30).
- Mirror: `cmp` of the library and bundled mirror exited 0 (byte-identical).
- Simplicity: the fix reuses the tokenizing expression already used at `parallel-lane-assertion.sh:88`; no new helper.
- Verdict: PASS.

## General unit test

- Location: new rows are in `tests/shell/parallel_cohorts.bats`, the mirrored location for `.claude/lib/bash/parallel-cohorts.sh` under this repository's bats layout.
- No temporary files: the rows use `$'...'` literals; no `mktemp`/`BATS_*TMPDIR` tokens (evidence `size-and-hygiene`, count 0). No new fixtures.
- Determinism: no clocks, sleeps, or network.
- Scenario completeness: positive (newline, tab, CR, VT, FF, CRLF, mixed), negative (malformed token, duplicate key), edge (whitespace-only, newline-only, glob characters, unset argument), and library-level direct call. 15 new rows.
- Fail-first: CI run 37896730789 (head 36795b64) concluded `failure` with 15 `not ok` lines, all `separator-parity:`; the check step succeeded. CI run 37897674234 (head 5cbd8485) concluded `success`. Both verified directly with `gh run view`.
- Verdict: PASS.

## Bash toolchain

- `shellcheck -x .claude/lib/bash/parallel-cohorts.sh`: exit 0 (run by this review).
- `shfmt -d .claude/lib/bash/parallel-cohorts.sh`: exit 0, no diff (run by this review).
- CI `Run shell-qc check` step: `success` on run 37897674234 (evidence `final-shell-check-ci`).
- Local bats is not installed on the review host; the local `shell-qc.sh test` output is recorded as a vacuous pass and the evidence file correctly declares it non-evidence. CI is the authority.
- Verdict: PASS.

## Coverage verification (bash)

The coverage artifact table in the review procedure has no bash row. Bash coverage is produced by kcov in the `_shell-coverage.yml` CI job; evidence is `final-shell-coverage-ci` and `coverage-comparison`.

| Metric | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|
| Repo-wide line coverage | 94.2% | 94.2% | >= 85% | PASS |
| `parallel-cohorts.sh` line coverage (modified file) | 99.3% | 99.3% | >= 85%, no regression | PASS |
| Changed lines 67 and 138 hit counts | n/a | 1 each | >= 1 | PASS |

No branch gate applies to bash (kcov measures lines only). The two changed executable lines are executed. The comparison is recorded evidence; this review did not rerun kcov, per the no-rerun rule.

Verdict: PASS.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exited 0.
- The branch diff contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence is under `<FEATURE>/evidence/{baseline,regression-testing,qa-gates,other}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event applies.
- Verdict: PASS.

## Observations (non-blocking)

1. Scope drift is documented, not a violation: `pcoh_build_adjacency` was changed although spec scope lists only `pcoh_split_words`. `evidence/other/spec-gap-note` records the reason with before/after reproductions and states orchestrator acceptance. `spec.md` itself was not updated to reflect the added change.
2. `ac-status-summary` and spec checkboxes are already checked by the executor; the reviewer concurs (see feature-audit).
