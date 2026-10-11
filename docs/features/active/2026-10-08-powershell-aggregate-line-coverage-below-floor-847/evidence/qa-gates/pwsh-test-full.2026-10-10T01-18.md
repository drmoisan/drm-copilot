# Final QA: PowerShell FULL_RUN (Issue #847, AC-11 test stage)

Timestamp: 2026-10-10T01-18
Task: [P7-T3] (loop iteration 1)
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (rows "FULL_RUN (P7-T3 final)" and "CRP / JRP reductions"), the local `pwsh` FULL_RUN is replaced by a `workflow_dispatch` of `_poshqc.yml` on the final branch head, which runs `Invoke-PoshQCTest -Root` with no `-ScanFolders` and no `-SettingsPath`; the JRP reduction is the equivalent Python reduction over the same XML. Acceptance conditions are unchanged. PR CI confirmation is AC-15 and is decided in a later stage.
Command: CI run 38011932558 (`workflow_dispatch` of `.github/workflows/_poshqc.yml` with `--ref bug/powershell-aggregate-line-coverage-below-floor-847`), job `PowerShell QC` 114093650487, step "Test PowerShell": `Invoke-PoshQCTest -Root "D:\a\drm-copilot\drm-copilot"` (job log line 835). Artifact downloaded to `artifacts/ci/run-38011932558/` (`pester-junit.xml`, `powershell-coverage.xml`, `poshqc-job.log`). Reduction: `poetry run python <scratchpad>/reduce847.py artifacts/ci/run-38011932558/powershell-coverage.xml artifacts/ci/run-38011932558/pester-junit.xml` (output `artifacts/ci/run-38011932558/reduction.txt`).
EXIT_CODE: 0
Output Summary:
- Commit measured: `1c3d1a4c6d0cc741081f45511c3ab6c5adf2d184` (checkout line 101 of the job log resets the branch to the remote ref; the SHA appears in the log). Every CPFS blob at this commit equals the worktree file (`pwsh-format.2026-10-10T01-18.md`).
- Step result: job conclusion success; the Pester summary at log line 1294 reads `Tests Passed: 6699, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`. The shipped run settings set `Run.Exit = $true`, so a successful step means the Pester exit code was 0 (EXIT_CODE 0).
- Population line (log line 839): `Code coverage population: source=config; files=178`.
- JRP step 5 on `pester-junit.xml`: `testsuites` tests=6709 failures="0" errors="0" disabled=10; `//testcase[@status='Failed']`: 0. Baseline failure set (P0-T5) is empty; no `PRE-EXISTING FAILURES`.
- Result: PASS.

## FULL_RUN validity conditions (substituted route)

- (a) Freshness: the XML files are the `poshqc-test-results` artifact uploaded by job 114093650487 of run 38011932558 itself. The head commit `1c3d1a4c6` was committed at 2026-10-10T00:59:57Z; the job checked out the branch at 2026-10-10T01:07:45Z (log line 100) and produced the artifact after that. P7-T1 changed no CPFS file (`UNCHANGED_HASHES=19`), so the run measures the current tree.
- (b) Population line: `grep -c "Code coverage population: source=config"` over `poshqc-job.log` returns 1 (line 839). The other population lines (`source=settings; files=1`, lines 1271-1275) are output of PoshQC's own Pester tests and do not match the literal.
- (c) Command text: the "Test PowerShell" step runs `Invoke-PoshQCTest -Root "${{ github.workspace }}"` (`.github/workflows/_poshqc.yml` line 42; rendered at log line 835) with no `-ScanFolders` and no `-SettingsPath` argument.
