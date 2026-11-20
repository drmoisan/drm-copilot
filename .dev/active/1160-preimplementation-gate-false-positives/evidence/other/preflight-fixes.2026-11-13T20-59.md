# Preflight Fixes — Remediation Cycle 3 Plan, Confirming Preflight (Issue 1160)

Timestamp: 2026-11-13T20-59
Plan: docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T19-53.md
Preflight-Signal: PREFLIGHT: REVISIONS REQUIRED (iteration 2; the fix below is trivial and was made in place; substantive defects are reported in the preflight return)

## Fixes

1. `## Design: decision D17` (Posix allowlist, unmodelled shell-state builtins) | ambiguous literal | "`printf` with a `-v` option" changed to "`printf` with a `-v` option, separate or attached as `-vNAME`". Bash's `printf` builtin accepts the attached form (`printf -vc hello` sets `c`), and a check written as an exact `-v` token match leaves `printf -vc pytest; env $c` unclassified in the SCRATCH prototype. The clause already covers the attached form in meaning; the edit states it, so no row, case, count, or acceptance value changes.

No task was added, removed, or reordered, and no acceptance value changed.

## Verification Context (SCRATCH prototype, both surfaces, identical output)

- Rows ED-51 to ED-93: 43 rows with unique identifiers; each is unclassified at head, classified at the merge base, and classified under D17. ED-86 to ED-93 each return unclassified under the mutant that removes only its own clause.
- New suite: 38 cases (35 classified, 3 guards). All 35 return `$false` at head and `$true` under D17; the 3 guards return `$false` under both. The six clause cases each return `$false` under their own clause mutant.
- Existing corpus: 76 ED, FP, and NG rows keep their expected values at head and under D17; the 47 literal calls of the existing commands suite keep their asserted values (two calls whose assertion depends on a mocked host table are outside the harness and are unaffected, because the head result is returned first).
- Counts: 43 rows, 35 classified cases plus 3 guards, and 242 expected failures (43 x 2 tests x 2 runners plus 35 x 2 surfaces) match the plan text.
- Validator: the branch Python CLI `plan` subcommand exits 0.
