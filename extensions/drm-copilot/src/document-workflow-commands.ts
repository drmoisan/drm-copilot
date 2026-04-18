import * as vscode from "vscode";
import { getWorkspaceRoot } from "./command-runtime";
import {
  promptForActiveFeaturePlan,
  promptForChoice,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import type { RepoAutomationService } from "./repo-automation-service";
import {
  normalizeWorkspaceDestinationPath,
  POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS,
  resolvePolicyAuditTemplateAssetInvocation,
} from "./workflow-command-arguments";

interface DocumentWorkflowCommandOptions {
  readonly output: vscode.OutputChannel;
  readonly service: RepoAutomationService;
}

async function openBundledDocument(filePath: string): Promise<void> {
  const document = await vscode.workspace.openTextDocument(
    vscode.Uri.file(filePath),
  );
  await vscode.window.showTextDocument(document);
}

export function registerDocumentWorkflowCommands(
  options: DocumentWorkflowCommandOptions,
): readonly [vscode.Disposable, vscode.Disposable, vscode.Disposable] {
  const resolvePolicyAuditTemplateAssetDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
      async (...rawArgs: unknown[]) => {
        const commandId = "drmCopilotExtension.resolvePolicyAuditTemplateAsset";
        const workspaceRoot = getWorkspaceRoot();
        const invocation = resolveWorkflowInvocation(
          options.output,
          commandId,
          () => resolvePolicyAuditTemplateAssetInvocation(rawArgs),
        );

        if (invocation.mode === "direct") {
          const result = await options.service.resolvePolicyAuditTemplateAsset({
            workspaceRoot,
            invocationId: commandId,
            asset: invocation.input.asset,
            ...(invocation.input.targetPath === undefined
              ? {}
              : {
                  targetPath: normalizeWorkspaceDestinationPath(
                    invocation.input.targetPath,
                    workspaceRoot,
                    "-target",
                  ),
                }),
          });
          if (result.destinationPath === undefined) {
            await openBundledDocument(
              result.bundledSourcePath ??
                (() => {
                  throw new Error(
                    "Policy-audit asset resolution did not return a bundled source path.",
                  );
                })(),
            );
          }
          return;
        }

        const asset = await promptForChoice(
          "drm-copilot: Resolve Policy Audit Template Asset",
          "Choose the bundled policy-audit asset to open.",
          POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS,
        );
        if (!asset) {
          return;
        }

        const result = await options.service.resolvePolicyAuditTemplateAsset({
          workspaceRoot,
          invocationId: commandId,
          asset,
        });
        await openBundledDocument(
          result.bundledSourcePath ??
            (() => {
              throw new Error(
                "Policy-audit asset resolution did not return a bundled source path.",
              );
            })(),
        );
      },
    );

  const resolveExecuteHardLockPromptDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
      async () => {
        const commandId = "drmCopilotExtension.resolveExecuteHardLockPrompt";
        const workspaceRoot = getWorkspaceRoot();
        const planPath = await promptForActiveFeaturePlan(workspaceRoot);
        if (!planPath) {
          return;
        }

        await options.service.resolveExecuteHardLockPrompt({
          workspaceRoot,
          invocationId: commandId,
          target: planPath,
        });
      },
    );

  const resolveAtomicPlanPromptDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.resolveAtomicPlanPrompt",
    async () => {
      const commandId = "drmCopilotExtension.resolveAtomicPlanPrompt";
      const workspaceRoot = getWorkspaceRoot();
      const planPath = await promptForActiveFeaturePlan(workspaceRoot);
      if (!planPath) {
        return;
      }

      await options.service.resolveAtomicPlanPrompt({
        workspaceRoot,
        invocationId: commandId,
        target: planPath,
      });
    },
  );

  return [
    resolvePolicyAuditTemplateAssetDisposable,
    resolveExecuteHardLockPromptDisposable,
    resolveAtomicPlanPromptDisposable,
  ];
}
