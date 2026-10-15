# Code Review — Issue #847 (PowerShell aggregate line coverage below floor)

- Timestamp: 2026-10-10T01-41
- Branch: `bug/powershell-aggregate-line-coverage-below-floor-847`
- Base: `main`; merge-base `460cd755de560b733be0c471d1d144e553fbe0e5`
- Head reviewed: `d2224baa86700fe445c87008228bd3efe56dd6f8`
- Scope: all PowerShell production and test files in the full branch diff (19 changed `.ps1`/`.psm1`, 1 deleted)

## Total Blocking Findings: 0

## Executive Summary

The branch extracts the logic of three host-bound entry scripts into five modules under `scripts/dev-tools/`, reduces the entry scripts to wiring, deletes `bootstrap-host.helpers.ps1`, and adds 11 Pester suites (182 test cases in the changed suites). The extraction is faithful at the level of control flow, messages, parameters, and exit codes. The deviations found are non-functional (output timing, preference-variable propagation, module persistence in the caller session) or documentation drift. No defect was found that changes a documented outcome.

## Behavior Parity Review (base vs head)

Method: `git show 460cd755:<path>` for `bootstrap-host.ps1`, `bootstrap-host.helpers.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`, compared function-by-function with the head modules and entry scripts.

### bootstrap-host.ps1 -> HostBootstrap.psm1 + HostBootstrapWorkspace.psm1 + HostTooling.psm1

| Behavior | Base | Head | Parity |
|---|---|---|---|
| `param` block | lines 2-18 | lines 2-18, identical | Equal |
| Banner, dry-run "- Would ..." lines, apply lines, final lines | `Invoke-BootstrapHost` lines 335-479 | `HostBootstrap.psm1:330-460`, same strings and order | Equal |
| Non-Windows / missing winget | `Write-Error ...; exit 1` under script-scope EAP Stop: `Write-Error` is terminating, so `exit 1` was unreachable; `pwsh -File` exit code 1 from the uncaught error | `Write-Error -ErrorAction Stop` in module; entry `catch` sets `$global:LASTEXITCODE = 1` and rethrows; `pwsh -File` exit code 1 | Equal (same message, same exit code) |
| Manifest missing | `Get-HostManifest` throws `Host tools manifest not found at <dev-tools>\..\host-tools.manifest.json` | `Get-HostToolsManifestPath` returns the same unnormalized path; `Get-HostManifest` throws the same message | Equal |
| Resume argument string | inline build, lines 360-373 | pure `Get-BootstrapResumeArgument`, same composition and join | Equal |
| RunOnce set only with `-Apply -EnableAutoResumeAfterReboot`; cleared after apply | lines 359, 470-473 | lines 352, 451-454 | Equal |
| RunOnce command path | `$PSScriptRoot` of the script (`scripts/dev-tools/bootstrap-host.ps1`) | `$PSScriptRoot` of the module (same directory) | Equal |
| Poetry winget failure -> pip fallback; other package rethrows | lines 80-88 | lines 77-85 | Equal |
| User PATH de-dup (case, trailing `\`) | `[Environment]` calls | `Get/Set-HostEnvironmentVariable` seams, same comparison | Equal |
| Session PATH refresh | `$env:Path = ...` | `Set-HostEnvironmentVariable -Target Process` | Equal |
| `Install-Module` | direct call | `Install-HostPowerShellModule` wrapper, same arguments | Equal |
| Poetry project install failure -> warning | try/catch/finally with Push/Pop-Location | same | Equal |
| verify-host invoked by sibling path, exit code ignored | `Invoke-VerifyHostScript` -> `& $ScriptPath` | `Invoke-HostBootstrapVerifyScript` -> `& $ScriptPath` | Equal |
| `Resolve-ProjectRepoRoot` default root | helper file `$PSScriptRoot\..\..` | module `$PSScriptRoot\..\..` (same directory) | Equal |
| Process exit code on success | no `exit`; `pwsh -File` returns 0 on normal termination | explicit `exit 0` | Equal |
| Native output (winget, wsl, npm, git, pip, poetry) | streamed live to the host | captured by `Invoke-HostNativeCommand`, emitted after process exit | Different (timing only; see CR-N1) |

### verify-host.ps1 -> HostVerification.psm1 + HostTooling.psm1

| Behavior | Base | Head | Parity |
|---|---|---|---|
| `param()` | empty | empty, identical | Equal |
| Missing manifest | `Write-Error "Manifest not found at <path>"` (terminating under EAP Stop); exit 1 | `Write-Error -ErrorAction Stop` in module; entry sets exit 1 and rethrows | Equal |
| Section headings, line text, order | five sections, lines 192-325 | `Invoke-HostVerification` builds the same lines in the same order via an ordered dictionary | Equal |
| Poetry-unavailable in quality-tools section counts one failure | `$failureCount++` | `FailureCount = 1` | Equal |
| Exit code | `exit 0` iff failure count 0, else `exit 1` | `ExitCode` 0/1, entry `exit $result.ExitCode` | Equal |
| `Get-CommandVersion`, `Get-PoetryVersionInfo` parsing | inline regex | `ConvertTo-HostToolVersion`, same regex and `[version]` cast fallback | Equal |
| `Invoke-PoetryCommand` result | returned raw output; caller read `$LASTEXITCODE` | returns `{ Output; ExitCode }` with merged stderr | Equal outcome; first-line text may differ if a tool writes to stderr first (see CR-N7) |
| Output timing | progressive | after completion | Different (accepted in spec "Performance") |

### publish-sideloaded-extension.ps1 -> SideloadedExtensionPublish.psm1

| Behavior | Base | Head | Parity |
|---|---|---|---|
| `param` block incl. `CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")` and both default expressions | lines 23-51 | lines 23-51, identical | Equal |
| Step order npm ci -> compile -> vsce package -> install, each ShouldProcess-gated and Skip-gated | lines 357-395 | lines 409-445 | Equal |
| EPERM retry up to 3 attempts, backoff `DelaySeconds * attempt`, non-EPERM rethrow | `Start-Sleep` | injected `-Sleep` scriptblock defaulting to `Start-Sleep` | Equal |
| `-Force` cleanup path (stop node, remove `node_modules`, `npm cache clean --force`) | nested `Stop-NodeProcess` | top-level non-exported `Stop-NodeProcess` | Equal |
| VSIX missing throws; final pipeline output is VSIX path | lines 373-375, 403 | lines 425-427, 453 | Equal |
| `CodeCommand` bound-empty vs unbound | `$PSBoundParameters.ContainsKey('CodeCommand')` in script | entry forwards the key only when bound; module checks `ContainsKey` | Equal |
| `-WhatIf` / `-Confirm` | script-scope `$WhatIfPreference` / `$ConfirmPreference` | forwarded when bound | Equal for explicit switches; see CR-N2 for inherited preferences |
| VSIX timestamp | `Get-Date -Format` | `Get-Date -Date (& $Now) -Format` | Equal |

## Test Design Review

| Rule | Verdict | Evidence |
|---|---|---|
| No temporary files | PASS | No `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `$env:TEMP`, `$env:TMP`, `Set-Content`, `Out-File` in the 11 files. |
| Fail-closed mocks | PASS | Each suite's `BeforeAll` installs throwing default mocks for every reachable host seam (75 occurrences); individual tests override with explicit fixtures. |
| No `Import-ScriptFunction` | PASS | No occurrence in the 11 files; `publish-sideloaded-extension.Tests.ps1` rewritten as an entry test and retains `Describe "scaffold extension package identity"`. |
| Import through `Resolve-Path`, `Remove-Module` in `AfterAll` | PASS | All 11 suites. |
| Entry scripts invoked with `&` per exit path with `$LASTEXITCODE` sentinel 99 | PASS | `bootstrap-host.Tests.ps1`, `verify-host.Tests.ps1`, `publish-sideloaded-extension.Tests.ps1`. |
| Arrange-Act-Assert, descriptive names | PASS | AC-tagged test names (for example `AC06-EPERM-BACKOFF`) map directly to spec criteria. |
| Host-OS independence | PASS | `-IsWindowsHost` is passed explicitly; verify fixture omits `bashdb`/`copilot`; bootstrap entry tests mock the orchestrator to avoid the `$IsWindows` default. |

## Module Gotchas (spec "Module gotchas")

| Gotcha | Verdict | Evidence |
|---|---|---|
| Module-scope StrictMode and EAP Stop | PASS | Lines 12-15 of each of the 5 modules. |
| No `-Force` on entry-script `Import-Module` | PASS | Grep `Import-Module.*-Force` over the three entry scripts: no match. |
| No `exit` in modules | PASS | Grep `^\s*exit\b` over the 5 modules: no match; `exit` appears only in `verify-host.ps1:19` and `bootstrap-host.ps1:34`. |

## Findings Table

Blocking findings: 0. Non-blocking findings: 7 (CR-N1..CR-N7).

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (CR-N1) | `scripts/dev-tools/HostTooling.psm1` | lines 124-129; callers `HostBootstrapWorkspace.psm1` (winget, npm, wsl, git, poetry wrappers), `HostBootstrap.psm1:144` (pip) | `Invoke-HostNativeCommand` assigns native output to a variable, so bootstrap's long-running installs no longer stream progress; output appears after each process exits, and tools that detect redirected stdout may suppress progress bars. Content, order, and exit codes are unchanged. The spec accepts an output-timing change only for `verify-host.ps1`, so this is an undocumented deviation from DR-1. | Record it as an accepted non-functional change in the PR description, or stream through the pipeline (for example `& $FilePath @ArgumentList \| ForEach-Object { $_ }`, reading the exit code afterward) in a follow-up. | No outcome changes; operator experience during multi-minute installs changes. | Base `bootstrap-host.ps1:98`, `:111`, `:121`, `:226`, helpers `:11` invoked natives directly in the output pipeline. |
| Non-blocking (CR-N2) | `scripts/dev-tools/publish-sideloaded-extension.ps1` | lines 58-83 | Only explicitly bound `-WhatIf`, `-Confirm`, `-Verbose`, `-WarningAction` are forwarded. In the base script a caller-scope `$WhatIfPreference`/`$ConfirmPreference`/`$VerbosePreference` flowed into every function by dynamic scope; module functions resolve preferences through module and global scope, so an inherited `$WhatIfPreference = $true` (for example a parent script run with `-WhatIf` that calls this script without `-WhatIf`) no longer suppresses the steps. `-Debug`, `-InformationAction`, `-ErrorAction` are not forwarded. | In a follow-up, forward effective values (`WhatIf = $WhatIfPreference`, `Confirm` from `$ConfirmPreference`, `Verbose` from `$VerbosePreference`). | Implementation matches the spec wording ("forwards `-WhatIf`/`-Confirm` by splatting"); the only in-repo caller (`.vscode/tasks.json`) uses `pwsh -File` with explicit arguments. | Base publish script lines 349-394 used script-scope `$PSCmdlet.ShouldProcess`. |
| Non-blocking (CR-N3) | entry scripts | `bootstrap-host.ps1:23`, `verify-host.ps1:8`, `publish-sideloaded-extension.ps1:56` | Entry scripts import modules into the session, so exported functions remain loaded after an interactive run, and a previously loaded (possibly stale) module is reused because `-Force` is omitted. The base dot-sourced functions into a script scope discarded on exit. | Accept as a consequence of spec gotcha 2, or note it in script help. | Behavioral side effect only in interactive sessions. | Spec "Module gotchas" item 2. |
| Non-blocking (CR-N4) | `scripts/dev-tools/HostTooling.psm1` | lines 131-134 | `Invoke-HostNativeCommand` reads global `$LASTEXITCODE`, which is not reset when `FilePath` resolves to a cmdlet, function, or script that does not set it; a stale non-zero value would be reported. | Reset `$global:LASTEXITCODE = 0` before invoking, or document the seam as native-only. | Latent: all production callers pass native executables or `Get-Command` `.Source` paths. | `HostBootstrapWorkspace.psm1:30,202,220,235,269,283`; `HostBootstrap.psm1:144`; `HostVerification.psm1:46,77,82`. |
| Non-blocking (CR-N5) | `docs/.../spec.md` | line 66 vs `HostVerification.psm1:134-289` | Spec design table uses plural section-function names (`Test-HostCoreVersions`, ...); plan and implementation use singular nouns. | Optionally align the spec table; no code change. | Internal API; singular nouns satisfy `PSUseSingularNouns`. | `plan.2026-10-08T23-43.md:117`. |
| Non-blocking (CR-N6) | `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` | lines 51-62 | The `-WhatIf` entry test runs the real orchestrator with default `-Now { Get-Date }`, reading the wall clock for the VSIX file name. | Accept. | Assertion uses a wildcard, so the result is deterministic; the entry script exposes no clock parameter. | `SideloadedExtensionPublish.psm1:383,406`. |
| Non-blocking (CR-N7) | `scripts/dev-tools/HostVerification.psm1` | lines 77-82, 310-314 | `Invoke-PoetryCommand` always merges stderr; if a tool writes a warning to stderr before its version line, the displayed first line could differ from base. | Accept. | Pass/fail is exit-code driven and unchanged. | Base `verify-host.ps1:304-306`. |

## Positive Observations

- Seams are narrow and named, and every test suite installs throwing defaults, so an unmocked host call fails the test rather than touching the host.
- Pure helpers (`ConvertTo-HostToolVersion`, `Get-BootstrapResumeArgument`, `Test-VersionAtLeast`) were extracted and tested at boundary values.
- Entry scripts place one statement per line, so every statement has its own coverage entry (7/7, 7/7, 24/24 lines covered).
- Exit-code semantics are owned by the entry scripts; modules contain no `exit`.
