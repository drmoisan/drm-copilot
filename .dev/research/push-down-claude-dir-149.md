# Research: pushDownClaudeDir (Issue #149)

- **Timestamp:** 2026-04-16T20-30
- **Feature folder:** `docs/features/active/2026-04-16-push-down-claude-dir-149/`
- **Command:** `drmCopilotExtension.pushDownClaudeDir`
- **MCP tool name:** `push_down_claude_dir`

---

## 1. Analogous Command: `pushDownCodexAndAgentsCustomizations`

This command is the primary reference pattern.

### Registration in `extension.ts`

Lines 149–160:

```
const pushDownCodexAndAgentsCustomizationsDisposable =
  vscode.commands.registerCommand(
    "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    async () => {
      const commandId = "drmCopilotExtension.pushDownCodexAndAgentsCustomizations";
      await service.pushDownCodexAndAgentsCustomizations({
        workspaceRoot: getWorkspaceRoot(),
        invocationId: commandId,
      });
    },
  );
```

The disposable is added to `context.subscriptions.push(...)` at line 428.

This command takes no arguments beyond `workspaceRoot` and `invocationId`. No interactive prompt, no `resolveWorkflowInvocation` call. The new command follows the identical zero-argument pattern.

### Service interface in `repo-automation-service.ts`

Interface declaration at lines 63–65:
```
pushDownCodexAndAgentsCustomizations(
  input: WorkspaceExecutionInput,
): Promise<RepoAutomationExecutionResult>;
```

Implementation at lines 216–232. It calls `this.executeScript(...)` with:
- `tool`: `"push_down_codex_and_agents_customizations"`
- `runtimeKind`: `"python"`
- `bundledRelativePath`: `"resources/templates/push_down_codex_and_agents_customizations.py"`
- `args`: `["--destination", input.workspaceRoot]`
- `summary`: `"Pushed bundled Codex and agents customizations into the destination workspace."`
- `stdoutArtifactPattern`: `/Wrote push-down summary artifact to:\s*(.+)/i`

The `REPO_AUTOMATION_TOOLS` const (lines 22–39) is a `readonly` tuple that all three layers (service, MCP tool definitions, MCP dispatch switch) derive from. A new entry `"push_down_claude_dir"` must be added to this tuple.

### Argument resolver in `workflow-command-arguments.ts`

`pushDownCodexAndAgentsCustomizations` has **no argument resolver function** in `workflow-command-arguments.ts`. Its command handler in `extension.ts` does not call `resolveWorkflowInvocation`. The new command requires the same: no argument resolver is needed.

### Python entry-point template

File: `extensions/drm-copilot/resources/templates/push_down_codex_and_agents_customizations.py`

This thin wrapper:
1. Adds `resources/scripts/` to `sys.path`.
2. Dynamically imports `dev_tools.push_down_codex_and_agents_customizations`.
3. Resolves `customizations_root` to `Path(__file__).resolve().parent.parent / "codex-and-agents-customizations"`.
4. Calls `publish_fn(repo_root=..., destination_root=..., fs=fs_factory(), source_root=..., artifact_root=...)`.
5. Prints `f"Wrote push-down summary artifact to: {summary.artifact_path}"`.

### Dev-tools publisher script

File: `extensions/drm-copilot/resources/scripts/dev_tools/push_down_codex_and_agents_customizations.py`

It delegates to the shared `push_down_customizations` engine in `push_down_copilot_customizations.py`, passing:
- `ROOT_FOLDERS = (Path(".codex"), Path(".agents"))`
- `ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations"`
- A passthrough rewrite function (no reference rewrites needed).

The new `.claude` publisher must follow the same structure with:
- `ROOT_FOLDERS = (Path(".claude"),)`
- `ARTIFACT_DIRECTORY = "artifacts/claude-dir-customizations"`

---

## 2. MCP Tool Surface

### `mcp-tools.ts` — tool definition

Each tool has a `ToolDefinition` entry in the `toolDefinitions` array (lines 55–381). For zero-argument push-down commands, the schema contains only `workspace_root`:

```
{
  name: "push_down_codex_and_agents_customizations",
  description: "Copy the bundled Codex and agents customization payload into the target workspace.",
  inputSchema: {
    type: "object",
    properties: {
      workspace_root: workspaceRootProperty,
    },
    additionalProperties: false,
  },
},
```

The new tool entry follows this exactly, with name `push_down_claude_dir`.

### `mcp-tools.ts` — dispatch

The `dispatchRepoAutomationTool` switch (lines 457–548) has one case per tool name. For `push_down_codex_and_agents_customizations`:

```
case "push_down_codex_and_agents_customizations": {
  const input = resolvePushDownCodexAndAgentsCustomizationsToolInput(rawInput);
  return toMcpToolResult(
    await service.pushDownCodexAndAgentsCustomizations(input),
  );
}
```

A new `case "push_down_claude_dir":` block is required in the same switch.

### `mcp-tool-inputs.ts` — input resolver

`resolvePushDownCodexAndAgentsCustomizationsToolInput` (lines 134–145) is a minimal resolver that extracts only `workspace_root`. Its pattern is identical to `resolvePushDownCopilotCustomizationsToolInput`. A new `resolvePushDownClaudeDirToolInput` function is needed with the same body.

---

## 3. Bundled Resources

### Current resource layout

```
extensions/drm-copilot/resources/
  customizations/              -> .github/ payload (for pushDownCopilotCustomizations)
  codex-and-agents-customizations/  -> .codex/ and .agents/ payload
  templates/                   -> Python/PS1 entry-point scripts
  scripts/dev_tools/           -> shared publisher engine
  feature-templates/           -> feature folder templates
```

### `.claude/` resource directory

No `resources/.claude/` directory currently exists. It must be created at:

```
extensions/drm-copilot/resources/claude-dir-customizations/.claude/
```

The directory name `claude-dir-customizations` follows the `codex-and-agents-customizations` naming convention. The `.claude/` tree to bundle is the entire `C:\Users\DanMoisan\repos\drm-copilot\.claude\` directory, which contains:

```
.claude/
  agents/        (13 .md files: atomic-executor, atomic-planner, csharp-typed-engineer, ...)
  hooks/         (validate-bash.ps1)
  rules/         (csharp.md, powershell.md, python.md, typescript.md)
  settings.json
  settings.local.json   <- must review whether to exclude from bundle
  skills/        (25 subdirectories, each with SKILL.md)
```

**Risk: `settings.local.json` contains user-local overrides.** It should not be bundled; only `settings.json` should be included. This must be confirmed against the feature spec or the author's intent.

**Risk: `agent-memory/` directory** — if it exists at push time it would be in the tree. Currently absent but will be created by this research agent. The bundle copy should exclude `agent-memory/` to avoid shipping ephemeral state.

The dev-tools publisher (the shared engine in `push_down_copilot_customizations.py`) copies all files under `ROOT_FOLDERS` without exclusion filtering. If exclusions are needed (e.g., `settings.local.json`, `agent-memory/`), either the bundle directory must be curated to not contain them, or a filtered root-folder list must be provided.

Cleanest approach: structure the bundle directory to only contain what should be shipped — omit `settings.local.json` and `agent-memory/` from the bundle source directory.

---

## 4. `package.json` — commands section

Current push-down command entries (lines 54–60):

```json
{
  "command": "drmCopilotExtension.pushDownCopilotCustomizations",
  "title": "drm-copilot: Push Down Copilot Customizations"
},
{
  "command": "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
  "title": "drm-copilot: Push Down Codex and Agents Customizations"
},
```

A new entry must be added to the `commands` array:

```json
{
  "command": "drmCopilotExtension.pushDownClaudeDir",
  "title": "drm-copilot: Push Down Claude Dir"
}
```

Position: after `pushDownCodexAndAgentsCustomizations`, consistent with the existing ordering.

---

## 5. Test Patterns

### Registration test

File: `extensions/drm-copilot/test/extension.workflow-commands.test.ts`

The pattern for zero-argument push-down commands is a single registration test:

```typescript
it("registers pushDownCodexAndAgentsCustomizations", () => {
  activateAndGetHandler(
    "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
  );
});
```

A new `it("registers pushDownClaudeDir", ...)` test using `activateAndGetHandler` is the required registration assertion.

### MCP tool list test

File: `extensions/drm-copilot/test/mcp-server.test.ts`, lines 69–90.

The test `"registers the semantic repo automation tools"` asserts an **exact ordered array** of tool names via `toEqual`. Adding `push_down_claude_dir` to the tools tuple in `repo-automation-service.ts` means this test must have `"push_down_claude_dir"` inserted at the corresponding position in that array assertion.

### Mock service

The `createMockService()` function in `mcp-server.test.ts` (lines 17–36) creates a `jest.Mocked<RepoAutomationService>`. Adding `pushDownClaudeDir` to the service interface requires adding `pushDownClaudeDir: jest.fn()` to this mock object.

No test for the script arguments of push-down commands (comparable to `collectCommitContext` spawn argument assertions) exists in the current test files for `pushDownCopilotCustomizations` or `pushDownCodexAndAgentsCustomizations`. The existing practice is to test only registration. However the spec seeds these unit tests:
- Service method copies bundled `.claude/` to workspace root.
- Command handler resolves invocation and calls service method.
- MCP tool schema validates correctly.

---

## 6. Complete File Change Map

| File | Change |
|------|--------|
| `extensions/drm-copilot/resources/claude-dir-customizations/.claude/` | **Create.** Bundle the curated `.claude/` directory tree here (agents, hooks, rules, settings.json, skills). Exclude `settings.local.json` and `agent-memory/`. |
| `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_dir.py` | **Create.** New dev-tools publisher. Import shared engine, set `ROOT_FOLDERS = (Path(".claude"),)` and `ARTIFACT_DIRECTORY = "artifacts/claude-dir-customizations"`. |
| `extensions/drm-copilot/resources/templates/push_down_claude_dir.py` | **Create.** Thin entry-point wrapper that adds `resources/scripts/` to `sys.path`, imports `dev_tools.push_down_claude_dir`, resolves `source_root` to `../claude-dir-customizations`, invokes publisher, prints `Wrote push-down summary artifact to:` line. |
| `extensions/drm-copilot/src/repo-automation-service.ts` | **Modify.** (a) Add `"push_down_claude_dir"` to `REPO_AUTOMATION_TOOLS` const at line 38. (b) Add `pushDownClaudeDir(input: WorkspaceExecutionInput): Promise<RepoAutomationExecutionResult>` to the interface. (c) Implement the method in `DefaultRepoAutomationService` using `executeScript` with `bundledRelativePath: "resources/templates/push_down_claude_dir.py"`. |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | **Modify.** Add `resolvePushDownClaudeDirToolInput` function. |
| `extensions/drm-copilot/src/mcp-tools.ts` | **Modify.** (a) Import `resolvePushDownClaudeDirToolInput`. (b) Add tool definition entry. (c) Add dispatch switch case. |
| `extensions/drm-copilot/src/extension.ts` | **Modify.** (a) Register command `drmCopilotExtension.pushDownClaudeDir`. (b) Add disposable to `context.subscriptions.push`. |
| `extensions/drm-copilot/package.json` | **Modify.** Add command entry `{ "command": "drmCopilotExtension.pushDownClaudeDir", "title": "drm-copilot: Push Down Claude Dir" }`. |
| `extensions/drm-copilot/test/extension.workflow-commands.test.ts` | **Modify.** Add registration test `it("registers pushDownClaudeDir", ...)`. |
| `extensions/drm-copilot/test/mcp-server.test.ts` | **Modify.** (a) Add `pushDownClaudeDir: jest.fn()` to `createMockService()`. (b) Insert `"push_down_claude_dir"` in the tool name array assertion. |

---

## 7. Recommended Implementation Approach

### Recommendation: Direct clone of `pushDownCodexAndAgentsCustomizations`

**Rationale:** The pattern is fully established across five layers (resource directory, dev-tools publisher, template script, service, MCP). The codex-and-agents command is structurally identical to what is needed. No new abstractions, no new dependencies, and no interactive prompts are required.

**Steps in dependency order:**

1. Create `resources/claude-dir-customizations/.claude/` by copying the curated `.claude/` content from the repo root (agents, hooks, rules, settings.json, skills subdirectories). Deliberately omit `settings.local.json` and `agent-memory/`.

2. Create `resources/scripts/dev_tools/push_down_claude_dir.py` using the codex-and-agents publisher as a template. Only `ROOT_FOLDERS`, `ARTIFACT_DIRECTORY`, and module-level strings change.

3. Create `resources/templates/push_down_claude_dir.py` as a thin wrapper, mirroring `push_down_codex_and_agents_customizations.py`. The `customizations_root` path resolves to `../claude-dir-customizations`.

4. Update `repo-automation-service.ts`: add tool name to `REPO_AUTOMATION_TOOLS`, add interface method, implement in class.

5. Update `mcp-tool-inputs.ts`: add input resolver.

6. Update `mcp-tools.ts`: add tool definition and dispatch case, import new resolver.

7. Update `extension.ts`: register command, push disposable to subscriptions.

8. Update `package.json`: add command entry.

9. Update tests: registration test in `extension.workflow-commands.test.ts`; mock and tool list assertion in `mcp-server.test.ts`.

### Rejected alternatives

- **TypeScript-only directory copy (no Python script):** Would break the established script-execution pattern, require new filesystem logic in the TypeScript service layer, and introduce inconsistency with all other push-down commands.
- **Reusing the copilot-customizations publisher with a `root_folders` override via CLI flag:** The existing Python scripts do not expose root-folder selection as a CLI argument; the codex-and-agents pattern addresses this by creating a dedicated publisher module. Adding CLI overrides would require changes to the shared engine.

---

## 8. Risks and Constraints

| Risk | Severity | Mitigation |
|------|----------|------------|
| `settings.local.json` contains user secrets or local paths | High | Exclude from bundle directory. Curate `claude-dir-customizations/.claude/` without this file. |
| `agent-memory/` subtree grows over time and gets accidentally bundled | Medium | Do not include `agent-memory/` in the bundle directory. The memory system is ephemeral and user-specific. |
| `.claude/skills/` contains any skill with absolute paths or user-specific content | Low | Review skill files before bundling; all verified skills in scope use relative references only. |
| `mcp-server.test.ts` tool list assertion is an exact ordered array | Medium | The new tool name must be inserted at a consistent position relative to existing entries. Recommended position: immediately after `push_down_codex_and_agents_customizations`. |
| No new npm dependencies allowed per spec | None | This approach adds no npm dependencies. |
