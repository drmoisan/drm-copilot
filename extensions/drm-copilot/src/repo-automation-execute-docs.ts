/**
 * Executor for the docs MCP tools (issue #1036).
 *
 * Runs the workspace copy of `.claude/lib/docs/Invoke-DocsCommand.ps1` with
 * `pwsh -NoProfile -File <script> -Command <subcommand> -Json <options>`, with
 * the workspace root as working directory and the request stdin (empty unless
 * an update_docs_ledger operations batch supplies its document), once per call and
 * without retry. Before launch it checks, in order, the absolute workspace
 * root, the entry script and `pwsh`. TypeScript writes nothing.
 */

import { existsSync } from "node:fs";

import {
  createNodeProcessLauncher,
  type DiscoveryProcessLauncher,
} from "./discovery-runtime";
import {
  DocsHostError,
  parseDocsEnvelope,
  type DocsCommandEnvelope,
} from "./docs-command-envelope";
import { resolveExecutableOnPath } from "./lib/executable-resolver";
import type { FileSystem } from "./lib/file-system";
import { isAbsolutePathLike } from "./workflow-command-arguments";

/** Workspace-relative path of the docs entry script. */
export const DOCS_ENTRY_SCRIPT_RELATIVE_PATH =
  ".claude/lib/docs/Invoke-DocsCommand.ps1";

/** One validated docs command. */
export interface DocsCommandRequest {
  readonly workspaceRoot: string;
  readonly subcommand: string;
  /** Option tokens in declarative-table order. */
  readonly options: ReadonlyArray<string>;
  /** Standard input of the process; empty when absent (issue #1173 operations batch). */
  readonly stdin?: string;
}

/** Injected collaborators of {@link invokeDocsCommand}. */
export interface DocsCommandDependencies {
  readonly fileSystem: Pick<FileSystem, "isFile">;
  readonly launcher: DiscoveryProcessLauncher;
  /** Returns the `pwsh` path, or undefined when it does not resolve. */
  readonly resolvePwsh: () => string | undefined;
}

/** The parsed envelope and the raw stderr of one docs command. */
export interface DocsCommandOutcome {
  readonly envelope: DocsCommandEnvelope;
  readonly stderr: string;
}

/** Process environment facts used to resolve `pwsh` on PATH. */
export interface PwshResolutionEnvironment {
  readonly pathValue: string | undefined;
  readonly pathExtValue: string | undefined;
  readonly platform: NodeJS.Platform;
  readonly exists: (candidate: string) => boolean;
}

/**
 * Builds the argument list that follows the `pwsh` executable.
 *
 * @param subcommand The docs subcommand.
 * @param options The option tokens in table order.
 * @returns `-NoProfile -File <script> -Command <subcommand> -Json ...options`.
 */
export function buildDocsCommandArguments(
  subcommand: string,
  options: ReadonlyArray<string>,
): ReadonlyArray<string> {
  return [
    "-NoProfile",
    "-File",
    DOCS_ENTRY_SCRIPT_RELATIVE_PATH,
    "-Command",
    subcommand,
    "-Json",
    ...options,
  ];
}

/**
 * Creates a resolver for `pwsh` only; Windows `powershell` is never a fallback.
 *
 * @param environment PATH, PATHEXT, platform and an existence predicate.
 * @returns A resolver returning the `pwsh` path or undefined.
 */
export function createDefaultPwshResolver(
  environment: PwshResolutionEnvironment,
): () => string | undefined {
  return () =>
    resolveExecutableOnPath({
      name: "pwsh",
      pathValue: environment.pathValue,
      pathExtValue: environment.pathExtValue,
      platform: environment.platform,
      exists: environment.exists,
    });
}

/** Inputs of {@link createDefaultDocsDependencies}. */
export interface DefaultDocsDependencyInputs {
  readonly fileSystem: Pick<FileSystem, "isFile">;
  readonly launcher?: DiscoveryProcessLauncher;
  readonly resolvePwsh?: () => string | undefined;
  /** Defaults to the running process environment. */
  readonly environment?: PwshResolutionEnvironment;
}

/**
 * Fills the docs dependencies with defaults: the Node process launcher and a
 * `pwsh` resolver over the given (or the running process) environment.
 *
 * @param inputs The file system and optional overrides.
 * @returns The complete dependency set.
 */
export function createDefaultDocsDependencies(
  inputs: DefaultDocsDependencyInputs,
): DocsCommandDependencies {
  const environment = inputs.environment ?? {
    pathValue: process.env["PATH"],
    pathExtValue: process.env["PATHEXT"],
    platform: process.platform,
    exists: existsSync,
  };
  return {
    fileSystem: inputs.fileSystem,
    launcher: inputs.launcher ?? createNodeProcessLauncher(),
    resolvePwsh: inputs.resolvePwsh ?? createDefaultPwshResolver(environment),
  };
}

function entryScriptPath(workspaceRoot: string): string {
  return `${workspaceRoot.replace(/[\\/]+$/, "")}/${DOCS_ENTRY_SCRIPT_RELATIVE_PATH}`;
}

/**
 * Runs one docs command and parses its envelope.
 *
 * @param request The validated request.
 * @param deps The file system, launcher and `pwsh` resolver.
 * @returns The envelope and stderr; exit codes 1 to 3 are returned, not thrown.
 * @throws DocsHostError for a host failure before or after launch.
 */
export async function invokeDocsCommand(
  request: DocsCommandRequest,
  deps: DocsCommandDependencies,
): Promise<DocsCommandOutcome> {
  if (!isAbsolutePathLike(request.workspaceRoot)) {
    throw new DocsHostError(
      "DOCS_WORKSPACE_ROOT_INVALID",
      `workspace_root must be an absolute path; received ${JSON.stringify(request.workspaceRoot)}.`,
    );
  }
  if (!deps.fileSystem.isFile(entryScriptPath(request.workspaceRoot))) {
    throw new DocsHostError(
      "DOCS_ENTRY_SCRIPT_MISSING",
      `${DOCS_ENTRY_SCRIPT_RELATIVE_PATH} is not present in the workspace. Next action: run push_down_claude_customizations for this workspace, then retry.`,
    );
  }
  const pwshPath = deps.resolvePwsh();
  if (pwshPath === undefined) {
    throw new DocsHostError(
      "DOCS_PWSH_UNAVAILABLE",
      "pwsh (PowerShell 7.4 or later) was not found on PATH. Install PowerShell 7.4 or later and retry.",
    );
  }
  const outcome = await deps.launcher.launch(
    pwshPath,
    buildDocsCommandArguments(request.subcommand, request.options),
    { cwd: request.workspaceRoot, stdin: request.stdin ?? "" },
  );
  if (outcome.launchError !== undefined) {
    throw new DocsHostError(
      "DOCS_PWSH_UNAVAILABLE",
      `pwsh could not be started: ${outcome.launchError}`,
    );
  }
  const envelope = parseDocsEnvelope(outcome.stdout, {
    exitCode: outcome.exitCode,
    stderr: outcome.stderr,
    command: request.subcommand,
  });
  return { envelope, stderr: outcome.stderr };
}
