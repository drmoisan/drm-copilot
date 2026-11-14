# 2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation (Spec)

- **Issue:** #1012
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T12-40
- **Status:** Approved for planning
- **Version:** 0.2

## Context
The completion stop hook traps a session after a parallel mutation is rejected before any run checkpoint exists. The skill correctly stops without writing state, but the hook then demands a valid parallel checkpoint, so the agent cannot finish. One of four sibling bugs (this one is independent of the target-worktree resolver).

Environment:
- OS/version: not recorded
- Python version: not applicable
- Command/flags used: `/parallel-run <slug>`, `/parallel-add`, `/parallel-close`, `/parallel-remove`
- Data source or fixture: hook `validate-orchestrator-output.ps1` as SubagentStop/Stop for `parallel-orchestrator` and the forked `parallel-run`, `parallel-add`, `parallel-close`, and `parallel-remove` skills

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Invoke `/parallel-run <slug>` from a checkout where the committed kickoff artifact is absent (the planner branch is not checked out), or invoke `/parallel-add` before the run's execution checkpoint exists.
2. The skill stops without delegating or writing state, as its procedure requires.
3. Try to end the session.

Expected:
When no run checkpoint exists AND the agent's output carries a structured rejection signal, the stop is allowed without checkpoint validation.

- Signal: a final line `PARALLEL_MUTATION_REJECTED: <reason-code>`, with a closed reason enum defined once in `.claude/rules/parallel-orchestration.md`: `kickoff_artifact_missing`, `run_not_started`, `items_in_flight`, `unknown_item`.
- Free text is not matched.
- A rejection signal while a checkpoint exists, or any path that wrote state, validates fully as today.
- The four skills emit the signal on each documented STOP path and consume the enum without redefining it.

Actual:
The stop hook requires a valid parallel checkpoint for a known run, finds none, and blocks every stop. The agent cannot finish without fabricating a checkpoint, and the session must be killed from outside.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: none recorded

Design input: `research/research.2026-10-30T12-15.md` in this feature folder is the authoritative design input for every section below.


## Scope & Non-Goals
- In scope:
  - A narrowly gated allow path in `.claude/hooks/validate-orchestrator-output.ps1` for a parallel stop that wrote no state and ends with a valid `PARALLEL_MUTATION_REJECTED: <code>` line.
  - A new dot-sourced sibling `.claude/hooks/validate-orchestrator-output-rejection.ps1` holding the signal parser, the state-absence scan, and the decision helper.
  - A hint line appended to the existing parallel `NoTarget` block message, and a repairable block for a signal line that carries an invalid code.
  - A new rule section `## Mutation Rejection Signal (issue #1012)` in `.claude/rules/parallel-orchestration.md` that defines the signal grammar and the closed code set once.
  - Emission instructions at each mapped STOP path in the `parallel-run`, `parallel-add`, `parallel-close`, and `parallel-remove` skills.
  - Byte-identical bundle copies under `extensions/drm-copilot/resources/claude-customizations/` and one new `pack-manifests/core.json` entry.
  - New Pester and Python tests (listed under Files/modules to change).
- Out of scope / non-goals:
  - Any relaxation of validation when the resolver returns `Resolved` (a checkpoint exists) or when a path wrote state.
  - Any change to `Ambiguous` or `Rejected` resolution outcomes, to `orchestrator-state` or `epic-orchestrator-state` validation, to worktree-isolation behavior, or to checkpoint schemas.
  - Extending the closed code set beyond the four members named in the issue.
  - Changes to the target-worktree resolver introduced by sibling items #1009, #1010, and #1011 (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1` is neither created nor imported here).
  - Changes to `parallel-orchestrate` or to `.claude/agents/parallel-orchestrator.md`.
- Explicitly excluded systems, integrations, or datasets:
  - The Codex surface (`.codex/`), the `.agents/` surface, and the `.github/` surface. Research section 2 found no `validate-orchestrator-output*.ps1` under `.codex/hooks/`, no `.codex/config.toml` registration of this hook, no Codex `parallel-orchestrator` agent, and no `.agents/skills/parallel-*` or `.github` parallel surface. These surfaces need no change.
  - `.claude/settings.json` and its bundle copy, and the frontmatter of `.claude/agents/parallel-orchestrator.md`: the hook command line does not change, so both registrations remain as they are.
  - The execution-environment brief (`.claude/skills/execution-environment/SKILL.md` and its copies): it states no fact this change alters, so none of its copies changes.

## Root Cause Analysis
`validate-orchestrator-output.ps1` has no path for a legitimate no-state stop on a parallel skill.

Detail (research section 1):
- `Invoke-OrchestratorOutputValidation` reads the SubagentStop envelope through `Read-SubagentStopEnvelope` (`.claude/hooks/subagentstop-envelope.ps1`) and passes `last_assistant_message` as `AgentOutput` to `Get-OrchestratorOutputBlockDecision`.
- `Get-OrchestratorOutputBlockDecision` calls `Resolve-OrchestratorOutputCheckpointPath` (`.claude/hooks/validate-orchestrator-output-resolution.ps1`). For kind `parallel`, the resolver extracts `parallel_slug:` with `Find-WorktreeRunIdentitySignal`, otherwise discovers a slug through `Find-OrchestratorOutputRunSignalValue` over `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText`, and then calls `Resolve-WorktreeParallelTarget`. When no live root holds a parseable `route_id: parallel` checkpoint recording the slug, the result is `Status 'NoTarget'` with reason code `TARGET_WORKTREE_NOT_DERIVABLE`.
- Inside the `if (-not $resolution.Resolved)` branch the hook blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: ...`, and marks the block `Repairable = $true` for `NoTarget` and `Ambiguous` on `epic-orchestrator-state` and `parallel-orchestrator-state`. A repairable block is never released by `stop_hook_active`, so a parallel skill that correctly stopped without writing state is blocked on every stop. The only way out for the agent is to fabricate a checkpoint.

## Proposed Fix

### Design summary (what changes where):
- New sibling `.claude/hooks/validate-orchestrator-output-rejection.ps1` with three pure helpers:
  - `Get-ParallelMutationRejectionCode -AgentOutput`: returns the code from a valid final-line signal, or `$null`. Holds the closed code set as a script-scope array with a comment citing `## Mutation Rejection Signal (issue #1012)` in `.claude/rules/parallel-orchestration.md`.
  - `Test-ParallelRunStateAbsent -AgentOutput -SessionRoot`: the live-root state-absence scan (research section 4.2), using `Find-WorktreeRunIdentitySignal` for the slug the output names.
  - `Get-OrchestratorOutputRejectionDecision -ArtifactType -Resolution -AgentOutput -SessionRoot`: returns `@{ Ok = $true; Message = $null }` when every allow condition holds, otherwise `$null`.
- `.claude/hooks/validate-orchestrator-output.ps1` gains one guarded dot-source of the sibling and one call inside the `if (-not $resolution.Resolved)` branch of `Get-OrchestratorOutputBlockDecision`, before that branch's `return`. When the decision helper returns a result, the hook returns it; otherwise the existing block applies.
- The allow path is gated on all of:
  1. `ArtifactType -eq 'parallel-orchestrator-state'`;
  2. `resolution.Status -ceq 'NoTarget'` (not `Ambiguous`, not `Rejected`);
  3. a valid final-line signal matching the case-sensitive pattern `^PARALLEL_MUTATION_REJECTED: (?<code>[a-z_]+)$` whose `code` is an ordinal member of {`kickoff_artifact_missing`, `run_not_started`, `items_in_flight`, `unknown_item`};
  4. the state-absence scan passes (research section 4.2).
- Outcome table (research section 4.3):

| Condition | Result |
| --- | --- |
| parallel, NoTarget, valid signal, state absent | allow (`Ok = $true`), regardless of `stop_hook_active` |
| parallel, NoTarget, no or invalid signal | block as today (repairable), with one appended hint line naming the signal and the rule section |
| parallel, NoTarget, valid signal, non-blank malformed/off-route/same-slug text found | block as today |
| parallel, Ambiguous or Rejected, any signal | block as today |
| parallel, Resolved, any signal | full validation as today |
| orchestrator-state or epic-orchestrator-state, any signal | unchanged |

- Hint line: the parallel `NoTarget` block message keeps its existing `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: NoTarget (...)` prefix and gains one appended line that names the literal signal form `PARALLEL_MUTATION_REJECTED: <code>` and the rule heading `## Mutation Rejection Signal (issue #1012)`, so the repairable block tells the agent how to finish a legitimate no-state stop.
- Invalid-code block: a final line that starts with `PARALLEL_MUTATION_REJECTED:` but carries a code outside the closed set does not allow. The stop blocks as a repairable block whose message lists the allowed codes so the agent can correct the line.
- Rule section: add `## Mutation Rejection Signal (issue #1012)` to `.claude/rules/parallel-orchestration.md`, immediately after `## Enum Ownership (F6/F7/F8 consume, never extend)` and before `## F7 Seam`. It defines the line grammar and the four codes, each with a one-line meaning; states that the signal is an output signal, not a checkpoint field, and is not one of the existing nine enums (the existing count in the rule table and in the skills' `## Constraints` remains true); states the hook behavior from the outcome table; and states the ownership rule (skills consume, never redefine). `.claude/hooks/validate-orchestrator-output-rejection.ps1` may be added to the rule's `paths:` frontmatter.
- Per-skill emission points (research section 3). Each skill adds, at each mapped STOP path, the instruction to end the final output with the literal line `PARALLEL_MUTATION_REJECTED: <code>` naming only that path's code, to make it the last line with no formatting, to emit `parallel_slug: <slug>` before it where the slug is known, and to cite the rule section by heading. No skill lists the full member set.

| Skill | STOP path (heading) | Code |
| --- | --- | --- |
| parallel-run | `## Procedure` step 2, kickoff artifact path does not exist | `kickoff_artifact_missing` |
| parallel-add | `## Prerequisites`, pending or not-started run | `run_not_started` |
| parallel-add | `## Prerequisites`, no checkpoint tracks the run's `parallel_slug` | `run_not_started` |
| parallel-close | `## Prerequisites`, checkpoint does not track the slug | `run_not_started` |
| parallel-close | `## Procedure` step 2, gate exit 1, blocking keys reported | `items_in_flight` |
| parallel-remove | `## Prerequisites`, checkpoint does not track the slug | `run_not_started` |
| parallel-remove | `## State-Dependent Behavior Table`, `in_flight` without `--disposition` | `items_in_flight` |
| parallel-remove | unknown, `withdrawn`, or `blocked` item | `unknown_item` |

- Decision on unmapped STOP paths: the following paths emit no signal, and each affected skill states so explicitly: parallel-add closed run; parallel-add multi-item argument; parallel-add `## Procedure` step 5 and failed preparation under `## Constraints` (state already written); parallel-close `closed`-mode run; parallel-remove argument that is not exactly one integer key; parallel-remove `merged` item; and the `parallel-orchestrate` malformed-manifest and Run Closing stops. Each of these either occurs with a checkpoint present (and validates fully) or follows the run-existence check. The closed set of four codes is not extended in this item.
- Decision on ordering: each of `parallel-add`, `parallel-close`, and `parallel-remove` states that its run-existence check (`run_not_started`) is evaluated first, so an argument-shape rejection is reached only when a checkpoint exists and validates normally.

### Boundaries and invariants to preserve:
- A `Resolved` result always validates fully; a signal never relaxes validation when a checkpoint exists.
- `Ambiguous` and `Rejected` resolutions block as today, with or without a signal.
- `orchestrator-state` and `epic-orchestrator-state` behavior is unchanged for every input.
- Free text is not matched: only the last non-blank line, after trailing whitespace (including `\r`) is trimmed, is considered.
- A parallel resolution with no matching checkpoint yields `Status 'NoTarget'`. This is the only resolver contract this item depends on; sibling items #1009–#1011 must preserve it.
- The new sibling imports no module, invokes no Python, and starts no process.
- The existing nine-enum count in `.claude/rules/parallel-orchestration.md` and in the skills' `## Constraints` remains true.
- Fragments pinned by existing tests remain byte-stable: `RUN_PROCEDURE_FRAGMENTS` in `parallel_orchestrator_surface_expectations.py`; the parallel-add fragments "pending or not-started" and "execution has started" (`test_parallel_planner_surface_contracts.py::test_parallel_intake_requires_consolidation_before_execution`); the parallel-add step 2 and step 3 start lines (`test_parallel_issue_adoption_skill_contracts.py`); the parallel-remove single abandon invocation line (`test_parallel_abandon_token_seam.py`); and the subcommand tokens in `test_skill_bundle_contract_repo.py`.
- The hook registration command lines (pinned by `HOOK_COMMAND_FRAGMENTS`) do not change.

### Dependencies or blocked work:
- No blocking dependency. Sibling items #1009, #1010, and #1011 are expected to edit `validate-orchestrator-output.ps1` (dependency-load block and `Get-OrchestratorOutputBlockDecision`), `validate-orchestrator-output-resolution.ps1`, the hook's bundle copy, and `core.json`. The sibling feature folders are not present in this checkout, so their exact file sets are unknown; the orchestrator confirms overlap at scheduling time. This item limits the main-hook edit to one guarded load statement and one call to reduce merge contention.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Production and documentation (repository source):
1. `.claude/hooks/validate-orchestrator-output.ps1` (edit)
2. `.claude/hooks/validate-orchestrator-output-rejection.ps1` (new)
3. `.claude/rules/parallel-orchestration.md` (edit; the change writes this rule file, as the issue requires)
4. `.claude/skills/parallel-run/SKILL.md` (edit)
5. `.claude/skills/parallel-add/SKILL.md` (edit)
6. `.claude/skills/parallel-close/SKILL.md` (edit)
7. `.claude/skills/parallel-remove/SKILL.md` (edit)

Bundle copies (byte-identical to source):
8. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`
9. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-rejection.ps1` (new)
10. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` (the change writes this bundle copy of the rule file)
11. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-run/SKILL.md`
12. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
13. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-close/SKILL.md`
14. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md`

Pack manifest:
15. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: add `.claude/hooks/validate-orchestrator-output-rejection.ps1` next to the existing `validate-orchestrator-output-*.ps1` entries. The other changed files are already listed.

Tests (new):
16. `tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1`: unit rows for the three helpers.
17. `tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1`: end-to-end rows through `Invoke-OrchestratorOutputValidation` using the `Set-OutputRunTopology` pattern, one `Invoke-HookTail`-style exit-0 row, and a rule-to-hook enum parity row.
18. `tests/scripts/dev_tools/test_parallel_mutation_rejection_signal_contracts.py`: Python contract test for skill emission.

Not changed: `.claude/settings.json` and its bundle copy; `.claude/agents/parallel-orchestrator.md` (body and frontmatter); `.claude/skills/parallel-orchestrate/SKILL.md`; every `.codex/`, `.agents/`, and `.github/` file; the execution-environment brief and its copies; `config/poshqc-coverage.json` (it lists the `.claude/hooks` directory, so the new file enters the coverage population automatically); `config/file-size-baseline.json`.

#### Functions/classes/CLI commands impacted:
- `Get-OrchestratorOutputBlockDecision` (edited: one call in the unresolved branch; hint line appended to the parallel `NoTarget` message).
- New: `Get-ParallelMutationRejectionCode`, `Test-ParallelRunStateAbsent`, `Get-OrchestratorOutputRejectionDecision`.
- Reused without change: `Resolve-OrchestratorOutputCheckpointPath`, `Find-WorktreeRunIdentitySignal`, `Get-WorktreeItemLiveRoot`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunCheckpointPath`, `Add-HookDependencyFailure`, `Get-HookDependencyFailureDecision`, `Read-SubagentStopEnvelope`, `Invoke-OrchestratorOutputValidation`.
- Skill commands affected (output text only): `/parallel-run`, `/parallel-add`, `/parallel-close`, `/parallel-remove`.

#### Data flow and validation changes:
1. Envelope → `AgentOutput` (unchanged).
2. Empty-output check and resolver call (unchanged).
3. Unresolved branch: `Get-OrchestratorOutputRejectionDecision` evaluates artifact type, `Status`, signal, and state absence. Allow returns `Ok = $true`. Otherwise the existing block is returned, with the hint line for parallel `NoTarget`, or with the allowed-code list when the final line carries the signal prefix and an invalid code.
4. State-absence scan: for every live root from `Get-WorktreeItemLiveRoot`, the text from `Get-WorktreeRunCheckpointText` at `Get-WorktreeRunCheckpointPath -Kind parallel` must be null or blank, or parse as an object with `route_id == 'parallel'` whose `parallel_slug` differs from the slug the output names (when it names one). Any non-blank text that is unparseable, has a non-object root, is off-route, lacks a slug, or records the named slug defeats the allow.
5. Resolved branch (unchanged): checkpoint read, required fields, `Test-HumanInteractionShape`, `Invoke-RoutingContractValidation`, feature-folder probe, wave barrier.

#### Error handling and logging updates:
- The sibling is loaded with a single-statement guarded dot-source: `try { . (Join-Path $PSScriptRoot 'validate-orchestrator-output-rejection.ps1') } catch { Add-HookDependencyFailure -Name 'validate-orchestrator-output-rejection.ps1' -ErrorRecord $_ }`. A load failure surfaces through the existing `Get-HookDependencyFailureDecision` path (fail closed).
- An exception inside the decision helper propagates to the script tail, which already converts it into `Exit-SubagentStopBlock` with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: validator error: ...` (fail closed).
- Block messages: one hint line on the parallel `NoTarget` block; an allowed-code list on the invalid-code block. No new logging channel.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the change set; removing the guarded dot-source and the single call restores the previous decision path exactly. The rule section and skill instructions are additive text.

### Implementation decisions (recorded at execution):
- Fourth helper (plan Design Decision 2): the sibling `.claude/hooks/validate-orchestrator-output-rejection.ps1` holds a fourth helper, `Get-ParallelMutationRejectionHint -ArtifactType -Status -AgentOutput`, in addition to the three named above. It returns the text appended to an unresolved block message: an empty string unless the artifact type is `parallel-orchestrator-state` and the status is `NoTarget`; otherwise one hint line naming `PARALLEL_MUTATION_REJECTED: <code>` and `## Mutation Rejection Signal (issue #1012)`, plus a line listing the allowed codes when the last non-blank line begins with `PARALLEL_MUTATION_REJECTED:` and carries no valid code. Keeping the hint in the sibling keeps the code array referenced only there and limits the main-hook edit to one guarded load statement, one decision call, and one message append.
- Bundle copies and batch budget (plan Design Decision 6): the two bundle PowerShell copies and the five bundle Markdown copies are written by a copy script run under `sh`, which the batch-budget hook does not see, so only the two source PowerShell files were written through `Write` or `Edit`. Direct mode therefore suffices; the executing worktree's checkpoint also selected the large route.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: `last_assistant_message` from the SubagentStop envelope (string), `stop_hook_active` (boolean), `-CheckpointPath`, `-ArtifactType` (unchanged parameters).
- Signal grammar: the last non-blank line of the message after trailing whitespace (including `\r`) is trimmed must match `^PARALLEL_MUTATION_REJECTED: (?<code>[a-z_]+)$` case-sensitively, with exactly one space after the colon, no Markdown wrapping, and no trailing text. `code` must be an ordinal member of {`kickoff_artifact_missing`, `run_not_started`, `items_in_flight`, `unknown_item`}. Not a signal: the token on an earlier line or inside free text, inside backticks or bold, a lowercase prefix, an uppercase code, extra tokens, a double space after the colon, or a code outside the set.
- `Get-ParallelMutationRejectionCode` output: `[string]` code or `$null`.
- `Test-ParallelRunStateAbsent` output: `[bool]`.
- `Get-OrchestratorOutputRejectionDecision` output: `@{ Ok = $true; Message = $null }` or `$null`.
- Hook output on allow: exit 0 with no block decision.

#### Required configuration keys and defaults:
- None. No configuration file, setting, or registration changes.

#### Backward-compatibility expectations:
- Every input that does not satisfy all allow conditions produces the same decision as before, except that the parallel `NoTarget` block message gains one appended line; its existing prefix is unchanged, so `StartsWith` assertions (for example R8) continue to hold.
- No checkpoint schema, enum, or registration changes.

#### Performance constraints (latency/throughput/memory):
- The state-absence scan runs only on the parallel `NoTarget` path with a valid signal, and reads the same live-root checkpoint texts the resolver already reads. No additional process start, network call, or Python invocation.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Claude Code supplies `last_assistant_message` on Stop and SubagentStop as the final assistant text of the turn (confirmed in research section 1.3 against the hooks reference).
  - The forked parallel skills stop as SubagentStop events with agent type `parallel-orchestrator`, covered by the `.claude/settings.json` registration and the `.claude/agents/parallel-orchestrator.md` frontmatter registration (research section 2 and Numeric Derivation Evidence N2).
  - Of the skills that fork `parallel-orchestrator`, only `parallel-run`, `parallel-add`, `parallel-close`, and `parallel-remove` document a no-state STOP path; `parallel-orchestrate` does not (research section 3 and Numeric Derivation Evidence N1).
- Constraints (budget, performance, compatibility):
  - Enforcement hooks must not use Python; the sibling is PowerShell only.
  - New tests run in the Linux `poshqc / PowerShell hook suites` job: use case-sensitive matching (`-cmatch`, ordinal comparison), exact lowercase file names, `Join-Path`, and `/synthetic-worktrees/<name>` roots; no drive letters or backslash literals.
  - No temporary files in tests.
  - New suites that load the hook null-mock the epic-state seams and call `Invoke-EpicStateInterceptionProbe` inside an `It` (`enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-6).
  - New rows go into new test files; no rows are added to `validate-orchestrator-output.Tests.ps1` or `validate-orchestrator-output.WorktreeResolution.Tests.ps1`.
  - Changing more than three non-test PowerShell files exceeds the direct-mode batch budget; the plan uses a large-path route or writes bundle copies through a copy script.
- External dependencies (services, libraries, releases):
  - None beyond the existing Pester, PoshQC, and Poetry toolchains. Isolated subagents run `main`'s hooks, so hook behavior on this branch is proven by Pester results, not by a live subagent stop.

## Data / API / Config Impact
- User-facing or API changes:
  - New output convention for the four parallel skills: a final line `PARALLEL_MUTATION_REJECTED: <code>` on mapped STOP paths.
  - The parallel `NoTarget` block message gains one hint line; the invalid-code block lists the allowed codes.
- Data or migration considerations:
  - None. No checkpoint field or schema is added or changed.
- Logging/telemetry updates (if any):
  - None beyond the block-message text changes above.
- Compatibility notes (CLI flags, config schemas, versioning):
  - Hook parameters and registrations are unchanged. The bundle copies and the `core.json` entry keep push-down destinations consistent with the repository source.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: each reason with no checkpoint → allow; the signal with a checkpoint present → normal validation; no signal and no checkpoint → block, as today.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity: update `.claude/rules/parallel-orchestration.md` (the rejection enum), mirrored and bundled copies, and Codex counterparts where the hook is carried. Contract tests, pack-manifest completeness, and no Python in hooks.

Out of scope: no relaxation of validation when a checkpoint exists or state was written; no change to worktree-isolation behavior or checkpoint schemas.

- Regression tests to add or update:
  - Unchanged and must keep passing: `validate-orchestrator-output.WorktreeResolution.Tests.ps1` `R8 blocks a parallel validation as NoTarget when no live parallel checkpoint exists` (the no-signal, no-checkpoint regression row), R9, R10, R11; `validate-orchestrator-output.Reentry.Tests.ps1` `O-5 epic target not derivable blocks always`; `validate-orchestrator-output.Envelope.Tests.ps1` `E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved`; `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` `denies a missing parallel checkpoint (fail closed)`; `validate-orchestrator-output.WaveBarrier.Tests.ps1` `H5 does not run the port for the parallel checkpoint type`; the parallel row in `validate-orchestrator-output.FeatureFolder.Tests.ps1`; `validate-orchestrator-output-resolution.Tests.ps1` `S2-6 passes the cross-check for every existing SubagentStop registration unchanged`.
  - Re-evaluated: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` S1–S6 for the main hook and the new guarded dot-source; `tests/scripts/claude-runtime` no-Python-in-hooks suite.
- Unit tests (Pester) for the fixed behavior and boundaries (`validate-orchestrator-output-rejection.Tests.ps1`):
  - each code parsed; trailing CRLF and trailing blank lines tolerated;
  - the absence scan for blank, unparseable, non-object, off-route, missing-slug, same-slug, and other-slug text;
  - decision helper returns `Ok` only when all gates hold, and `$null` for each gate that fails.
- End-to-end tests (`validate-orchestrator-output.MutationRejection.Tests.ps1`):
  - each code with no checkpoint → `Ok` with `stop_hook_active` false and true;
  - signal with a resolved checkpoint → `Get-CheckpointFileContent` and the routing seam invoked, and a structural failure still blocks;
  - no signal and no checkpoint → NoTarget block on both stops, message carries the hint line;
  - invalid code → repairable block listing the allowed codes;
  - signal plus `Ambiguous` → block; signal plus `Rejected` leaf → block;
  - signal on `orchestrator-state` and `epic-orchestrator-state` → unchanged block;
  - signal plus a malformed or same-slug parallel file in a live root → block;
  - one script-tail row asserting exit code 0 in the `Invoke-HookTail` style;
  - rule-to-hook parity: reads `## Mutation Rejection Signal (issue #1012)` from `.claude/rules/parallel-orchestration.md` and compares its code set with the hook's array.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - token not on the last line; token followed by text; lowercase prefix; uppercase code; backtick-wrapped; bold-wrapped; double space after the colon; unknown code; empty output.
- Python contract test (`test_parallel_mutation_rejection_signal_contracts.py`): each of the four skills emits only codes present in the rule section, emits only its mapped code at each mapped STOP path, cites the rule heading, and does not restate the full member set.
- Error handling and logging verification:
  - sibling load failure surfaces as a dependency-failure block (covered by the dependency-guard suite and a unit row where feasible);
  - hint-line and allowed-code message text asserted.
- Coverage impact and targets for changed lines/modules:
  - `validate-orchestrator-output-rejection.ps1` and the changed lines of `validate-orchestrator-output.ps1` each at or above 85% line coverage, read per file from `artifacts/pester/powershell-coverage.xml` (not from the MCP summary). No PowerShell branch gate applies.
- Toolchain commands to run (format → lint → type-check → test):
  - PowerShell: Invoke-Formatter, PSScriptAnalyzer, Pester (with coverage) through the `sh`-launched PowerShell 7 route or the PoshQC MCP tools, reading results from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`.
  - Python contract tests through Poetry: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_claude_rules_frontmatter.py`, the parallel surface contract files, and the new contract test (with Black, Ruff, and Pyright on the new Python file).
  - Test isolation: three seeded shuffled file-order runs of the touched suites and one fresh single-process run over `tests/scripts`, recorded under `evidence/regression-testing/`.
  - QA evidence recorded under `evidence/qa-gates/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Manual validation steps (if required):
  - None. No acceptance condition depends on a live subagent stop.


## Acceptance Criteria
- [x] AC-1: For each code `kickoff_artifact_missing`, `run_not_started`, `items_in_flight`, and `unknown_item`, a `parallel-orchestrator-state` stop whose final line is `PARALLEL_MUTATION_REJECTED: <code>`, with no live parallel checkpoint, returns `Ok` through `Invoke-OrchestratorOutputValidation` with `stop_hook_active` false and with `stop_hook_active` true (rows in `tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1`).
- [x] AC-2: A script-tail row in `validate-orchestrator-output.MutationRejection.Tests.ps1` shows the hook exits 0 for a valid signal with no live parallel checkpoint.
- [x] AC-3: A valid signal with a resolved parallel checkpoint runs full validation: `Get-CheckpointFileContent` and the routing seam are invoked, and a structurally invalid checkpoint still blocks.
- [x] AC-4: With no signal and no checkpoint, the parallel stop blocks as `NoTarget` on both stops; the existing test `R8 blocks a parallel validation as NoTarget when no live parallel checkpoint exists` passes without modification, and the block message carries one appended hint line naming `PARALLEL_MUTATION_REJECTED: <code>` and `## Mutation Rejection Signal (issue #1012)`.
- [x] AC-5: No allow occurs for a non-conforming signal: token on an earlier line, token followed by text, lowercase prefix, uppercase code, backtick-wrapped, bold-wrapped, double space after the colon, unknown code, or empty output (unit rows in `validate-orchestrator-output-rejection.Tests.ps1`); trailing CRLF and trailing blank lines after a valid line are tolerated.
- [x] AC-6: A final line with the `PARALLEL_MUTATION_REJECTED:` prefix and a code outside the closed set produces a repairable block whose message lists the allowed codes.
- [x] AC-7: A valid signal with resolver `Status` `Ambiguous`, or with a `Rejected` leaf, blocks as today.
- [x] AC-8: A valid signal with no resolvable checkpoint blocks when any live root holds non-blank parallel checkpoint text that is unparseable, has a non-object root, is off-route, lacks a slug, or records the slug the output names; other-slug and blank text do not defeat the allow.
- [x] AC-9: A valid signal on `orchestrator-state` and on `epic-orchestrator-state` produces the same decision as without the signal; `O-5 epic target not derivable blocks always`, `E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved`, R9, R10, R11, `H5 does not run the port for the parallel checkpoint type`, `denies a missing parallel checkpoint (fail closed)`, and `S2-6 passes the cross-check for every existing SubagentStop registration unchanged` pass without modification.
- [x] AC-10: `.claude/rules/parallel-orchestration.md` contains `## Mutation Rejection Signal (issue #1012)` immediately after `## Enum Ownership (F6/F7/F8 consume, never extend)` and before `## F7 Seam`, defining the line grammar and the closed code set exactly once, stating it is an output signal and not one of the nine enums, and stating the hook behavior and the consume-never-redefine rule.
- [x] AC-11: A Pester parity row reads the rule section and asserts its code set equals the script-scope array in `validate-orchestrator-output-rejection.ps1`.
- [x] AC-12: `test_parallel_mutation_rejection_signal_contracts.py` passes, asserting that `parallel-run`, `parallel-add`, `parallel-close`, and `parallel-remove` each emit only their mapped code on each mapped STOP path in the emission table, cite `## Mutation Rejection Signal (issue #1012)` by heading, and do not restate the full member set.
- [x] AC-13: `parallel-add`, `parallel-close`, and `parallel-remove` each state that the run-existence check is evaluated first, and the affected skills state that the unmapped STOP paths listed in this spec emit no signal; all pinned fragments listed under Boundaries and invariants remain byte-stable and their tests pass.
- [x] AC-14: The changed or new source files listed as items 1–7 under Files/modules to change are byte-identical to their bundle copies (items 8–14), `pack-manifests/core.json` lists `.claude/hooks/validate-orchestrator-output-rejection.ps1`, and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, and `test_claude_rules_frontmatter.py` pass.
- [x] AC-15: `hook-dependency-guard-completeness.Tests.ps1` (S1–S6) and the no-Python-in-hooks suite pass; the new sibling is loaded by a single-statement guarded `try` with `Add-HookDependencyFailure`, imports no module, and starts no process.
- [x] AC-16: `.claude/settings.json`, `.claude/agents/parallel-orchestrator.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, the execution-environment brief, and every `.codex/`, `.agents/`, and `.github/` file are unchanged in the branch diff.
- [x] AC-17: `validate-orchestrator-output-rejection.ps1` and `validate-orchestrator-output.ps1` each report at or above 85% line coverage in `artifacts/pester/powershell-coverage.xml`.
- [x] AC-18: The full toolchain passes in a single pass (format, lint, type-check, architecture, unit, contract, integration) for the changed PowerShell and Python files, the new suites satisfy `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-6, and three seeded shuffled runs plus one single-process run over `tests/scripts` pass, with evidence under `evidence/qa-gates/` and `evidence/regression-testing/`.
- [x] AC-19: No changed or new file exceeds 800 logical lines.
- [x] AC-20 (CI-dependent): The CI run on the PR head, including the Linux `poshqc / PowerShell hook suites` job, concludes `success`.

### Acceptance Criteria Evidence

Paths are relative to this feature folder.

| AC | Evidence |
| --- | --- |
| AC-1 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md`; `evidence/qa-gates/pester-coverage.2026-10-31T11-13.md` (MutationRejection AC-1 rows, 8 of 8 passed) |
| AC-2 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md`; `evidence/qa-gates/pester-coverage.2026-10-31T11-13.md` (script-tail row passed) |
| AC-3 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (AC-3 rows passed) |
| AC-4 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (AC-4 rows and R8 passed); `evidence/qa-gates/assertion-preservation.2026-10-31T10-57.md` (R8 suite unmodified) |
| AC-5 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (parser rows in validate-orchestrator-output-rejection.Tests.ps1 passed) |
| AC-6 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (invalid-code rows passed) |
| AC-7 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (Ambiguous and Rejected rows passed) |
| AC-8 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (scan rows and AC-8 rows passed) |
| AC-9 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (AC-9 rows, O-5, E-ORC-2, R9, R10, R11, H5, the fail-closed dispatch row, and S2-6 passed); `evidence/qa-gates/assertion-preservation.2026-10-31T10-57.md` |
| AC-10 | `evidence/qa-gates/python-contracts.2026-10-31T10-56.md` (rule-section tests passed) |
| AC-11 | `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (parity row passed) |
| AC-12 | `evidence/qa-gates/python-contracts.2026-10-31T10-56.md` (skill emission tests passed) |
| AC-13 | `evidence/qa-gates/python-contracts.2026-10-31T10-56.md` (run-existence and unmapped-path tests and the pinned-fragment modules passed) |
| AC-14 | `evidence/qa-gates/mirror-parity.2026-10-31T10-57.md` |
| AC-15 | `evidence/qa-gates/pester-coverage.2026-10-31T11-13.md` (hook-dependency-guard-completeness and no-Python suites passed); `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` (S1 through S6 rows; AST row) |
| AC-16 | `evidence/qa-gates/scope-check.2026-10-31T10-57.md` |
| AC-17 | `evidence/qa-gates/coverage-comparison.2026-10-31T11-13.md` |
| AC-18 | `evidence/qa-gates/poshqc-format.2026-10-31T10-56.md`, `evidence/qa-gates/pssa.2026-10-31T10-56.md`, `evidence/qa-gates/python-black.2026-10-31T10-56.md`, `evidence/qa-gates/python-ruff.2026-10-31T10-56.md`, `evidence/qa-gates/python-pyright.2026-10-31T10-56.md`, `evidence/qa-gates/pester-coverage.2026-10-31T11-13.md`, `evidence/qa-gates/python-contracts.2026-10-31T10-56.md`, `evidence/qa-gates/mirror-parity.2026-10-31T10-57.md`, `evidence/regression-testing/isolation.2026-10-31T11-33.md` |
| AC-19 | `evidence/qa-gates/line-counts.2026-10-31T10-58.md` |
| AC-20 | pending CI on the pull request head; checked off at S9 by the executing orchestrator run |

## Risks & Mitigations
- Technical or operational risks:
  - False allow: an agent writes state and emits the signal. A well-formed checkpoint resolves and validates fully; a malformed or partial write is caught by the state-absence scan. Residual: state written outside the canonical parallel path is not observable to the hook, consistent with the documented contract that rejected mutations change nothing.
  - False block (trap persists): the agent formats the line or adds text after it, or a stale unparseable parallel checkpoint exists in a live worktree.
  - Discovery picks another run: an output naming no `parallel_slug:` with exactly one other live run resolves to that run and validates it structurally; a well-formed checkpoint passes.
  - Linux-only failures from case or path literals in the new tests.
  - Enum restated in the hook contrary to "defined once in the rule".
  - Merge overlap with #1009, #1010, and #1011 in the main hook, resolver sibling, bundle copy, and `core.json`.
  - Bundle-copy drift across the mirrored files and the `core.json` entry.
- Mitigations and rollbacks:
  - Allow requires `NoTarget` plus the state-absence scan; `Resolved` always validates fully.
  - Each skill states the exact literal and that it must be the last line; the `NoTarget` block message carries the hint line; the invalid-code block lists allowed codes; the stale-checkpoint remedy is the existing `artifacts/orchestration/handoff/` move.
  - Skills emit `parallel_slug: <slug>` before the signal where the slug is known.
  - Case-sensitive matching, `Join-Path`, `/synthetic-worktrees/<name>` roots, exact lowercase file names.
  - Rule-to-hook parity test (AC-11).
  - Logic isolated in a new sibling; main-hook edit limited to one guarded load and one call.
  - Dedicated bundle-copy step verified by the push-down contract tests (AC-14).
  - Rollback: revert the change set.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge to `main`; the repository hooks take effect for sessions using `main`. Push-down destinations receive the change on the next extension rebuild and reinstall, because push-down serves the installed extension payload.
- Post-fix monitoring or clean-up tasks:
  - Confirm on the next parallel rejection in a live session that the stop is released.
  - Confirm with the orchestrator that #1009–#1011 preserve the parallel `NoTarget` contract when they merge.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/1012; research `research/research.2026-10-30T12-15.md`; rule `.claude/rules/parallel-orchestration.md`; sibling items #1009, #1010, #1011.
