import {
  type CommandOutput,
  executeBundledScriptFromExtensionRoot,
} from "./command-runtime";
import {
  parseFirstArtifactPath,
  type ScriptExecutionOptions,
} from "./repo-automation-service-support";
import type { RepoAutomationToolName } from "./repo-automation-tool-names";

/**
 * Result record produced by {@link executeScriptServiceCall}; assignable to
 * `RepoAutomationExecutionResult`.
 */
export interface ExecuteScriptServiceCallResult {
  readonly tool: RepoAutomationToolName;
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: ReadonlyArray<string>;
}

/**
 * Execute a bundled script and build the service result record.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.executeScript` delegates to,
 *     keeping the service file within the 500-line limit while preserving the
 *     observable return contract (tool/workspaceRoot/summary plus parsed
 *     artifacts). Lives in a dedicated module (not
 *     `repo-automation-service-support.ts`) so that the host-bound
 *     `command-runtime` (which imports `vscode`) is not pulled into the
 *     support module consumed by host-neutral lib tests.
 *
 * Side effects:
 *     Spawns the bundled script through
 *     {@link executeBundledScriptFromExtensionRoot}.
 *
 * @param output Output sink for command diagnostics.
 * @param extensionRoot Installed extension root used to resolve the script.
 * @param options Script execution options plus the owning tool name.
 * @returns The result record with any parsed artifact path.
 */
export async function executeScriptServiceCall(
  output: CommandOutput,
  extensionRoot: string,
  options: ScriptExecutionOptions & { readonly tool: RepoAutomationToolName },
): Promise<ExecuteScriptServiceCallResult> {
  const execution = await executeBundledScriptFromExtensionRoot(output, {
    runtimeKind: options.runtimeKind,
    bundledRelativePath: options.bundledRelativePath,
    commandId: options.invocationId,
    args: options.args,
    extensionRoot,
    workspaceRoot: options.workspaceRoot,
  });

  const parsedArtifactPath =
    options.stdoutArtifactPattern === undefined
      ? undefined
      : parseFirstArtifactPath(execution, options.stdoutArtifactPattern);
  const artifacts =
    options.artifactPaths ??
    (parsedArtifactPath === undefined ? undefined : [parsedArtifactPath]);

  return {
    tool: options.tool,
    workspaceRoot: options.workspaceRoot,
    summary: options.summary,
    ...(artifacts === undefined ? {} : { artifacts }),
  };
}
