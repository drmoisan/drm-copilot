import { POSH_QC_TOOL_CONFIG } from "./repo-automation-service-support";
import type { WorkspaceExecutionInput } from "./repo-automation-service";
import type { RepoAutomationToolName } from "./repo-automation-tool-names";

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
