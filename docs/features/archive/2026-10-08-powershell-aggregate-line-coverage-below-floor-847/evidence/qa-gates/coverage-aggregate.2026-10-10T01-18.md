# Coverage: Aggregate (Issue #847, AC-02)

Timestamp: 2026-10-10T01-18
Task: [P7-T4]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (rows "FULL_RUN (P7-T3 final)" and "CRP / JRP reductions"), CRP is applied by an equivalent Python reduction to the P7-T3 FULL_RUN coverage XML, which is the CI artifact `artifacts/ci/run-38011932558/powershell-coverage.xml` (the plan's `artifacts/pester/powershell-coverage.xml` is produced by CI on this route). Selection rules and the integer threshold are unchanged.
Command: `poetry run python <scratchpad>/reduce847.py artifacts/ci/run-38011932558/powershell-coverage.xml artifacts/ci/run-38011932558/pester-junit.xml` (output `artifacts/ci/run-38011932558/reduction.txt`), cross-checked with `poetry run python -I <scratchpad>/spot847.py artifacts/ci/run-38011932558/powershell-coverage.xml` (ElementTree read of the report-level `counter` children and the per-file rows; identical values).
EXIT_CODE: 0
Output Summary:
- Baseline aggregate (P0-T5, `evidence/baseline/pwsh-test-coverage-baseline.2026-10-09T23-46.md`, CI run 38005028184 at BASE_SHA `460cd755de560b733be0c471d1d144e553fbe0e5`): covered=13328 missed=2410 total=15738 pct=84.69 required=13378 gap=50 (FAIL).
- Post-change aggregate (CRP step 2; exactly one report-level LINE counter; run 38011932558 at `1c3d1a4c6`): covered=13918 missed=1898 total=15816 pct=88.0 required=13444 gap=0.
- Threshold (CRP step 4): 100*13918 = 1391800 >= 85*15816 = 1344360 -> PASS.
- Delta: covered +590 lines (13328 -> 13918), total +78 lines (15738 -> 15816), percentage +3.31 points (84.69 -> 88.0).
- New/changed-code coverage (sum over the eight PROD8 rows from P7-T5): covered=584 total=589 pct=99.15 (HostTooling 36/38, HostBootstrapWorkspace 70/70, HostBootstrap 155/155, HostVerification 149/149, SideloadedExtensionPublish 136/139, bootstrap-host.ps1 7/7, verify-host.ps1 7/7, publish-sideloaded-extension.ps1 24/24).
- Population: `Code coverage population: source=config; files=178` (baseline 174; +5 new modules, -1 deleted helper).
- Result: PASS (AC-02). The coverage-gap stop rule does not apply.
