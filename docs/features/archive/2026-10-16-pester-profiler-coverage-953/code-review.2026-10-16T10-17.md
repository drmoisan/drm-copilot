# Code Review: pester-profiler-coverage (Issue #953)

- Timestamp: 2026-10-16T10-17
- Reviewer: feature-review agent (full feature-vs-base review, pre-PR)
- Branch: `bug/pester-profiler-coverage-953`, HEAD `0087d2bc2514721a0a89b1032010e95afb6c21ec`
- Base: `origin/main` @ `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`; diff `git diff 5bdf22d0f...HEAD`
- Companion artifacts: `policy-audit.2026-10-16T10-17.md`, `feature-audit.2026-10-16T10-17.md`

## Executive Summary

The change is small and matches the spec design. The speedup is a single configuration key (`CodeCoverage.UseBreakpoints = $false`) in both runsettings copies, so every local runner and CI inherit it without code changes, and rollback is a one-line removal per copy. The Pester minimum is reconciled to 5.9.0 at all listed sites, and the D8 ceiling uses an exclusive `UpperBound = '6.0.0'` where installed versions are filtered and `-MaximumVersion 5.99.99` where `Import-Module` is called, which is the correct split because `Import-Module` has only an inclusive maximum.

The tests are well targeted: seven regression cases that failed 7 of 7 before the fix and pass after, plus five coverage cases that raised `PoshQC.psm1` from 66.67% to 88.33% line coverage. All installer seams are injected, so no test installs a module, touches the network, or writes a file. The D9 split of `PoshQC.Tests.ps1` is a verbatim move (reviewer `diff` exit 0). Repository and bundle copies are byte-identical.

No Blocking code finding. Non-blocking: 3 Minor (CR-1 to CR-3) and 3 Info (CR-4 to CR-6).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (and bundle copy) | default `EnsureModule` seam, lines 163-170 | CR-1: the presence check `Get-Module -ListAvailable -Name $Name` ignores the new ceiling. When only Pester 6.x is installed, the check passes and `Import-Module -MaximumVersion 5.99.99` then fails with the generic "no valid module file was found" error instead of the seam's actionable message ("Run Install-PoshQCTool ..."). | Follow-up: filter the presence check to versions `< 6.0.0` (or catch the import failure and throw `$ErrorMessage`), and add a test for the Pester-6-only case. | Same failure outcome, weaker diagnostics; the D8 scenario (a runner image that ships Pester 6) is exactly when the message matters. | `PoshQC.Testing.psm1:164-169` |
| Minor | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (and bundle copy) | default `EnsureModule` seam, line 169 | CR-2: the import sets only a maximum. On a host where Pester 5.x is absent but the inbox Pester 3.4.0 is present (stock Windows), the import loads 3.4.0 and the run fails later in `New-PesterConfiguration`. This behavior predates the branch (the base import had no version bound), but the seam now carries an explicit version range on one side only. | Follow-up: pass `-MinimumVersion 5.9.0` together with `-MaximumVersion 5.99.99`, matching the Linux workflow line and the installer floor. | Aligns the three import/installer sites on one range and fails at import with a version error. | `.github/workflows/_poshqc.yml:73` uses both bounds |
| Minor | `scripts/powershell/PoshQC/PoshQC.psm1` (and bundle copy) | lines 62 and 75 | CR-3: the version predicate `$_.Version -ge [version]$module.Version -and (-not $module.ContainsKey('UpperBound') -or $_.Version -lt [version]$module.UpperBound)` is written twice (present check and post-install check). The two shell scripts carry a third and fourth copy. | Follow-up: assign the predicate to one scriptblock in `Install-PoshQCTool` and use it in both `Where-Object` calls. | Reusability policy; a future range change must otherwise be applied in two places per file. Both copies are currently identical and covered (`ci=5`). | `PoshQC.psm1:62`, `PoshQC.psm1:75` |
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | lines 53-64, 204, 213, 251-255 | CR-4: under profiler mode 13 lines that were covered under breakpoint mode are reported as missed (default seam scriptblock bodies and a `Where-Object` filter). File coverage remains 93.50% and no changed line regressed. | None required in this item; AC-09 records the per-file shift from the CI artifacts. If later per-file gates depend on these lines, investigate profiler attribution of scriptblocks defined in parameter defaults. | This is the attribution shift the spec risk table anticipates. | `artifacts/pester/powershell-coverage.xml` (reviewer `grep`) |
| Info | `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` | RS07, lines 145-162 | CR-5: the workflow is parsed by indentation (`^  <job-id>:`) rather than as YAML. The test is correct for the current file and fails closed (`Count | Should -Be 1`) if the job layout changes. | None required. | A YAML parser dependency is not justified for one line check. | RS07 passed; fail-before message shows it read the `5.6.1` line |
| Info | `tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1` | MC05, lines 76-102 | CR-6: MC05 sets the process-wide AppDomain slot `PoshQC.ParsedSubModuleScriptBlocks` to `$null`. `AfterEach` restores the saved value and re-imports the module, so later tests see the original state. | None required; keep the restore in `AfterEach` if the test is edited. | Global state mutation is contained and restored. | full-suite run 10388 passed, 0 failed |

## Detailed Notes

### Configuration change

- Both `pester.runsettings.psd1` copies add `UseBreakpoints = $false` after `CoveragePercentTarget = 0` with a comment citing #953. `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget` are unchanged (RS01 asserts all four).
- A caller that supplies `-SettingsPath` keeps control of the mode; README documents the breakpoint-mode opt-out.

### Version range

- `Install-PoshQCTool`: the `UpperBound` key is optional (`ContainsKey`), so the PSScriptAnalyzer entry keeps floor-only semantics. RS05 covers the Pester-6-only case; MC04 covers the post-install failure path.
- Shell present-checks in `.devcontainer/post-create.sh` and `.github/codex/codex-web-setup.sh` use the same predicate with the quoting style of each file. shfmt and shellcheck outputs are unchanged relative to baseline.
- `scripts/host-tools.manifest.json` carries no ceiling, consistent with D8 (HostBootstrap installs the exact `minimumVersion`). `HostVerification.psm1` still accepts Pester 6.x; the spec lists this as a residual non-goal.

### API compatibility

- `EnsureModule` gains a third parameter `[string] $MaximumVersion`. A caller-supplied scriptblock that declares only two parameters receives the third argument in `$args` and is not broken. Existing tests that inject `EnsureModule` continue to pass.

### Test split (D9)

- `PoshQC.TestingCommands.Tests.ps1` lines 7-295 equal base `PoshQC.Tests.ps1` lines 291-579; lines 1-6 repeat the original header. The JUnit total (10388) is unchanged by the split.

## Verdict

No Blocking code finding. Non-blocking: 3 Minor (CR-1, CR-2, CR-3) and 3 Info (CR-4, CR-5, CR-6).
