# Preflight Fixes — Issue 1028 (OD-2 confirming preflight)

Timestamp: 2026-11-15T17-55
Plan: docs/features/active/2026-10-30-shared-source-generators-skills-rules-mcp-agents-1028/plan.2026-10-30T18-30.md

## Fixes

1. [P5-T3] acceptance | validator-blind observation defect (assertion meaning kept) | The before-and-after comparison for the first and second Codex write runs used porcelain status. `-Surface agents` writes the base `.codex/agents/<family>.toml` files and their bundle copies before the Codex run, so those paths are already modified when the first run starts, and porcelain status would show no difference even if `scripts/dev_tools/generate_codex_agent_variants.py` rewrote them; likewise variants already rewritten by the first run would hide a second-run rewrite. The comparison now uses the content hash (`git hash-object`) of every file under `.codex/agents/`, the bundle `.codex/agents/` copy and the bundle `pack-manifests/` folder. What is asserted is unchanged: no base, bundle base or pack manifest change on the first run, only listed variants change, and nothing changes on the second run.
