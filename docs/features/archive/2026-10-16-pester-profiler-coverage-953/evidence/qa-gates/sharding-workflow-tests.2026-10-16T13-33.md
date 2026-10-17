# Sharding Workflow Tests: PoshQcWorkflow (P8-T15)

Timestamp: 2026-10-16T13-33
Command: sh "SCRATCH/issue-953-p8-t15.sh" — TARGETED_RUN(`workflow`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`) through the Tool route: `$env:ISSUE953_PATHS = 'tests/scripts/workflows/PoshQcWorkflow.Tests.ps1'; $env:ISSUE953_JUNIT = Join-Path $S 'issue-953-workflow-junit.xml'; $start = [datetime]::UtcNow; pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.4.0 -MaximumVersion 5.99.99 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @($env:ISSUE953_PATHS -split '';''); $c.Run.Exit = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $true; $c.TestResult.OutputFormat = ''JUnitXml''; $c.TestResult.OutputPath = $env:ISSUE953_JUNIT; $c.Output.Verbosity = ''Detailed''; Invoke-Pester -Configuration $c' *> (Join-Path $S 'issue-953-workflow.log'); "EXIT_CODE=$LASTEXITCODE START_UTC=$($start.ToString('o'))"`, followed in the same script by the JUnit freshness check, JRP totals, and a per-testcase pass listing on `SCRATCH/issue-953-workflow-junit.xml`.
EXIT_CODE: 0

Output Summary:
- Run valid: JUNIT_FRESH=True (JUnit LastWriteTimeUtc later than START_UTC 2026-10-16T13:33:13.4921129Z).
- JRP totals: tests=10, failures=0, errors=0. All ten test cases passed.
- Updated cases: the job-set case asserts exactly `poshqc,poshqc-linux-hooks,poshqc-shard,poshqc-static`; the `poshqc` case asserts `name: PowerShell QC`, `windows-latest`, `needs: [poshqc-static, poshqc-shard]`, `Test-PoshQCShardCompleteness`, `Merge-PoshQCCoverageReport`, and artifact `poshqc-test-results`.
- New cases: `poshqc-shard` has `fail-fast: false`, matrix `shard: [1, 2, 3]`, `windows-latest`, `Invoke-PoshQCTest -Root`, `-ShardIndex ${{ matrix.shard }} -ShardCount 3`, a step named `Test PowerShell`, and an `if: always()` upload of `poshqc-test-results-shard-${{ matrix.shard }}`; `poshqc-static` runs `Invoke-PoshQCFormat` and `Invoke-PoshQCAnalyze` and not `Invoke-PoshQCTest`.
- The five `poshqc-linux-hooks` cases are textually unchanged (`git diff HEAD` shows no removed or added line inside them); because the edited `poshqc` case gained three lines, they now start at lines 65, 71, 76, 84, and 92 instead of 62, 68, 73, 81, and 89.
- Supporting checks on the workflow (P8-T14): `actionlint .github/workflows/_poshqc.yml` exited 0; a local discovery-only Pester pass (`Run.SkipRun = $true`) over the three new test files reported `TotalCount` 22, equal to the sum of their JUnit `testsuites/@tests` values (10 + 8 + 4), which is the comparison the completeness step makes.
