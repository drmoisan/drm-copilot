# codex-routing-resolver-powershell-budget-two (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #769

## Summary

#769 set the PowerShell direct-mode threshold to 1-3 production files on the Claude and Copilot surfaces and in both batch-budget hooks. The Codex topology resolver still pins a PowerShell `max_production_files` of 2, and the Codex and `.agents` threshold text that documents it was deferred by #769. A 3-file PowerShell change therefore routes to the large path under Codex and to the small path elsewhere.

## Scope

- Resolver configuration and implementations:
  - `config/orchestration-routing.json:229-234` and its two bundled copies.
  - `scripts/dev_tools/resolve_codex_topology.py:76-80`.
  - `.claude/lib/codex-routing/CodexTopology.psm1:72` and its bundle copies.
  - `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`.
  - The parity fixtures and tests listed in the #769 research artifact, Section 3.3.
- Deferred Codex and `.agents` threshold text, with mirrors:
  - `.agents/skills/powershell-change-budget-router/SKILL.md`.
  - The `1-2` and "one-to-two" clauses of `.agents/skills/powershell/SKILL.md` and `.agents/skills/invoke-powershell-engineer/SKILL.md`.
  - `.agents/skills/codex-model-routing/SKILL.md`.
  - `.codex/agents/powershell-orchestrator.toml`.
  - The `1-2` and `2` clauses of `.codex/agents/powershell-typed-engineer*.toml` (regenerated, not hand-edited).

## Acceptance Criteria (early draft)

- [ ] The resolver in all three runtimes (Python, PowerShell, TypeScript) routes a 3-file PowerShell change to the small path, with the parity fixtures updated.
- [ ] The Codex and `.agents` threshold text states 1-3 production files and names the large path above it.
- [ ] Every changed primary file is byte-identical to its bundle mirror.

## Constraints & Risks

- The resolver value is shared across three runtimes; a partial change creates a parity failure.
- Changing the Codex routing budget changes which Codex agent handles 3-file PowerShell work.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
