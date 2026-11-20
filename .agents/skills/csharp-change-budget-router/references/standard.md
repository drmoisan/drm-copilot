# Gold Standard: csharp-change-budget-router

## Objective

Budget-first routing contract for C# work: estimate production-file scope, choose small vs large path, enforce orchestration-first routing for larger changes, and use the repository automation tools for promotion lifecycle steps when available. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Canonical Routing Rules: The skill first estimates the change budget from the likely production C# files touched and then routes 1 to 3 production files with their tests to the small path (`csharp-typed-engineer` direct mode) and more than 3 production files or more than 3 test files to the large path (the orchestration workflow with promotion, research, spec, planning, execution and review).
- **OB-2** Orchestrated Small-Path Requirements: Promotion and folder lifecycle steps run through the repository automation tools, and when the required tool is unavailable the skill stops before promotion begins.
- **OB-3** Direct-Mode Rejection Rule: Stop before implementation.
- **OB-4** Invocation Mode: The worker runs in direct mode by default, when no handoff directive is present and the strict change-budget limits apply, or in orchestrator handoff mode only when the request contains the exact line `DIRECTIVE: ORCHESTRATOR HANDOFF MODE`, which lifts the overall limits but requires a complete context package of the objective and expected outcome, `${promotion-type}` and `${issue-num}` when available, the `${feature-folder}` path, the issue, spec and user-story paths (or an explicit `NONE` for the user story), the research artifact paths, and the constraints, APIs or invariants to preserve, and it stops to request any missing field before Phase A proceeds.
- **OB-5** Per-Batch Cap: In all modes, per-batch budget remains: at most 3 production files and 3 test files unless an explicit override is approved by the user.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Canonical Routing Rules, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Orchestrated Small-Path Requirements, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Direct-Mode Rejection Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Invocation Mode, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Per-Batch Cap, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
