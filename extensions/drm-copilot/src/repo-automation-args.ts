import * as path from "node:path";
import {
  normalizeGeneratedPath,
  POSH_QC_TOOL_CONFIG,
} from "./repo-automation-service-support";
import type { WorkspaceExecutionInput } from "./repo-automation-service";
import type { RepoAutomationToolName } from "./repo-automation-tool-names";
import {
  isAbsolutePathLike,
  type PotentialPromotionType,
  type WorkModeOption,
} from "./workflow-command-arguments";

export interface ResolveExecuteHardLockPromptArguments {
  readonly args: string[];
  readonly artifactPaths?: ReadonlyArray<string>;
}

export function buildResolveExecuteHardLockPromptArguments(
  input: WorkspaceExecutionInput & {
    readonly target: string;
    readonly output?: string;
    readonly quiet?: boolean;
  },
): ResolveExecuteHardLockPromptArguments {
  if (input.quiet === true && input.output === undefined) {
    throw new Error(
      "resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.",
    );
  }

  const args: string[] = [
    "--target",
    input.target,
    "--workspace",
    input.workspaceRoot,
  ];
  if (input.output !== undefined) {
    args.push("--output", input.output);
  }
  if (input.quiet === true) {
    args.push("--quiet");
  }

  const artifactPaths =
    input.output === undefined
      ? undefined
      : [
          normalizeGeneratedPath(
            isAbsolutePathLike(input.output)
              ? input.output
              : path.join(input.workspaceRoot, input.output),
          ),
        ];

  return {
    args,
    ...(artifactPaths === undefined ? {} : { artifactPaths }),
  };
}

export function buildNewActiveFeatureFolderArgs(
  input: WorkspaceExecutionInput & {
    readonly featureName: string;
    readonly type: PotentialPromotionType;
    readonly issueNumber?: string;
    readonly workMode: WorkModeOption;
  },
  templateRoot: string,
): string[] {
  const args = ["--feature-name", input.featureName, "--type", input.type];
  if (input.issueNumber !== undefined) {
    args.push("--issue-number", input.issueNumber);
  }

  args.push("--work-mode", input.workMode, "--template-root", templateRoot);
  return args;
}

type PoshQcWorkflowTool = Extract<
  RepoAutomationToolName,
  | "run_poshqc_format"
  | "run_poshqc_analyze"
  | "run_poshqc_test"
  | "run_poshqc_analyze_autofix"
  | "run_poshqc_suite"
>;

export interface PoshQcWorkflowArguments {
  readonly args: string[];
  readonly bundledRelativePath: string;
  readonly summary: string;
}

export function buildPoshQcWorkflowArguments(
  tool: PoshQcWorkflowTool,
  input: WorkspaceExecutionInput & {
    readonly scanFolders?: ReadonlyArray<string>;
  },
): PoshQcWorkflowArguments {
  const toolConfig = POSH_QC_TOOL_CONFIG[tool];
  const args = ["-WorkspaceRoot", input.workspaceRoot];
  if (input.scanFolders && input.scanFolders.length > 0) {
    if (
      tool === "run_poshqc_format" ||
      tool === "run_poshqc_analyze" ||
      tool === "run_poshqc_test"
    ) {
      args.push("-ScanFoldersJson", JSON.stringify(input.scanFolders));
    } else {
      for (const scanFolder of input.scanFolders) {
        args.push("-ScanFolders", scanFolder);
      }
    }
  }

  const summaryTemplate =
    input.scanFolders && input.scanFolders.length > 0
      ? toolConfig.summaryWithFolders
      : toolConfig.summaryWithoutFolders;
  const summary = summaryTemplate
    .replace("{workspaceRoot}", input.workspaceRoot)
    .replace("{scanFolderCount}", String(input.scanFolders?.length ?? 0));

  return {
    args,
    bundledRelativePath: toolConfig.bundledRelativePath,
    summary,
  };
}

export function buildValidateOrchestrationArtifactsArgs(
  input: WorkspaceExecutionInput & {
    readonly artifactType: string;
    readonly artifactPath: string;
    readonly requireComplete?: boolean;
  },
): string[] {
  const args = [input.artifactType, input.artifactPath];
  if (input.requireComplete) {
    args.push("--require-complete");
  }

  return args;
}
