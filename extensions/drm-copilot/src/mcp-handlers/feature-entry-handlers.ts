import {
  resolveNewActiveFeatureFolderToolInput,
  resolveNewPotentialBugEntryToolInput,
  resolveNewPotentialEntryToolInput,
  resolvePotentialToIssueToolInput,
} from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handleNewPotentialBugEntry(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveNewPotentialBugEntryToolInput(rawInput);
  return service.newPotentialBugEntry(input);
}

export async function handleNewPotentialEntry(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveNewPotentialEntryToolInput(rawInput);
  return service.newPotentialEntry(input);
}

export async function handlePotentialToIssue(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolvePotentialToIssueToolInput(rawInput);
  return service.potentialToIssue(input);
}

export async function handleNewActiveFeatureFolder(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveNewActiveFeatureFolderToolInput(rawInput);
  return service.newActiveFeatureFolder(input);
}
