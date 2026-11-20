import {
  type PushDownCodexAndAgentsCustomizationsInput,
  type PushDownClaudeCustomizationsInput,
  type PushDownCopilotCustomizationsInput,
  type RepoAutomationExecutionResult,
} from "./repo-automation-service";
import {
  type CSharpVariant as CodexCSharpVariant,
  type MemoryMode as CodexMemoryMode,
} from "./lib/push-down/codex-pack-selection";
import {
  type CSharpVariant,
  type MemoryMode,
} from "./lib/push-down/claude-customizations";
import { type PushDownFileSystem } from "./lib/push-down/filesystem-adapter";
import {
  pushDownClaudeCustomizationsServiceCall,
  pushDownCodexAndAgentsCustomizationsServiceCall,
  pushDownCopilotCustomizationsServiceCall,
} from "./lib/push-down/push-down-service-call";

/** Run options forwarded to every push-down service call (issue #1029). */
interface PushDownForwardedRunOptions {
  /** Plan and report only; write nothing. */
  readonly dryRun?: boolean;
  /** Overwrite `unmanaged-conflict` files (O-4 opt-in). */
  readonly overwriteUnmanaged?: boolean;
  /** Destination CI mode (issue #1050); omitted reuses the recorded mode. */
  readonly ciWorkflows?: "off" | "reference" | "copy";
}

/**
 * Forwarded options for the in-process Claude customization push-down call.
 *
 * Carries the destination workspace root plus the optional pack selection, C#
 * variant, memory mode, and run options forwarded to
 * `pushDownClaudeCustomizationsServiceCall`.
 */
export interface PushDownClaudeServiceForwardedOptions extends PushDownForwardedRunOptions {
  /** Destination workspace root that receives the copied `.claude` tree. */
  readonly workspaceRoot: string;
  /** Optional language-pack selection. */
  readonly packs?: ReadonlyArray<string>;
  /** Optional C# toolchain variant. */
  readonly csharpVariant?: CSharpVariant;
  /** Optional agent-memory handling mode. */
  readonly memoryMode?: MemoryMode;
}

/** Forwarded options for the in-process Codex/agents push-down call. */
export interface PushDownCodexServiceForwardedOptions extends PushDownForwardedRunOptions {
  readonly workspaceRoot: string;
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: CodexCSharpVariant;
  readonly memoryMode?: CodexMemoryMode;
}

/** Forwarded options for the in-process Copilot push-down call. */
export interface PushDownCopilotServiceForwardedOptions extends PushDownForwardedRunOptions {
  readonly workspaceRoot: string;
  readonly packs?: ReadonlyArray<string>;
}

/**
 * Copy the run options that were supplied.
 *
 * @param input A push-down service input.
 * @returns `dryRun`, `overwriteUnmanaged`, and `ciWorkflows`, each only when
 *   present.
 */
function forwardRunOptions(
  input: PushDownForwardedRunOptions,
): PushDownForwardedRunOptions {
  return {
    ...(input.dryRun === undefined ? {} : { dryRun: input.dryRun }),
    ...(input.overwriteUnmanaged === undefined
      ? {}
      : { overwriteUnmanaged: input.overwriteUnmanaged }),
    ...(input.ciWorkflows === undefined
      ? {}
      : { ciWorkflows: input.ciWorkflows }),
  };
}

/**
 * Copy the pack, variant, and memory fields that were supplied.
 *
 * @param input A Claude or Codex push-down service input.
 * @returns The present selection fields.
 */
function forwardSelection<
  Variant extends string,
  Memory extends string,
>(input: {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: Variant;
  readonly memoryMode?: Memory;
}): {
  packs?: ReadonlyArray<string>;
  csharpVariant?: Variant;
  memoryMode?: Memory;
} {
  return {
    ...(input.packs === undefined ? {} : { packs: input.packs }),
    ...(input.csharpVariant === undefined
      ? {}
      : { csharpVariant: input.csharpVariant }),
    ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
  };
}

/**
 * Build the forwarded options for the in-process Claude push-down call.
 *
 * Carries the workspace root and only the optional fields that were supplied,
 * so a no-field input forwards just the workspace root (matching the
 * backward-compatible publish-everything default).
 *
 * @param input The Claude push-down service input.
 * @returns Forwarded options for `pushDownClaudeCustomizationsServiceCall`.
 */
export function buildPushDownClaudeCustomizationsOptions(
  input: PushDownClaudeCustomizationsInput,
): PushDownClaudeServiceForwardedOptions {
  return {
    workspaceRoot: input.workspaceRoot,
    ...forwardSelection(input),
    ...forwardRunOptions(input),
  };
}

/**
 * Build the forwarded options for the in-process Codex/agents push-down call.
 *
 * @param input The Codex push-down service input.
 * @returns Forwarded options for `pushDownCodexAndAgentsCustomizationsServiceCall`.
 */
export function buildPushDownCodexAndAgentsCustomizationsOptions(
  input: PushDownCodexAndAgentsCustomizationsInput,
): PushDownCodexServiceForwardedOptions {
  return {
    workspaceRoot: input.workspaceRoot,
    ...forwardSelection(input),
    ...forwardRunOptions(input),
  };
}

/**
 * Build the forwarded options for the in-process Copilot push-down call.
 *
 * @param input The Copilot push-down service input.
 * @returns Forwarded options for `pushDownCopilotCustomizationsServiceCall`.
 */
export function buildPushDownCopilotCustomizationsOptions(
  input: PushDownCopilotCustomizationsInput,
): PushDownCopilotServiceForwardedOptions {
  return {
    workspaceRoot: input.workspaceRoot,
    ...(input.packs === undefined ? {} : { packs: input.packs }),
    ...forwardRunOptions(input),
  };
}

/** Dependencies the push-down service calls need from the service. */
export interface PushDownServiceDeps {
  /** Injected push-down filesystem. */
  readonly fs: PushDownFileSystem;
  /** Extension root used to resolve the bundled source tree. */
  readonly extensionRoot: string;
  /** Log sink wired to the service output channel. */
  readonly log: (message: string) => void;
}

/**
 * Run the in-process Copilot push-down service call.
 *
 * @param input The Copilot push-down service input.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
export function runPushDownCopilotCustomizations(
  input: PushDownCopilotCustomizationsInput,
  deps: PushDownServiceDeps,
): RepoAutomationExecutionResult {
  return pushDownCopilotCustomizationsServiceCall({
    fs: deps.fs,
    extensionRoot: deps.extensionRoot,
    log: deps.log,
    ...buildPushDownCopilotCustomizationsOptions(input),
  });
}

/**
 * Run the in-process Codex/agents push-down service call.
 *
 * @param input The Codex push-down service input.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
export function runPushDownCodexAndAgentsCustomizations(
  input: PushDownCodexAndAgentsCustomizationsInput,
  deps: PushDownServiceDeps,
): RepoAutomationExecutionResult {
  return pushDownCodexAndAgentsCustomizationsServiceCall({
    fs: deps.fs,
    extensionRoot: deps.extensionRoot,
    log: deps.log,
    ...buildPushDownCodexAndAgentsCustomizationsOptions(input),
  });
}

/**
 * Run the in-process Claude push-down service call from a service input.
 *
 * Keeps the optional forwarding out of the service file so
 * `repo-automation-service.ts` stays within the 500-line limit. Forwards only
 * the optional fields that were supplied.
 *
 * @param input The Claude push-down service input.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
export function runPushDownClaudeCustomizations(
  input: PushDownClaudeCustomizationsInput,
  deps: PushDownServiceDeps,
): RepoAutomationExecutionResult {
  return pushDownClaudeCustomizationsServiceCall({
    fs: deps.fs,
    extensionRoot: deps.extensionRoot,
    log: deps.log,
    ...buildPushDownClaudeCustomizationsOptions(input),
  });
}
