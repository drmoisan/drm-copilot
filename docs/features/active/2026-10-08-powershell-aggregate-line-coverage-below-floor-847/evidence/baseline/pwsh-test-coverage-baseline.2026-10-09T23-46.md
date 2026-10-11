# PowerShell Test and Coverage Baseline (Issue #847, AC-01)

Timestamp: 2026-10-09T23-46
Task: [P0-T5]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (rows "FULL_RUN (P0-T5 baseline)" and "CRP / JRP reductions"), the local `pwsh` FULL_RUN is replaced by the CI `poshqc / PowerShell QC` job on `main` at BASE_SHA, and the CRP/JRP reductions are performed by an equivalent Python reduction over the same XML files. Thresholds and derivations are unchanged.
Command: CI run 38005028184 (workflow CI, push to `main` at 460cd755de560b733be0c471d1d144e553fbe0e5), job `poshqc / PowerShell QC` (id 114071725598), step `Import-Module "<root>/scripts/powershell/PoshQC/PoshQC.psm1"; Invoke-PoshQCTest -Root "<root>"` (no `-ScanFolders`, no `-SettingsPath`). Artifact `poshqc-test-results` downloaded with `gh run download` to `artifacts/ci/run-38005028184/`. Reduction: `poetry run python <scratchpad>/reduce847.py artifacts/ci/run-38005028184/powershell-coverage.xml artifacts/ci/run-38005028184/pester-junit.xml` (output saved as `artifacts/ci/run-38005028184/reduction.txt`).
EXIT_CODE: 0
Output Summary:
- Commit measured: 460cd755de560b733be0c471d1d144e553fbe0e5 (BASE_SHA; branch HEAD c04940465584cedb9df7f85efd17b64dfc56870d is identical in PowerShell content per the P0-T2 artifact)
- Population line (job log line 839, exactly 1 occurrence of `Code coverage population: source=config`): `Code coverage population: source=config; files=174`
- JRP step 5 totals: tests=6534 failures=0 errors=0 (disabled=10); failed testcases: 0 (baseline failure set is empty)
- CRP aggregate: covered=13328 missed=2410 total=15738 pct=84.69 required=13378 gap=50 -> FAIL (below 85%)
- CRP per-file (D = scripts/dev-tools):
  - bootstrap-host.ps1 covered=0 missed=177 total=177 pct=0.00
  - verify-host.ps1 covered=0 missed=153 total=153 pct=0.00
  - publish-sideloaded-extension.ps1 covered=0 missed=138 total=138 pct=0.00
  - bootstrap-host.helpers.ps1 covered=0 missed=43 total=43 pct=0.00
  - vscode-cli.helpers.ps1 covered=9 missed=18 total=27 pct=33.33 (context)

## FULL_RUN validity conditions (substituted route)

- (a) Freshness: the coverage and junit files are the artifact uploaded by job 114071725598 of run 38005028184 itself, so they were produced by that run.
- (b) Population line: the job log contains exactly one line with the literal `Code coverage population: source=config` (line 839). The other `Code coverage population` lines in the log (`source=settings; files=1`, lines 1254-1258) are output of PoshQC's own Pester tests and do not match the literal.
- (c) Command text: job log line 835 shows `Invoke-PoshQCTest -Root "D:\a\drm-copilot\drm-copilot"` with no `-ScanFolders` and no `-SettingsPath`.

## Reduction details

- ROOT inferred from the `.claude/hooks` package name: `D:/a/drm-copilot/drm-copilot`; packages=19, sourcefiles=174.
- Each per-file row was located with package name equal to `ROOT/scripts/dev-tools` and an exact sourcefile name match (one row each).
- PROD8 new-code total at baseline: covered=0 total=468 (the five new modules do not exist yet; their rows are absent, as expected before the change).
- Files below 85% at baseline: 42.
