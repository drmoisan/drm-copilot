# owner-directive-pass-down — Spec

- **Issue:** #1157
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T21-37
- **Status:** Draft
- **Version:** 0.1
- **Work Mode:** full-feature
- **Research:** `docs/features/active/owner-directive-pass-down-1157/research/research.2026-11-09T21-37.md`
- **Prior art:** issue #1139, `docs/features/active/2026-11-08-owner-directive-relay-1139/spec.md`, `.claude/skills/owner-directives/SKILL.md`

## Overview

Issue #1139 defined recorded owner directives (`owner_directives[]`), per-directive decision records (`owner_directive_records[]`), the closed honor/refuse class set, the fenced `Owner directives:` relay format, and the stop-hook rules B1-B8 and R1-R10. Relay itself remained prose only: nothing moves a directive from a parent checkpoint to a child checkpoint or into a worker's context. Two failures followed. An epic orchestrator ended its turn after launching children, so the directives it was asked to relay never reached them. A feature orchestrator blocked on its running executor could not deliver a course correction, and the executor kept retrying non-compliant commands for many minutes after the owner's instruction.

This feature makes pass-down mechanical and independent of any orchestrator being active:

- A coordinator ledger (`artifacts/orchestration/owner-directives.jsonl`, per worktree, append-only) lets the coordinator record directives without writing a checkpoint owned by a running agent.
- A new standalone Claude PreToolUse hook, `.claude/hooks/enforce-owner-directive-pass-down.ps1`, (a) denies a worker or `orchestrator` delegation whose item checkpoint or prompt lacks a selected directive (relay mode), and (b) holds a worker agent on its next matched tool call, with the rendered directive block as the deny reason, until it writes a decision file per pending directive (acknowledgement mode).
- A new stop-hook check, `OWNER_DIRECTIVE_RELAY_MISSING`, verifies that every in-scope running child of an epic or parallel parent, and every item checkpoint at stop, holds the parent's unexpired directives.
- Workers record `honored` or `refused` per directive (decision file or return line), and the orchestrator writes those decisions to `owner_directive_records` on return.

Personas: the repository owner (issues directives), the coordinator session (records and relays them), item, epic, and parallel orchestrators (pass them down), and executors and other workers (decide and record).

Success measure: a directive recorded by the coordinator reaches a running worker on the worker's next matched tool call, without any orchestrator acting, and the worker cannot run a matched tool until it has recorded a decision for it. With no directive sources present, behavior equals today's.

## Design Decisions

Adopted verbatim from the research record, `## Recommended Design Decisions`, as the decisions of record.

- **D1.** Deliver the mechanism as one standalone Claude PreToolUse hook, `.claude/hooks/enforce-owner-directive-pass-down.ps1`, with two modes chosen from the payload: acknowledgement mode for a call whose `agent_type` is in the acknowledgement set, and relay mode for an `Agent` or `Task` call whose target `subagent_type` is a worker or `orchestrator`. All PowerShell; no Python, no TypeScript.
- **D2.** Inject by denying: `permissionDecision: "deny"` with the rendered block in `permissionDecisionReason`, prefix `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:` and sub-codes `OWNER_DIRECTIVE_DECISION_REQUIRED`, `OWNER_DIRECTIVE_DECISION_INVALID`, `OWNER_DIRECTIVE_RELAY_REQUIRED`, `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`. Emit nothing on allow. Do not use `additionalContext` or `allow`.
- **D3.** Acknowledgement set: `atomic-executor`, `atomic-planner`, `feature-review`, `task-researcher`, `prd-feature`, `python-typed-engineer`, `powershell-typed-engineer`. Relay targets add `csharp-typed-engineer`, `typescript-engineer`, and `orchestrator`. The two engineers without `Write` record decisions in return lines only; this is documented as a limitation.
- **D4.** Resolve the item root from payload `cwd` first (enclosing registered worktree holding `artifacts/orchestration/orchestrator-state.json`), then from the worker's delegation prompt read from its subagent transcript (`agent-<agent_id>.jsonl`, derived from `transcript_path`) through `Resolve-HookTargetWorktree`, else stay inert. Resolve the parent through `epic_context.integration_branch` (`Resolve-WorktreeEpicTarget`) or `parallel_slug` (`Resolve-WorktreeParallelTarget`).
- **D5.** Add the coordinator ledger `artifacts/orchestration/owner-directives.jsonl` per worktree (one directive object per line, B2-B8 per line, append-only, written only by the main session). The hook reads item checkpoint, item ledger, parent checkpoint, and parent ledger. The hook denies ledger writes by any subagent, any `Edit` of a ledger, and any `Write` that does not keep existing lines as a prefix.
- **D6.** Relay mode denies a delegation when a selected directive is missing from the item checkpoint (same `id` and `text_sha256`) or its rendered lines are missing from the prompt; the deny reason carries the block and the JSON entries to append. For a child `orchestrator` launch by an epic or parallel coordinator, only the prompt check applies, against the caller's parent sources filtered by the prompt's canonical issue line.
- **D7.** Scope rule: item match on `issue` (and `branch` when the item branch is known); epic fan-out when `scope.issue == epic_issue_num` and `scope.branch == integration_branch`; step match on `any`, exact `next_step`, or `next_step` prefix `<step>_`. Unexpired means `expires_at > Now`. Refused classes are selected, flagged, and accept only `refused`.
- **D8.** Id allocation: ids are unique across a parent checkpoint and ledger and all child checkpoints and ledgers; same id and hash is one entry; same id with a different hash is a conflict reported by the stop-hook check, and the item-local entry wins in the hook.
- **D9.** Return-line and decision-file grammar: `OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at|-> | <reason>`. Decision files at `artifacts/orchestration/owner-directive-decisions/<agent_id>/<id>.md`, one line, write-once, written only by the matching `agent_id`, validated by the hook at write time (class, refused-class, expiry, future time, reason length).
- **D10.** On return the orchestrator first copies missing selected entries into `owner_directives`, then appends one `owner_directive_records` entry per decision with `decided_by` set to the worker agent type; a decision file takes precedence over a return line for the same id; optional tolerated fields `agent_id` and `decision_source`.
- **D11.** Pure logic in two new modules: `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1` (scope, selection, rendering, prompt and checkpoint coverage, running-child coverage) and `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1` (grammar, decision validation, decision path, pending set, ledger append-only check). `OrchestratorStateOwnerDirectives.psm1` gains one exported per-entry function that returns the B2-B8-valid entries of a JSON array or ledger text, so the B rules are not duplicated. The two new modules read no clock, no file, and start no process.
- **D12.** I/O in thin adapters: the hook entry file, its dot-sourced sibling `.claude/hooks/owner-directive-pass-down-target.ps1` (item and parent resolution, transcript read, checkpoint/ledger/decision-file reads, clock seam), and the stop-hook sibling `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`. Each seam is an injectable script block or a mockable function; tests use in-memory content and a fixed clock.
- **D13.** Stop-hook check `OWNER_DIRECTIVE_RELAY_MISSING` in `validate-orchestrator-output.ps1` through the new sibling: epic and parallel parents check every running child (presence in the child checkpoint, or a child checkpoint that links back to this parent); the item checkpoint must contain every entry selected for it from its ledger and parent. Key-gated, one clock reading through a seam, repairable. R3 and R6 unchanged.
- **D14.** Relay independence: hook-level pass-down only. Do not add a no-end-turn rule.
- **D15.** Register the hook as a new `hooks.PreToolUse[]` element in `.claude/settings.json` and its bundle copy with matcher `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*`. No new configuration knob: with no ledger and no `owner_directives` in any source, both modes are inert, so behavior equals today's.
- **D16.** Documentation per Section 6; do not edit `.claude/agents/epic-orchestrator.md`; re-baseline only the epic skill digest, computed after the final `origin/main` merge; update the six execution-environment copies in the same change.
- **D17.** No Codex or Copilot hook twin and no Python or TypeScript validator change; state both as extensions of the existing limitations in the owner-directives skill and the rule.

Notes on reading the decisions: "Section 6" in D16 refers to research Section 6 (`## 6. Documentation Surfaces, Mirrors, and Pinning Tests`). The matcher value in D15 is a regular expression evaluated by the Claude Code hook runtime; it is not a file path.

## Behavior

### Directive sources

The hook and the stop-hook check read four directive sources for an item:

- the item checkpoint `artifacts/orchestration/orchestrator-state.json`, key `owner_directives`;
- the item ledger `artifacts/orchestration/owner-directives.jsonl` in the item worktree;
- the parent checkpoint (`artifacts/orchestration/epic-orchestrator-state.json` or `artifacts/orchestration/parallel-orchestrator-state.json` in the parent worktree), key `owner_directives`;
- the parent ledger `artifacts/orchestration/owner-directives.jsonl` in the parent worktree.

The ledger holds one directive object per line, in the same shape as an `owner_directives` entry. It is written only by the coordinator main session, append-only. A coordinator that owns a checkpoint (a standalone `/orchestrate` main session) may still write `owner_directives` directly, as #1139 specifies.

### Selection

For an item with issue `I`, branch `Bc` (from the item root's `git worktree list --porcelain` record; `$null` when detached or unknown), and step `St` (the item checkpoint `next_step`), an entry is selected when all of the following hold:

1. The entry passes B2-B8 (decided by the new exported per-entry function in `OrchestratorStateOwnerDirectives.psm1`; the B rules are not reimplemented).
2. Scope matches: either (item match) `scope.issue == I` and, when `Bc` is not `$null`, `scope.branch == Bc` by ordinal comparison; or (epic fan-out) the entry comes from an epic parent source, `scope.issue == epic_issue_num`, and `scope.branch == integration_branch` by ordinal comparison.
3. Step matches: `scope.step` is `any`, or `St` equals `scope.step` ordinally, or `St` starts with `scope.step` followed by `_`.
4. The entry is unexpired: `expires_at > Now`, strictly. An entry with `expires_at` equal to `Now` is not selected.

Refused classes (`gate_bypass`, `force_push`, `tag_or_publish`, `policy_or_settings_edit`, `evidence_alteration`, `unclassified`) are selected with `IsRefusedClass = $true`, never dropped. Duplicate ids: an identical `id` and `text_sha256` across sources yields one selected entry; the same `id` with a different `text_sha256` is a conflict, the item-local entry (item checkpoint, then item ledger) is kept, and the conflict is returned to the caller.

### Relay mode (delegation)

For an `Agent` or `Task` call from any caller (including the main session) whose `subagent_type` is in the relay target set (`atomic-executor`, `atomic-planner`, `feature-review`, `task-researcher`, `prd-feature`, `python-typed-engineer`, `powershell-typed-engineer`, `csharp-typed-engineer`, `typescript-engineer`, `orchestrator`), the hook selects entries for the resolved item and denies with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED:` when any selected entry is missing from the item checkpoint `owner_directives` (matched on `id` and `text_sha256`) or its rendered header line or quoted text line is missing from the prompt. The deny reason contains the rendered block and the JSON entries to append. The item orchestrator therefore records and pastes the block before every worker delegation in preparation (S2-S4 including preflight), execution (S5), remediation, and review (S7 and R4). For a child `orchestrator` launch by an epic or parallel coordinator, the child worktree does not yet exist; only the prompt check applies, against the caller's parent sources filtered by the prompt's canonical issue line, and the child records the entries at its first checkpoint write (checked by the child's stop hook).

### Acknowledgement mode (running worker)

For a matched tool call whose payload `agent_type` is in the acknowledgement set (`atomic-executor`, `atomic-planner`, `feature-review`, `task-researcher`, `prd-feature`, `python-typed-engineer`, `powershell-typed-engineer`):

- Pending = selected entries whose decision file `artifacts/orchestration/owner-directive-decisions/<agent_id>/<id>.md` under the item root does not exist.
- While pending is non-empty, the call is denied with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_DECISION_REQUIRED:` followed by the rendered block, an always-refused note for each flagged entry, the absolute decision-file path for each pending id, the line grammar, and the hook's clock reading to use as `decided_at`.
- A `Write` by the calling `agent_id` of the decision file of a pending id, whose content is one valid decision line, is not denied by this hook. An invalid line is denied with `OWNER_DIRECTIVE_DECISION_INVALID:`.
- A `Write` to an existing decision file, an `Edit` of a decision file, or a `Write` of another `agent_id`'s decision file is denied with `OWNER_DIRECTIVE_DECISION_INVALID:` (write-once).
- When pending is empty, the hook emits nothing. A directive added later (ledger append or checkpoint write) becomes pending and is injected on the worker's next matched tool call.
- `Read`, `Grep`, and `Glob` are not in the matcher, so a held agent can still read.
- An `agent_id` that does not match `^[A-Za-z0-9][A-Za-z0-9._-]*$` makes the hook inert for that call.
- Orchestrators, the main session, `csharp-typed-engineer`, and `typescript-engineer` are never held in acknowledgement mode.

### Decision grammar

One line per directive, in a decision file or as a line in the worker's final message:

```text
OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at> | <reason>
```

Parsed by `ConvertFrom-OwnerDirectiveDecisionLine` with the anchored pattern `^OWNER-DIRECTIVE-DECISION: (OD-[1-9][0-9]*) \| ([a-z_]+) \| (honored|refused) \| (\S+) \| (.+)$`. `<decided_at>` is an ISO 8601 UTC date-time or `-` (the orchestrator then supplies its own clock reading). `<reason>` is the rest of the line, may contain `|`, and must be at least 20 characters after trimming (R8). `Test-OwnerDirectiveDecision` rejects: an unparseable line; a class that differs from the directive's class (R4); `honored` for a refused class (R6 at write time); `honored` with `decided_at` later than `expires_at` (R10); `decided_at` later than `Now`; a reason shorter than 20 characters after trimming.

### Orchestrator write on return

After a worker returns, the orchestrator (1) copies into `owner_directives` any selected entry it lacks, (2) reads the worker's decision files and its `OWNER-DIRECTIVE-DECISION:` return lines, with a decision file taking precedence over a return line for the same id, and (3) appends one `owner_directive_records` entry per decision: `directive_id`, `class`, `outcome`, `reason`, `decided_by` = the worker's agent type, `decided_at` = the recorded value or the orchestrator's clock reading for `-`, and optionally `agent_id` and `decision_source` (`decision_file` or `return_line`). The existing stop hook then applies R1-R10 unchanged.

### Ledger write guard

For a `Write`, `Edit`, `MultiEdit`, or `NotebookEdit` whose target path ends with `artifacts/orchestration/owner-directives.jsonl`, the hook denies with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_LEDGER_WRITE_DENIED:` when the caller is a subagent (payload `agent_type` present), when the tool is not `Write`, when the new content does not keep every existing line as an unchanged prefix, or when any new line fails B2-B8. A main-session `Write` that appends valid lines emits nothing.

### Stop-hook running-child check

`.claude/hooks/validate-orchestrator-output.ps1` (`Get-OrchestratorOutputBlockDecision`) calls the new sibling `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` after the existing owner-directive call. The check blocks with `OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: <details>` and `Repairable = $true`.

- Activation: the checkpoint under validation (or, for an item checkpoint, its linked parent) has `owner_directives`, or the relevant worktree has a non-empty ledger. Otherwise the check does not run.
- Epic parent (`features[]`): running children are those with `merge_status` in `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`. Not checked: `not_started`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed`.
- Parallel parent (`items[]`): running children are those with `merge_status` in `worktree_created`, `pr_open`, `ci_green`. Not checked: `not_started`, `merged`, `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit`.
- For each running child and each parent entry selected for it at `Now`, the child is compliant when its checkpoint `owner_directives` holds the same `id` and `text_sha256`, or when the child worktree resolves by issue and its checkpoint links back to this parent (`epic_context.integration_branch` equal to the parent's `integration_branch`, or `parallel_slug` equal to the parent's). Otherwise the child is reported. An id conflict between parent and child is reported.
- Item stop (`orchestrator-state`): the item checkpoint must hold every entry selected for it from its own ledger and, through its link, from the parent checkpoint and parent ledger.
- Ledger lines failing B2-B8 are reported as `OWNER_DIRECTIVE_LEDGER_INVALID` by this check (not by the worker hook).
- The check takes one clock reading per hook run through a seam function in the sibling and passes it as `-Now`.
- Rules B1-B8 and R1-R10, including R3 (record without matching directive) and R6 (honored record for a refused class), stay blocking with their #1139 error strings unchanged.

### Relay independence

Pass-down happens at hook level: the worker hook reads the parent checkpoint and parent ledger itself, so delivery does not depend on the epic orchestrator or the item orchestrator being active. No no-end-turn rule is added to any orchestrator surface.

## Inputs / Outputs

- Inputs: Claude PreToolUse payload (`tool_name`, `tool_input`, `cwd`, `transcript_path`, `agent_id`, `agent_type`); the four directive sources; decision files; `git worktree list --porcelain` output through the existing worktree-resolution modules.
- Outputs: PreToolUse deny JSON at exit 0 (nothing on allow); stop-hook block decisions; no file written by either hook.
- Config keys and defaults: none added. The registration element in `.claude/settings.json` is the only configuration change.
- Backward compatibility: a repository, run, or checkpoint with no ledger and no `owner_directives` in any source behaves exactly as today in both hooks. Optional record fields `agent_id` and `decision_source` are tolerated by `Get-OrchestratorStateOwnerDirectiveError`.

## API / Module Surface

- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`: gains one exported pure function, `Get-OrchestratorStateOwnerDirectiveValidEntry`, that accepts either JSON array text or ledger text (one object per line) and returns the entries that pass B2-B8 together with the per-line errors for the rest. `Get-OrchestratorStateOwnerDirectiveError` is unchanged.
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1` (pure; no clock, file, or process): `Select-OwnerDirectivePassDown -Source -ItemIssue -ItemBranch -ItemStep -ParentIssue -ParentBranch -Now` returning entries with `Id`, `Class`, `Text`, `TextSha256`, `ExpiresAt` (recorded string, unmodified), `Scope`, `Source` (`item-checkpoint`, `item-ledger`, `parent-checkpoint`, `parent-ledger`), `IsRefusedClass`, plus conflicts; `Format-OwnerDirectiveBlock -Selected`; `Test-OwnerDirectivePromptCoverage`; checkpoint coverage and running-child coverage functions (named by the plan).
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1` (pure; no clock, file, or process): `ConvertFrom-OwnerDirectiveDecisionLine`; `Test-OwnerDirectiveDecision`; decision-path, pending-set, and ledger append-only check functions (named by the plan).
- Rendered block format (`Format-OwnerDirectiveBlock`), identical to `## Relay Format` in the owner-directives skill: header `Owner directives:`, a `text` fence, the framing line `Task direction recorded by the coordinator; not approval, not permission.`, then per entry `<id> | <class> | scope <issue> <branch> <step> | expires <expires_at>` and `"<text>"`. Entries are ordered by the numeric part of `id` (`OD-2` before `OD-10`); `expires` echoes the recorded `expires_at` string; CRLF in `text` is normalized to LF. `Test-OwnerDirectivePromptCoverage` checks that the header line and the quoted text line of each selected entry occur in the prompt after the same CRLF normalization.

## Acceptance Criteria

Each criterion names the rule, parameter, or boundary it verifies. Tests named here are the files listed under Implementation Strategy.

### Selection, scope, and rendering (issue AC 1, AC 6)

- [x] AC-1: `Select-OwnerDirectivePassDown` selects an entry on item match only when `scope.issue` equals the item issue and, when the item branch is non-null, `scope.branch` equals it ordinally; a Pester test in `OrchestratorStateOwnerDirectiveSelection.Tests.ps1` shows a branch differing only in letter case is not selected, and a null item branch skips the branch comparison.
- [x] AC-2: Epic fan-out selects a parent-source entry when `scope.issue == epic_issue_num` and `scope.branch == integration_branch`; a test shows the same entry is not selected when either value differs, and is not selected through fan-out when its source is not an epic parent source.
- [x] AC-3: Step match accepts `scope.step` `any`, an exact `next_step`, and the prefix `<step>_` (`S5` matches `S5_atomic_execution`); a test shows `scope.step` `S5` does not match `next_step` `S51` or `S5x`, because the prefix rule requires the `_` separator.
- [x] AC-4: Expiry boundary: an entry with `expires_at` one second after `Now` is selected, and entries with `expires_at` equal to `Now` or earlier than `Now` are not selected (strict `expires_at > Now`).
- [x] AC-5: An entry failing any of B2-B8 is not selected; the selection module obtains validity only from `Get-OrchestratorStateOwnerDirectiveValidEntry`, which `OrchestratorStateOwnerDirectives.Entry.Tests.ps1` tests for one violating entry per B rule, for valid JSON-array input, and for ledger-text input with one malformed line.
- [x] AC-6: Refused classes are selected with `IsRefusedClass = $true`; a test covers each of `gate_bypass`, `force_push`, `tag_or_publish`, `policy_or_settings_edit`, `evidence_alteration`, and `unclassified`, and shows each honorable class is selected with `IsRefusedClass = $false`.
- [x] AC-7: Id conflict rule: identical `id` and `text_sha256` across sources yields one selected entry; the same `id` with a different `text_sha256` keeps the item-local entry and returns the conflict.
- [x] AC-8: `Format-OwnerDirectiveBlock` output matches the `## Relay Format` example of the owner-directives skill byte for byte for the same entry, orders `OD-2` before `OD-10`, echoes the recorded `expires_at` string unmodified, and normalizes CRLF in `text` to LF; `Test-OwnerDirectivePromptCoverage` returns false when either the header line or the quoted text line of any selected entry is absent from the prompt.
- [x] AC-9: `OrchestratorStateOwnerDirectiveSelection.psm1` and `OrchestratorStateOwnerDirectiveDecision.psm1` read no clock, no file, and start no process: a contract assertion in their test suites shows neither module text references `Get-Date`, `[DateTime]::Now`, `[DateTime]::UtcNow`, `Get-Content`, `Test-Path`, `Start-Process`, or `& git`, and every time-dependent function takes `-Now`.

### Relay mode (issue AC 1, AC 4)

- [x] AC-10: For an `Agent` or `Task` call whose `subagent_type` is in the relay target set, `enforce-owner-directive-pass-down.ps1` denies with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_RELAY_REQUIRED:` when a selected entry is missing from the item checkpoint `owner_directives` (matched on `id` and `text_sha256`), and when the entry is present in the checkpoint but its rendered lines are missing from the prompt; the deny reason contains the rendered block and the JSON entry to append. Tests cover each target in the relay set.
- [x] AC-11: Relay mode applies at every delegation phase: hook tests run a delegation with item `next_step` values from preparation (S2, S3, S4 including preflight), execution (S5), remediation, and review (S7 and R4), each denied when the selected entry is missing and allowed (no output) when the checkpoint holds the entry and the prompt holds its rendered lines.
- [x] AC-12: For a child `orchestrator` launch by an epic or parallel coordinator, only the prompt check applies, against the caller's parent sources filtered by the prompt's canonical issue line; a test shows the launch is denied when the rendered lines are absent from the prompt and allowed when present, without any child checkpoint.
- [x] AC-13: A delegation whose `subagent_type` is outside the relay target set produces no output; the test case uses `subagent_type` `pr-author`.

### Acknowledgement mode and decision records (issue AC 2, AC 3)

- [x] AC-14: For each agent type in the acknowledgement set, a matched tool call with a pending entry is denied with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_DECISION_REQUIRED:`; the reason contains the rendered block, the always-refused note for each flagged entry, the absolute decision-file path for each pending id, the decision-line grammar, and the injected clock value.
- [x] AC-15: The same agent produces no output once every selected entry has a decision file under its `agent_id`; a test then adds an entry to the item ledger and shows the next matched call is denied again for the new id only.
- [x] AC-16: `ConvertFrom-OwnerDirectiveDecisionLine` parses lines matching the anchored grammar pattern, accepts `-` as `decided_at`, keeps `|` characters inside the reason, and rejects lines with a missing field, an id not matching `OD-[1-9][0-9]*`, an outcome other than `honored` or `refused`, or leading or trailing text outside the pattern.
- [x] AC-17: `Test-OwnerDirectiveDecision` rejects, with a distinct message per rule: class not equal to the directive class (R4); `honored` for each refused class (R6 at write time); `honored` with `decided_at` later than `expires_at` (R10); `decided_at` later than `Now`; a reason of 19 characters after trimming (R8). It accepts a `refused` decision for each refused class and a reason of exactly 20 characters after trimming.
- [x] AC-18: A `Write` by the calling `agent_id` of the decision file of a pending id with one valid line produces no output; the same `Write` with an invalid line is denied with `OWNER_DIRECTIVE_DECISION_INVALID:`.
- [x] AC-19: Decision files are write-once: a `Write` to an existing decision file, an `Edit` of a decision file, and a `Write` of a decision file under a different `agent_id` are each denied with `OWNER_DIRECTIVE_DECISION_INVALID:`.
- [x] AC-20: The hook is inert (no output) when `agent_id` does not match `^[A-Za-z0-9][A-Za-z0-9._-]*$`, and never holds the main session (no `agent_type`), `orchestrator`, `csharp-typed-engineer`, or `typescript-engineer` in acknowledgement mode.
- [x] AC-21: `Get-OrchestratorStateOwnerDirectiveError` returns no errors for a valid record carrying the optional fields `agent_id` and `decision_source`, and R3 and R6 still fire on records carrying them.
- [x] AC-22: The orchestrate skill states the write-on-return procedure (copy missing selected entries first; decision file takes precedence over a return line for the same id; one `owner_directive_records` entry per decision with `decided_by` set to the worker agent type; `decided_at` from the orchestrator's clock for `-`), asserted by `owner-directives-skill-contract.Tests.ps1`.

### Resolution and inert default (issue AC 3, AC 4)

- [x] AC-23: `owner-directive-pass-down-target.ps1` resolves the item root from payload `cwd` when the enclosing registered worktree holds `artifacts/orchestration/orchestrator-state.json`; otherwise from the delegation prompt in the subagent transcript, using `transcript_path` directly when its file name is `agent-<agent_id>.jsonl` and otherwise deriving the subagent transcript path from it; otherwise it returns no root and the hook emits nothing. `owner-directive-pass-down-target.Tests.ps1` covers each branch through injected seams.
- [x] AC-24: Parent resolution uses `Resolve-WorktreeEpicTarget` when the item checkpoint records `epic_context.integration_branch` and `Resolve-WorktreeParallelTarget` when it records `parallel_slug`; a test shows a parent-ledger entry reaches a worker held in acknowledgement mode with no change to the item checkpoint (hook-level pass-down independent of any orchestrator).
- [x] AC-25: Inert default: with no ledger and no `owner_directives` in the item checkpoint, item ledger, parent checkpoint, or parent ledger, the hook emits nothing for every matched tool and caller in a test matrix covering relay mode, acknowledgement mode, and ledger paths, and `validate-orchestrator-output.ps1` returns the same decision as before this change for epic, parallel, and item checkpoints without either key. No configuration knob is added.
- [x] AC-26: No orchestrator surface gains a no-end-turn rule: `owner-directives-skill-contract.Tests.ps1` asserts the epic-orchestrate skill states hook-level pass-down and contains no instruction to keep the epic orchestrator's turn open while relay is pending.

### Ledger (issue AC 3, AC 4)

- [x] AC-27: The ledger guard denies with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_LEDGER_WRITE_DENIED:` a ledger write by any subagent, any `Edit`, `MultiEdit`, or `NotebookEdit` of a ledger, a main-session `Write` that changes or removes an existing line, and a main-session `Write` whose appended line fails B2-B8; a main-session `Write` appending valid lines produces no output.
- [x] AC-28: A test pins that `Test-ImplementationPath` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` does not classify `artifacts/orchestration/owner-directives.jsonl` or a decision-file path as an implementation path.

### Stop-hook validator (issue AC 5)

- [ ] AC-29: R3 and R6 are unchanged: the existing suites `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1`, and `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` pass without edits, and a record without a matching directive or an `honored` record for a refused class still blocks with `OWNER_DIRECTIVE_BLOCKED:` and the #1139 strings.
- [x] AC-30: For an epic checkpoint, `validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1` shows a child with `merge_status` in each of `worktree_created`, `pr_open`, `ci_green`, `merge_conflict` that lacks a selected parent entry and does not link back is reported with `OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING:` and `Repairable = $true`, and a child in each of `not_started`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed` is not checked.
- [x] AC-31: For a parallel checkpoint, a child with `merge_status` in each of `worktree_created`, `pr_open`, `ci_green` is checked as in AC-30, and a child in each of `not_started`, `merged`, `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit` is not checked.
- [x] AC-32: A running child is compliant when its checkpoint holds the same `id` and `text_sha256`, or when it resolves by issue and its checkpoint links back (`epic_context.integration_branch` or `parallel_slug` equal to the parent's); an unresolvable child, an unreadable child checkpoint, and a child that does not link back are reported when they lack the entry; an id conflict between parent and child is reported; an expired parent entry (`expires_at` not greater than the injected `Now`) is not required.
- [x] AC-33: At item stop, an item checkpoint missing an entry selected for it from its own ledger, the parent checkpoint, or the parent ledger is blocked with `OWNER_DIRECTIVE_RELAY_MISSING`; a ledger line failing B2-B8 is reported as `OWNER_DIRECTIVE_LEDGER_INVALID` by the stop-hook check and does not cause the worker hook to deny.
- [x] AC-34: The check is key-gated (runs only when `owner_directives` is present in the checkpoint or its linked parent, or the relevant worktree has a non-empty ledger) and takes one clock reading per run through the sibling's seam; tests pass a fixed clock value.
- [x] AC-35: `validate-orchestrator-output.ps1` imports the new sibling and modules with the guarded fail-closed pattern; `hook-import-failure-exemptions.FailClosed.Tests.ps1` gains a case for the new import, and `hook-dependency-guard-completeness.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1` pass.

### Registration and packaging

- [x] AC-36: `.claude/settings.json` gains one new standalone `hooks.PreToolUse[]` element with matcher `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*` and the single command `pwsh -NoProfile -File .claude/hooks/enforce-owner-directive-pass-down.ps1`; no existing element is modified. `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` receives the same edit, asserted by `owner-directive-pass-down.Registration.Tests.ps1`.
- [x] AC-37: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/enforce-owner-directive-pass-down.ps1`, `.claude/hooks/owner-directive-pass-down-target.ps1`, `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`, `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1`, and `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1`; `test_push_down_pack_manifest_dependency_closure.py` and `OrchestratorState.Manifest.Tests.ps1` pass.
- [x] AC-38: Each new and edited `.claude` PowerShell file has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/`, and the push-down contract tests pass.
- [x] AC-39: `hook-dependency-failure.Claude.Tests.ps1` lists the reason prefix `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:` and `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` lists the new hook as an exempt hook with the stated reason.

### Documentation and mirror parity (issue AC 6)

- [x] AC-40: `.claude/skills/owner-directives/SKILL.md` documents the ledger, id allocation, the `any` step value, epic fan-out scope, the `OWNER-DIRECTIVE-DECISION:` grammar, decision files, orchestrator write-on-return, the Claude-only hook paragraph naming `enforce-owner-directive-pass-down.ps1`, and the known limitations of this spec; its copies `.agents/skills/owner-directives/SKILL.md`, `.github/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/owner-directives/SKILL.md` are byte-identical, asserted by `owner-directives-skill-contract.Tests.ps1`, which also asserts the ledger path, the grammar token, and the hook name.
- [x] AC-41: `.claude/skills/orchestrate/SKILL.md` (subsection under `## Delegation Model`), `.claude/skills/epic-orchestrate/SKILL.md` (`## Context Handoff to Dependent Features`), and `.claude/skills/parallel-orchestrate/SKILL.md` (the pass-through text "in a later course-correction message" replaced by ledger plus hook-level pass-down with per-item scope) are updated, each with its bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/` byte-identical.
- [x] AC-42: Each of `.claude/agents/atomic-executor.md`, `.claude/agents/atomic-planner.md`, `.claude/agents/feature-review.md`, `.claude/agents/task-researcher.md`, `.claude/agents/prd-feature.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`, and `.claude/agents/typescript-engineer.md` lists `owner-directives` in `skills:` and carries one pointer sentence (decision file for the acknowledgement-set agents; return lines only for `csharp-typed-engineer` and `typescript-engineer`), with byte-identical bundle copies; `owner-directives-skill-contract.Tests.ps1` lists each in `$script:PointerFile`, and `test_claude_rules_frontmatter.py` passes.
- [x] AC-43: `.claude/agents/epic-orchestrator.md`, `.claude/agents/orchestrator.md`, and `.claude/agents/parallel-orchestrator.md` are unchanged in the branch diff.
- [x] AC-44: `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` document the ledger, the `OWNER_DIRECTIVE_RELAY_MISSING` and `OWNER_DIRECTIVE_LEDGER_INVALID` checks, the amended clock statement (the B/R check reads no clock; the pass-down coverage check reads one clock value through a seam), and a new enforcement bullet for the PreToolUse hook; the rule file and its bundle copy are byte-identical.
- [x] AC-45: `.claude/skills/execution-environment/SKILL.md` gains one `## Hook Execution Context` bullet naming the new PreToolUse hook and the stop-hook check, and its copies `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` stay byte-identical; `test_execution_environment_brief_contracts.py` passes.
- [x] AC-46: In `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, only the `.claude/skills/epic-orchestrate/SKILL.md` digest in `PINNED_FROZEN_SURFACE_HASHES` changes, recomputed as the SHA-256 of the file bytes after the final `origin/main` merge into the branch, and the comment block gains a `RE-BASELINED by issue #1157` paragraph stating that only the skill digest moved; the agent digest is unchanged and the frozen-surface test passes.

### Quality gates

- [x] AC-47: Each new PowerShell file reaches at least 90% line coverage (new-code rule) and the repository line threshold of 85% holds, measured by one `Invoke-PoshQCParallelTest` run and recorded under `docs/features/active/owner-directive-pass-down-1157/evidence/coverage/`; `Invoke-PoshQCLeakScan` reports no leaked global functions or environment variables from the new suites.
- [x] AC-48: The branch diff adds no `.py` file, and the only `.py` change is the digest and comment edit of AC-46; no Codex or Copilot hook file and no Python or TypeScript validator file is changed.

## Constraints

- **PowerShell only for pushed-down code.** No new Python. The only Python edit extends existing data in place in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. No TypeScript.
- **Separation of pure logic and I/O.** Scope, selection, rendering, coverage, grammar, decision validation, pending set, and ledger prefix checks live in host-neutral modules with no clock, file, or process access. Transcript, checkpoint, ledger, decision-file, worktree-list, and clock reads go through injectable seams in `.claude/hooks/owner-directive-pass-down-target.ps1` and `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`.
- **Tests.** No temporary files and no wall-clock waits; in-memory content and a fixed clock. Hook suites run on Linux in CI: use `Join-Path`, forward-slash relative forms, ordinal comparisons, no drive letters, and `/`-rooted fixture roots.
- **Parallel-only test gates.** One `Invoke-PoshQCParallelTest` run for Pester and one `pytest -n auto` run for the Python contract tests; no serial, single-process, shuffled, or reversed runs.
- **Evidence append-only.** Evidence under `docs/features/active/owner-directive-pass-down-1157/evidence/` is appended, never back-dated, rewritten, or deleted, and stamped from clock reads.
- **Defaults equal today's behavior.** No configuration knob is added; with no directive source present, both hooks behave as today.
- **Push-down payload parity.** Every edited or new `.claude` file listed in this spec has a byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/`.
- **File size.** `.claude/hooks/validate-orchestrator-output.ps1` (430 lines) gains only an import and a call; each new file is planned under 500 lines.
- **Shared file with sibling #1159.** `.claude/settings.json` and its bundle copy are shared with sibling #1159 (single hook dispatcher), which starts after this item merges. This item adds a normal standalone `hooks.PreToolUse[]` element and does not anticipate the dispatcher. `hook-dependency-failure.Claude.Tests.ps1` and `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` are also likely shared with #1159.
- **Rules path.** The only `.claude/rules/` file written is `.claude/rules/orchestrator-state.md` (with its bundle copy). Canonical policy files under `.github/instructions/` and `.github/copilot-instructions.md` are not edited.
- **No gate weakened.** No existing hook changes its decision for any input without a directive source; no hook gains a directive-based allow path.

## Known Limitations

- **No Codex or Copilot twin.** Neither the PreToolUse hook nor the running-child check exists for Codex or Copilot. Those runtimes receive the runtime-neutral procedure through the byte-identical owner-directives skill only. This extends the existing Codex enforcement gap.
- **Python and TypeScript validators unchanged.** `scripts/dev_tools/validate_orchestrator_state.py` and the TypeScript orchestrator-state validator do not validate the ledger, the new optional record fields, or the running-child check. This extends the existing parity gap.
- **`csharp-typed-engineer` and `typescript-engineer` record decisions in return lines only.** Their tool lists have no `Write`, so they cannot write decision files and are not held in acknowledgement mode. They receive directives through relay mode (the prompt check) and their docs state the limitation.
- **Branch hooks are not exercised by isolated subagents until merge.** Hooks fired for subagents run the scripts from `main`. Acceptance rests on Pester suites; until merge, the return-line channel is the record path. No acceptance criterion depends on a live run of the branch hook.
- **UNVERIFIED: `transcript_path` content in a subagent PreToolUse payload.** It is not confirmed whether the field carries the root session transcript or the subagent's own transcript. The design tolerates both: the hook uses `transcript_path` directly when its file name is `agent-<agent_id>.jsonl` and otherwise derives the subagent transcript path from the root path using the layout fixed by `extensions/drm-copilot/src/lib/subagent-tree/transcript-scanner.ts`. When neither yields a readable delegation prompt, the hook stays inert, and `cwd` resolution still covers non-isolated workers (the normal executor shape). The orchestrator confirms the fact with a non-isolated check.
- **UNVERIFIED: isolated-worktree `Write` to another worktree.** It is not confirmed that the runtime admits a `Write` from an isolated worktree to an absolute path in another worktree. In the normal non-isolated case the decision file is inside the agent's own working tree. If the write is not admitted, the isolated worker records its decisions in return lines, which the orchestrator writes on return (D10); the hook would continue to hold it, which is the documented cost of isolation. The orchestrator confirms the fact with a non-isolated check.
- **Same-session forgery and policy-only conditions** from #1139 remain; the ledger is a policy-level control, not a security control.
- **Per-call cost.** One extra `pwsh` process per matched tool call, plus a `git worktree list` when resolution is needed; the no-source fast path exits early. Sibling #1159's dispatcher is expected to reduce this later.
- **Frozen-surface digest.** A sibling that also edits `.claude/skills/epic-orchestrate/SKILL.md` conflicts on `PINNED_FROZEN_SURFACE_HASHES`; the second to merge recomputes.

## Implementation Strategy

Route: large path (more production PowerShell files than the direct-mode budget).

Production, new (each with a byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/`):

- `.claude/hooks/enforce-owner-directive-pass-down.ps1`
- `.claude/hooks/owner-directive-pass-down-target.ps1`
- `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1`
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1`
- Bundle: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-owner-directive-pass-down.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/owner-directive-pass-down-target.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1`

Production, edited:

- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`
- `.claude/hooks/validate-orchestrator-output.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`
- `.claude/settings.json` and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

Documentation, edited:

- `.claude/skills/owner-directives/SKILL.md`, `.agents/skills/owner-directives/SKILL.md`, `.github/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/owner-directives/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/epic-orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/rules/orchestrator-state.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `.claude/agents/atomic-executor.md`, `.claude/agents/atomic-planner.md`, `.claude/agents/feature-review.md`, `.claude/agents/task-researcher.md`, `.claude/agents/prd-feature.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/agents/typescript-engineer.md`, and `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/typescript-engineer.md`

Tests, new:

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Entry.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1`
- `tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1`
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`
- `tests/scripts/claude-runtime/owner-directive-pass-down.Registration.Tests.ps1`

Tests, edited:

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (append the new modules to `$script:ExpectedPaths`)
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`
- `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (digest and comment only)

Dependencies: none added. Logging: deny reasons and stop-hook block reasons are the only output. Rollout: no flag; the behavior activates only when a directive source exists.

## Definition of Done

- [x] Every acceptance criterion above is mapped to a named test or contract assertion in the plan.
- [ ] Toolchain loop passes in a single pass (format, lint, type check where applicable, architecture, one parallel unit-test run, contract checks, integration).
- [x] Mirror and bundle parity verified by the push-down contract tests.
- [x] Evidence recorded append-only under `docs/features/active/owner-directive-pass-down-1157/evidence/`.
- [ ] CI green on the PR head after the final `origin/main` merge and digest recompute.
