# Research: codex-gates-4-5-lack-epic-scope (Issue #707)

- Timestamp: 2026-09-26T23-00
- Branch: `bug/codex-gates-4-5-lack-epic-scope-707` (base `origin/main` 218b518e)
- Requirements source: `docs/features/active/codex-gates-4-5-lack-epic-scope-707/issue.md` (AC-1 to AC-5)
- Precedent: issue #663, PR #700, feature folder `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/`

## 0. Method and limits

- Every finding below was verified by reading files in this worktree with Read, Grep, and Glob.
- No shell was available to this researcher, so `gh issue view 663`, `git log --grep 663 origin/main`, and `git show --stat` were NOT run. The #663 commit SHAs and per-commit file lists are taken from `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/commits.md`. That file records the #663 feature-branch commits. It does not record the PR #700 merge commit, and this research does not record it either. The planner should verify the SHAs with `git log --oneline --grep 663 origin/main` before citing them in spec.md.
- The #663 code is present on this base. `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` exist, and the Claude gate calls the epic-scope decision at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:387-394`.
- The sibling feature folders (#708, #709, #710, #713) are not on this branch. The overlap analysis in section 6 uses the delegation descriptions and #663 follow-ups 2, 6, and 8 (`.../663/evidence/other/follow-ups.md:9,21,25`).

## 1. #663 reference design (the precedent)

### 1.1 Decisions that govern the port

`.../663/spec.md:67-74`:

- **D1:** Codex gate-4 and gate-5 fixes were deferred. The four byte-identical `enforce-orchestration-preimplementation-gate-helpers.ps1` copies were the only exception.
- **D2:** In epic scope, a production (non-bookkeeping) operand may be staged or edited only while `MERGE_HEAD` exists in the effective worktree. The check goes through a mockable seam.
- **D3 (gate 5):** No production code change. Behaviour was pinned by tests: a completion-asserting Write/Edit to `artifacts/orchestration/epic-orchestrator-state.json` is not intercepted, and a per-feature checkpoint whose `feature-folder` is `docs/features/epics/<slug>` is still denied.
- **D5:** The epic readiness predicates are PowerShell-authoritative, and no hook calls Python.

`.../663/evidence/qa-gates/p7-d1-scope.md:4-18` shows that the three Codex hooks and the Claude modes file had an empty diff against `origin/main`.

### 1.2 #663 commits and Claude-side files (from `.../663/evidence/other/commits.md`)

| Batch | Commit | Gate-4/5 relevant files |
| --- | --- | --- |
| B1 | 3c842d1c | four helpers copies; `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (lines 11-18) |
| B2 | fd9e9c50 | `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, `EpicScopeReadiness.psm1`, their bundle mirrors, `pack-manifests/core.json` (Claude), both `pester.runsettings.psd1` copies, `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`, `EpicScopeReadiness.Tests.ps1`, `WorktreeResolution.Manifest.Tests.ps1` (lines 20-27) |
| B2r | ed7e8059 | resolver remediation (lines 29-36) |
| B5 | da84e31b | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (new), `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, mirrors, Claude `core.json`, both runsettings, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` (lines 56-64) |
| B6 | a574c89a | `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` (D3 pinning rows), plus contract docs (lines 66-73) |
| P8 | c56ddd11 | EpicScope suite coverage rows (lines 84-91) |
| Rem1 | b18a11ef, 50a7fc88 | helpers backslash fail-closed; head-matched scope decided from the effective worktree (lines 111-127) |

### 1.3 Claude gate-4 design as implemented

- The gate dot-sources the sibling at `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:22-24`. The decision function consults the epic scope for the command and path legs only (lines 387-394). If the call is not epic scope, the result is `$null` and the unchanged single-feature path runs (lines 417-429).
- Sibling `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`:
  - Imports the two lib modules (lines 30-31).
  - Holds `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent`, which were moved out of the gate for line headroom (lines 33-58).
  - Defines `Get-OrchestrationEpicScopeSelector`, which reads the `git -C` selector (lines 60-86).
  - Defines `Get-OrchestrationEpicScopeDecision` (lines 88-127). It calls `Resolve-EpicScopeCheckpoint -Text $Command -SessionRoot (Get-Location).Path -WorktreeSelector $selector -MatchWorktreeHead` and then `Get-EpicCommandLegReadinessFailure`. The deny reason names the epic checkpoint path and the failed conjunct (line 126).
- Resolver `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`:
  - Read seams: `Get-EpicScopeCheckpointText` (lines 120-138), `Get-EpicScopeWorktreeHeadBranch` (219-248), `Test-EpicScopeMergeInProgress` (250-271).
  - Decision: `Resolve-EpicScopeCheckpoint` (273-360). Reason codes: `no-branch-signal`, `session-root-unresolved`, `epic-checkpoint-absent-or-unparseable`, `route_id`, `integration_branch`, `selector-unresolved`, `branch-mismatch`, `epic-scope`.
  - Dependencies: it imports `WorktreeResolution.psm1` and `WorktreeTargetResolution.psm1` (lines 36-37). From them it uses `Find-WorktreeResolutionRoot`, `Join-WorktreeResolutionPath`, `ConvertTo-WorktreeResolutionNormalizedPath`, `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, and `Find-WorktreeResolutionBranchSignal`.
- Predicate `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1`: `Get-EpicCommandLegReadinessFailure` (lines 124-174) checks conjuncts in this order: `checkpoint-absent`, `route_id`, `epic_feature_folder`, `epic_manifest_path` (must match `(^|/)docs/features/epics/`), `integration_branch`, `features`, `merge-in-progress`.
- Caller identity: the #663 implementation does not read `agent_type` or any envelope caller field. Scope is decided only by the session root's epic checkpoint plus a match between the effective worktree HEAD and `integration_branch` (resolver lines 335-353). A text branch signal is ignored on the command and path legs (remediation CR-2).

### 1.4 Claude gate-5 design as implemented

No production change (D3). `.claude/hooks/enforce-completion-consistency.ps1:88-97` matches only `(^|/)artifacts/orchestration/orchestrator-state\.json$`. The pinning rows are in `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1:456-481`, under the context `issue #663 epic checkpoint pinning (D3)`.

## 2. Codex surface: current state and divergence

### 2.1 Gate 4, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

- **The file is at the 500-line cap.** Read returned lines 1-500, and line 1 is blank. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:93-108` enforces `<= 500` for this file and its bundle copy. No line can be added unless lines are removed.
- It is not byte-identical to the Claude gate. The divergences are pre-existing and intentional:
  - The Codex copy dot-sources `codex-pretooluse-file-mapping.ps1` (line 11). The Claude copy imports `HookPayload.psm1` (Claude line 9).
  - It has apply_patch file-marker detection in `Test-ImplementationCommand` (lines 137-148).
  - It uses `Get-StringProperty` where the Claude copy uses `Get-ClaudeHookToolInputString` (lines 200-205, 223-226).
  - Malformed input throws (lines 385-392). The Claude copy returns a fail-closed deny (Claude 340-346).
  - It has a stdin entry point that handles `Bash`/`apply_patch` and `Edit`/`Write` separately (lines 470-500).
- **It still defines the two per-mode read seams inline:** `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` (lines 289-314, 26 lines). #663 moved these out of the Claude gate.
- The single-feature path has no epic-scope hook-in. The command and path legs go directly to the delegation-mode block (lines 430-449) and then to `Test-OrchestrationReady` with `docs/features/active/` (lines 248-276, 451-463). This is where AC-1's `PREIMPLEMENTATION_GATE_BLOCKED` comes from.
- Registration in `.codex/config.toml`: matcher `^Bash$` (line 120, command line 136) and `^(apply_patch|Edit|Write)$` (line 186, command line 220). No Agent matcher reaches the gate (see `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1:9-20`, decision D5 of #554).
- For apply_patch, the entry point passes the raw `tool_input`, including the patch in `command`, to the decision (line 477-478). As a result, apply_patch is classified by `Test-ImplementationCommand` as a *command* leg. Edit and Write are mapped to `{file_path}` (lines 488-490).
- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is close to, but not identical with, the Claude modes file. `Find-OrchestrationModeRecord` ends 3 lines earlier (`Get-EpicOrchestrationReadinessFailure` starts at Codex line 362 versus Claude line 365). The port does not need to change it.
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` is byte-identical to the other three copies. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:14-54` enforces SHA-256 identity. It already provides `Split-OrchestrationCommandLine` (line 58) and `ConvertTo-OrchestrationCommandToken` (line 163), which the selector needs.

### 2.2 Gate 5, `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1`

- `Test-IsCheckpointPath` (line 96-105) uses the same regex as the Claude copy: `(^|/)artifacts/orchestration/orchestrator-state\.json$`. As a result, `artifacts/orchestration/epic-orchestrator-state.json` is **not intercepted** by the decision function (lines 361-364 allow).
- The stdin entry point maps through `ConvertTo-CodexFileEditInput -ResolveUpdateContent -GovernedPath $script:GovernedCheckpointPath` (line 424). `$script:GovernedCheckpointPath` is `artifacts/orchestration/orchestrator-state.json` (`.codex/hooks/enforce-checkpoint-monotonic.ps1:54`). `Test-CodexGovernedPath` anchors on `(^|/)<governed>$` (`.codex/hooks/codex-pretooluse-file-mapping.ps1:384-390`). For an apply_patch Update whose path is ungoverned, the mapper `continue`s and emits no record (lines 299-305). An apply_patch Update of the epic checkpoint therefore produces no decision and is allowed. Add and Delete records for the epic path produce a record, but `Test-IsCheckpointPath` then allows it.
- `Test-IsValidFeatureFolder` (`.codex/hooks/enforce-completion-helpers.ps1:57-104`) still requires `docs/features/active/`. This is the per-feature deny that Claude D3 kept, and it is identical in the Codex copy.
- **Finding: the Codex gate 5 already behaves as the Claude gate 5 behaves after #663.** The "seam" that Claude gate 5 uses after #663 is non-interception of the epic checkpoint, and the Codex hook already has it. Under the #663 precedent, AC-2 is met by D3-style pinning tests with no production change to either Codex gate-5 file. The issue text (`issue.md:33`) assumed that a code change was needed. spec.md must record this as a numbered decision (AC-5).
- Pre-existing Codex/Claude gate-5 divergences are not epic-related and are out of scope. Codex denies an unresolved Edit patch (lines 370-377) and invalid JSON (lines 380-388). Claude allows both (Claude lines 365-381).

### 2.3 Where the resolver lives and whether Codex can import it

- No `.codex/hooks/*.ps1` uses `Import-Module`, and none references `.claude/lib` (Grep across `.codex/hooks` found only a config path at `enforce-completion-helpers.ps1:128` and two comment lines). Codex hooks share code only through `. (Join-Path $PSScriptRoot '<file>.ps1')` siblings.
- `.codex/lib/` does not exist in the repository (Glob returned nothing).
- The Codex bundle `extensions/drm-copilot/resources/codex-and-agents-customizations/` contains only `.codex/**`, `.agents/**`, pack manifests, and variants (`tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:35-40,215-228`). It contains no `.claude/lib`.
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1:100-196` runs every bundled PreToolUse hook, including gate 4 and gate 5, from the bundle location with `WorkingDirectory = <bundle root>`. It requires exit 0. A load-time `Import-Module` of a `.claude/lib` path, or of a `.codex/lib` path that is not bundled, would fail there.
- The one existing cross-surface precedent is the codex-routing modules. They live at `.claude/lib/codex-routing/` in the repository, are stored once under `extensions/drm-copilot/resources/lib/codex-routing/`, and are published to `.codex/lib/codex-routing/` through `VIRTUAL_RESOURCE_PAIRS` (`scripts/dev_tools/push_down_codex_and_agents_customizations.py:68-94`). A candidate-path fallback finds them (`.codex/scripts/codex-routing-cli-common.ps1:18-70`). They are CLI wrappers, not hooks, and are not covered by the bundle hook probe.
- **Guard coverage gap for `.codex/lib`:**
  - The pack-manifest completeness test enumerates only `.codex/agents`, `.codex/hooks`, and `.agents/skills` (`test_push_down_codex_and_agents_pack_manifest_completeness.py:140-181`).
  - The core-closure test follows only `. (Join-Path $PSScriptRoot '...')` dot-sources, not `Import-Module` (`test_codex_core_manifest_closure.py:48-58,79-112`).
  - A new `.codex/lib/*.psm1` imported by a hook would therefore have no automatic guard for manifest registration.
  - Dot-sourced `.codex/hooks/*.ps1` siblings are covered by both tests.

## 3. Candidate approaches

**Approach A (recommended): a Codex-local, dot-sourced port of the #663 seam in `.codex/hooks/`.**

Two new dot-sourced siblings:

1. `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`. This has the same name and role as the Claude sibling. It holds:
   - the relocated `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` (verbatim move from gate lines 289-314);
   - `Get-OrchestrationEpicScopeSelector`;
   - `Get-OrchestrationEpicScopeDecision`;
   - `Get-EpicCommandLegReadinessFailure`, with the same conjunct names and order as `EpicScopeReadiness.psm1:124-174`.
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`. This holds:
   - the resolver, with the same public seam names: `Get-EpicScopeCheckpointText`, `ConvertFrom-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeGitDirectory`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, `Resolve-EpicScopeCheckpoint` (head-matching mode only);
   - the minimal worktree primitives it needs, taken from `WorktreeResolution.psm1:61-99,118-293` and `WorktreeTargetResolution.psm1:311-339`.

The gate dot-sources the epic-scope sibling, and the sibling dot-sources the resolution sibling. The gate calls `Get-OrchestrationEpicScopeDecision` for `$filePath -or $command`, in the same position as the Claude gate (after the declared-checkpoint cross-check, before the mode block).

Advantages:
- It follows the Codex convention (dot-source only).
- The bundle stays self-contained, and the bundle hook probe still passes.
- Both manifest guards cover the new files.
- It needs no Python push-down change.
- The Codex tests can mirror the Claude EpicScope suite row for row, with the same seam names.

Limitations:
- The logic now exists twice. This is mitigated by a Codex logic-parity suite that uses the Claude fixtures and outcomes, following the precedent in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1:4-33`.

Rejected alternatives (brief):
- **B, import `.claude/lib/worktree-resolution/*.psm1` from `.codex/hooks`.** This breaks Codex-only installs and the bundle hook probe (section 2.3).
- **C, byte-identical copies of the four `.claude/lib/worktree-resolution` modules under `.codex/lib/`, loaded with `Import-Module`.** This means about 1,400 copied lines, most of them unused. The manifest and closure guards do not cover it. The module headers state a Claude mirror location.
- **D, the codex-routing virtual-resource pattern.** It requires changes to the Python push-down script and extra resource copies. The hook must also tolerate a missing module when run from the bundle location. This is larger than the defect.

## 4. Behaviour semantics (target)

- **Gate 4, command leg (`Bash`), and apply_patch leg (serialized as a command):**
  - When `Test-ImplementationCommand` is true, first evaluate `Get-OrchestrationEpicScopeDecision -Command $command`.
  - If the call is epic scope, return allow when the epic command-leg predicate passes and `MERGE_HEAD` exists (D2). Otherwise deny with `PREIMPLEMENTATION_GATE_BLOCKED`, naming `epic-orchestrator-state.json` and the failed conjunct.
  - If the call is not epic scope, run the unchanged single-feature path and return its unchanged reason text.
  - For apply_patch, the patch text yields no `git -C` selector, so the session-root HEAD decides. This matches the path leg.
- **Gate 4, path leg (`Edit`/`Write`, mapped to `file_path`):** Same decision with `-FilePath`, using the session-root HEAD.
- **Gate 4, delegation leg:** Unchanged. It is not reachable on Codex.
- **Fail-closed rules:** Each of the following means "not epic scope" and continues to the per-feature path, including its denials: an absent or unparseable epic checkpoint, a non-`epic` `route_id`, an empty `integration_branch`, an unresolved selector, or a HEAD mismatch. Resolver errors must never throw out of the hook.
- **Gate 5:** No decision change. A completion-asserting Write, Edit, or apply_patch to `artifacts/orchestration/epic-orchestrator-state.json` is allowed. A per-feature `orchestrator-state.json` whose `feature-folder` is `docs/features/epics/<slug>` is still denied with `COMPLETION_CONSISTENCY_BLOCKED`.
- **AC-3 (unchanged per-feature behaviour):** Every existing Codex gate-4 and gate-5 suite must pass without modification of its assertions.

## 5. Design decisions (numbered, with recommendations)

- **D1 (resolver placement):** Use a Codex-local dot-sourced port (Approach A), not an import or a copy of `.claude/lib`. Record this as an intentional divergence under AC-5. Rationale: sections 2.3 and 3.
- **D2 (seam names and decision set):** Keep the #663 public seam names, reason codes, and conjunct order identical to `EpicScopeResolution.psm1` and `EpicScopeReadiness.psm1`, and keep the deny-reason format of Claude sibling line 126. Rationale: AC-5 requires "the same seam and decision set", and identical names let the Codex suite mirror the Claude suite. Codex suites must not import the Claude modules in the same test file, so that a module export cannot shadow the dot-sourced functions.
- **D3 (resolver scope):** Port only head-matching mode (`-MatchWorktreeHead` semantics), which is the only mode gate 4 uses. Omit `Find-WorktreeResolutionBranchSignal`, because the text branch signal is ignored on the command and path legs (resolver lines 335-338). Either keep the `-MatchWorktreeHead` switch for signature parity or remove it and document the removal. Recommendation: remove it, and give the resolver a fixed head-match contract so the Codex copy has no dead branch that would lower coverage.
- **D4 (caller-identity signal):** Use the same signal as #663: the session-root epic checkpoint plus a HEAD match, with the session root taken from `(Get-Location).Path`. Do not use the Codex payload `cwd` field or any `agent_type`. Rationale: #663 did not use envelope caller fields. The Codex hook process is started by `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/..."` (`.codex/config.toml:136,220`), and reading `cwd` would add a Codex-only input. Record the payload-`cwd` option as rejected.
- **D5 (line headroom):** Move `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` out of the Codex gate into the new epic-scope sibling. This mirrors #663 [P5-T4] and frees 26 lines, against about 12 lines needed for the dot-source line and the epic-scope call. Keep the function names unchanged. The existing suites that rely on them by name (`enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1:14,173`) get them through the gate's dot-source.
- **D6 (gate 5):** Make no production change to `.codex/hooks/enforce-completion-consistency.ps1` or `.codex/hooks/enforce-completion-helpers.ps1`. Pin the behaviour with tests, following #663 D3. State in spec.md that AC-2 is satisfied by pinning because the Codex hook already has the post-#663 Claude behaviour (section 2.2).
- **D7 (dot-source form):** Write every new dot-source line exactly as `. (Join-Path $PSScriptRoot '<file>.ps1')` so the closure test follows it (`test_codex_core_manifest_closure.py:53`). Register both new files in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` next to lines 41-42 and 53.
- **D8 (bundle mirrors):** Copy each new or changed `.codex/hooks` file byte-for-byte to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. `test_push_down_codex_and_agents_resource_contracts.py:215-228` and `legacy-codex-hook-contracts.Tests.ps1:111-117` enforce this.
- **D9 (test layout):** Add new suites under `tests/scripts/codex-hooks/`, one per new or changed production file, instead of extending shared legacy suites. This keeps the change set separate from siblings. Use Arrange-Act-Assert. Mock the seams by name without `-ModuleName`. Use `/synthetic-worktrees/...` roots, as the Claude suite does (`...EpicScope.Tests.ps1:16-20,58-79`). Create no files and change no directory.
- **D10 (existing Codex gate-4 suites exposed to local epic state):** After the port, in-process Codex suites that drive implementation-classified command or path legs will call the real `Get-EpicScopeCheckpointText` and HEAD read. This is the hazard class of #663 CR-4 / #709, now introduced on the Codex surface. It is inert in CI (no gitignored file) and requires a matching HEAD locally. Recommendation: in #707, add a `Mock Get-EpicScopeCheckpointText { $null }` in the `BeforeAll`/`BeforeEach` of each exposed in-process suite, as a separate batch. The exposed suites are the files that call `Invoke-OrchestrationPreimplementationGateDecision` on command or path legs: `codex-preimplementation-gate-absolute-paths.Tests.ps1`, `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, and the in-process contexts of `legacy-codex-hook-contracts.Tests.ps1`. The planner must confirm the exact list by reading each file. Process-level rows (child `pwsh`) cannot be mocked. They remain deny-robust, because an epic-scope deny still carries `PREIMPLEMENTATION_GATE_BLOCKED`. Alternative: defer to a follow-up, as #663 did with CR-4. This is not recommended, because #709 covers Claude suites only.
- **D11 (sibling overlap):** See section 6.

## 6. Merge-order independence

| Sibling | Its write set (per delegation / follow-ups) | Overlap with #707 | Rule for #707 |
| --- | --- | --- | --- |
| #708 | `.claude/hooks/enforce-completion-consistency.ps1` Edit branch (literal relative path at `Resolve-EditedCheckpointContent`), possibly `.codex/hooks/enforce-completion-consistency.ps1:308` | Possible on the Codex gate-5 file | #707 does not edit either Codex gate-5 file (D6). The Codex gate-5 pinning rows use Write-shaped payloads (`content` present) or a `CheckpointReader` that ignores its path argument, and never assert the path passed to the reader. Put them in a new file, not `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`. |
| #709 | Claude gate 1/3/4 suites under `tests/scripts/claude-hooks/` | None on files; same remedy class | #707 applies the remedy only to Codex suites (D10). It does not touch `tests/scripts/claude-hooks/`. |
| #710 | `enforce-orchestration-preimplementation-gate-helpers.ps1` and its three copies, including `.codex/hooks/...-helpers.ps1` | The helpers copy; the selector depends on helpers parsing | #707 does not touch any helpers copy. The parity test compares the four copies with each other, so it holds whichever item merges first. The `-C` selector rows use unquoted paths without backslashes, so their tokens do not depend on #710's escape handling. |
| #713 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` no-checkpoint commit admission; possibly the Codex gate mirror | Possible on the Codex gate file, which has zero headroom | #707 limits its gate edits to three regions: the dot-source header (current lines 13-25), deletion of the read-seam block (lines 289-314), and a single insertion before the mode block (current line 430). It does not touch `Test-ImplementationCommand` (lines 127-176). Phase 0 of the plan re-reads the Codex gate on the current base and records its line count and whether the read seams are still inline, then adapts the relocation. Tests assert behaviour, not line numbers. |

A general rule applies to all of them. The plan should rebase on `main` before PR and rerun the parity, manifest, and bundle tests after each rebase. It should not encode any sibling's intermediate state in an assertion.

## 7. Write set and read set

### 7.1 Files the fix writes (repository-relative)

Production (Codex):

- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified: dot-source, epic-scope call, read-seam removal)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (new)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` (new)

Bundle mirrors (byte copies):

- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`

Manifests and configuration:

- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (add both new `.codex/hooks` files to `CodeCoverage.Path` near lines 139-147)
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (identical copy; enforced by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18`)

Tests (new):

- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` (gate-4 allow/deny/standalone rows mirroring the Claude EpicScope suite; relocated read-seam rows; no-leg guard; apply_patch row)
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` (resolver and predicate units: every reason code, selector precedence, gitdir file vs directory, detached HEAD, `MERGE_HEAD` probe, unparseable/array JSON, absolute path composition)
- `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` (gate-5 pinning: Write/Edit/apply_patch to the epic checkpoint allowed; per-feature epics-folder checkpoint denied; mapper emits no record for an apply_patch Update of the epic path; byte identity and 500-line cap for the three new or changed gate-4 files and their bundle copies)

Tests (modified, per D10; confirm the list by reading each file):

- `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (in-process contexts only)

Feature documents: `spec.md`, the plan, and the evidence under `docs/features/active/codex-gates-4-5-lack-epic-scope-707/`.

Explicitly not written:

- `.codex/hooks/enforce-completion-consistency.ps1`
- `.codex/hooks/enforce-completion-helpers.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three copies
- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- every `.claude/**` file
- `scripts/dev_tools/push_down_codex_and_agents_customizations.py`

### 7.2 Files read only

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, `EpicScopeReadiness.psm1`, `WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`
- `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`
- `.codex/hooks/codex-pretooluse-file-mapping.ps1`, `.codex/hooks/enforce-checkpoint-monotonic.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.codex/config.toml`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`
- Guard tests (run, not edited): `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- The #663 feature folder

## 8. Testing implications

- **Hermeticity (AC-4):**
  - Mock `Get-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, and the root ascent (`Find-WorktreeResolutionRoot` or its Codex-local equivalent) by name.
  - Resolver unit rows mock `Get-WorktreeResolutionGitEntryKind` and `Get-WorktreeResolutionGitFileText` (or the Codex-local equivalents) instead of touching disk.
  - Always pass `-CheckpointRaw` with a not-ready single-feature JSON, so the fallback path never reads `artifacts/orchestration/orchestrator-state.json`.
  - Use no `origin/main`, no `git` subprocess, no `C:/` roots, and no temporary files. CI runs Linux, `config/poshqc-scan.json:4` scans `tests/scripts`, and the new suites are collected automatically.
- **AC-3 coverage:** Include standalone rows: no epic checkpoint, `integration_branch` mismatch, and missing `route_id`/`integration_branch`, each returning the exact single-feature reason string (see the Claude suite, lines 131-145 and 189-226). The existing Codex gate-4 and gate-5 suites must pass with assertions unchanged.
- **Logic parity (AC-5):** Reuse the Claude fixture literals: ready epic JSON, conjunct names, and reason fragments.
- **Coverage:** Each new or changed Codex production file needs line coverage of at least 85%. #663 needed a remediation pass for its sibling, which was at 66.67% on pass 1 (`.../663/evidence/qa-gates/final-pester-coverage.md:17`). Plan rows for the relocated read seams and the no-leg guard up front.
- **Batch cap:** Three production and three test files per PowerShell batch (`.claude/rules/powershell.md`). A feasible split:
  - B1: resolution sibling plus its suite.
  - B2: epic-scope sibling, gate edit, and gate-4 suite.
  - B3: gate-5 pinning suite, then manifests, runsettings, and mirrors.
  - B4: the D10 exposed-suite mocks.

## 9. Toolchain commands

1. Format: `mcp__drm-copilot__run_poshqc_format`.
2. Analyze: `mcp__drm-copilot__run_poshqc_analyze`.
3. Test: `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
4. Python guards: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.

Caveats:

- The MCP PoshQC test runner reads the installed-extension settings and may ignore new `CodeCoverage.Path` entries. Its result also carries no test output, so no pass count or coverage percentage may be asserted from it.
- For coverage evidence, invoke the self-hosted module directly in a fresh PowerShell 7 process: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Then read `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, as #663 did (`.../663/evidence/qa-gates/final-pester-coverage.md:5-12`).
- In an agent worktree, the isolation guard denies Bash text that contains `pwsh`. Use the PowerShell tool, or `sh <script>` as #663 did.
- Write evidence to `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/<kind>/`.

## 10. Automation Feasibility

Every step can be automated and none needs human interaction:

- editing the Codex hooks and siblings;
- byte-copying mirrors;
- updating the manifest and runsettings;
- writing and running tests;
- running the Python guards.

No live GitHub or live epic is needed for the acceptance criteria. An optional manual check, running a Codex-driven epic main-sync merge and staging, can be recorded as a follow-up. It is the same kind of step as #663 follow-up 5, and it is not required by AC-1 to AC-5.

## 11. Numeric claims

This research proposes no numeric count, enumeration, or population for a spec.md acceptance criterion. The D10 suite list is a planning input that must be confirmed by reading each file. It must not become a numeric AC unless the planner adds a complete `## Numeric Derivation Evidence` section.
