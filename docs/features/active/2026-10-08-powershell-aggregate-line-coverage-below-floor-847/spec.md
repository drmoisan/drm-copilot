# 2026-10-08-powershell-aggregate-line-coverage-below-floor (Spec)

- **Issue:** #847
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T23-55
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only)
- **Primary research:** `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/research/research.2026-10-08T23-50.md`

## Context

Repository-wide PowerShell line coverage is 84.67% (13325/15738 lines, 174 files), below the uniform 85% line-coverage floor in `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md`. The drop from 96.38% (127 files) followed #527 (PR #821, merged as 9fb35e7f), which replaced the 127-file runsettings allow-list with a population derived from `config/poshqc-coverage.json`. The newly measured files include several with zero coverage. CI does not enforce a PowerShell threshold, so no gate currently fails.

Baseline source: `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md` (CI run 36983551836). On that baseline the floor requires 53 more covered lines (research, Numeric Derivation Evidence N2). That figure is context only; it is not an acceptance criterion because `main` has moved since 2026-10-02.

The three scripts targeted by this fix and their baseline line coverage:

| File | Covered / Total | Cause of 0% |
|---|---|---|
| `scripts/dev-tools/bootstrap-host.ps1` | 0/177 | No tests |
| `scripts/dev-tools/verify-host.ps1` | 0/153 | No tests; logic runs at script top level |
| `scripts/dev-tools/publish-sideloaded-extension.ps1` | 0/138 | Tests load functions through `Import-ScriptFunction`, which re-parses text so coverage breakpoints on the original file never fire |
| `scripts/dev-tools/bootstrap-host.helpers.ps1` | 0/43 | No tests; dot-sourced only by `bootstrap-host.ps1` |

## Decision Record (fixed; not to be revisited)

- **DR-1 (operator decision, 2026-10-08):** Refactor the three 0%-covered host scripts `scripts/dev-tools/bootstrap-host.ps1`, `scripts/dev-tools/verify-host.ps1` and `scripts/dev-tools/publish-sideloaded-extension.ps1` into thin entry-point wiring plus host-neutral logic in testable modules (`.psm1`), then test them, per the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`. Preserve each script's existing external behavior and parameters, including current failure behavior (for example, the missing `scripts/host-tools.manifest.json`). That defect is out of scope and is recorded as a follow-up.
- **DR-2 (design, from research):** Use the research's recommended four-module layout directly in `scripts/dev-tools/`: `HostTooling.psm1`, `HostBootstrap.psm1` (absorbing `bootstrap-host.helpers.ps1`, which is then deleted), `HostVerification.psm1`, `SideloadedExtensionPublish.psm1`. No `.psd1` manifests and no subfolders. The research found no reason to differ.

## Repro & Evidence

1. On `main` at or after 9fb35e7f, run the self-hosted PoshQC suite: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root .`.
2. Confirm the log line `Code coverage population: source=config; files=<n>`.
3. Reduce `artifacts/pester/powershell-coverage.xml` to the report-level `counter[@type='LINE']` and per-file `sourcefile/counter[@type='LINE']` rates.

Expected: aggregate line coverage >= 85% with every production file in the denominator; each new or modified file >= 85%.
Actual (2026-10-02 baseline): 84.67%; the four files above at 0%.

## Root Cause Analysis

- The 127-file allow-list excluded these files from measurement. #527 made the population config-derived, which exposed existing untested code; it did not remove tests.
- `bootstrap-host.ps1` and `verify-host.ps1` mix host I/O with logic; `verify-host.ps1` and `publish-sideloaded-extension.ps1` have no dot-source guard and execute side effects on load, so they cannot be tested in place.
- The existing publish tests use `Import-ScriptFunction` (`tests/scripts/powershell/Support/TestHelpers.ps1:27-34`), which cannot attribute coverage to the source file.

## Scope & Non-Goals

- **In scope:** the module extraction in DR-1/DR-2; new Pester tests for the four modules and the three entry scripts; rewriting `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`; deleting `scripts/dev-tools/bootstrap-host.helpers.ps1`; recording a follow-up for the missing manifest and missing bash bootstrap script; baseline and post-change coverage evidence.
- **Out of scope / non-goals:**
  - Fixing the missing `scripts/host-tools.manifest.json` or the stale `scripts/bash/bootstrap-host.sh` reference.
  - Raising coverage of any other file, including `scripts/powershell/PoshQC/PoshQC.psm1` and the `.codex/scripts/**` files named in `issue.md`. The issue's seeded test-strategy item naming those files is superseded by DR-1.
  - Adding an enforced PowerShell coverage threshold to CI (candidate follow-up).
  - Changing #527's open acceptance criteria.
- **Explicitly excluded paths (must not be edited):** `.codex/**` (including `.codex/scripts/**` epic-child launch scripts and `.codex/hooks/**`); `.claude/hooks/validate-feature-review-coverage.ps1` (shared with #824); `.claude/rules/**`; `.github/instructions/**`; `config/poshqc-coverage.json`; `scripts/powershell/PoshQC/**` (including `settings/pester.runsettings.psd1`); `quality-tiers.yml`; `config/blast-radius.json`; `.vscode/tasks.json`; `scripts/dev-tools/vscode-cli.helpers.ps1`; `extensions/drm-copilot/resources/**`.
- **No coverage exclusions:** no production file may be added to any coverage `exclude` list, and no coverage root may be narrowed.

## Proposed Fix

### Design summary

| Module | Responsibility | Key exports |
|---|---|---|
| `HostTooling.psm1` | Shared host seams used by bootstrap and verify | `Get-HostToolsManifestPath`, `Read-HostToolsManifest` (returns `$null` when absent), `Get-SessionPathFromMachineAndUser` (de-duplicated), `Get-HostEnvironmentVariable`, `Set-HostEnvironmentVariable` (ShouldProcess), `Invoke-HostNativeCommand` (returns `{ Output; ExitCode }`), `Get-CommandVersion`, pure `ConvertTo-HostToolVersion` |
| `HostBootstrap.psm1` | Bootstrap logic plus the former helper file; imports `HostTooling.psm1` | `Invoke-BootstrapHost` (signature unchanged, including `[bool]$IsWindowsHost = $IsWindows`), install/PATH/RunOnce/workspace functions, pure `Get-BootstrapResumeArgument`, `Install-HostPowerShellModule` seam, process wrappers renamed with module-unique nouns (for example `Invoke-HostBootstrapWinget`) |
| `HostVerification.psm1` | Verification logic; imports `HostTooling.psm1` | `Invoke-HostVerification` (returns `{ Lines; ExitCode }`), section functions `Test-HostCoreVersions`, `Test-HostRequiredCommands`, `Test-HostOptionalCommands`, `Test-HostPowerShellModules`, `Test-HostPoetryTools` (each returns `{ Lines; FailureCount }`), `Test-VersionAtLeast`, `Get-RequiredCommandsForHost`, `Get-PoetryVersionInfo`, `Invoke-PoetryCommand` (returns `{ Output; ExitCode }`) |
| `SideloadedExtensionPublish.psm1` | Publish logic; dot-sources `vscode-cli.helpers.ps1` from its own path | `Invoke-SideloadedExtensionPublish` (same parameters as the script, `SupportsShouldProcess`, `ConfirmImpact = 'Medium'`), manifest/project-root/compile/npm-retry functions; `Stop-NodeProcess` becomes a non-exported top-level function |

If `HostBootstrap.psm1` exceeds 500 lines, move the workspace/project functions into `scripts/dev-tools/HostBootstrapWorkspace.psm1`.

### Residual entry-point shape

Each entry script keeps its `param` block unchanged, sets StrictMode and EAP, imports its module with `Import-Module (Join-Path $PSScriptRoot '<Module>.psm1')` (no `-Force`), and calls one orchestrator function. `verify-host.ps1` writes the returned lines and calls `exit $result.ExitCode`. `publish-sideloaded-extension.ps1` keeps its two default expressions and forwards `CodeCommand` only when `$PSBoundParameters.ContainsKey('CodeCommand')`, and forwards `-WhatIf`/`-Confirm` by splatting. Each statement in an entry script occupies its own line so every statement has its own coverage entry.

### Boundaries and invariants to preserve

- Parameter names, types, defaults, attributes, and switch semantics on all three entry scripts.
- bootstrap: dry run (no `-Apply`) performs no installs, registry writes, or clones and prints "- Would ..." lines; non-Windows host or missing `winget` produces an error record and exit code 1; RunOnce is set only with both `-Apply` and `-EnableAutoResumeAfterReboot` and cleared after a successful apply; a poetry winget failure falls back to pip; a poetry project-install failure is a warning; `verify-host.ps1` is still invoked by sibling script path and its exit code is still ignored.
- verify: same five section headings, line text, and line order; exit 0 if and only if the failure count is 0; a missing manifest produces `Manifest not found at <path>` and exit 1.
- publish: step order npm ci, compile, vsce package, install; each step gated by ShouldProcess and the Skip switches; EPERM retry up to 3 attempts with backoff `DelaySeconds x attempt`; non-EPERM errors rethrow immediately; throws when the VSIX is missing; final pipeline output is the VSIX path; an explicit `-CodeCommand` that is not found throws; `.vscode/tasks.json` invocation with `-Force` unchanged.
- Current failure behavior caused by the missing `scripts/host-tools.manifest.json` and `scripts/bash/bootstrap-host.sh` is preserved.

### Module gotchas (mandatory)

1. **Preference isolation.** Every new module sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope. Module functions do not inherit these from the calling script; without them, `Write-Error` precondition failures become non-terminating and the entry scripts would exit 0.
2. **No `-Force` in entry scripts.** Entry scripts import their module without `-Force`. A forced re-import while a test runs the entry script discards `-ModuleName` mocks and could run real host commands.
3. **No `exit` inside modules.** `exit` in a module function ends the caller (and a Pester container). Exit codes are returned to the entry script.

### Error handling and logging

Existing `Write-Error`/`throw` semantics are retained. Native-command wrappers keep throw-on-nonzero behavior where the original functions had it (`Invoke-NpmExe` had no exit-code check and keeps none). No new logging channel is added.

### Rollback

Revert the PR. No configuration, data, or schema is migrated.

### Technical specifications

- **Inputs/outputs:** unchanged for all three entry scripts (stdout status lines, error records, process exit codes, VSIX path pipeline output).
- **Configuration keys:** none added. `config/poshqc-coverage.json`, `pester.runsettings.psd1`, and `quality-tiers.yml` are unchanged (research section 4: new `.psm1` files under `scripts/dev-tools/` are discovered by the existing `scripts` root and map to the existing T4 `scripts/dev-tools` project under rule R3).
- **Backward compatibility:** no in-repo caller other than `.vscode/tasks.json` and the bootstrap-to-verify sibling invocation; both remain valid.
- **Performance:** no constraint. Accepted non-functional change: `verify-host.ps1` emits its status lines when the run completes rather than progressively (content and order unchanged).

## Assumptions, Constraints, Dependencies

The operator is not consulted during execution. The following are recorded as assumptions:

- **A-1:** DR-1 and DR-2 are fixed and are not reopened during planning or execution.
- **A-2:** The coverage configuration files `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and `quality-tiers.yml` need no change (research section 4).
- **A-3:** The 2026-10-02 baseline is stale because `main` has moved (for example #802/#803 at `a24a1ce3`). The baseline aggregate is re-measured at execution time, before code changes, from a self-hosted full PoshQC run on the branch base (or a current-`main` CI `poshqc` artifact) and recorded as evidence.
- **A-4:** Refactoring the three scripts is sufficient to lift the aggregate above 85%. Research projects about 87.1% to 87.6% on the 2026-10-02 denominator; these are estimates. If the measured post-change aggregate is below 85%, the executor records the gap and stops for re-planning rather than editing excluded paths.
- **A-5:** The MCP `run_poshqc_test` result is not used as evidence because it reads the installed extension's settings and returns no output. Evidence comes from the self-hosted invocation or the CI `poshqc` job.
- **A-6:** Pester `Mock -ModuleName` mock bodies run in module session state; fixtures inside them are inline literals.
- **A-7:** Test-scope mocks intercept commands called from an entry script run with `&` in the same session (precedent `tests/scripts/dev-tools/tree.Tests.ps1:438-445`).
- **A-8:** Clock and sleep seams in `SideloadedExtensionPublish.psm1` use injected scriptblock parameters (`$Now`, `$Sleep`) per the controllable-clock rule; other host seams use wrapper functions mocked with `-ModuleName`.
- **A-9:** The CI `poshqc` job runs on `windows-latest`; registry and `$IsWindows` behavior is reached in tests only through mocks or `-IsWindowsHost`.
- **A-10:** In agent worktrees, PowerShell invocations use the PowerShell tool, because the Bash text guard denies commands containing `pwsh`.
- **A-11:** The follow-up for the missing manifest is recorded as a potential-issue entry under `docs/features/potential/`, because `gh issue create` is blocked by a repository hook.
- **Constraints:** 500-line file limit; no temporary files in tests; no new dependencies; T4 tier gates plus uniform coverage thresholds (line >= 85%; Pester has no branch-coverage gate).
- **External dependencies:** Pester and PSScriptAnalyzer as already used by PoshQC; GitHub Actions `poshqc` job.

## Data / API / Config Impact

- User-facing changes: none, apart from the verify-host output-timing note above.
- Data or migration: none.
- Logging/telemetry: none.
- Compatibility: entry-script paths and parameters unchanged.

## Test Strategy

- **Test files (mirror module paths under `tests/scripts/dev-tools/`):** `HostTooling.Tests.ps1`, `HostBootstrap.Tests.ps1` (plus `HostBootstrap.Workspace.Tests.ps1` or `HostBootstrapWorkspace.Tests.ps1` if needed for the 500-line limit), `HostVerification.Tests.ps1`, `SideloadedExtensionPublish.Tests.ps1`, `bootstrap-host.Tests.ps1`, `verify-host.Tests.ps1`.
- **Rewritten test file:** `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`. Its `Import-ScriptFunction` usage is removed (the functions move, so it would otherwise fail with "Function ... not found"). It becomes an entry-point test; the `scaffold extension package identity` Describe, which reads the checked-in `extensions/drm-copilot/package.json`, is kept.
- **Import pattern:** import modules through `Resolve-Path` so coverage binds to the configured path (precedent `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1:21-40`); `AfterAll { Remove-Module <name> -ErrorAction SilentlyContinue }`. No new or rewritten test uses `Import-ScriptFunction`.
- **Entry tests:** run `& $entryPath <args>` in-process once per exit path, with module mocks plus a test-scope mock of the orchestrator as a second layer; assert output and `$LASTEXITCODE`.
- **Required scenarios:** dry-run vs apply; already-installed short-circuit; winget-failure poetry fallback and non-poetry rethrow; missing python; User PATH de-duplication (case and trailing backslash); resume-argument composition; manifest missing; empty winget list; each verify section's OK/FAIL/WARN outcome; exit-code boundary (0 vs 1 failure); poetry via `python -m poetry`; EPERM retry exhaustion; non-EPERM immediate rethrow; `-Force` cleanup path; compile selection (script, tsconfig, neither); `CodeCommand` bound-empty vs unbound; `-WhatIf` performs no seam calls; VSIX-missing throw; non-Windows and missing-winget preconditions return exit code 1.
- **Isolation:** mock Test-Path, Get-Content, New-Item, New-ItemProperty, Remove-ItemProperty, Get-Command, Get-Module, Get-Process, Stop-Process, Remove-Item, Push-Location, Pop-Location, Get-ChildItem, the PowerShell-module install seam, the environment seams, and every native-process wrapper. No real `winget`, `npm`, `npx`, `wsl`, `git`, `python`, `poetry`, `code`, or `cmd.exe` call. No `TestDrive:`, `New-TemporaryFile`, or temp-path writes.
- **Toolchain loop (PowerShell):** PoshQC format, PSScriptAnalyzer, Pester (architecture, contract, and integration stages are not applicable to these files and are recorded as such).
- **Coverage measurement:** targeted per-file verification may use direct Pester with JaCoCo output under `artifacts/pester/`; the aggregate is taken only from a full self-hosted run (`Invoke-PoshQCTest -Root .`) without `-ScanFolders`. Evidence summaries go to `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/<kind>/`.

## Acceptance Criteria

- [x] AC-01: A pre-change baseline evidence file under `evidence/baseline/` records the repository-wide PowerShell LINE covered/total/percentage and the per-file LINE rows for the four in-scope files, measured at execution time from a full self-hosted PoshQC run on the branch base or a current-`main` CI `poshqc` artifact, and names the commit measured.
- [x] AC-02: Repository-wide PowerShell line coverage is >= 85%, computed as covered / (covered + missed) from the report-level `counter[@type='LINE']` in `artifacts/pester/powershell-coverage.xml` produced by a full self-hosted `Invoke-PoshQCTest -Root .` run whose log shows `Code coverage population: source=config`, with no root narrowed, no `-ScanFolders` argument, and no production file excluded; the values are recorded in `evidence/coverage/`.
- [x] AC-03: Each new or modified PowerShell production file (`HostTooling.psm1`, `HostBootstrap.psm1`, `HostVerification.psm1`, `SideloadedExtensionPublish.psm1`, `HostBootstrapWorkspace.psm1` if created, `bootstrap-host.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`) has per-file line coverage >= 85% in the AC-02 coverage XML, with each per-file row recorded in `evidence/coverage/`.
- [x] AC-04: The `param` block of each of the three entry scripts is unchanged from the branch base, verified by an evidence record comparing parameter names, types, default-value expressions, and attributes (including `CmdletBinding` arguments) parsed via the PowerShell AST from the base and head versions, with no differences reported.
- [x] AC-05: Each entry script is invoked directly with `&` from at least one Pester test per exit path, with all host commands mocked, asserting output and `$LASTEXITCODE`: bootstrap (dry-run success; non-Windows exit 1; missing-winget exit 1), verify (exit 0 with zero failures; exit 1 with one failure; exit 1 with `Manifest not found at <path>`), publish (VSIX path as final pipeline output; `-WhatIf` performs no seam calls; `CodeCommand` bound-empty vs unbound forwarding).
- [x] AC-06: Tests demonstrate the preserved behaviors listed under "Boundaries and invariants to preserve", including the missing-manifest failure path for both bootstrap and verify, the poetry pip fallback, RunOnce set/clear conditions, the EPERM retry limit and backoff, and the publish step order.
- [x] AC-07: No new or rewritten test creates or writes temporary files, and every process, registry, network, environment-variable write, and file-system host call made by code under test is mocked; verified by a recorded search of the new and rewritten test files showing no `TestDrive:`, `New-TemporaryFile`, `GetTempPath`, `$env:TEMP`, or `$env:TMP` usage, and by the Pester run completing with all host seams mocked.
- [x] AC-08: No new or rewritten test file calls `Import-ScriptFunction`; `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1` is rewritten accordingly and retains the `scaffold extension package identity` Describe.
- [x] AC-09: Every new module sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope, contains no `exit` statement, and no entry script calls `Import-Module` with `-Force`; verified by a recorded search of the changed files.
- [x] AC-10: `scripts/dev-tools/bootstrap-host.helpers.ps1` is deleted and no file in the repository (excluding `docs/features/**`) references it.
- [x] AC-11: The PowerShell toolchain is clean on all changed PowerShell files in a single pass: PoshQC format reports no changes, PSScriptAnalyzer reports zero errors and zero warnings, and the full Pester suite reports zero failures; results are recorded in `evidence/qa-gates/`.
- [x] AC-12: Every new or modified file in the PR (production, test, and evidence `.ps1`/`.psm1` files) is <= 500 lines.
- [x] AC-13: `git diff --name-only <merge-base>...HEAD` lists no path under `.codex/`, `.claude/rules/`, or `.github/instructions/`, and does not list `.claude/hooks/validate-feature-review-coverage.ps1`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/**`, `quality-tiers.yml`, `.vscode/tasks.json`, or `scripts/dev-tools/vscode-cli.helpers.ps1`.
- [ ] AC-14: A follow-up potential-issue entry exists under `docs/features/potential/` describing the missing `scripts/host-tools.manifest.json` (read by `bootstrap-host.ps1` and `verify-host.ps1`) and the missing `scripts/bash/bootstrap-host.sh` referenced by `bootstrap-host.ps1`, and the PR description references it.
- [ ] AC-15: The CI `poshqc` job passes on the PR head commit (CI-dependent; verified from the PR checks).

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Forced re-import discards `-ModuleName` mocks and real host commands run during tests | No `-Force` in entry scripts (AC-09); entry tests also mock the orchestrator at test scope |
| Missing module-scope EAP/StrictMode turns precondition failures into exit 0 | Module-scope settings (AC-09); exit-1 path tests (AC-05) |
| Exported wrapper names collide with functions dot-sourced by other test files (`Invoke-GitExe`, `Invoke-NpmExe` in `Invoke-MarketplacePublish.ps1`) | Module-unique wrapper names; `Remove-Module` in `AfterAll` |
| Stale baseline misstates the delta | Re-baseline at execution time (AC-01) |
| Post-change aggregate still below 85% because other files regressed on `main` | Record measured gap and stop for re-planning (A-4); excluded paths are not edited |
| Entry-script statements sharing a line hide a missed statement | One statement per line in entry scripts |
| `verify-host.ps1` output timing changes | Accepted non-functional change; content and order tested |

## Files Expected to Change

Production (new):
- `scripts/dev-tools/HostTooling.psm1`
- `scripts/dev-tools/HostBootstrap.psm1`
- `scripts/dev-tools/HostBootstrapWorkspace.psm1` (only if required by the 500-line limit)
- `scripts/dev-tools/HostVerification.psm1`
- `scripts/dev-tools/SideloadedExtensionPublish.psm1`

Production (modified):
- `scripts/dev-tools/bootstrap-host.ps1`
- `scripts/dev-tools/verify-host.ps1`
- `scripts/dev-tools/publish-sideloaded-extension.ps1`

Production (deleted):
- `scripts/dev-tools/bootstrap-host.helpers.ps1`

Tests (new):
- `tests/scripts/dev-tools/HostTooling.Tests.ps1`
- `tests/scripts/dev-tools/HostBootstrap.Tests.ps1`
- `tests/scripts/dev-tools/HostBootstrap.Workspace.Tests.ps1` or `HostBootstrapWorkspace.Tests.ps1` (only if required)
- `tests/scripts/dev-tools/HostVerification.Tests.ps1`
- `tests/scripts/dev-tools/SideloadedExtensionPublish.Tests.ps1`
- `tests/scripts/dev-tools/bootstrap-host.Tests.ps1`
- `tests/scripts/dev-tools/verify-host.Tests.ps1`

Tests (rewritten):
- `tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1`

Documentation and evidence:
- `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md` (this file)
- `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.*.md`
- `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/baseline/*.md`, `evidence/coverage/*.md`, `evidence/qa-gates/*.md`
- `docs/features/potential/<date>-host-tools-manifest-and-bash-bootstrap-missing.md` (follow-up, AC-14)

Generated, not committed: `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/powershell-coverage.koverage.xml`, and any targeted `artifacts/pester/847-*.xml`.

## Rollout & Follow-up

- Rollout: merge the PR after AC-15; no deployment step.
- Follow-ups: the missing manifest and bash bootstrap script (AC-14); optional enforced PowerShell line threshold in the CI PoshQC job once the aggregate is >= 85%; remaining sub-85% files (`.codex/scripts/**`, both `validate-feature-review-coverage.ps1` hooks, `PoshQC.psm1`) tracked separately, with `.claude/hooks/validate-feature-review-coverage.ps1` coordinated with #824.
- Links: issue #847; predecessor #527 (PR #821); related #824.
