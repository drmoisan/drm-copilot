# Consumer Onboarding

This page documents the generic path by which a consumer repository receives the
legacy-discovery-and-parity capability. It describes the onboarding flow independently of
any specific consumer. TaskMaster (the legacy source provider) and TMW (the modern target
provider) appear only in the labeled example section at the end of this page, per the
[domain-neutrality invariant](README.md#domain-neutrality-invariant): they are the epic's
first consumers, not framework behavior.

## What Is Delivered, and How

The capability's assets are distributed to a consumer repository through two different
mechanisms, depending on the asset's kind. A maintainer onboarding a consumer repository
needs both, not just one:

1. **Agent personas, skills, and hooks — pushed down as `.claude`/`.codex`+`.agents` assets.**
   The four discovery agent personas, the seven discovery skills, and the two
   discovery completion-gate hooks are ordinary repository-native `.claude/` assets,
   mirrored byte-identically into `extensions/drm-copilot/resources/` and delivered
   through the existing push-down tooling described below. They are placed in the `core`
   pack-manifest, which is unconditionally included in every `--packs`-scoped push-down —
   a consumer selecting only its own language pack (for example a C# pack or a TypeScript
   pack) still receives the full discovery agent/skill/hook set without a separate opt-in.
2. **Schemas and initialization templates — distributed as Python package data via the
   MCP-server npm package, not pushed down.** The seven discovery JSON schemas
   (`schemas/discovery/v1/*.schema.json`) and the initialization templates
   (`docs/discovery/templates/`) live under repository-root trees that are outside the
   byte-identical `.claude`/`.codex` mirror contract. They reach a consumer repository as
   Python source/data through the `@danmoisan/drm-copilot-mcp` npm package (the same
   package that exposes the MCP tools in [`running-the-workflow.md`](running-the-workflow.md)),
   not through `push_down_claude_customizations.py` or
   `push_down_codex_and_agents_customizations.py`. This is a deliberate scope boundary, not
   an omission: an asset under `scripts/` or `docs/discovery/templates/` is Python source
   the consumer's own toolchain resolves at runtime, not a customization asset the push-down
   publishers mirror.

## The Push-Down Tool

A maintainer runs the appropriate push-down variant against the consumer workspace to
deliver the assets described in item 1 above, through any of three equivalent surfaces:

- **CLI**: `scripts/dev_tools/push_down_copilot_customizations.py`,
  `scripts/dev_tools/push_down_codex_and_agents_customizations.py`, or
  `scripts/dev_tools/push_down_claude_customizations.py`.
- **MCP tools**: `push_down_copilot_customizations`,
  `push_down_codex_and_agents_customizations`, and `push_down_claude_customizations`,
  exposed by the same MCP surfaces described in
  [`running-the-workflow.md`](running-the-workflow.md).
- **VS Code commands**: the command-palette entries that wrap the same push-down service
  calls as the MCP tools above.

The maintainer selects the variant that matches the consumer repository's own tooling
(Claude Code, Codex/Agents, or GitHub Copilot), and optionally scopes the push-down to
specific packs (for example a language pack) via `--packs`; the `core` pack placement
described above guarantees the discovery agent personas, skills, and hooks always arrive
regardless of which packs are selected.

## Onboarding Sequence (Generic)

1. The maintainer runs the appropriate push-down tool (CLI, MCP, or VS Code) against the
   consumer workspace. The consumer repository receives the discovery agent personas,
   skills, and completion-gate hooks under its own native `.claude/`, `.codex/`, or
   `.github/` tree.
2. The consumer repository adds `@danmoisan/drm-copilot-mcp` (or an equivalent workspace
   dependency resolving the discovery schemas and templates) so its own tooling can reach
   the discovery schemas and initialization templates.
3. The maintainer points the consumer-repository engineer at
   [`domain-profile.md`](domain-profile.md) to begin authoring the repository's domain
   profile, and at [`workflow.md`](workflow.md) and
   [`running-the-workflow.md`](running-the-workflow.md) to run the workflow end to end.

## Worked Example: Onboarding TaskMaster and TMW

TaskMaster and TMW are the epic's first consumers and appear here strictly as an
illustration of the generic flow above, not as framework behavior:

- **TaskMaster** onboards as the legacy source provider: a maintainer runs the push-down
  tool against the TaskMaster repository, then TaskMaster's engineers author a domain
  profile with `legacy_source.root` pointing at TaskMaster's own codebase.
- **TMW** onboards as the modern target provider: the same push-down flow applies, with
  TMW's domain profile's `target.root` pointing at TMW's own codebase.

No TaskMaster- or TMW-specific behavior is implemented by the push-down tooling, the
mirrored assets, or the discovery workflow itself; both repositories use the identical
generic onboarding sequence described above.
