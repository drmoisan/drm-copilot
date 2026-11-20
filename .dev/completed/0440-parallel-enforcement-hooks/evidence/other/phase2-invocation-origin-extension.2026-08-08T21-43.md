# Phase 2 — Invocation-Origin Hook Extension — Issue #440 (F7)

Timestamp: 2026-08-08T21-43

Task: [P2-T1]

Target file: `.claude/hooks/enforce-epic-invocation-origin.ps1` (258 lines, under the 500-line limit)

## Changes Applied

Exactly two behavioral changes, both strictly additive:

1. **Gated set extended.** `$script:GatedSubagentTypes` grew from `@('epic-planner', 'epic-orchestrator')` to `@('epic-planner', 'epic-orchestrator', 'parallel-planner', 'parallel-orchestrator')`, and the companion literal `$script:ParallelSubagentTypes = @('parallel-planner', 'parallel-orchestrator')` was added to drive the reason-variant selection.
2. **Parallel-family deny reason variant selected by target.** A new guarded branch placed immediately before the pre-existing epic reason assignment returns the frozen prefix `PARALLEL_INVOCATION_ORIGIN_BLOCKED` for a parallel target and falls through to the untouched epic reason for an epic target.

Four documentation-comment lines/blocks were also updated so the header `.SYNOPSIS`, `.DESCRIPTION`, decision-procedure step 1/step 3, and two inline comments describe the four gated types instead of asserting an epic-only gate. These are prose-only edits with no behavioral effect; no existing behavior statement was removed, only widened to match the extended gated set.

## Byte-Identity Proof — Epic Deny Reason

The epic reason line was not modified. `git diff` renders it as an unchanged context line (leading space, no `-`/`+` marker). Independently confirmed by hashing the line in `HEAD` and in the working tree:

Command: `git show HEAD:.claude/hooks/enforce-epic-invocation-origin.ps1 | grep -F 'EPIC_INVOCATION_ORIGIN_BLOCKED:' | sha256sum` and `grep -F 'EPIC_INVOCATION_ORIGIN_BLOCKED:' .claude/hooks/enforce-epic-invocation-origin.ps1 | sha256sum`

```
HEAD:     851971c5a1dc830f2cb861a7947e143bf0b4b3e7304ed77df4add4e3db7054c6
worktree: 851971c5a1dc830f2cb861a7947e143bf0b4b3e7304ed77df4add4e3db7054c6
```

The rendered epic reason for an epic target, captured from the running hook:

```
EPIC_INVOCATION_ORIGIN_BLOCKED: Agent(epic-planner) must not be invoked from an orchestrator agent. Both epic-planner and epic-orchestrator delegate to Agent(orchestrator), so an orchestrator-originated invocation would nest orchestrator inside its own delegation chain. Invoke epic-planner from the main session instead.
```

## Behavioral Verification

Command: `pwsh -NoProfile -File <scratchpad>/smoke-invocation-origin.ps1 -HookPath .claude/hooks/enforce-epic-invocation-origin.ps1`

EXIT_CODE: 0

```
parallel-orchestrator: fromOrchestrator=deny prefix=PARALLEL_INVOCATION_ORIGIN_BLOCKED fromMain=allow fromNonOrchestrator=allow
parallel-planner: fromOrchestrator=deny prefix=PARALLEL_INVOCATION_ORIGIN_BLOCKED fromMain=allow fromNonOrchestrator=allow
epic-orchestrator: fromOrchestrator=deny prefix=EPIC_INVOCATION_ORIGIN_BLOCKED fromMain=allow fromNonOrchestrator=allow
epic-planner: fromOrchestrator=deny prefix=EPIC_INVOCATION_ORIGIN_BLOCKED fromMain=allow fromNonOrchestrator=allow
atomic-planner: fromOrchestrator=allow prefix= fromMain=allow fromNonOrchestrator=allow
nonGatedMalformedPayload=allow
```

The smoke script is a throwaway created outside the repository (scratchpad) and is not a repository artifact. The durable regression coverage for these behaviors is [P2-T2]'s appended Pester contexts, verified by [P2-T7].

Output Summary: PASS. The invocation-origin hook now gates four subagent types. Both parallel targets deny with the frozen `PARALLEL_INVOCATION_ORIGIN_BLOCKED` prefix when the caller `agent_type` is `orchestrator`, and allow from the main thread (absent `agent_type`) and from a non-`orchestrator` agent. Pre-existing epic behavior is unchanged: both epic targets still deny with a byte-identical `EPIC_INVOCATION_ORIGIN_BLOCKED` reason (sha256 of the reason line matches `HEAD` exactly), a non-gated target still allows, and a non-gated target with a malformed `CLAUDE_HOOK_INPUT` still allows without parsing the payload. File is 258 lines.
