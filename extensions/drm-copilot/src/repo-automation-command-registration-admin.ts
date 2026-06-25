import * as vscode from "vscode";

import { executeBundledScript, getWorkspaceRoot } from "./command-runtime";
import {
  promptForChoice,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import { listRepoAutomationTools } from "./mcp-tools";
import {
  discoverPrBaseBranches,
  pickPrBaseBranch,
} from "./pr-context-branches";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";
import { resolveCollectPrContextInvocation } from "./workflow-command-arguments";

function registerCollectCommitContextCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.collectCommitContext",
    async () => {
      const commandId = "drmCopilotExtension.collectCommitContext";
      await options.service.collectCommitContext({
        workspaceRoot: getWorkspaceRoot(),
        invocationId: commandId,
      });
    },
  );
}

function registerCollectPrContextCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.collectPrContext",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.collectPrContext";
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () => resolveCollectPrContextInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await options.service.collectPrContext({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      options.output.appendLine(`[${commandId}] branch discovery start`);
      let discoveryResult: ReturnType<typeof discoverPrBaseBranches>;
      try {
        discoveryResult = discoverPrBaseBranches(
          options.output,
          commandId,
          workspaceRoot,
        );
      } catch (error: unknown) {
        options.output.appendLine(`[${commandId}] branch discovery failure`);
        throw error;
      }
      options.output.appendLine(
        `[${commandId}] branch discovery success: ${discoveryResult.candidates.join(", ")}`,
      );

      const selectedBase = await pickPrBaseBranch(
        options.output,
        commandId,
        discoveryResult.candidates,
        discoveryResult.defaultBranch,
      );
      if (!selectedBase) {
        return;
      }

      await options.service.collectPrContext({
        workspaceRoot,
        invocationId: commandId,
        base: selectedBase,
      });
    },
  );
}

function registerPushDownCopilotCustomizationsCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.pushDownCopilotCustomizations",
    async () => {
      const commandId = "drmCopilotExtension.pushDownCopilotCustomizations";
      await options.service.pushDownCopilotCustomizations({
        workspaceRoot: getWorkspaceRoot(),
        invocationId: commandId,
      });
    },
  );
}

function registerPushDownCodexAndAgentsCustomizationsCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    async () => {
      const commandId =
        "drmCopilotExtension.pushDownCodexAndAgentsCustomizations";
      await options.service.pushDownCodexAndAgentsCustomizations({
        workspaceRoot: getWorkspaceRoot(),
        invocationId: commandId,
      });
    },
  );
}

/**
 * Selectable language packs for the Claude push-down command, ordered for the
 * multi-select QuickPick. Each entry maps a human-readable label to the
 * corresponding pack manifest name. `core` is always published by the engine
 * and is therefore not offered as a selectable item here.
 */
const CLAUDE_PUSH_DOWN_PACK_ITEMS: ReadonlyArray<{
  readonly label: string;
  readonly pack: string;
}> = [
  { label: "Python", pack: "python" },
  { label: "PowerShell", pack: "powershell" },
  { label: "TypeScript", pack: "typescript" },
  { label: "C#", pack: "csharp" },
];

const CLAUDE_PUSH_DOWN_TITLE =
  "drm-copilot: Push Down Claude Code Customizations";

function registerPushDownClaudeCustomizationsCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.pushDownClaudeCustomizations",
    async () => {
      const commandId = "drmCopilotExtension.pushDownClaudeCustomizations";

      // Step 1: multi-select the language packs to publish. All packs are
      // pre-picked so the default selection matches the prior publish-all
      // behavior. Cancellation (undefined) aborts without invoking the service.
      const packSelection = await vscode.window.showQuickPick(
        CLAUDE_PUSH_DOWN_PACK_ITEMS.map((item) => ({
          label: item.label,
          pack: item.pack,
          picked: true,
        })),
        {
          title: CLAUDE_PUSH_DOWN_TITLE,
          placeHolder:
            "Select the language packs to publish (core is always included).",
          canPickMany: true,
          ignoreFocusOut: true,
        },
      );
      if (packSelection === undefined) {
        return;
      }
      const packs = packSelection.map((item) => item.pack);

      // Step 2: when the C# pack is selected, choose the C# variant. The prompt
      // is skipped entirely when C# was not selected.
      let csharpVariant: "modern" | "legacy" | undefined;
      if (packs.includes("csharp")) {
        const variantChoice = await promptForChoice(
          CLAUDE_PUSH_DOWN_TITLE,
          "Choose the C# toolchain variant.",
          ["modern", "legacy"],
        );
        if (!variantChoice) {
          return;
        }
        csharpVariant = variantChoice;
      }

      // Step 3: choose the agent-memory mode.
      const memoryMode = await promptForChoice(
        CLAUDE_PUSH_DOWN_TITLE,
        "Choose the agent-memory handling mode.",
        ["overwrite", "merge", "skip"],
      );
      if (!memoryMode) {
        return;
      }

      await options.service.pushDownClaudeCustomizations({
        workspaceRoot: getWorkspaceRoot(),
        invocationId: commandId,
        packs,
        ...(csharpVariant === undefined ? {} : { csharpVariant }),
        memoryMode,
      });
    },
  );
}

function registerRunCodexNativeConverterCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.runCodexNativeConverter",
    async () => {
      const commandId = "drmCopilotExtension.runCodexNativeConverter";
      const workspaceRoot = getWorkspaceRoot();
      const mode = await promptForChoice(
        "drm-copilot: Run Codex-native Converter",
        "Choose the converter mode.",
        ["review", "apply"],
      );
      if (!mode) {
        return;
      }

      const sourceEcosystem = await promptForChoice(
        "drm-copilot: Run Codex-native Converter",
        "Choose the source ecosystem.",
        ["github-copilot", "claude"],
      );
      if (!sourceEcosystem) {
        return;
      }

      const sourceRoot = await vscode.window.showInputBox({
        title: "drm-copilot: Run Codex-native Converter",
        prompt: "Enter the source runtime root.",
        value: workspaceRoot,
        ignoreFocusOut: true,
      });
      if (sourceRoot === undefined || sourceRoot.trim().length === 0) {
        return;
      }

      let destinationRoot: string | undefined;
      if (mode === "apply") {
        destinationRoot = await vscode.window.showInputBox({
          title: "drm-copilot: Run Codex-native Converter",
          prompt: "Enter the destination root for native output.",
          value: workspaceRoot,
          ignoreFocusOut: true,
        });
        if (
          destinationRoot === undefined ||
          destinationRoot.trim().length === 0
        ) {
          return;
        }
      }

      const enableRepoPromptsChoice = await promptForChoice(
        "drm-copilot: Run Codex-native Converter",
        "Enable repository-convention .codex/prompts output?",
        ["No", "Yes"],
      );
      if (!enableRepoPromptsChoice) {
        return;
      }

      await options.service.runCodexNativeConverter({
        workspaceRoot,
        invocationId: commandId,
        mode,
        sourceEcosystem,
        sourceRoot,
        ...(destinationRoot === undefined ? {} : { destinationRoot }),
        enableRepoPrompts: enableRepoPromptsChoice === "Yes",
      });
    },
  );
}

function registerSyncAgentsFromInstructionsCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.syncAgentsFromInstructions",
    async () => {
      const commandId = "drmCopilotExtension.syncAgentsFromInstructions";
      const workspaceRoot = getWorkspaceRoot();

      await executeBundledScript(options.context, options.output, {
        runtimeKind: "powershell",
        bundledRelativePath:
          "resources/templates/sync-agents-from-instructions.ps1",
        commandId,
        args: ["-RepoRoot", workspaceRoot],
      });
    },
  );
}

function registerListMcpToolsCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.listMcpTools",
    async () => {
      const commandId = "drmCopilotExtension.listMcpTools";
      const toolItems = listRepoAutomationTools().map((tool) => ({
        label: tool.name,
        description: tool.description,
        detail:
          tool.inputSchema.required === undefined ||
          tool.inputSchema.required.length === 0
            ? "Required inputs: none"
            : `Required inputs: ${tool.inputSchema.required.join(", ")}`,
      }));

      options.output.appendLine(`[${commandId}] available MCP tools:`);
      for (const toolItem of toolItems) {
        options.output.appendLine(
          `- ${toolItem.label}: ${toolItem.description} (${toolItem.detail})`,
        );
      }

      await vscode.window.showQuickPick(toolItems, {
        title: "drm-copilot: List MCP Tools",
        placeHolder: "Available tools on the drmCopilotExtension MCP server.",
        matchOnDescription: true,
        matchOnDetail: true,
      });
    },
  );
}

export function registerRepoAutomationAdminCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  return [
    registerCollectCommitContextCommand(options),
    registerCollectPrContextCommand(options),
    registerPushDownCopilotCustomizationsCommand(options),
    registerPushDownCodexAndAgentsCustomizationsCommand(options),
    registerPushDownClaudeCustomizationsCommand(options),
    registerRunCodexNativeConverterCommand(options),
    registerSyncAgentsFromInstructionsCommand(options),
    registerListMcpToolsCommand(options),
  ];
}
