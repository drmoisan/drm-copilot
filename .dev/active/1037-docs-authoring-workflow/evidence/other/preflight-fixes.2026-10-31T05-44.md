# Preflight Fixes (confirming preflight)

Timestamp: 2026-10-31T05-44
Plan: docs/features/active/2026-10-30-docs-authoring-workflow-1037/plan.2026-10-30T18-59.md

## Fix 1 — [P2-T1]

- Defect class: validator-blind changed-behavior assertion (entrypoint ordering left implicit); correction keeps the assertion's meaning.
- Finding: `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` test B1 asserts `Should -Invoke Read-ClaudeHookRawPayload -Times 0 -Exactly` for a PreToolUse hook whose dependency fails. The task text placed the dependency decision inside `Invoke-DocsRoleWriteScopeDecision -HookInputRaw`, which, if called as `-HookInputRaw (Read-ClaudeHookRawPayload)`, reads the payload before the dependency check and fails B1. The precedent `enforce-epic-invocation-origin.ps1` runs the bootstrap tail check and `Get-HookDependencyFailureDecision` before reading the payload.
- Change: the entrypoint clause now states that the bootstrap tail check and the `Get-HookDependencyFailureDecision` check run before `Read-ClaudeHookRawPayload` is called, citing the precedent and B1. The [P2-T5] acceptance (B1 to B4 pass) is unchanged.

## Fix 2 — [P7-T10]

- Defect class: citation correction (context classification).
- Finding: the execution-environment brief `## CI Shape and Required Checks` lists the ruleset-required contexts; `poshqc / PowerShell hook suites (Linux)` is not among them. The task called all six contexts "required".
- Change: "the six CI contexts this feature relies on", with a parenthetical stating that the Linux hook-suite context is not ruleset-required and the other five are. The acceptance (exactly six contexts, each `pending-CI`) is unchanged.

## Fix 3 — `## Pre-Mortem` CI-only behavior bullet

- Defect class: citation correction (consistent with Fix 2).
- Change: "The six required CI contexts" now reads "The six CI contexts of [P7-T10]".

## Fix 4 — `## Open Questions / Notes` N11

- Defect class: citation correction (consistent with Fix 2).
- Change: "records the six required contexts" now reads "records the six CI contexts".
