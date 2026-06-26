import * as path from "node:path";

import type { BundledScriptExecutionResult } from "./command-runtime";
import { collectCommitContext } from "./lib/collect-commit-context";
import type { CommandRunner } from "./lib/subprocess-runner";
import type { FileSystem } from "./lib/file-system";

export interface ScriptExecutionOptions {
  readonly tool: string;
  readonly runtimeKind: "powershell";
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

/**
 * Result record produced by {@link runCollectCommitContext}, matching the
 * historical `collectCommitContext` service return contract.
 */
export interface CollectCommitContextResult {
  readonly tool: "collect_commit_context";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
}

/**
 * Run the in-process `collect_commit_context.py` port (F4) and build the
 * service result.
 *
 * Purpose:
 *     Keep the `RepoAutomationService.collectCommitContext` method thin by
 *     centralizing output-path construction, the library invocation, the log
 *     callback wiring, and the result record here.
 *
 * Side effects:
 *     Runs git child processes through `runner` and writes one file through
 *     `fileSystem` (delegated to {@link collectCommitContext}).
 *
 * @param input Dependencies and workspace root for the run.
 * @returns The collect-commit-context result record with the normalized
 *   artifact path.
 */
export function runCollectCommitContext(input: {
  readonly runner: CommandRunner;
  readonly fileSystem: FileSystem;
  readonly workspaceRoot: string;
  readonly log: (message: string) => void;
}): CollectCommitContextResult {
  const outputPath = path.join(
    input.workspaceRoot,
    "artifacts/commit_context.txt",
  );
  collectCommitContext({
    runner: input.runner,
    fileSystem: input.fileSystem,
    cwd: input.workspaceRoot,
    outputPath,
    log: input.log,
  });
  return {
    tool: "collect_commit_context",
    workspaceRoot: input.workspaceRoot,
    summary: "Collected commit context into artifacts/commit_context.txt.",
    artifacts: [normalizeGeneratedPath(outputPath)],
  };
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
