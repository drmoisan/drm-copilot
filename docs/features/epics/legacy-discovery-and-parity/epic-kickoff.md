# Epic Kickoff: legacy-discovery-and-parity

Planned by epic-planner on 2026-07-17T10:10Z. All fourteen child features are prepared: issues
promoted, active folders created, research complete, spec/user-story written, atomic plans
approved, preflight ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json
(branch: epic/legacy-discovery-and-parity-integration).

## Invocation Prompt

Run `/epic-run legacy-discovery-and-parity` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/legacy-discovery-and-parity/epic.md. The integration branch
epic/legacy-discovery-and-parity-integration already contains every prepared feature folder and
approved atomic plan; child features resume at atomic execution from their committed plan-path
rather than re-planning. Execute per the epic-orchestrate skill: wave-scheduled child
orchestrator runs in isolated worktrees, merge-on-green fan-in to the integration branch, and
the final integration-to-main PR. model_budget.fable_policy: preferred (note: the fable tier
returned "usage credits required" throughout preparation and each child clamped its overlay
delegations to opus/sonnet; if fable remains unentitled at execution, expect the same clamp).

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 360 | 2026-07-17-legacy-discovery-config-contract-360 | 0 | C3 | docs/features/active/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md |
| 359 | 2026-07-17-legacy-discovery-schemas-359 | 0 | C3 | docs/features/active/2026-07-17-legacy-discovery-schemas-359/plan.2026-07-17T14-03.md |
| 361 | 2026-07-17-legacy-discovery-validators-361 | 1 | C2 | docs/features/active/2026-07-17-legacy-discovery-validators-361/plan.2026-07-17T14-03.md |
| 362 | 2026-07-17-legacy-discovery-init-templates-362 | 1 | C2 | docs/features/active/2026-07-17-legacy-discovery-init-templates-362/plan.2026-07-17T14-05.md |
| 363 | 2026-07-17-legacy-discovery-analyzer-framework-363 | 1 | C3 | docs/features/active/2026-07-17-legacy-discovery-analyzer-framework-363/plan.2026-07-17T14-34.md |
| 365 | 2026-07-17-legacy-discovery-agent-roles-365 | 1 | C3 | docs/features/active/2026-07-17-legacy-discovery-agent-roles-365/plan.2026-07-17T14-37.md |
| 364 | 2026-07-17-legacy-discovery-acceptance-scenarios-364 | 1 | C3 | docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/plan.2026-07-17T14-37.md |
| 366 | 2026-07-17-legacy-discovery-hooks-366 | 2 | C2 | docs/features/active/2026-07-17-legacy-discovery-hooks-366/plan.2026-07-17T14-38.md |
| 367 | 2026-07-17-legacy-discovery-skills-367 | 2 | C3 | docs/features/active/2026-07-17-legacy-discovery-skills-367/plan.2026-07-17T15-03.md |
| 368 | 2026-07-17-legacy-discovery-reports-368 | 2 | C2 | docs/features/active/2026-07-17-legacy-discovery-reports-368/plan.2026-07-17T15-03.md |
| 369 | 2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369 | 2 | C4 | docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/plan.2026-07-17T15-07.md |
| 370 | 2026-07-17-legacy-discovery-mcp-vscode-370 | 3 | C3 | docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md |
| 372 | 2026-07-17-legacy-discovery-publishing-372 | 3 | C2 | docs/features/active/2026-07-17-legacy-discovery-publishing-372/plan.2026-07-17T15-30.md |
| 371 | 2026-07-17-legacy-discovery-documentation-371 | 4 | C2 | docs/features/active/2026-07-17-legacy-discovery-documentation-371/plan.2026-07-17T15-28.md |

## Execution-Time Reconciliation Notes (from preparation)

Preparation ran all child specs/plans against documented upstream contracts because siblings
in earlier waves had not yet merged into each child's worktree at prep time. epic-orchestrator
executes waves in dependency order, so upstreams will be present on the integration branch when
each dependent feature executes. Two cross-feature contracts to reconcile during execution:

- Analyzer `ParseResult` payload (#363 vs #369): the .NET/VSTO analyzers (#369) require file
  text between the I/O `parse` stage and the pure `classify` stage; they adopt a frozen
  `TextParseResult` and record an open item to reconcile with #363's paths-only `ParseResult`
  before that contract freezes.
- MCP runtime (#370): the MCP server ports former Python tools in-process (feature #240;
  `RuntimeKind` was PowerShell-only), so #370's plan extends the runtime with a Python kind and
  spawns the discovery CLI rather than relying on a bundled-Python shell-out. Documentation
  (#371) and publishing (#372) both carry a pre-PR reconciliation pass against the actual
  landed `dev.discovery.*` command names, schema paths, and pack-manifest decisions.

These are execution-time reconciliations, not planning defects; each child's plan flags them
explicitly for epic-orchestrator.
