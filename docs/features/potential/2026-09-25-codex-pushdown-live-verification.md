# codex-pushdown-live-verification (Potential)

- Date captured: 2026-09-25
- Author: Dan Moisan
- Status: Draft
- Source: issue #697 (`docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/spec.md`, AC-2.5)

## Problem / Why

Issue #697 made a Codex push-down self-sufficient: the published `.codex` tree now carries the
routing config files, the `.codex/lib/codex-routing` modules, the PowerShell routing wrappers, a
corrected `csharp-legacy` role file, fail-soft registry loading in `enforce-epic-planning-only.ps1`,
and a complete `core.json`. That work was verified in-repository only: unit tests, an in-memory
real-bundle integration test, and a bundle-location hook probe.

It was not verified against a live destination, because a live Codex session in a destination
loads the MCP server pinned in `.codex/config.toml`. The fixes that ship through the
`@danmoisan/drm-copilot-mcp` package (the anchored prepack filter that now packages the nested
`.codex/scripts` wrappers) reach a destination only after the next package release and a version-pin
bump.

## Proposed Behavior

After the next `@danmoisan/drm-copilot-mcp` release:

1. Bump the MCP version pin in `.codex/config.toml` and in
   `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` to the
   released version.
2. Re-run `push_down_codex_and_agents_customizations` into a destination workspace that has no
   Python toolchain and no prior `.codex` tree.
3. In a Codex session in that destination, confirm:
   - zero hook failures on ordinary `Bash`, `apply_patch`, `Edit`, and `mcp__` tool calls;
   - no malformed-role warning when Codex loads `.codex/agents/*.toml`;
   - successful topology resolution with
     `pwsh -NoProfile -File .codex/scripts/Resolve-CodexTopology.ps1` and successful deployment
     resolution with `pwsh -NoProfile -File .codex/scripts/Resolve-CodexDeployment.ps1`.

## Acceptance Criteria (early draft)

- [ ] Both `.codex/config.toml` copies pin the released `@danmoisan/drm-copilot-mcp` version.
- [ ] A fresh push-down into a Python-free destination reports zero hook failures.
- [ ] Codex reports no malformed-role warning in the destination.
- [ ] Both routing wrappers resolve successfully in the destination.

## Constraints & Risks

The version-pin bump is a non-goal of issue #697 (AC-6.6) and must be a separate change. The live
check depends on a published package, so it cannot run in CI.

## Test Conditions to Consider

- [ ] Destination without Python on `PATH`
- [ ] Full-tree and pack-mode push-downs
- [ ] `csharp-legacy` variant selection

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/codex-pushdown-live-verification/` folder from the template
