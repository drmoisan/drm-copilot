# Research — Blast-radius PowerShell calling-convention hardening (Issue #598)

- Feature: `docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/`
- Epic: `claude-runtime-portability`, Feature A, wave 0, band C3
- Date: 2026-08-29
- Tree state: worktree `drm-copilot-wt-2026-08-29T15-07`, branched from `c861ddff`
- Scope: research only. No production or test file was modified.

## Executive Summary

1. **Q1 — The governing runtime floor for `.claude/lib/**` is PowerShell 7.4, not 5.1.** The `5.1`
   entry in `pssa.settings.psd1` belongs to `PSUseCompatibleSyntax`, which checks language syntax
   only and cannot flag a cmdlet parameter. `.claude/lib/discovery-validation/DiscoveryValidation.psm1`
   already declares and enforces a 7.4 floor in production. `-DateKind` is a 7.5 parameter and is
   therefore **above** the established floor.
2. **Q2 — Recommended boundary: all 27 `.psm1` modules under `.claude/lib/**`**, with the guard
   placed on the line immediately after each module's existing `Set-StrictMode -Version Latest`,
   plus `-ErrorAction Stop` on the 44 column-0 `Import-Module` statements in the 16 modules that
   have them. Module scope does not leak to callers; the mechanism is safe.
3. **Q3 — Only `OrchestratorState.psm1:175` is in scope.** The other two parse sites are excluded on
   evidence. The exposure there is **latent, not active**: every ISO-8601-valued checkpoint key is
   validated by presence only, and no `.claude/lib` module re-serializes the parsed checkpoint. A
   post-parse repair is provably lossy and is rejected. Two viable dispositions are presented; one
   requires an owner decision.
4. **Q4 — No gap. No new test required.**
5. **Q5 — The mirror is a manual edit-both-files obligation.** No tooling performs the repo → bundle
   copy. The parity assertion is UTF-8 text equality with universal-newline translation, and it is
   one-directional (repo → bundle).

---

## Numeric Derivation Evidence

Every numeric claim below that feeds a proposed acceptance criterion is derived twice, by two
distinct search strategies, with both member sets enumerated and compared.

### N1 — Count of `.psm1` modules under `.claude/lib/**`

- **Complete Family:** every tracked PowerShell *module* file (`.psm1`) anywhere in the
  `.claude/lib/` subtree, at any depth, in any subdirectory.
- **Exhaustive Search Scope:** the entire `.claude/lib/` subtree, recursive, no directory or depth
  filter.
- **Inclusion Rules:** file extension is exactly `.psm1`; path is under `.claude/lib/`.
- **Exclusion Rules:** `.sh`, `.ps1`, `.psd1`, and any non-file path are excluded. The bundle mirror
  under `extensions/drm-copilot/resources/claude-customizations/` is excluded from this count and
  counted separately in N2.
- **Primary Search Strategy:** filesystem enumeration — `Glob` pattern `.claude/lib/**/*.psm1`.
- **Primary Member Set:** `blast-radius/BlastRadius.psm1`, `blast-radius/BlastRadiusConfig.psm1`,
  `blast-radius/BlastRadiusExtraction.psm1`, `blast-radius/BlastRadiusGlob.psm1`,
  `blast-radius/BlastRadiusNormalization.psm1`, `blast-radius/BlastRadiusTokenShape.psm1`,
  `blast-radius/BlastRadiusValidation.psm1`, `codex-routing/CodexDeployment.psm1`,
  `codex-routing/CodexTopology.psm1`, `discovery-validation/DiscoveryValidation.psm1`,
  `hook-payload/HookPayload.psm1`, `mermaid/MermaidGrammar.psm1`,
  `mermaid/MermaidLineScanner.psm1`, `mermaid/MermaidMarkdownFences.psm1`,
  `mermaid/MermaidValidation.psm1`, `model-routing/ModelRouting.psm1`,
  `orchestrator-state/OrchestratorState.psm1`,
  `orchestrator-state/OrchestratorStateCheckpointValue.psm1`,
  `orchestrator-state/OrchestratorStateCodexModelReceipts.psm1`,
  `orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1`,
  `orchestrator-state/OrchestratorStateCompletion.psm1`,
  `orchestrator-state/OrchestratorStateCompletionChecks.psm1`,
  `orchestrator-state/OrchestratorStateModelReceipts.psm1`,
  `orchestrator-state/OrchestratorStateReceipts.psm1`,
  `orchestrator-state/OrchestratorStateRoutingContract.psm1`,
  `orchestrator-state/OrchestratorStateRoutingMatrix.psm1`,
  `orchestrator-state/OrchestratorStateUnconditional.psm1`.
- **Primary Count:** 27.
- **Cross-check Search Strategy:** committed-configuration enumeration, independent of the
  filesystem — count the `.claude/lib/<dir>/<Name>.psm1` string literals in the `CodeCoverage.Path`
  allow-list of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, via the regex
  `'\.claude/lib/[a-z-]+/[A-Za-z]+\.psm1'`.
- **Cross-check Member Set:** the allow-list entries at lines 66, 70, 71, 96, 100, 101, 102, 106,
  107, 108, 109, 110, 111, 112, 113, 163, 164, 165, 166, 167, 168, 169, 194, 195, 196, 197, 204 —
  which name, in order, `model-routing/ModelRouting.psm1`,
  `orchestrator-state/OrchestratorState.psm1`, `orchestrator-state/OrchestratorStateCompletion.psm1`,
  `discovery-validation/DiscoveryValidation.psm1`,
  `orchestrator-state/OrchestratorStateCheckpointValue.psm1`,
  `orchestrator-state/OrchestratorStateReceipts.psm1`,
  `orchestrator-state/OrchestratorStateModelReceipts.psm1`,
  `codex-routing/CodexDeployment.psm1`, `codex-routing/CodexTopology.psm1`,
  `orchestrator-state/OrchestratorStateCodexModelReceipts.psm1`,
  `orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1`,
  `orchestrator-state/OrchestratorStateRoutingMatrix.psm1`,
  `orchestrator-state/OrchestratorStateCompletionChecks.psm1`,
  `orchestrator-state/OrchestratorStateRoutingContract.psm1`,
  `orchestrator-state/OrchestratorStateUnconditional.psm1`,
  `blast-radius/BlastRadiusExtraction.psm1`, `blast-radius/BlastRadiusGlob.psm1`,
  `blast-radius/BlastRadiusConfig.psm1`, `blast-radius/BlastRadiusValidation.psm1`,
  `blast-radius/BlastRadius.psm1`, `blast-radius/BlastRadiusNormalization.psm1`,
  `blast-radius/BlastRadiusTokenShape.psm1`, `mermaid/MermaidGrammar.psm1`,
  `mermaid/MermaidLineScanner.psm1`, `mermaid/MermaidMarkdownFences.psm1`,
  `mermaid/MermaidValidation.psm1`, `hook-payload/HookPayload.psm1`.
- **Cross-check Count:** 27.
- **Member-set Comparison:** normalized to forward-slash relative paths and sorted, the two sets are
  **identical**; each contains the same 27 members with no residual on either side. The two
  strategies are independent: one reads the filesystem, the other reads a committed configuration
  file that no filesystem walk produced.

**Consequence for planning:** every module in the recommended boundary is already inside the coverage
denominator. No `pester.runsettings.psd1` change is required for any boundary this research
recommends.

### N2 — Production-file count implied by the recommended boundary

- **Complete Family:** every file an implementer must edit to place the guard, counting the
  repository copy and its mandatory bundle mirror as separate files.
- **Exhaustive Search Scope:** `.claude/lib/**` plus
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/**`.
- **Inclusion Rules:** `.psm1` files in either tree.
- **Exclusion Rules:** the 9 `.sh` files in each tree (a bash script cannot carry a PowerShell
  preference variable); test files.
- **Primary Search Strategy:** N1's filesystem enumeration of the repository tree (27), doubled by
  the mirror obligation.
- **Primary Member Set:** the 27 members of N1, plus the same 27 relative paths rooted at
  `extensions/drm-copilot/resources/claude-customizations/`.
- **Primary Count:** 54.
- **Cross-check Search Strategy:** independent enumeration of the bundle tree —
  `Glob` pattern `extensions/drm-copilot/resources/claude-customizations/.claude/lib/**/*`, then
  classify by extension.
- **Cross-check Member Set:** 36 bundle files, comprising 9 `.sh` under `bash/` and 27 `.psm1` whose
  relative paths under `.claude/lib/` are byte-for-byte the same 27 relative paths listed in N1's
  primary member set.
- **Cross-check Count:** 27 bundle `.psm1` + 27 repository `.psm1` = 54.
- **Member-set Comparison:** the bundle's 27 `.psm1` relative paths and the repository's 27 `.psm1`
  relative paths are **identical after normalization**; the union of the two rooted sets has
  cardinality 54 with no overlap. Confirms the manifest's "doubles each feature's touched-file
  count" claim for this specific surface.

### N3 — JSON-deserialization call sites under `.claude/lib/**`

- **Complete Family:** every executable statement under `.claude/lib/**` that deserializes serialized
  text into a PowerShell object graph — the complete family of such mechanisms available to a
  PowerShell 7.x module, not the single `ConvertFrom-Json` cmdlet name.
- **Exhaustive Search Scope:** all 36 files under `.claude/lib/**` (27 `.psm1` + 9 `.sh`), full text.
- **Inclusion Rules:** the statement must execute and must produce a deserialized object whose
  member values could be subject to type coercion.
- **Exclusion Rules:** occurrences inside comment-based help, inline comments, or prose (they do not
  execute). `Test-Json` is excluded because it returns a `[bool]` verdict and produces no object, so
  it cannot coerce a value.
- **Primary Search Strategy:** literal cmdlet-name search for `ConvertFrom-Json` across
  `.claude/lib/**`, with every one of the 10 matched lines individually read and classified as
  *call* or *comment* by reading the surrounding function body.
- **Primary Member Set:** calls — `hook-payload/HookPayload.psm1:262`
  (`$envelope = $text | ConvertFrom-Json -ErrorAction Stop`),
  `orchestrator-state/OrchestratorState.psm1:175`
  (`$state = $raw | ConvertFrom-Json -ErrorAction Stop`),
  `discovery-validation/DiscoveryValidation.psm1:338`
  (`$parsed = ConvertFrom-Json -InputObject $Text -Depth 100 -ErrorAction Stop`).
  Classified as comments and excluded — `HookPayload.psm1:253`, `HookPayload.psm1:334`,
  `OrchestratorStateCheckpointValue.psm1:41`, `OrchestratorState.psm1:163`,
  `BlastRadiusConfig.psm1:26`, `BlastRadiusConfig.psm1:147`, `BlastRadiusConfig.psm1:175`.
- **Primary Count:** 3.
- **Cross-check Search Strategy:** family-exhaustive alternation over every PowerShell 7.x JSON /
  structured-text deserialization entry point, deliberately naming mechanisms the primary query
  could not match —
  `ConvertFrom-StringData|Import-PowerShellDataFile|System\.Text\.Json|Newtonsoft|Test-Json|ConvertFrom-Yaml|ConvertFrom-Json|JavaScriptSerializer|DataContractJsonSerializer`
  across `.claude/lib/**`.
- **Cross-check Member Set:** 21 matched lines. Executable deserializing statements —
  `HookPayload.psm1:262`, `OrchestratorState.psm1:175`, `DiscoveryValidation.psm1:338`. One
  executable but non-deserializing statement, excluded by the stated exclusion rule —
  `DiscoveryValidation.psm1:362` (`Test-Json -Json $Text -SchemaFile ...`, returns `[bool]`). The
  remaining 17 lines are comment-based help or inline comments. **Zero** occurrences of
  `System.Text.Json`, `Newtonsoft`, `ConvertFrom-StringData`, `Import-PowerShellDataFile`,
  `ConvertFrom-Yaml`, `JavaScriptSerializer`, or `DataContractJsonSerializer` anywhere in the
  subtree.
- **Cross-check Count:** 3.
- **Member-set Comparison:** the primary and cross-check member sets are **identical** —
  `{HookPayload.psm1:262, OrchestratorState.psm1:175, DiscoveryValidation.psm1:338}`. The cross-check
  additionally establishes exhaustiveness over the deserialization family: no alternative
  deserializer exists in the subtree, so the primary's single-cmdlet query is not under-inclusive.

### N4 — `$ErrorActionPreference` occurrences under `.claude/lib/**`

- **Complete Family:** every mechanism by which a PowerShell file can set the effective error
  preference for its own scope — the preference variable in any scope-modifier form, the
  `$PSDefaultParameterValues` route, and the `Set-Variable` route.
- **Exhaustive Search Scope:** all 36 files under `.claude/lib/**`.
- **Inclusion Rules:** any assignment or mutation of the effective error preference.
- **Exclusion Rules:** per-call `-ErrorAction` common-parameter uses, which are call-scoped and are
  counted separately in the Q2 findings; `.claude/hooks/**`, which is outside the declared scope and
  is reported separately.
- **Primary Search Strategy:** literal token search for `ErrorActionPreference` across `.claude/`,
  then partition the results by directory.
- **Primary Member Set:** under `.claude/lib/**` — **empty**. Under `.claude/hooks/**` —
  `validate-executor-output.ps1:33`, `validate-planner-output.ps1:35`,
  `validate-task-researcher-output.ps1:24`, `validate-required-artifact-output.ps1:32`,
  `validate-orchestrator-output.ps1:39`, `validate-feature-review-coverage.ps1:39` (6 files, all
  `= 'Stop'`).
- **Primary Count:** 0 under `.claude/lib/**`; 6 files under `.claude/hooks/**`.
- **Cross-check Search Strategy:** family-exhaustive alternation over the five distinct
  error-preference-setting mechanisms, deliberately naming routes the literal token query would miss
  —
  `PSDefaultParameterValues|Set-Variable[^\n]*ErrorAction|ErrorActionPreference|\$global:ErrorAction|\$script:ErrorAction`
  across `.claude/lib/**`.
- **Cross-check Member Set:** **empty** — 0 occurrences across 0 files.
- **Cross-check Count:** 0.
- **Member-set Comparison:** both member sets for `.claude/lib/**` are the **empty set**; they agree.
  The cross-check makes the zero exhaustive over the mechanism family rather than over one token, so
  the claim "no module under `.claude/lib/**` establishes a fail-fast error preference by any means"
  is supported, not merely "no module contains the string `ErrorActionPreference`".

### N5 — Load-time (column-0) `Import-Module` statements under `.claude/lib/**`

- **Complete Family:** every `Import-Module` statement in a `.claude/lib` module, in every position —
  module-root (load-time), inside a function body (call-time), and in prose.
- **Exhaustive Search Scope:** all 27 `.psm1` files under `.claude/lib/**`.
- **Inclusion Rules for the reported figure:** the statement starts at column 0, i.e. it is a
  module-root statement that executes during `Import-Module` of the containing module. These are the
  statements the issue calls "the shared module IMPORT PATH".
- **Exclusion Rules:** indented occurrences (inside a function body, which execute at call time, not
  load time) and occurrences in comments.
- **Primary Search Strategy:** column-0-anchored form search over the two argument shapes used in
  this subtree — `^Import-Module \(Join-Path|^Import-Module \$script:`.
- **Primary Member Set:** `BlastRadius.psm1` ×5, `BlastRadiusConfig.psm1` ×2,
  `BlastRadiusExtraction.psm1` ×2, `BlastRadiusValidation.psm1` ×4,
  `BlastRadiusNormalization.psm1` ×3, `MermaidLineScanner.psm1` ×1, `MermaidValidation.psm1` ×3,
  `OrchestratorStateCodexModelReceipts.psm1` ×2, `OrchestratorStateCompletion.psm1` ×7,
  `OrchestratorStateCodexTopologyReceipts.psm1` ×2, `OrchestratorStateReceipts.psm1` ×1,
  `OrchestratorStateCompletionChecks.psm1` ×2, `OrchestratorStateUnconditional.psm1` ×5,
  `OrchestratorStateRoutingContract.psm1` ×2, `OrchestratorStateRoutingMatrix.psm1` ×1,
  `OrchestratorStateModelReceipts.psm1` ×2.
- **Primary Count:** 44 statements across 16 modules.
- **Cross-check Search Strategy:** unanchored whole-family token count of `Import-Module` across
  `.claude/lib/**` (which necessarily includes every excluded position), then reconcile the
  difference by reading each excluded occurrence.
- **Cross-check Member Set:** 47 occurrences across 17 files. The 17th file is
  `OrchestratorState.psm1`, whose two occurrences are both excluded: line 427 (indented, inside a
  function body) and line 479 (prose in a comment). The third excluded occurrence is
  `OrchestratorStateUnconditional.psm1:91` (indented, inside a function body), which is why that
  file shows 6 in the unanchored count and 5 in the anchored count.
- **Cross-check Count:** 47 total − 3 excluded = 44.
- **Member-set Comparison:** the two derivations reconcile **exactly** on both axes. Statements:
  44 = 47 − 3, with all three exclusions individually named and individually classified. Files:
  16 modules with at least one column-0 statement, plus `OrchestratorState.psm1` whose only two
  occurrences are excluded, equals the 17 files the unanchored query reports.

### N6 — ISO-8601-valued keys in the live orchestrator checkpoint

- **Complete Family:** every key in `artifacts/orchestration/orchestrator-state.json` whose **value**
  is a string that Json.NET's default date handling would parse as a date, at any nesting depth.
- **Exhaustive Search Scope:** the whole file, 258 lines.
- **Inclusion Rules:** the value is a standalone ISO-8601 instant.
- **Exclusion Rules:** a string that merely *contains* an ISO-8601-like substring inside a longer
  non-date value. Such a value does not parse as a date and is not coerced.
- **Primary Search Strategy:** key-name search — regex
  `"(last_updated|started_at|completed_at|verified_at|computed_at|created_at|[a-z_]*_at)"\s*:`.
- **Primary Member Set:** line 42 `last_updated`; line 52 `model_routing_preflight.checked_at`;
  lines 63, 71, 79, 87 `complexity_assessments[].assessed_at`.
- **Primary Count:** 6 value-carrying occurrences, across 3 distinct key names.
- **Cross-check Search Strategy:** value-shape search, independent of key naming — regex
  `\d{4}-\d{2}-\d{2}T\d{2}` over the same file. This catches a date-valued key whose name does not
  end in `_at`, which the primary query would miss.
- **Cross-check Member Set:** lines 32, 42, 52, 63, 71, 79, 87. Line 32 is
  `"plan-path": "docs/.../plan.2026-08-29T16-05.md"`, excluded by the stated exclusion rule: the
  value is a file path and the embedded `2026-08-29T16-05` uses a hyphenated time separator that is
  not an ISO-8601 instant, so the whole string does not parse as a date.
- **Cross-check Count:** 7 matched lines − 1 excluded = 6.
- **Member-set Comparison:** after applying the exclusion rule the two member sets are **identical**
  — `{42, 52, 63, 71, 79, 87}`. The cross-check further establishes that no differently-named
  date-valued key exists in the file, so the primary's key-name query is not under-inclusive.
- **Contract extension (not present in this instance but reachable):** two further ISO-8601-valued
  key families are declared by the module constants and would appear in a richer checkpoint —
  `delegation_receipts.agents[].started_at` and `.completed_at`
  (`OrchestratorStateReceipts.psm1:46-47`) and `ci_gate.verified_at`
  (`OrchestratorStateCompletionChecks.psm1:70`). This is a contract observation from the module
  constants, not a count from this file instance.

---

## Q1 — The minimum supported PowerShell version for `.claude/lib/**`

**Conclusion: the effective floor is PowerShell 7.4. The `5.1` target is a syntax-compatibility
target only and has never constrained runtime behavior. `-DateKind` (7.5) is above the established
floor; `-AsHashtable` (6.0) and `-Depth` (6.2) are below it.**

### Evidence

**E1 — Every invocation path is `pwsh`.** All 36 hook command entries in `.claude/settings.json` are
of the form `pwsh -NoProfile -File .claude/hooks/<name>.ps1` (for example lines 84, 95, 99, 103, 107,
… 265). There is no `powershell -File` or `powershell.exe` entry anywhere in the file. On Windows,
`pwsh` is the PowerShell 6+/7+ executable and Windows PowerShell 5.1 is `powershell.exe`; the two are
distinct binaries. No `.claude/lib` module is loaded by a 5.1 host on the hook path.

**E2 — CI executes under `pwsh`.** `.github/workflows/_poshqc.yml` runs on `windows-latest` and every
step declares `shell: pwsh` (lines 17, 23, 33, 39). The Pester suite that exercises these modules is
step "Test PowerShell" at lines 38-42.

**E3 — `.claude/lib` already contains a parameter that does not exist on 5.1, and CI is green.**
`.claude/lib/discovery-validation/DiscoveryValidation.psm1:338` calls
`ConvertFrom-Json -InputObject $Text -Depth 100 -ErrorAction Stop`. Per the `ConvertFrom-Json`
reference, "`-Depth` … This parameter was introduced in PowerShell 6.2." Windows PowerShell 5.1's
`ConvertFrom-Json` has no `-Depth`. This statement is on `main` and passes the PoshQC analyze gate.

**E4 — `PSUseCompatibleSyntax` cannot flag a cmdlet parameter, and no rule in this repository can.**
`scripts/powershell/PoshQC/settings/pssa.settings.psd1:8-12` enables exactly one compatibility rule:

```powershell
PSUseCompatibleSyntax = @{
    Enable         = $true
    TargetVersions = @('5.1', '7.6')
    IgnoreUntested = $false
}
```

The Microsoft rule reference for `UseCompatibleSyntax` states: "This rule detects **syntax elements**
that aren't compatible with your specified PowerShell target versions," and its noncompliant example
is the ternary and null-coalescing operators. Parameter availability is the domain of
`PSUseCompatibleCommands`, whose reference states "**Default state: Disabled**" and which requires an
explicit `TargetProfiles` list. A repository-wide search for `PSUseCompatible` returns exactly two
occurrences — `pssa.settings.psd1:8` and its bundle mirror at
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pssa.settings.psd1:8` — both
`PSUseCompatibleSyntax`. `PSUseCompatibleCommands`, `PSUseCompatibleCmdlets`, and
`PSUseCompatibleTypes` are configured nowhere. This is precisely why E3's `-Depth 100` passes.

**E5 — A 7.4 floor is already declared, enforced, and tested inside `.claude/lib/**`.**
`.claude/lib/discovery-validation/DiscoveryValidation.psm1:71` sets
`$script:MinimumPowerShellVersion = [version]'7.4'`. `Get-DiscoveryRuntimeVersionError` (lines
78-116) is a fail-closed guard with an injectable, read-only `-PowerShellVersion` seam defaulting to
`$PSVersionTable.PSVersion` (line 102) that runs before any schema work (invoked at line 330). The
module's comment-based help states the floor as a destination-visible requirement (lines 11-19) and
explicitly records the divergence: "The repo standard in `.claude/rules/powershell.md` is
'PowerShell 7+', which is below this floor; that rule file is NOT modified by this change." The guard
is pinned by `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1`,
and the two consuming hooks restate the requirement
(`.claude/hooks/enforce-discovery-artifact-gate.ps1:28`,
`.claude/hooks/validate-discovery-artifact-gate.ps1:31`).

**E6 — CI must be on 7.5 or later.** `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:318`
calls `ConvertFrom-Json -AsHashtable -DateKind String` unguarded, inside a `BeforeAll` block, with the
explanatory comment at lines 314-316. That file is under `tests/scripts`, which is inside the Pester
`Run.Path` (`pester.runsettings.psd1:3`). On a pre-7.5 host this would fail with a
parameter-not-found error. Since the file is on `main` and the PoshQC gate is required, the CI host's
`pwsh` is 7.5 or later. `DiscoveryValidation.psm1:14` separately records "Verified present in
PowerShell 7.6.3 in this environment."

**E7 — Consumer repositories do NOT guarantee any PowerShell version.**
`extensions/drm-copilot/src/runtime-detection.ts:244-283` prefers `pwsh` and, when absent, falls back
to `powershell` (Windows PowerShell), documented at lines 232-233 as "`\"powershell\"` resolves
PowerShell Core (`pwsh`) then Windows PowerShell (`powershell`)". Nothing in the push-down pipeline
probes or asserts a destination PowerShell version. The repository's established answer to that gap
is E5's pattern: a fail-closed in-module version check with an actionable message, not a silent
degradation and not a build-time assertion.

### The contradiction, and what remains open

The practical question — *does the 5.1 leg govern the runtime behavior of `.claude/lib/**`?* — is
**resolved by evidence: no.** E1–E4 together establish that no execution path uses 5.1 and that the
5.1 target has never been enforced against cmdlet parameters.

The *declaratory* question — *what floor should the repository state?* — is **an open product
decision that cannot be closed from evidence.** The repository holds an explicit, unresolved decision
record: `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md:53-84`, Residual 2,
which ends "decide whether the repository standard in `.claude/rules/powershell.md` should be raised
to 7.4+, or whether destination-side tooling should detect and report the floor ahead of hook
execution rather than at hook-execution time." That entry has not been promoted.

Options and consequences for Feature A:

| Option | Consequence |
| --- | --- |
| **Adopt 7.4 as the working floor for this feature** (recommended) | No rule-file or PSSA change. Consistent with the only in-tree production floor declaration. `-DateKind` is unavailable. `-AsHashtable` and `-Depth` are available. |
| Raise `.claude/rules/powershell.md:24` to 7.4 | Closes Residual 2's first branch, but `.claude/rules/**` is a policy surface; the PoshQC `5.1` syntax target is a *separate* setting and would remain, so this does not by itself unlock `-DateKind`. Out of Feature A's declared scope. |
| Raise the working floor to 7.5 to unlock `-DateKind` | Discussed in Q3. Regresses destination compatibility for PowerShell 7.0–7.4 hosts on the orchestrator-state hook family. Requires an owner decision. |
| Remove `'5.1'` from `TargetVersions` | Would relax an existing gate. Not required by anything in this feature and would reduce, not increase, enforcement. Recommended against. |

**Recommendation: treat 7.4 as the floor. Do not modify `pssa.settings.psd1` or
`.claude/rules/powershell.md` in this feature.** The `5.1` syntax target is harmless and continues to
provide value: it will reject PowerShell-7-only *syntax* (ternary, `??`, `&&`/`||`) in these modules,
which is a real constraint on any implementation the planner authors.

---

## Q2 — Scope boundary for the fail-fast import guard

**Recommendation: option (b), all 27 `.psm1` modules under `.claude/lib/**`, applied as a two-part
guard.**

### Mechanism semantics, established from documentation

**M1 — A module-root variable is visible to that module's functions and does not leak to the
caller.** `about_Scopes` states: "Functions from a module don't run in a child scope of the calling
scope. Modules have their own session state that's linked to the scope in which the module was
imported. All module code runs in a module-specific hierarchy of scopes that has its own root
scope." Its worked example defines `$a = "Hello"` at a module's root and a module function that
prints both `$a` and `$Global:a`; with a caller-side `$a = "Goodbye"` the function reports
`$a = Hello` and `$Global:a = Goodbye`. `about_Preference_Variables` adds: "Changes to preference
variables apply only in the scope they are made and any child scopes thereof."

Consequence: `$ErrorActionPreference = 'Stop'` at a `.psm1` root governs (i) the module's own
load-time statements that follow it and (ii) the module's exported functions when they run. It does
**not** change the caller's `$ErrorActionPreference`. The concern that the guard "leaks to callers"
is not supported by the documentation; the leak is in the opposite direction and is what module
session-state isolation prevents.

**M2 — Inheritance from a *loader* module to a separately-imported sibling is not established.**
`about_Scopes` also says "If you load **Module2** from *within* **Module1**, **Module2** is loaded
into the scope container of Module1," while simultaneously saying each module has "its own root
scope." These two statements do not jointly determine whether a variable set at Module1's root is
resolvable from inside a Module2 function. **This could not be settled from documentation, and no
PowerShell execution was available in this session to settle it empirically.** Any design that
depends on that inheritance is therefore unproven. This is the decisive argument against a shared
bootstrap/loader module.

**M3 — What `$ErrorActionPreference = 'Stop'` actually changes.** It promotes *non-terminating*
cmdlet errors to terminating errors within the governed scope. It does not affect exceptions from
.NET method calls (already terminating), native-executable exit codes, or errors raised inside
*another* module's functions (which resolve their own preference from their own module scope). This
bounds the behavioral risk: adding the guard to module X cannot change the error behavior of module
Y's functions.

**M4 — `Set-StrictMode` is complementary, not an alternative.** It governs uninitialized-variable
reads, non-existent property reads, and improper function-call syntax. It has no effect on
non-terminating cmdlet errors. All 27 modules already carry `Set-StrictMode -Version Latest` at
module root (verified: 27 distinct `.psm1` files matched, one occurrence each at the module root —
`BlastRadiusValidation.psm1:35`, `BlastRadiusExtraction.psm1:38`, `BlastRadiusTokenShape.psm1:54`,
`BlastRadius.psm1:52`, `BlastRadiusConfig.psm1:33`, `BlastRadiusNormalization.psm1:32`,
`BlastRadiusGlob.psm1:36`, `OrchestratorStateUnconditional.psm1:42`,
`OrchestratorStateRoutingMatrix.psm1:38`, `OrchestratorStateRoutingContract.psm1:50`,
`OrchestratorStateReceipts.psm1:32`, `OrchestratorStateModelReceipts.psm1:24`,
`OrchestratorStateCompletionChecks.psm1:38`, `OrchestratorStateCompletion.psm1:49`,
`OrchestratorStateCodexTopologyReceipts.psm1:30`, `OrchestratorStateCodexModelReceipts.psm1:27`,
`OrchestratorStateCheckpointValue.psm1:28`, `OrchestratorState.psm1:32`, `ModelRouting.psm1:23`,
`HookPayload.psm1:42`, `DiscoveryValidation.psm1:54`, `MermaidGrammar.psm1:33`,
`MermaidLineScanner.psm1:35`, `MermaidMarkdownFences.psm1:37`, `MermaidValidation.psm1:42`,
`CodexTopology.psm1:52`, `CodexDeployment.psm1:41`). **The guard is the missing sibling of an
already-uniform line, in the same position, in every file.**

### What "fail-fast on the shared module IMPORT PATH" means concretely

The import path is the set of 44 column-0 `Import-Module` statements in 16 modules (N5). Every one of
them is of the form `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '<Sibling>.psm1') -Force`
or `Import-Module $script:<Path> -Force`, and **not one carries `-ErrorAction`**. A missing or
unreadable sibling makes `Import-Module` write a non-terminating error; under the default
`$ErrorActionPreference = 'Continue'` the outer module's load script continues, the outer module
finishes importing, and its exported functions then fail later with an unrelated
command-not-recognized error. That is the "continue silently instead of surfacing" behavior the issue
describes, and it is a real, currently-reachable path: `BlastRadius.psm1` alone imports five
siblings (lines 54-58), and the `parallel-plan` skill's documented entry point is exactly
`Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` (`SKILL.md:183`).

Two guards address it, and they are complementary:

- **Guard A — statement-scoped.** Add `-ErrorAction Stop` to each of the 44 column-0 `Import-Module`
  statements. Provably correct regardless of M2's unresolved inheritance question, and it changes
  nothing about any function's error semantics. This is the narrow, literal fix for "the import
  path".
- **Guard B — module-scoped.** Add `$ErrorActionPreference = 'Stop'` on the line after each module's
  existing `Set-StrictMode -Version Latest`. This covers Guard A's cases *and* the issue's second
  half ("an internal module failure surfaces as a terminating error"). Because it must be placed
  *before* the module's `Import-Module` block to cover the import path, its position is fixed and
  reviewable.

Both are recommended, in the same edit, in the same file. In the 16 modules that have imports they
are one contiguous edit; in the other 11 only Guard B applies.

### Boundary evaluation

**Option (a) — the 7 `.claude/lib/blast-radius/*.psm1` modules only. Rejected.** It is incoherent
with the feature's own second work item: the date-coercion work targets
`.claude/lib/orchestrator-state/OrchestratorState.psm1`, which option (a) excludes. It would also
make the issue's Expected Behavior #1 ("Import any module under `.claude/lib/**` …") false as
written. And it excludes 9 of the 16 modules that actually have an unguarded import path.

**Option (b) — all 27 `.psm1` modules. Recommended.** Justification:

1. **Uniformity is the existing house pattern and the only verifiable AC shape.** 27 of 27 modules
   carry `Set-StrictMode -Version Latest` at module root. An acceptance criterion of the form "every
   `.psm1` under `.claude/lib/**` sets `$ErrorActionPreference = 'Stop'` at module scope" is
   mechanically verifiable by a single Pester assertion that discovers the modules from disk — the
   exact shape already used by `BlastRadius.Manifest.Tests.ps1:27-31`, which discovers modules with
   `Get-ChildItem -Filter '*.psm1'` rather than restating them "so a future module cannot be added
   without also being listed". A partial boundary admits no such assertion.
2. **The blast radius of the change is bounded by M3.** Adding the preference to module X cannot
   alter module Y's function behavior, so the 27 edits are 27 independent changes, not one coupled
   change.
3. **No coverage-configuration work.** All 27 are already in `CodeCoverage.Path` (N1 cross-check).
4. **No new files.** A new shared file would require a `core.json` pack-manifest entry, a bundle
   copy, and updates to the four `*.Manifest.Tests.ps1` suites that assert manifest membership and
   bundled-counterpart existence.

**Option (c) — a shared bootstrap/loader module. Rejected.** Two independent reasons: (i) M2 — the
documentation does not establish that a loader's module-scope preference is inherited by a
separately-imported sibling's functions, so the mechanism is unproven; (ii) it adds a new file with
the manifest, bundle, and manifest-test costs listed above, in exchange for saving edits in files
that must be visited anyway for Guard A.

**Option (d) — `-ErrorAction Stop` at the caller's `Import-Module` call sites only. Out of scope and
insufficient.** Those three call sites
(`.claude/skills/parallel-plan/SKILL.md:183`, `.claude/skills/parallel-add/SKILL.md:62`,
`.claude/agents/parallel-planner.md:151`) belong to Feature C and were not modified or examined for
change here. Even if corrected, they would only guard the *outermost* import; the 44 intra-library
sibling imports would remain unguarded. **What Feature A must establish so Feature C has something to
apply:** the convention statement itself — "a `.claude/lib` module import is `-ErrorAction Stop`; a
`.claude/lib` module sets `$ErrorActionPreference = 'Stop'` at module scope" — recorded in the
modules' own comment-based help so it is destination-visible, matching how `DiscoveryValidation.psm1`
records its version floor.

### Batching cost, stated plainly

54 production files (N2). At the `.claude/rules/powershell.md:40` per-batch cap of 3 production files,
that is **18 batches**. Each batch is a 1-to-6 line edit in one repository module plus the identical
edit in its bundle mirror.

The planner should consider requesting an explicit per-batch override for the bundle-mirror half. The
mirror is a byte-copy with no independent review surface, and its correctness is machine-checked by
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Counting 27 repository files
against the cap and treating the 27 mirrors as a mechanical obligation of the same batch yields
**9 batches**. `.claude/rules/powershell.md:40` permits this: "at most 3 production files and 3 test
files **unless an explicit override has been approved**." Requesting the override is a planning
decision, not a research finding; without it, plan for 18.

---

## Q3 — Parse sites and the date-coercion guard

### Site-by-site disposition

**`OrchestratorState.psm1:175` — IN SCOPE.**
`$state = $raw | ConvertFrom-Json -ErrorAction Stop`, inside `Get-OrchestratorStateCheckpoint`
(lines 125-195). The parsed object is the orchestrator checkpoint and is returned to callers as
`@{ Ok = $true; State = $state; Error = '' }` (line 194), crossing the module boundary into all 11
`orchestrator-state` modules and the hook surface. The ISO-8601-valued keys in the live checkpoint
are the six enumerated in N6, plus the two contract-declared families
(`delegation_receipts.agents[].started_at` / `.completed_at`; `ci_gate.verified_at`).

**`HookPayload.psm1:262` — OUT OF SCOPE.**
`$envelope = $text | ConvertFrom-Json -ErrorAction Stop`, inside `ConvertFrom-ClaudeHookEnvelope`
(lines 224-272). The parsed object is the Claude hook envelope. The module names exactly one payload
key constant, `$script:ToolInputKey = 'tool_input'` (line 52); everything else is read through the
generic `Get-ClaudeHookEnvelopeValue` accessor (lines 304+) by consumers requesting `tool_name`,
`file_path`, `content`, `command`, and `session_id`. None is ISO-8601-valued. The one path by which a
checkpoint could reach this parser is a `Write` payload whose `tool_input.content` is checkpoint JSON
text — but that arrives as a JSON *string* holding a whole JSON document, which does not parse as a
date and is therefore not coerced. **Exclusion justification: no ISO-8601-valued key is read from
this parse, and the checkpoint-in-payload case is provably not a coercion case.**

**`DiscoveryValidation.psm1:338` — OUT OF SCOPE.**
`$parsed = ConvertFrom-Json -InputObject $Text -Depth 100 -ErrorAction Stop`, inside
`Get-DiscoverySchemaArtifactValidationError` (lines 303+). The parsed object is used for exactly two
things: an `-isnot [System.Management.Automation.PSCustomObject]` root-shape check (line 345) and
reading the `$schema` property (lines 350-351). The actual schema validation runs against the **raw
text**, not the parsed object: `Test-Json -Json $Text -SchemaFile ...` (line 362). No value is read
from `$parsed` other than `$schema`, which is a URI, not a date. **Exclusion justification: the
coercion is unobservable at this site because no date-valued field is ever read from the parsed
object.**

### The exposure at the in-scope site is latent, not active

This is a material finding that should shape the acceptance criteria.

- Every ISO-8601-valued checkpoint key is validated by **presence only**. `REQUIRED_STATE_KEYS`
  (`OrchestratorState.psm1:36-59`, including `last_updated` at line 50) is checked for key presence.
  `REQUIRED_RECEIPT_KEYS` (`OrchestratorStateReceipts.psm1:41-50`, including `started_at` and
  `completed_at`) is checked with the explicit comment at lines 103-104: "Key PRESENCE is the Python
  test (`key not in receipt`), so a present key holding null satisfies the requirement."
  `CI_GATE_KEYS` (`OrchestratorStateCompletionChecks.psm1:70`, including `verified_at`) is checked
  via `Get-MissingGateKey` at line 275. Presence is unaffected by the value's runtime type.
- **No `.claude/lib` module re-serializes the parsed checkpoint.** A search for `ConvertTo-Json`,
  `Set-Content`, and `Out-File` across `.claude/lib/**` returns **zero** occurrences. There is no
  read-modify-write path in the library by which a coerced `[datetime]` could be written back in a
  different format.
- The one mechanism that *would* misfire on a type divergence is
  `Test-PythonValueEqual` (`OrchestratorStateCheckpointValue.psm1:213-292`). Lines 256-258 read: if
  either side is a `[string]` and the other is not, return `$false`. A `[datetime]` compared against
  an expected string would silently produce a wrong "mismatch" verdict. **No `*_at` key is currently
  routed through it** — the values compared today are `conclusion`, `head_sha`, and the model- and
  Codex-routing scalars. The mechanism is real; the exposure is future, not present.
- The producer side is also silently permissive: `Get-BlastRadius` and
  `Get-BlastRadiusFromObservedPaths` both declare `[string] $ComputedAt`
  (`BlastRadius.psm1:158-160` and `324-326`). PowerShell parameter binding would coerce a
  `[datetime]` argument to a string using the current culture's default `ToString()`, producing a
  locale-dependent value in the radius record with no error. That is a second, distinct silent path
  and is worth naming in the spec even though no in-repo caller exercises it.

### Guard mechanisms evaluated against the 7.4 floor

**`-DateKind String` — the only lossless mechanism, but it requires 7.5.** The `ConvertFrom-Json`
reference states "This parameter was introduced in PowerShell 7.5," with `String` documented as
"Preserves the value the `[string]` instance." Above the Q1 floor.

**Post-parse repair (`[datetime]` back to a string) — REJECTED, provably lossy.** The reference's
NOTES define `Default` handling: a string with no zone becomes an *unspecified* time; a trailing `Z`
becomes a *UTC* value; and "If the timestamp includes a UTC offset like `+02:00`, the offset is
converted to the caller's configured time zone. **The default output formatting doesn't indicate the
original time zone offset.**" Two independent losses follow:

1. *Offset destroyed.* For a value such as `2026-08-29T16:06:23-04:00`, the original offset is not
   recoverable from the resulting `[datetime]`. Any repair would emit a different, though
   instant-equivalent, literal — and for a consumer doing an ordinal string comparison (which
   `Test-PythonValueEqual` does, line 258) that is a changed value.
2. *Format not restored even in the round-trippable case.* The live checkpoint's
   `"2026-08-29T20:06:23Z"` parses to a UTC `[datetime]`; `ToString('o')` yields
   `2026-08-29T20:06:23.0000000Z`, which is not the original literal.

A repair helper would therefore **silently change values** — a worse failure mode than the coercion
it purports to fix. Do not adopt it.

**A pre-parse text transform — REJECTED.** Escaping date-shaped string values before parsing requires
a JSON-aware rewrite of arbitrary nested values, i.e. writing a JSON parser to avoid using one.

**A non-coercing parser (`[System.Text.Json.JsonDocument]::Parse`) — REJECTED for this feature.**
Available on every PowerShell 7.x host and it never coerces. But it returns `JsonElement`, not
`PSCustomObject`, which breaks `Get-OrchestratorStateCheckpoint`'s documented output contract
(`OrchestratorState.psm1:137-141`) and its root-shape assertion at line 186, and would require
rewriting every accessor in `OrchestratorStateCheckpointValue.psm1` and its 10 dependants. That is a
far larger change than a C3 Feature A.

**A version-adaptive splat (use `-DateKind String` when the host is ≥ 7.5, otherwise not) —
REJECTED.** The same checkpoint would yield `[string]` on one host and `[datetime]` on another. A
host-dependent value contract is precisely the `cross_module_contract_change` risk this feature is
banded C3 for, and it is worse than either consistent branch.

**A fail-closed type assertion (detect and reject a coerced value) — REJECTED.** Under `Default`
handling the coercion is *unconditional* for a well-formed ISO-8601 value, so such an assertion would
fail on every real checkpoint, blocking every hook. It is not a guard; it is an outage.

### Recommended disposition, and the decision it requires

**Primary recommendation — adopt `-DateKind String` at `OrchestratorState.psm1:175` and declare a
7.5 floor for that entry point, using the established house pattern.** Concretely: a module-scoped
`$script:MinimumPowerShellVersion = [version]'7.5'` constant, a fail-closed
`Get-OrchestratorStateRuntimeVersionError` modelled line-for-line on
`Get-DiscoveryRuntimeVersionError` (`DiscoveryValidation.psm1:78-116`) with an injectable read-only
`-PowerShellVersion` seam, invoked before the parse, a destination-visible statement of the floor and
its reason in the module's comment-based help, and a dedicated Pester suite modelled on
`DiscoveryValidation.VersionFloor.Tests.ps1`.

Why this and not the alternatives: it is the only mechanism that makes the parsed value a `[string]`
without changing it, without a host-dependent contract, and without rewriting the object model across
11 modules. The repository already has the exact precedent for declaring a `.claude/lib` destination
floor above `.claude/rules/powershell.md`, including the guard shape, the seam, the help statement,
and the test.

**The consequence that requires an owner decision.** A destination on PowerShell 7.0–7.4 would have
every hook that calls `Get-OrchestratorStateCheckpoint` fail closed. That is a materially larger
destination-compatibility regression than issue #475's, which affected two discovery-gate hooks;
`Get-OrchestratorStateCheckpoint` is on the path of the whole orchestrator-state enforcement family.
PowerShell 7.4 is the current LTS, so a 7.4 destination is a realistic configuration, and the
repository holds an *open, unresolved* decision on exactly this class of question
(`docs/features/potential/2026-08-15-portable-hook-validation-residuals.md:82-84`). Trading a
working-for-7.4 hook surface for a fix to a **latent** divergence is a judgement call, not a
technical one.

**Fallback if the owner declines to raise the floor — scope item 2 to a documented, tested contract
with no behavioral change.** Record in `OrchestratorState.psm1`'s comment-based help that
`Get-OrchestratorStateCheckpoint` returns ISO-8601-valued keys as `[datetime]` under the default
`ConvertFrom-Json` date handling; name the affected keys (N6's three key names plus the two
contract-declared families); state that all current validations are presence-only so the coercion is
unobservable today; state the two future exposures (`Test-PythonValueEqual`'s string/non-string
mismatch at `OrchestratorStateCheckpointValue.psm1:256-258`, and `[string] $ComputedAt` binding
coercion at `BlastRadius.psm1:158-160` / `324-326`); and add a Pester test that pins the coercion so
a future consumer assuming `[string]` fails at development time rather than in a consumer repository.
Cost: 1 repository module + 1 mirror + 1 test file. This is honest, cheap, and regresses nothing.

---

## Q4 — Does the existing truthiness test pair leave a gap?

**No gap. No new test is required.**

Both artifacts are present at the cited lines and were re-read against the current tree:

- `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-108` — `It 'is
  unconditionally truthy even when its conflict key is false'`. It arranges two provably disjoint
  radii, evaluates the relation, computes `$coerced = [bool]$result`, and asserts **both halves in
  one `It`**: `$result['conflict'] | Should -BeFalse` (line 106) and `$coerced | Should -BeTrue`
  (line 107). The comment at lines 94-95 records why both halves live in one `It`: "a test asserting
  only one half would keep passing while the other drifted."
- `BlastRadius.Conflict.Tests.ps1:110-118` — `It 'documents the truthiness divergence in its
  comment-based help'`. It reads rendered help via `Get-Help -Full | Out-String -Width 500` (line
  114, width-pinned so console width cannot wrap the literal) and asserts the presence of `*the
  conflict key of the returned hashtable*` (line 117).
- `.claude/lib/blast-radius/BlastRadius.psm1:432-441` — the warning text is present verbatim,
  including "Read the verdict from the conflict key of the returned hashtable" (432), "Do not test
  the returned object itself" (433), and the `'if ($result)'` example (435).

Considered and rejected as gaps:

- *The converse case (a genuine conflict, where `[bool]$result` and `$result['conflict']` are both
  `$true`).* The divergence is observable only in the false case; asserting agreement in the true
  case pins nothing, and `$result['conflict']` being `$true` for contending pairs is already covered
  extensively from line 122 onward. A test here would be the duplicate the prompt asks me not to
  recommend.
- *Help-text wording latitude.* The assertion pins one substring, not the whole paragraph. That is
  intentional latitude, not an uncovered behavior.
- *The bundle mirror's copy of the help text.* Covered by
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which asserts content equality
  for every `.claude/**` file.
- *Whether callers actually use the `$result['conflict']` read pattern.* That is a property of the
  three caller sites, which are Feature C's surface and out of scope here. It is not a test gap in
  the library.

**Item 3 of the issue is verification-only and is satisfied.**

---

## Q5 — Bundle mirror and batching mechanics

### What the parity test asserts

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, lines 101-126:

- `SCOPED_ROOTS = (Path(".claude"),)` (line 20). The comparison scope is `.claude/**` only.
- It enumerates every file under `<root>/.claude` recursively with `rglob("*")`, filtering to
  `path.is_file()` (lines 34-43), for both the repository root and
  `extensions/drm-copilot/resources/claude-customizations` (lines 16-19).
- Exclusions are exactly two (lines 113-117): the literal path `.claude/settings.local.json`, and
  anything under `.claude/agent-memory/` via `_is_agent_memory_path` (lines 71-98).
- For each remaining repository file it asserts (a) the same relative path exists in the bundle list
  (lines 120-122) and (b) `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (lines 123-126).

Two precision points the epic manifest's "byte-identical" phrasing understates:

1. **It is a UTF-8 *text* comparison, not a byte comparison.** `read_text` (lines 46-49) calls
   `Path.read_text(encoding="utf-8")`, which opens in text mode with Python's default universal-
   newline translation. A CRLF-versus-LF difference between the two copies would **not** fail this
   test. Anything else — including a trailing-whitespace or a single-character difference — would.
2. **It is one-directional (repository → bundle).** Extra files that exist only in the bundle are
   permitted; that is how `.claude-variants/csharp-legacy/**` and the general-scoped agent memories
   live in the bundle without a repository counterpart (see the sibling tests at lines 163-176 and
   179-213). Deleting a repository `.claude/**` file therefore does **not** fail this test, but
   leaving a stale bundle copy is invisible to it.

### A second, weaker PowerShell-side gate

Four Pester suites assert bundled-counterpart *existence* (not content) plus pack-manifest
membership, discovering modules from disk rather than restating them:
`tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` (see lines 27-31 for the
disk-discovery pattern and lines 62-74 for the bundled-counterpart assertion), and its siblings
`orchestrator-state/OrchestratorState.Manifest.Tests.ps1`,
`discovery-validation/DiscoveryValidation.Manifest.Tests.ps1`,
`codex-routing/CodexRouting.Manifest.Tests.ps1`, and
`model-routing/ModelRouting.Manifest.Tests.ps1`. Because Feature A adds **no new module file**, none
of these requires a change. They would all require changes if a shared bootstrap module were
introduced — a further argument against option (c) in Q2.

### Is the mirror copy automated?

**No. It is a manual edit-both-files obligation.** Verified three ways:

1. The only two scripts naming the bundle root are `scripts/dev_tools/push_down_claude_customizations.py`
   (line 68) and `scripts/dev_tools/push_down_claude_pack_selection.py` (line 144). Both read *from*
   the bundle to push *to* a destination workspace; neither writes into the bundle.
2. The extension code that names the bundle —
   `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:75` and
   `push-down-service-call.ts:171-174` — likewise treats it as a pre-built source root.
3. No build step copies it: `extensions/drm-copilot/package.json` scripts (lines 202-213) are
   `tsc`/esbuild/prettier/eslint/jest only. The one `sync-*` script in `.vscode/tasks.json`
   (line 1179) is `scripts/dev-tools/sync-agents-from-instructions.ps1`, which generates `AGENTS.md`
   from `.github/instructions/**` and does not touch the bundle.

The bundle is a committed, hand-maintained tree. **The only thing that catches a missed mirror is the
pytest parity test.** This is the single most likely avoidable CI failure in this feature, exactly as
the epic manifest states.

### Additional batching input the planner needs

PoshQC's analyzer and formatter run over the **whole workspace** in CI
(`_poshqc.yml:26` and `:36` pass `-Root "${{ github.workspace }}"` with no `ScanFolders`), and
`$script:DefaultExcludedDirs` (`scripts/powershell/PoshQC/PoshQC.psm1:5-9`) excludes only `.git`,
`.venv`, `venv`, `node_modules`, `dist`, `build`, `.pytest_cache`, `__pycache__`, `.mypy_cache`,
`.ruff_cache`, `.vscode`, `.idea`, `artifacts`, and `.vscode-test`. Neither `.claude` nor
`extensions` is excluded. Therefore **both** the repository module and its bundle mirror are
format-checked and analyzed. The formatter step fails the build on any reformatting
(`_poshqc.yml:27-30`), so an edit must be formatter-clean in both copies — which, since the copies
are identical, it will be.

The Pester `Run.Path` is `@('scripts', 'tests/powershell', 'tests/scripts')`
(`pester.runsettings.psd1:3`) and `config/poshqc-scan.json` sets the same three folders. Tests for
these modules live under `tests/scripts/claude-lib/<area>/` and are therefore executed. Test homes
already exist for all three parse-site modules and for the whole blast-radius library, so new
coverage extends existing files rather than creating new ones — which keeps the 3-test-file per-batch
cap workable.

---

## Automation Feasibility

**One step is not fully automatable.**

Fully automatable:

- Every file edit in Q2's recommended boundary (Guard A and Guard B in 27 modules) and its 27 bundle
  mirrors. These are deterministic textual insertions at a fixed position relative to an existing
  line that is present in all 27 files.
- The Pester coverage for the guard, including a disk-discovering assertion over `.claude/lib/**`.
- The Q3 fallback disposition (help-text contract statement plus a coercion-pinning test).
- The Q3 primary disposition's implementation, if the decision below is made in its favour.
- The Q4 verification (read two files, assert the pair is present and passing).
- The bundle-mirror obligation and its verification via the existing pytest.
- The full seven-stage toolchain loop, via the PoshQC MCP functions.

**Not automatable — one product decision.** Q3's primary recommendation raises the destination
PowerShell floor for `Get-OrchestratorStateCheckpoint` from 7.4 to 7.5, which makes every hook on the
orchestrator-state enforcement path fail closed on a PowerShell 7.0–7.4 destination. The reason this
cannot be decided by an executing agent:

- It trades a working hook surface on the current PowerShell LTS (7.4) against a fix to an exposure
  that is **latent, not active** (no consumer reads a timestamp value; no library module
  re-serializes the checkpoint).
- The repository holds an explicit, **unresolved** decision record on precisely this class of
  question — `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md:82-84`, which
  is an unpromoted potential entry, not a settled policy.
- The consequence lands on consumer repositories, not on this repository's CI, so no automated gate
  can surface it.

**Recommended handling:** record it as a human-interaction requirement in the plan with the two
dispositions and their consequences as stated in Q3, and default to the **fallback** disposition if
no decision is returned, because the fallback regresses nothing.

No other step in this feature requires human interaction.

---

## Recommended Scope

### Item 1 — Fail-fast import guard

**Boundary: all 27 `.psm1` modules under `.claude/lib/**`.**

For each module: insert `$ErrorActionPreference = 'Stop'` on the line immediately following the
existing `Set-StrictMode -Version Latest`, and — in the 16 modules that have them — add
`-ErrorAction Stop` to each of the 44 column-0 `Import-Module` statements. Record the convention in
each module's comment-based help in one sentence, so it is destination-visible and so Feature C has a
stated convention to apply at its three caller sites.

Evidence for the boundary: 27 of 27 modules already carry `Set-StrictMode -Version Latest` at module
root (M4); module-scope preferences do not leak to callers (M1) and cannot alter another module's
behavior (M3); all 27 are already in the coverage denominator (N1 cross-check); and 16 modules carry
44 currently-unguarded load-time sibling imports (N5), which is the literal defect the issue names.

### Item 2 — Date-coercion guard

**Site: `.claude/lib/orchestrator-state/OrchestratorState.psm1:175` only.**
`HookPayload.psm1:262` and `DiscoveryValidation.psm1:338` are excluded with the justifications
recorded in Q3.

**Mechanism:** subject to the owner decision recorded under Automation Feasibility.

- If the floor may be raised: `-DateKind String` plus a fail-closed 7.5 version guard modelled on
  `Get-DiscoveryRuntimeVersionError` (`DiscoveryValidation.psm1:78-116`), with a destination-visible
  help statement and a dedicated Pester suite.
- If not: the documented-contract fallback (help statement naming the affected keys and the two
  future exposures, plus a coercion-pinning test), with no behavioral change.

A post-parse `[datetime]` → string repair must **not** be used; it is provably lossy in both the
offset and the format dimension (Q3).

### Item 3 — Truthiness verification

**No new test. No production change.** Verified satisfied by
`BlastRadius.Conflict.Tests.ps1:87-108` and `:110-118` against
`.claude/lib/blast-radius/BlastRadius.psm1:432-441`. Record the verification as evidence under
`<FEATURE>/evidence/qa-gates/`.

### Production-file count implied

| Component | Repository files | Bundle mirrors | Total |
| --- | --- | --- | --- |
| Item 1 — guard in all 27 modules | 27 | 27 | 54 |
| Item 2 — `OrchestratorState.psm1` | (already counted in the 27) | (already counted) | 0 additional |
| Item 3 — verification only | 0 | 0 | 0 |
| **Total production files** | **27** | **27** | **54** |

Item 2's edit lands in `OrchestratorState.psm1`, which is already one of the 27, so it adds no
additional production file. If the primary Q3 disposition is chosen and the version guard is placed
in a new sibling module for headroom, add 1 repository file + 1 mirror + a `core.json` pack-manifest
entry + an update to `OrchestratorState.Manifest.Tests.ps1` — check `OrchestratorState.psm1`'s
current line count against the 500-line limit before deciding.

**Batching:** 54 production files at the 3-production-file per-batch cap
(`.claude/rules/powershell.md:40`) is **18 batches**. With an explicit override treating the 27
byte-identical mirrors as a mechanical obligation of their source batch, **9 batches**. Test files:
new coverage extends `tests/scripts/claude-lib/<area>/*.Tests.ps1`, which already exist for every
area, so the 3-test-file cap is not a binding constraint.

---

## Testing Implications

No test code is proposed here; this section states the strategy only.

**Framework and location.** Pester 5.x, under `tests/scripts/claude-lib/<area>/`, mirroring the
production structure per `.claude/rules/general-unit-test.md`. All target modules already have test
homes; extend rather than create.

**Item 1 — the guard.**

- A single disk-discovering assertion over `.claude/lib/**/*.psm1` that every discovered module sets
  `$ErrorActionPreference` to `'Stop'` at module scope, following the discovery pattern of
  `BlastRadius.Manifest.Tests.ps1:27-31` so a future module cannot be added without the guard. This
  is the assertion that makes the "all 27" boundary verifiable and that a partial boundary could not
  support.
- A behavioral assertion, in one representative module with a load-time sibling import, that a failed
  sibling import surfaces as a terminating error to the caller rather than yielding a
  partially-initialized module. Achieve this by injecting a non-resolvable module path through the
  existing `$script:<Name>ModulePath` seam pattern already used at
  `OrchestratorStateModelReceipts.psm1:31`, `OrchestratorStateCompletion.psm1:56`,
  `OrchestratorStateCodexTopologyReceipts.psm1:37`, and `OrchestratorStateCodexModelReceipts.psm1:34`
  — not by creating a file. `.claude/rules/general-unit-test.md` prohibits temporary files in tests.
- A non-leakage assertion: after importing a guarded module, the caller's `$ErrorActionPreference` is
  unchanged. This pins M1 and prevents a future regression to a `$global:` form.

**Item 2 — the date-coercion guard.**

- Under the primary disposition: version-boundary tests through the injectable read-only
  `-PowerShellVersion` seam at the 7.4 / 7.5 boundary (below, at, above), asserting the fail-closed
  message names the required version and the reason — mirroring
  `DiscoveryValidation.VersionFloor.Tests.ps1`. Plus a value test asserting a parsed
  ISO-8601-valued key is `[string]`, using an in-memory JSON literal rather than a file.
- Under the fallback disposition: a coercion-pinning test asserting the current `[datetime]` type for
  a representative ISO-8601-valued key, plus a help-text assertion in the shape of
  `BlastRadius.Conflict.Tests.ps1:110-118`.

**Item 3.** Verification only; re-run the existing pair and capture the result as evidence.

**Determinism.** Every test above is pure and in-memory: no filesystem writes, no temporary files, no
network, no clock reads. The version seam is injected, never read from `$PSVersionTable` in the test,
and never mutated — the existing `DiscoveryValidation.psm1:92-94` comment records this requirement
explicitly.

**Coverage.** Line coverage ≥ 85% per `.claude/rules/quality-tiers.md`; Pester measures no branch
coverage, so no branch gate applies. All 27 modules are already registered in `CodeCoverage.Path`
(N1), so no `pester.runsettings.psd1` change is needed — unless a new module file is created, in
which case it must be registered there under the Coverage Exclusion Policy.

**Bundle parity.** `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` must
pass in the same change as every `.claude/**` edit. Run it after each batch, not only at the end.

---

## Evidence Index

| Claim | Location |
| --- | --- |
| All hooks launched with `pwsh` | `.claude/settings.json` (36 command entries, e.g. lines 84, 95, 103, 265) |
| CI runs `pwsh` on `windows-latest` | `.github/workflows/_poshqc.yml:10, 17, 23, 33, 39` |
| PoshQC scans the whole workspace | `_poshqc.yml:26, 36`; `scripts/powershell/PoshQC/PoshQC.psm1:5-9` |
| Only `PSUseCompatibleSyntax` is configured | `scripts/powershell/PoshQC/settings/pssa.settings.psd1:8-12` |
| `PSUseCompatibleSyntax` checks syntax only | Microsoft `UseCompatibleSyntax` rule reference |
| `PSUseCompatibleCommands` is default-disabled and unconfigured | Microsoft `UseCompatibleCommands` rule reference; repo search for `PSUseCompatible` |
| `-DateKind` is 7.5; `-Depth` is 6.2; `-AsHashtable` is 6.0 | Microsoft `ConvertFrom-Json` reference, Parameters section |
| `-DateKind String` semantics and `Default` lossiness | Microsoft `ConvertFrom-Json` reference, NOTES |
| A 6.2-only parameter is already in `.claude/lib` | `.claude/lib/discovery-validation/DiscoveryValidation.psm1:338` |
| 7.4 floor declared and enforced in `.claude/lib` | `DiscoveryValidation.psm1:11-19, 69-71, 78-116, 330`; `DiscoveryValidation.VersionFloor.Tests.ps1` |
| Open decision on the declared floor | `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md:53-84` |
| Destination may fall back to Windows PowerShell | `extensions/drm-copilot/src/runtime-detection.ts:232-233, 244-283` |
| CI must be ≥ 7.5 | `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:314-318`; `pester.runsettings.psd1:3` |
| Module scope does not leak to callers | `about_Scopes`, "Parent and child scopes" note and the Modules section worked example |
| Preference variables are scope-local | `about_Preference_Variables`, "Changes to preference variables apply only in the scope they are made and any child scopes thereof." |
| `Set-StrictMode` present in all 27 modules | 27 module-root occurrences, enumerated in Q2 M4 |
| 44 column-0 `Import-Module` statements in 16 modules | N5 |
| Three deserialization call sites | N3 |
| Zero error-preference settings in `.claude/lib` | N4 |
| Six ISO-8601-valued keys in the live checkpoint | N6; `artifacts/orchestration/orchestrator-state.json:42, 52, 63, 71, 79, 87` |
| Timestamp keys are presence-checked only | `OrchestratorState.psm1:36-59`; `OrchestratorStateReceipts.psm1:41-50, 103-109`; `OrchestratorStateCompletionChecks.psm1:70, 275` |
| No re-serialization in `.claude/lib` | Zero `ConvertTo-Json`/`Set-Content`/`Out-File` occurrences under `.claude/lib/**` |
| String/non-string comparison returns false | `OrchestratorStateCheckpointValue.psm1:256-258` |
| `[string] $ComputedAt` binding coercion | `.claude/lib/blast-radius/BlastRadius.psm1:158-160, 324-326` |
| `Get-RequiredText` enforces a non-empty string | `.claude/lib/blast-radius/BlastRadiusConfig.psm1:52-94`; call site `BlastRadiusValidation.psm1:124` |
| Truthiness pair and help text | `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-118`; `.claude/lib/blast-radius/BlastRadius.psm1:432-441` |
| Bundle parity assertion | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20, 34-49, 101-126` |
| Bundle mirrors all 36 lib files | `Glob extensions/drm-copilot/resources/claude-customizations/.claude/lib/**/*` |
| No repo → bundle sync tooling | `scripts/dev_tools/push_down_claude_customizations.py:68`; `push_down_claude_pack_selection.py:144`; `extensions/drm-copilot/package.json:202-213`; `.vscode/tasks.json:1179` |
| Manifest suites assert existence, not content | `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1:27-31, 62-74` |
| Per-batch cap and override clause | `.claude/rules/powershell.md:40` |

## Out of Scope (Feature C)

`.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, and
`.claude/agents/parallel-planner.md` were **read only** to establish the Q2 division of
responsibility. They were not modified and no change to them is proposed here.

## Adjacent Observations (not in scope; recorded so they are not rediscovered)

- The same `ConvertFrom-Json` date-coercion hazard exists at multiple checkpoint parse sites under
  `.claude/hooks/**` — for example `enforce-checkpoint-monotonic.ps1:74`,
  `enforce-completion-consistency.ps1:62`, `validate-orchestrator-output.ps1:354`,
  `enforce-parallel-cohort-barrier.ps1:226`, `enforce-epic-wave-barrier.ps1:276`,
  `enforce-parallel-drift-gate.ps1:314`, `enforce-parallel-worktree-removal-gate.ps1:216`, and
  `enforce-pr-author-skill.epic-base-branch.ps1:77`. Issue #598's declared scope is `.claude/lib/**`.
  Spot checks found no active date comparison at these sites
  (`enforce-checkpoint-monotonic.ps1` contains no `last_updated` reference), but the surface was not
  audited exhaustively.
- The `$ErrorActionPreference` convention is only partially applied within `.claude/hooks/**` as
  well: 6 of the hooks set it, while for example `.claude/hooks/enforce-mermaid-validation.ps1:60`
  sets `Set-StrictMode` without it. Out of scope for #598.
- `.claude/skills/parallel-plan/SKILL.md:193-194` states the PowerShell port "reads"
  `config/blast-radius.json` but never spells the parse. There is **no** `ConvertFrom-Json`
  occurrence in any `.claude/**` markdown file (verified: zero matches). A caller must therefore
  supply the parsed truth table by an undocumented means. This is a documentation gap on the caller
  surface, adjacent to Feature C but not named in it.
