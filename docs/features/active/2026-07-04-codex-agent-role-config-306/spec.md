# codex-agent-role-config (Spec)

- **Issue:** #306
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-04T13-47
- **Status:** Draft
- **Version:** 0.1

## Context
New worktrees can receive a malformed `.codex/agents/orchestrator.toml` role definition that Codex rejects during startup or `codex doctor --json`. The `drm-copilot: New Codex Worktree Session` command can also fail before worktree setup because the extension cannot resolve the Codex CLI executable when `codex` is not available on `PATH`.

Environment:
- OS/version: Windows, VS Code Insiders
- Command/flags used: `drm-copilot: New Codex Worktree Session`; `codex doctor --json`
- Data source or fixture: affected worktree `C:\Users\DanMoisan\repos\TaskMaster-wt-2026-07-04-12-57\.codex\agents\orchestrator.toml`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Run `drm-copilot: New Codex Worktree Session` from VS Code Insiders in a repository that uses the pushed-down Codex customization payload.
2. Inspect the generated `.codex/agents/orchestrator.toml` in the new or affected worktree.
3. Run `codex doctor --json` with the Codex executable from the VS Code extension package.

Expected:
The worktree session command resolves a usable Codex CLI executable, completes bootstrap, and produces a Codex role file that Codex can deserialize without startup warnings.

Actual:
The command reports that the Codex CLI is not found. When an affected worktree role file is present, Codex startup or `codex doctor --json` reports malformed role-definition warnings including `invalid transport`, `invalid type: map, expected a sequence`, `invalid type: string "policy-compliance-order", expected struct BundledSkillsConfig`, `invalid type: map, expected a boolean`, and `missing field enabled`.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.`


## Scope & Non-Goals
- In scope:
  - Correct the root `.codex/agents/orchestrator.toml` role file and the bundled payload copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`.
  - Keep the complete `drm-copilot` MCP transport configuration only in `.codex/config.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`.
  - Update Codex executable resolution for `drmCopilotExtension.newCodexWorktreeSession` so an installed VS Code extension package path can be used when `PATH` does not contain `codex`.
  - Add focused regression tests for the role TOML contract, push-down payload parity, executable discovery, and command launch behavior.
  - Validate the resulting payload with `codex doctor --json` on an affected or fresh worktree.
- Out of scope / non-goals:
  - Reworking orchestration delegation rules, checkpoint semantics, or required skill lists beyond correcting their TOML encoding.
  - Moving repository-specific `.codex` and `.agents` copy logic into the VS Code extension command handler.
  - Changing the MCP server package, tool list, or `@danmoisan/drm-copilot-mcp` transport command.
- Explicitly excluded systems, integrations, or datasets:
  - No changes to GitHub issue templates, unrelated language-pack manifests, or completed feature folders.
  - No `user-story.md` artifact is required because `issue.md` declares `Work Mode: full-bug`.

## Root Cause Analysis
The generated orchestrator role file includes role-local MCP server configuration that belongs in `.codex/config.toml`, and its skills configuration does not match Codex's structured `[skills] config = [{ name = "...", enabled = true }]` shape. The active root role file and bundled role file currently contain `[mcp_servers.drm-copilot] enabled = true` and a map-style `[skills.config]` table, which matches the warning classes in the issue.

The extension executable resolver currently supports configured executable paths, configured command names, and default `codex` resolution through `PATH`/`PATHEXT`. It does not document or test a fallback that discovers the Codex executable from the installed VS Code extension package when `PATH` lacks `codex`.


## Proposed Fix

### Design summary (what changes where):
- Update `.codex/agents/orchestrator.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` to use a Codex-valid role schema:
  - Keep top-level role identity fields such as `name`, `description`, `model_reasoning_effort`, `default_permissions`, and `developer_instructions`.
  - Remove the role-local `[mcp_servers.drm-copilot]` block entirely.
  - Replace the map-style `[skills.config]` table with a `[skills]` table containing `config = [{ name = "<skill>", enabled = true }, ...]`.
- Keep full MCP transport only in `.codex/config.toml` and the bundled `.codex/config.toml`, including `command = "npx"`, `args = ["-y", "@danmoisan/drm-copilot-mcp"]`, `required = true`, `enabled_tools`, and tool-specific approval entries.
- Update `extensions/drm-copilot/src/command-runtime.ts` so `resolveCodexExecutable` can locate a Codex executable from an installed VS Code extension package path when configuration is blank and `PATH` lookup fails.
- Update `extensions/drm-copilot/src/extension.ts` only if needed to pass the VS Code extension context or installed-extension discovery data into the resolver while preserving existing configured-path and PATH behavior.
- Update `extensions/drm-copilot/package.json` configuration description if the default resolution order changes.

### Boundaries and invariants to preserve:
- `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` remains the highest-priority override when configured.
- PATH/PATHEXT resolution remains supported for users with `codex` installed globally.
- The generated terminal command must continue to launch Codex through the PowerShell call operator and must not emit a bare unresolved `codex` command.
- The post-Codex script remains source-root-relative and continues to run after trust setup and before Codex launch.
- The extension must not hardcode repository-specific customization copy behavior.
- The MCP server transport must not be duplicated into any role-local agent TOML file.

### Dependencies or blocked work:
- The exact installed Codex extension package path must be derived from the local VS Code extension installation metadata or extension root discovery at runtime, not from a user-specific absolute path.
- Manual `codex doctor --json` validation requires a usable Codex executable from PATH, configuration, or installed VS Code extension package discovery.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `.codex/agents/orchestrator.toml`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
- `extensions/drm-copilot/src/command-runtime.ts`
- `extensions/drm-copilot/src/extension.ts`, only if the resolver needs VS Code context or extension discovery inputs
- `extensions/drm-copilot/package.json`, only if configuration wording needs to reflect installed-extension fallback behavior
- `extensions/drm-copilot/test/extension.test.ts`
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts`
- `extensions/drm-copilot/test/extension-test-harness.ts`
- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`

#### Functions/classes/CLI commands impacted:
- `resolveCodexExecutable` in `extensions/drm-copilot/src/command-runtime.ts`
- `newCodexWorktreeSession` command registration in `extensions/drm-copilot/src/extension.ts`
- `drm-copilot: New Codex Worktree Session`
- `codex doctor --json` validation against generated `.codex` payloads

#### Data flow and validation changes:
- Role-file data flow:
  1. Source and bundled role TOML files are updated to valid Codex role schema.
  2. `push_down_codex_and_agents_customizations` copies the corrected bundled role file into new worktrees.
  3. Codex reads MCP transport from `.codex/config.toml` and skill enablement from `[skills].config` in the role file.
- Executable data flow:
  1. Use configured `codexExecutablePath` when supplied.
  2. Resolve configured command names or default `codex` through `PATH`/`PATHEXT`.
  3. If no PATH result exists, discover candidate Codex executables in installed VS Code extension package locations and validate that the candidate exists before terminal creation.
  4. Emit the resolved executable path into the terminal command through `buildCodexWorktreeSessionCommands`.

#### Error handling and logging updates:
- Preserve the existing explicit failure message when no configured path, PATH executable, or installed-extension package executable can be resolved.
- If installed-extension discovery is attempted, log concise resolver evidence to the extension output channel or testable resolver return path without logging user secrets.
- If a discovered package path exists but no executable exists under the expected package location, continue probing other candidates before failing.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag is required.
- Rollback is limited to restoring the previous resolver behavior and role payload, but that rollback would reintroduce the `codex doctor --json` warnings and missing executable fallback.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input role TOML:
  - `.codex/agents/orchestrator.toml`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml`
- Required role skills shape:
  ```toml
  [skills]
  config = [
      { name = "policy-compliance-order", enabled = true },
      { name = "orchestrate", enabled = true },
      { name = "orchestrator-workflow", enabled = true },
      { name = "feature-promotion-lifecycle", enabled = true },
      { name = "repo-automation-adapter", enabled = true },
      { name = "atomic-plan-contract", enabled = true },
      { name = "acceptance-criteria-tracking", enabled = true },
      { name = "evidence-and-timestamp-conventions", enabled = true },
      { name = "pr-context-artifacts", enabled = true },
      { name = "pr-base-branch-merge-base", enabled = true },
  ]
  ```
- Disallowed role TOML:
  - `[mcp_servers.drm-copilot]`
  - `command`, `args`, `required`, or full transport settings under `.codex/agents/orchestrator.toml`
  - map-style `[skills.config]` entries such as `orchestrate = true`
- Output:
  - `codex doctor --json` reports no role-definition warnings for `invalid transport`, `invalid type`, or `missing field enabled`.
  - The worktree session terminal launches the resolved executable path instead of a bare `codex`.

#### Required configuration keys and defaults:
- `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath`
  - Default: empty string
  - Resolution order: configured path or command, PATH/PATHEXT fallback, installed VS Code extension package executable fallback, explicit failure.
- `.codex/config.toml`
  - Retains `[mcp_servers.drm-copilot]` with full transport details.
  - Retains `[mcp_servers.drm-copilot.tools.validate_orchestration_artifacts] approval_mode = "approve"`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`
  - Mirrors the root MCP transport configuration required for pushed-down worktrees.

#### Backward-compatibility expectations:
- Existing users with configured `codexExecutablePath` see no behavior change.
- Existing users with `codex` on PATH see no behavior change.
- Users with Codex available only through the installed VS Code extension package can start new Codex worktree sessions without adding Codex to PATH.
- Existing MCP tool allowlist behavior remains controlled by `.codex/config.toml`.

#### Performance constraints (latency/throughput/memory):
- Executable discovery must run before terminal creation and should perform bounded filesystem probes only.
- Discovery must not recursively scan broad user directories.
- Role TOML validation and contract tests must remain deterministic and fast.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The issue source and current repository files provide sufficient information to complete this full-bug spec.
  - The installed VS Code extension package exposes a stable filesystem location that can be discovered from VS Code extension metadata or package root data available to the extension process.
  - Codex accepts `[skills] config = [{ name = "...", enabled = true }]` for role skill enablement.
- Constraints (budget, performance, compatibility):
  - Full-bug mode uses `spec.md` only; no `user-story.md` should be created unless the issue explicitly requires one.
  - Implementation must preserve the generic VS Code extension boundary and keep repository-specific setup in the configured post-Codex script.
  - Tests must not depend on a real installed VS Code extension package or real external network services.
- External dependencies (services, libraries, releases):
  - VS Code extension host APIs for installed-extension/package-path discovery.
  - Local Codex executable used for `codex doctor --json` validation.
  - Existing TypeScript/Jest and Python/Pytest test harnesses.

## Data / API / Config Impact
- User-facing or API changes:
  - `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath` remains optional.
  - The extension may document an additional default fallback to an installed VS Code extension package executable.
- Data or migration considerations:
  - Existing worktrees with malformed `.codex/agents/orchestrator.toml` need the corrected root or bundled payload copied into place.
  - No data migration is required outside `.codex` configuration files.
- Logging/telemetry updates (if any):
  - Resolver diagnostics should identify the resolution category, such as configured path, PATH, installed extension package, or unresolved.
  - Logs must not include environment dumps or unrelated user filesystem paths.
- Compatibility notes (CLI flags, config schemas, versioning):
  - `codex doctor --json` is the required schema validation signal for the corrected role file.
  - `.codex/config.toml` remains the only location for the full MCP server transport.

## Test Strategy
Seeded from issue:

- [x] Update the source or bundled resource that owns `.codex/agents/orchestrator.toml`.
- [x] Add regression coverage for the expected role-file TOML shape.
- [x] Add or update worktree-session executable-resolution coverage for bundled Codex CLI discovery.
- [x] Validate an affected or fresh worktree with `codex doctor --json` and confirm startup warnings are absent.

- Regression tests to add or update:
  - Add Python contract coverage that parses both `.codex/agents/orchestrator.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/orchestrator.toml` and asserts:
    - no `[mcp_servers.*]` table exists in the role file,
    - `[skills].config` is a sequence,
    - every skill entry has `name` and `enabled = true`,
    - root and bundled role files remain byte-identical.
  - Add Python contract coverage that verifies `.codex/config.toml` and bundled `.codex/config.toml` retain the full `drm-copilot` MCP transport.
  - Add Jest coverage for `resolveCodexExecutable` resolving an installed VS Code extension package executable when `PATH` lacks `codex` and `codexExecutablePath` is blank.
  - Add or update command-handler Jest coverage proving `newCodexWorktreeSession` launches the installed-extension Codex path through the PowerShell call operator and still fails before terminal creation when no configured, PATH, or installed-extension executable exists.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`
  - `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Configured executable path is missing: preserve the existing explicit failure.
  - Configured command name is missing from PATH: preserve the existing explicit failure.
  - PATH lacks `codex` and installed-extension package path is absent: fail before terminal creation.
  - Installed-extension package path exists but candidate executable is absent: continue probing and then fail explicitly if no candidate resolves.
  - Role file contains `[skills.config]` or role-local `[mcp_servers.*]`: contract test fails.
- Error handling and logging verification:
  - Verify failure text remains actionable and mentions `drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath`.
  - Verify successful installed-extension fallback does not require a user setting.
- Coverage impact and targets for changed lines/modules:
  - Changed TypeScript resolver and command-handler lines require focused Jest coverage.
  - Changed Python contract tests require deterministic assertions over checked-in files only.
  - Repository coverage must remain at or above the configured 80% floor, and changed modules should be covered by targeted tests.
- Toolchain commands to run (format -> lint -> type-check -> test):
  - `Push-Location extensions/drm-copilot; npm run format; npm run lint; npm run typecheck; npm test; Pop-Location`
  - `pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- Manual validation steps (if required):
  - Create or refresh an affected worktree from the corrected bundled payload.
  - Run `codex doctor --json` using the resolved Codex executable from the installed VS Code extension package.
  - Confirm the JSON output contains no warnings for `invalid transport`, `invalid type: map, expected a sequence`, `expected struct BundledSkillsConfig`, `invalid type: map, expected a boolean`, or `missing field enabled`.


## Acceptance Criteria
- [x] `.codex/agents/orchestrator.toml` and the bundled orchestrator role TOML use a valid Codex role schema with `[skills] config = [{ name = "...", enabled = true }, ...]` entries for every required orchestrator skill.
- [x] The orchestrator role TOML no longer contains any role-local `[mcp_servers.drm-copilot]` block or full MCP transport settings.
- [x] The full `drm-copilot` MCP transport remains only in `.codex/config.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`.
- [x] `drm-copilot: New Codex Worktree Session` resolves a Codex executable from the installed VS Code extension package path when `codexExecutablePath` is blank and PATH/PATHEXT lacks `codex`.
- [x] Existing configured executable path and PATH/PATHEXT resolution behavior remains covered and unchanged.
- [x] Regression tests cover role TOML shape, MCP transport location, pushed-down payload parity, installed-extension Codex executable fallback, and missing-executable failure behavior.
- [x] `codex doctor --json` validation passes on an affected or fresh worktree without the documented role-definition warnings.
- [x] No unintended behavior changes occur outside the defined Codex role config and executable-resolution scope.
- [x] Full toolchain pass completed for changed TypeScript and Python contract-test surfaces.
- [x] Docs/config references updated to match the new resolver behavior and role schema.

## Risks & Mitigations
- Technical or operational risks:
  - VS Code extension package discovery may vary between VS Code Stable, VS Code Insiders, and extension package versions.
  - A role TOML change could correct the orchestrator while leaving other role files with similar schema issues.
  - Manual `codex doctor --json` validation may be skipped if a local Codex executable cannot be resolved.
- Mitigations and rollbacks:
  - Use test doubles for installed-extension discovery and keep filesystem probing bounded.
  - Add contract tests that compare root and bundled role files so pushed-down worktrees receive the same fix.
  - Record the exact `codex doctor --json` command and output in feature evidence during implementation.
  - If additional role files exhibit the same schema issue, classify them as follow-up scope unless they block the orchestrator validation path.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge the corrected root and bundled `.codex` payload.
  - Publish or install the updated VS Code extension package.
  - Re-run `drm-copilot: New Codex Worktree Session` for a fresh worktree and validate with `codex doctor --json`.
- Post-fix monitoring or clean-up tasks:
  - Check issue #306 for any remaining startup warnings from affected worktrees.
  - Consider a follow-up audit for other `.codex/agents/*.toml` files if `codex doctor --json` reports additional schema warnings outside the orchestrator role.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/306
  - Source issue artifact: `docs/features/active/2026-07-04-codex-agent-role-config-306/issue.md`
