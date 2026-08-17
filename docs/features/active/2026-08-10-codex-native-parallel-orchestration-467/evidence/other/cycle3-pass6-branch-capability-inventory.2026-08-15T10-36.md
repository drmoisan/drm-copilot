# Cycle 3 Pass 6 Branch Capability Inventory

Timestamp: 2026-08-15T11:55:25-04:00
Command: Parse and inspect the seven [P1-T1] PowerShell runtime, configuration, conversion, and test files without editing them.
EXIT_CODE: 0
Output Summary: The existing surface can run Pester, observe test-case outcomes, and collect source-attributed command/line hits. It contains no callable collector that emits genuine source-attributable taken/not-taken branch outcomes or a positive branch denominator.

## Inspected files

| Path | Lines | SHA-256 | Parse errors |
|---|---:|---|---:|
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` | 0 |
| `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` | 463 | `6BAC92862E0464E9319D5D3629D0B55F671102F3E52BFE45B3CFAC3FF09FC280` | 0 |
| `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1` | 35 | `D2EBD92B2A0C071A364486AF5E38071723AEFEA6489147DC8C15D7D100B6379F` | 0 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 190 | `0AFFEBB7A08F407E562BEFEAA2CD7AD56CB2C3816489BC1D64CD0366950FC81D` | 0 |
| `scripts/powershell/PoshQC/PoshQC.psd1` | 27 | `B19E3BC37782F4634197529BE29DA32E2D9D22178713464D52FE8957D9876812` | 0 |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1` | 259 | `AD167E1218BE92637F750F73EFA26BE4B8A4ED94C79DDECE9F298E7F8E05DFB8` | 0 |
| `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` | 579 | `8202A5BD80305FB6E649B2CE874B4483687CE88AE19AFDEDBF0AD6B16186497C` | 0 |

The root and shipped `PoshQC.Testing.psm1` files are byte-identical. Their capabilities are therefore one implementation surface, not two independent collectors.

## Existing callable capability inventory

| ID | Callable surface | Observable runtime result | Source attribution | Genuine taken/not-taken outcomes | Disposition |
|---|---|---|---|---|---|
| C1 | Exported `Invoke-PoshQCTest` | Invokes Pester, returns its execution result internally, replays test counts, and consumes `CodeCoverage.CoverageReport` | Pester command/line records carry file and position data | No | Probe as the primary existing runtime coverage entry point; current code exposes no branch-result contract. |
| C2 | Default `$InvokePester` seam: `Invoke-Pester -Configuration $Config` | Pester test cases plus instrumented command execution/miss data | File, function, line, and command/extent positions | No | Runtime observation exists, but Pester command coverage is not branch coverage. |
| C3 | Injected `$InvokePester` seam in `Invoke-PoshQCTest` | Tests can capture configuration and provide a result object | Only whatever an injected test double supplies | No | Synthetic/test-double results cannot establish observed production branch outcomes. |
| C4 | `New-PesterConfiguration -Hashtable` plus `CodeCoverage` settings | Enables coverage, selects paths, format, and output destination | Selected source paths only | No | Configuration capability; it does not collect outcomes. |
| C5 | `CoverageGutters` output | JaCoCo-style `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters | Package/class/source filename and line ownership | No | The fresh report contains zero `BRANCH` counters at all scopes. |
| C6 | Pester `Describe`/`Context`/`It` plus `Should` assertions | Distinct authored test scenarios can pass or fail | Test identity, not a source branch identity | No | Behavioral evidence is valid for a named scenario but cannot produce a complete branch denominator. |
| C7 | Injectable `TestPathExists`, `Logger`, `CopyCoverage`, and captured configuration seams in pruning tests | Tests distinguish pruning, keep, disable, copy, and logging decisions | The tested function and configured paths are known | No | Manually asserted side effects identify selected scenarios only; they do not enumerate both outcomes for every source branch. |
| C8 | `Convert-PoshQCCoverageToRelative` | Rewrites absolute XML path prefixes to relative paths | Preserves existing source identities | No | Serialization/path transformation only; it neither observes runtime control flow nor adds counters. |
| C9 | `convert-poshqc-coverage.ps1` | Calls C8 under `ShouldProcess` | Preserves the input report's attribution | No | Wrapper only; no runtime-outcome collector. |
| C10 | `Invoke-PoshQCSuite` | Orders format, analyze, and Pester execution | Delegates to the invoked operations | No | Orchestration only; adds no coverage semantics. |
| C11 | `CodeCoverage.CoverageReport` string replay | Prints a textual coverage summary until `Missed commands` | Summary text may name command/line coverage | No | Presentation only; the tests' injected `Coverage: 100%` strings are synthetic fixtures. |
| C12 | PowerShell AST/source extents underlying Pester coverage breakpoints | Static command locations can be correlated with execution hits | File, line, column, function, AST/extent | No | Static positions plus hit counts do not state a branch outcome or complete branch denominator. |

## Explicit proxy rejections

| Proposed proxy | Rejection |
|---|---|
| Command hits or executed/missed command counts | A command point can execute without identifying which conditional edge was taken. Multiple commands can belong to one outcome, and an empty arm can have no command point. |
| Line hits or report-level `LINE` counters | A line can contain multiple decisions or both outcomes, and separate branch arms can share a line. Line coverage has no branch identity or taken/not-taken pair. |
| `INSTRUCTION`, `METHOD`, or `CLASS` counters | These are coverage aggregation units, not control-flow edges. |
| AST nodes or AST positions | AST data is static syntax. It does not record runtime selection of an edge. |
| Source positions, extents, line/column pairs, or function names | Positions identify code locations only. They do not record distinct runtime outcomes. |
| Correlation of source/AST positions with command hits | Correlation infers an outcome from proxy data and cannot prove complete edge enumeration, duplicate rejection, or empty-arm behavior. |
| Test pass/fail, logs, captured configuration, or output strings | These can prove a specific behavioral scenario but do not enumerate all source branches or produce a repository branch denominator. |
| Adding or relabeling JaCoCo `BRANCH` counters during conversion | A serializer cannot convert command/line hits into genuine observed control-flow outcomes. Such counters would be synthetic and are prohibited. |

## Inspection result

- Existing callable candidates requiring deterministic probes: C1 through C12.
- Existing qualifying source-attributable branch collector established by inspection: `none`.
- Command, line, AST-position, source-position, correlation, test-result, log, and synthetic-counter proxies: rejected.
- Next required step: run read-only deterministic probes under [P1-T2]; inspection alone does not decide [P1-T3].
