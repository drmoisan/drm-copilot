# P5-T11 to P5-T13 MCP Route Compliance

Timestamp: 2026-10-02T09-00
Command: mcp__drm-copilot__run_poshqc_format, mcp__drm-copilot__run_poshqc_analyze, mcp__drm-copilot__run_poshqc_test (workspace_root = <ROOT>); git -C <ROOT> status --porcelain --untracked-files=all; git -C <ROOT> hash-object <eleven CHANGED_PS paths> (replaces rule HS, deviation DEV-P5-HS)
EXIT_CODE: 0
Output Summary: route-compliance steps only (D10); no acceptance condition reads a count, percentage, or finding from them. The format call changed no file (the eleven `CHANGED_PS` hashes and the porcelain listing are identical before and after), so no restore and no mirror re-copy was needed. The analyze and test calls changed no tracked file; the final listing after each call equals the P5-T11 final listing and holds only Complete Write Set rows.

## P5-T11 run_poshqc_format

Call: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` `<ROOT>` and `scan_folders` `["scripts/powershell/PoshQC","tests/scripts/powershell/PoshQC","tests/fixtures/poshqc-consumer"]`.

Returned summary (verbatim, root replaced):

```text
{"ok":true,"tool":"run_poshqc_format","workspace_root":"<ROOT>","summary":"Ran bundled PoshQC format against '<ROOT>' with 3 selected scan folder(s)."}
```

Porcelain before (`git status --porcelain --untracked-files=all`):

```text
 M docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md
 M docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md
 M extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1
 M extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1
 M extensions/drm-copilot/resources/powershell/PoshQC/README.md
 M extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
 M tests/scripts/dev_tools/test_poshqc_bundled_parity.py
?? docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/other/manifest-unchanged.2026-10-02T08-50.md
?? docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/other/mirror-copy.2026-10-02T08-50.md
?? docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/regression-testing/parity-after-mirror.2026-10-02T08-55.md
?? extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1
```

Porcelain after: identical to the listing above (same eleven lines).

Hash listing before and after (`git hash-object`; identical in both runs):

| CHANGED_PS path | before | after |
| --- | --- | --- |
| `tests/fixtures/poshqc-consumer/scripts/Sample.psm1` | `b4f0fcefb386ccd345ed3122616bd27cdb2f359e` | `b4f0fcefb386ccd345ed3122616bd27cdb2f359e` |
| `tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1` | `d8b7918f7c82359f92f94cfa0a7f0af8f291348b` | `d8b7918f7c82359f92f94cfa0a7f0af8f291348b` |
| `tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1` | `55d0edee2f5a1dfd6bb3ca00b88121916f3ec540` | `55d0edee2f5a1dfd6bb3ca00b88121916f3ec540` |
| `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` | `1ca9116a255b46d15b57a381aac4cff517415fde` | `1ca9116a255b46d15b57a381aac4cff517415fde` |
| `tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` | `b023c6b4261ed5c198b5d0acec193c8e227fff40` | `b023c6b4261ed5c198b5d0acec193c8e227fff40` |
| `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` | `23cd722f1f40485413c57246269d8816c765bfc1` | `23cd722f1f40485413c57246269d8816c765bfc1` |
| `scripts/powershell/PoshQC/PoshQC.psm1` | `2ce1628f21cc3faa0bd0aa02b95054cf3db09614` | `2ce1628f21cc3faa0bd0aa02b95054cf3db09614` |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | `8a3d6acfc8c1e74145651d53305a5d8178ee0db1` | `8a3d6acfc8c1e74145651d53305a5d8178ee0db1` |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8` | `b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8` |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` | `bda2eefd10b8e835ed89a60e0d8297bc0ff0c712` | `bda2eefd10b8e835ed89a60e0d8297bc0ff0c712` |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | `c27d726cfad3fbb103be9a20d4d85d87deb49389` | `c27d726cfad3fbb103be9a20d4d85d87deb49389` |

Disposition: (a) no tracked path outside the Complete Write Set changed, so nothing was restored from BASE; (b) no `CHANGED_PS` hash changed, so no mirror was re-copied. The installed extension copy executed; this is not acceptance evidence (D10). P6-T1 and the CI `Format PowerShell` step are the format gates.

Final listing (`git status --porcelain --untracked-files=all -- . ':(exclude)docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527'`):

```text
 M docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md
 M extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1
 M extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1
 M extensions/drm-copilot/resources/powershell/PoshQC/README.md
 M extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
 M tests/scripts/dev_tools/test_poshqc_bundled_parity.py
?? extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Coverage.psm1
```

Every listed path is a Complete Write Set row (21, 17, 19, 16, 18, 20, 15).

## P5-T12 run_poshqc_analyze

Call: `mcp__drm-copilot__run_poshqc_analyze` with the P5-T11 `workspace_root` and `scan_folders`.

Returned summary (verbatim, root replaced):

```text
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<ROOT>","summary":"Ran bundled PoshQC analyze against '<ROOT>' with 3 selected scan folder(s)."}
```

Final listing (same feature-folder exclusion): identical to the P5-T11 final listing (same seven lines).

Disposition: the installed extension copy executed and its result is not acceptance evidence (D10). P6-T3 and the CI `Analyze PowerShell` step are the analyzer gates. The analyzer wrote no file.

## P5-T13 run_poshqc_test

Call: `mcp__drm-copilot__run_poshqc_test` with the P5-T11 `workspace_root` and `scan_folders` `["tests/scripts/powershell/PoshQC"]`.

Returned summary (verbatim, root replaced):

```text
{"ok":true,"tool":"run_poshqc_test","workspace_root":"<ROOT>","summary":"Ran bundled PoshQC test against '<ROOT>' with 1 selected scan folder(s)."}
```

Final listing (same feature-folder exclusion): identical to the P5-T11 final listing (same seven lines); the run output under the git-ignored `artifacts/pester/` is not listed.

Disposition: the installed extension copy, which lacks this change, executed the run and its result is not acceptance evidence (D10). P6-T4 and the CI `Test PowerShell` step are the test gates.

Diagnostic observation (not acceptance evidence; recorded for the orchestrator only): every PoshQC test file removes any PoshQC instance not loaded from the repository root and imports `scripts/powershell/PoshQC/PoshQC.psm1` in its `BeforeAll`, so the tests in this run exercised the branch code. The emitted `artifacts/pester/pester-junit.xml` (written 2026-10-02 local 04:18, after the call) reports `tests="148" errors="0" failures="0" disabled="7"` across the twelve files, including `PoshQC.Coverage.Tests.ps1` `tests="13" failures="0"` and `PoshQC.CoverageConfig.Tests.ps1` `tests="17" failures="0"`; the seven non-passing cases are the pre-existing skipped `Install-PoshQCTool` tests. This does not substitute for the CI runs named in the classification.
