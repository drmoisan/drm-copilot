# Preflight Fixes (remediation cycle 4)

Timestamp: 2026-11-14T02-08
Plan: docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-14T01-40.md
Result: PREFLIGHT: ALL CLEAR (three trivial fixes in task text; no substantive defect)
Validator: branch Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` exit 0 before and after the fixes, with no warning.

## Fixes

1. [P2-T1] | typo | "No other function, the table, the executing-option scan, and the D18 sentence stay unchanged." read as a list with a missing verb; changed to "No other function changes; the table, the executing-option scan, and the D18 sentence stay unchanged." Meaning unchanged.
2. [P3-T5] | citation correction | six test files were named by bare file name after the first full path; each now carries its full repository-relative path under `tests/scripts/dev_tools/`. The file set is unchanged.
3. [P3-T6] | literal formatting | the `python` token search is stated as case-sensitive, matching the AC-21 intent (no `python` invocation) and the prior cycles' parity evidence; the sibling help text carries the capitalized words "Python tools" naming a stage-1 pattern group, which a case-insensitive search would report. The asserted value is unchanged.

## Design check (recorded in this pass, no further artifact)

Prototype in SCRATCH on the unmodified tree, both surfaces: at head ED-97 to ED-116 are unclassified and ED-117 to ED-120 classified; the two `confirms` cases return false and the two `clears` cases false. With the D19 draft (loop replaced by one statement; 486 logical lines before help text), all 24 rows are classified, the four cases return their expected values, and the classification corpus (ED, FP, NG) has zero mismatches; the 39 Modelled-suite cases and the 45 unmocked literal calls of the commands suite keep their values. Mutants: skipping only listed value-taking options is killed by the `--no-pager` case; rejecting any option in the record is killed by the `git log --oneline` case and FP-07; reading token 1 is killed by the `timeout 60 npm ls prettier` case; reading an attached `=value` as the subcommand is killed by ED-117 to ED-120.
