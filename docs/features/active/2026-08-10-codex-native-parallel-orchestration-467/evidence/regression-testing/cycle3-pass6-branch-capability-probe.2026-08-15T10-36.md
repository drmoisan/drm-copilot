# Cycle 3 Pass 6 Branch Capability Probe

Timestamp: 2026-08-15T12:03:13-04:00
Task: `[P1-T2]`
EXIT_CODE: 0
Result: PASS for probe completeness; no genuine branch collector was established.

## Scope and method

The twelve candidates inventoried by `[P1-T1]` were exercised or interrogated with read-only, deterministic PowerShell probes. The probes used existing repository-owned source files and the fresh default-toolchain outputs `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`. No test suite or MCP quality-gate command was repeated during this task.

The required numeric fields use only genuine source-attributable observed control-flow outcomes. Command hits, line hits, AST/source positions, correlations, test outcomes, configuration values, and synthetic counters are excluded from those fields.

## Exact commands

The following commands were executed from repository root through `pwsh`.

### P1T2-CMD-1 — in-memory `Invoke-PoshQCTest` seam probe

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.Testing.psm1 -Force; Invoke-PoshQCTest twice with injected EnsureModule, InvokePester, TestPathExists, Logger, and CopyCoverage scriptblocks: once with the configured source path reported present and once with it reported missing; capture CodeCoverage.Enabled, forwarded paths, prune/disable log counts, test result, and any returned branch records as compressed JSON; compute SHA-256 over the UTF-8 JSON bytes.
```

This command performed no file write. It observed the following exact result:

```json
{"source":"scripts/powershell/PoshQC/PoshQC.Testing.psm1","existing_path":{"scenario":"existing_path","coverage_enabled":true,"forwarded_paths":["C:/Users/DanMoisan/repos/drm-copilot-wt/2026-08-10T19-25/scripts/powershell/PoshQC/PoshQC.Testing.psm1"],"prune_log_count":0,"disable_log_count":0,"test_passed":1,"genuine_branch_records":0},"missing_path":{"scenario":"missing_path","coverage_enabled":false,"forwarded_paths":["scripts/powershell/PoshQC/missing-branch-probe.ps1"],"prune_log_count":1,"disable_log_count":1,"test_passed":1,"genuine_branch_records":0}}
```

Output SHA-256: `75958AE8E50ED6A9342857E2FD01C505359F7C32EFDD70B8B5F1CCF489D45564`.

### P1T2-CMD-2 — Pester runtime/configuration capability probe

```powershell
Import-Module Pester -MinimumVersion 5.0 -Force; $config = New-PesterConfiguration; [ordered]@{ pester_version = (Get-Module Pester).Version.ToString(); invoke_pester_command_type = (Get-Command Invoke-Pester).CommandType.ToString(); invoke_pester_source = (Get-Command Invoke-Pester).Source; code_coverage_properties = @($config.CodeCoverage.PSObject.Properties.Name | Sort-Object); branch_property_present = @($config.CodeCoverage.PSObject.Properties.Name -contains 'Branch') } | ConvertTo-Json -Compress
```

Observed Pester version: `5.6.1`. `Invoke-Pester` is a `Function` from module `Pester`. `CodeCoverage` exposes `CoveragePercentTarget`, `Enabled`, `ExcludeTests`, `OutputEncoding`, `OutputFormat`, `OutputPath`, `Path`, `RecursePaths`, `SingleHitBreakpoints`, and `UseBreakpoints`; it exposes no branch property. Output SHA-256: `08C7037D680216700F0453458FCC87B0C78764BB07AC586017350EF5DF3A730D`.

### P1T2-CMD-3 — fresh coverage XML parse

```powershell
[xml]$coverage = Get-Content -LiteralPath artifacts/pester/powershell-coverage.xml -Raw; enumerate package, class, line, condition, and counter nodes; group counters by type; report root covered/missed values; count BRANCH counters, branch=true lines, positive mb/cb denominators, and condition nodes; serialize compressed JSON and compute SHA-256 over its UTF-8 bytes.
```

Observed: 8 packages, 52 classes, and 4,260 source line elements. Counter types are `CLASS`, `INSTRUCTION`, `LINE`, and `METHOD`. Root counters are instruction `5489/325`, line `4040/220`, method `336/27`, and class `50/2`. There are zero `BRANCH` counter nodes, zero `branch=true` lines, zero positive `mb+cb` denominators, and zero condition nodes. Output SHA-256: `FE5E9E32B1CC8A55DD31E693516C5E30C257AE6BC0A8F7608E87E74F8EDFC5D8`.

### P1T2-CMD-4 — fresh JUnit outcome parse

```powershell
[xml]$junit = Get-Content -LiteralPath artifacts/pester/pester-junit.xml -Raw; read tests/failures/errors/disabled from the root suite; select existing PoshQC coverage, pruning, seam, and summary scenarios; record their pass/fail outcome and whether any testcase carries a source branch identity or denominator; serialize compressed JSON and compute SHA-256 over its UTF-8 bytes.
```

Observed: 2,456 tests, 0 failures, 0 errors, and 9 disabled. The relevant coverage-enabled, Koverage-copy, pruning-all, pruning-mixed, pruning-none, rooted-path, default-seam, and coverage-report-replay scenarios passed. These are named behavioral outcomes only; no testcase supplies a source branch identity or complete branch denominator. Output SHA-256: `EBB9564938B810D0863A2B4935E0D5A3C131334E52E08178A3F518CE55108D65`.

### P1T2-CMD-5 — in-memory converter probe

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.Testing.psm1 -Force; read artifacts/pester/powershell-coverage.xml into memory; invoke Convert-PoshQCCoverageToRelative with injected TestPathExists, Logger, and SetContent seams so the transformed text remains in memory; compare counter multisets and absolute package/class identities before and after; count BRANCH counters and denominators; serialize compressed JSON and compute SHA-256 over its UTF-8 bytes.
```

Input SHA-256: `B750B029C0C0530062C4408133A6791286BED4D7E647767A5AF7F4E46A8ECE93`. Transformed-text SHA-256: `AD7DEE6A090A276B465E44388BD0A866C99BF13E97CBD179523907236E191433`. The counter multiset was preserved, 8 absolute package names and 52 absolute class names became relative, and the branch counter/denominator remained zero. Probe JSON SHA-256: `E585F517887A0301989EFFC113552CE7D6652CB8A5150587F7A19274F75515AE`.

### P1T2-CMD-6 — converter wrapper `WhatIf` probe

```powershell
& ./scripts/powershell/PoshQC/convert-poshqc-coverage.ps1 -CoveragePath artifacts/pester/powershell-coverage.xml -RepoRoot (Get-Location).Path -OutputPath artifacts/pester/powershell-coverage.branch-probe.xml -WhatIf
```

PowerShell reported the proposed `Convert coverage paths to relative paths` operation. Pipeline output was empty, with SHA-256 `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855`. `artifacts/pester/powershell-coverage.branch-probe.xml` does not exist.

### P1T2-CMD-7 — AST/source and report-correlation probe

```powershell
$sourcePath = 'scripts/powershell/PoshQC/PoshQC.Testing.psm1'; $sourceText = Get-Content -LiteralPath $sourcePath -Raw; $tokens = $null; $parseErrors = $null; $ast = [System.Management.Automation.Language.Parser]::ParseInput($sourceText,$sourcePath,[ref]$tokens,[ref]$parseErrors); collect IfStatementAst, SwitchStatementAst, LoopStatementAst, CommandAst, and Invoke-PoshQCSuite body command names; parse artifacts/pester/powershell-coverage.xml; select sourcefile name PoshQC.Testing.psm1; count source lines, hit/miss instruction attributes, branch=true lines, positive mb+cb denominators, and BRANCH counters; serialize compressed JSON and compute SHA-256 over its UTF-8 bytes.
```

Observed: 0 parse errors; `Invoke-PoshQCSuite` calls `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, and `Invoke-PoshQCTest`; 64 `IfStatementAst`, 0 switches, 5 loops, and 98 command AST nodes exist. The report has 202 line elements for this source, all with hits; four also contain missed instructions. All 202 line elements carry zero-valued `mb`/`cb` attributes, zero have a positive `mb+cb` denominator, zero have `branch=true`, and the report has zero `BRANCH` counters. Output SHA-256: `3F406701F3E98CB34CBDB279D080C9D6EBC7E8158781144696C8EFE37968E87E`.

## Candidate results

The `Taken/not-taken observation` column distinguishes a behavioral scenario result from genuine source branch outcomes. Numeric coverage fields remain zero unless the output explicitly identifies source-attributable control-flow edges.

| ID | Probe | Observed taken/not-taken result | Output SHA-256 | Covered | Missed | Denominator | Disposition |
|---|---|---|---|---:|---:|---:|---|
| C1 | Existing `Invoke-PoshQCTest` | Existing path enabled coverage; missing path disabled coverage. No returned branch records. | `75958AE8E50ED6A9342857E2FD01C505359F7C32EFDD70B8B5F1CCF489D45564` | 0 | 0 | 0 | Behavioral side effects only. |
| C2 | Default `Invoke-Pester` seam | Fresh run completed 2,447 passed and 9 disabled, but emitted command/line rather than branch outcomes. | `EBB9564938B810D0863A2B4935E0D5A3C131334E52E08178A3F518CE55108D65` | 0 | 0 | 0 | No branch-result contract. |
| C3 | Injected `InvokePester` seam | Two injected scenarios returned pass results and captured distinct configurations; the double emitted no source branch records. | `75958AE8E50ED6A9342857E2FD01C505359F7C32EFDD70B8B5F1CCF489D45564` | 0 | 0 | 0 | Test-double outcome is not production branch evidence. |
| C4 | `New-PesterConfiguration` / CodeCoverage | Coverage can be enabled and paths selected; branch property is absent. | `08C7037D680216700F0453458FCC87B0C78764BB07AC586017350EF5DF3A730D` | 0 | 0 | 0 | Configuration only. |
| C5 | `CoverageGutters` output | Report contains line/instruction/method/class counters and no branch counter or positive branch line. | `FE5E9E32B1CC8A55DD31E693516C5E30C257AE6BC0A8F7608E87E74F8EDFC5D8` | 0 | 0 | 0 | No genuine branch output. |
| C6 | Pester test outcomes | Relevant authored scenarios passed; testcase identities do not identify source edges or enumerate a denominator. | `EBB9564938B810D0863A2B4935E0D5A3C131334E52E08178A3F518CE55108D65` | 0 | 0 | 0 | Test outcomes are rejected proxies. |
| C7 | Injectable path/logger/copy seams | Existing/missing inputs select keep/disable and log/copy behaviors; no source edge record is emitted. | `75958AE8E50ED6A9342857E2FD01C505359F7C32EFDD70B8B5F1CCF489D45564` | 0 | 0 | 0 | Scenario assertions do not enumerate source branches. |
| C8 | `Convert-PoshQCCoverageToRelative` | Absolute and relative serialization outcomes differ; the counter multiset is unchanged and remains branch-free. | `E585F517887A0301989EFFC113552CE7D6652CB8A5150587F7A19274F75515AE` | 0 | 0 | 0 | Path transformation only. |
| C9 | Converter wrapper | `WhatIf` reports the proposed operation and creates no file. | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` | 0 | 0 | 0 | Wrapper adds no coverage semantics. |
| C10 | `Invoke-PoshQCSuite` | AST confirms ordered format/analyze/test delegation with no additional collector. | `3F406701F3E98CB34CBDB279D080C9D6EBC7E8158781144696C8EFE37968E87E` | 0 | 0 | 0 | Orchestration only. |
| C11 | `CoverageReport` replay | Existing replay scenario passes and stops at `Missed commands`; output text has no source edge records. | `EBB9564938B810D0863A2B4935E0D5A3C131334E52E08178A3F518CE55108D65` | 0 | 0 | 0 | Presentation string is a rejected proxy. |
| C12 | AST/source extents and breakpoints | Static probe finds 64 conditional nodes; coverage contains zero positive branch denominators. | `3F406701F3E98CB34CBDB279D080C9D6EBC7E8158781144696C8EFE37968E87E` | 0 | 0 | 0 | AST/position correlation is a rejected proxy. |

## Input identity and no-mutation verification

| Path | SHA-256 before and after |
|---|---|
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` |
| `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` | `D2EBD92B2A0C071A364486AF5E38071723AEFEA6489147DC8C15D7D100B6379F` |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `0AFFEBB7A08F407E562BEFEAA2CD7AD56CB2C3816489BC1D64CD0366950FC81D` |
| `scripts/powershell/PoshQC/PoshQC.psd1` | `B19E3BC37782F4634197529BE29DA32E2D9D22178713464D52FE8957D9876812` |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` | `AD167E1218BE92637F750F73EFA26BE4B8A4ED94C79DDECE9F298E7F8E05DFB8` |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` | `8202A5BD80305FB6E649B2CE874B4483687CE88AE19AFDEDBF0AD6B16186497C` |

- Seven inspected-input tracked diff count: `0`.
- Tracked PowerShell path count: `391` before and after.
- Tracked PowerShell aggregate SHA-256: `564F23B55BCB6917F9B71D3FC016F0F42A549783C26F52706EFD5AD81EB970EF` before and after.
- Fresh JUnit SHA-256: `119D402F428CE6CBFDF3A4E6653BEBBFF29BA6D1346CC93A5EA38E62A51980A2` before and after.
- Fresh coverage XML SHA-256: `B750B029C0C0530062C4408133A6791286BED4D7E647767A5AF7F4E46A8ECE93` before and after.
- `artifacts/pester/powershell-coverage.branch-probe.xml` exists: `false`.
- Source, test, configuration, dependency, lockfile, policy, threshold, suppression, and checkpoint mutation by probes: `none`.
- The only `[P1-T2]` write is this required canonical evidence receipt; plan checkbox mutation occurs only after validation.

## Probe conclusion

- Candidate count probed: `12/12`.
- Genuine source-attributable covered branch outcomes: `0`.
- Genuine source-attributable missed branch outcomes: `0`.
- Genuine branch denominator: `0`.
- A numeric branch percentage is not computed because the denominator is zero.
- Qualifying existing branch collector established: `no`.
- Proxy or synthetic metric used: `no`.
