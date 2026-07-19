# Phase 0 — Current Wording Capture (Remediation Cycle 1)

Timestamp: 2026-07-19T07-51
Command: Get-Content -Path docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md
EXIT_CODE: 0

Output Summary:

## Passage 1 — "What Is Delivered, and How" section, item 2 (lines 10-36)

```
10  ## What Is Delivered, and How
11
12  The capability's assets are distributed to a consumer repository through two different
13  mechanisms, depending on the asset's kind. A maintainer onboarding a consumer repository
14  needs both, not just one:
15
16  1. **Agent personas, skills, and hooks — pushed down as `.claude`/`.codex`+`.agents` assets.**
17     The four discovery agent personas, the seven discovery skills, and the two
18     discovery completion-gate hooks are ordinary repository-native `.claude/` assets,
19     mirrored byte-identically into `extensions/drm-copilot/resources/` and delivered
20     through the existing push-down tooling described below. They are placed in the `core`
21     pack-manifest, which is unconditionally included in every `--packs`-scoped push-down —
22     a consumer selecting only its own language pack (for example a C# pack or a TypeScript
23     pack) still receives the full discovery agent/skill/hook set without a separate opt-in.
24  2. **Schemas and initialization templates — distributed as Python package data via the
25     MCP-server npm package, not pushed down.** The seven discovery JSON schemas
26     (`schemas/discovery/v1/*.schema.json`) and the initialization templates
27     (`docs/discovery/templates/`) live under repository-root trees that are outside the
28     byte-identical `.claude`/`.codex` mirror contract. They reach a consumer repository as
29     Python source/data through the `@danmoisan/drm-copilot-mcp` npm package (the same
30     package that exposes the MCP tools in [`running-the-workflow.md`](running-the-workflow.md)),
31     not through `push_down_claude_customizations.py` or
32     `push_down_codex_and_agents_customizations.py`. This is a deliberate scope boundary, not
33     an omission: an asset under `scripts/` or `docs/discovery/templates/` is Python source
34     the consumer's own toolchain resolves at runtime, not a customization asset the push-down
35     publishers mirror.
36
```

## Passage 2 — Onboarding Sequence step 2 (lines 58-66)

```
58  ## Onboarding Sequence (Generic)
59
60  1. The maintainer runs the appropriate push-down tool (CLI, MCP, or VS Code) against the
61     consumer workspace. The consumer repository receives the discovery agent personas,
62     skills, and completion-gate hooks under its own native `.claude/`, `.codex/`, or
63     `.github/` tree.
64  2. The consumer repository adds `@danmoisan/drm-copilot-mcp` (or an equivalent workspace
65     dependency resolving the discovery schemas and templates) so its own tooling can reach
66     the discovery schemas and initialization templates.
```

Both passages were verified byte-for-byte against the on-disk file content at capture time via
`sed -n` cross-checks in addition to `Get-Content`. Line numbers match exactly. This artifact
serves as the pre-edit baseline for the Phase 1 rewrite.