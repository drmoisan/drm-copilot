# Acceptance-Criteria Check-Off Record (Issue #710)

Timestamp: 2026-09-27T02-47
Source: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/spec.md`, section `## Acceptance Criteria`

Name checks for AC-1 to AC-5 were made with `sh <SCRATCHPAD>/p6-names.sh` (exec pwsh -NoProfile -File <SCRATCHPAD>/p6-names.ps1), which counts, per surface, the `PASSED:` or `FAILED:` lines that end with `.` followed by the name and contain `(.claude/hooks)` or `(.codex/hooks)`. Every required count was 1.

| AC | Spec line | Evidence | Outcome |
| --- | --- | --- | --- |
| AC-1 | 206 | `qa-gates/pass-after-chain-escape.md` (PASSED, both surfaces), `regression-testing/fail-before-chain-escape.md` (FAILED, both surfaces) for the three escaped-operator names. Fail-before evidence location: `EVIDENCE_LOCATION_OVERRIDE_REJECTED: .../evidence/regression/ replaced with .../evidence/regression-testing/` (plan header). | Checked off |
| AC-2 | 207 | `qa-gates/pass-after-chain-escape.md` (PASSED, both surfaces) and `regression-testing/fail-before-chain-escape.md` (FAILED, both surfaces) for `exempts a commit whose message contains an escaped semicolon`. | Checked off |
| AC-3 | 208 | `qa-gates/pass-after-chain-escape.md` (PASSED, both surfaces, "ends with" form) for the five `still splits on unescaped` expansions; `qa-gates/final-pester-full.md` (pass 2) ChainEscape row `tests=38 failures=0 errors=0`. | Checked off |
| AC-4 | 209 | `qa-gates/pass-after-chain-escape.md` (PASSED, both surfaces) for `still splits after an escaped backslash`, `splits on the unescaped ampersand after an escaped one`, `keeps backslash literal inside single quotes`, `does not exempt a chained command after an escaped backslash`. | Checked off |
| AC-5 | 210 | `qa-gates/pass-after-chain-escape.md` (PASSED, both surfaces) for `does not split after an odd run of backslashes`, `consumes an escaped double quote inside double quotes`, `does not open a quote on an unquoted escaped double quote`, `treats a trailing lone backslash as balanced`, `treats backslash-newline as a line continuation`. | Checked off |
| AC-6 | 211 | `qa-gates/mirror-parity-sha256.md` (`BYTE_IDENTICAL: True`; four SHA256 values all `EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A`); `qa-gates/parity-and-legacy-contracts.md` (EXIT_CODE 0, FailedCount 0, the three required PASSED lines present); `qa-gates/final-pester-full.md` (pass 2) Parity and legacy-codex rows `failures=0 errors=0`. | Checked off |
| AC-7 | 212 | `qa-gates/canonical-edit-checks.md` (`PRE_EDIT_LINE_COUNT: 497`, `POST_EDIT_LINE_COUNT: 497`, at most 500; hunks at pre-image lines 63, 77, 78 inside `[58, 108]`); `qa-gates/scope-boundary.md` (BASE_ANCESTOR_EXIT 0; numstat lists exactly the five section 2 paths, each helper copy 5/5; porcelain inside the feature folder only; every helper hunk inside the region). | Checked off |
| AC-8 | 213 | `qa-gates/final-pester-full.md` (pass 2) ChainEscape row `tests=38 failures=0 errors=0`; `qa-gates/test-portability-inspection.md` (every listed token and the drive-letter expression `matches=0`, `Join-Path` `matches=3`, `$PSScriptRoot` `matches=1`). LOCAL_CLAUSES: MET. CI_CLAUSE: PENDING - the orchestrator checks off AC-8 after the ci.yml PoshQC job passes on the pull-request head | Left unchecked (CI clause pending) |
| AC-9 | 214 | `qa-gates/final-pester-full.md` (pass 2): the rows for both CommandExemption suites, the EpicScope and TriggerScoping suites, and the Codex trigger-scoping, mode-resolution, and mode-routing suites each read `failures=0 errors=0` (119, 119, 19, 19, 23, 55, 11 tests). `B_FULL` is empty. | Checked off |
| AC-10 | 215 | Pass 2 (named by `qa-gates/final-seven-stage-loop.md`): `qa-gates/final-poshqc-format.md` (`Formatted: ` 0, porcelain unchanged), `qa-gates/final-poshqc-analyze.md` (no findings), `qa-gates/final-scoped-coverage.md` (97.08% both copies, four changed lines executed), `qa-gates/final-coverage-delta.md` (97.04 to 97.08, changed-line 100%), `qa-gates/final-pester-full.md` (`JUNIT_FAILURES: 0`, `JUNIT_ERRORS: 0`). Coverage evidence location: `EVIDENCE_LOCATION_OVERRIDE_REJECTED: .../evidence/coverage/ replaced with .../evidence/qa-gates/` (plan header). | Checked off |
| AC-11 | 216 | `other/follow-up-d7-operand-gap.md` (all seven labels present with non-empty values: Timestamp, Title, Function, Reproduction, Candidate fixes, Relation to #710, Filing route); `qa-gates/scope-boundary.md` (no hunk at or after base line 110; `Test-ExemptOrchestrationOperand` at base line 220 unchanged in all four copies). | Checked off |

## AC-8 Row Detail

LOCAL_CLAUSES: MET
CI_CLAUSE: PENDING - the orchestrator checks off AC-8 after the ci.yml PoshQC job passes on the pull-request head
