# 2026-08-29-blast-radius-powershell-calling-convention (Spec)

- **Issue:** #598
- **Parent (optional):** Epic `claude-runtime-portability` (`docs/features/epics/claude-runtime-portability/epic.md`), Feature A, wave 0, band C3
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T20-45
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** `full-bug`. This document is the sole acceptance-criteria source. `user-story.md` is
  correctly absent and must remain absent.

## Context

The shared PowerShell modules under `.claude/lib/**` set no fail-fast error preference, so a failed
load-time sibling import leaves the outer module importable and its exported functions fail later
with an unrelated error. Separately, the checkpoint parse in
`.claude/lib/orchestrator-state/OrchestratorState.psm1` calls `ConvertFrom-Json` with no date-coercion
control, so an ISO-8601-valued key is returned as `System.DateTime` rather than as the string the
checkpoint holds.

This is Feature A (wave 0) of the `claude-runtime-portability` epic. It establishes the calling
convention that Feature C (wave 1) later applies at its three caller sites. The epic's
`business_outcome_hypothesis` is that the `.claude/**` payload becomes executable on destination
runtimes; that hypothesis governs the item 2 disposition recorded below.

Environment:

- OS/version: Windows 11 Pro 10.0.26200. The `.claude/**` payload also ships to consumer repositories
  through the push-down mechanism, which guarantees no Python interpreter and no `scripts/dev_tools`
  tree at the destination.
- Python version: not applicable to the change surface. The only Python involvement is the
  bundle-parity test named under Test Strategy.
- Command/flags used: `Import-Module .claude/lib/<area>/<Module>.psm1`; `ConvertFrom-Json` at the
  three parse sites listed under Root Cause Analysis.
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` (the checkpoint object
  read at `OrchestratorState.psm1:175`).

Impact / Severity:

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A failed load in a shared module surfaces later as a wrong result rather than as an error. The
date-coercion divergence is latent today (see Root Cause Analysis) but is a value-contract divergence
at a module boundary that reaches every caller of the shared library, including consumer repositories
that receive the pushed-down payload.

## Repro & Evidence

Steps to Reproduce:

1. Import any module under `.claude/lib/**`. No module sets `$ErrorActionPreference`, so a
   non-terminating error inside the module does not stop the caller, and a failed load-time sibling
   import does not stop the enclosing module from finishing its import.
2. Write an orchestrator checkpoint containing a true ISO-8601 instant value (for example
   `"last_updated": "2026-08-29T20:38:00Z"`).
3. Read the checkpoint through `Get-OrchestratorStateCheckpoint` (`OrchestratorState.psm1:175`),
   which calls `$raw | ConvertFrom-Json -ErrorAction Stop` with no date-coercion control.
4. Inspect the parsed field's runtime type.

Expected:

1. An import failure or an internal module failure surfaces as a terminating error rather than being
   swallowed, so a caller cannot proceed on partially-initialized state.
2. The parsed-value type contract of `Get-OrchestratorStateCheckpoint` is stated where a consumer can
   read it, and is pinned by a test, so a consumer cannot assume `[string]` without being contradicted
   at development time.

Actual:

1. Zero files under `.claude/lib/**` establish a fail-fast error preference by any mechanism. The
   setting appears only in `.claude/hooks/*.ps1` (6 files).
2. `ConvertFrom-Json` materializes an ISO-8601 instant as `[datetime]` under its default date
   handling. No statement of that behavior exists in the module's comment-based help, and no test
   pins it.

Re-derived against the current worktree on 2026-08-29 (each figure re-checked rather than copied from
the research artifact):

| Figure | Value | Derivation |
| --- | --- | --- |
| `.psm1` modules under `.claude/lib/**` | 27 | `Glob .claude/lib/**/*.psm1`; cross-checked against the 27 `.claude/lib/<dir>/<Name>.psm1` entries in `CodeCoverage.Path` of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| Modules carrying `Set-StrictMode -Version Latest` at module root | 27 of 27 | 28 total matches across 27 files; the extra match is prose inside a comment at `OrchestratorState.psm1:461` |
| Column-0 `Import-Module` statements | 44, across 16 modules | anchored search `^Import-Module \(Join-Path` and `^Import-Module \$script:` |
| `$ErrorActionPreference` occurrences under `.claude/lib/**` | 0 | family search over the preference variable, `$PSDefaultParameterValues`, and `Set-Variable` routes |
| Executable `ConvertFrom-Json` call sites under `.claude/lib/**` | 3 | `HookPayload.psm1:262`, `OrchestratorState.psm1:175`, `DiscoveryValidation.psm1:338`; the other 7 matches are comments |
| `-DateKind` occurrences under `.claude/lib/**` | 0 | token search |
| Bundle `.psm1` mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/**` | 27, same relative paths | `Glob` over the bundle tree |
| Production files implied | 54 | 27 repository modules plus 27 bundle mirrors |

Deliberately not restated as a fixed count: the number of ISO-8601-valued keys in the live
`artifacts/orchestration/orchestrator-state.json`. That file is a mutable runtime artifact; the
research recorded 6 occurrences across 3 key names, and the same file now holds 9 occurrences across
6 key names (`last_updated`, `checked_at`, `assessed_at`, `started_at`, `completed_at`, `decided_at`)
because the orchestrator wrote to it between the two readings. No acceptance criterion in this
document asserts a count over that file. The durable, module-declared ISO-8601 key families are
`last_updated` (`OrchestratorState.psm1:50`), `started_at` and `completed_at`
(`OrchestratorStateReceipts.psm1:46-47`), and `verified_at`
(`OrchestratorStateCompletionChecks.psm1:70`).

## Scope & Non-Goals

In scope:

1. **Item 1 — fail-fast import guard**, applied to all 27 `.psm1` modules under `.claude/lib/**` and
   their 27 bundle mirrors. Two-part guard plus a one-line convention statement in each module's
   leading comment-based-help block.
2. **Item 2 — date-coercion contract**, at `.claude/lib/orchestrator-state/OrchestratorState.psm1`
   only. Documented-contract fallback: a comment-based-help contract statement plus a Pester test
   that pins the current coercion behavior. No behavioral change.
3. **Item 3 — truthiness verification**, verification-only. No new test and no production change.
4. The bundle-mirror obligation for every `.claude/**` file this feature edits.

Out of scope / non-goals:

- **Raising the PowerShell floor from 7.4 to 7.5 is an explicit non-goal.** The rationale and the
  preserved open decision are recorded under "Decision: the PowerShell floor is not raised" below.
- **`ConvertFrom-Json -DateKind String` is not adopted anywhere in this feature.** It is a
  PowerShell 7.5 parameter and is above the established 7.4 floor
  (`DiscoveryValidation.psm1:71` declares and enforces that floor in production).
- **A post-parse `[datetime]`-to-string repair is prohibited**, not merely unselected. See "Prohibited
  mechanisms" below.
- `HookPayload.psm1:262` and `DiscoveryValidation.psm1:338`. Excluded on the site-by-site evidence
  recorded under Root Cause Analysis.
- The date-coercion hazard at the `.claude/hooks/**` parse sites. Issue #598's declared surface is
  `.claude/lib/**`.
- The partial `$ErrorActionPreference` application inside `.claude/hooks/**` (6 of the hooks set it).
- `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, and
  `.claude/agents/parallel-planner.md`. These are Feature C (wave 1) and must not be modified here.
- Any file under `.claude/rules/` or `.github/instructions/`. Those are policy surfaces and are not
  modified by this feature, including `.claude/rules/powershell.md:24`.
- `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Its `TargetVersions = @('5.1', '7.6')`
  belongs to `PSUseCompatibleSyntax`, which checks syntax only and cannot flag a cmdlet parameter.
  Removing the `'5.1'` leg would relax an existing gate for no benefit this feature requires.
- A shared bootstrap or loader module. Rejected under "Boundaries and invariants to preserve".
- `pester.runsettings.psd1`. All 27 modules are already in `CodeCoverage.Path` (27 of 27 verified),
  and this feature creates no new production module, so no coverage-configuration change is required.

Explicitly excluded systems, integrations, or datasets:

- TaskMaster-repository code. The TaskMaster framing in the originating report is motivating
  consumer-repository evidence, not a target of this fix.
- The push-down TypeScript pipeline under `extensions/drm-copilot/src/`. This feature edits the
  committed bundle payload, not the code that publishes it.

## Root Cause Analysis

### Item 1 — the missing fail-fast guard

- All 27 modules already carry `Set-StrictMode -Version Latest` at module root, and none carries an
  error preference. `Set-StrictMode` governs uninitialized-variable reads, non-existent property
  reads, and improper call syntax; it has no effect on non-terminating cmdlet errors. The guard is
  therefore the missing sibling of an already-uniform line, in the same position, in every file.
- All 44 column-0 `Import-Module` statements are of the form
  `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '<Sibling>.psm1') -Force` or
  `Import-Module $script:<Path> -Force`, and none carries `-ErrorAction`. A missing or unreadable
  sibling makes `Import-Module` write a non-terminating error; under the default
  `$ErrorActionPreference = 'Continue'` the outer module's load script continues and the outer module
  finishes importing. Its exported functions then fail later with an unrelated
  command-not-recognized error. The path is currently reachable: `BlastRadius.psm1` imports five
  siblings at load time, and the `parallel-plan` skill's documented entry point is an
  `Import-Module` of that facade.
- Scope semantics, from `about_Scopes` and `about_Preference_Variables`: a module has its own root
  scope, and a preference variable applies only in the scope where it is set and that scope's
  children. A module-root `$ErrorActionPreference = 'Stop'` therefore governs the module's own
  load-time statements and its exported functions, and does **not** change the caller's preference.
  It also cannot change the error behavior of another module's functions, which resolve their own
  preference from their own module scope. The 27 edits are consequently 27 independent changes rather
  than one coupled change.

### Item 2 — the date-coercion divergence, and why it is latent

- `OrchestratorState.psm1:175` (`$state = $raw | ConvertFrom-Json -ErrorAction Stop`) sits inside
  `Get-OrchestratorStateCheckpoint` (lines 125-195), whose result crosses the module boundary into
  the other orchestrator-state modules and the hook surface as
  `@{ Ok = $true; State = $state; Error = '' }` (line 194).
- The exposure is latent, not active. Every ISO-8601-valued checkpoint key is validated by **presence
  only**: `REQUIRED_STATE_KEYS` (`OrchestratorState.psm1:36-59`), `REQUIRED_RECEIPT_KEYS`
  (`OrchestratorStateReceipts.psm1:41-50`, with the explicit comment at lines 103-104 that key
  presence is the test), and `CI_GATE_KEYS` (`OrchestratorStateCompletionChecks.psm1:70`). Presence
  is unaffected by the value's runtime type.
- No `.claude/lib` module re-serializes the parsed checkpoint: there are zero `ConvertTo-Json`,
  `Set-Content`, and `Out-File` occurrences under `.claude/lib/**`. There is no read-modify-write path
  by which a coerced `[datetime]` could be written back in a different format.
- Two future exposures exist and are the reason the contract is worth stating rather than ignoring.
  `Test-PythonValueEqual` (`OrchestratorStateCheckpointValue.psm1:256-258`) returns `$false` when one
  side is a `[string]` and the other is not, so a `[datetime]` compared against an expected string
  would produce a wrong mismatch verdict; no `*_at` key is routed through it today. And
  `Get-BlastRadius` / `Get-BlastRadiusFromObservedPaths` declare `[string] $ComputedAt`
  (`BlastRadius.psm1:160` and `:326`), so PowerShell parameter binding would coerce a `[datetime]`
  argument to a culture-dependent string with no error; no in-repo caller exercises this.

### Site exclusions for item 2

- **`HookPayload.psm1:262` — excluded.** The parsed object is the Claude hook envelope. The module
  names one payload key constant (`$script:ToolInputKey = 'tool_input'`, line 52); every other value
  is read through the generic accessor by consumers requesting `tool_name`, `file_path`, `content`,
  `command`, and `session_id`. None is ISO-8601-valued. The one path by which checkpoint text could
  reach this parser is a `Write` payload whose `tool_input.content` is a whole JSON document carried
  as a JSON string; such a string does not parse as a date and is not coerced.
- **`DiscoveryValidation.psm1:338` — excluded.** The parsed object is used for exactly two things: an
  `-isnot [System.Management.Automation.PSCustomObject]` root-shape check (line 345) and reading the
  `$schema` property (lines 350-351), which is a URI. The schema validation itself runs against the
  raw text through `Test-Json -Json $Text -SchemaFile ...` (line 362). The coercion is unobservable at
  this site because no date-valued field is ever read from the parsed object.

### Item 3 — already satisfied

`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-108`
(`It 'is unconditionally truthy even when its conflict key is false'`) asserts
`$result['conflict'] | Should -BeFalse` and `$coerced | Should -BeTrue` in one `It`, with the comment
at lines 94-95 recording why both halves live together. Its companion at lines 110-118
(`It 'documents the truthiness divergence in its comment-based help'`) reads rendered help through
`Get-Help -Full | Out-String -Width 500` and asserts the substring
`the conflict key of the returned hashtable`. The warning text is present at
`.claude/lib/blast-radius/BlastRadius.psm1:432-441`. No gap was identified. The converse case (a
genuine conflict, where the coerced boolean and the verdict agree) pins nothing, because the
divergence is observable only in the false case.

## Decision: the PowerShell floor is not raised

Recorded as a `scope_change` response to human-interaction requirement `HI-1-powershell-floor-raise`
in `artifacts/orchestration/orchestrator-state.json`. This decision is settled and is not
relitigated by planning or execution.

**What was decided.** Item 2 adopts the research's documented-contract fallback. It does not adopt
`-DateKind String`, does not add a `$script:MinimumPowerShellVersion` constant or a version-guard
function to `OrchestratorState.psm1`, does not add a version-guard module, and does not change the
declared floor anywhere.

**Rationale.**

1. The epic's `business_outcome_hypothesis` is that the `.claude/**` payload becomes executable on
   destination runtimes. Raising the floor to 7.5 would make every hook that calls
   `Get-OrchestratorStateCheckpoint` fail closed on a PowerShell 7.4 destination. PowerShell 7.4 is
   the current LTS, so that is a realistic destination configuration, and the result would work
   against the epic's stated purpose. The blast radius is materially larger than issue #475's, which
   affected two discovery-gate hooks; `Get-OrchestratorStateCheckpoint` is on the path of the whole
   orchestrator-state enforcement family.
2. The exposure is latent, not active: all ISO-8601-valued checkpoint keys are presence-checked only,
   and there are zero `ConvertTo-Json`, `Set-Content`, and `Out-File` occurrences under
   `.claude/lib/**`. No consumer reads or rewrites a coerced value today.
3. The fallback regresses nothing and costs one module, one mirror, and test additions in an existing
   test file.

**The open question is preserved, not closed.** The 7.4-to-7.5 floor-raise decision remains open and
is recorded here as a non-goal pointing at the existing unpromoted decision record
`docs/features/potential/2026-08-15-portable-hook-validation-residuals.md:82-84` (Residual 2), which
ends "decide whether the repository standard in `.claude/rules/powershell.md` should be raised to
7.4+, or whether destination-side tooling should detect and report the floor ahead of hook execution
rather than at hook-execution time." This feature files no new issue for it and does not modify that
record.

### Prohibited mechanisms

- **A post-parse `[datetime]`-to-string repair is prohibited.** It is lossy in two independent
  dimensions. First, offset: under default date handling a value carrying a UTC offset such as
  `-04:00` is converted to the caller's configured time zone and the original offset is not
  recoverable, so a repair emits a different literal — and `Test-PythonValueEqual` compares strings
  ordinally, so a different literal is a changed value. Second, format: `2026-08-29T20:06:23Z` parses
  to a UTC `[datetime]` whose round-trip form is `2026-08-29T20:06:23.0000000Z`, which is not the
  original literal. A repair helper would silently change values, which is a worse failure mode than
  the coercion it purports to fix.
- **A version-adaptive splat is prohibited.** Supplying `-DateKind String` only on hosts at 7.5 or
  above would make the same checkpoint yield `[string]` on one host and `[datetime]` on another. A
  host-dependent value contract is the `cross_module_contract_change` risk this feature is banded C3
  for, and is worse than either consistent branch.
- **A fail-closed type assertion is prohibited.** Under default date handling the coercion is
  unconditional for a well-formed ISO-8601 value, so an assertion that rejects a coerced value would
  fail on every real checkpoint and block every hook.

## Proposed Fix

### Design summary (what changes where)

| Item | Repository files | Bundle mirrors | Test files |
| --- | --- | --- | --- |
| 1 — fail-fast guard and convention statement | 27 `.claude/lib/**/*.psm1` | 27 | 1 new: `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` |
| 2 — date-coercion contract | `OrchestratorState.psm1` (already one of the 27) | already counted | 1 extended: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` |
| 3 — truthiness verification | none | none | none (evidence only) |
| **Total** | **27** | **27** | **2** |

### Boundaries and invariants to preserve

**Why all 27 modules, and not the 7 blast-radius modules only.**

1. A blast-radius-only boundary is incoherent with this feature's own item 2, which targets
   `OrchestratorState.psm1` — a module that boundary excludes. It would also make the issue's
   Expected Behavior #1 ("Import any module under `.claude/lib/**` …") false as written, and it
   excludes 9 of the 16 modules that actually carry an unguarded load-time import path.
2. Uniformity is the existing house pattern and is the only verifiable acceptance-criterion shape. An
   assertion of the form "every `.psm1` discovered on disk under `.claude/lib/**` sets the guard at
   module scope" is mechanically checkable by one Pester test that discovers modules from disk — the
   pattern already used at `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1:27-31`,
   which discovers with `Get-ChildItem -Filter '*.psm1'` explicitly "so a future module cannot be
   added without also being listed". A partial boundary admits no such assertion and would let a new
   module be added unguarded.
3. Module-scope preferences do not leak to callers and cannot alter another module's function
   behavior, so the change's blast radius is bounded per module.
4. All 27 modules are already in the coverage denominator, so no coverage-configuration change is
   needed.
5. No new file is created, so no `core.json` pack-manifest entry, no additional bundle file, and no
   change to the four `*.Manifest.Tests.ps1` suites is required.

**A shared bootstrap or loader module is rejected.** `about_Scopes` states both that a module loaded
from within another module is loaded into the loader's scope container and that each module has its
own root scope. Those two statements do not jointly determine whether a variable set at a loader's
root is resolvable from inside a separately-imported sibling's function, and the question was not
settled from documentation. A design that depends on that inheritance is unproven. The loader would
also add a new file with pack-manifest, bundle, and manifest-test costs, in exchange for saving edits
in files that must be visited anyway for the per-statement `-ErrorAction Stop`.

**Invariants that must survive the change.**

- No module's public function signature, exported-member list, or return contract changes.
- No caller's `$ErrorActionPreference` is modified by importing a guarded module.
- The parsed-value types returned by `Get-OrchestratorStateCheckpoint` are unchanged. Item 2 documents
  and pins the existing behavior; it does not alter it.
- `.claude/lib/discovery-validation/DiscoveryValidation.psm1` retains its 7.4 version-floor constant,
  its fail-closed guard, and the comment recording why the floor exists (issue #475, `Test-Json
  -SchemaFile` Draft 2020-12 support). That rationale is what prevents the floor from being removed
  by a later reader.

### Dependencies or blocked work

- No dependency on another feature. Feature A is wave 0 with an empty `depends_on`.
- Feature C (wave 1, issue to be resolved from the epic manifest) depends on this feature for the
  convention statement it applies at its three caller sites. Feature A must therefore leave the
  convention stated in the modules themselves, not only in this document.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

- All 27 `.psm1` files under `.claude/lib/**`, across the 7 subdirectories `blast-radius`,
  `codex-routing`, `discovery-validation`, `hook-payload`, `mermaid`, `model-routing`, and
  `orchestrator-state`.
- The 27 corresponding files under
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/**`, which must receive the
  identical edit in the same change.
- The 9 `.sh` files under `.claude/lib/bash/` are untouched: a bash script cannot carry a PowerShell
  preference variable.

Per repository module, three edits:

1. Insert `$ErrorActionPreference = 'Stop'` on the line immediately following the module's existing
   `Set-StrictMode -Version Latest` line. The position is fixed and reviewable, and it must precede
   the module's `Import-Module` block so that the guard covers the load-time import path.
2. In the 16 modules that have them, add `-ErrorAction Stop` to each of the 44 column-0
   `Import-Module` statements. This is an in-place addition to an existing line and adds no line.
   `PSAvoidLongLines` is not configured in `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, so
   the longer line does not create analyzer debt.
3. Add one line to the module's leading comment-based-help block (the block that precedes
   `Set-StrictMode`), stating the convention in a fixed, uniform sentence containing the single-line
   token `imports its siblings with -ErrorAction Stop`. The sentence is fixed rather than
   author-chosen so that one disk-discovering test can assert it across all 27 modules and so that
   Feature C has one stated convention to apply.

The per-statement guard and the module-scope guard are complementary and both are required. The
per-statement form is correct regardless of the unresolved loader-inheritance question and changes no
function's error semantics; the module-scope form additionally covers the issue's second half, an
internal module failure surfacing as a terminating error.

For `OrchestratorState.psm1` only, a fourth edit: the item 2 contract statement in the
comment-based help of `Get-OrchestratorStateCheckpoint`. It must state, at minimum, that under
default `ConvertFrom-Json` date handling an ISO-8601-valued key is returned as `System.DateTime` and
not as the string the checkpoint holds; name the module-declared key families `last_updated`,
`started_at`, `completed_at`, and `verified_at`; state that all current validations are presence-only
so the coercion is unobservable today; name the two future exposures
(`OrchestratorStateCheckpointValue.psm1:256-258` and the `[string] $ComputedAt` binding at
`BlastRadius.psm1:160` / `:326`); and state that a post-parse repair is prohibited as lossy. It must
contain the single-line token `date-coerced by ConvertFrom-Json`.

#### The 500-line file limit is a binding constraint on this change

`.claude/rules/general-code-change.md` caps a production file at 500 lines. Line counts re-derived on
2026-08-29 against this worktree; they must be re-derived at execution time before any edit:

| Module | Lines now | Headroom before the cap |
| --- | --- | --- |
| `discovery-validation/DiscoveryValidation.psm1` | 500 | **0** |
| `mermaid/MermaidValidation.psm1` | 496 | 4 |
| `hook-payload/HookPayload.psm1` | 494 | 6 |
| `blast-radius/BlastRadius.psm1` | 493 | 7 |
| `mermaid/MermaidGrammar.psm1` | 491 | 9 |
| `orchestrator-state/OrchestratorState.psm1` | 488 | 12 |
| `mermaid/MermaidLineScanner.psm1` | 488 | 12 |
| all other 20 modules | 471 or fewer | 29 or more |

Item 1 adds 2 lines to every module (the guard line and the convention line). Consequences:

- **`DiscoveryValidation.psm1` cannot absorb the change as-is.** It is exactly at the cap. Two lines
  must be freed inside that file by condensing existing comment text. The condensation must not
  remove the version-floor rationale: the comment at `DiscoveryValidation.psm1:69-70` carrying
  `Draft 2020-12 support in PowerShell 7.4`, the constant at line 71, and the destination-visible
  floor statement in the module help must all survive. That the cap actively binds in this area is
  corroborated by `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1:3-5`,
  which records that it exists as a sibling split because `DiscoveryValidation.Tests.ps1` reached the
  same cap.
- **`OrchestratorState.psm1` has 12 lines of headroom, of which item 1 consumes 2.** The item 2
  contract statement must therefore fit in at most 10 lines. If it does not fit, the statement is
  condensed to name the coercion, the four module-declared key families, and the prohibition, and the
  fuller rationale is carried in the `.DESCRIPTION` block of
  `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (474 lines, 26 lines of
  headroom). Splitting `OrchestratorState.psm1` into a sibling module is not authorized by this spec:
  it would add a pack-manifest entry, a bundle file, and a change to
  `OrchestratorState.Manifest.Tests.ps1`, which is a larger change than the item it serves.
- No other module is within 4 lines of the cap, so no other file requires condensation.

#### Functions/classes/CLI commands impacted

- No function signature changes. No function is added to or removed from any module.
- `Get-OrchestratorStateCheckpoint` gains help text only; its parameters, output shape, and returned
  value types are unchanged.
- Error propagation changes for every exported function in all 27 modules: a non-terminating cmdlet
  error inside a module function becomes terminating within that module's scope.

#### Data flow and validation changes

None. No parsed value changes type, no validation rule is added or removed, and no checkpoint key is
newly required or newly optional.

#### Error handling and logging updates

- A failed load-time sibling import now terminates the enclosing module's import instead of allowing
  it to complete partially initialized. Callers observe a terminating error at import time rather
  than a command-not-recognized error at first use.
- No logging or telemetry statement is added. The modules emit no logs today and this feature adds
  none.

#### Rollback/feature-flag considerations (if applicable)

No feature flag. The change is a per-file textual edit; rollback is a revert of the commit range.
Because the guard is module-scoped and cannot alter another module's behavior, a partial revert of
individual modules is also coherent, though it would break the disk-discovering acceptance assertions
and is not a supported end state.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

Unchanged. `Get-OrchestratorStateCheckpoint` continues to return
`System.Collections.Hashtable` with keys `Ok`, `State`, and `Error`, and continues to return a
`PSCustomObject` in `State` on success.

#### Required configuration keys and defaults

None added. `pester.runsettings.psd1` and `pssa.settings.psd1` are unchanged.

#### Backward-compatibility expectations

- The parsed-value contract is unchanged, so no consumer of `Get-OrchestratorStateCheckpoint` needs
  to change.
- The error-propagation contract changes: a caller that previously received a partially-initialized
  module now receives a terminating error at import time. That is the intended correction, and it is
  the only behavior change this feature makes.
- The destination PowerShell floor is unchanged at 7.4. No destination that works today stops
  working.

#### Performance constraints (latency/throughput/memory)

None. The change adds one variable assignment per module load and one common parameter per import
statement.

## Assumptions, Constraints, Dependencies

Assumptions:

- Every `.claude/lib` module is loaded by `pwsh`, not by Windows PowerShell 5.1. All 36 hook command
  entries in `.claude/settings.json` are of the form `pwsh -NoProfile -File ...`, and every step in
  `.github/workflows/_poshqc.yml` declares `shell: pwsh`.
- The CI host's `pwsh` is 7.5 or later, because
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:318` calls
  `ConvertFrom-Json -AsHashtable -DateKind String` unguarded and that file is inside the Pester
  `Run.Path`. This assumption affects nothing in this feature's scope; it is recorded so that the
  absence of a `-DateKind` usage in production is not mistaken for a CI capability limit.

Constraints:

- **Batching. `.claude/rules/powershell.md:40` caps a batch at 3 production files and 3 test files
  "unless an explicit override has been approved." No override has been approved for this feature.**
  Planning and execution must sequence 54 production files within the unoverridden cap, which is 18
  batches. The 2 test files fit inside the 3-test-file cap in a single batch.
- **Requested but not granted: a mirror exemption.** The following is a request for approval and must
  not be treated as an assumption or acted on until it is explicitly granted. Request: count only the
  27 repository modules against the per-batch production-file cap and treat each module's bundle
  mirror as a mechanical obligation of the same batch, on the grounds that the mirror is a
  byte-identical copy that adds no independent review surface and whose correctness is
  machine-checked by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. If granted,
  the sequence is 9 batches. **Until it is granted, plan for 18.**
- **The 500-line file limit**, as detailed above. `DiscoveryValidation.psm1` requires condensation.
- **Toolchain per batch.** `.claude/rules/powershell.md:20` requires format, then analyze, then test,
  restarting from step 1 if any step fails or changes files. This must be run per batch, not only at
  the end, because PoshQC's analyzer and formatter run over the whole workspace in CI
  (`_poshqc.yml:26` and `:36` pass the workspace root with no folder filter) and
  `$script:DefaultExcludedDirs` in `scripts/powershell/PoshQC/PoshQC.psm1:5-9` excludes neither
  `.claude` nor `extensions`. Both the repository module and its bundle mirror are format-checked and
  analyzed.
- **Test failures caused by the guard are in scope.** Adding `$ErrorActionPreference = 'Stop'`
  converts non-terminating errors into terminating errors in all 27 modules. Any Pester test that
  fails as a result is in-scope work for this feature and must be repaired within it. It is not an
  unexpected result, not a reason to narrow the boundary, and not grounds to weaken an assertion. If
  a failure reveals that a module depended on a non-terminating error to continue, the correct
  response is to make that dependence explicit in the module, not to remove the guard.
- **The bundle-parity comparison is text, not bytes.** `read_text` in
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:46-49` calls
  `Path.read_text(encoding="utf-8")`, which applies Python's universal-newline translation. A
  CRLF-versus-LF difference between the two copies alone would therefore **not** fail the test; any
  other difference, including a single trailing space, would. The epic manifest's "byte-identical"
  phrasing is stricter than what the test actually asserts.
- **The parity assertion is one-directional (repository to bundle).** Extra files that exist only in
  the bundle are permitted, which is how `.claude-variants/**` and general-scoped agent memories live
  there. A stale bundle copy of a file deleted from the repository is invisible to the test. This
  feature deletes no file, so the direction is not load-bearing here; it is recorded so that the test
  is not over-relied on as a two-way mirror check.

External dependencies:

- Nothing new. Pester 5.x and PoshQC are already in use; no package is added.
- Nothing automates the repository-to-bundle copy. Verified three ways: the only two scripts naming
  the bundle root (`scripts/dev_tools/push_down_claude_customizations.py:68` and
  `scripts/dev_tools/push_down_claude_pack_selection.py:144`) read *from* the bundle; the extension
  code treats the bundle as a pre-built source root; and no build step copies it. The mirror is a
  **manual edit-both-files obligation**, and the pytest parity test is the only thing that catches a
  missed mirror.

## Data / API / Config Impact

- User-facing or API changes: none. No exported function signature, parameter, or return shape
  changes.
- Data or migration considerations: none. No checkpoint, artifact, or configuration file format
  changes, and no existing checkpoint needs rewriting.
- Logging/telemetry updates: none.
- Compatibility notes: the destination PowerShell floor remains 7.4. No CLI flag, config schema, or
  version constraint changes. `.claude/rules/powershell.md` is not modified.

## Test Strategy

Framework and location: Pester 5.x under `tests/scripts/claude-lib/`, mirroring the production
structure per `.claude/rules/general-unit-test.md`. All target areas already have test homes.

New test file: `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`. It sits at the root of
the `claude-lib` test tree because its production subject is the `.claude/lib` tree as a whole rather
than any single module. It is inside the Pester `Run.Path` (`pester.runsettings.psd1:3` names
`tests/scripts`). Required structure:

- `Describe 'Claude library module conventions'`, discovering modules with
  `Get-ChildItem -Filter '*.psm1' -File -Recurse` under the resolved `.claude/lib` root. The module
  list must be discovered from disk, never restated, so that a module added later cannot escape the
  convention.
- An anti-vacuity `It` asserting the discovered count is greater than zero. Without it, every
  subsequent assertion would pass on an empty set.
- One `It` per convention: the module-scope guard immediately after `Set-StrictMode`, the
  `-ErrorAction Stop` on every column-0 `Import-Module` line, the convention sentence above the
  `Set-StrictMode` line, and the 500-line limit.
- One `It` pinning non-leakage: after importing a guarded module, the caller's
  `$ErrorActionPreference` equals the value it held before the import.

Extended test file: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`. It
already establishes the required fixture pattern at lines 62-68 — mock `Test-Path` and `Get-Content`
inside the module scope with an in-memory JSON string, creating no temporary file and invoking no
external process. Two additions:

- A coercion-pinning `It` asserting that a true ISO-8601 instant value survives the parse as
  `System.DateTime`, and that a non-date string key survives as `System.String`. The existing fixture
  template uses `last_updated = '2026-07-06T00-00'`, which is **not** a parseable instant and is
  therefore not coerced; the new test must supply a real instant such as `2026-08-29T20:38:00Z` or it
  will assert nothing.
- A help-text `It` in the shape of `BlastRadius.Conflict.Tests.ps1:110-118`, reading rendered help
  through `Get-Help -Full | Out-String -Width 500` so console width cannot wrap the asserted literal.

Determinism: every test above is pure and in-memory. No filesystem write, no temporary file, no
network, no clock read, no dependence on `$PSVersionTable`. `.claude/rules/general-unit-test.md`
prohibits temporary files in tests; the existing mock-the-boundary pattern satisfies this.

Coverage: line coverage >= 85% per `.claude/rules/quality-tiers.md`. Pester measures no branch
coverage, so no branch gate applies. All 27 modules are already listed in `CodeCoverage.Path` (27 of
27 verified), and this feature adds no production file, so no coverage-configuration change is needed
and no new coverage entry has to be registered.

Integration scenario to retest:
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 101-126). Run it after each batch, not only at the end. It is the single most likely avoidable
CI failure in this feature.

Manual validation: none required. Item 3 is satisfied by re-running two existing tests and recording
the result.

Toolchain commands to run, in order, per batch and again at the end: PoshQC format, PoshQC analyze,
Pester, then the pytest bundle-parity test. Restart from format if any stage changes a file.

## Acceptance Criteria

Item 1 — fail-fast import guard:

- [ ] `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` exists, discovers its module list
      from disk with `Get-ChildItem -Filter '*.psm1' -File -Recurse` under the `.claude/lib` root and
      does not restate any module name, and its anti-vacuity `It 'discovers the claude library modules on disk'`
      passes by asserting the discovered count is greater than zero.
- [ ] `It 'sets the fail-fast error preference at module scope in every discovered module'` in
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes: for every discovered
      module, the line immediately following its `Set-StrictMode -Version Latest` line is
      `$ErrorActionPreference = 'Stop'`.
- [ ] `It 'guards every load-time sibling import with an explicit stop preference'` in
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes: every column-0
      `Import-Module` line in every discovered module contains `-ErrorAction Stop`.
- [ ] `It 'states the fail-fast convention in the module help block'` in
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes: every discovered module
      contains the token `imports its siblings with -ErrorAction Stop` on a line preceding its
      `Set-StrictMode -Version Latest` line.
- [ ] `It 'leaves the caller error preference unchanged after import'` in
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes: the caller-scope
      `$ErrorActionPreference` after importing a guarded module equals the value captured before the
      import.
- [ ] `It 'keeps every claude library module within the five hundred line limit'` in
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes: no discovered module
      exceeds 500 lines.
- [x] `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1`
      passes unchanged, and `.claude/lib/discovery-validation/DiscoveryValidation.psm1` still contains
      the token `Draft 2020-12 support in PowerShell 7.4`, so the condensation that freed room for the
      guard did not remove the version-floor rationale.

Item 2 — date-coercion contract:

- [ ] `It 'documents the checkpoint date-coercion contract in its comment-based help'` in
      `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` passes: the rendered
      help for `Get-OrchestratorStateCheckpoint`, read through `Get-Help -Full | Out-String -Width 500`,
      contains the token `date-coerced by ConvertFrom-Json`.
- [ ] `It 'returns an ISO-8601 valued checkpoint key as a DateTime under default date handling'` in
      `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` passes: with the
      in-memory fixture supplying `"last_updated": "2026-08-29T20:38:00Z"`, the value returned in
      `State` is `System.DateTime`, and a non-date string key in the same fixture is
      `System.String`.
- [x] A search for the token `-DateKind` across `.claude/lib/` returns zero matches, and a search for
      the token `MinimumPowerShellVersion` across `.claude/lib/orchestrator-state/` returns zero
      matches. The PowerShell floor was not raised and no version guard was added to the
      orchestrator-state modules.
- [x] A search for the token `ToString(` across `.claude/lib/orchestrator-state/` returns zero
      matches. No post-parse datetime-to-string repair was introduced.

Item 3 — truthiness verification:

- [ ] `It 'is unconditionally truthy even when its conflict key is false'` and
      `It 'documents the truthiness divergence in its comment-based help'` in
      `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` both pass, and that file
      appears nowhere in this feature's change set.
- [ ] An evidence artifact under
      `docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/`
      records the item 3 verification with the fields `Timestamp:`, `Command:`, and `EXIT_CODE:` per
      `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, and its recorded `EXIT_CODE` is
      `0`.

Cross-cutting — bundle mirror, scope, and toolchain:

- [ ] `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes. Every `.claude/**` file this feature edits has the identical edit in its counterpart
      under `extensions/drm-copilot/resources/claude-customizations/.claude/**`, covering all 54
      production files (27 repository modules and 27 mirrors).
- [ ] The change set contains no modification to `.claude/skills/parallel-plan/SKILL.md`,
      `.claude/skills/parallel-add/SKILL.md`, or `.claude/agents/parallel-planner.md`. Those files are
      Feature C.
- [ ] The change set contains no modification to any file under `.claude/rules/` or
      `.github/instructions/`, and none to
      `scripts/powershell/PoshQC/settings/pssa.settings.psd1` or
      `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- [ ] The full PowerShell toolchain — PoshQC format, then PoshQC analyze, then Pester — completes with
      zero failures in a single pass over the final tree, with the result recorded as an evidence
      artifact under
      `docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/evidence/qa-gates/`
      carrying `Timestamp:`, `Command:`, and `EXIT_CODE:`.
- [ ] Every Pester test that failed as a consequence of the new error preference is repaired inside
      this feature. The final Pester run reports zero failed tests and zero skipped tests that were
      not skipped before the change.
- [ ] Line coverage for the PowerShell suite is at or above 85% and no changed line lost coverage,
      with the coverage figure recorded in the toolchain evidence artifact.

## Risks & Mitigations

Technical or operational risks:

1. **A missed bundle mirror fails CI.** 27 pairs of files must be edited identically by hand, with no
   tooling performing the copy. Mitigation: run the pytest parity test after every batch rather than
   at the end, so a missed mirror is caught within one batch instead of at PR time.
2. **The new error preference breaks an existing Pester test.** Converting non-terminating errors to
   terminating ones in 27 modules can change the observed behavior of any test that relied on
   execution continuing past a cmdlet error. Mitigation: this is treated as in-scope work by the
   acceptance criteria above; the per-batch toolchain run surfaces it three files at a time rather
   than all at once, and the module-scope isolation means a failure is attributable to the module
   just edited.
3. **`DiscoveryValidation.psm1` is exactly at the 500-line cap.** An implementer who edits it without
   first freeing two lines will produce a 502-line file. Mitigation: the constraint is stated with
   its line count and its condensation rule above, and an acceptance criterion asserts the limit
   across all discovered modules.
4. **`OrchestratorState.psm1` has 12 lines of headroom for two items.** Mitigation: the headroom
   budget is allocated explicitly above (2 lines for item 1, at most 10 for item 2) with a stated
   fallback that moves rationale into the test file's description block.
5. **18 batches under the unoverridden cap is a long sequence with a repeated mechanical edit**,
   which raises the chance of an inconsistent insertion position across modules. Mitigation: the
   insertion position is anchored to an existing line present in all 27 files, and the
   disk-discovering test asserts the position rather than mere presence.
6. **A future module added under `.claude/lib/**` could omit the guard.** Mitigation: the convention
   test discovers modules from disk rather than from a list, so a new unguarded module fails the
   suite.

Mitigations and rollbacks:

- Rollback is a revert of the commit range. No data migration, no configuration change, and no
  destination-side state is created, so a revert restores the prior behavior exactly.

## Rollout & Follow-up

- Release/rollout steps: none beyond the normal merge. The bundle mirror is committed in the same
  change, so the next push-down delivers the guarded modules with no additional action.
- Post-fix monitoring or clean-up tasks: none. The convention test is the standing check.
- Deliberately not filed as new issues by this feature, and recorded here so the omissions are not
  read as oversights:
  - The 7.4-to-7.5 PowerShell floor decision, which remains open at
    `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md:82-84`.
  - The same `ConvertFrom-Json` date-coercion hazard at the `.claude/hooks/**` checkpoint parse
    sites, which is outside issue #598's declared `.claude/lib/**` surface and was not audited
    exhaustively.
  - The partial `$ErrorActionPreference` application within `.claude/hooks/**`, where 6 hooks set it
    and others, for example `.claude/hooks/enforce-mermaid-validation.ps1`, set `Set-StrictMode`
    without it.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/598; epic manifest
  `docs/features/epics/claude-runtime-portability/epic.md`; research artifact
  `docs/features/active/2026-08-29-blast-radius-powershell-calling-convention-598/research/2026-08-29T20-30-blast-radius-powershell-calling-convention-598-research.md`.
