<!-- markdownlint-disable-file -->

# Task Research Notes: Issue #306 Codex Agent Role Config and Codex CLI Resolution

## Research Executed

### File Analysis

- `.github/agents/task-researcher.agent.md`
  - Verified the task-researcher role is research-only and requires a structured artifact with verified findings only.
- `docs/features/active/2026-07-04-codex-agent-role-config-306/issue.md`
  - Verified issue #306 reports two failures: malformed generated `.codex/agents/orchestrator.toml` and `drm-copilot: New Codex Worktree Session` failure to resolve Codex CLI.
- `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md`
  - Verified intended behavior, disallowed role TOML sections, tests to add, validation commands, and acceptance criteria.
- `.codex/agents/orchestrator.toml`
  - Verified the active root role file contains `[mcp_servers.drm-copilot] enabled = true` and map-style `[skills.config]` entries.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
  - Verified the bundled generated source has the same malformed role-local MCP and map-style skills shape at lines 136-149.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`
  - Verified the full `drm-copilot` MCP transport already lives in the correct config file with `command = "npx"`, `args = ["-y", "@danmoisan/drm-copilot-mcp"]`, and `required = true`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
  - Verified `.codex/agents/orchestrator.toml` is part of the core pushed-down payload.
- `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
  - Verified the publisher copies `.codex` and `.agents` roots and uses a passthrough rewrite, so the bundled TOML file is the source of generated worktree content.
- `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts`
  - Verified `pushDownCodexAndAgentsCustomizationsServiceCall` resolves the bundle root to `resources/codex-and-agents-customizations`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`
  - Verified the worktree session post script copies `.codex` and `.agents` from the source root to the new worktree; it does not transform TOML.
- `extensions/drm-copilot/src/extension.ts`
  - Verified command `drmCopilotExtension.newCodexWorktreeSession` reads `codexExecutablePath`, calls `resolveCodexExecutable`, and passes the result to `buildCodexWorktreeSessionCommands`.
- `extensions/drm-copilot/src/command-runtime.ts`
  - Verified `resolveCodexExecutable` currently supports configured path, configured command name, and default `codex` on PATH/PATHEXT only.
- `C:/Users/DanMoisan/.vscode-insiders/extensions/openai.chatgpt-26.5623.101652-win32-x64/package.json`
  - Verified the installed extension identity is `publisher = openai`, `name = chatgpt`, and display name is Codex/OpenAI coding agent.
- `C:/Users/DanMoisan/.vscode-insiders/extensions/openai.chatgpt-26.5623.101652-win32-x64/bin/windows-x86_64/codex.exe`
  - Verified a local bundled Windows Codex executable exists in the installed VS Code Insiders extension package.
- `.github/instructions/general-code-change.instructions.md`
  - Verified final implementation must run format, lint, type-check, and test in one passing loop.
- `.github/instructions/general-unit-test.instructions.md`
  - Verified repository-wide coverage must remain `>= 80%` and tests must avoid external dependencies.
- `.github/instructions/typescript-code-change.instructions.md`
  - Verified TypeScript commands are `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit`.
- `.github/instructions/powershell-code-change.instructions.md`
  - Verified PowerShell validation uses PoshQC formatter, analyzer, and Pester test tooling through repository-approved commands or MCP equivalents.

### Code Search Results

- `orchestrator.toml`
  - Found active root role file, bundled role file, and core pack manifest ownership.
- `newCodexWorktreeSession`
  - Found command registration in `extensions/drm-copilot/src/extension.ts` and existing Jest coverage in `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`.
- `resolveCodexExecutable`
  - Found resolver implementation in `extensions/drm-copilot/src/command-runtime.ts` and current resolver tests in `extensions/drm-copilot/test/extension.test.ts`.
- `codex-and-agents-customizations`
  - Found push-down service ownership in `extensions/drm-copilot/src/lib/push-down/*.ts`, MCP handler routing, package command registration, and existing push-down Jest tests.

### External Research

- #githubRepo:"microsoft/vscode vscode.d.ts Extension extensionPath extensionUri"
  - Search located the upstream VS Code API source path and confirmed the official API reference is compiled from `vscode.d.ts`.
- #fetch:https://code.visualstudio.com/api/references/vscode-api
  - Verified VS Code exposes `Extension.extensionPath`, `Extension.extensionUri`, `ExtensionContext.extension`, `ExtensionContext.extensionPath`, `ExtensionContext.extensionUri`, and `ExtensionContext.asAbsolutePath(relativePath)`. These APIs support installed-extension resource discovery without hardcoding user profile extension directories.
- #fetch:https://developers.openai.com/codex/config-reference
  - Verified current Codex config reference documents `skills.config` as an `array<object>` with per-entry `enabled` and `path` fields, and confirms map-style `[skills.config]` is not the documented current shape.

### Project Conventions

- Standards referenced: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Instructions followed: research-only constraint, no implementation file changes, artifact written under `artifacts/research/`, evidence paths not used because this artifact is research rather than baseline, regression, or QA evidence.

## Key Discoveries

### Project Structure

The generated `.codex/agents/orchestrator.toml` is owned by the checked-in Codex customization payload:

- Bundle source: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
- Active root copy: `.codex/agents/orchestrator.toml`
- Inclusion point: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- Publisher: `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
- Service entry: `extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts`
- First-run worktree copy path: `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1`

### Implementation Patterns

The Codex/agents publisher intentionally uses passthrough rewriting, so fixing the generated role file should happen in the checked-in TOML source rather than through a runtime string rewrite. The worktree-session command already resolves PowerShell before terminal creation and resolves Codex before building terminal commands, so the executable fallback belongs in `resolveCodexExecutable` or a small helper called by it.

### Complete Examples

```toml
[skills]
config = [
    { name = "policy-compliance-order", enabled = true },
    { name = "orchestrate", enabled = true },
    { name = "orchestrator-workflow", enabled = true },
]
```

```typescript
// Existing call site that should continue receiving a resolved executable path.
const codexExecutablePath = resolveCodexExecutable(configuredCodexExecutablePath);
```

### API and Schema Documentation

VS Code provides extension resource-location APIs through the extension context and installed extension objects. The local installed OpenAI extension package was verified at `C:/Users/DanMoisan/.vscode-insiders/extensions/openai.chatgpt-26.5623.101652-win32-x64`, with the Windows executable at `bin/windows-x86_64/codex.exe`.

The current public Codex config reference documents `skills.config` as an array of objects. The feature spec for issue #306 requires the role-file shape `config = [{ name = "...", enabled = true }, ...]`. Implementation should validate against the installed Codex CLI behavior with `codex doctor --json`; if `name` versus `path` differs in the installed CLI, update the feature spec or implementation contract before merging.

### Configuration Examples

```toml
[mcp_servers.drm-copilot]
command = "npx"
args = ["-y", "@danmoisan/drm-copilot-mcp"]
required = true
```

### Technical Requirements

**Mandatory unachievable objective callout**:
- No required objective was proven unachievable. One schema detail remains validation-sensitive: the issue spec says skill entries use `name`, while the current public Codex config reference documents `path`. The implementation gate should be the installed Codex CLI parser output from `codex doctor --json`.

## Recommended Approach

Use source-owned corrections plus resolver fallback.

1. Update both role TOML copies:
   - `.codex/agents/orchestrator.toml`
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
2. Remove role-local `[mcp_servers.drm-copilot]` from those role files. Keep the full MCP transport only in:
   - `.codex/config.toml`
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`
3. Replace map-style `[skills.config]` with a `[skills]` table whose `config` value is a sequence of enabled skill objects, then validate with the installed Codex CLI.
4. Extend `extensions/drm-copilot/src/command-runtime.ts` so blank configuration resolves in this order:
   - PATH/PATHEXT `codex`
   - installed VS Code extension package candidate path, using VS Code extension APIs or explicit candidate roots passed from `extension.ts`
   - existing explicit failure message
5. Update `extensions/drm-copilot/src/extension.ts` only if the resolver needs `ExtensionContext.extensionPath`, `vscode.extensions.getExtension("openai.chatgpt")`, or candidate extension roots injected from the activation context.

Rejected alternatives:
- Post-copy TOML patching in `post-codex-worktree-session.ps1`: rejected because the push-down system already owns the source payload and uses passthrough copying.
- User-only workaround through `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath`: rejected because issue #306 requires default resolution from the installed extension package.
- Moving full MCP transport into the role file: rejected because `.codex/config.toml` already owns the full transport and the role-local partial table produces `invalid transport`.

## Implementation Guidance

- **Objectives**: Correct the source-owned Codex role payload, preserve MCP transport ownership in config files, and make the VS Code command resolve the bundled Codex executable when PATH lacks `codex`.
- **Key Tasks**:
  - Edit `.codex/agents/orchestrator.toml` and the bundled `orchestrator.toml`.
  - Add deterministic TOML contract tests for active root and bundled role files.
  - Add resolver tests for installed OpenAI/Codex extension package fallback.
  - Update command-handler tests to prove `newCodexWorktreeSession` launches the resolved package executable and still fails before terminal creation when all candidates are absent.
- **Dependencies**:
  - Existing TypeScript test harness in `extensions/drm-copilot/test/extension-test-harness.ts` must mock any added VS Code extension-discovery API.
  - Existing in-memory push-down tests can assert payload ownership without creating temporary files.
- **Tests to Update**:
  - `extensions/drm-copilot/test/extension.test.ts`
  - `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
  - `extensions/drm-copilot/test/extension-test-harness.ts`
  - `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`
  - `extensions/drm-copilot/test/repo-automation-service.push-down-codex.test.ts`
  - `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`
  - `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
  - `tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1` only if implementation changes copy planning or first-run script behavior.
- **Validation Commands**:
  - `Push-Location extensions/drm-copilot; npm run format; npm run lint; npm run typecheck; npm test; Pop-Location`
  - `pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
  - `pwsh -NoProfile -File extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/post-codex-worktree-session.ps1 -SourceRoot <source-root> -WorktreeRoot <fresh-worktree>`
  - `& "C:/Users/DanMoisan/.vscode-insiders/extensions/openai.chatgpt-26.5623.101652-win32-x64/bin/windows-x86_64/codex.exe" doctor --json`
  - Confirm `codex doctor --json` has no warnings containing `invalid transport`, `invalid type: map, expected a sequence`, `expected struct BundledSkillsConfig`, `invalid type: map, expected a boolean`, or `missing field enabled`.
- **Success Criteria**:
  - Source and bundled role files remain schema-valid and in parity.
  - New worktree push-down copies the corrected role file without runtime patching.
  - Command tests prove bundled executable fallback is used when PATH lacks `codex`.
  - Existing configured-path and PATH resolution tests continue to pass.
  - Full toolchain completes in the required order with no regressions.
