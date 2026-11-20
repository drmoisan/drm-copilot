# Final Full Suite, Run A (P6-T4)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P6-RUNS (replaces FR args '.', 'final-run-a.log', then JX args '.', then the local `Copy-Item` to `final-run-a-coverage.xml`). Source: run A, workflow `_poshqc.yml` on `bug/poshqc-coverage-denominator-not-reproducible-527` at a987ebfb184a8a1466d0faeb1dc99264c019f4d1, run https://github.com/drmoisan/drm-copilot/actions/runs/36983551836, job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194, step `Test PowerShell` (`Invoke-PoshQCTest -Root <CI_ROOT>` with the branch copy of PoshQC). Artifact `poshqc-test-results` downloaded by the orchestrator to `artifacts/ci/run-36983551836/` (git-ignored; this download replaces the local copy to `final-run-a-coverage.xml`). JUnit reduced with `poetry run python artifacts/ci/ci_evidence.py jx artifacts/ci/run-36983551836/pester-junit.xml` (jx.txt). Population line read with the Grep tool from the job log (the CI step logs to the job log, which replaces `artifacts/pester/final-run-a.log`).
EXIT_CODE: 0
Output Summary: TESTS=6529 FAILURES=0 ERRORS=0 DISABLED=10
- Job log line 837: `Code coverage population: source=config; files=174` (the only `source=config` line in the log; the four `source=settings; files=1` lines at 1252-1256 are output of unit tests that call `Invoke-PoshQCTest` with injected settings).
- Pester summary (job log line 1274): `Tests Passed: 6519, Failed: 0, Skipped: 10`. Job conclusion success for Format, Analyze, and Test.
- Code tree: a987ebfb; the run used the same tree that this segment's local MCP format and analyze calls observed (no file outside the feature folder changed since).
- Acceptance: EXIT_CODE 0 and the JX line shows FAILURES=0 ERRORS=0 (AC-15). Met.
