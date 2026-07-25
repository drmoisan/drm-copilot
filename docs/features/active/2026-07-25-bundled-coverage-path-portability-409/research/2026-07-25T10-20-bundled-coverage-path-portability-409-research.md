# Research: Bundled Coverage Path Portability (Issue #409)

- **Issue:** #409
- **Work mode:** full-bug
- **Branch:** `bug/bundled-coverage-path-portability-409`
- **Date:** 2026-07-25T10-20
- **Author:** task-researcher agent

All findings below were verified by reading the cited sources in this session unless explicitly marked otherwise. This research session had no command-execution tool (available tools: Read, Grep, Glob, WebFetch, Write, Edit), so no execution-based reproduction was performed; the failure mechanism is established by line-level reading of the installed Pester 5.6.1 module that the suite loads, the repository sources, and the official PowerShell documentation. A no-temp-file reproduction protocol for the executor is specified in "Reproduction Protocol" below.

## 1. Current State Analysis

### Components in the failure path

| Component | Path | Role |
|---|---|---|
| MCP tool `run_poshqc_test` | `extensions/drm-copilot/src/mcp-tools.ts:215-216` → `repo-automation-service.ts:277-282` | Dispatches to the bundled script |
| Entry script | `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` | Sets `Set-StrictMode -Version Latest` (line 19) and `$ErrorActionPreference = "Stop"` (line 20), imports the bundled PoshQC module (lines 22-23), calls `Invoke-PoshQCTest -Root $WorkspaceRoot ...` (line 32) |
| Runtime launch | `extensions/drm-copilot/src/runtime-detection.ts:254-264` | `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File <script>` |
| PoshQC module root | `scripts/powershell/PoshQC/PoshQC.psm1:3` | `$script:PesterSettings` = module-relative `settings/pester.runsettings.psd1` (default for every workspace root) |
| Settings file | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `Run.Path = @('scripts','tests/powershell','tests/scripts')` with `Exit = $true` (lines 3-4); `CodeCoverage.Enabled = $true` (line 18) with ~35 drm-copilot-specific `Path` entries (lines 23-98), including `scripts/powershell/Publish-DrmCopilotExtension.ps1` (line 38) |
| Test runner | `scripts/powershell/PoshQC/PoshQC.Testing.psm1:151-443` (`Invoke-PoshQCTest`) | Joins each `CodeCoverage.Path` entry to `-Root` in the `$ExpandCoveragePaths` default seam (lines 215-240, join at 219-223) and again in the coverage-enabled block (lines 338-347), with no existence filter and no empty-set fallback |
| Bundled mirror | `extensions/drm-copilot/resources/powershell/PoshQC/**` | Exact-text mirror of the repo-root module tree; `packages/mcp-server/prepack.cjs:33-55` copies `extensions/drm-copilot/resources/**` (minus `.py` files and `scripts/` segments) into the published npm package |
| Parity contract | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18, 63-81` | Locks 8 files, including `PoshQC.Testing.psm1` and `settings/pester.runsettings.psd1`, to exact text parity between `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/` |
| Pester | `C:\Users\DanMoisan\OneDrive\Documents\PowerShell\Modules\Pester\5.6.1\Pester.psm1` | Installed version 5.6.1; `Install-PoshQCTool` pins 5.6.1 (`PoshQC.psm1:57`) |

Exactly two copies of `PoshQC.Testing.psm1` exist in the repository (repo root and bundled mirror), both governed by the parity test. No third copy exists under `.codex/` or `claude-customizations/`.

### Q1 — Failure mechanism (verified against installed Pester 5.6.1)

The abort is a five-link chain. Every link was verified by reading the cited line ranges.

1. **The entry script's `Stop` preference is process-global.** The extension launches `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File run-poshqc-test.ps1` (`runtime-detection.ts:254-264`). Per the official `about_pwsh` documentation for `-File`: "The specified script runs in the local scope ('dot-sourced') of the new session, so that the functions and variables that the script creates are available in [the] new session." Therefore `$ErrorActionPreference = "Stop"` at `run-poshqc-test.ps1:20` sets the session's global preference. `-NoProfile` guarantees no profile modifies it first. Pester's module functions resolve `$ErrorActionPreference` through their module scope chain, which falls back to the runspace global scope, so all non-terminating errors written inside Pester become terminating in this hosting configuration. (Verified: `Pester.psm1` contains zero occurrences of `ErrorActionPreference`, so Pester itself never overrides the inherited preference.)

2. **Coverage paths reach Pester unfiltered.** `Invoke-PoshQCTest` joins every configured `CodeCoverage.Path` entry to `-Root` (`PoshQC.Testing.psm1:219-223` and `340-346`) with no existence check. The Pester coverage plugin's `Start` step uses the configured paths verbatim — the Run.Path-derived fallback at `Pester.psm1:8567-8588` applies only when the configured path count is zero.

3. **One missing path discards the entire coverage set.** At `RunStart`, `Enter-CoverageAnalysis` (`Pester.psm1:8780`) passes the single plugin-config dictionary — containing all ~35 paths in one `Path` array (`Pester.psm1:8597-8608`) — to `Get-CoverageInfoFromUserInput` (`8896-8917`) → `Get-CoverageInfoFromDictionary` (`8933-8954`) → one `CoverageInfo` object holding the whole array → `Resolve-CoverageInfo` (`8967-8998`). There, all paths iterate inside a **single** `try { foreach ... Resolve-Path -ErrorAction Stop }` (`8975-8979`). The first nonexistent path throws; the `catch` executes `Write-Error "Could not resolve coverage path '$path': ..."` and `return` (`8980-8983`), discarding every path including those that exist.

4. **The `Write-Error` is terminating here, so RunStart fails.** Because the effective `$ErrorActionPreference` is `Stop` (link 1), the `Write-Error` at `Pester.psm1:8981` becomes a terminating error inside the RunStart plugin step. `Invoke-PluginStep` catches it (`Pester.psm1:1807-1813`), and because RunStart is invoked with `-ThrowOnFailure` (`Pester.psm1:1584-1590`), `Assert-Success` throws `"Invoking step RunStart failed: ... Could not resolve coverage path '...'"` (`1816-1819`, `1855-1857`).

5. **`Run.Exit = $true` turns the throw into `exit -1`.** The throw is caught by `Invoke-Pester`'s top-level catch (`Pester.psm1:5157-5174`); with `Run.Exit = $true` (settings line 4) it calls `exit -1` (`5171-5172`). The `pwsh -File` process exits non-zero; the MCP `CommandRunner` reports the tool call as failed. No test executed.

**Some paths exist versus none:** the abort is identical. Because all entries share one `try/catch` (`8975-8983`), a single missing entry among 35 aborts the run exactly as 35 missing entries do. This repository is currently protected only because every configured path exists here. Under a hypothetical `Continue` preference the failure mode changes but does not become correct: the error is non-terminating, the **entire** coverage set (including existing files) is silently dropped, and the run continues with zero coverage — a silent full-coverage loss rather than an abort.

**Reproduction status:** not executed in this session (no execution tool available). See "Reproduction Protocol" below for the closest achievable verification without temp files.

### Q2 — Why discovery succeeded but RunStart failed

Discovery (Pester's discovery phase, which produced "30 tests") runs before `RunStart` and consumes only `Run.Path`, via `Find-File` (`Pester.psm1:5085-5091`, `3567-3636`). Three mechanisms explain the asymmetry:

1. **Scan folders are existence-validated before reaching Pester.** When a scan config or explicit `scan_folders` is present, `Invoke-PoshQCTest` replaces `Run.Path` with resolved folders (`PoshQC.Testing.psm1:305-318`). `Resolve-PoshQCScanFolder` resolves each folder with `Resolve-Path -ErrorAction Stop` and throws a named error on a missing folder (`PoshQC.FileDiscovery.psm1:118-127`), and `Get-PoshQCScanConfigFolder` filters config-sourced folders that do not exist, with a warning (`PoshQC.ScanConfig.psm1:108-124`). So any Run.Path that comes from the scan mechanism is guaranteed to exist.
2. **The pre-Pester enumeration skips nonexistent Run.Path entries.** `$EnumerateTests` ignores paths failing `$TestPathExists` (`PoshQC.Testing.psm1:245`) and the function returns early with a logged message when zero test files are found (`373-378`).
3. **In the reported TaskMaster run, the effective Run.Path entries existed** (discovery found 30 tests), so `Find-File`'s existing-directory branch (`Pester.psm1:3584-3626`) ran without error.

**Latent `Run.Path` portability risk: yes, it exists but is narrower.** When no scan config is present, the settings defaults (`'scripts'`, `'tests/powershell'`, `'tests/scripts'`) are joined to `-Root` (`PoshQC.Testing.psm1:170-189`) and passed to Pester unvalidated. If at least one entry contains tests (so the early return at line 375 is not taken) while another entry does not exist, `Find-File` falls into its wildcard branch — `Get-ChildItem -Recurse -Path <missing> ...` (`Pester.psm1:3628-3632`) — which writes a non-terminating "Cannot find path" error that is terminating under the same global `Stop` preference, aborting **discovery**. This is a distinct defect surface from #409's coverage abort and is recommended for a separate issue (see Open Questions).

## 2. Candidate Approaches (Q3)

### (a) Prune nonexistent coverage paths inside `Invoke-PoshQCTest` — RECOMMENDED

**What it changes.** In the coverage-enabled block of `Invoke-PoshQCTest` (`PoshQC.Testing.psm1:338-347`), after `$resolvedCoveragePaths` is computed, filter the set through the existing `$TestPathExists` seam (line 167). Log each pruned entry through the existing `$Logger` seam (lines 256-260) so pruning is never silent. When the surviving set is empty: disable coverage for that run (`$config.CodeCoverage.Enabled = $false`, `$coverageEnabled = $false`) and log a clear one-line explanation, then proceed with the test run.

**Empty-set behavior rationale (all three candidate behaviors evaluated):**
- *Proceed with an empty path list* is not actually expressible: Pester treats a zero-count `CodeCoverage.Path` as "derive coverage from Run.Path parent directories" (`Pester.psm1:8567-8588`), which would instrument every file under the consumer's test directories — a large, slow, surprising behavior change.
- *Fail with a clear message* keeps consumer repositories blocked, which is the defect's impact; the issue's Expected Behavior states the run must complete.
- *Disable coverage with a logged warning* matches the issue's Expected Behavior ("coverage paths that do not exist in the target workspace do not abort the run") and is the only behavior of the three that is both expressible and unblocking. This is the recommended behavior.

**What it does not fix.** The bundled settings file still ships drm-copilot's path list (harmless after pruning — consumers simply get coverage disabled). Consumers get no coverage measurement of their own code through the bundled default; giving consumers a coverage mechanism is a separate enhancement (see option c / Open Questions). The latent `Run.Path` discovery risk from Q2 remains (separate issue).

**Tests and contracts disturbed.** None break, provided pruning consults `$TestPathExists`:
- The parity contract (`test_poshqc_bundled_parity.py`) is satisfied by making the identical edit in both copies of `PoshQC.Testing.psm1`.
- The one existing test that drives the coverage-enabled block injects `-TestPathExists { $true }` (`tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1:115-157`, injection at line 125), so its configured path survives pruning and its assertions (lines 153-155) remain valid.
- `PoshQC.TestingSeamDefaults.Tests.ps1`, `PoshQC.TestingInvokeSummary.Tests.ps1`, and `PoshQC.Comprehensive.Tests.ps1` do not assert on unpruned coverage-path pass-through.

**Size note.** `PoshQC.Testing.psm1` is currently 443 lines; the pruning block adds roughly 15-25 lines, remaining under the 500-line file cap.

### (b) Repo-neutral bundled settings + repository-local coverage list — REJECTED

Making `settings/pester.runsettings.psd1` neutral removes drm-copilot's own 35-file coverage list from the canonical `run_poshqc_test` gate, because this repository consumes the same module-relative default (`PoshQC.psm1:3`, `PoshQC.Testing.psm1:156`). A neutral file with `Enabled = $true` and an empty path list triggers Pester's whole-directory fallback (`Pester.psm1:8567-8588`), changing coverage semantics repo-wide; with `Enabled = $false`, every PowerShell coverage gate in this repository loses its data. Restoring in-repo behavior would additionally require the option-(c) discovery mechanism plus a new repo-local settings file, pushing the production surface past the 2-file direct-mode budget. The parity test itself would pass (both copies changed identically), but this repository's coverage evidence pipeline — the thing `.claude/rules/general-unit-test.md` protects — is the casualty.

### (c) Workspace-local settings discovery with bundled fallback — REJECTED AS STANDALONE

Precedent exists: `Get-PoshQCScanConfigFolder` reads a workspace-local `config/poshqc-scan.json` under `-Root` (`PoshQC.ScanConfig.psm1:31-53`). No analogous mechanism exists today for the Pester settings file (verified: `$SettingsPath` defaults to the module-relative file and is only overridable as an explicit parameter, `PoshQC.Testing.psm1:156`). As a standalone fix this does **not** resolve #409: a consumer without a local settings file still falls back to the bundled default containing the poisoned coverage list and still aborts. It fixes only consumers who take a manual authoring action, contradicting the out-of-the-box expectation in the issue.

### Rejected alternatives summary

(b) breaks this repository's own coverage gates unless combined with (c), exceeding the change budget; (c) alone does not fix the reported defect. A future (a)+(c) combination remains open as an enhancement for consumers who want their own coverage lists, but it is not needed to fix #409.

## 3. Behavior Semantics

Intended behavior after the fix (from `issue.md` Expected Behavior plus the analysis above):

- **Success condition:** `run_poshqc_test` against any workspace root completes the discovered Pester tests. Coverage instrumentation covers exactly the configured paths that exist under the resolved root.
- **Pruning rule:** each resolved coverage path (rooted entries kept as-is, relative entries joined to `-Root`) is kept if and only if `$TestPathExists` returns true for it. Every pruned path is logged individually with its resolved value.
- **Empty-set rule:** if pruning leaves zero coverage paths, coverage is disabled for that run (never passed to Pester as an empty enabled set), a single clear log line states this, and the test run proceeds. The Koverage-copy step is naturally skipped because `$coverageEnabled` is false (`PoshQC.Testing.psm1:383`).
- **Ordering:** pruning happens once, at the final authoritative resolution site (the coverage-enabled block, lines 338-347), after `$coverageEnabled` is computed (lines 329-336) and before `$InvokePester` runs (line 380). The earlier `$ExpandCoveragePaths` default seam (lines 215-240) continues to root paths only; a second pruning site is unnecessary because the enabled block re-resolves both rooted and unrooted entries.
- **No-change condition:** when every configured path exists (this repository), the surviving set is identical to today's set and behavior is byte-for-byte unchanged, including the coverage summary replay (lines 411-431).
- **Edge cases:** rooted absolute entries (kept/pruned by the same existence test); entries with wildcards (`Test-Path` supports wildcards; the current settings list contains none); `CodeCoverage.Enabled` false (pruning block never runs, exactly as today); `$config.CodeCoverage` null (guarded at line 330, unchanged).

## 4. Requirements Mapping

| Acceptance criterion (spec.md) | Design element |
|---|---|
| Repro steps produce expected behavior | Pruning + disable-on-empty in `Invoke-PoshQCTest`; consumer run reaches test execution because `Resolve-CoverageInfo` never sees a nonexistent path |
| Regression tests added | Seam-injected unit tests (section 5) asserting pruning, empty-set disable, and all-exist pass-through |
| Edge cases handled | Rooted entries, mixed existing/missing sets, disabled coverage |
| No unintended behavior changes | drm-copilot's own run is unchanged (all paths exist); verified via baseline/post coverage-artifact comparison (section 6) |
| Full toolchain pass | PoshQC format → analyze → test via MCP commands per `.claude/rules/powershell.md` |

**Production file surface (2 files, byte-identical edits):**
1. `scripts/powershell/PoshQC/PoshQC.Testing.psm1`
2. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`

**Change budget check (`.claude/rules/powershell.md`):** 2 production PowerShell files — fits the direct-mode overall scope (up to 2 production files) and the per-batch cap (at most 3 production + 3 test files). One new/extended test file keeps the batch at 2 production + 1 test.

## 5. Testing Implications (Q5)

**Seams to use (all already exist as injectable scriptblock parameters of `Invoke-PoshQCTest`):**
- `$TestPathExists` (`PoshQC.Testing.psm1:167`) — the pruning predicate. Tests inject a scriptblock returning per-path booleans (for example, keep paths containing `exists`, drop others). This is the same seam `$EnumerateTests` already receives (line 374), so one seam governs all existence checks.
- `$Logger` (`PoshQC.Testing.psm1:256-260`) — tests capture messages in a `List[string]` and assert each pruned path is named and the disable message appears.
- `$InvokePester` (`PoshQC.Testing.psm1:261-281`) — tests capture the final `$Config` and assert `CodeCoverage.Path` equals the surviving set and `CodeCoverage.Enabled` is false when the set is empty.
- `$LoadSettings` / `$BuildConfiguration` / `$EnsureModule` / `$ResolveScanConfig` / `$EnumerateTests` — faked exactly as in the existing pattern (`PoshQC.TestingInvokeConfigPaths.Tests.ps1:30-44, 125-149`), so no filesystem access and no temp files occur, satisfying `.claude/rules/general-unit-test.md` (temp files strictly prohibited) and the PowerShell mocking rules (mock the seam, signature parity with the production parameter list).

**Required scenarios:**
1. All configured paths exist → `InvokePester` receives the full resolved set; no prune logs (pass-through preservation).
2. Mixed set → only existing paths survive; each pruned path logged with its resolved value.
3. No path exists → `CodeCoverage.Enabled` false at `InvokePester`; run proceeds (result summary still replayed); disable message logged; `CopyCoverage` not invoked.
4. Rooted absolute entry → pruned/kept by the same predicate without re-joining to `-Root`.

**Existing test files covering `Invoke-PoshQCTest`** (all under `tests/scripts/powershell/PoshQC/`): `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `PoshQC.TestingInvokeSummary.Tests.ps1`, `PoshQC.TestingSeamDefaults.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1`. New tests belong in the same directory (mirroring `scripts/powershell/PoshQC/` per the universal test-layout rule): either extend `PoshQC.TestingInvokeConfigPaths.Tests.ps1` (currently 192 lines; headroom under the 500-line cap) or add `PoshQC.TestingCoveragePruning.Tests.ps1` following the same module-collision-guard `BeforeAll` pattern (`PoshQC.TestingInvokeConfigPaths.Tests.ps1:6-20`). A separate file is preferred if the four scenarios plus arrange blocks push the existing file near the cap.

**Coverage accounting for the changed file:** `scripts/powershell/PoshQC/PoshQC.Testing.psm1` is already in the coverage denominator (`pester.runsettings.psd1:97`), so the new pruning lines produce real per-file changed-line coverage evidence in the canonical artifact. Branch coverage is not separately measurable — Pester 5.6.1's coverage engine emits no `BRANCH` counter in this repository's toolchain (documented, accepted limitation; see `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/coverage-delta.md:14`).

**Reproduction Protocol (for the executor; no temp files):**
- *Fail-before (integration-shaped):* run the bundled entry with a root inside the existing repo tree where tests exist but coverage paths do not, for example `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot <repo>/tests -ScanFoldersJson '["scripts/powershell/PoshQC"]'`. Discovery succeeds (the scan folder `tests/scripts/powershell/PoshQC` exists and contains `*.Tests.ps1`); RunStart aborts on the first missing coverage path (`<repo>/tests/.claude/hooks/validate-bash.ps1`). Caveat: `Invoke-PoshQCTest` unconditionally creates the `TestResult`/coverage output directories under the chosen root (`PoshQC.Testing.psm1:196-197, 229-230, 352-354`), so `<repo>/tests/artifacts/` will be created and must be deleted afterward. This is repository-tree churn, not a temp file in the unit-test-policy sense; a fully side-effect-free faithful reproduction is not achievable because directory creation precedes the abort. If that churn is unacceptable, the fail-before evidence may instead be an exception dossier citing this research (the consumer-repo failure is already field-evidenced per `issue.md:47`).
- *Pass-after:* the same command completes with coverage disabled and a logged prune/disable explanation; clean up the same directories.
- The deterministic unit tests in section 5 remain the primary regression evidence; they touch no filesystem.

## 6. Coverage-Policy Consequence (Q4)

**Can the fix silently reduce this repository's measured coverage?** Two guards make the answer no:

1. **Nothing is prunable here.** All 35 configured entries exist in this repository, are relative, and are joined to the same `$Root` that Pester receives; `Test-Path` on Windows accepts both separators, and the pruning predicate runs on exactly the string handed to Pester today. A path that Pester could previously resolve (`Resolve-Path`, `Pester.psm1:8977`) is also resolvable by `Test-Path` — both use the same provider path semantics — so no existing-and-measured file can be dropped.
2. **Pruning is never silent by design.** Every pruned path is individually logged, so any accidental prune in this repository would be visible in the replayed run output and in CI logs.

**Verification that proves no reduction (required evidence, canonical locations per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`):**
- Baseline: run `mcp__drm-copilot__run_poshqc_test` at the drm-copilot root before the change; store the replayed coverage summary and the per-file `<sourcefile>`/`filename` set from `artifacts/pester/powershell-coverage.xml` under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/`.
- Post-change: repeat after the fix; store under `evidence/qa-gates/`.
- Comparison: the measured-file set must be identical (same 35 files), the covered-percent equal or better, and the run log must contain zero prune messages. Store the delta note under `evidence/qa-gates/`.

This also satisfies the "no production file excluded from coverage" rule: the fix adds no coverage exclusion anywhere; it only prevents Pester from being handed paths that cannot exist in the target workspace.

## 7. Delivery Path to the Consumer (Q6)

1. **Mirrored copies:** the fix must land identically in `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`; `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` enforces this at CI.
2. **Packaging:** `packages/mcp-server/prepack.cjs` copies `extensions/drm-copilot/resources/**` into the npm package's `resources/` at pack time (`prepack.cjs:51-55`; `package.json` `files` includes `resources`, `packages/mcp-server/package.json:10-13`). No packaging change is needed.
3. **Release:** `scripts/dev-tools/Invoke-FullRelease.ps1` (confirmation-token-gated) opens a version-bump PR that patch-bumps both `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json` (currently 1.0.18 → next 1.0.19) and pins the Codex MCP transports (`Invoke-FullRelease.ps1:6-27`). It never publishes; after the bump PR merges, `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` pushes the release tags and CI performs the npm publish. This matches the observed release history (commits `dbd41dee` / `904cee2a` for 1.0.18).
4. **Marketplace:** `extensions/drm-copilot/PUBLISHING.md` documents the manual `vsce`/PAT flow via `scripts/powershell/Publish-DrmCopilotExtension.ps1`. Marketplace publish updates the VS Code extension surface only; the reporting consumer uses the npm MCP server, so the npm publish path is the required delivery vehicle. Marketplace publication of the same fix can follow independently.
5. **Version-bump scope:** the bump belongs in a **separate release action** (the dedicated `Invoke-FullRelease` PR), not in this fix's diff — consistent with repository practice where release commits are isolated `release:` PRs.

## Automation Feasibility

Every step of the recommended fix and its verification within this fix's scope is automatable, for the following reasons:

- Code change, mirror update, and unit tests: plain file edits plus MCP-invocable toolchain (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) — no human interaction.
- Parity verification: `pytest` on `test_poshqc_bundled_parity.py` — no human interaction.
- Baseline/post coverage comparison: two `run_poshqc_test` runs plus artifact diff — no human interaction.
- Fail-before/pass-after integration reproduction: a `pwsh -File` invocation of the bundled entry script against an in-repo root — no human interaction (with a documented cleanup of the created `tests/artifacts/` directories).

Out-of-scope delivery steps that involve gates, classified per the required taxonomy:
- **Release version-bump PR** (`Invoke-FullRelease.ps1 -ConfirmToken yes`): the token is an explicit confirmation gate by design; the invocation itself is scriptable. Classification: **removable by scope change** — releasing is a separate action outside this fix's scope; no exception runbook is needed for the fix itself.
- **npm publish:** performed by CI after the release PR merges and tags push — automatable, out of scope here.
- **VS Code Marketplace publish** (`vsce` with PAT, interactive confirmation per `PUBLISHING.md:89-110`): third-party portal credentialing. Classification: **removable by scope change** — not required to deliver the MCP-server fix the consumer needs; if the extension surface must also ship, this step would require an exception runbook (existing runbook: `extensions/drm-copilot/PUBLISHING.md`).

No hard halt exists anywhere in the fix or its required verification.

## Recommended Approach

**Option (a): prune nonexistent coverage paths inside `Invoke-PoshQCTest`, disabling coverage (with logged explanation) when the surviving set is empty.**

- **Production surface (2 files, byte-identical):** `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (coverage-enabled block, lines 338-347, plus the `$coverageEnabled` flag) and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`. Fits the PowerShell direct-mode budget (2 production files) and per-batch cap (3+3).
- **Test surface:** new seam-injected Pester tests in `tests/scripts/powershell/PoshQC/` (extend `PoshQC.TestingInvokeConfigPaths.Tests.ps1` or add `PoshQC.TestingCoveragePruning.Tests.ps1`), scenarios per section 5; no filesystem, no temp files.
- **Justification:** it is the smallest change that makes the consumer path succeed out of the box; it uses only existing seams; it leaves this repository's coverage measurement provably unchanged (section 6); it disturbs no existing test or contract; and the alternatives either fail to fix the defect standalone (c) or endanger this repository's own coverage gates and exceed the change budget (b).

## Open Questions

1. **Scope ruling needed:** the latent `Run.Path` discovery abort for consumer repos without a scan config and with a missing default Run.Path entry (Q2) — fix here or file a new issue? Recommendation: new issue; it is a different code path (`Find-File` wildcard branch) with different empty/partial semantics, and including it would grow this fix beyond the minimal-regression pattern.
2. **Product confirmation of the empty-set behavior:** this research recommends *disable coverage + logged warning* (the only expressible, unblocking option of the three named in the delegation). The planner should encode this choice explicitly in the spec's "Design summary" so the executor does not re-litigate it.
3. **Fail-before evidence form:** confirm whether the in-repo integration reproduction (which creates and then removes `tests/artifacts/` directories) is acceptable, or whether an exception dossier citing the field evidence (`issue.md:47`) plus the deterministic unit tests should stand as the fail-before proof.
