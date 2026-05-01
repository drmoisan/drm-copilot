import * as vscode from "vscode";

import { getWorkspaceRoot } from "./command-runtime";
import {
  promptForChoice,
  promptForFeatureName,
  promptForIssueNumber,
  promptForPotentialPath,
  promptForRequiredIssueNumber,
  promptForShortName,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";
import {
  POTENTIAL_PROMOTION_TYPES,
  resolveLinkParentChildInvocation,
  resolveNewActiveFeatureFolderInvocation,
  resolveNewPotentialBugEntryInvocation,
  resolveNewPotentialEntryInvocation,
  resolvePotentialToIssueInvocation,
  WORK_MODE_OPTIONS,
} from "./workflow-command-arguments";

function registerNewPotentialBugEntryCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.newPotentialBugEntry",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newPotentialBugEntry";
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () => resolveNewPotentialBugEntryInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await options.service.newPotentialBugEntry({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const shortName = await promptForShortName(
        "drm-copilot: New Potential Bug Entry",
        "Enter a kebab-case short name for the potential bug entry.",
      );
      if (!shortName) {
        return;
      }

      await options.service.newPotentialBugEntry({
        workspaceRoot,
        invocationId: commandId,
        shortName,
      });
    },
  );
}

function registerNewPotentialEntryCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.newPotentialEntry",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newPotentialEntry";
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () => resolveNewPotentialEntryInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await options.service.newPotentialEntry({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const shortName = await promptForShortName(
        "drm-copilot: New Potential Entry",
        "Enter a kebab-case short name for the potential entry.",
      );
      if (!shortName) {
        return;
      }

      await options.service.newPotentialEntry({
        workspaceRoot,
        invocationId: commandId,
        shortName,
      });
    },
  );
}

function registerLinkParentChildCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.linkParentChild",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.linkParentChild";
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () => resolveLinkParentChildInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await options.service.linkParentChild({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const childIssueNumber = await promptForRequiredIssueNumber(
        "drm-copilot: Link Parent/Child Issues",
        "Enter the child issue number.",
        "Child issue number",
      );
      if (!childIssueNumber) {
        return;
      }

      const parentIssueNumber = await promptForRequiredIssueNumber(
        "drm-copilot: Link Parent/Child Issues",
        "Enter the parent tracking issue number.",
        "Parent issue number",
      );
      if (!parentIssueNumber) {
        return;
      }

      await options.service.linkParentChild({
        workspaceRoot,
        invocationId: commandId,
        childIssueNumber,
        parentIssueNumber,
      });
    },
  );
}

function registerPotentialToIssueCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.potentialToIssue",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.potentialToIssue";
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () => resolvePotentialToIssueInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await options.service.potentialToIssue({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const potentialPath = await promptForPotentialPath(workspaceRoot);
      if (!potentialPath) {
        return;
      }

      const promotionType = await promptForChoice(
        "drm-copilot: Potential To Issue",
        "Choose a promotion type.",
        POTENTIAL_PROMOTION_TYPES,
      );
      if (!promotionType) {
        return;
      }

      const workMode = await promptForChoice(
        "drm-copilot: Potential To Issue",
        "Choose a work mode.",
        WORK_MODE_OPTIONS,
      );
      if (!workMode) {
        return;
      }

      await options.service.potentialToIssue({
        workspaceRoot,
        invocationId: commandId,
        potentialPath,
        promotionType,
        workMode,
      });
    },
  );
}

function registerNewActiveFeatureFolderCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    "drmCopilotExtension.newActiveFeatureFolder",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newActiveFeatureFolder";
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () => resolveNewActiveFeatureFolderInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await options.service.newActiveFeatureFolder({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const featureType = await promptForChoice(
        "drm-copilot: New Active Feature Folder",
        "Choose the feature folder type.",
        POTENTIAL_PROMOTION_TYPES,
      );
      if (!featureType) {
        return;
      }

      const featureName = await promptForFeatureName(
        "drm-copilot: New Active Feature Folder",
        "Enter the feature name (kebab-case or underscore-case).",
      );
      if (!featureName) {
        return;
      }

      const issueNumber = await promptForIssueNumber();
      if (issueNumber === undefined) {
        return;
      }

      const workMode = await promptForChoice(
        "drm-copilot: New Active Feature Folder",
        "Choose a work mode.",
        WORK_MODE_OPTIONS,
      );
      if (!workMode) {
        return;
      }

      await options.service.newActiveFeatureFolder({
        workspaceRoot,
        invocationId: commandId,
        featureName,
        type: featureType,
        workMode,
        ...(issueNumber === null ? {} : { issueNumber }),
      });
    },
  );
}

export function registerRepoAutomationFeatureWorkflowCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  return [
    registerNewPotentialBugEntryCommand(options),
    registerNewPotentialEntryCommand(options),
    registerLinkParentChildCommand(options),
    registerPotentialToIssueCommand(options),
    registerNewActiveFeatureFolderCommand(options),
  ];
}
