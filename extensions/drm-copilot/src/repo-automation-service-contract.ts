import { type RepoAutomationToolName } from "./repo-automation-tool-names";
import { type RunCodexNativeConverterInput } from "./repo-automation-service-workflows";
import {
  type PolicyAuditTemplateAssetSelector,
  type PotentialPromotionType,
  type WorkModeOption,
} from "./workflow-command-arguments";
import { type RenderSubagentTreeServiceInput } from "./repo-automation-service-subagent-tree";
import {
  type RunDiscoveryAnalyzerInput,
  type RunDiscoveryInitInput,
  type RunDiscoveryReportInput,
  type RunDiscoveryScenarioGenerationInput,
  type ValidateDiscoveryArtifactsInput,
} from "./repo-automation-execute-discovery";

/**
 * Service contract declarations for {@link RepoAutomationService}.
 *
 * Extracted from `repo-automation-service.ts` to keep that implementation file
 * under the 500-line cap; every moved symbol is re-exported from
 * `repo-automation-service.ts` so existing imports remain valid.
 */

export interface RepoAutomationExecutionResult {
  readonly tool: RepoAutomationToolName;
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: ReadonlyArray<string>;
  readonly assetId?: string;
  readonly bundledSourcePath?: string;
  readonly destinationPath?: string;
  readonly renderedTree?: string;
  readonly warnings?: ReadonlyArray<string>;
}

export interface WorkspaceExecutionInput {
  readonly workspaceRoot: string;
  readonly invocationId?: string;
}

export interface PushDownClaudeCustomizationsInput extends WorkspaceExecutionInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

export interface PushDownCodexAndAgentsCustomizationsInput extends WorkspaceExecutionInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

export interface RepoAutomationService {
  collectCommitContext(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  collectPrContext(
    input: WorkspaceExecutionInput & { readonly base: string },
  ): Promise<RepoAutomationExecutionResult>;
  runCodexNativeConverter(
    input: RunCodexNativeConverterInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownCopilotCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownCodexAndAgentsCustomizations(
    input: PushDownCodexAndAgentsCustomizationsInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownClaudeCustomizations(
    input: PushDownClaudeCustomizationsInput,
  ): Promise<RepoAutomationExecutionResult>;
  newPotentialBugEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult>;
  newPotentialEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult>;
  linkParentChild(
    input: WorkspaceExecutionInput & {
      readonly parentIssueNumber: string;
      readonly childIssueNumber: string;
    },
  ): Promise<RepoAutomationExecutionResult>;
  potentialToIssue(
    input: WorkspaceExecutionInput & {
      readonly potentialPath: string;
      readonly promotionType: PotentialPromotionType;
      readonly workMode: WorkModeOption;
    },
  ): Promise<RepoAutomationExecutionResult>;
  newActiveFeatureFolder(
    input: WorkspaceExecutionInput & {
      readonly featureName: string;
      readonly type: PotentialPromotionType;
      readonly issueNumber?: string;
      readonly workMode: WorkModeOption;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCFormat(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCAnalyze(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCTest(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCAnalyzeAutofix(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCSuite(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolvePolicyAuditTemplateAsset(
    input: WorkspaceExecutionInput & {
      readonly asset: PolicyAuditTemplateAssetSelector;
      readonly targetPath?: string;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolveExecuteHardLockPrompt(
    input: WorkspaceExecutionInput & {
      readonly target: string;
      readonly output?: string;
      readonly quiet?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolveAtomicPlanPrompt(
    input: WorkspaceExecutionInput & { readonly target: string },
  ): Promise<RepoAutomationExecutionResult>;
  validateOrchestrationArtifacts(
    input: WorkspaceExecutionInput & {
      readonly artifactType: string;
      readonly artifactPath: string;
      readonly requireComplete?: boolean;
      readonly requirePrCreationReady?: boolean;
      readonly requireModelRouting?: boolean;
      readonly requireCodexModelRouting?: boolean;
      readonly requireCodexTopology?: boolean;
      readonly requireReadyForExecution?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult>;
  renderSubagentTree(
    input: RenderSubagentTreeServiceInput,
  ): Promise<RepoAutomationExecutionResult>;
  validateDiscoveryArtifacts(
    input: ValidateDiscoveryArtifactsInput,
  ): Promise<RepoAutomationExecutionResult>;
  runDiscoveryInit(
    input: RunDiscoveryInitInput,
  ): Promise<RepoAutomationExecutionResult>;
  runDiscoveryRepoInventory(
    input: RunDiscoveryAnalyzerInput,
  ): Promise<RepoAutomationExecutionResult>;
  runDiscoveryDotnetAnalyzer(
    input: RunDiscoveryAnalyzerInput,
  ): Promise<RepoAutomationExecutionResult>;
  runDiscoveryVstoAnalyzer(
    input: RunDiscoveryAnalyzerInput,
  ): Promise<RepoAutomationExecutionResult>;
  runDiscoveryScenarioGeneration(
    input: RunDiscoveryScenarioGenerationInput,
  ): Promise<RepoAutomationExecutionResult>;
  runDiscoveryReport(
    input: RunDiscoveryReportInput,
  ): Promise<RepoAutomationExecutionResult>;
}
