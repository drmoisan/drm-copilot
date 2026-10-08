# Pass-After: New Issue-527 Suites (P4-T1)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P4-TR (replaces TR args 'tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1', '<23 titles>'). Source: run A, workflow `_poshqc.yml` on branch `bug/poshqc-coverage-denominator-not-reproducible-527` at a987ebfb184a8a1466d0faeb1dc99264c019f4d1, run https://github.com/drmoisan/drm-copilot/actions/runs/36983551836, job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194 (Format, Analyze, Test all success). Reductions: orchestrator `poetry run python artifacts/ci/ci_evidence.py tr artifacts/ci/run-36983551836/pester-junit.xml ...` into `artifacts/ci/run-36983551836/tr-new.txt`; executor re-check this segment: `poetry -C <ROOT> run python <ROOT>/artifacts/ci/ci_evidence.py named <ROOT>/artifacts/ci/run-36983551836/pester-junit.xml "<the 23 titles joined by ;>"` (C3 given as its fixed prefix `fails fast naming config/poshqc-coverage.json for `), exit 0.
EXIT_CODE: 0
Output Summary: PASSED=30 FAILED=0 SKIPPED=0 MISSING_REQUIRED=0 FAILED_CONTAINERS=0
- tr-new.txt: `PASSED=30 FAILED=0 SKIPPED=0 MISSING_REQUIRED=0`. FAILED_CONTAINERS=0 derived: the run A job log has no `##[error][-]` line and no container or discovery failure line, and JX reports `ERRORS=0`.
- All 23 titles present in run A JUnit: 22 titles with CASES=1 FAILED=0 SKIPPED=0 and the C3 template with CASES=8 FAILED=0 SKIPPED=0 (22 + 8 = 30 nodes).
- Acceptance: FAILED=0, MISSING_REQUIRED=0, FAILED_CONTAINERS=0, PASSED at least 30. Met. No assertion was weakened (the test files at a987ebfb are those written in Phase 2; `git log` shows no later edit to them).

## Named-title check output (executor re-run)

```text
measures an identical population for the repository and bundled settings copies over the same workspace CASES=1 FAILED=0 SKIPPED=0
measures only the consumer production file when a stale bundled allow-list names pushed-down files CASES=1 FAILED=0 SKIPPED=0
logs the population source and file count before Pester runs CASES=1 FAILED=0 SKIPPED=0
resolves a relative Root to an absolute path before building run, coverage, and output paths CASES=1 FAILED=0 SKIPPED=0
disables coverage, logs once, and still runs Pester when the derived population is empty CASES=1 FAILED=0 SKIPPED=0
hands the scan-configuration folders to the coverage resolver when -ScanFolders is absent CASES=1 FAILED=0 SKIPPED=0
returns the same ordinally sorted list for shuffled enumeration order CASES=1 FAILED=0 SKIPPED=0
collapses case-variant duplicates to one entry CASES=1 FAILED=0 SKIPPED=0
collapses files reached through overlapping roots CASES=1 FAILED=0 SKIPPED=0
excludes *.Tests.ps1 files, the root-level tests tree, and default excluded directories CASES=1 FAILED=0 SKIPPED=0
keeps only .ps1 and .psm1 files CASES=1 FAILED=0 SKIPPED=0
skips a nonexistent root with one warning naming the root CASES=1 FAILED=0 SKIPPED=0
returns an empty set when every root is missing CASES=1 FAILED=0 SKIPPED=0
reports the configuration as absent when the file does not exist CASES=1 FAILED=0 SKIPPED=0
returns the validated roots for a version 1 document CASES=1 FAILED=0 SKIPPED=0
fails fast naming config/poshqc-coverage.json for  CASES=8 FAILED=0 SKIPPED=0
honors a non-empty CodeCoverage.Path from a caller-supplied settings file over the workspace config CASES=1 FAILED=0 SKIPPED=0
prunes and logs each nonexistent caller-supplied settings path CASES=1 FAILED=0 SKIPPED=0
ignores CodeCoverage.Path in the module-default settings file and logs that it was ignored CASES=1 FAILED=0 SKIPPED=0
uses the workspace config roots over the fallback scan folders CASES=1 FAILED=0 SKIPPED=0
falls back to the scan-folder roots when no workspace config exists CASES=1 FAILED=0 SKIPPED=0
falls back to the settings Run.Path when no scan folders are supplied CASES=1 FAILED=0 SKIPPED=0
returns source config with an empty population when every configured root is missing CASES=1 FAILED=0 SKIPPED=0
```
