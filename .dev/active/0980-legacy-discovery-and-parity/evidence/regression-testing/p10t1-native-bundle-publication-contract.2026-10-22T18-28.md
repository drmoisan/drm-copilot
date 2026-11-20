# P10-T1 Native bundle publication contract

Timestamp: 2026-10-22T18-28
Task: [P10-T1] Regenerate the three complete native customization bundles.
Result: PASS

## Regeneration

- Canonical sources: `.github/agents/<role>.agent.md` (four roles), `.github/skills/<name>/SKILL.md` (nine workflows, seven aliases), `.github/hooks` (four handlers, the capability probe and `discovery.json`), `.claude/{agents,skills,hooks,lib,settings.json}`, `.codex/{agents,hooks,config.toml}`, `.agents/skills`, `config/orchestration-routing.json`, and the explicit native adapter mappings of P7-T3 (role-link and tool-identifier rewrites) and P8-T9 (hook and helper classifications, Codex virtual `.codex/lib/discovery-validation` root).
- Claude bundle `extensions/drm-copilot/resources/claude-customizations`: already byte-identical for every distributable `.claude` file and the two bundled config files; the P7-T3 conversion reports zero drift; the core pack manifest lists every discovery hook, helper, role and skill path.
- Codex bundle `extensions/drm-copilot/resources/codex-and-agents-customizations`: already byte-identical for `.codex` and `.agents`; the generated families (`<role>-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4`) report zero drift from `generate_codex_agent_variants --check`; the shared helpers publish from `extensions/drm-copilot/resources/lib/discovery-validation` (eleven modules, exactly the Codex hook import closure; the Claude-only compatibility module is deliberately absent); the core pack manifest lists every hook, helper, role, variant and skill path.
- Copilot bundle `extensions/drm-copilot/resources/customizations`: 28 files published so the five scoped `.github` roots are now complete mirrors, including the new `.github/hooks` root (`discovery-agent-start.ps1`, `discovery-pre-tool.ps1`, `discovery-planning.ps1`, `discovery-agent-stop.ps1`, `discovery-capability-probe.ps1`, `discovery.json`), the four role agents, the sixteen skills, and two files (`mermaid.instructions.md`, `execute-hard-lock.prompt.md`) that the bundle had never carried. No bundle file lacks a canonical source.

## Proof

- New `tests/scripts/dev_tools/test_discovery_publication_contracts.py` (32 cases): every scoped `.github` file mirrors byte-for-byte with no orphans; each role is published as a Copilot agent, a Claude persona and a Codex base plus its five variants, with the Claude tool list equal to the canonical Copilot tool list, every operation a registered drm-copilot MCP tool (`repo-automation-tool-names.ts`), the same identifiers present in the Codex base, no `Write(` grant, and no source-ecosystem or consumer-specific text; each role and handler is registered by `.claude/settings.json`, `.codex/config.toml` and `.github/hooks/discovery.json`; each of the sixteen skills mirrors on all three hosts, workflows route to their host's role file, aliases dispatch only to canonical workflows, and no `.github/`, `drmcopilotextension`, `.agent.md`, `.claude/` (Codex) or consumer name leaks; the Claude hooks and all twelve helpers, the Codex hooks and the eleven shared helpers, and the six GitHub hook files are mirrored and listed by their manifests; every generated role, variant and skill path is in its core manifest.
- Set K: `legacy-discovery-agent-roles.Tests.ps1` and `test_legacy_discovery_skills_contracts.py`; Set L: the seven Codex routing Python suites and the five `codex-routing` Pester suites plus `Resolve-CodexRouting.Parity.Tests.ps1`; the five named push-down suites, `test_skill_bundle_contract_repo.py`, `test_claude_rules_frontmatter.py`, the manifest closure and dependency-scan contracts and the Copilot publisher suites; generator check mode for the conversion and the variant families.

## Gates

- Python 437 passed (new test: black unchanged, ruff clean, pyright 0 errors); Pester 328/328; PoshQC analyze clean on the published hook copies; Jest 7 suites / 50 tests over the bundle-reading suites; conversion and variant generators report zero drift after regeneration. Changed files: one new test (under 500 lines) and 28 published bundle files; no production code changed.

## Carried notes

- No dependency-cruiser configuration exists in this repository, so the "native architecture/dependency contracts" named by the task resolve to the Python pack-manifest dependency closure and scan suites, which pass.
- The Copilot bundle is a committed snapshot with no generator in the repository; the SCRATCH regeneration script mirrors the publisher's `ROOT_FOLDERS`, and the new contract test now pins the mirror so future `.github` changes under those roots must be republished.
- The Claude bundle carries seed `.claude/agent-memory` files for the orchestrator and epic-orchestrator that have no root counterpart in the distributable filter; they are the existing memory-mode payload and are left unchanged.
