---
name: python-change-budget-router
description: Budget-first routing contract for Python work. Estimate production-file scope, choose small vs large path, and route direct-mode work of more than 3 production files to the orchestrated large path.
---

# Python Change Budget Router

Canonical guidance for deciding whether Python work stays on the small path (`python-typed-engineer` direct mode) or escalates to the orchestrated large path through `.codex/prompts/orchestrate-work.md`.

## When to Use This Skill

Use this skill when:

- Intake starts from a natural-language Python request.
- An agent must decide the execution path before planning or implementation.
- A direct-mode route must reject over-budget requests and switch to orchestrated flow.

## Canonical Routing Rules

1. Estimate rough change budget first based on likely **production Python files** touched.
2. Route:
   - `1-3` production files (plus corresponding tests) → **small path** (`python-typed-engineer` direct mode).
   - More than 3 production files → **large path** (`.codex/prompts/orchestrate-work.md`). The large path has no production-file cap.
3. Test files are not counted toward the routing threshold.

## Direct-Mode Rejection Rule

If `python-typed-engineer` is invoked directly and the estimated scope, or the scope discovered during implementation, is more than 3 production files:

- Stop before editing the 4th production file.
- Report the production files already changed and the production files still required.
- Return an explicit routing instruction to invoke `.codex/prompts/orchestrate-work.md`.
- Do not request an exception to the threshold; routing is the only path past it.

## Orchestrated Small-Path Requirements

When routed through the orchestrator, the small path still requires lifecycle scaffolding before implementation:

- invoke promotion and folder lifecycle steps through the `drm-copilot` MCP tools required by `repo-automation-adapter`. If the MCP server or required tool is unavailable, stop before promotion.
- promote the potential item to a GitHub issue with `--work-mode minor-audit`,
- create the active feature folder with `--work-mode minor-audit`,
- delegate minimal-audit plan creation to `atomic_planner` with `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`,
- require `atomic_executor` preflight until `PREFLIGHT: ALL CLEAR`,
- execute Phase 0 only via `atomic_executor` before branching,
- run the reduced small-audit after implementation and QC.

Direct invocation of `python-typed-engineer` remains implementation-focused and does not replace orchestrator lifecycle steps.

## Documentation Expectations

Record in the agent response or logs:

- estimated production file count,
- chosen path (`small` or `large`),
- rationale summary (1-3 bullets),
