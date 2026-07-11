import * as vscode from "vscode";
import { type CommandOutput, getWorkspaceRoot } from "./command-runtime";
import {
  promptForChoice,
  promptForWorkspaceScanFolders,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import { type FileSystem, RealFileSystem } from "./lib/file-system";
import { promptForPoshQcScanFolders } from "./poshqc-folder-picker";
import {
  type TerminalOutput,
  createPoshQcTerminalOutput,
  createTeeOutput,
} from "./poshqc-terminal-output";
import type { RepoAutomationService } from "./repo-automation-service";
import { resolveRunPoshQCSuiteInvocation } from "./workflow-command-arguments";

interface PoshQcCommandRegistrationOptions {
  readonly output: vscode.OutputChannel;
  readonly service: RepoAutomationService;
  /**
   * Filesystem seam used by the test command's folder picker; defaults to a
   * {@link RealFileSystem}. Tests inject an in-memory fake.
   */
  readonly fileSystem?: FileSystem;
  /**
   * Optional per-invocation service factory. When provided, each PoshQC command
   * builds a tee sink (the shared `OutputChannel` plus a streaming integrated
   * terminal) and constructs a service bound to that tee, so command output
   * streams into the terminal in addition to the `OutputChannel` without
   * changing `repo-automation-service.ts` or the spawn pipeline. When omitted,
   * the shared `service` is used unchanged (the default path).
   */
  readonly createService?: (output: CommandOutput) => RepoAutomationService;
  /**
   * Terminal-output factory seam; defaults to {@link createPoshQcTerminalOutput}.
   * Tests inject a fake to assert terminal creation and reveal.
   */
  readonly createTerminalOutput?: () => TerminalOutput;
}

interface PoshQcCommandDefinition {
  readonly commandId: string;
  readonly title: string;
  readonly runOperation: (
    service: RepoAutomationService,
    input: {
      readonly workspaceRoot: string;
      readonly invocationId: string;
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ) => Promise<unknown>;
  /**
   * Folder-selection strategy for the interactive "Select folders to scan"
   * choice. Defaults to {@link promptForWorkspaceScanFolders} (native dialog);
   * the test command overrides this with the seeded multi-select picker.
   */
  readonly selectScanFolders?: (
    workspaceRoot: string,
  ) => Promise<string[] | undefined>;
}

/**
 * Per-invocation run context: the service to execute against and a `reveal`
 * callback that focuses the integrated terminal (a no-op on the default path).
 */
interface PoshQcRunContext {
  readonly service: RepoAutomationService;
  readonly reveal: () => void;
}

/**
 * Resolve the run context for a single command invocation. When a service
 * factory is configured, build a streaming terminal, tee the `OutputChannel`
 * and the terminal into one sink, and bind a fresh service to that tee;
 * otherwise use the shared service with a no-op reveal.
 *
 * @param options The command-registration options.
 * @returns The service to run against and its terminal-reveal callback.
 */
function resolvePoshQcRunContext(
  options: PoshQcCommandRegistrationOptions,
): PoshQcRunContext {
  if (!options.createService) {
    return { service: options.service, reveal: (): void => undefined };
  }
  const terminal = (
    options.createTerminalOutput ?? createPoshQcTerminalOutput
  )();
  const teed = createTeeOutput(options.output, terminal);
  return {
    service: options.createService(teed),
    reveal: (): void => terminal.reveal(),
  };
}

function registerPoshQcCommand(
  options: PoshQcCommandRegistrationOptions,
  definition: PoshQcCommandDefinition,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    definition.commandId,
    async (...rawArgs: unknown[]) => {
      const invocation = resolveWorkflowInvocation(
        options.output,
        definition.commandId,
        () => resolveRunPoshQCSuiteInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        const context = resolvePoshQcRunContext(options);
        context.reveal();
        await definition.runOperation(context.service, {
          workspaceRoot,
          invocationId: definition.commandId,
          ...invocation.input,
        });
        return;
      }

      const scopeChoice = await promptForChoice(
        definition.title,
        "Choose the scan scope.",
        ["Scan entire workspace", "Select folders to scan"],
      );
      if (!scopeChoice) {
        return;
      }

      if (scopeChoice === "Select folders to scan") {
        const selectScanFolders =
          definition.selectScanFolders ?? promptForWorkspaceScanFolders;
        const selectedFolders = await selectScanFolders(workspaceRoot);
        if (!selectedFolders) {
          return;
        }

        const context = resolvePoshQcRunContext(options);
        context.reveal();
        await definition.runOperation(context.service, {
          workspaceRoot,
          invocationId: definition.commandId,
          scanFolders: selectedFolders,
        });
        return;
      }

      const context = resolvePoshQcRunContext(options);
      context.reveal();
      await definition.runOperation(context.service, {
        workspaceRoot,
        invocationId: definition.commandId,
      });
    },
  );
}

export function registerPoshQcCommands(
  options: PoshQcCommandRegistrationOptions,
): readonly [
  vscode.Disposable,
  vscode.Disposable,
  vscode.Disposable,
  vscode.Disposable,
] {
  // Filesystem seam for the test command's seeded multi-select folder picker.
  const fileSystem = options.fileSystem ?? new RealFileSystem();
  return [
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCFormat",
      title: "drm-copilot: Run PoshQC Format",
      runOperation: (service, input) => service.runPoshQCFormat(input),
    }),
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCAnalyze",
      title: "drm-copilot: Run PoshQC Analyze",
      runOperation: (service, input) => service.runPoshQCAnalyze(input),
    }),
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCTest",
      title: "drm-copilot: Run PoshQC Test",
      runOperation: (service, input) => service.runPoshQCTest(input),
      selectScanFolders: (workspaceRoot) =>
        promptForPoshQcScanFolders(fileSystem, workspaceRoot),
    }),
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCAnalyzeAutofix",
      title: "drm-copilot: Run PoshQC Analyze Autofix",
      runOperation: (service, input) => service.runPoshQCAnalyzeAutofix(input),
    }),
  ];
}
