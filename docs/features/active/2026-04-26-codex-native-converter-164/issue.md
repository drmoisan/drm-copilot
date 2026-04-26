# codex-native-converter (Issue #164)

- Date captured: 2026-04-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-native-converter/ (Issue #164)

- Issue: #164
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/164
- Last Updated: 2026-04-26
- Work Mode: full-feature

## Problem / Why

This repository now has a clear Codex-native runtime shape: persistent instructions live in `AGENTS.md`, reusable workflow skills live under `.agents/skills`, subagents live under `.codex/agents`, runtime configuration and MCP bindings live under `.codex/config.toml`, and hard enforcement belongs in native Codex hooks, rules, approval policy, and required MCP configuration. This repository also uses `.codex/prompts` as a launcher surface by convention. However, migration from other agent ecosystems is still largely manual. Existing structures from sources such as legacy Copilot `.github` assets or Claude-oriented layouts need file-by-file interpretation, repeated concept mapping, and careful rewriting of host/tool references.

That manual conversion is slow and inconsistent. It also creates avoidable duplication risk because the same source material can be translated differently across runs or by different contributors. A native Codex conversion skill would provide a deterministic way to ingest an external agentic structure, classify each artifact by role, and emit the corresponding Codex-native form while preserving the original workflow intent.

## Proposed Behavior

Create a Codex-native converter that accepts an input source tree or selected source files from another agent ecosystem and converts them into the repository's Codex-native layout.

At a high level, the skill should:

1. Inspect the source structure and classify each source artifact into a deterministic conversion class such as `direct`, `decomposed`, `repo-convention`, or `unsupported`, rather than performing a literal rename-and-copy migration.
2. Identify artifact roles such as standing instructions, reusable skills, user-invocable prompts or launchers, bounded worker agents, orchestration entrypoints, host-specific automation bindings, hook enforcement, shell-policy enforcement, and MCP dependency declarations.
3. Map those roles into the repository's preferred Codex-native targets:
   - persistent standing guidance becomes `AGENTS.md`;
   - reusable workflow guidance becomes `.agents/skills/<skill-name>/SKILL.md`;
   - bounded delegation roles become `.codex/agents/*.toml`;
   - runtime configuration, MCP bindings, approval policy, and hook registration become `.codex/config.toml` and related `.codex` runtime assets;
   - shell execution policy becomes `.codex/rules/*.rules`;
   - lightweight launch prompts may become `.codex/prompts/*.md` only when the repository-specific prompt surface is intentionally selected.
4. Rewrite supported host-specific automation references toward semantic MCP usage through the `drmCopilotExtension` server when that mapping is defined, instead of carrying forward raw VS Code command IDs or references to repository-local scripts.
5. Generate converted files with minimal duplication, preserving reusable content in shared skills instead of flattening the same rules into multiple agents or prompts.
6. Produce a conversion report that records:
   - source files examined;
   - output files created or proposed;
   - conversion class applied to each source artifact;
   - mappings applied;
   - rewrite actions taken;
   - validation failures; and
   - items that could not be converted safely without human review.
7. Support a review-first mode that produces a proposed mapping/report without writing files, plus an apply mode that writes the converted Codex-native assets into the workspace.

Initial support should explicitly prioritize ecosystems already relevant to this repository's research and migration work:

- GitHub Copilot artifacts such as `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `.github/skills/*`, `.github/agents/*`, and prompt launchers;
- Claude-oriented artifacts such as `CLAUDE.md`, `.claude/skills/*`, `.claude/agents/*`, `.claude/hooks/*`, `.claude/settings.json`, and `.claude/rules/*`.

The design should remain extensible so additional ecosystems can be added later without changing the core conversion contract, but unsupported mappings must be reported explicitly rather than synthesized.

## Acceptance Criteria

- [ ] The converter can analyze supported GitHub Copilot and Claude source structures and classify each input artifact into a deterministic conversion class (`direct`, `decomposed`, `repo-convention`, or `unsupported`) plus a concrete target role such as standing instruction, reusable skill, worker agent, launcher prompt, MCP dependency, hook, shell-policy rule, or host adapter
- [ ] The converter emits Codex-native outputs only into approved Codex-native surfaces such as `AGENTS.md`, `.agents/skills/**`, `.codex/agents/**`, `.codex/config.toml`, `.codex/hooks/**` or inline hooks, `.codex/rules/**`, and repository-specific `.codex/prompts/**` when that output mode is enabled, without flattening shared guidance into duplicated copies across multiple outputs
- [ ] When a supported host-specific automation mapping exists, the converter rewrites it toward the repository's preferred semantic MCP usage model on server `drmCopilotExtension`; converted outputs do not retain raw `drmCopilotExtension.*` command IDs, `.github` references, `.claude` references, `CLAUDE.md` references, or repository-local script references where a native Codex or MCP target exists
- [ ] The converter produces deterministic review artifacts that include at minimum `conversion-report.md`, `mapping-catalog.json`, `validation-results.json`, and a reviewable `proposed-tree/` snapshot of generated outputs
- [ ] The converter supports a non-mutating review mode and a mutating apply mode; apply mode requires an explicit destination root and fails closed when required inputs are missing, the source layout is unsupported, a hard-gate mapping has no native enforcement equivalent, or an MCP rewrite cannot be resolved safely
- [ ] Hard gates from source ecosystems are converted only to equally strict Codex-native enforcement mechanisms such as approval policy, `.codex/rules/*.rules`, `PermissionRequest` or `Stop` hooks, required MCP server configuration, or other verified native controls; the converter must not downgrade a hard gate into advisory text
- [ ] At least one end-to-end GitHub Copilot fixture and one end-to-end Claude fixture convert successfully into reviewable Codex-native outputs, and unsupported constructs are surfaced explicitly rather than silently dropped

## Constraints & Risks

- Conversion accuracy matters more than breadth. A narrower first version that handles a few supported ecosystems well is preferable to a broad converter that produces ambiguous or low-confidence output.
- Not every foreign concept will have a one-to-one Codex-native equivalent. The converter needs explicit fallback behavior for unsupported constructs instead of inventing unsafe mappings.
- The repository already defines anti-duplication rules for skills and agents. The converter must preserve those rules and avoid copying the same guidance into multiple generated files.
- Host-specific commands from other ecosystems may not map cleanly to this repository's preferred `drmCopilotExtension` MCP surface. Those rewrites need a maintained mapping catalog and clear reporting when no safe translation exists.
- Orchestration models differ across ecosystems. For example, nested delegation assumptions in one ecosystem may not be valid in another. The converter must account for those runtime differences instead of performing a literal syntax rewrite.
- Codex shell rules are execution-policy files, not a Markdown instruction substitute, and `PreToolUse` hooks alone are not a complete enforcement boundary. Hard-gate conversion therefore needs a composed enforcement model rather than a single textual rewrite.
- The repository's `.codex/prompts` surface is a repository convention; it should be treated as such in conversion output and reporting rather than presented as a universally portable Codex product contract.
- Scope can expand quickly if the feature attempts to support every external ecosystem at once. The initial contract should name the supported inputs explicitly.

## Test Conditions to Consider

- [ ] Unit coverage for source-artifact classification, target-path selection, reusable-content extraction, rewrite-catalog application, and hard-gate validation logic
- [ ] Integration scenarios that convert a representative legacy `.github` structure and a representative Claude-oriented structure into reviewable Codex-native outputs
- [ ] Dry-run and apply-mode scenarios covering successful conversion, partial conversion with review warnings, hard failure for unsupported or malformed inputs, and fail-closed behavior for unresolved MCP or enforcement mappings
- [ ] CLI and MCP invocation examples showing required inputs, output report shape, destination-root requirements, and expected behavior when a mapping is ambiguous or unavailable

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/codex-native-converter/` folder from the template