/**
 * In-process service wiring for the three push-down command variants.
 *
 * Purpose:
 *     Hold the bodies that the three `RepoAutomationService` push-down methods
 *     delegate to, so the service file stays within the 500-line limit while
 *     preserving each method's observable return contract exactly. Mirrors the
 *     F2/F4/F5 service-call precedents. Each function resolves the bundled
 *     source root from the extension root, invokes the matching in-process
 *     {@link pushDownCustomizations} port, and returns a
 *     `RepoAutomationExecutionResult`-shaped record preserving the prior `tool`,
 *     `summary`, and single-element `artifacts` contract.
 *
 * Side effects:
 *     Reads bundled source files and writes destination files plus the summary
 *     artifact through the injected {@link PushDownFileSystem}.
 */

import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import { type RepoAutomationToolName } from "../../repo-automation-tool-names";
import { type PushDownFileSystem, toPosixPath } from "./filesystem-adapter";
import { type Clock } from "./copilot-customizations-engine";
import { pushDownCustomizations as pushDownCopilot } from "./copilot-customizations";
import { pushDownCustomizations as pushDownCodexAgents } from "./codex-agents-customizations";
import {
  type CSharpVariant as CodexCSharpVariant,
  type MemoryMode as CodexMemoryMode,
} from "./codex-pack-selection";
import {
  type CSharpVariant,
  type MemoryMode,
  pushDownCustomizations as pushDownClaude,
} from "./claude-customizations";

/** Preserved result shape of a push-down service call. */
export interface PushDownServiceCallResult {
  readonly tool: RepoAutomationToolName;
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
}

/** Common input for the copilot and codex/agents service calls. */
export interface PushDownServiceCallInput {
  /** Injected push-down filesystem (in-memory in tests, real in production). */
  readonly fs: PushDownFileSystem;
  /** Extension root used to resolve the bundled source tree. */
  readonly extensionRoot: string;
  /** Destination workspace root that receives the copied tree. */
  readonly workspaceRoot: string;
  /** Optional injected clock for deterministic artifact naming. */
  readonly clock?: Clock;
  /** Optional log sink wired to the service output channel. */
  readonly log?: (message: string) => void;
}

/** Input for the Claude service call (adds pack/variant/memory selection). */
export interface PushDownClaudeServiceCallInput extends PushDownServiceCallInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: CSharpVariant;
  readonly memoryMode?: MemoryMode;
}

/** Input for the Codex service call (adds pack/variant/memory selection). */
export interface PushDownCodexServiceCallInput extends PushDownServiceCallInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: CodexCSharpVariant;
  readonly memoryMode?: CodexMemoryMode;
}

/**
 * Join the extension root and a bundled relative directory using POSIX slashes.
 *
 * @param extensionRoot Extension root path.
 * @param relativeDir Bundled relative directory.
 * @returns The combined POSIX source root path.
 */
function bundledSourceRoot(extensionRoot: string, relativeDir: string): string {
  const root = toPosixPath(extensionRoot).replace(/\/+$/, "");
  return `${root}/${relativeDir}`;
}

/**
 * Push the bundled Copilot customizations into the destination workspace.
 *
 * @param input Filesystem, extension root, workspace root, optional clock/log.
 * @returns The preserved result record with the normalized artifact path.
 */
export function pushDownCopilotCustomizationsServiceCall(
  input: PushDownServiceCallInput,
): PushDownServiceCallResult {
  const sourceRoot = bundledSourceRoot(
    input.extensionRoot,
    "resources/customizations",
  );
  const destinationRoot = toPosixPath(input.workspaceRoot);
  const summary = pushDownCopilot({
    repoRoot: sourceRoot,
    destinationRoot,
    fs: input.fs,
    sourceRoot,
    artifactRoot: destinationRoot,
    ...(input.clock === undefined ? {} : { clock: input.clock }),
  });
  return {
    tool: "push_down_copilot_customizations",
    workspaceRoot: input.workspaceRoot,
    summary:
      "Pushed bundled Copilot customizations into the destination workspace.",
    artifacts: [normalizeGeneratedPath(summary.artifactPath)],
  };
}

/**
 * Push the bundled Codex and agents customizations into the workspace.
 *
 * @param input Filesystem, extension root, workspace root, optional clock/log.
 * @returns The preserved result record with the normalized artifact path.
 */
export function pushDownCodexAndAgentsCustomizationsServiceCall(
  input: PushDownCodexServiceCallInput,
): PushDownServiceCallResult {
  const sourceRoot = bundledSourceRoot(
    input.extensionRoot,
    "resources/codex-and-agents-customizations",
  );
  const destinationRoot = toPosixPath(input.workspaceRoot);
  const packs =
    input.packs === undefined || input.packs.length === 0
      ? null
      : new Set(input.packs);
  const summary = pushDownCodexAgents({
    repoRoot: sourceRoot,
    destinationRoot,
    fs: input.fs,
    sourceRoot,
    artifactRoot: destinationRoot,
    bundleRoot: sourceRoot,
    packs,
    ...(input.csharpVariant === undefined
      ? {}
      : { csharpVariant: input.csharpVariant }),
    ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
    ...(input.clock === undefined ? {} : { clock: input.clock }),
  });
  return {
    tool: "push_down_codex_and_agents_customizations",
    workspaceRoot: input.workspaceRoot,
    summary:
      "Pushed bundled Codex and agents customizations into the destination workspace.",
    artifacts: [normalizeGeneratedPath(summary.artifactPath)],
  };
}

/**
 * Push the bundled Claude Code customizations into the workspace.
 *
 * Threads the optional pack selection, C# variant, and memory mode into the
 * in-process Claude port. The bundled source root is also the bundle root that
 * holds the pack manifests and the legacy variant subtree.
 *
 * @param input Filesystem, extension root, workspace root, and optional
 *   packs/csharpVariant/memoryMode plus clock/log.
 * @returns The preserved result record with the normalized artifact path.
 */
export function pushDownClaudeCustomizationsServiceCall(
  input: PushDownClaudeServiceCallInput,
): PushDownServiceCallResult {
  const sourceRoot = bundledSourceRoot(
    input.extensionRoot,
    "resources/claude-customizations",
  );
  const destinationRoot = toPosixPath(input.workspaceRoot);
  // The bundled source root already is the claude-customizations directory, so
  // it doubles as the bundle root (manifests and legacy variant live beneath).
  const packs =
    input.packs === undefined || input.packs.length === 0
      ? null
      : new Set(input.packs);
  const summary = pushDownClaude({
    repoRoot: sourceRoot,
    destinationRoot,
    fs: input.fs,
    sourceRoot,
    artifactRoot: destinationRoot,
    bundleRoot: sourceRoot,
    packs,
    ...(input.csharpVariant === undefined
      ? {}
      : { csharpVariant: input.csharpVariant }),
    ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
    ...(input.clock === undefined ? {} : { clock: input.clock }),
  });
  return {
    tool: "push_down_claude_customizations",
    workspaceRoot: input.workspaceRoot,
    summary:
      "Pushed bundled Claude Code customizations into the destination workspace.",
    artifacts: [normalizeGeneratedPath(summary.artifactPath)],
  };
}
