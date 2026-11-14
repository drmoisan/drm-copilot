# Research: Owner Directives Must Reach Every Executing Agent (Issue #1157)

- Issue: #1157
- Branch: feature/owner-directive-pass-down-1157
- Authoritative scope: `docs/features/active/owner-directive-pass-down-1157/issue.md` (six acceptance criteria). `spec.md` and `plan.2026-11-09T16-32.md` in the same folder are unfilled templates.
- Environment facts (tool routes, hook execution context, command-text restrictions, CI shape, contract tests) are cited from `.claude/skills/execution-environment/SKILL.md` and are not restated.
- Tool limits: this researcher has Read, Grep, Glob, WebFetch, and Write only. Facts that need `git`, `gh`, or a live run are marked `UNVERIFIED (orchestrator to confirm)`.

## Prior Art (issue #1139, verified by reading the files)

- `.claude/skills/owner-directives/SKILL.md`: checkpoint schemas for `owner_directives[]` and `owner_directive_records[]`, the closed class set (five honorable, six always-refused), the coordinator "record before relay" procedure, the fenced `Owner directives:` relay format, the epic/parallel pass-through rule, and the receiving agent's recording duty. Six byte-identical copies, pinned by `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1`.
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`: one exported pure function, `Get-OrchestratorStateOwnerDirectiveError -CheckpointText`, applying B1-B8 and R1-R10 through `System.Text.Json`. Private helpers (`ConvertFrom-OwnerDirectiveDateText`, `Get-OwnerDirectiveTextDigest`, `Get-OwnerDirectiveEntryError`, scope check `Test-OwnerDirectiveScope`) are not exported. It reads no clock.
- `.claude/hooks/validate-orchestrator-output.ps1`, function `Get-OrchestratorOutputBlockDecision`: calls the module for every artifact type when the checkpoint has either key (`Test-OrchestratorOutputOwnerDirectiveKey`) and blocks with `OWNER_DIRECTIVE_BLOCKED:`.
- `.claude/rules/orchestrator-state.md`, `## Owner-Directive Scope and Backward Compatibility`: rule table B1-R10, "the check reads no clock", Python/TypeScript parity gap, Codex enforcement gap.
- Relay today is prose only: `.claude/skills/orchestrate/SKILL.md` (`## Delegation Model`), `.claude/agents/orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md` (`## Context Handoff to Dependent Features`, last paragraph), and `.claude/skills/parallel-orchestrate/SKILL.md` (pass-through "in a later course-correction message"). Nothing mechanical moves a directive from a parent checkpoint to a child or to a worker, which is the failure the issue reports.

## 1. Parent-to-Child Pass-Down

### Parent checkpoints and child identity (verified)

| Parent | Checkpoint (in the parent's worktree) | Child list | Child identity | Child-side link back to the parent |
|---|---|---|---|---|
| Epic | `artifacts/orchestration/epic-orchestrator-state.json` | `features[]` | `issue_num`, `feature_folder` | Child records `epic_context.integration_branch` at its first write (`.claude/skills/epic-orchestrate/SKILL.md`, `## Merge-on-Green Kickoff Parameter`) |
| Parallel | `artifacts/orchestration/parallel-orchestrator-state.json` | `items[]` | `issue_num` | Child records `parallel_mode: true` and `parallel_slug` at kickoff (`.claude/rules/orchestrator-state.md`, `## Green-CI standalone merge (issue #997)`) |
| Item | `artifacts/orchestration/orchestrator-state.json` | workers | `issue-num`, `next_step` | n/a |

Parent worktrees are already resolvable from the child side: `Resolve-WorktreeEpicTarget` (integration branch) and `Resolve-WorktreeParallelTarget` (parallel slug) in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`. Child worktrees are resolvable from the parent side by issue through `Resolve-HookTargetWorktree` with a synthesized canonical issue line and `Get-WorktreeItemCheckpointIssue` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`) as `CheckpointIssueReader`.

The epic checkpoint carries `epic_issue_num` (`.claude/agents/epic-orchestrator.md`, `## Checkpoint Persistence`). The parallel checkpoint has no run-level issue (`REQUIRED_KEYS` in `scripts/dev_tools/validate_parallel_orchestrator_state.py`).

### Scope mapping

A directive entry's `scope` is `{ issue, branch, step }` (rule B8). Proposed mapping for a child item with issue `I`, branch `Bc` (from the `git worktree list --porcelain` record of the item root, `$null` when detached or unknown), and current step `St` (the item checkpoint `next_step`):

- Item match: `scope.issue == I`, and `scope.branch == Bc` when `Bc` is known (ordinal).
- Epic fan-out match: the entry comes from the epic parent, `scope.issue == epic_issue_num`, and `scope.branch == integration_branch`. This is how one recorded entry reaches every running child of an epic. Parallel parents have no run issue, so a coordinator records one entry per item.
- Step match: `scope.step` is the reserved value `any`, or `St` equals `scope.step`, or `St` starts with `scope.step` followed by `_` (so `S5` matches `S5_atomic_execution`). `any` is additive: B8 already accepts any non-empty step string.

### Pure selection function (recommended contract)

`Select-OwnerDirectivePassDown -Source <entry sets> -ItemIssue -ItemBranch -ItemStep -ParentIssue -ParentBranch -Now` returns the selected entries, each with `Id`, `Class`, `Text`, `TextSha256`, `ExpiresAt` (the recorded string, unmodified), `Scope`, `Source` (`item-checkpoint`, `item-ledger`, `parent-checkpoint`, `parent-ledger`), and `IsRefusedClass`.

- An entry that fails any B2-B8 rule is not selected (validity comes from a new exported per-entry function in `OrchestratorStateOwnerDirectives.psm1`, so the B rules are not reimplemented).
- Unexpired means `expires_at > Now` (strict); expired entries are never selected.
- Refused classes are selected and flagged, not dropped: the agent is told the class is always refused and must record `refused`.
- Duplicate `id`: identical `id` and `text_sha256` are one entry; the same `id` with a different hash is a conflict, the item-local entry is kept, and the conflict is returned for the stop-hook check to report. The coordinator procedure gains an id-allocation rule: ids are unique across a parent checkpoint, its ledger, and every child checkpoint and ledger.
- `Now` is a parameter; the function reads no clock.

### Where the copy into the child checkpoint happens

The item orchestrator owns its checkpoint. Before it builds any worker delegation prompt (preparation S2-S4 including preflight, execution S5, remediation R1-R3, review S7/R4), it re-reads its directive sources (its own ledger and, through `epic_context`/`parallel_slug`, the parent checkpoint and parent ledger), appends every selected entry that its checkpoint lacks to `owner_directives` verbatim, writes the checkpoint, and pastes the rendered block into the prompt. This is enforced mechanically by the relay mode of the new PreToolUse hook (Section 3, D6): an `Agent` delegation whose target is a worker or `orchestrator` is denied with `OWNER_DIRECTIVE_RELAY_REQUIRED:` when a selected entry is missing from the item checkpoint or its rendered lines are missing from the prompt. The deny reason carries the exact block and the JSON entries to add, so the orchestrator never composes them. For an epic or parallel coordinator launching a child `orchestrator`, the child worktree does not yet exist; only the prompt check applies, and the child records the entries at its first checkpoint write (checked by its own stop hook, Section 5).

### Verbatim block rendering

`Format-OwnerDirectiveBlock -Selected` produces exactly the format of `## Relay Format` in the owner-directives skill:

````text
Owner directives:
```text
Task direction recorded by the coordinator; not approval, not permission.
OD-1 | extra_planner_revision | scope 1139 feature/owner-directive-relay S5 | expires 2026-11-09T14:05:00Z
"<verbatim owner text>"
```
````

Rules: entries ordered by numeric id; `expires` echoes the recorded `expires_at` string; the quoted line is `"` + `text` + `"` with CRLF normalized to LF. Prompt coverage (`Test-OwnerDirectivePromptCoverage`) checks that the header line and the quoted text of each selected entry occur in the prompt after the same CRLF normalization.

## 2. Worker Decision Record

### Return-line grammar (recommended)

One line per directive in the block the worker received, in the worker's final message:

```text
OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at> | <reason>
```

- `<id>` matches `OD-[1-9][0-9]*`; `<class>` repeats the directive's class (R4); `<outcome>` is `honored` or `refused` (R5).
- `<decided_at>` is an ISO 8601 UTC date-time, or `-` when the agent has no clock reading; with `-` the orchestrator supplies its own clock reading.
- `<reason>` is the rest of the line, at least 20 characters after trimming (R8); it may contain `|`.
- Parser: `ConvertFrom-OwnerDirectiveDecisionLine` (pure) with the anchored pattern `^OWNER-DIRECTIVE-DECISION: (OD-[1-9][0-9]*) \| ([a-z_]+) \| (honored|refused) \| (\S+) \| (.+)$`.
- A worker refuses, with a reason, a directive that is outside its role, in a refused class, or expired; it honors at most once an `extra_planner_revision` (R7).

### Decision file (hook channel, same grammar)

`artifacts/orchestration/owner-directive-decisions/<agent_id>/<id>.md` beneath the item root, holding exactly one decision line. The file is write-once. `.md` under `artifacts/orchestration/` is not an implementation path for the preimplementation gate (`Test-ImplementationPath` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` matches only code and `json`/`yml` extensions), is a permitted `artifacts/` sub-path for `.claude/hooks/enforce-evidence-locations.ps1`, and never counts against the batch budget.

### Orchestrator write on return

After a worker returns, the orchestrator:

1. Copies into `owner_directives` any selected entry it lacks (a directive can arrive through a ledger while the worker runs).
2. Reads the worker's decision files and return lines. A decision file takes precedence over a return line for the same id (the file was validated by the hook); a return line covers workers without hook coverage and runs before the hook merges to `main` (hooks for subagents run `main`'s scripts, execution-environment brief, `## Hook Execution Context`).
3. Appends one `owner_directive_records` entry per decision: `directive_id`, `class`, `outcome`, `reason`, `decided_by` = the worker's agent type, `decided_at` = the recorded value or its clock reading for `-`; optional tolerated `agent_id` and `decision_source` (`decision_file` or `return_line`). The module reads only the listed record fields, so the extras are tolerated.
4. The existing stop hook then applies R1-R10 unchanged.

## 3. PreToolUse Injection Hook

### Injection mechanism (verified)

- `permissionDecision: "deny"` with `permissionDecisionReason`: the Claude Code hooks reference (`code.claude.com/docs/en/hooks`, PreToolUse decision control) states the deny reason is "shown to Claude" and the tool call is blocked. Every Claude PreToolUse gate in `.claude/hooks/` uses this shape (for example `Get-DocsWriteScopeDenyDecision` in `.claude/hooks/enforce-docs-role-write-scope.ps1`), emitted as JSON at exit 0 (`.claude/lib/hook-payload/HookPayload.psm1` header).
- `additionalContext` under PreToolUse `hookSpecificOutput`: the same reference lists it as "String added to Claude's context alongside the tool result", ignored for `defer`. The text arrives with the result, after the tool has run, so a non-compliant command would already have executed. No Claude PreToolUse hook in this repository emits it; the Claude-side occurrence is a SubagentStart output in `.claude/lib/discovery-validation/DiscoveryStart.psm1`, and the PreToolUse occurrences are Codex hooks (`.codex/hooks/record-subagent-routing-attestation.ps1`, `.codex/hooks/discovery-start-attestation.ps1`).
- Do not emit `permissionDecision: "allow"`: the reference states it skips the permission prompt. The hook emits nothing on allow, as `enforce-docs-role-write-scope.ps1` does.

Recommendation: deny with the directive block as the reason. The deny is the injection and the hold.

### Caller identity (verified)

The hooks reference states that settings hooks fire for subagent tool calls and that the input carries `agent_id` and `agent_type` for a subagent. `enforce-docs-role-write-scope.ps1` (`Invoke-DocsRoleWriteScopeDecision`) and `enforce-epic-invocation-origin.ps1` read `agent_type` from the envelope root; an absent `agent_type` is the main thread.

Proposed agent sets (module constants):

- Acknowledgement mode (the agent must record a decision before proceeding): `atomic-executor`, `atomic-planner`, `feature-review`, `task-researcher`, `prd-feature`, `python-typed-engineer`, `powershell-typed-engineer`. Each has the `Write` tool (a `Write(<pattern>)` entry admits the bare tool, execution-environment brief, `## Tool Routes by Agent`).
- `csharp-typed-engineer` and `typescript-engineer` have no `Write` tool (their `tools:` lists are Read, Grep, Glob, and one `Bash(...)` entry), so they cannot write a decision file. They receive directives through the prompt (relay mode) and record decisions in return lines only; this is a stated limitation, and their docs say so.
- Relay mode (checks `Agent`/`Task` delegations from any caller, including the main session): target `subagent_type` in the acknowledgement set, the two engineers above, or `orchestrator`.
- Orchestrators and the main session are never held in acknowledgement mode; they consume directives through the checkpoint, the relay check, and the stop hook.

### Resolving the item checkpoint

Resolution chain, implemented in an I/O sibling with injectable seams:

1. Payload `cwd`: `Resolve-HookTargetWorktree -FilePath <cwd>` yields the enclosing registered worktree. When `<root>/artifacts/orchestration/orchestrator-state.json` exists there, that root is the item root. This covers the normal case: a worker delegated without isolation by an item orchestrator runs with the item worktree as its working directory, and `artifacts/` is physically present there even though it is gitignored.
2. Delegation identity, for an isolated worker whose own worktree has no checkpoint (execution-environment brief, `## Batch Budget`): derive the worker's own transcript from the payload. The repository's subagent-tree code (`extensions/drm-copilot/src/lib/subagent-tree/transcript-scanner.ts`, which derives the `subagents` directory from the root session transcript path) fixes the layout `<root session transcript without .jsonl>/subagents/agent-<agentId>.jsonl`. The hook uses `transcript_path` directly when its file name is `agent-<agent_id>.jsonl`, and otherwise derives the subagent path from it. It reads the first user entry with `Read-TranscriptHead` and `Get-TranscriptFirstUserText`, reduces it with `Get-SubagentStopIdentityPrompt` (all in `.claude/hooks/subagentstop-target-worktree.ps1`), and calls `Resolve-HookTargetWorktree -DelegationPrompt` with `Get-WorktreeItemCheckpointIssue` as `CheckpointIssueReader`. Delegation prompts already carry the `branch:` label and canonical issue line (`.claude/skills/orchestrate/SKILL.md`, `## Issue Number Consistency`).
3. Otherwise the hook is inert (no output). Directive injection is task direction, not a safety control, so an unresolvable target allows.

`UNVERIFIED (orchestrator to confirm)`: whether a PreToolUse payload fired inside a subagent carries the root session transcript or the subagent's own transcript in `transcript_path`. Step 2 handles both. Also unverified: that the runtime admits a `Write` from an isolated worktree to an absolute path in another worktree; in the normal non-isolated case the decision file is inside the agent's own working tree.

Parent resolution: when the item checkpoint records `epic_context.integration_branch`, `Resolve-WorktreeEpicTarget` gives the epic root; when it records `parallel_slug`, `Resolve-WorktreeParallelTarget` gives the parallel root. The hook reads the parent checkpoint and parent ledger there.

### Directive sources and the coordinator ledger

The hook reads four sources: the item checkpoint `owner_directives`, the item ledger, the parent checkpoint `owner_directives`, and the parent ledger. The ledger is `artifacts/orchestration/owner-directives.jsonl` in a worktree: one directive object per line, the same shape as an `owner_directives` entry.

Reason for the ledger: a running orchestrator rewrites its whole checkpoint from its own copy, so a coordinator that inserts an entry into a checkpoint owned by a running agent can lose it on the agent's next write. The ledger has one writer class (the coordinator main session), is append-only, and is never rewritten by an agent. A coordinator that owns the checkpoint (a standalone `/orchestrate` main session) may still write `owner_directives` directly, as #1139 specifies, and the hook reads both. The `.jsonl` extension is not matched by `Test-ImplementationPath`, so the preimplementation gate does not treat a ledger write as implementation.

Ledger write guard (same hook, Write/Edit of a path ending `artifacts/orchestration/owner-directives.jsonl`): a write by any subagent (payload `agent_type` present) is denied, because only the coordinator records directives; an `Edit` is denied; a `Write` whose content does not keep every existing line as an unchanged prefix is denied (append-only), and every new line must pass B2-B8.

### Acknowledgement state and the hold

The decision files are the acknowledgement state; the hook writes nothing. For an agent in the acknowledgement set:

- Pending = selected entries whose `<id>.md` does not exist under `artifacts/orchestration/owner-directive-decisions/<agent_id>/` of the item root.
- While pending is non-empty, every matched tool call is denied with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_DECISION_REQUIRED:` followed by the rendered block, the always-refused note for flagged entries, the exact absolute decision-file path per id, the line grammar, and the hook's clock reading to use as `decided_at`. Read, Grep, and Glob are not in the matcher, so the agent can still read.
- Narrow allow: a `Write` of a decision file of the calling `agent_id` for a pending id, whose content is one valid line, is not denied by this hook. Validation (`Test-OwnerDirectiveDecision`, pure): line parses; class equals the directive class; `honored` is rejected for a refused class (refused classes stay refused, R6 at write time); `honored` with `decided_at` later than `expires_at` is rejected (R10); `decided_at` later than `Now` is rejected; reason length per R8. A violation denies with `OWNER_DIRECTIVE_DECISION_INVALID:`.
- A `Write` to an existing decision file, or an `Edit` of one, is denied (write-once, append-only evidence).
- When pending is empty the hook emits nothing. A directive added later becomes pending and is injected on the agent's next matched tool call.

Path checks use `Join-Path`, forward-slash relative forms, and ordinal comparisons (Linux hook-suite job, execution-environment brief, `## CI-Only Failure Classes`). `agent_id` must match `^[A-Za-z0-9][A-Za-z0-9._-]*$`; otherwise the hook is inert for that call.

## 4. Relay Independence from the Epic Orchestrator

Recommendation: hook-level pass-down (the worker hook reads the parent checkpoint and ledger itself), not a no-end-turn rule.

- Hook-level pass-down reaches a worker on its next tool call regardless of whether the epic orchestrator or the item orchestrator is active. The issue's second failure (the item orchestrator blocked while its executor runs) is solved only this way, because a blocked orchestrator cannot relay anything.
- A no-end-turn rule depends on agent behavior, and children are launched with `run_in_background: true` (`.claude/agents/epic-orchestrator.md`, `## Wave Scheduling`), so the epic orchestrator's turn ending is the normal pattern. A stop-hook block that keeps it running while children run would make it poll with no repair available to it.
- The validator check of Section 5 provides the remaining backstop without forcing the epic orchestrator to stay active.

Rejected alternative: a no-end-turn rule (behavioral, busy-loop risk, and no help for an item orchestrator blocked on its executor).

## 5. Validator Check for Running Children

Keep B1-B8 and R1-R10 blocking and unchanged (R3: record without matching directive; R6: honored refused class). Add one key-gated, clock-injected check in a new stop-hook sibling, called from `Get-OrchestratorOutputBlockDecision` after the existing owner-directive call and blocking with `OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: <details>`, repairable.

- Activation: the parent checkpoint has `owner_directives`, or its worktree has a non-empty ledger. Otherwise nothing runs, so existing checkpoints and runs are unchanged.
- Running child, epic (`features[]`): `merge_status` in `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`. Excluded: `not_started`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed` (`VALID_MERGE_STATUS` in `scripts/dev_tools/validate_epic_orchestrator_state.py`).
- Running child, parallel (`items[]`): `merge_status` in `worktree_created`, `pr_open`, `ci_green`. Excluded: `not_started`, `merged`, `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit` (`VALID_MERGE_STATUS` in `scripts/dev_tools/_parallel_state_common.py`).
- For each running child and each parent entry selected for that child at `Now`: the child is compliant when its checkpoint `owner_directives` holds the same `id` and `text_sha256`, or when the child worktree resolves by issue and its checkpoint links back to this parent (`epic_context.integration_branch` equal to the parent's `integration_branch`, or `parallel_slug` equal to the parent's), which guarantees the worker hook and the relay check reach the entry. A child that does not resolve, or whose checkpoint is unreadable or does not link back, and lacks the entry, is reported. Id conflicts between parent and child are reported.
- Item stop (`orchestrator-state`): the item checkpoint must hold every entry selected for it from its own ledger and, through its link, from the parent checkpoint and parent ledger. This is where "the child has the parent's directives" becomes literal presence, and it is checked whenever the child stops.
- Clock: one reading per hook run through a seam function in the sibling, passed as `-Now` to the pure functions; tests pass a fixed value. The rule text "the check reads no clock" in `.claude/rules/orchestrator-state.md` is amended to say the B/R check reads none and the pass-down coverage check reads one clock value through the seam.
- Ledger lines failing B2-B8 are reported by this check (`OWNER_DIRECTIVE_LEDGER_INVALID`) rather than by the worker hook, so a malformed ledger does not halt workers.
- Python and TypeScript validators stay unchanged (the documented parity gap extends to the new check); no Codex twin.

## 6. Documentation Surfaces, Mirrors, and Pinning Tests

| Surface (lines today) | Change | Copies to keep identical |
|---|---|---|
| `.claude/skills/owner-directives/SKILL.md` (117) | Ledger, id allocation, `any` step, fan-out scope, return-line grammar, decision files, orchestrator write-on-return, Claude-only hook paragraph, known limitations (engineers without Write, Codex, transcript assumption) | `.agents/skills/owner-directives/SKILL.md`, `.github/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/owner-directives/SKILL.md` |
| `.claude/skills/orchestrate/SKILL.md` (538) | Subsection under `## Delegation Model`: pass-down before every delegation, the relay check, write-on-return | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` |
| `.claude/skills/epic-orchestrate/SKILL.md` (480) | Extend the owner-directive paragraph of `## Context Handoff to Dependent Features`: hook-level pass-down, ledger in the epic worktree, fan-out scope, the running-child check; no no-end-turn rule | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`; digest re-baseline (below) |
| `.claude/skills/parallel-orchestrate/SKILL.md` (1392) | Replace "in a later course-correction message" with ledger plus hook-level pass-down; per-item scope | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` |
| `.claude/rules/orchestrator-state.md` (412) | Owner-directive section: ledger, new check, `OWNER_DIRECTIVE_RELAY_MISSING`, clock statement, new enforcement bullet | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` |
| `.claude/skills/execution-environment/SKILL.md` (192) | One `## Hook Execution Context` bullet for the new hook and the stop-hook check (maintenance rule) | the five other copies named in the brief's `## Purpose and Maintenance` |
| Worker agents: `.claude/agents/atomic-executor.md` (164), `atomic-planner.md` (92), `feature-review.md` (177), `task-researcher.md` (96), `prd-feature.md` (48), `python-typed-engineer.md` (73), `powershell-typed-engineer.md` (80), `csharp-typed-engineer.md` (69), `typescript-engineer.md` (25) | Add `owner-directives` to `skills:` and one pointer sentence (decision file for the first seven; return lines only for the two engineers) | Each file's copy under `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` |

Not edited: `.claude/agents/epic-orchestrator.md` (frozen; `owner-directives-skill-contract.Tests.ps1` asserts it has no pointer, and the AC does not name it), `.claude/agents/orchestrator.md` and `.claude/agents/parallel-orchestrator.md` (the skills carry the procedure), and the Codex surfaces `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md`, which are separate Codex texts (569 and 321 lines against the Claude 538 and 480, so not byte copies) with no hook to describe. The runtime-neutral parts reach Codex and Copilot through the byte-identical owner-directives skill.

Pinning tests:

- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `PINNED_FROZEN_SURFACE_HASHES`: the `.claude/skills/epic-orchestrate/SKILL.md` digest moves; the agent digest does not. Recompute the SHA-256 of the file bytes after the last merge of `origin/main` into the branch, immediately before the PR, and append a `RE-BASELINED by issue #1157` paragraph to the comment block that states only the skill digest moved and that the digest is the merged result of the listed issues. Any sibling that also edits the epic skill causes a certain conflict on this constant; the second to merge recomputes.
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1`: add the nine worker agents and their pointer to `$script:PointerFile`, and statements for the ledger, the grammar token `OWNER-DIRECTIVE-DECISION:`, and the hook name.
- `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_execution_environment_brief_contracts.py`, `test_claude_rules_frontmatter.py` (preloaded skill exists), `test_push_down_issue_824_follow_ups.py` (no consuming product named).

## 7. Settings Registration and Pack Manifests

- Registration pattern (verified, `.claude/settings.json`): a `hooks.PreToolUse[]` element with `matcher` and one `{ "type": "command", "command": "pwsh -NoProfile -File .claude/hooks/<name>.ps1" }`. Add a new element with matcher `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*` and command `pwsh -NoProfile -File .claude/hooks/enforce-owner-directive-pass-down.ps1`. WebFetch and WebSearch are omitted because neither executes or writes in the repository; Read, Grep, and Glob are omitted so a held agent can read. The bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` receives the same edit. Sibling #1159 consolidates hooks later; this item adds a standalone registration only.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (432 lines) lists hooks and lib modules individually (for example `.claude/hooks/enforce-docs-role-write-scope.ps1`, `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`). Add the four new `.claude` PowerShell files (D12). The Codex `core.json` is generated and unaffected (no `.codex` file changes).
- Dependency closure: `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` requires every `$PSScriptRoot` dependency of a manifested PowerShell file, and every hook script named by `.claude/settings.json`, to be in core plus the owning pack. The new hook dot-sources `hook-dependency-guard.ps1`, `subagentstop-target-worktree.ps1`, and its own I/O sibling, and imports `HookPayload.psm1`, `HookTargetWorktree.psm1`, `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, and the two new modules; all pre-existing ones are already manifested.
- Hook registry tests that enumerate every registered Claude hook: `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (`$script:ReasonPrefix`, add `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:`) and `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (`$script:ExemptHook`, reason: acts only for worker agent types and for delegations to workers or `orchestrator`; the workflow delegates only `pr-author` from the main session). `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` gains a case for the new import in `validate-orchestrator-output.ps1`, following its H9 case. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` requires the guarded single-statement import pattern; `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` stays green (no Python).

## Recommended Design Decisions

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

## Proposed File Inventory

Production, new (each with a byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/`):

- `.claude/hooks/enforce-owner-directive-pass-down.ps1`
- `.claude/hooks/owner-directive-pass-down-target.ps1`
- `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1`
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1`
- Bundle: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-owner-directive-pass-down.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/owner-directive-pass-down-target.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1`

Production, edited (line count today):

- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` (378) and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`
- `.claude/hooks/validate-orchestrator-output.ps1` (430) and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`
- `.claude/settings.json` (352) and `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (432)

Documentation, edited:

- `.claude/skills/owner-directives/SKILL.md`, `.agents/skills/owner-directives/SKILL.md`, `.github/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/owner-directives/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/owner-directives/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/epic-orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/rules/orchestrator-state.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `.claude/agents/atomic-executor.md`, `.claude/agents/atomic-planner.md`, `.claude/agents/feature-review.md`, `.claude/agents/task-researcher.md`, `.claude/agents/prd-feature.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/agents/typescript-engineer.md`, and each one's copy: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/task-researcher.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/prd-feature.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/python-typed-engineer.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/powershell-typed-engineer.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/csharp-typed-engineer.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/typescript-engineer.md`

Tests, new:

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Entry.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-owner-directive-pass-down.Tests.ps1`
- `tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1`
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1`
- `tests/scripts/claude-runtime/owner-directive-pass-down.Registration.Tests.ps1` (registration element, bundle settings equality, `core.json` membership)

Tests, edited (line count today):

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (110): append the two new modules to `$script:ExpectedPaths`
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (218)
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (278)
- `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` (510)
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1` (233)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (475): digest and comment only (extending existing Python data in place)

Expected sharing with sibling items (#1156, #1158, #1159, #1160, #1161, #1162, #1163; scopes not read, so this is a likelihood statement): `.claude/settings.json` and its bundle copy, `hook-dependency-failure.Claude.Tests.ps1`, and `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` with #1159 (hook consolidation); the six execution-environment copies, `core.json`, `.claude/rules/orchestrator-state.md`, and `parallel_orchestrator_surface_expectations.py` with any sibling that edits the brief, the manifest, the rule, or the epic skill.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for an approved `spec.md` acceptance criterion; `spec.md` is an unfilled template. The agent sets in D3 and the merge-status sets in Section 5 are design selections stated by name, not counts asserted by an acceptance criterion; the plan should name members, not counts.

## Risks

- Transcript assumption: the isolated-worker path depends on the subagent transcript layout taken from `extensions/drm-copilot/src/lib/subagent-tree/transcript-scanner.ts` and on the content of `transcript_path` in a subagent PreToolUse payload (UNVERIFIED). The `cwd` path covers non-isolated workers, which is the delegation shape used for executors working in the item worktree.
- Branch hooks are not exercised by isolated subagents until merge (execution-environment brief, `## Hook Execution Context`): acceptance must rest on Pester suites, and the return-line channel is the record path until the merge lands.
- Cost: one extra `pwsh` process per matched tool call for every agent, plus a `git worktree list` when the item or parent must be resolved; mitigated by the fast path (no sources → exit) and later by #1159's dispatcher.
- A held agent sees repeated denies until it writes its decision files; the deny text must state the exact paths and grammar so one write per directive clears it.
- Ledger extension trick: the preimplementation gate admits `.jsonl` because its extension pattern does not match; a later widening of `Test-ImplementationPath` to `jsonl` would deny coordinator ledger writes. A test in `owner-directive-pass-down.Registration.Tests.ps1` or the hook suite should pin the gate's decision for the ledger path.
- Same-session forgery and policy-only conditions from #1139 remain; the ledger is a policy-level control, not a security control.
- Frozen-surface digest conflict with any sibling editing `.claude/skills/epic-orchestrate/SKILL.md`.
- `csharp-typed-engineer` and `typescript-engineer` cannot be held by the hook.

## Automation Feasibility

No human interaction is required. Every step (code, tests, mirrors, manifest, digest re-baseline, CI) is performed by agents and CI. The orchestrator must confirm, with `git` or a non-isolated live check, the two UNVERIFIED runtime facts in Section 3; neither needs a human.

## Pre-Mortem

- Review checklists: a reviewer could find an AC unmet because worker docs lack the pointer or the two Write-less engineers are silently excluded; mitigation: the plan names all nine agent files, states the engineer limitation in the owner-directives skill and in those two agent docs, and maps each AC to a named test.
- Coverage: the two new modules and three adapters must reach 85% line coverage under `config/poshqc-coverage.json` (`.claude/hooks`, `.claude/lib`); mitigation: one test per rule branch (scope, expiry boundary, refused class, conflict, decision grammar errors, ledger prefix, each resolution step, each running-child status) with injected seams and a fixed clock.
- Mirror parity: twenty-plus mirrored Markdown files, five new bundle PowerShell copies, settings bundle copy, `core.json`, and six execution-environment copies; mitigation: run the push-down contract tests, `owner-directives-skill-contract.Tests.ps1`, `OrchestratorState.Manifest.Tests.ps1`, and the dependency-closure test, and name the brief-update task in the plan's Mirror parity bullet.
- File size: `validate-orchestrator-output.ps1` is at 430 lines and gains only an import and a call; all new logic goes into new files, each planned under 500 lines; `OrchestratorStateOwnerDirectives.psm1` grows from 378 by one exported function.
- Test isolation: transcript, checkpoint, ledger, decision-file, worktree-list, and clock reads go through seams with in-memory content; no temporary files; the gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run; `Invoke-PoshQCLeakScan` must stay clean (no global functions or environment variables left by the new suites).
- CI-only behavior: hook suites run in `poshqc / PowerShell hook suites (Linux)` on a case-sensitive file system; use `Join-Path`, forward-slash relative paths, no drive letters, and literal `/`-rooted fixture roots; the digest in `PINNED_FROZEN_SURFACE_HASHES` must be recomputed after the final `origin/main` merge or the pytest job fails.
- Evidence: hook behavior on the branch is proven by Pester, not a live isolated subagent; record the Phase 0 and final gate artifacts under `<FEATURE>/evidence/` with clock-read stamps; no acceptance condition may depend on a live run of the branch hook.
