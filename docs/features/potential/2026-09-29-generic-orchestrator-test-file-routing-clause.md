# generic-orchestrator-test-file-routing-clause (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #773, #769

## Summary

`.github/agents/orchestrator.agent.md` lines 117 and 283 and `.github/prompts/orchestrate-work.prompt.md` line 37 route work to the large path when it touches more than 3 test files. Issues #769 and #773 route on production files only, test files are not counted toward the routing threshold, and the Codex topology resolver routes only on the production-file count. The language-generic orchestrator surfaces therefore disagree with the language-specific routing rule.

## Scope

- `.github/agents/orchestrator.agent.md` (lines 117 and 283)
- `.github/prompts/orchestrate-work.prompt.md` (line 37)
- The bundle copies of both files under `extensions/drm-copilot/resources/customizations/.github/`

Related surfaces that carry the same clause: `.github/agents/csharp-orchestrator.agent.md` lines 102 and 248, `.github/prompts/orchestrate-csharp-work.prompt.md` line 37, and `.github/skills/csharp-change-budget-router/SKILL.md` line 22.

## Acceptance Criteria (early draft)

- [ ] The #773 AC-20 regex search returns no match in the two files and their bundle copies.
- [ ] The two files and their bundle copies stay byte-identical.

## Constraints & Risks

- The generic orchestrator routes every language; removing the test-file clause changes routing for work whose language surface has not adopted the production-only rule.
- The C# surfaces are listed as related only and may need a separate decision.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
