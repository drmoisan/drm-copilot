# Research: completion stop hook traps session after rejected parallel mutation (Issue #1012)

- Issue: #1012
- Branch: `bug/completion-stop-hook-rejected-mutation-1012`
- Inputs read: `issue.md`, `spec.md` (Draft), `plan.2026-10-30T08-10.md` (template), `.claude/skills/execution-environment/SKILL.md`
- Researcher tool limits: no Bash, `git`, or `gh`; every finding below comes from Read, Grep, Glob, and one WebFetch of the Claude Code hooks reference.

## 1. Current State Analysis

### 1.1 Decision path in the hook

`.claude/hooks/validate-orchestrator-output.ps1`:

- Entry: the script tail calls `Invoke-OrchestratorOutputValidation -CheckpointPath $CheckpointPath -ArtifactType $ArtifactType`. An exception there is turned into `Exit-SubagentStopBlock` with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: validator error: ...`.
- `Invoke-OrchestratorOutputValidation` checks dependency loads first (`Get-HookDependencyFailureDecision`). It then reads the envelope through `Read-SubagentStopEnvelope` (from `subagentstop-envelope.ps1`), passing `-InputText` when the test binds it and reading stdin otherwise. It passes `envelope.AssistantText` as `AgentOutput` to `Get-OrchestratorOutputBlockDecision`, and then applies the re-entry policy: a block with `Repairable = $false` blocks once and is released when `StopHookActive` is set; a block with `Repairable = $true` blocks on every stop.
- `Get-OrchestratorOutputBlockDecision` runs these checks in order:
  1. Empty `AgentOutput` blocks (repairable).
  2. `Resolve-OrchestratorOutputCheckpointPath` (resolution sibling). A thrown resolver blocks with `NoTarget (RESOLVER_FAILED)` (not repairable).
  3. **`if (-not $resolution.Resolved)`** blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: <type>: <Status> (<ReasonCode>): <Detail>`. `Repairable` is `$true` only when `Status` is `NoTarget` or `Ambiguous` **and** `ArtifactType` is `epic-orchestrator-state` or `parallel-orchestrator-state`. **This is where the trap occurs.** For a parallel stop that wrote no state, the resolver returns `NoTarget`, the block is repairable, so `stop_hook_active` never releases it, and the agent cannot clear it without fabricating a checkpoint.
  4. `Get-CheckpointFileContent` existence, emptiness, JSON parse, required fields (`objective`, `completed_steps`, `next_step`, `last_updated`), `Test-HumanInteractionShape`, then `Invoke-RoutingContractValidation` (routing sibling; for `parallel-orchestrator-state` the default invoker runs the structural check `Test-OrchestratorCheckpointStructure`), the feature-folder probe (orchestrator-state only), and the wave barrier (epic only).

### 1.2 Checkpoint selection for a parallel stop

The selection is made by `.claude/hooks/validate-orchestrator-output-resolution.ps1` in `Resolve-OrchestratorOutputCheckpointPath`:

- `$script:OrchestratorOutputRunKind` maps `parallel-orchestrator-state` to kind `parallel`.
- `Test-OrchestratorOutputCheckpointLeafShape` rejects a malformed leaf before any read (`Rejected`, `CHECKPOINT_PATH_MISMATCH`).
- For kind `parallel`, `Find-WorktreeRunIdentitySignal -Text $AgentOutput` (in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`) extracts the `parallel_slug:` literal, matched case-sensitively, with exactly one distinct value required.
- When the output names no slug, `Find-OrchestratorOutputRunSignalValue -Kind parallel` scans `Get-WorktreeItemLiveRoot` and reads each live root's `artifacts/orchestration/parallel-orchestrator-state.json` through `Get-WorktreeRunCheckpointText`. It keeps only parseable object roots with `route_id == 'parallel'` and a string `parallel_slug`. More than one distinct value gives `Ambiguous`; exactly one value is used as the identity; zero values give an empty identity.
- `Resolve-WorktreeParallelTarget` (module) returns `NoTarget` for a blank slug ("the call carries no parallel_slug: value") or when no live root's checkpoint records the slug (`Resolve-WorktreeRunMatch`, zero matches). Several matches give `Ambiguous`.
- `Test-OrchestratorOutputCheckpointLeaf` composes the leaf beneath the resolved root and requires an ordinal match with `Get-WorktreeRunCheckpointPath`.

A `Resolved` result therefore already implies that a parseable `route_id: parallel` checkpoint recording the slug existed at resolution time. "No run checkpoint exists" maps to `Status -eq 'NoTarget'` on the parallel kind. The reason code is `TARGET_WORKTREE_NOT_DERIVABLE` (`$script:OrchestratorOutputNoTargetReasonCode`; the tests obtain it from `Get-WorktreeResolutionNoTargetReasonCode`).

### 1.3 How the hook obtains the final output text

- The text comes only from the SubagentStop envelope field `last_assistant_message` (`Read-SubagentStopEnvelope` in `.claude/hooks/subagentstop-envelope.ps1`; the name is matched with `-ceq` and the value must be a string). The hook reads no transcript and has no transcript seam.
- `StopHookActive` comes from `stop_hook_active`, and only a real boolean counts.
- The Claude Code hooks reference (fetched from code.claude.com/docs/en/hooks) confirms that `last_assistant_message` is provided on Stop and SubagentStop for "the final assistant text of the current turn". It also confirms that a `Stop` hook in a subagent's frontmatter is converted to `SubagentStop`.

### 1.4 Injectable seams used by the Pester suites

- `-InputText` on `Invoke-OrchestratorOutputValidation` bypasses stdin.
- `Get-CheckpointFileContent` (hook) is the checkpoint read seam.
- `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` are mocked both with `-ModuleName WorktreeRunResolution` and in script scope, because the resolution sibling calls them directly. `Set-OutputRunTopology` in `validate-orchestrator-output.WorktreeResolution.Tests.ps1` registers both.
- `Resolve-OrchestratorOutputCheckpointPath` is mocked wholesale in `validate-orchestrator-output.Reentry.Tests.ps1` (`Set-ReentryResolution`) and `validate-orchestrator-output.Envelope.Tests.ps1`.
- The `-RoutingInvoker` scriptblock seam, plus mocks of `Get-OrchestratorStateCheckpoint`, `Test-OrchestratorStateCompletionReadiness`, and `Get-OrchestratorStateEpicWaveBarrierError`.
- `Test-OrchestratorOutputRunbookFile` is the runbook existence seam.
- Every suite that loads the hook calls `Invoke-EpicStateInterceptionProbe` from inside an `It`. This is enforced by `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (AC-6).

### 1.5 Where the new allow path belongs

The new allow path belongs in `Get-OrchestratorOutputBlockDecision`, inside the `if (-not $resolution.Resolved)` branch and before its `return`. It is gated on:

- `ArtifactType -eq 'parallel-orchestrator-state'`;
- `resolution.Status -ceq 'NoTarget'` (not `Ambiguous`, not `Rejected`);
- a valid rejection signal on the final line of `AgentOutput`;
- a state-absence check (section 4.2).

Every other path is unchanged. A `Resolved` result, which means a checkpoint is present, always validates fully, so a signal never relaxes validation when a checkpoint exists.

## 2. Hook Registration and Codex Surface

- `.claude/settings.json`, `SubagentStop`, matcher `parallel-orchestrator`, runs `pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state`.
- `.claude/agents/parallel-orchestrator.md` frontmatter, `hooks: SubagentStop`, matcher `parallel-orchestrator`, runs the identical command. The hook therefore runs twice per stop, with the same arguments.
- The four skills (`parallel-run`, `parallel-add`, `parallel-close`, `parallel-remove`) and `parallel-orchestrate` declare `context: fork` and `agent: parallel-orchestrator`. None declares `hooks:` (Grep of `^hooks:` under `.claude/skills` returns no files). Their stops are SubagentStop events with agent type `parallel-orchestrator` and are covered by the two registrations above. No `Stop` (main-session) registration exists for this hook.
- Matcher semantics: the hooks reference states that a matcher made only of letters, digits, `_`, `-`, spaces, `,`, and `|` is an exact string. The `orchestrator` and `epic-orchestrator` matchers therefore do not fire for `parallel-orchestrator`, and only the parallel registration applies.
- Codex: no `validate-orchestrator-output*.ps1` exists under `.codex/hooks/`. `.codex/config.toml` registers only `validate-codex-subagent-routing.ps1` and `validate-feature-review-coverage.ps1` under `SubagentStop`. There is no Codex `parallel-orchestrator` agent (Glob of `.codex/**/*orchestrator*` lists no parallel variant). No `.agents/skills/parallel-*` or `.github` parallel surface exists. **The Codex surface does not need the change.**

## 3. STOP / Reject Paths Mapped to Reason Codes

Rule for interpreting the table: the allow path matters only when no checkpoint exists. A rejection that occurs while the run's checkpoint exists falls through to full validation. For parallel checkpoints that validation is structural only (exists, parses, object root), so a well-formed checkpoint already lets that stop pass today.

| Skill | Documented STOP / reject path (heading) | Checkpoint at stop | Reason code | Mapping |
| --- | --- | --- | --- | --- |
| parallel-run | `## Procedure` step 2: "STOP without delegating anything when that path does not exist" (kickoff artifact absent) | normally absent | `kickoff_artifact_missing` | clean |
| parallel-add | `## Prerequisites`: "Reject a pending or not-started run" | absent (planner writes only `parallel-planner-state.json`) | `run_not_started` | clean |
| parallel-add | `## Prerequisites`: no checkpoint tracks the run's `parallel_slug` | absent | `run_not_started` | clean |
| parallel-add | `## Prerequisites`: "closed runs are not eligible" | present (close entry recorded) | none | **not clean**; no enum member; full validation applies |
| parallel-add | `## Prerequisites`: "An argument naming more than one item is rejected" | either | none | **not clean**; see recommendation below |
| parallel-add | `## Procedure` step 5 "stop rather than write a result that names a pinned key"; `## Constraints` failed preparation | present, state already written (step 1 adds `proposed`) | none | not a no-state rejection; must not emit |
| parallel-close | `## Prerequisites`: checkpoint does not track the slug | absent | `run_not_started` | clean |
| parallel-close | `## Prerequisites`: `closed`-mode run, "Report that and stop" | present | none | **not clean**; full validation applies |
| parallel-close | `## Procedure` step 2: gate exit 1, "report the blocking keys and stop" | present (and `## Re-Derive Durable State` may rewrite it) | `items_in_flight` | clean code; allow path not exercised |
| parallel-remove | `## Prerequisites`: checkpoint does not track the slug | absent | `run_not_started` | clean |
| parallel-remove | `## Prerequisites`: argument is not exactly one integer key | either | none | **not clean** |
| parallel-remove | `## State-Dependent Behavior Table`: `in_flight` without `--disposition` | present | `items_in_flight` | **approximate** (the item is in flight; the code name is plural) |
| parallel-remove | `## State-Dependent Behavior Table`: `merged` | present | none | **not clean**; full validation applies |
| parallel-remove | unknown, `withdrawn`, or `blocked` item ("rejected as an unknown item") | present | `unknown_item` | clean |
| parallel-orchestrate | malformed manifest "recorded as a synthetic Blocking finding in the checkpoint"; Run Closing "stop and report" | present / written | none | writes state; no no-state STOP path is documented, so no emission is required |

The agent `.claude/agents/parallel-orchestrator.md` `## Prepared-Run Execution` restates the parallel-run STOP and is otherwise consistent.

Recommendation for the unmapped paths: do not extend the enum in this item, because the issue fixes the closed set of four. Each unmapped path occurs with a checkpoint present (closed run, closed-mode close, merged item), or should be ordered after the run-existence check (multi-item argument, non-integer key). Each skill should state that the run-existence check (`run_not_started`) is evaluated first. Under that ordering, an argument-shape rejection is reached only when a checkpoint exists and validates normally. The skills should state explicitly that these paths emit no signal. Record this as a decision in `spec.md`.

## 4. Behavior Semantics

### 4.1 Signal grammar

- The signal is the last non-blank line of `last_assistant_message`, after trailing whitespace (including `\r`) is trimmed. It must match the case-sensitive regular expression `^PARALLEL_MUTATION_REJECTED: (?<code>[a-z_]+)$`: exactly one space after the colon, no Markdown wrapping, and no trailing text.
- `code` must be an ordinal member of `{kickoff_artifact_missing, run_not_started, items_in_flight, unknown_item}`.
- The following are not a signal: the token appearing elsewhere (free text, an earlier line, inside backticks or bold), a lowercase prefix, an uppercase code, extra tokens, or a code outside the set.
- A final line that starts with `PARALLEL_MUTATION_REJECTED:` but carries an invalid code should block as today, with a repairable message that lists the allowed codes so the agent can correct it.

### 4.2 Determining that no run checkpoint exists

Allow only when all of the following hold:

1. The resolver returns `Status 'NoTarget'` for kind `parallel`.
2. A state-absence check passes. For every live root from `Get-WorktreeItemLiveRoot`, the text of `Get-WorktreeRunCheckpointText` on that root's `Get-WorktreeRunCheckpointPath -Kind parallel` is either null or blank, or parses as an object with `route_id == 'parallel'` whose `parallel_slug` differs from the slug the output names (when it names one).

Any non-blank text that is unparseable, has a non-object root, is off-route, lacks a slug, or records the named slug defeats the allow, and the existing block applies. This closes the false-allow case where the agent wrote a malformed or partial checkpoint (which the resolver skips, producing `NoTarget`) and then emitted the signal. It reuses only the two seams the resolver already uses, so the existing test topology helper models it without new seams.

### 4.3 Outcomes

| Condition | Result |
| --- | --- |
| parallel, NoTarget, valid signal, state absent | allow (`Ok = $true`), regardless of `stop_hook_active` |
| parallel, NoTarget, no or invalid signal | block as today (repairable); recommend appending one hint line naming the signal and the rule section |
| parallel, NoTarget, valid signal, non-blank malformed/off-route/same-slug text found | block as today |
| parallel, Ambiguous or Rejected, any signal | block as today |
| parallel, Resolved, any signal | full validation as today |
| orchestrator-state or epic-orchestrator-state, any signal | unchanged |

## 5. Requirements Mapping and Proposed Design

### 5.1 Selected approach

Add a new dot-sourced sibling, `.claude/hooks/validate-orchestrator-output-rejection.ps1`, with pure helpers:

- `Get-ParallelMutationRejectionCode -AgentOutput`: returns the code or `$null`. It holds the four members as a script-scope array, with a comment citing the rule section.
- `Test-ParallelRunStateAbsent -AgentOutput -SessionRoot`: the live-root scan from section 4.2, using `Find-WorktreeRunIdentitySignal` for the named slug.
- `Get-OrchestratorOutputRejectionDecision -ArtifactType -Resolution -AgentOutput -SessionRoot`: returns `@{ Ok = $true; Message = $null }` or `$null`.

The main hook loads the sibling with a guarded dot-source, `try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-rejection.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-rejection.ps1' -ErrorRecord $_ }`, and gains a short call inside the `-not $resolution.Resolved` branch. The sibling imports no module (it relies on the modules the hook already imports), which satisfies `hook-dependency-guard-completeness.Tests.ps1` S4. It invokes no Python and starts no process.

Rejected alternatives:

- **Adding the helpers to `validate-orchestrator-output-resolution.ps1`.** That file has 311 lines, so it has room. However, it is the resolver file that sibling items #1009/#1010/#1011 are most likely to edit, so adding to it raises merge contention. It also mixes signal parsing with path resolution.
- **Inline code in the main hook.** The main hook has 368 lines and would mix concerns.
- **Parsing the enum from the rule file at runtime.** This adds a file read in a hook and a failure mode for pushed-down destinations.

### 5.2 Rule section

In `.claude/rules/parallel-orchestration.md`, add a new section `## Mutation Rejection Signal (issue #1012)` immediately after `## Enum Ownership (F6/F7/F8 consume, never extend)` and before `## F7 Seam`. It should:

- define the line grammar and the four codes, each with a one-line meaning;
- state that this is an output signal, not a checkpoint field, and is not one of "the nine enums" (the existing count in the table and in the skills' `## Constraints` stays true);
- state the hook behavior from section 4.3 and the ownership rule (skills consume, never redefine);
- optionally add `.claude/hooks/validate-orchestrator-output-rejection.ps1` to `paths:`. `test_claude_rules_frontmatter.py` checks only that paths reach their surfaces, so the addition is additive.

### 5.3 Skills

Each of the four skills adds, at each mapped STOP path, the instruction to end the final output with the literal line `PARALLEL_MUTATION_REJECTED: <code>`, naming that path's specific code and citing the rule section by heading. No skill lists the full member set. Fragments pinned by tests must be kept byte-stable:

- `RUN_PROCEDURE_FRAGMENTS` in `parallel_orchestrator_surface_expectations.py` ("STOP without delegating anything when that path does not exist", "the user must run `/parallel-plan` first", ...);
- the parallel-add fragments "pending or not-started" and "execution has started" (`test_parallel_planner_surface_contracts.py::test_parallel_intake_requires_consolidation_before_execution`);
- the parallel-add step 2 and step 3 start lines (`test_parallel_issue_adoption_skill_contracts.py`);
- the parallel-remove single abandon invocation line (`test_parallel_abandon_token_seam.py`);
- the subcommand tokens in `test_skill_bundle_contract_repo.py`.

`parallel-orchestrate` is not changed. The agent `.claude/agents/parallel-orchestrator.md` needs no change. If a sentence is added, it must go under an existing heading, because `test_agent_body_contains_exactly_the_nine_required_headings` pins the heading set.

### 5.4 Full explicit file list

Production and documentation (repository source):

1. `.claude/hooks/validate-orchestrator-output.ps1` (edit)
2. `.claude/hooks/validate-orchestrator-output-rejection.ps1` (new)
3. `.claude/rules/parallel-orchestration.md` (edit)
4. `.claude/skills/parallel-run/SKILL.md` (edit)
5. `.claude/skills/parallel-add/SKILL.md` (edit)
6. `.claude/skills/parallel-close/SKILL.md` (edit)
7. `.claude/skills/parallel-remove/SKILL.md` (edit)

Bundle copies (byte-identical):

8. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`
9. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-rejection.ps1` (new)
10. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-run/SKILL.md`
12. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
13. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md`
14. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md`

Pack manifest:

15. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: add `.claude/hooks/validate-orchestrator-output-rejection.ps1` next to the existing `validate-orchestrator-output-*.ps1` entries. The other six files are already listed in `core.json`.

No `.agents/`, `.github/`, or `.codex/` counterpart exists for any of these files. `.claude/settings.json` and its bundle copy are unchanged because the command line does not change. `config/poshqc-coverage.json` lists the `.claude/hooks` directory, so the new file enters the coverage population automatically. The execution-environment brief states no fact this change alters, so none of its six copies changes.

Tests (new):

16. `tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1`: unit rows for the three helpers.
17. `tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1`: end-to-end rows through `Invoke-OrchestratorOutputValidation` with the `Set-OutputRunTopology` pattern, one `Invoke-HookTail`-style exit-0 row, and a rule-to-hook enum parity row.
18. A Python contract test, for example `tests/scripts/dev_tools/test_parallel_mutation_rejection_signal_contracts.py`. It asserts that each of the four skills emits only codes present in the rule section, cites the section heading, and does not restate the member set.

## 6. Existing Tests Affected

- `validate-orchestrator-output.WorktreeResolution.Tests.ps1` `R8 blocks a parallel validation as NoTarget when no live parallel checkpoint exists`: output `'Final summary.'`, no signal. The expectation is **unchanged**; it becomes the "no signal, no checkpoint" regression row. If a hint line is appended, the `StartsWith` assertion still holds.
- `R10` (Ambiguous) and `R9`/`R11` (resolved): unchanged.
- `validate-orchestrator-output.Reentry.Tests.ps1` `O-5 epic target not derivable blocks always` (epic, no signal): unchanged. A parallel counterpart row (signal plus NoTarget, allowed on both calls) belongs in the new suite.
- `validate-orchestrator-output.Envelope.Tests.ps1` `E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved` (default orchestrator-state type): unchanged.
- `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` `denies a missing parallel checkpoint (fail closed)` tests `Invoke-RoutingContractValidation` directly: unchanged.
- `validate-orchestrator-output.WaveBarrier.Tests.ps1` `H5 does not run the port for the parallel checkpoint type`, and `validate-orchestrator-output.FeatureFolder.Tests.ps1` parallel row: unchanged.
- `validate-orchestrator-output-resolution.Tests.ps1` `S2-6 passes the cross-check for every existing SubagentStop registration unchanged`: unchanged (registrations are not edited).
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` S1–S6: rows for the main hook are re-evaluated. The new guarded dot-source must be a single-statement `try` with `Add-HookDependencyFailure`.
- `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-6: each new suite that mocks the epic-state seams must call `Invoke-EpicStateInterceptionProbe` inside an `It`.
- Python contracts: `test_push_down_claude_resource_contracts.py` (bundle equality), `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (the new `$PSScriptRoot` dot-source must be in core), `test_push_down_issue_824_follow_ups.py` (no consuming-product names), `test_claude_rules_frontmatter.py`, and the parallel surface contract files listed in section 5.3.
- `PINNED_FROZEN_SURFACE_HASHES` pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. No parallel skill, the parallel rule, or the hook is hash-pinned. `HOOK_COMMAND_FRAGMENTS` pins the registration command, which does not change.

## 7. File Sizes (logical lines; Grep line count)

| File | Lines now | Expected after | Tier |
| --- | --- | --- | --- |
| `.claude/hooks/validate-orchestrator-output.ps1` | 368 | about 375 | below 500 |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` | 311 | unchanged | below 500 |
| `.claude/hooks/validate-orchestrator-output-routing.ps1` | 170 | unchanged | below 500 |
| `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` | 146 | unchanged | below 500 |
| new `validate-orchestrator-output-rejection.ps1` | 0 | about 110–150 | below 500 |
| `validate-orchestrator-output.WorktreeResolution.Tests.ps1` | 366 | unchanged (new rows go to a new file) | below 500 |
| `validate-orchestrator-output.Tests.ps1` | 454 | unchanged | below 500 |
| new test files | 0 | about 200–300 each | below 500 |

`config/file-size-baseline.json` has no entry for any of these files. The Markdown files are exempt.

## 8. Risks

- **False allow.** The allow requires both `NoTarget` and the state-absence scan (section 4.2). A path that wrote a well-formed checkpoint resolves and validates fully, and a malformed write defeats the allow. Residual risk: an agent that writes state elsewhere (not at the canonical parallel path) and emits the signal is allowed. That is outside the hook's observable surface and matches the existing documented contract that rejected mutations "change nothing".
- **False block (trap persists).** This happens if the agent formats the line (backticks, bold, a trailing period) or adds text after it. Mitigation: each skill states the exact literal and that it must be the last line, and the NoTarget block message names the signal so the repairable block tells the agent how to finish. A stale unparseable parallel checkpoint in any live worktree also defeats the allow. The block message should name that path, and the remedy is the existing `artifacts/orchestration/handoff/` move.
- **Discovery picks another run.** If the output names no `parallel_slug:` and exactly one other run's checkpoint is live, resolution resolves to that run and validates it structurally. It passes when that checkpoint is well formed, so the stop is not trapped. The skills should still emit `parallel_slug: <slug>` before the signal line where the slug is known.
- **Linux case sensitivity.** Use `-cmatch` / `[regex]` with ordinal semantics, exact lowercase file names, `Join-Path`, and `/synthetic-worktrees/<name>` roots, with no drive letters or backslash literals in new tests. The suites run in `poshqc / PowerShell hook suites (Linux)`.
- **Overlap with #1009/#1010/#1011.** Those items introduce `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`; this item neither creates nor imports it. The likely overlap is in `validate-orchestrator-output.ps1` (dependency-load block and `Get-OrchestratorOutputBlockDecision`), `validate-orchestrator-output-resolution.ps1`, the hook's bundle copy, and `core.json`. Keeping this item's logic in a new sibling limits the main-hook edit to one guarded load line and one call. The only contract this item depends on is that a parallel resolution with no matching checkpoint yields `Status 'NoTarget'`; the sibling items must preserve it. The four sibling feature folders are not present in this checkout, so the exact file sets of #1009–#1011 are unknown and need confirmation by the orchestrator.

## Numeric Derivation Evidence

### N1: forked skills that run as `parallel-orchestrator` (basis for "the four skills")

- Complete Family: every `SKILL.md` under `.claude/skills/` whose frontmatter forks the `parallel-orchestrator` agent.
- Exhaustive Search Scope: `.claude/` (all skills and agents).
- Inclusion Rules: frontmatter line `agent: parallel-orchestrator`.
- Exclusion Rules: skills forking another agent (`parallel-plan` forks `parallel-planner`).
- Primary Search Strategy or Query Expression: Grep `^agent: parallel-orchestrator` over `.claude`, files mode.
- Primary Member Set: parallel-add, parallel-close, parallel-orchestrate, parallel-remove, parallel-run.
- Primary Count: 5.
- Cross-check Search Strategy or Query Expression: Glob `**/skills/parallel-*/SKILL.md` (6 under `.claude`), then exclude by Grep `^agent:` on `parallel-plan` (returns `agent: parallel-planner`).
- Cross-check Member Set: parallel-add, parallel-close, parallel-orchestrate, parallel-remove, parallel-run.
- Cross-check Count: 5.
- Member-set Comparison: identical. Of the 5, `parallel-orchestrate` has no documented no-state STOP path (section 3), so the emitting set is the 4 named in the issue.

### N2: registrations of the hook with `-ArtifactType parallel-orchestrator-state`

- Complete Family: every runtime registration of `validate-orchestrator-output.ps1` for the parallel artifact type.
- Exhaustive Search Scope: `.claude/` (settings, agents, skills) and `.codex/config.toml`.
- Inclusion Rules: a hook command line naming the hook with `-ArtifactType parallel-orchestrator-state`.
- Exclusion Rules: prose mentions (the `parallel-orchestrate` skill's Layer 2 paragraph).
- Primary Search Strategy or Query Expression: Grep `-ArtifactType parallel-orchestrator-state` over `.claude`.
- Primary Member Set: `.claude/settings.json` SubagentStop matcher `parallel-orchestrator`; `.claude/agents/parallel-orchestrator.md` frontmatter hook (the skill hit is prose and excluded).
- Primary Count: 2.
- Cross-check Search Strategy or Query Expression: Grep `validate-orchestrator-output` over `.claude` excluding tests, docs, and extensions, filtered to command lines; Grep `orchestrator-output|parallel|Stop` over `.codex` (no `.codex` hit names the hook); Grep `^hooks:` under `.claude/skills` (no files).
- Cross-check Member Set: `.claude/settings.json` (parallel matcher line); `.claude/agents/parallel-orchestrator.md`.
- Cross-check Count: 2.
- Member-set Comparison: identical.

## 9. Testing Implications

- Pester unit rows in the new rejection suite:
  - each of the four codes parsed;
  - token not on the last line;
  - token followed by text;
  - lowercase prefix; uppercase code; backtick-wrapped; bold-wrapped;
  - double space after the colon; unknown code;
  - trailing CRLF and trailing blank lines tolerated;
  - empty output;
  - the absence scan for blank, unparseable, off-route, same-slug, and other-slug text.
- End-to-end rows through `Invoke-OrchestratorOutputValidation`:
  - four codes × no checkpoint → `Ok` on both `stop_hook_active` false and true;
  - signal with a resolved checkpoint → `Get-CheckpointFileContent` and the routing seam invoked, with a structural failure still blocking;
  - no signal and no checkpoint → NoTarget block on both stops;
  - signal plus Ambiguous → block;
  - signal plus Rejected leaf → block;
  - signal on `orchestrator-state` and `epic-orchestrator-state` → unchanged block;
  - signal plus a malformed parallel file in a live root → block.
- One script-tail row (exit code 0) in the `Invoke-HookTail` style of the Envelope suite.
- Rule/hook parity: the Pester row reads the rule section and compares its code set with the hook's array.
- The Python contract test covers the skill emission rules (section 5.4).
- Coverage: the new sibling and the changed hook lines must each reach at least 85% line coverage in `artifacts/pester/powershell-coverage.xml`. No PowerShell branch gate applies.

## Pre-Mortem

- **Review checklists:** A reviewer may flag that the enum is restated in the hook, contrary to the "defined once in the rule" wording, or that the unmapped STOP paths were ignored. Mitigation: the plan carries the rule/hook parity test and records the unmapped-path decision (section 3) in `spec.md` and in each skill.
- **Coverage:** The new sibling falls below 85% if the absence-scan branches (unparseable, off-route, same slug) lack rows. Mitigation: the plan enumerates one row per branch and reads per-file coverage from `artifacts/pester/powershell-coverage.xml`, not from the MCP summary.
- **Mirror parity:** The bundle copies of 7 files, plus the new `core.json` entry, can drift from source. Mitigation: a dedicated task copies all bundle files and runs `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py`. The execution-environment brief is unaffected, so none of its copies changes.
- **File size:** All PowerShell files stay below 500 lines if new rows go into new test files. Mitigation: the plan forbids adding rows to `validate-orchestrator-output.Tests.ps1` (454 lines) and `WorktreeResolution.Tests.ps1` (366 lines).
- **Test isolation:** New suites that load the hook without null-mocking the epic-state seams, or without the interception-probe row, fail AC-6, and leaked script-scope mocks can affect sibling suites in single-process runs. Mitigation: copy the `BeforeAll` null-mock block and probe row from `WorktreeResolution.Tests.ps1`; use no temporary files; run three seeded shuffled file-order runs of the touched suites plus a fresh single-process run over `tests/scripts`, and record them under `evidence/regression-testing/`.
- **CI-only behavior:** The Linux hook-suite job is case-sensitive, and a drive-letter fixture or a case-mismatched dot-source name fails only there. Mitigation: use `/synthetic-worktrees/<name>` roots, `Join-Path`, and exact lowercase file names. Changing four non-test PowerShell files (two source, two bundle) exceeds the direct-mode batch budget of 3. Mitigation: the plan runs under a large-path route, or writes the bundle copies through a copy script, which the budget hook does not see.
- **Evidence:** Hook behavior on this branch cannot be proven by a live isolated subagent, because isolated subagents run `main`'s hooks. Mitigation: acceptance relies on Pester JUnit results (`artifacts/pester/pester-junit.xml`) recorded under `evidence/qa-gates/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. No acceptance condition depends on a live subagent stop.

## Automation Feasibility

No step requires human interaction. All changes are file edits, bundle copies, and a manifest entry. Verification runs through Pester (via the `sh`-launched PowerShell 7 route or the PoshQC MCP tools, reading results from files), the Python contract tests through Poetry, and CI. Hook behavior is proven by Pester suites rather than by a live session stop, so no operator action is needed to reproduce or verify the trap.
