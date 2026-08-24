# 2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path (Spec)

- **Issue:** #516
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-25
- **Status:** Draft
- **Version:** 0.1

## Context
`enforce-orchestration-preimplementation-gate.ps1` exempts the orchestrator checkpoint from the gate by comparing the tool's `file_path` for exact equality against the repo-relative literal `artifacts/orchestration/orchestrator-state.json`. It normalizes backslashes to forward slashes but never strips the workspace root, so an absolute path to that same file fails the exemption, matches the `\.json$` implementation pattern, and is blocked. The orchestrator cannot create its own checkpoint through the `Write` tool, which supplies absolute paths by contract.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a — hooks are PowerShell; PowerShell 7.6.5
- Command/flags used: `Write` tool with `file_path` set to an absolute Windows path ending `artifacts\orchestration\orchestrator-state.json`
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` at commit `bee15c06`; observed live during an orchestration run on 2026-08-23

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. It fails closed, so it is not a safety hole — but it blocks the documented orchestration path at its first step, and the obstruction is silent about its real cause: the message describes missing checkpoint fields, which sends the reader looking for a content problem rather than a path-comparison problem. An agent that trusts the message will try to populate fields in a file it is not permitted to create.

Not a Blocker because a workaround exists once the cause is known.


## Repro & Evidence
Steps to Reproduce:
1. Start from a worktree with no `artifacts/orchestration/orchestrator-state.json`, which is the state at the beginning of any new orchestration.
2. Attempt to create that checkpoint using the `Write` tool, passing the absolute path — for example `C:\Users\<user>\repos\<repo>\artifacts\orchestration\orchestrator-state.json`. The `Write` tool requires an absolute path, so this is not an avoidable choice.
3. Observe the hook decision.
4. As a control, invoke the hook's decision function directly with `file_path` set to the repo-relative `artifacts/orchestration/orchestrator-state.json` and observe that it is allowed.

Expected:
The checkpoint path is explicitly exempted from the gate; the exemption exists precisely so the orchestrator can write its own state before implementation begins. The exemption should hold for any path that resolves to that file, whether expressed relative to the workspace root or absolutely. Otherwise the gate blocks the one write that is a precondition for satisfying it.

Actual:
Step 2 is denied:

```text
PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require
artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder,
route metadata, lifecycle readiness, and checkpoint state before implementation begins.
```

Step 4 is allowed. The decision logic is sound; the path comparison is what fails.

The relevant code is a two-line sequence in `Invoke-OrchestrationPreimplementationGateDecision`:

```powershell
$normalized = ([string]$filePath) -replace '\\', '/'
$requiresReadyCheckpoint = Test-ImplementationPath -NormalizedPath $normalized
```

`Test-ImplementationPath` then exempts the path only on exact equality with the repo-relative literal:

```powershell
if ($NormalizedPath -eq $script:CheckpointPath) {
    return $false
}
return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
```

An absolute path survives both checks and is classified as an implementation write. The gate then reads a checkpoint that does not exist yet, cannot find the required fields, and blocks — a circular precondition: the checkpoint is required to exist before it may be created.

The same normalization gap affects the `docs/features/active/` exemption in `Test-FeatureDocumentationOrEvidencePath`, which uses `StartsWith`. An absolute path to a feature document does not start with that prefix either, so feature-documentation writes carrying absolute paths are also misclassified. That path is only reachable for the file extensions in the pattern above — a `.json` or `.yml` artifact inside a feature folder — since `.md` is not matched.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet is inlined under **Actual Behavior** above.
- Workaround used at the time: write the checkpoint through the shell with a workspace-relative path instead of the `Write` tool. That is a workaround, not a fix, and it is only discoverable by reading the hook source.


## Scope & Non-Goals

### In scope — the complete written file set

The diff writes exactly these seven repo-relative paths and nothing else:

```text
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1
docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md
```

Four production hook copies, two new Pester suites, and this specification. No other file in the repository is created, modified, moved, or deleted by this change.

Evidence artifacts produced during execution and verification are written under `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/evidence/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Those are run outputs, not source changes, and are not part of the seven-path source file set above.

### Out of scope, with reasons

| Excluded path or concern | Reason it is excluded |
| --- | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | Both canonical hook copies are already registered in `CodeCoverage.Path`. Coverage is produced without a configuration change. |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Already lists the Claude hook copy. No manifest entry is missing. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | The Codex hook copy is a recorded pre-existing exception in `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`. No manifest entry is added. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | Every existing case still passes unmodified. The file is at 461 content lines; adding the paired matrix would breach the 500-line cap in `.claude/rules/general-code-change.md`. New cases go in the new sibling suite. |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 content lines against the 500-line cap, six lines of headroom. Its byte-identity and decision assertions all still pass. A new sibling suite is required, not merely preferred. |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | All must be **run** as verification legs. None needs editing: the deny-decision schema, the transport contract, the no-Python constraint, and the root-to-bundle content equality are all unchanged by this fix. |
| `.claude/hooks/enforce-evidence-locations.ps1` and `.codex/hooks/enforce-evidence-locations.ps1` | Verified free of the defect. Both already match with `(^\|/)` and carry the source comment stating the construction handles relative and absolute forms. No follow-up issue is filed. |
| `.claude/hooks/enforce-feature-folder-order.ps1` and its Codex counterpart | Verified free of the defect. Already matches with `(^\|/)`. No follow-up issue is filed. |
| `.claude/settings.json`, `.codex/config.toml`, and their bundled mirrors | Hook registration is unchanged. |
| `.claude/lib/hook-payload/HookPayload.psm1` and any new shared helper module | Not reachable by the Codex copies, which publish through a separate pack. A cross-runtime import is forbidden by the base-state plan for issue #535 and would fail at hook load on a Codex-only destination. |
| Any file under `.claude/rules/` or `.github/instructions/` | The change adopts an idiom five existing hooks already use, introduces no new invariant, and adds no enforcement mechanism that needs prose backing. `CLAUDE.md` forbids modifying `.github/instructions/` in any case. |
| `quality-tiers.yml` | Needs no change; the tier classification of these files is unaffected. |
| `Test-OrchestrationReady`'s `StartsWith('docs/features/active/')` on the checkpoint's own `feature-folder` field | A different input class. That value is repo-relative by the checkpoint contract, not a tool-supplied path. Changing it would be over-reach. |
| The undocumented `lifecycle_ready` truthiness requirement | Named as a separate observation in the promoted record itself. Not part of this defect. |
| The `PREIMPLEMENTATION_GATE_BLOCKED` message wording | Distinguishing the two failure reasons would break existing message-substring assertions for no functional gain. Deferred. |

## Root Cause Analysis
- The hook was almost certainly written and tested against repo-relative payloads. Its tests likely construct `file_path` relative, which is why the gap is invisible to the suite — the same test-shape blind spot recorded in the resolved issue #501, where every hook test constructed a flat payload the harness never sends.
- The fix is path normalization relative to the workspace root before classification, applied once and shared. Candidate home: the existing `.claude/lib/hook-payload/` module, which already centralizes envelope parsing for exactly this reason.
- A tolerant comparison is preferable to a second literal: resolve the incoming path against the workspace root and compare the resulting repo-relative form, so both spellings work and future exemptions need only the relative literal.
- Check every other hook that classifies a `file_path` for the same pattern. `enforce-evidence-locations.ps1` and `enforce-feature-folder-order.ps1` both make path-prefix decisions and are the most likely to share it.
- Related: the checkpoint exemption also requires `lifecycle_ready` to be truthy, which is undocumented in the skill. That is a separate observation and not part of this defect.


## Proposed Fix

### Design summary (what changes where):

`Invoke-OrchestrationPreimplementationGateDecision` normalizes separators only (`-replace '\\', '/'`) and never converts an absolute path to a repo-relative one. `Test-ImplementationPath` therefore fails to exempt an absolute spelling of an orchestration checkpoint, because the checkpoint test is a `-contains` membership check against seven repo-relative literals, and fails to exempt an absolute spelling of a feature document, because `Test-FeatureDocumentationOrEvidencePath` uses `StartsWith('docs/features/active/')`. The `Write` tool supplies absolute paths by contract, so both exemptions are unreachable through that tool.

The fix replaces the two defective predicate bodies with segment-anchored `(^|/)` matching, in place, in all four hook copies. Separator normalization stays exactly where it is. No workspace root is resolved anywhere.

```powershell
function Test-FeatureDocumentationOrEvidencePath {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $NormalizedPath)

    return $NormalizedPath -cmatch '(^|/)docs/features/active/'
}

function Test-ImplementationPath {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $NormalizedPath)

    if (Test-FeatureDocumentationOrEvidencePath -NormalizedPath $NormalizedPath) {
        return $false
    }
    foreach ($checkpoint in $script:CheckpointPaths) {
        if ($NormalizedPath -match ('(^|/)' + [regex]::Escape($checkpoint) + '$')) {
            return $false
        }
    }
    return $NormalizedPath -match '\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$'
}
```

Rationale for this construction over a workspace-root strip:

- No workspace root is needed, so every root-resolution failure mode disappears: 8.3 short names, drive-letter case, symlinks, and the linked-worktree case where the worktree root is not the main repository root. A strip that fails to match leaves the path absolute and the gate denies, which would reintroduce the reported defect in a subtler, less reproducible form.
- The decision function stays pure. No new parameter, no environment read, no filesystem probe, no subprocess. The existing test seam `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ... -CheckpointRaw ...` is unchanged in both families, so no existing test signature moves.
- Five existing in-repo hooks already use this idiom for the same classification problem: `.claude/hooks/enforce-checkpoint-monotonic.ps1`, `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-evidence-locations.ps1`, `.claude/hooks/enforce-feature-folder-order.ps1`, and `Test-CodexGovernedPath` in `.codex/hooks/codex-pretooluse-file-mapping.ps1`. The repository has answered this question five times and has never resolved a workspace root inside a hook.

Case handling is deliberately zero-delta. PowerShell `-match` and `-contains` are case-insensitive; .NET `String.StartsWith(string)` is case-sensitive. The fix therefore uses case-insensitive `-match` for the checkpoint literal set, preserving the current `-contains` semantics exactly, and case-sensitive `-cmatch` for the `docs/features/active/` documentation prefix, preserving the current `StartsWith` semantics exactly. A source comment must record this choice so that a later reader does not normalize `-cmatch` into `-match`.

### Boundaries and invariants to preserve:

1. **The negative half is mandatory.** An absolute path to a production source file — for example the absolute spelling of a `.ps1` or `.py` file — must still classify as an implementation path and must still be denied when the checkpoint is not ready. A fix that allowed everything absolute would be worse than the defect.
2. **Idempotence for relative paths.** `(^|/)` matches at `^`, so an already-relative path is classified exactly as it is today. This is load-bearing: the Codex `Test-ImplementationCommand` calls `Test-ImplementationPath` with repo-relative paths harvested from `apply_patch` file markers.
3. **`Test-OrchestrationReady` is not touched.** Its `StartsWith('docs/features/active/')` reads the checkpoint's own `feature-folder` value, which is repo-relative by the checkpoint contract, not a tool-supplied path. Conflating the two is the most likely over-reach in this item.
4. **Classification is the only behavior that changes.** `Test-ImplementationCommand`, `Test-PreparationModeDelegation`, `Test-ImplementationDelegation`, `Get-CheckpointContent`, the payload-anomaly path, the deny reason text, and the decision-JSON schema are all unmodified.
5. **The gate remains fail-closed.** Nothing moves a deny to an allow except the two exemptions the gate already grants in the relative spelling.
6. **Family parity.** The two Claude copies remain byte-identical to each other and the two Codex copies remain byte-identical to each other. The two families remain distinct from each other; they differ in payload plumbing, in `apply_patch` handling, and in malformed-input behavior, and none of those differences is reconciled here.
7. **The Codex exit-code contract is unmodified** (0 for a decision, 2 for a transport failure).

Two consequences are accepted and recorded rather than hidden:

- **Segment-anchored widening.** The predicate also exempts a path outside the workspace whose tail is exactly a `.../artifacts/orchestration/` segment followed by one of the seven checkpoint names. Measured exposure in this worktree: a glob of the pattern `artifacts/orchestration` JSON files returns exactly one file, the real checkpoint. There is no nested or vendored second copy. The same widening has already been accepted four times for the identical literal in two other hooks. Accept it and state it in the hook comment.
- **Accepted fail-closed miss.** A path containing `..` segments, for example an `artifacts/orchestration/` prefix followed by a `..` hop back into `orchestration/orchestrator-state.json`, remains **denied**. The `Write` tool does not emit `..` segments, and adding a canonicalizer would reintroduce filesystem dependence for no measured benefit. This is a known, deliberate miss, not an oversight.

### Dependencies or blocked work:

- The branch is based on `origin/bug/preimplementation-gate-blocks-planner-surfaces-535` (head `c308dd92`), not on `origin/main`. PR #536 is open and unmerged and rewrote the same hook. The seven-literal `$script:CheckpointPaths` array and the `Test-PreparationModeDelegation` helper are **base state** for this item, not work of it.
- The base-state plan for issue #535 forbids adding a cross-runtime import of `.claude/lib/hook-payload/HookPayload.psm1` into the Codex hooks. That prohibition is settled and is what fixes the placement decision.
- No external service, library, or release is required.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

The four production hook copies and the two new Pester suites listed under **Scope & Non-Goals**. No shared helper module is created.

A shared helper was evaluated and rejected on cost: it would require creating a new module plus its bundled mirror, a Codex-reachable copy plus its bundled mirror, entries in two pack manifests, entries in two runsettings files, a new test suite, and an edit to the shared-module name list in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — twelve or more written files to share four lines of regex, against four files for the in-place edit. The repository already accepts family duplication for this hook and gates it with byte-identity and content-equality tests.

`.claude/rules/powershell.md` caps a batch at 3 production files and 3 test files. Four production copies are in scope, so the implementation must split into two batches: batch 1 is the two Claude hook copies plus the Claude test file; batch 2 is the two Codex hook copies plus the Codex test file. The Codex pair must land byte-identical **in the same commit**, or the byte-identity assertion in `legacy-codex-hook-contracts.Tests.ps1` fails. The PowerShell batch-budget session state must be reset between the two batches.

#### Functions/classes/CLI commands impacted:

- `Test-FeatureDocumentationOrEvidencePath` — body replaced with `-cmatch '(^|/)docs/features/active/'`. Signature unchanged.
- `Test-ImplementationPath` — the `-contains` membership check replaced with a segment-anchored `-match` loop over `$script:CheckpointPaths`. Signature unchanged. Evaluation order (documentation exemption, then checkpoint exemption, then extension regex) unchanged.

No other function in any copy is modified. No CLI command, MCP tool, or hook registration is added or changed.

#### Data flow and validation changes:

The tool-supplied `file_path` continues to flow through `Get-StringProperty`, then through the unchanged `-replace '\\', '/'` separator normalization, then into `Test-ImplementationPath`. Only the two predicates inside that last step change. Intended behavior after the change, stated as decision rules over the separator-normalized `file_path`:

1. A path whose text contains the segment `docs/features/active/` at the string start or immediately after a `/` is **not** an implementation path, in either spelling and either separator style, with case sensitivity preserved.
2. A path whose text ends with one of the seven checkpoint literals at a segment boundary is **not** an implementation path, in either spelling and either separator style, case-insensitively.
3. Any other path matching `\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$` **is** an implementation path, in either spelling.
4. Rules 1 and 2 are evaluated in that order, unchanged.

Note on the harm window, which determines how test cases must be written: the exemptions are load-bearing whenever `artifacts/orchestration/orchestrator-state.json` is **absent, unparseable, or not-ready** — not only before the file exists. Once a ready checkpoint exists, `Test-OrchestrationReady` short-circuits to allow and masks the misclassification, which is why the defect presents as a bootstrap-window failure.

#### Error handling and logging updates:

None. No new error path, no new `Write-Debug`, `Write-Error`, or `throw`, and no change to the `PREIMPLEMENTATION_GATE_BLOCKED` reason text. The existing suites assert the current message substrings and this item must not disturb them.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. Rollback is restoring two expressions per file across four files. There is no data migration, no schema change, and no published-artifact coupling beyond the two bundle mirrors, which are gated by existing tests.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Unchanged. `Invoke-OrchestrationPreimplementationGateDecision` accepts `-ToolInputRaw` (the serialized tool payload) and an optional `-CheckpointRaw`, and returns an ordered dictionary whose `hookSpecificOutput` carries `hookEventName = 'PreToolUse'`, `permissionDecision` of `allow` or `deny`, and, on deny, `permissionDecisionReason`. The emitted JSON schema is byte-compatible with the current output.

#### Required configuration keys and defaults:

None. `$script:CheckpointPaths` keeps its existing seven repo-relative literals; no absolute literal is added, because an absolute prefix is machine- and worktree-specific and unknowable at authoring time.

#### Backward-compatibility expectations:

Every currently-allowed relative spelling stays allowed and every currently-denied path stays denied, with the sole intended exception of the absolute spellings of the two exemptions. Two pre-existing deny cases from issue #535 survive unchanged: an `artifacts/orchestration/` file whose name is not one of the seven literals still denies, and a checkpoint-named file outside `artifacts/orchestration/` still denies because the required segment is absent.

#### Performance constraints (latency/throughput/memory):

The hook runs once per governed tool call. The change replaces one `-contains` membership test with a loop of at most seven bounded regular-expression matches over a short string, and one `StartsWith` with one anchored match. No I/O and no subprocess is added. The added cost is not measurable against the existing process-start cost of the hook, and no latency budget is defined or required.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): PowerShell 7+ on Windows; PoshQC and Pester 5.x available through the MCP server; Poetry available for the single pytest verification leg. No network access is required by any step. The `Write` tool supplies absolute `file_path` values by contract; that is the input shape the fix is written against.
- Constraints (budget, performance, compatibility): `.claude/rules/powershell.md` per-batch cap of 3 production and 3 test files forces the two-batch split described above. `.claude/rules/general-code-change.md` caps every file at 500 lines, which forces the two new test suites to be new files rather than extensions of the existing ones. All four hook copies must stay PowerShell 7+ compatible and must remain free of any interpreter invocation, which the AST scanner `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` enforces with an empty allowlist.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact
- User-facing or API changes: none. The hook's decision JSON schema, its exit-code contract, and its registration in `.claude/settings.json` and `.codex/config.toml` are unchanged.
- Data or migration considerations: none. No persisted artifact format changes; the orchestrator checkpoint contract is untouched.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag, config key, or schema version changes. `$script:CheckpointPaths` keeps its seven existing entries.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas — for each exemption in the hook, a paired test asserting the same decision for the repo-relative and the absolute spelling of the same path, on both separator styles. Keep the existing relative cases and add absolute twins; replacing them would relocate the blind spot rather than close it.
- [x] Integration scenario to retest — end-to-end: with no checkpoint present, a `Write` of the checkpoint via its absolute path must be allowed, and a `Write` of a production source file via its absolute path must still be blocked. Both halves are required; a fix that allowed everything absolute would be worse than the defect.
- [x] Manual verification notes — confirm the gate still blocks genuine implementation writes after the change, and confirm the block message is reached only for real checkpoint-content failures. Consider distinguishing the two failure reasons in the message text so the next reader is not misdirected.

### Two new Pester suites, no edits to the existing suites

New cases land in two new sibling suites rather than in the existing files, because both existing files are at or near the 500-line cap in `.claude/rules/general-code-change.md`:

| New suite | Covers | Why a new file |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | The Claude canonical copy, dot-sourced. Paired relative/absolute matrix over the seven checkpoint literals, the documentation exemption, and the negative half. | The existing suite is 461 content lines. The paired matrix plus a re-declaration of the literal list (which currently lives in a sibling `Context`'s `BeforeAll` and is not visible to a new `Context`) lands the file at or above the cap. |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | The Codex canonical copy, dot-sourced. The same matrix plus the `apply_patch` idempotence proof. | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is at 494 content lines against a 500-line cap — six lines of headroom. Even the most compact table-driven `It` covering one allow, one documentation allow, and one deny exceeds it. A new file is required, not merely preferred. |

Each new suite must itself stay under 500 lines. Neither existing suite is edited: every case in both still passes unmodified.

Both hooks guard their entry point with `if ($MyInvocation.InvocationName -eq '.') { return }`, so dot-sourcing exposes the pure decision function without executing the entry point. The existing suites already use this seam and the new suites reuse it. No disk I/O, no child process, no temporary file, and no fixture file is created by any new case.

### Synthetic absolute prefixes — never derived from the runtime environment

Every absolute path string in the new suites must be a **synthetic constant** declared in the suite, never derived from `$PSScriptRoot`, `$PWD`, `Resolve-Path`, an environment variable, or a `git` invocation. Because the shipped predicate is a pure segment-anchored suffix match, the real checkout root is irrelevant to every assertion, and a synthetic prefix makes the suites independent of checkout location, of operating system, and of the linked-worktree layout. This satisfies the determinism requirements in `.claude/rules/powershell.md` ("tests must not depend on implicit working-directory assumptions") and `.claude/rules/general-unit-test.md`.

Three prefix shapes must be exercised for each covered path:

1. A Windows-shaped forward-slash absolute prefix, for example a `C:/` drive root followed by fixed synthetic directory segments.
2. A POSIX-shaped absolute prefix, for example a leading `/` followed by fixed synthetic directory segments.
3. A Windows-shaped backslash absolute prefix, which proves the existing upstream `-replace '\\', '/'` normalization still feeds the new predicates correctly.

A UNC-shaped prefix is a permitted fourth shape and is expected to behave identically.

### Mandatory explicit not-ready checkpoint on every new case

**Every new case — allow and deny alike — must pass an explicit not-ready `-CheckpointRaw` argument**, built the way the existing suite builds it (`ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false` or the equivalent local helper).

This is not stylistic. A case that omits `-CheckpointRaw` falls through to `Get-CheckpointContent`, which reads `artifacts/orchestration/orchestrator-state.json` relative to the process working directory. That file exists in this worktree and is ready during an orchestrated run, so `Test-OrchestrationReady` short-circuits to allow. An allow assertion would then pass **vacuously**, proving nothing about the classification under test, and a deny assertion would read allow and fail for the wrong reason. A new case without an explicit not-ready checkpoint is a defect in the test, regardless of whether it passes.

### Scenario coverage required of the plan

Positive half (allow), each with an explicit not-ready checkpoint:

- For each of the seven literals in `$script:CheckpointPaths`: the repo-relative spelling (regression), the absolute forward-slash spelling, and the absolute backslash spelling.
- Documentation exemption: a repo-relative `.json` artifact under `docs/features/active/` (regression), its absolute forward-slash spelling, and its absolute backslash spelling. `.md` is not in the extension pattern, so the reachable case is a `.json` or `.yml` artifact inside a feature folder.
- A `./`-prefixed relative checkpoint spelling, which the anchor admits via the `/` of `./`.

Negative half (deny), each with an explicit not-ready checkpoint, and each expected to **pass both before and after** the fix so that the run demonstrates the gate did not simply open:

- An absolute spelling of a production `.ps1` file.
- An absolute spelling of a production `.py` file.
- An absolute spelling of an `artifacts/orchestration/` JSON file whose name is not one of the seven literals.
- An absolute spelling of a checkpoint-named JSON file that is not under an `artifacts/orchestration/` segment.
- An absolute path whose text reaches a checkpoint name only through a `..` hop. This asserts the accepted fail-closed miss explicitly rather than leaving it undocumented.
- A case-varied absolute spelling of the `docs/features/active/` prefix, which must still deny, proving the `-cmatch` case sensitivity was preserved.

Case-handling assertions:

- A case-varied absolute spelling of a checkpoint literal must **allow**, proving the case-insensitive `-match` preserved the previous `-contains` semantics.

Codex-specific:

- A repo-relative `apply_patch` file-marker path routed through `Test-ImplementationCommand` classifies exactly as it does today, in both the allow and the deny direction. This is the idempotence proof for the call site that passes repo-relative paths.

### Fail-before / pass-after shape

The regression evidence must be a single run of the new suites captured twice.

- **Fail-before.** Against the unmodified hook copies, run both new suites. The positive-half absolute cases must **fail** with `permissionDecision` equal to `deny`. The negative-half cases must **pass**. Capture the run output to `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/evidence/regression-testing/`.
- **Pass-after.** Apply the fix, re-run both suites. All cases must pass. Capture the run output to the same evidence directory.

A fail-before capture in which the positive-half cases pass is invalid: it means the case omitted its explicit not-ready `-CheckpointRaw` and passed vacuously against the on-disk checkpoint. That capture must be discarded and the case corrected.

### Existing suites to run without editing

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (its byte-identity assertion over the Codex pair is the parity gate for that family)
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — asserts content equality for every repo `.claude/**` file against its bundled counterpart. This is the parity gate for the Claude family; no new parity test is needed.

### Coverage

Both canonical hook copies are already registered in `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, so per-file line coverage is produced with no configuration change. Coverage output lands at `artifacts/pester/powershell-coverage.xml` and test results at `artifacts/pester/pester-junit.xml`. `CoveragePercentTarget` is `0`, so the run never fails on percentage; the threshold check is the reader's responsibility and must be read from the **per-file** counters, not from the aggregate console summary.

Per `.claude/rules/quality-tiers.md`, the uniform line threshold of >= 85% applies. PowerShell is exempt from the branch-coverage threshold because Pester does not measure branch coverage; that exemption is a capability limit on an unevaluable threshold, not a licence to exclude a file. Both hook copies remain in the coverage denominator. The two bundle mirrors are executed by no suite and inherit their measurement through SHA256 equality with their canonical counterparts.

### Toolchain commands to run (format → lint → type-check → test)

Per `.claude/rules/powershell.md`, run in order and restart from step 1 whenever a stage fails or rewrites a file:

1. **Format** — `mcp__drm-copilot__run_poshqc_format`
2. **Analyze** — `mcp__drm-copilot__run_poshqc_analyze` (optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`)
3. **Type check** — not applicable to PowerShell; skip
4. **Test** — `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
5. **Push-down parity leg** — `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

Do not substitute VS Code task wrappers.

### Manual validation steps (if required)

None are required. Every verification step is a non-interactive command: allow/deny is a string comparison on `permissionDecision`, coverage is a numeric read from `artifacts/pester/powershell-coverage.xml`, byte-identity is a `Get-FileHash` comparison, and parity is a pytest exit code. No step prompts, requires credentials, or requires a network.


## Acceptance Criteria

Each criterion below is decidable PASS or FAIL from a named command output or a named file inspection.

Evidence annotations below use paths relative to this feature folder, `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/`. Every named artifact exists on disk. One criterion is deliberately left unticked; the reason is stated inline.

### Positive half — absolute checkpoint spellings are allowed

- [x] For each of the seven literals in `$script:CheckpointPaths`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` contains a passing case that calls `Invoke-OrchestrationPreimplementationGateDecision` with a `Write` payload whose `file_path` is a synthetic forward-slash absolute prefix joined to that literal, together with an explicit not-ready `-CheckpointRaw`, and asserts `permissionDecision` equals `allow`. Seven passing cases, one per literal, verified from the Pester run output.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — the seven "allows the forward-slash absolute spelling of ..." cases all report pass.
- [x] The same suite contains a passing case per literal using a synthetic **backslash** absolute prefix, asserting `permissionDecision` equals `allow`, proving the upstream separator normalization still feeds the new predicate.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — the seven "allows the backslash absolute spelling of ..." cases all report pass.
- [x] The same suite contains at least one passing case using a synthetic **POSIX-shaped** absolute prefix (leading `/`), asserting `permissionDecision` equals `allow`.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "admits the POSIX-shaped absolute spelling of artifacts/orchestration/orchestrator-state.json" reports pass.
- [x] `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` contains the equivalent absolute-spelling allow cases against the dot-sourced `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, all passing.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — Codex suite, 35 of 35 cases pass; `evidence/regression-testing/pass-after-codex-batch.2026-08-23T23-25.md`.
- [x] A case with the relative spelling `./artifacts/orchestration/orchestrator-state.json` asserts `permissionDecision` equals `allow`, confirming the leading `./` form is admitted by the segment anchor.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "admits the leading dot-slash relative spelling of ..." reports pass in both suites.

### No regression on the relative spellings

- [x] For each of the seven literals, a passing case asserts that the plain repo-relative spelling still yields `permissionDecision` equal to `allow` under an explicit not-ready `-CheckpointRaw`.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — the seven "allows the repo-relative spelling of ..." cases pass in both suites, and they also passed in the fail-before capture, confirming no regression.
- [x] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` passes with zero modifications; `git diff` against the branch base shows no change to that file.
  - Evidence: `evidence/qa-gates/final-poshqc-test.2026-08-23T23-25.md` (35/35 pass) and `evidence/qa-gates/file-set-discipline.2026-08-23T23-25.md` ([P5-T2] section: absent from the changed-path union).
- [x] `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes with zero modifications; `git diff` against the branch base shows no change to that file. Its pre-existing deny cases for an `artifacts/orchestration/` file outside the seven literals and for a checkpoint-named file outside `artifacts/orchestration/` both still report pass.
  - Evidence: `evidence/regression-testing/pass-after-codex-batch.2026-08-23T23-25.md` (43/43 pass, zero failures, so every case including the two named deny cases passes) and `evidence/qa-gates/file-set-discipline.2026-08-23T23-25.md` ([P5-T2] section: absent from the union).

### Negative half — absolute production paths are still denied

- [x] A passing case asserts that a synthetic absolute path ending in a production `.ps1` file yields `permissionDecision` equal to `deny` under an explicit not-ready `-CheckpointRaw`.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "denies a synthetic absolute path ending in a production .ps1 file" passes in both suites.
- [x] A passing case asserts the same for a synthetic absolute path ending in a production `.py` file.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "denies a synthetic absolute path ending in a production .py file" passes in both suites.
- [x] A passing case asserts `deny` for a synthetic absolute path ending in an `artifacts/orchestration/` JSON file whose name is not one of the seven literals.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "denies ... an orchestration JSON whose name is not one of the seven literals" passes in both suites.
- [x] A passing case asserts `deny` for a synthetic absolute path ending in a checkpoint-named JSON file that is not preceded by an `artifacts/orchestration/` segment.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "denies ... a checkpoint-named JSON with no preceding artifacts/orchestration segment" passes in both suites.
- [x] A passing case asserts `deny` for a synthetic absolute path that reaches a checkpoint name only through a `..` segment, recording the accepted fail-closed miss as an asserted behavior rather than an undocumented gap.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "denies ... a checkpoint name reached only through a parent-directory hop" passes in both suites. The `..` hop sits inside the `artifacts/orchestration/` segment itself, so the case denies both before and after the fix.
- [x] Every negative-half case above reports **pass in both the fail-before and the pass-after capture**, demonstrating the fix did not open the gate.
  - Evidence: `evidence/regression-testing/fail-before-new-suites.2026-08-23T23-25.md` (all five deny cases listed among the passing cases in a run with 38 failures) and `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` (all five pass again).

### Documentation exemption and case sensitivity

- [x] A passing case asserts `permissionDecision` equals `allow` for a repo-relative `.json` artifact path beginning with `docs/features/active/`, under an explicit not-ready `-CheckpointRaw`.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "allows the repo-relative spelling of a feature-folder .json artifact" passes in both suites.
- [x] Passing cases assert `allow` for the same artifact expressed with a synthetic forward-slash absolute prefix and with a synthetic backslash absolute prefix.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — both absolute documentation spellings pass in both suites, having failed in the fail-before capture.
- [x] A passing case asserts `permissionDecision` equals `deny` for a synthetic absolute path whose feature-documentation prefix differs only in letter case, confirming `-cmatch` preserved the case-sensitive `StartsWith` semantics exactly.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "denies an absolute path whose documentation prefix differs only in letter case" passes in both suites, and passed in the fail-before capture as well.
- [x] A passing case asserts `permissionDecision` equals `allow` for a synthetic absolute checkpoint path whose literal differs only in letter case, confirming the case-insensitive `-match` preserved the `-contains` semantics exactly.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — "allows an absolute checkpoint path whose literal differs only in letter case" passes in both suites, having failed in the fail-before capture.

### Idempotence and untouched behavior

- [x] `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` contains passing cases proving that a repo-relative `apply_patch` file-marker path routed through `Test-ImplementationCommand` produces the same classification as before the change, in both the allow and the deny direction.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — both `apply_patch` idempotence cases pass, and both also passed in the fail-before capture, which is what makes them an idempotence proof.
- [x] `git diff` against the branch base shows that within each of the four hook copies, the only modified function bodies are `Test-FeatureDocumentationOrEvidencePath` and `Test-ImplementationPath`. `Test-OrchestrationReady`, including its `StartsWith('docs/features/active/')` on the checkpoint's own `feature-folder` field, `Test-PreparationModeDelegation`, `Test-ImplementationDelegation`, `Get-CheckpointContent`, the payload-anomaly path, the `PREIMPLEMENTATION_GATE_BLOCKED` reason text, and the entry points are all byte-unchanged.
  - Evidence: `evidence/qa-gates/scope-confinement.2026-08-23T23-25.md` — exactly two hunks per copy, both inside the two target functions, plus a direct brace-balanced body extraction reporting BYTE-UNCHANGED for every named symbol in both canonical copies.
- [x] `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` and `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` both pass with zero modifications.
  - Evidence: `evidence/regression-testing/pass-after-claude-batch.2026-08-23T23-25.md` (15/15), `evidence/regression-testing/pass-after-codex-batch.2026-08-23T23-25.md` (56/56), and `evidence/qa-gates/file-set-discipline.2026-08-23T23-25.md` ([P5-T2]: both absent from the union).
- [x] `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with zero modifications, confirming no interpreter invocation was introduced into any hook copy.
  - Evidence: `evidence/qa-gates/no-python-invocation.2026-08-23T23-25.md` — 27/27 pass, including the empty-allowlist repository scan over both guarded hook roots.

### Four-copy parity

- [x] All four hook copies listed in **Scope & Non-Goals** contain the segment-anchored predicates; `git diff --stat` against the branch base lists all four paths as modified.
  - Evidence: `evidence/qa-gates/scope-confinement.2026-08-23T23-25.md` — `git diff --stat` reports "4 files changed, 128 insertions(+), 12 deletions(-)" across all four copies.
- [x] `Get-FileHash` reports identical SHA256 values for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`.
  - Evidence: `evidence/qa-gates/four-copy-parity-hashes.2026-08-23T23-25.md` — both `658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207`.
- [ ] `Get-FileHash` reports identical SHA256 values for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and the Codex pair lands in a single commit so the byte-identity assertion in `legacy-codex-hook-contracts.Tests.ps1` never observes a split state.
  - **Deliberately left unticked.** The hash half is satisfied — `evidence/qa-gates/four-copy-parity-hashes.2026-08-23T23-25.md` records both Codex copies at `98DC6917AE5AE3239DBE89C31391960D260AB74B83A51D93FA9D575AA16DBABD`, and both were made byte-identical in the working tree before any commit existed. The single-commit half is satisfied by orchestrator-side commit sequencing, which lies outside plan execution, so no executor evidence can prove it. Tick this only after the Codex pair has actually landed in one commit.
- [x] `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` exits 0, confirming Claude root-to-bundle content equality.
  - Evidence: `evidence/qa-gates/final-pytest-pushdown-parity.2026-08-23T23-25.md` — 10 passed, EXIT_CODE 0.

### Toolchain

- [x] `mcp__drm-copilot__run_poshqc_format` reports no files requiring reformatting on a final clean pass.
  - Evidence: `evidence/qa-gates/final-poshqc-format.2026-08-23T23-25.md` — zero files rewritten, confirmed by SHA256 comparison of all six PowerShell files before and after the run.
- [x] `mcp__drm-copilot__run_poshqc_analyze` reports zero PSScriptAnalyzer findings across the six changed PowerShell files.
  - Evidence: `evidence/qa-gates/final-poshqc-analyze.2026-08-23T23-25.md` — per-file counts of 0 for each of the six files, total 0.
- [x] `mcp__drm-copilot__run_poshqc_test`, using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, reports zero failed and zero errored tests in `artifacts/pester/pester-junit.xml`.
  - Evidence: `evidence/qa-gates/final-poshqc-test.2026-08-23T23-25.md` — 3476 tests, 0 failures, 0 errors.
- [x] The format, analyze, and test stages all complete in a single pass in that order with no stage failing or rewriting a file.
  - Evidence: `evidence/qa-gates/final-clean-pass.2026-08-23T23-25.md` — the confirmed pass, with the two earlier abandoned attempts and their causes recorded.

### Coverage

- [x] The per-file line-coverage percentages read from `artifacts/pester/powershell-coverage.xml` for `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` are each at or above 85%.
  - Evidence: `evidence/qa-gates/final-powershell-coverage.2026-08-23T23-25.md` — 90.09% (100/111) and 99.19% (122/123).
- [x] Every line changed by this diff in either canonical hook copy is reported as covered in `artifacts/pester/powershell-coverage.xml`, so there is no coverage regression on changed lines.
  - Evidence: `evidence/qa-gates/coverage-delta.2026-08-23T23-25.md` — 4 instrumented changed lines per canonical copy, all COVERED, zero uncovered; neither per-file percentage decreased against the `evidence/baseline/baseline-powershell-coverage.2026-08-23T23-25.md` baseline.
- [ ] The spec records, and the reviewer confirms, that PowerShell is exempt from the >= 75% branch-coverage threshold under `.claude/rules/quality-tiers.md` because Pester does not measure branch coverage, and that this exemption does not remove either hook copy from the coverage denominator. Neither hook copy appears in any coverage exclusion list.
  - Evidence: this spec records the exemption in its **Coverage** section under **Test Strategy**, and `evidence/qa-gates/final-powershell-coverage.2026-08-23T23-25.md` restates it and confirms both copies are measured. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` carries no coverage exclusion list at all — it uses an inclusion list, `CodeCoverage.Path`, in which both canonical copies are registered, which is why both appear with counters in `artifacts/pester/powershell-coverage.xml`. Note: the "reviewer confirms" clause remains an independent reviewer action; the executor-verifiable content is fully evidenced above. The orchestrator reverted this checkbox to unticked, because the criterion names the reviewer as a required actor and the `acceptance-criteria-tracking` skill permits a tick only once the work satisfying the criterion is verified. `feature-review` is the correct actor to tick it.

### Regression evidence

- [x] A fail-before capture exists under `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/evidence/regression-testing/` showing the positive-half absolute cases reporting `deny` and failing against the unmodified hook copies, with the negative-half cases passing in the same run.
  - Evidence: `evidence/regression-testing/fail-before-new-suites.2026-08-23T23-25.md` — EXIT_CODE 38, 19 failed cases in each new suite, all 38 named, with every negative-half case passing in the same run.
- [x] A pass-after capture exists in the same directory showing every case in both new suites passing against the fixed hook copies.
  - Evidence: `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — EXIT_CODE 0, all 68 cases named and passing, against the identical 1600-test population as the fail-before run.
- [x] Every case in both fail-before and pass-after captures supplied an explicit not-ready `-CheckpointRaw`; no case relies on the on-disk `artifacts/orchestration/orchestrator-state.json`, so no allow assertion passes vacuously.
  - Evidence: `evidence/regression-testing/fail-before-new-suites.2026-08-23T23-25.md`, [P1-T13] section — a structural audit shows the Claude suite has exactly one call site to the decision function and the Codex suite exactly two, each supplying `-CheckpointRaw (ConvertTo-NotReadyCheckpointRaw)` unconditionally, so no case can reach the on-disk checkpoint by any path.

### File-set discipline

- [x] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` and `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` each exist and each contains fewer than 500 lines.
  - Evidence: `evidence/qa-gates/synthetic-path-constant-audit.2026-08-23T23-25.md` — 223 lines and 242 lines respectively, both under the 500-line cap.
- [x] Every absolute path string in both new suites is a literal constant declared in the suite. A search of both files finds no use of `$PSScriptRoot`, `$PWD`, `Resolve-Path`, `Get-Location`, or a `git` invocation to construct a test path.
  - Evidence: `evidence/qa-gates/synthetic-path-constant-audit.2026-08-23T23-25.md` — `Get-Location`, `PWD`, and the source-control executable name each occur **zero** times in both suites. `Resolve-Path` and `PSScriptRoot` each occur **exactly once per suite**, together on the single `BeforeAll` hook-locating line (line 141 in the Claude suite, line 132 in the Codex suite). That line resolves only the file to dot-source and constructs no path that any case asserts against, so it is not test-path construction, which is the qualifier this criterion carries. All three synthetic absolute prefixes in each suite are bare string literals.
- [x] The union of `git diff --name-only` against the branch base and `git status --porcelain --untracked-files=all` contains all seven paths listed under **Scope & Non-Goals**, and every other path in that union lies under `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/`, which holds this item's own planning documents and its `evidence/` tree. No file under `.claude/rules/`, no file under `.github/instructions/`, and no `quality-tiers.yml` appears in that union.
  - Evidence: `evidence/qa-gates/file-set-discipline.2026-08-23T23-25.md` — all seven declared paths present, every other path under this feature folder, and zero paths under `.claude/rules/`, `.github/instructions/`, or named `quality-tiers.yml`.

## Risks & Mitigations
- Technical or operational risks:
  - **Over-widening the gate.** A predicate that exempts too much would turn a fail-closed gate into a permissive one. Mitigated by the mandatory negative half: four deny cases must pass both before and after the fix.
  - **Over-reach into `Test-OrchestrationReady`.** Its `StartsWith('docs/features/active/')` looks identical to the defective one but reads a different input class. Mitigated by an explicit acceptance criterion asserting that only the two named predicate bodies changed in each copy.
  - **Split Codex pair.** Landing the two Codex copies in separate commits fails the byte-identity assertion in `legacy-codex-hook-contracts.Tests.ps1`. Mitigated by the batch plan, which requires the pair in a single commit.
  - **Vacuous test passes.** A new case that omits `-CheckpointRaw` reads the ready on-disk checkpoint and passes without exercising the classification. Mitigated by the mandatory explicit not-ready argument and by the fail-before capture, in which such a case would pass and thereby expose itself.
  - **Segment-anchored widening outside the workspace.** A path outside the workspace whose tail matches a checkpoint literal on a segment boundary becomes exempt. Exposure measured as one matching file in the tree; the same widening is already accepted in four other hooks; recorded in the hook comment.
- Mitigations and rollbacks: rollback is restoring two expressions per file across four files. No data migration, no schema change, no configuration change, no coupling beyond the two bundle mirrors that existing tests already gate.

## Rollout & Follow-up
- Release/rollout steps: merge to the parent branch for issue #535, then to `main` with the rest of that chain. The hooks take effect on the next tool call; no restart, migration, or announcement is required. The bundled mirrors ship with the next extension publication through the existing packs.
- Post-fix monitoring or clean-up tasks: confirm on the next orchestration bootstrap that a `Write` of the checkpoint through its absolute path is allowed with no checkpoint present. Two deferred items remain unfiled and out of scope: documenting the `lifecycle_ready` truthiness requirement in the orchestration skill, and distinguishing the two failure reasons in the `PREIMPLEMENTATION_GATE_BLOCKED` message text. No follow-up issue is filed for `enforce-evidence-locations.ps1` or `enforce-feature-folder-order.ps1`; both were verified free of this defect.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/516
  - Base-state PR (open, unmerged): #536 for issue #535
  - Research: `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/research/2026-08-23T23-40-preimplementation-gate-absolute-path-516-research.md`
  - Rules: `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
