# Coverage verification (#884)

Timestamp: 2026-10-16T00-28
Command: Read of docs/features/active/untouched-files-coverage-verification-884/evidence/other/ci-per-file-coverage.2026-10-15T11-47.md; Grep -n source assertions listed in the sections below (executed with the Grep tool; the Bash tool does not permit grep)
EXIT_CODE: 0
Output Summary: AC1 bash 44/44 (100.00%) and AC2 Codex hook 146/146 (100.00%) on CI run 38683717593, both at or above the 85% floor. #917 kcov record 81.82% to 100.00% and #896 Pester record 99.29% to 100.00% cited with file and line. The 7.30% figure is superseded. Every source assertion printed the line numbers stated in the plan.

## AC1 and AC2 figures (from the CI artifact)

Source: `docs/features/active/untouched-files-coverage-verification-884/evidence/other/ci-per-file-coverage.2026-10-15T11-47.md` (lines 6 and 24-25).

- AC1-FIGURE: 44/44 (`.claude/lib/bash/compute-concurrency-batches.sh`, kcov, 100.00%, floor 85%, CI run 38683717593).
- AC2-FIGURE: 146/146 (`.codex/hooks/validate-feature-review-coverage.ps1`, Pester, 100.00%, floor 85%, CI run 38683717593).
- IMPLEMENTATION-HANDOFF: NOT REQUIRED (no code change)

## CORROBORATION-917:

Committed records for PR #917 (bash file raised by bats tests):

- `docs/features/active/2026-10-11-compute-concurrency-batches-coverage-884/evidence/qa-gates/ci-kcov-per-file-coverage.2026-10-12T13-16.md` line 6: baseline line coverage 81.82% (kcov CI run 38057811190), post-change 100.00% (line-rate 1.000), delta +18.18 percentage points. Observed: Grep for "81.82" printed line 6; Grep for "1.000" printed line 6.
- `docs/features/active/2026-10-11-compute-concurrency-batches-coverage-884/policy-audit.2026-10-12T14-00.md` lines 11, 31, 39, 49, 51, and 85: per-file kcov coverage of the script rose from 81.82% to 100.00%. Observed: Grep for "100.00" printed lines 11, 31, 39, 49, 51, 85.

## CORROBORATION-896:

Committed records for #896 (Codex hook raised by the Pester suite):

- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/final-pester-coverage.2026-10-12T08-31.md` line 15: `covered=146 | missed=0 | pct=100.00`. Observed: Grep for "covered=146" printed line 15.
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/pester-coverage.2026-10-11T23-30.md` lines 8 and 15: baseline `pct=99.29` (covered=140, missed=1). Observed: Grep for "covered=140" printed lines 8 and 15.
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/coverage-delta.2026-10-12T08-38.md` lines 6 and 17: Codex hook baseline 99.29 to post-change 100.00. Observed: Grep for "99.29" printed lines 6 and 17.

## SUPERSEDED-7.30: YES

The 7.30% figure (10 of 137 lines) cited in #884 is superseded by later measurements.

- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/pester-coverage.2026-10-11T23-30.md` line 8: "A previously cited figure of 7.30% does not match this measurement and is not used." Observed: Grep for "7.30" printed line 8.
- `docs/features/active/subagentstop-envelope-feature-review-coverage-896/policy-audit.2026-10-12T11-25.md` line 142: "The 7.30% Codex figure cited in #884 is superseded by the 99.29% baseline measurement." Observed: Grep for "superseded" printed line 142.
- Origin of the figure: `docs/features/potential/promoted/2026-10-08-powershell-aggregate-line-coverage-below-floor.md` line 52: `.codex/hooks/validate-feature-review-coverage.ps1` 10/137 (7.30%). Observed: Grep for "10/137" printed line 52.
