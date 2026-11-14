# Remediation cycle 2 — registration-consumer sweep (class of finding F2) ([P0-T5])

Timestamp: 2026-11-14T08-49
Command: git -C <worktree root> grep -n -E "PreToolUse|settings\.json|config\.toml|pretooluse-dispatch" -- ':!docs/' ':!tests/' ':!.claude/lib/' ':!.claude/hooks/' ':!.codex/hooks/' ':!scripts/' ':!extensions/drm-copilot/resources/claude-customizations/.claude/lib/' ':!extensions/drm-copilot/resources/claude-customizations/.claude/hooks/' ':!extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/' ':!extensions/drm-copilot/resources/**/scripts/' ':!extensions/drm-copilot/resources/**/tests/'
EXIT_CODE: 0
Output Summary: One consumer found: collectRegisteredHookClosure in extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts, assigned to [P1-T2]. No other consumer; [P1-T4] takes its skip branch (no further consumer). Markdown hits: 94 files, 298 lines, all prose.

## Trees searched

Every tracked file at the cycle-start head except docs/ and the five trees approved [P0-T2] (c) already covered (tests/, .claude/lib/, .claude/hooks/, .codex/hooks/, scripts/) and their bundle mirrors. This includes extensions/drm-copilot/src, extensions/drm-copilot/test, extensions/drm-copilot/resources (outside the mirrors), packages/, .github/, .codex/ (outside hooks/), .agents/, .claude/ (outside lib/ and hooks/), config/, .devcontainer/, examples/, schemas/ and root files. Root tests/unit/ falls under the excluded tests/ tree; no tracked root src/ exists.

Tokens: PreToolUse, settings.json, config.toml, pretooluse-dispatch.

## Code and test hits

| File (hits) | Class | Reason |
|---|---|---|
| extensions/drm-copilot/test/lib/push-down/real-bundle-filesystem.test-helpers.ts (collectRegisteredHookClosure) | consumer | Parses hook command paths from the bundle .codex/config.toml to decide the required published hook set; ignores the registry. Re-target in [P1-T2]: add the registryHookPaths result of the bundle .codex/hooks/pretooluse-dispatch.json as closure roots. Asserting test: codex-bundle-publish.integration.test.ts "publishes every registered hook and its dot-source closure in typescript pack mode" (updated by [P1-T3]); the helper has no other importer. |
| extensions/drm-copilot/src/codex-worktree-session.ts; test/codex-worktree-session.test.ts; test/codex-worktree-session-command.test.ts | unaffected | Reference the user-home ~/.codex/config.toml path; no hook enumeration. |
| extensions/drm-copilot/src/discovery-authorization.ts, discovery-authorization-binding.ts, discovery-root-grant.ts, discovery-sentinel.ts, mcp-discovery-authorization-gate.ts, lib/validate/parallel-orchestrator-state-cohort-barrier.ts; test/discovery-grant-test-support.ts | unaffected | Comment or prose mentioning PreToolUse adapters. |
| extensions/drm-copilot/src/lib/codex-native-converter/classifier-claude.ts, inventory.ts, mapping.ts, rewrites-rules.ts and their tests (classifier, inventory, mapping, rewrites, validation) | unaffected | Whole-file classification, path mapping and text rewrite of settings.json to config.toml; no PreToolUse block parsed. |
| extensions/drm-copilot/test/lib/push-down/blast-radius-derive*.test.ts, claude-customizations.test.ts, claude-filesystem-adapter.test.ts, codex-agents-customizations.test.ts, codex-pack-selection.test.ts, config-carriage.test-helpers.ts, push-down-service-call.test.ts, repo-automation-service.push-down-codex.test.ts | unaffected | Fixtures that build their own settings or config text, or path lists for whole-file copy and merge. |
| extensions/drm-copilot/test/packaging/discovery-resources.test.ts, mcp-server-prepack.test.ts | unaffected | Packaged-resource path lists (whole-file presence). |
| .github/hooks/discovery*.ps1, discovery.json and bundle copies under extensions/drm-copilot/resources/customizations/.github/hooks/ | unaffected | Copilot .github/hooks runtime. |
| extensions/drm-copilot/resources/lib/discovery-validation/*.psm1 | unaffected | Mirror of .claude/lib/discovery-validation (a tree cycle 1 covered); DiscoveryCapability.psm1 already reads the registry through Add-DiscoveryDispatchRegistryEntry; the other modules mention PreToolUse in prose or build envelopes. |
| .claude/settings.json, .codex/config.toml and bundle copies | unaffected | The registration files themselves, not readers. |
| extensions/drm-copilot/resources/*/pack-manifests/core.json, config/blast-radius.json (and bundle copy), config/poshqc-shard-weights.json, quality-tiers.yml | unaffected | Path lists and weights (whole-file inclusion), not hook parsing. |
| .codex/agents/*.toml and bundle copies, .codex-variants csharp-legacy role | unaffected | Prose in agent instructions. |
| .devcontainer/codespaces/Dockerfile, .devcontainer/local/Dockerfile | unaffected | Write /etc/codex/config.toml update settings; no hook data. |
| .gitignore | unaffected | .vscode/settings.json.bak ignore pattern. |
| packages/discovery-runtime/.../analyzer/configuration.py | unaffected | Generic settings.json name recognition for discovery analysis. |
| packages/discovery-runtime/.../_resources/schemas/*.json, schemas/discovery/v2/*.json, examples/** | unaffected | Schema or example prose mentioning PreToolUse adapters or settings.json names. |
| .cache/schemas/<schemastore settings schema>.json, testResults.xml | unaffected | Cached JSON schema and a test-result file; no code reads them for hook sets. |

## Markdown hits

94 Markdown files, 298 matching lines, classed as prose (counted per file by git grep -c).

## Consumers and assignment

- collectRegisteredHookClosure — [P1-T2].
- No other consumer; [P1-T4] skip branch applies.
