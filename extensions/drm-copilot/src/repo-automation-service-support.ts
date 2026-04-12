import type { BundledScriptExecutionResult } from "./command-runtime";

export interface ScriptExecutionOptions {
  readonly tool: string;
  readonly runtimeKind: "python" | "powershell";
  readonly bundledRelativePath: string;
  readonly workspaceRoot: string;
  readonly invocationId: string;
  readonly args: ReadonlyArray<string>;
  readonly summary: string;
  readonly artifactPaths?: ReadonlyArray<string>;
  readonly stdoutArtifactPattern?: RegExp;
}

export const POSH_QC_TOOL_CONFIG: Readonly<
  Record<
    | "run_poshqc_format"
    | "run_poshqc_analyze"
    | "run_poshqc_test"
    | "run_poshqc_analyze_autofix"
    | "run_poshqc_suite",
    {
      readonly bundledRelativePath: string;
      readonly summaryWithoutFolders: string;
      readonly summaryWithFolders: string;
    }
  >
> = {
  run_poshqc_format: {
    bundledRelativePath: "resources/templates/run-poshqc-format.ps1",
    summaryWithoutFolders:
      "Ran bundled PoshQC format against '{workspaceRoot}'.",
    summaryWithFolders:
      "Ran bundled PoshQC format against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
  },
  run_poshqc_analyze: {
    bundledRelativePath: "resources/templates/run-poshqc-analyze.ps1",
    summaryWithoutFolders:
      "Ran bundled PoshQC analyze against '{workspaceRoot}'.",
    summaryWithFolders:
      "Ran bundled PoshQC analyze against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
  },
  run_poshqc_test: {
    bundledRelativePath: "resources/templates/run-poshqc-test.ps1",
    summaryWithoutFolders: "Ran bundled PoshQC test against '{workspaceRoot}'.",
    summaryWithFolders:
      "Ran bundled PoshQC test against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
  },
  run_poshqc_analyze_autofix: {
    bundledRelativePath: "resources/templates/run-poshqc-analyze-autofix.ps1",
    summaryWithoutFolders:
      "Ran bundled PoshQC analyze autofix against '{workspaceRoot}'.",
    summaryWithFolders:
      "Ran bundled PoshQC analyze autofix against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
  },
  run_poshqc_suite: {
    bundledRelativePath: "resources/templates/run-poshqc-suite.ps1",
    summaryWithoutFolders:
      "Ran the bundled PoshQC suite against '{workspaceRoot}'.",
    summaryWithFolders:
      "Ran the bundled PoshQC suite against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
  },
};

export function normalizeGeneratedPath(filePath: string): string {
  return filePath.replace(/\\/g, "/");
}

export function parseFirstArtifactPath(
  execution: BundledScriptExecutionResult,
  pattern: RegExp,
): string | undefined {
  const match = execution.stdout.match(pattern);
  const capturedPath = match?.[1]?.trim();
  return capturedPath && capturedPath.length > 0
    ? normalizeGeneratedPath(capturedPath)
    : undefined;
}
