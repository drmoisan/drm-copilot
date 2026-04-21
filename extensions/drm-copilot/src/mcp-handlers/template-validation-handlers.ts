import {
  resolvePolicyAuditTemplateAssetToolInput,
  resolveValidateOrchestrationArtifactsToolInput,
} from "../mcp-tool-inputs";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

export async function handleResolvePolicyAuditTemplateAsset(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolvePolicyAuditTemplateAssetToolInput(rawInput);
  return service.resolvePolicyAuditTemplateAsset(input);
}

export async function handleValidateOrchestrationArtifacts(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationExecutionResult> {
  const input = resolveValidateOrchestrationArtifactsToolInput(rawInput);
  return service.validateOrchestrationArtifacts(input);
}
