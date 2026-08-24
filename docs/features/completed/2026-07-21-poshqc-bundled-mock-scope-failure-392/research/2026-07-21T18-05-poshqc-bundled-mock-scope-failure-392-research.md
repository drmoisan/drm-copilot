# Research: PoshQC bundled-entry Pester mock scope failure (Issue #392)

- **Issue:** #392
- **Date:** 2026-07-21T18-05
- **Researcher:** task-researcher agent
- **Feature folder:** `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/`

## Tooling Constraint Disclosure (read first)

The delegation requested empirical reproduction. This research session had no command-execution
tool (Read/Grep/Glob/WebFetch/Write/Edit only), so no `pwsh` command was run. Nothing in this
document is presented as a confirmed live reproduction. Instead, this document contains:

1. Facts verified by reading exact source, including the installed Pester 5.6.1 module the suite
   actually loads (`C:\Users\DanMoisan\OneDrive\Documents\PowerShell\Modules\Pester\5.6.1\Pester.psm1`),
   with line references.
2. Deductions derived from the failure evidence already captured in `spec.md` (31/1329 failed,
   1298 passed, 9 skipped, identical error text), each labeled as a deduction.
3. A short, ordered set of discriminating experiments the executor must run first; they take
   minutes and select between the two candidate mechanisms below before any code change.

## Symptom (from spec.md, treated as captured evidence)

- Direct run (`Invoke-Pester -Path tests/scripts/powershell/PoshQC` from a plain session): all pass.
- Bundled run (`scripts/dev-tools/run-poshqc-suite.ps1` or MCP `run_poshqc_suite`, which
  `Import-Module`s `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1` and calls
  `Invoke-PoshQCSuite -> Invoke-PoshQCTest -> Invoke-Pester` in-process): 31 failures, every one
  `RuntimeException: Mock data are not setup for this scope, what happened?`.

## Current State Analysis (verified)

### Invocation architecture difference between the two modes

- `scripts/dev-tools/run-poshqc-suite.ps1:21-24` imports the **bundled** manifest
  (`..\powershell\PoshQC\PoshQC.psd1` relative to `scripts/dev-tools`, i.e. the
  `extensions`-mirrored tree is used by the template; the repo entry script resolves
  `scripts/powershell/PoshQC/PoshQC.psd1`) with `-Force`, then calls `Invoke-PoshQCSuite`. The
  packaged template `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1` is
  line-identical in shape and imports the bundled tree's manifest.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:259` defines the Pester invocation seam as a
  parameter default: `[scriptblock] $InvokePester = { param($Config) Invoke-Pester -Configuration $Config }`,
  invoked at line 358 (`$pesterResult = & $InvokePester $config`). A scriptblock literal that is a
  parameter default of a module function is bound to that module's session state.
- Pester 5.6.1 `Invoke-Pester` captures its **caller's** session state:
  `Pester.psm1:5023` (`$sessionState = $PSCmdlet.SessionState`), and every discovered test file is
  dot-sourced into a scope rebound to exactly that session state:
  `Pester.psm1:3077-3100` (`Invoke-File` rebinds the wrapper scriptblock's
  `SessionStateInternal` to the caller session state before `. $Path`).

Consequence (verified from the above, not from a live run): in the bundled mode, **every test
container in the whole run — all of `tests/scripts/**` — executes inside the imported PoshQC
module's session state**, not the global session state. In the direct mode, containers execute in
the global session state. This is the single architectural difference between the passing and
failing invocations; the test files, guards, Pester version (pinned 5.6.1 by
`Install-PoshQCTool`, `PoshQC.psm1:57`; version 5.6.1 confirmed installed), and settings
(`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` Run.Path
`@('scripts','tests/powershell','tests/scripts')`; `config/poshqc-scan.json` lists the same three
folders) are identical.

### The error's throw site in Pester 5.6.1 (verified)

`Pester.psm1:15208-15231`, `Get-MockDataForCurrentScope`: throws
`"Mock data are not setup for this scope, what happened?"` when the current test (or, outside a
test, the current block) exists but its `PluginData.Mock` table is absent. That table is created
by the Mock plugin's `ContainerRunStart` / `EachBlockSetupStart` / `EachTestSetupStart` steps
(`Pester.psm1:14644-14687`), which run only during the run phase of an active `Invoke-Pester`.
The function has exactly two callers:

- `Mock` itself, at `Pester.psm1:14896` (before command resolution), and
- `Invoke-Mock`'s call-history lookup at `Pester.psm1:15868` (executed whenever a mocked command's
  bootstrap alias is invoked).

So the identical error text can arise either at mock setup or at mocked-command invocation.

### Mock's module-name defaulting under module-hosted containers (verified)

- `Pester.psm1:14876-14881`: when `Mock` runs in a scope whose session state belongs to a module,
  `$ModuleName` defaults to that module's name. In the bundled run, **every file-scope `Mock` in
  every suite** (not only PoshQC's) therefore becomes a module-scoped mock named `PoshQC`.
- `Pester.psm1:11582-11598` (`Resolve-Command`): when the caller session state's module name equals
  the target module name, Pester short-circuits ("We are already running in $ModuleName") and uses
  the caller's module object directly — no `Get-Module` lookup. This explains why the other 600+
  `Mock` uses in the run still intercept correctly: their hooks land in the hosting (bundled)
  module session state, which is the ancestor scope of every container.
- `InModuleScope` (`Pester.psm1:10665`) resolves the module via `Get-CompatibleModule`
  (`Pester.psm1:10712-10736`), which uses `Get-Module -Name <name> -All` and **throws
  "Multiple script or manifest modules named '<name>' are currently loaded"** if more than one
  instance is loaded.

### The failing set is exactly the Mock-calling tests (verified census + deduction)

Census of `tests/scripts/powershell/PoshQC/`:

| File | BeforeAll import pattern | Tests calling Pester `Mock` | In failing set |
|---|---|---|---|
| `Get-PoshQCFileList.Excludes.Tests.ps1` | plain `Import-Module ... -Force` (line 4) | 0 | no |
| `PoshQC.Comprehensive.Tests.ps1` | guard + `Import-Module -Force` (lines 7-23) | 26 | yes |
| `PoshQC.EntryPoints.Tests.ps1` | guard + `Import-Module -Force` (lines 5-24) | 1 (`Invoke-PoshQCFormat` empty-list test, lines 63-77) | inferred yes (completes the 31) |
| `PoshQC.ScanConfig.Tests.ps1` | guard + `Import-Module -Force` (lines 3-13) | 0 | no |
| `PoshQC.ScanFolders.Tests.ps1` | guard + `Import-Module -Force` (lines 3-13) | 4 (1 `InModuleScope`+`Mock`, 3 file-scope wrapper-transport) | yes |
| `PoshQC.Tests.ps1` | plain `Import-Module ... -Force` (lines 3-5) | 0 (injected seams only; 1 `InModuleScope` without behavior mocks in EntryPoints, see note) | no |

26 + 4 + 1 = **31**, matching the reported failure count exactly. Additional deductions from the
captured signature (all failures carry the *same* error text):

1. `PoshQC.ScanFolders.Tests.ps1` contains two `InModuleScope`-without-`Mock` tests (lines 41-63).
   They are not in the failing set. Had two `PoshQC` script-module instances been simultaneously
   visible at their run time, `Get-CompatibleModule` would have failed them with the distinct
   "Multiple script or manifest modules" message. Deduction: **at PoshQC container run time,
   exactly one `PoshQC` instance is visible; the BeforeAll guard does succeed at removing the
   bundled instance.** The root cause is therefore *not* an unresolved `InModuleScope` ambiguity.
2. `Mock -CommandName` appears 718 times across 36 test files under `tests/` (verified by grep);
   1298 tests pass in the same bundled run, including suites that sort after the PoshQC folder
   (for example `tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1`, 48 `Mock` uses).
   Deduction: **Pester's runtime `$state` and the Mock plugin are healthy before, during, and
   after the PoshQC containers.** The breakage is scoped to test code executing in the PoshQC
   containers' mock pipeline, not to a globally corrupted Pester run.
3. The three failing wrapper-transport tests use `Mock` at file scope, with no `InModuleScope` and
   no module guard interaction inside the test body. Deduction: any fix confined to the
   `InModuleScope` resolution layer or to individual `BeforeAll` guards cannot be shown to cover
   these tests; the shared factor for all 31 is Pester `Mock` executing in a PoshQC test container
   under the bundled hosting architecture after the guard removed the hosting module.

### Why the existing guard does not prevent the failure (verified structure + deduction)

The guard (`PoshQC.Comprehensive.Tests.ps1:10-15` and equivalents) runs in `BeforeAll` of each
guarded container and executes `Remove-Module -ModuleInfo <instance> -Force` for any loaded
`PoshQC` whose path is not the repo-root path. In the bundled run the removed instance is the
**module whose session state hosts the entire Pester run**: `Invoke-PoshQCSuite` and
`Invoke-PoshQCTest` frames are executing on the call stack in that session state, and every
already-discovered test container scriptblock (all suites) is bound to it. The guard was designed
for the direct-mode collision case (a stray pre-imported copy in an otherwise global-hosted run);
it was not designed for — and cannot repair — the bundled mode, where the "stray copy" is the live
host of the run itself. Removing it mid-run orphans the hosting session state and changes the
semantics of every subsequent `Mock` executed by PoshQC tests (module-name defaulting now points
at a removed module object; hooks and behaviors recorded against instances that the repeated
`Import-Module -Force` calls keep tearing down and recreating). The guard also cannot help the
three wrapper-transport tests, whose mocks never mention a module.

Note on upstream precedent: Pester issue #1534 documents this exact error text arising from
orphaned mock bootstrap functions/aliases surviving in a module session state, and
`Invoke-Pester` explicitly defends against stale hooks only at run start
(`Pester.psm1:4961-4965`, `Remove-MockFunctionsAndAliases`), not against a hosting module being
removed mid-run. Mid-run removal of the hosting module is outside Pester's supported envelope.

### What is established vs. what still requires the instrumented run

Established (evidence above):
- The only architectural difference between passing and failing modes is that the bundled entry
  hosts discovery and every container inside the bundled PoshQC module's session state, with a
  same-named module pre-imported before discovery.
- The failing set is exactly the 31 Pester-`Mock`-calling tests in the three guarded PoshQC files;
  mock machinery works everywhere else in the same run.
- The guard succeeds at de-duplicating module instances but removes the run's hosting module.

Not established (requires execution; see experiments): which of the two `Get-MockDataForCurrentScope`
call sites (14896 setup vs. 15868 invocation) actually throws, and the precise internal step that
loses the plugin-data association once the hosting module has been removed. Do not treat any
single-step internal narrative as confirmed until experiment E2 below is run.

## Discriminating Experiments (executor: run these before implementing)

All commands from the repo root, each in a fresh `pwsh -NoProfile` process.

- **E1 — isolate hosting vs. pre-import collision (primary discriminator).**
  ```powershell
  # E1a: global-hosted run WITH the colliding bundled module pre-imported
  pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-Pester -Path tests/scripts/powershell/PoshQC -Output Detailed"
  # E1b: module-hosted run (production bundled path), narrowed to the PoshQC folder
  pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"
  ```
  If E1a passes and E1b fails: module-session-state hosting is the necessary condition; the
  recommended fix below is confirmed as the right layer. If E1a also fails: the pre-import
  collision plus guard removal is sufficient on its own, and the fix must additionally clear the
  colliding top-level import before discovery (contingency noted in the fix section).
- **E2 — locate the throw site.** Re-run the failing case with test-result XML enabled (already on
  in the run settings) and inspect one failure's `ScriptStackTrace` in
  `artifacts/pester/pester-junit.xml`; Pester frames will show whether the throw came from `Mock`
  (`Pester.psm1: line ~14896`) or from `Invoke-Mock` (`line ~15868`).
- **E3 — observe module topology at failure time.** Temporarily insert into the first failing `It`
  (`PoshQC.Comprehensive.Tests.ps1`, before the `InModuleScope` call):
  ```powershell
  Get-Module -Name PoshQC -All | Select-Object Name, Path, Guid | Out-Host
  $ExecutionContext.SessionState.Module | Select-Object Name, Path | Out-Host
  ```
  Expected under the hosting hypothesis: `$ExecutionContext.SessionState.Module` is the (removed)
  bundled instance in the bundled run and `$null` in the direct run.
- **E4 — full baseline/repro pair.**
  ```powershell
  pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC -Output Detailed"   # expect pass
  pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1                                       # expect 31 failures
  ```
- Optional: set `Debug.WriteDebugMessages = $true` with `WriteDebugMessagesFrom = 'Mock'` in a
  copy of the run settings to capture Pester's own mock-resolution trace ("We are already running
  in PoshQC. Using that." at `Pester.psm1:11584` is the marker of module-hosted mock setup).

## Candidate Fix Approaches

### Approach A (recommended): host the Pester run in the global session state at the `Invoke-PoshQCTest` seam

Change the default `$InvokePester` seam in `PoshQC.Testing.psm1` so `Invoke-Pester` is called from
a function defined in the global scope from an **unbound** scriptblock, and make the Pester import
globally visible:

```powershell
[scriptblock] $EnsureModule = {
    param([string] $Name, [string] $ErrorMessage)
    if (-not (Get-Module -ListAvailable -Name $Name)) { throw $ErrorMessage }
    Import-Module $Name -Global -ErrorAction Stop
},
...
[scriptblock] $InvokePester = {
    param($Config)
    # Host the Pester run in the global session state so discovered test containers do not
    # execute inside this module's session state, and BeforeAll module guards in test files can
    # safely remove/re-import same-named modules mid-run (issue #392).
    $trampoline = [scriptblock]::Create('param($c) Invoke-Pester -Configuration $c')
    $null = New-Item -Path 'function:global:Invoke-PoshQCPesterRun' -Value $trampoline -Force
    try { Invoke-PoshQCPesterRun $Config }
    finally { Remove-Item -Path 'function:global:Invoke-PoshQCPesterRun' -Force -ErrorAction SilentlyContinue }
}
```

Why this layer and shape:
- It removes the architectural divergence itself: `Invoke-Pester`'s caller session state becomes
  the global session state (`$PSCmdlet.SessionState` of a global-scope function), so the bundled
  run hosts containers exactly where the passing direct run hosts them. Every deduced and
  candidate micro-mechanism (module-name defaulting of file-scope mocks, mid-run removal of the
  hosting module, hook/session bookkeeping against torn-down instances) is neutralized by the same
  change.
- It is inside the existing injectable-seam design (`$InvokePester`, `$EnsureModule` are already
  parameters), so all current unit tests that inject these seams are unaffected.
- The `[scriptblock]::Create(...)` is required: a scriptblock literal in the module file would stay
  bound to the module session state even when installed as a global function, defeating the fix.
- The `-Global` on the Pester import is required so `Describe`/`It`/`Mock` resolve in containers
  that now run in the global session state (today Pester is imported from inside the module, which
  is sufficient only because containers are module-hosted).
- The BeforeAll guards in the test files then behave exactly as in the direct mode: they remove
  the pre-imported bundled instance (no longer the run host) and leave a single repo-root
  instance for `InModuleScope`.

Files to change (change budget: 2 production PowerShell files, within the direct-mode cap in
`.claude/rules/powershell.md`):
1. `scripts/powershell/PoshQC/PoshQC.Testing.psm1` — the two seam defaults above.
2. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` — byte-identical
   mirror, required by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (file pair listed at
   its line 13).

No template or entry-script changes are needed (`run-poshqc-suite.ps1` and the
`extensions/drm-copilot/resources/templates/run-poshqc-*.ps1` wrappers stay as-is), and no test
file needs editing.

Contingency (only if experiment E1a fails): additionally have the default `$InvokePester` remove
top-level `PoshQC` imports before invoking the trampoline (`Get-Module -Name PoshQC | Remove-Module -Force`
is legal for the module's own executing functions; the session state stays live for frames already
on the stack). Do not add this pre-emptively: in consumer repos the bundled module may be the only
PoshQC copy, and tests there may rely on the ambient import.

### Rejected alternatives (brief)

- **Patch each test file's `BeforeAll` guard / add guards everywhere.** Does not scale (six files
  today, any future file regresses), cannot explain-away or fix the three wrapper-transport
  failures whose mocks never touch module resolution, and leaves the entry-point architectural
  divergence in place for every other suite in the repo.
- **Make the entry scripts import the repo-root module or unload after import.** Breaks the
  documented invariant that the local entry script and the packaged consumer-repo wrapper are
  identical (`run-poshqc-suite.ps1:19-20`); consumer repos have no repo-root copy.
- **Run the test stage in a child `pwsh` process.** Heavier behavioral change (output/exit-code
  plumbing, slower), and unnecessary once hosting is corrected in-process.
- **Have guards keep the bundled instance (copies are byte-identical by parity).** Tests assert
  repo-root paths (for example settings paths derived from `$moduleInfo.Path`), and the
  two-instance ambiguity for `InModuleScope` would remain for unguarded files.

## Behavior Semantics

- Success condition: `pwsh scripts/dev-tools/run-poshqc-suite.ps1` (and MCP `run_poshqc_suite`)
  produces the same pass/fail results as the direct `Invoke-Pester` run — currently 1329 tests,
  0 failed, 9 skipped — with unchanged coverage and JUnit artifact outputs under `artifacts/pester/`.
- Failure conditions to preserve: `Invoke-PoshQCTest` must still throw on missing Pester, missing
  settings, and unresolved explicit scan folders; the injected-seam contract of all existing
  callers must not change (all seams keep their names, positions, and semantics).
- Ordering rules: `Invoke-PoshQCSuite` continues to run format → analyze → test; the global
  trampoline function must exist only for the duration of the Pester call (try/finally removal),
  so no global state leaks between suite invocations in a persistent host (relevant to the MCP
  server if it reuses a process).
- Edge cases: nested Pester runs launched by tests themselves (all current tests mock or
  short-circuit `Invoke-Pester`) must remain short-circuited; the trampoline must not swallow the
  `PassThru` result object (it must return `Invoke-Pester`'s output unmodified).

## Requirements Mapping (spec acceptance criteria)

- "Repro steps now produce the expected behavior": covered by Approach A; verified by E4 pair.
- "Regression test(s) added and passing": see Testing Implications; the practical regression gate
  is the bundled-suite invocation itself (E1b narrowed form), because an in-process unit test that
  nests a real `Invoke-Pester` run inside the suite's own Pester run is unsupported by Pester and
  prohibited by the repo's no-external-process unit-test policy. The planner should specify the
  narrowed bundled invocation (`Invoke-PoshQCTest -ScanFolders 'tests/scripts/powershell/PoshQC'`
  after importing the bundled manifest) as a scripted verification step with captured output.
- "No unintended behavior changes outside the defined scope": the only behavior delta is the
  session state hosting the Pester run; all seam injections bypass the changed defaults, so the
  existing unit tests for `Invoke-PoshQCTest` are unaffected.
- "Full toolchain pass": PowerShell toolchain order format → analyze → test via the MCP PoshQC
  commands, per `.claude/rules/powershell.md`.

## Testing Implications (strategy only, no test code)

1. Existing 31 failing tests are the primary regression corpus; the bundled run going green while
   the direct run stays green is the acceptance evidence.
2. Unit-level additions for the changed seams (both must live in
   `tests/scripts/powershell/PoshQC/`, mirroring production layout):
   - assert the default `$InvokePester` defines and then removes `function:global:Invoke-PoshQCPesterRun`
     around an injected fake `Invoke-Pester` (achievable by injecting a global stub `Invoke-Pester`
     function and inspecting `function:` before/after — no external process, deterministic);
   - assert the default `$EnsureModule` passes `-Global` (mockable via `Mock Import-Module` in
     module scope, consistent with existing patterns in `PoshQC.Comprehensive.Tests.ps1`).
3. Do not weaken or remove the existing BeforeAll guards: after the fix they remain correct and
   are required for the pre-imported-collision case in both modes.
4. Parity: any change to `PoshQC.Testing.psm1` requires the mirrored bundled file in the same
   change set or `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` fails.
5. Coverage: `PoshQC.Testing.psm1` is not currently in the coverage `Path` list
   (`pester.runsettings.psd1`); per the repo's changed-line coverage policy the planner should
   decide whether to add it to the measured set for this change.

## Automation Feasibility

This defect and its fix are fully local PowerShell/Pester work: reproduction, diagnosis,
implementation, and verification are all executable through `pwsh` commands and the repo's MCP
PoshQC tooling. No third-party UI (no Azure portal, no Outlook, no admin center), no credentials,
no external service, and **no human-interaction requirement** applies to any step of this feature.

## Source References

- `scripts/dev-tools/run-poshqc-suite.ps1:21-24`; `extensions/drm-copilot/resources/templates/run-poshqc-suite.ps1:21-24`
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:160-164` (EnsureModule default), `:259` (InvokePester default), `:358` (invocation)
- `scripts/powershell/PoshQC/PoshQC.psm1:82-106` (AST dot-source workaround note), `:57` (Pester 5.6.1 pin)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:2-5`; `config/poshqc-scan.json`
- `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1:7-23` (guard), `PoshQC.ScanFolders.Tests.ps1:3-13`, `PoshQC.EntryPoints.Tests.ps1:5-24`, `PoshQC.ScanConfig.Tests.ps1:3-13`
- Installed Pester 5.6.1 (`C:\Users\DanMoisan\OneDrive\Documents\PowerShell\Modules\Pester\5.6.1\Pester.psm1`):
  `4959-4974` (state/init and leftover-mock cleanup), `5023` (caller session state capture),
  `3077-3100` (Invoke-File container hosting), `10665`, `10712-10736` (InModuleScope/Get-CompatibleModule),
  `11582-11598` (Resolve-Command caller-module short-circuit), `12548-12599` (Remove-MockFunctionsAndAliases),
  `14644-14687` (Mock plugin data lifecycle), `14876-14896` (Mock module-name defaulting and setup call),
  `15208-15231` (throw site), `15868` (invocation-path call)
- Upstream precedent: pester/Pester issue #1534 (orphaned mock hooks in module session state produce
  this error text); PR #2332 (mock-hook cleanup mechanics)
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:13` (parity pair for `PoshQC.Testing.psm1`)
