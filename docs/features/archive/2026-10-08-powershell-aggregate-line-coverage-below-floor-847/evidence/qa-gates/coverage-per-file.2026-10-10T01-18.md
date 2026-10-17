# Coverage: Per File (Issue #847, AC-03)

Timestamp: 2026-10-10T01-18
Task: [P7-T5]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (rows "FULL_RUN (P7-T3 final)" and "CRP / JRP reductions"), CRP step 3 is applied by an equivalent Python reduction to the P7-T3 FULL_RUN coverage XML `artifacts/ci/run-38011932558/powershell-coverage.xml`. ROOT is `D:/a/drm-copilot/drm-copilot` (inferred from the `.claude/hooks` package name); D = `scripts/dev-tools`; package match is case-insensitive equality with `ROOT/D`; sourcefile match is exact.
Command: `poetry run python <scratchpad>/reduce847.py artifacts/ci/run-38011932558/powershell-coverage.xml artifacts/ci/run-38011932558/pester-junit.xml` (output `artifacts/ci/run-38011932558/reduction.txt`), cross-checked with `poetry run python -I <scratchpad>/spot847.py artifacts/ci/run-38011932558/powershell-coverage.xml` (row counts per file name and LINE counters; identical values).
EXIT_CODE: 0
Output Summary:
- Every PROD8 row has exactly one matching sourcefile under package `D:/a/drm-copilot/drm-copilot/scripts/dev-tools` and exactly one LINE counter.

| File | covered | missed | total | pct | required | Result |
|---|---|---|---|---|---|---|
| HostTooling.psm1 | 36 | 2 | 38 | 94.74 | 33 | PASS |
| HostBootstrapWorkspace.psm1 | 70 | 0 | 70 | 100.0 | 60 | PASS |
| HostBootstrap.psm1 | 155 | 0 | 155 | 100.0 | 132 | PASS |
| HostVerification.psm1 | 149 | 0 | 149 | 100.0 | 127 | PASS |
| SideloadedExtensionPublish.psm1 | 136 | 3 | 139 | 97.84 | 119 | PASS |
| bootstrap-host.ps1 | 7 | 0 | 7 | 100.0 | 6 | PASS |
| verify-host.ps1 | 7 | 0 | 7 | 100.0 | 6 | PASS |
| publish-sideloaded-extension.ps1 | 24 | 0 | 24 | 100.0 | 21 | PASS |

- `bootstrap-host.helpers.ps1`: zero sourcefile rows in any package (the file left the population).
- (information) `vscode-cli.helpers.ps1`: covered=15 missed=12 total=27 pct=55.56 (excluded path; unchanged by this plan; baseline 9/27).
- Result: PASS (AC-03). All eight PROD8 rows meet `100*covered >= 85*total`.
