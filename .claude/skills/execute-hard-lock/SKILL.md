---
name: execute-hard-lock
description: Place the session in atomic execution mode bound to a specific plan-of-record. Enforces read-proof, preflight-only validation, and task-by-task execution without replanning. Use when a caller provides ${plan-path} and ${work-mode} and requires strict plan-following behavior.
allowed-tools:
  - mcp__drmCopilotExtension__resolve_execute_hard_lock_prompt
  - Read
  - "Bash(git rev-parse *)"
---

# Execute Hard Lock

Deterministic hard-lock workflow that activates atomic execution mode for a specific plan-of-record. The `mcp__drmCopilotExtension__resolve_execute_hard_lock_prompt` MCP tool is the sole source of truth for the hard-lock instruction set. After resolution, this skill delegates execution to the `atomic-executor` subagent.

## When to Use This Skill

Use this skill when:

- The caller provides an explicit plan file path (`${plan-path}`) and a selected work mode (`${work-mode}`).
- Strict plan-following behavior is required (no replanning, no reordering, no bucket tasks).
- The caller wants the session to return a read-proof and `READY TO BEGIN FROM [P#-T#]` signal before execution starts.

## Inputs

Required:

- `plan-path` — absolute or repo-relative path to the plan-of-record markdown file.
- `work-mode` — one of `minor-audit`, `full-feature`, `full-bug`. Legacy value `full` normalizes to `full-feature`. Missing or malformed values fail closed to `full-feature`.

## Invocation Flow

When this skill is invoked, perform these steps in order before executing any plan task.

### 1. Resolve the Hard-Lock Prompt via MCP (Authoritative)

Call the extension's resolver as the first action:

- Tool: `mcp__drmCopilotExtension__resolve_execute_hard_lock_prompt`
- Parameters:
  - `target` (required): the plan-of-record path (`${plan-path}`).
  - `workspace_root` (optional): the workspace root (`${workspaceFolder}`). Omit to default to the current working directory.

The returned text is the authoritative hard-lock instruction set for this session.

Abort on resolver failure: if the MCP tool is not available, is not permitted, or returns an error, stop immediately and report `BLOCKED: execute-hard-lock resolver unavailable`. Do not attempt to reconstruct or substitute the hard-lock contract from any other source. Execution must not proceed without a successful MCP resolution.

### 2. Record Mode Context

Record the selected work mode (`${work-mode}`) supplied by the caller. Resolve per the `Mode source precedence` rules in `atomic-plan-contract`. When the mode is absent or malformed, fail closed to `full-feature`.

### 3. Record Plan of Record

Record `${plan-path}` as the sole plan-of-record for the session.

### 4. Mandatory Read-Proof (Before Any Task Execution)

1. Confirm the plan-of-record file exists in the current branch.
2. Output a fingerprint of what was read:
   - `git rev-parse HEAD`
   - SHA-256 of the plan file
   - total count of lines matching `^- \[[ x]\] \[P` in the plan file
3. Enter atomic execution mode under the instruction set returned by the MCP tool in step 1.
4. Perform preflight validation only (no task execution).
5. Identify the first unchecked `[ ]` task in plan order and print only:
   - the exact line for that task
   - two lines above and two lines below
6. State `READY TO BEGIN FROM [P#-T#]` and wait for the caller to authorize execution.

## Equivalent Entry Points (Reference)

The following three entry points all produce the same resolved hard-lock prompt for a given plan path. This skill always uses the MCP form:

- MCP (used by this skill): `mcp__drmCopilotExtension__resolve_execute_hard_lock_prompt` with `target=<plan-path>`.
- VS Code command: `@command:drmCopilotExtension.resolveExecuteHardLockPrompt`.
- Local task (development only): `poetry run python scripts/dev_tools/resolve_hard_lock_prompt.py --target ${file} --workspace ${workspaceFolder}`.

## Delegation

After the MCP tool returns the hard-lock instruction set and the read-proof is emitted, this skill delegates execution to the `atomic-executor` subagent. The subagent applies the instruction set together with the referenced shared skills:

- `policy-compliance-order` — mandatory policy reading order.
- `atomic-plan-contract` — plan format, Phase 0 requirements, preflight signals, validator gate, and mode-specific plan gates.
- `acceptance-criteria-tracking` — AC check-off protocol and status summary format.
- `evidence-and-timestamp-conventions` — baseline and final-QC artifact paths and required fields.

## Prohibitions

- Do not proceed without a successful MCP resolver response.
- Do not reconstruct the hard-lock contract from any other source.
- Do not replan, reorder, or add tasks.
- Do not check off tasks via any in-session tracker; only on-disk check-offs to the plan file are authoritative.
- Do not block after execution begins.
- Do not modify policy files under `.claude/rules/` or `.github/instructions/`.
- Do not create or read secrets unless explicitly authorized.
