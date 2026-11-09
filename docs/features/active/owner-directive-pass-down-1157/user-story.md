# `owner-directive-pass-down` — User Story

- Issue: #1157
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09T21-37
- Spec: `docs/features/active/owner-directive-pass-down-1157/spec.md`

## Story Statement

- As the repository owner, I want a directive I give the coordinator to reach every agent that runs commands in its scope, including an executor that is already running, so that the agents stop non-compliant work on their next tool call instead of continuing for many minutes.
- As the coordinator session, I want to record a directive once, in a ledger that no running agent rewrites, so that it reaches every in-scope item and worker without depending on an epic or item orchestrator being active.
- As an item orchestrator, I want my delegations to be denied until my checkpoint and prompt carry the selected directives, and I want a defined way to collect each worker's decision, so that every delegation relays the directives verbatim and my checkpoint records each decision.
- As an executor or other worker, I want pending directives shown to me as the reason my next tool call was denied, with the exact file path and line grammar for my decision, so that I can record `honored` or `refused` in one write and continue.

## Problem / Why

Issue #1139 defined how owner directives are recorded, relayed, and decided, but relay is prose only. Nothing moves a directive from a parent checkpoint to a child or into a running worker's context. An epic orchestrator ended its turn after launching children, so directives it was asked to relay never reached them. A feature orchestrator blocked on its executor could not deliver a course correction, and the executor kept retrying non-compliant commands (killed test runs, renamed wrapper scripts) for many minutes after the owner's instruction.

## Personas & Scenarios

- Persona: Repository owner
  - Who: the person who directs work and issues directives in the coordinator session.
  - Cares about: instructions taking effect promptly and being auditable.
  - Constraints: directives are task direction only; they never grant approval, permission, or configuration authority.
  - Goals and frustrations: wants a correction to reach a running executor; is frustrated when agents continue non-compliant commands after an instruction.
  - Context: runs epic, parallel, and standalone orchestrations, often autonomously.
- Persona: Coordinator session (main session)
  - Who: the session that receives the owner's turns and records directives.
  - Cares about: recording each directive once, in a place that running agents do not overwrite.
  - Constraints: only the coordinator records directives; a running orchestrator owns its own checkpoint.
  - Goals: append to `artifacts/orchestration/owner-directives.jsonl` in the relevant worktree and have pass-down happen without further action.
- Persona: Executor or other worker (`atomic-executor`, `atomic-planner`, `feature-review`, `task-researcher`, `prd-feature`, `python-typed-engineer`, `powershell-typed-engineer`; `csharp-typed-engineer` and `typescript-engineer` through return lines)
  - Who: the agent running commands for an item.
  - Cares about: knowing which directives apply and how to record a decision.
  - Constraints: refused classes stay refused; a directive changes no hook, gate, permission, or setting.
  - Goals: record one decision per directive and continue work.

- Scenario: Course correction reaches a running executor
  1. An executor is running S5 for an item; its item orchestrator is blocked waiting for it.
  2. The owner tells the coordinator to change the order of work. The coordinator appends a `scheduling` directive scoped to the item issue, branch, and step `any` to the item worktree's ledger.
  3. On the executor's next `Bash` call, `enforce-owner-directive-pass-down.ps1` denies the call with `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED: OWNER_DIRECTIVE_DECISION_REQUIRED:`, the rendered block, the decision-file path, the grammar, and the clock value to use.
  4. The executor writes one `OWNER-DIRECTIVE-DECISION:` line to its decision file; the hook validates it and stops denying.
  5. On return, the item orchestrator copies the directive into `owner_directives` and appends the `owner_directive_records` entry; the stop hook verifies the records.
- Scenario: Epic directive fans out without the epic orchestrator
  1. The epic orchestrator launches children in the background and ends its turn.
  2. The coordinator appends a directive scoped to `epic_issue_num` and the integration branch to the epic worktree's ledger.
  3. Each child's workers resolve the epic parent through `epic_context.integration_branch` and are held on their next matched call until they record a decision.
  4. When the epic orchestrator next stops, the running-child check reports any running child that neither holds the entry nor links back to the epic.
- Scenario: Refused class
  1. The coordinator records a `force_push` directive.
  2. The worker is held and told the class is always refused; a decision file with `honored` is denied with `OWNER_DIRECTIVE_DECISION_INVALID:`; a `refused` decision with a reason of at least 20 characters is accepted.
- Scenario: No directives
  1. No ledger exists and no checkpoint has `owner_directives`.
  2. Every hook behaves exactly as before this feature.

## Acceptance Criteria

These criteria restate the issue ACs at story level; each is verified through the spec criteria named in parentheses.

- [ ] Before every worker or `orchestrator` delegation in preparation, execution, remediation, and review, the delegation is denied with `OWNER_DIRECTIVE_RELAY_REQUIRED` unless the item checkpoint holds each selected parent and item directive (same `id` and `text_sha256`) and the prompt contains its rendered block lines verbatim (spec AC-8, AC-10, AC-11, AC-12, AC-13).
- [ ] Directives are selected by scope (item issue and known branch, or epic fan-out on `epic_issue_num` and `integration_branch`), step (`any`, exact, or `<step>_` prefix), and strict expiry `expires_at > Now`; refused classes are selected and flagged (spec AC-1 to AC-7, AC-9).
- [ ] A worker in the acknowledgement set is denied on its next matched tool call with `OWNER_DIRECTIVE_DECISION_REQUIRED` while any selected directive lacks its decision file, and is released once each has a valid one; a directive added later is injected on the following call (spec AC-14, AC-15, AC-20).
- [ ] Decisions use the `OWNER-DIRECTIVE-DECISION:` grammar; decision files are one line, write-once, written only by the matching `agent_id`, and an `honored` decision for a refused class, a class mismatch, an `honored` decision after `expires_at`, a future `decided_at`, or a reason shorter than 20 characters is denied with `OWNER_DIRECTIVE_DECISION_INVALID` (spec AC-16 to AC-19).
- [ ] The orchestrator writes each worker's decisions to `owner_directive_records` on return, with a decision file taking precedence over a return line, and the optional fields `agent_id` and `decision_source` are tolerated (spec AC-21, AC-22).
- [ ] Pass-down reaches workers from the item and parent ledgers and checkpoints without any orchestrator acting, and no no-end-turn rule is added (spec AC-23, AC-24, AC-26).
- [ ] Only the coordinator main session can write a ledger, and only by appending valid lines (spec AC-27, AC-28).
- [ ] The stop hook still blocks a record without a matching directive (R3) and an `honored` record for a refused class (R6), and blocks with `OWNER_DIRECTIVE_RELAY_MISSING` when an in-scope running child of an epic or parallel parent, or an item checkpoint at stop, lacks an unexpired selected directive (spec AC-29 to AC-35).
- [ ] With no ledger and no `owner_directives` in any source, behavior equals today's, and no configuration knob is added (spec AC-25).
- [ ] The hook is registered as a standalone `hooks.PreToolUse[]` element in `.claude/settings.json` and its bundle copy, listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and every new or edited `.claude` file has a byte-identical bundle copy (spec AC-36 to AC-39).
- [ ] The owner-directives, orchestrate, epic-orchestrate, and parallel-orchestrate skills, `.claude/rules/orchestrator-state.md`, the execution-environment brief, and the worker agent docs are updated with mirror parity, the orchestrator agent docs are unchanged, and only the epic-orchestrate skill digest is re-baselined (spec AC-40 to AC-46).
- [ ] Unit tests cover the pure scope, selection, rendering, grammar, decision, and ledger logic with a fixed clock and in-memory content; new files reach at least 90% line coverage in one parallel Pester run; no new Python file is added (spec AC-47, AC-48).

## Non-Goals

- A Codex or Copilot hook twin, or any change to the Python or TypeScript orchestrator-state validators.
- A no-end-turn rule for the epic orchestrator.
- Holding `csharp-typed-engineer` or `typescript-engineer` in acknowledgement mode; they record decisions in return lines only.
- Any change to how a directive is classified, or any directive-based allow path in a hook.
- Consolidating hooks into a single dispatcher (sibling #1159).
- Edits to `.claude/agents/epic-orchestrator.md`, `.claude/agents/orchestrator.md`, or `.claude/agents/parallel-orchestrator.md`.
