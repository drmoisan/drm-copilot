# Consumer Onboarding

This page documents the generic path by which a consumer repository receives the
legacy-discovery-and-parity capability. It describes the onboarding flow independently of
any specific consumer. TaskMaster (the legacy source provider) and TMW (the modern target
provider) appear only in the labeled example section at the end of this page, per the
[domain-neutrality invariant](README.md#domain-neutrality-invariant): they are the epic's
first consumers, not framework behavior.

## What Is Delivered, and How

The capability's assets reach a consumer repository through two different mechanisms,
and the two are not at the same stage of delivery today. Item 1 below is delivered: a
maintainer distributes those assets through the push-down tooling described later on
this page. Item 2 below is not delivered: no consumer-facing distribution mechanism
currently exists for the schemas and initialization templates, as detailed below. A
maintainer onboarding a consumer repository needs to understand both, including the gap
in item 2:

1. **Agent personas, skills, and hooks — pushed down as `.claude`/`.codex`+`.agents` assets.**
   The four discovery agent personas, the seven discovery skills, and the two
   discovery completion-gate hooks are ordinary repository-native `.claude/` assets,
   mirrored byte-identically into `extensions/drm-copilot/resources/` and delivered
   through the existing push-down tooling described below. They are placed in the `core`
   pack-manifest, which is unconditionally included in every `--packs`-scoped push-down —
   a consumer selecting only its own language pack (for example a C# pack or a TypeScript
   pack) still receives the full discovery agent/skill/hook set without a separate opt-in.
2. **Schemas and initialization templates — no consumer-facing distribution mechanism
   today (open gap).** The seven discovery JSON schemas
   (`schemas/discovery/v1/*.schema.json`) and the initialization templates
   (`docs/discovery/templates/`) live under repository-root trees that are outside the
   byte-identical `.claude`/`.codex` mirror contract, and today they exist only inside the
   `drm-copilot` repository itself, at `schemas/discovery/v1/` and
   `docs/discovery/templates/`. No package or tool currently delivers either asset kind to
   a consumer repository: the `@danmoisan/drm-copilot-mcp` npm package does not ship them
   (its packaged contents are limited to the compiled MCP server and a `.claude`/`.codex`
   resource mirror that explicitly excludes every `.py` file and every `scripts/`-segment
   path), and neither `push_down_claude_customizations.py` nor
   `push_down_codex_and_agents_customizations.py` mirrors them either. This absence
   reflects a classification decision, not an oversight:
   `legacy-discovery-publishing-372`'s spec.md, section "Schema/Init-Template Placement —
   Resolved," documents `Decision: scripts-non-mirrored`, classifying these two asset
   kinds as outside the byte-identical mirror contract. That decision explains why the
   assets are not pushed down; it does not itself deliver a distribution mechanism, and no
   feature in the merged epic has implemented one. Closing this gap is an open, planned
   item, not delivered behavior.

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
2. There is currently no automated step by which the consumer repository receives the
   discovery schemas and initialization templates — see item 2 of "What Is Delivered, and
   How" above for the gap and its status. Until a distribution mechanism is delivered, an
   engineer retrieves the seven schemas and the initialization templates manually from the
   `drm-copilot` repository, at `schemas/discovery/v1/` and `docs/discovery/templates/`.
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
