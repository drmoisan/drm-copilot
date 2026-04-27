import * as path from "node:path";
import {
  copyBundledPolicyAuditTemplateAsset,
  resolveBundledPolicyAuditTemplateAsset,
} from "./policy-audit-template-assets";
import {
  buildNewActiveFeatureFolderArgs,
  buildResolveExecuteHardLockPromptArguments,
  buildValidateOrchestrationArtifactsArgs,
} from "./repo-automation-args";
import {
  normalizeGeneratedPath,
  type ScriptExecutionOptions,
} from "./repo-automation-service-support";
import type {
  RepoAutomationExecutionResult,
  RunCodexNativeConverterInput,
  WorkspaceExecutionInput,
} from "./repo-automation-service";
import type {
  PolicyAuditTemplateAssetSelector,
  PotentialPromotionType,
  WorkModeOption,
} from "./workflow-command-arguments";

interface NewActiveFeatureFolderInput extends WorkspaceExecutionInput {
  readonly featureName: string;
  readonly type: PotentialPromotionType;
  readonly issueNumber?: string;
  readonly workMode: WorkModeOption;
}

interface PolicyAuditTemplateAssetInput extends WorkspaceExecutionInput {
  readonly asset: PolicyAuditTemplateAssetSelector;
  readonly targetPath?: string;
}

interface ResolveExecuteHardLockPromptInput extends WorkspaceExecutionInput {
  readonly target: string;
  readonly output?: string;
  readonly quiet?: boolean;
}

interface ResolveAtomicPlanPromptInput extends WorkspaceExecutionInput {
  readonly target: string;
}

interface ValidateOrchestrationArtifactsInput extends WorkspaceExecutionInput {
  readonly artifactType: string;
  readonly artifactPath: string;
  readonly requireComplete?: boolean;
}

export function buildRunCodexNativeConverterOptions(
  input: RunCodexNativeConverterInput,
): ScriptExecutionOptions & { readonly tool: "run_codex_native_converter" } {
  const args = [
    input.mode,
    "--source-root",
    input.sourceRoot,
    "--source-ecosystem",
    input.sourceEcosystem,
  ];

  if (input.destinationRoot !== undefined) {
    args.push("--destination-root", input.destinationRoot);
  }

  if (input.artifactRoot !== undefined) {
    args.push("--artifact-root", input.artifactRoot);
  }

  if (input.enableRepoPrompts === true) {
    args.push("--enable-repo-prompts");
  }

  for (const selectedPath of input.selectedPaths ?? []) {
    args.push("--selected-path", selectedPath);
  }

  return {
    tool: "run_codex_native_converter",
    runtimeKind: "python",
    bundledRelativePath: "resources/templates/codex_native_converter.py",
    workspaceRoot: input.workspaceRoot,
    invocationId: input.invocationId ?? "run_codex_native_converter",
    args,
    summary: `Ran bundled codex-native-converter in ${input.mode} mode for '${input.sourceEcosystem}'.`,
    stdoutArtifactPattern: /Artifact root:\s*(.+)/i,
  };
}

export function buildNewActiveFeatureFolderOptions(
  input: NewActiveFeatureFolderInput,
  templateRoot: string,
): ScriptExecutionOptions & { readonly tool: "new_active_feature_folder" } {
  return {
    tool: "new_active_feature_folder",
    runtimeKind: "python",
    bundledRelativePath: "resources/templates/new_active_feature_folder.py",
    workspaceRoot: input.workspaceRoot,
    invocationId: input.invocationId ?? "new_active_feature_folder",
    args: buildNewActiveFeatureFolderArgs(input, templateRoot),
    summary: `Created a new active ${input.type} feature folder for '${input.featureName}'.`,
  };
}

export function resolvePolicyAuditTemplateAssetResult(
  extensionRoot: string,
  input: PolicyAuditTemplateAssetInput,
): RepoAutomationExecutionResult {
  const resolvedAsset = resolveBundledPolicyAuditTemplateAsset(
    extensionRoot,
    input.asset,
  );
  const destinationPath =
    input.targetPath === undefined
      ? undefined
      : copyBundledPolicyAuditTemplateAsset(
          resolvedAsset.bundledSourcePath,
          input.targetPath,
        );

  return {
    tool: "resolve_policy_audit_template_asset",
    workspaceRoot: input.workspaceRoot,
    summary:
      destinationPath === undefined
        ? `Resolved bundled policy-audit asset '${input.asset}'.`
        : `Copied bundled policy-audit asset '${input.asset}' to '${destinationPath}'.`,
    artifacts:
      destinationPath === undefined
        ? [resolvedAsset.bundledSourcePath]
        : [resolvedAsset.bundledSourcePath, destinationPath],
    assetId: resolvedAsset.assetId,
    bundledSourcePath: resolvedAsset.bundledSourcePath,
    ...(destinationPath === undefined ? {} : { destinationPath }),
  };
}

export function buildResolveExecuteHardLockPromptOptions(
  input: ResolveExecuteHardLockPromptInput,
): ScriptExecutionOptions & {
  readonly tool: "resolve_execute_hard_lock_prompt";
} {
  const { args, artifactPaths } =
    buildResolveExecuteHardLockPromptArguments(input);
  return {
    tool: "resolve_execute_hard_lock_prompt",
    runtimeKind: "python",
    bundledRelativePath: "resources/templates/resolve_hard_lock_prompt.py",
    workspaceRoot: input.workspaceRoot,
    invocationId: input.invocationId ?? "resolve_execute_hard_lock_prompt",
    args,
    summary: `Resolved the execute hard-lock prompt for '${input.target}'.`,
    ...(artifactPaths === undefined ? {} : { artifactPaths }),
  };
}

export function buildResolveAtomicPlanPromptOptions(
  input: ResolveAtomicPlanPromptInput,
): ScriptExecutionOptions & { readonly tool: "resolve_atomic_plan_prompt" } {
  return {
    tool: "resolve_atomic_plan_prompt",
    runtimeKind: "python",
    bundledRelativePath: "resources/templates/resolve_atomic_plan_prompt.py",
    workspaceRoot: input.workspaceRoot,
    invocationId: input.invocationId ?? "resolve_atomic_plan_prompt",
    args: ["--target", input.target, "--workspace", input.workspaceRoot],
    summary: `Resolved the atomic-plan prompt for '${input.target}'.`,
  };
}

export function buildValidateOrchestrationArtifactsOptions(
  input: ValidateOrchestrationArtifactsInput,
): ScriptExecutionOptions & {
  readonly tool: "validate_orchestration_artifacts";
} {
  return {
    tool: "validate_orchestration_artifacts",
    runtimeKind: "python",
    bundledRelativePath:
      "resources/templates/validate_orchestration_artifacts.py",
    workspaceRoot: input.workspaceRoot,
    invocationId: input.invocationId ?? "validate_orchestration_artifacts",
    args: buildValidateOrchestrationArtifactsArgs(input),
    summary: `Validated ${input.artifactType} artifact at '${input.artifactPath}'.`,
  };
}

export function buildTemplateRoot(extensionRoot: string): string {
  return normalizeGeneratedPath(
    path.join(extensionRoot, "resources", "feature-templates"),
  );
}
