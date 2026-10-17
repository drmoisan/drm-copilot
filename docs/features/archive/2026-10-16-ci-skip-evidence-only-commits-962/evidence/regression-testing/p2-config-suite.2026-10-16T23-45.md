# Config suite pass (P2-T2, AC-15)

Timestamp: 2026-10-16T23-45
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1" -NamePatternList "*(AC-15)*"
EXIT_CODE: 0
Output Summary: config/ci-docs-only-paths.json written with the section 9 content. NAMED: *(AC-15)* | Passed=23 | Failed=0 | Total=23; TOTAL Failed=0; EXIT_CODE_COMPUTED: 0. CI job: poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | Result=Passed
SUITE: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | Passed=23 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-15)* | Passed=23 | Failed=0 | Total=23
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | parses the committed allowlist with version 1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | starts every include prefix with docs/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not let any include prefix cover docs/features/templates/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not let any include prefix cover docs/engineering/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not let any include prefix cover docs/discovery/ (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | lists docs/features/templates/ as an exclude prefix (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | lists docs/features/potential/template.md as an exclude prefix (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .py (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .ps1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .psm1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .psd1 (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .sh (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .bats (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .ts (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .tsx (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .js (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .mjs (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .cjs (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .cs (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .yml (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .yaml (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | does not configure the code extension .toml (AC-15)
ROW: Passed | tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | configures exactly the D3 include prefixes and extensions (AC-15)
TOTAL: Passed=23 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
