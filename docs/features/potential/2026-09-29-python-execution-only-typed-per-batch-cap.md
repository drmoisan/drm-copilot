# python-execution-only-typed-per-batch-cap (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #773, #769

## Summary

`.github/agents/python-execution-only-typed.agent.md` lines 34-37 and its bundle copy under `extensions/drm-copilot/resources/customizations/.github/agents/` carry a separate per-batch cap of 30 production files and 30 test files, together with a `budget: prod=<N>, test=<M>` override. Line 84 of the same file tells the agent to "seek an override" when a planned addition would exceed the 500-line limit. Issue #773 replaced per-batch caps and overrides with the production-file routing rule on every other Python surface, but excluded this agent (spec Out of scope). No routing surface delegates to this agent, and `.codex/agents/python-execution-only-typed.toml` carries no budget text.

## Scope

- `.github/agents/python-execution-only-typed.agent.md`
- `extensions/drm-copilot/resources/customizations/.github/agents/python-execution-only-typed.agent.md`

An owner decision is required: align the agent with the routing model, retain its cap as a distinct execution-only budget, or remove the budget text.

## Acceptance Criteria (early draft)

- [ ] The owner decision (align, retain, or remove) is recorded in the promoted issue.
- [ ] If the decision is to align, the #773 AC-18 phrase search returns no match in the agent file and its bundle copy.
- [ ] The agent file and its bundle copy stay byte-identical.

## Constraints & Risks

- The agent is an execution-only worker; aligning it with the routing model may change behavior for callers that rely on the 30/30 cap.
- `.github/agents/*` edits must keep the Copilot bundle mirror byte-identical, or the bundle parity suites fail.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
