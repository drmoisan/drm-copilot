# Fail-before exception dossier (remediation cycle 2, P4-T4)

Timestamp: 2026-10-16T16-07
Command: sh "SCRATCH/issue-953-r2-p4-t4.sh" (pwsh text: @(git show 136d02fcb4ab6b87f87dc01479571f028262119b:tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Select-String -SimpleMatch -Pattern '{4}if:').Count; the same count for '{8}if:'; JRP token lines read from the latest r2-regression-fail-before.*.md and r2-regression-pass-after.*.md; the CRP L(..., 174) line read from the latest remediation-baseline/r2-poshqc-test-coverage.*.md)
EXIT_CODE: 0
Output Summary: four new cases pass on the pre-fix tree by design: WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS, WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE, WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS, and TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON. The alternative proofs below are absence-of-test proofs (WF01, TS04) and an in-memory mutation check (WF02, via WF03).
WhyFailingRunImpossible: WF01 asserts the job-level `if: always()` condition that decision D17 keeps unchanged, and WF02 asserts a gate step that is already committed and must not be removed from the workflow, so neither can fail on a correct tree. WF03 is a check of the WF02 helper, and TS04 covers an existing seam whose behavior this cycle does not change.

## Alternative proof

- WF01: WF01_PRE_CYCLE_JOB_IF_ASSERTIONS: 0. No line of the pre-cycle test file (commit 136d02fcb4ab6b87f87dc01479571f028262119b) contains `{4}if:`, so no pre-cycle test asserts the job-level condition of any job. The only pre-cycle `if:` assertion uses `{8}if:` (count 1, line 110, the shard upload step).
- WF02: `TOKEN WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS PASS` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r2-regression-fail-before.2026-10-16T15-59.md` and `TOKEN WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS PASS` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/regression-testing/r2-regression-pass-after.2026-10-16T16-07.md`. WF03 shows that the WF02 helper reports each of the four in-memory mutations (removed, weakened, no exit, moved), so WF02 fails whenever the gate step is removed or weakened.
- TS04: `L('scripts/powershell/poshqc/poshqc.testing.psm1', 174) = ci=0 mi=1` in `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/remediation-baseline/r2-poshqc-test-coverage.2026-10-16T15-56.md`. The default `WriteShardFileList` seam body was not executed by any pre-cycle test (absence-of-test proof, `ci=0`).
