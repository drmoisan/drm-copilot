# CI Evidence for CI-Deferred Gates (issue #791)

Timestamp: 2026-10-10T13-20
Command: gh workflow run ci.yml --ref bug/issue-763-parallel-skill-cli-port-follow-ups-791 (run 38053315951, workflow_dispatch); evidence read with gh run view 38053315951 --job <id> --log and gh api repos/drmoisan/drm-copilot/actions/artifacts/<id>/zip
EXIT_CODE: 0
Output Summary: CI run 38053315951 at head c81ffad7ef1fa30aa59246a27adcc5f8323d6eae concluded success on all 17 jobs. Bats under kcov: TAP plan 1..592, 592 ok, 0 not ok. kcov line coverage: remove-parallel-item.sh 99.1%, parallel-mutation.sh 95.7%, overall 94.5%. Pester (PowerShell QC): Tests Passed 6744, Failed 0, Covered 87.31%; R791-O1 status Passed. Pester (Linux hook suites): Tests Passed 3416, Failed 0.

This artifact closes the CI-deferred branches recorded in the [P0-T11], [P0-T12], [P0-T13] to [P0-T15], [P4-T11] to [P4-T14], [P8-T9] to [P8-T13] artifacts. Local bats and PowerShell runs were not performed under the operator constraint recorded in `evidence/other/execution-deviations.2026-10-10T08-02.md`.

## Run identity

- Run: https://github.com/drmoisan/drm-copilot/actions/runs/38053315951
- Head SHA: c81ffad7ef1fa30aa59246a27adcc5f8323d6eae
- Conclusion: success (all 17 jobs)

## Shell Coverage (Bats + kcov), job 114216674796

- `bash scripts/bash/shell-qc.sh check` step: success (shfmt 3.8.0 diff and shellcheck).
- `bash scripts/bash/shell-qc.sh test --coverage` step: success. TAP plan `1..592`; 592 lines `ok`; 0 lines `not ok`.
- Selected cases from the log:
  - `ok 23 the six CLI entry points are present in both trees`
  - `ok 178 decide withdraws a proposed item and recomputes` (first case of `tests/shell/parallel_mutation_remove.bats`)
  - `ok 221 the remove parity corpus meets the declared floor`
  - `ok 222 the harness interpreter is available to read the corpus`
  - `ok 223 the bash lane reproduces every remove corpus fixture`
  - `ok 238 the payload runs remove-parallel-item.sh without Python on PATH`
  - `ok 239 the payload recolors unstarted items without Python on PATH`
- Summary line: `Bash coverage (lines): 94.5%`.
- Artifact `shell-coverage` (id 11670037917), `cov.xml`:
  - `.claude/lib/bash/remove-parallel-item.sh` line-rate 0.991
  - `.claude/lib/bash/parallel-mutation.sh` line-rate 0.957
  - totals line-rate 0.945 (2849 / 3016)
- Baseline for [P0-T11]: the bats suites `parallel_payload_only.bats` and `parallel_bash_manifest_membership.bats` gained exactly the two payload cases listed above; the membership case was renamed, not added.

## PowerShell QC, job 114216674984

- `Tests Passed: 6744, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
- `Covered 87.31% / 0%. 22,010 analyzed Commands in 178 Files.`
- Artifact `poshqc-test-results` (id 11670287994), `pester-junit.xml`: testcase `enforce-parallel-abandon-gate.ps1 trigger scoping (issue #545).Issue 791 remove entry point.R791-O1 keeps the remove entry point removal-disposition option out of scope` has `status="Passed"`.
- Reference: the PowerShell QC job on main-based commit b9e1f75 reported `Tests Passed: 6743, Failed: 0` and `Covered 87.31%`; the branch adds one test and the hook coverage did not regress.

## PowerShell hook suites (Linux), job 114216674923

- `Tests Passed: 3416, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`

## Python (Code Quality & Tests 3.10 to 3.13)

- All four matrix jobs: success.

## AC mapping

| AC | Gate | Result |
| --- | --- | --- |
| AC-8 | bats unit suite `parallel_mutation_remove.bats` | PASS (0 not ok in 592) |
| AC-9 | bats unit suite `parallel_mutation_remove.bats` | PASS |
| AC-10 | bats parity lane `parallel_mutation_remove_parity.bats` | PASS (cases 221 to 223 ok) |
| AC-11 | shell-qc check and payload/membership bats | PASS |
| AC-12 | payload bats cases 238 and 239 | PASS |
| AC-13 | Pester R791-O1, Failed 0 | PASS |
| AC-18 | kcov line coverage >= 85% for both new files | PASS (99.1%, 95.7%) |
