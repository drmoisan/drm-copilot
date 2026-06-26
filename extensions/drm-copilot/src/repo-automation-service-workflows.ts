import * as path from "node:path";
import {
  copyBundledPolicyAuditTemplateAsset,
  resolveBundledPolicyAuditTemplateAsset,
} from "./policy-audit-template-assets";
import type { FileSystem } from "./lib/file-system";
import {
  resolveAtomicPlanPromptServiceCall,
  resolveExecuteHardLockPromptServiceCall,
} from "./lib/resolve/resolve-prompts-service-call";
import { normalizeGeneratedPath } from "./repo-automation-service-support";
import type {
  RepoAutomationExecutionResult,
  WorkspaceExecutionInput,
} from "./repo-automation-service";
import type { PolicyAuditTemplateAssetSelector } from "./workflow-command-arguments";

export interface RunCodexNativeConverterInput extends WorkspaceExecutionInput {
  readonly mode: "review" | "apply";
  readonly sourceEcosystem: "github-copilot" | "claude";
  readonly sourceRoot: string;
  readonly selectedPaths?: ReadonlyArray<string>;
  readonly destinationRoot?: string;
  readonly artifactRoot?: string;
  readonly enableRepoPrompts?: boolean;
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

export function buildTemplateRoot(extensionRoot: string): string {
  return normalizeGeneratedPath(
    path.join(extensionRoot, "resources", "feature-templates"),
  );
}

/** Dependencies the F5 in-process resolvers need from the service. */
export interface ResolvePromptServiceDeps {
  readonly fileSystem: FileSystem;
  readonly extensionRoot: string;
  readonly log: (message: string) => void;
}

/**
 * Run the in-process hard-lock resolver and return the preserved result.
 *
 * Thin wrapper that keeps `RepoAutomationService.resolveExecuteHardLockPrompt`
 * a single delegation while the F5 wiring lives in
 * `lib/resolve/resolve-prompts-service-call.ts`.
 *
 * @param deps Filesystem, extension root, and log sink from the service.
 * @param input Workspace root, target, and optional output/quiet.
 * @returns The preserved hard-lock service result record.
 */
export function runResolveExecuteHardLockPrompt(
  deps: ResolvePromptServiceDeps,
  input: ResolveExecuteHardLockPromptInput,
): RepoAutomationExecutionResult {
  return resolveExecuteHardLockPromptServiceCall({
    fileSystem: deps.fileSystem,
    extensionRoot: deps.extensionRoot,
    workspaceRoot: input.workspaceRoot,
    target: input.target,
    output: input.output,
    quiet: input.quiet,
    log: deps.log,
  });
}

/**
 * Run the in-process atomic-plan resolver and return the preserved result.
 *
 * @param deps Filesystem, extension root, and log sink from the service.
 * @param input Workspace root and target.
 * @returns The preserved atomic-plan service result record.
 */
export function runResolveAtomicPlanPrompt(
  deps: ResolvePromptServiceDeps,
  input: ResolveAtomicPlanPromptInput,
): RepoAutomationExecutionResult {
  return resolveAtomicPlanPromptServiceCall({
    fileSystem: deps.fileSystem,
    extensionRoot: deps.extensionRoot,
    workspaceRoot: input.workspaceRoot,
    target: input.target,
    log: deps.log,
  });
}
