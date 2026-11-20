# csharp-budget-text-per-batch-cap (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #769

## Summary

The C# guidance surfaces still describe a per-batch cap of production and test files with instructions to split work into smaller batches. #769 removed that text from the PowerShell surfaces because the orchestrated large path has no production-file cap. The C# surfaces were out of scope for #769 and still carry the old text.

## Scope

- `csharp-change-budget-router` under `.claude/skills/` and `.agents/skills/`.
- `.claude/agents/csharp-typed-engineer.md`.
- `.github/agents/csharp-typed-engineer.agent.md`.
- `.codex/agents/csharp-typed-engineer*.toml` (base and variants, regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`).
- The csharp-legacy variants under `extensions/drm-copilot/resources/claude-customizations/.claude-variants/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/`.
- The bundle mirrors of every file above.

## Acceptance Criteria (early draft)

- [ ] A case-insensitive search for the #769 AC-13 phrases ("per-batch", "batch cap", "smaller batches", "split the work", "new batch", "three-test") returns no match in C#-scoped surfaces and their mirrors.
- [ ] The Codex C# variants are regenerated with the repository generator, not edited by hand, and the generator's `--check` mode passes.
- [ ] Every changed primary file is byte-identical to its bundle mirror.

## Constraints & Risks

- The csharp-legacy variants are generated or copied from separate sources; the change must update the source of each variant rather than only its output.
- On Windows the variant generator rewrites unrelated pack manifests with CRLF line endings (observed during #769); restore them before verifying the change set.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
