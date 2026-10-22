# Maintainer Guide

This page is for maintainers of the framework repository. It names the canonical sources,
the generated outputs, the commands that regenerate them and the tests that pin them.
Consumers do not need it.

## Canonical sources and generated outputs

| Canonical | Generated | Rule |
|---|---|---|
| `.github/agents/<role>.agent.md` (four roles) | `.claude/agents/<role>.md`; `.codex/agents/<role>.toml` and the `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` variants | Copilot tool identifiers `drmcopilotextension/<op>` become `"mcp__drm-copilot__<op>"`; the body is verbatim; the Codex base embeds the persona with the migration preamble; variants come from `scripts/dev_tools/generate_codex_agent_variants.py`. |
| `.github/skills/<name>/SKILL.md` (nine workflows, seven aliases) | `.claude/skills/<name>/SKILL.md`; `.agents/skills/<name>/SKILL.md` | Role links `../../agents/<role>.agent.md` become `../../../.claude/agents/<role>.md` or `../../../.codex/agents/<role>.toml`; the body is verbatim and must contain no `.github/`, `drmcopilotextension` or `.agent.md` text. |
| `.claude/hooks/*discovery*.ps1`, `.claude/lib/discovery-validation/*.psm1` | Claude bundle mirrors; the eleven shared helpers also publish to `extensions/drm-copilot/resources/lib/discovery-validation` (the Codex virtual `.codex/lib`). | Byte-identical copies; `DiscoveryValidation.psm1` is Claude-only. |
| `.codex/hooks/*discovery*.ps1`, `.codex/config.toml`, `.agents/**` | Codex bundle `extensions/drm-copilot/resources/codex-and-agents-customizations` | Byte-identical copies. |
| `.github/{agents,hooks,instructions,prompts,skills}` | Copilot bundle `extensions/drm-copilot/resources/customizations/.github` | Byte-identical copies of the five scoped roots. |
| `schemas/discovery/v1`, `schemas/discovery/v2`, `docs/discovery/templates/v2` | `packages/discovery-runtime/src/drm_copilot_discovery/_resources/` and `manifest.json` | Allowlisted in `packages/discovery-runtime/resource-manifest.json`; staged with a sorted SHA-256 manifest. |
| `config/orchestration-routing.json` | `extensions/drm-copilot/resources/config/` and the Claude bundle `config/` | Byte-identical copy; the bundled `config/blast-radius.json` is a derived destination-portable document, not a copy. |

## Regenerating

1. Edit the canonical source only.
2. Apply the conversion rules above to produce the Claude and Codex outputs, then run
   `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` (`--check`
   reports drift) to refresh the Codex variants and the Codex core manifest rows.
3. Mirror the changed files byte-for-byte into the three bundles and add any new path to
   the bundle's `pack-manifests/core.json`.
4. Run the pinning tests: `tests/scripts/dev_tools/test_discovery_publication_contracts.py`
   (every role, skill, hook, helper and manifest row on every host),
   `test_legacy_discovery_skills_contracts.py`, `test_push_down_claude_resource_contracts.py`,
   `test_push_down_codex_and_agents_resource_contracts.py`, the two pack-manifest
   completeness suites, `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1`
   and `tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1`. A failing
   mirror assertion names the stale path.

## Building the wheel

```text
poetry run python -m scripts.dev_tools.build_discovery_runtime --check
poetry run python -m scripts.dev_tools.build_discovery_runtime --stage-only
poetry run python -m scripts.dev_tools.build_discovery_runtime
```

The builder verifies the allowlisted inputs, resolves every schema reference offline,
checks the runtime import closure against the four declared dependencies, refreshes
`_resources/` and `_build_manifest.json`, and builds
`dist/discovery/drm_copilot_discovery-<version>-py3-none-any.whl` with the poetry-core
backend and no network. Adding a schema or template means adding it to
`resource-manifest.json`; the builder rejects unlisted inputs and undeclared staged files.
`packages/discovery-runtime/README.md` documents the package itself.

## Building the host packages

- Extension: `npm run compile` in `extensions/drm-copilot`, then `npx --yes @vscode/vsce
  package --allow-missing-repository --skip-license --out <file>`; `.vscodeignore` excludes
  sources, tests, tooling, `**/*.py` and `resources/scripts/**`.
- Standalone MCP server: `npm run build` then `npm pack` in `packages/mcp-server`;
  `prepack.cjs` copies the extension resources except Python files and the root `scripts`
  tree. `tests/packaging/discovery-resources.test.ts` and `mcp-server-prepack.test.ts` pin
  the allowlists, the shared server entry, the absence of the VS Code host module and the
  explicit wheel requirement.

## Hooks and helpers

- A hook imports every helper through a guarded, statically resolvable `Import-Module`
  edge, returns the dependency decision first in its decision function, and invokes no
  Python; `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` and
  `enforcement-hooks-no-python-invocation.Tests.ps1` enforce the shape, and the Codex
  self-hosting fallback is the recorded Design exemption D4.
- Every hook's `ReasonPrefix` is listed in the host's dependency-failure table
  (`tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`,
  `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`).
- Shared helpers stay under 500 lines; split by component when necessary and update
  `DiscoveryAuthority.psd1`, the manifest suite and both bundles.

## Adding an analyzer

Add the module under `drm_copilot_discovery/analyzer/`, register its identifier in
`analyzer/registry.py` and the profile schema's `analyzers.enabled` enumeration, keep it
read-only and bounded, and cover it in `tests/discovery_runtime/`. Optional adapters that
depend on a platform go under `analyzer/optional/` and are imported only after consent.

## Verification before release

The toolchain loop applies per language (Black, Ruff, Pyright, pytest; Prettier, ESLint,
tsc, Jest; PoshQC format, analyze, Pester). The release records the wheel, VSIX and npm
digests, the generator check results and the capability probe outcome for each host in the
feature evidence; publication is a separate, deliberate step.
