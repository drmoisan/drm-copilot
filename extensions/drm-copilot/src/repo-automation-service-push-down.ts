import {
  type PushDownCodexAndAgentsCustomizationsInput,
  type PushDownClaudeCustomizationsInput,
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

/**
 * Forwarded options for the in-process Claude customization push-down call.
 *
 * Replaces the prior Python arg-vector builder. The three push-down service
 * methods now invoke the in-process TypeScript port (F3), so this builder only
 * carries the destination workspace root plus the optional pack selection, C#
 * variant, and memory mode forwarded to `pushDownClaudeCustomizationsServiceCall`.
 */
export interface PushDownClaudeServiceForwardedOptions {
  /** Destination workspace root that receives the copied `.claude` tree. */
  readonly workspaceRoot: string;
  /** Optional language-pack selection. */
  readonly packs?: ReadonlyArray<string>;
  /** Optional C# toolchain variant. */
  readonly csharpVariant?: CSharpVariant;
  /** Optional agent-memory handling mode. */
  readonly memoryMode?: MemoryMode;
}

export interface PushDownCodexServiceForwardedOptions {
  readonly workspaceRoot: string;
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: CodexCSharpVariant;
  readonly memoryMode?: CodexMemoryMode;
}

/**
 * Build the forwarded options for the in-process Claude push-down call.
 *
 * Carries the workspace root and only the optional selection fields that were
 * supplied, so a no-field input forwards just the workspace root (matching the
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
    ...(input.packs === undefined ? {} : { packs: input.packs }),
    ...(input.csharpVariant === undefined
      ? {}
      : { csharpVariant: input.csharpVariant }),
    ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
  };
}

export function buildPushDownCodexAndAgentsCustomizationsOptions(
  input: PushDownCodexAndAgentsCustomizationsInput,
): PushDownCodexServiceForwardedOptions {
  return {
    workspaceRoot: input.workspaceRoot,
    ...(input.packs === undefined ? {} : { packs: input.packs }),
    ...(input.csharpVariant === undefined
      ? {}
      : { csharpVariant: input.csharpVariant }),
    ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
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
 * @param workspaceRoot Destination workspace root.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
export function runPushDownCopilotCustomizations(
  workspaceRoot: string,
  deps: PushDownServiceDeps,
): RepoAutomationExecutionResult {
  return pushDownCopilotCustomizationsServiceCall({
    fs: deps.fs,
    extensionRoot: deps.extensionRoot,
    workspaceRoot,
    log: deps.log,
  });
}

/**
 * Run the in-process Codex/agents push-down service call.
 *
 * @param workspaceRoot Destination workspace root.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
export function runPushDownCodexAndAgentsCustomizations(
  input: PushDownCodexAndAgentsCustomizationsInput,
  deps: PushDownServiceDeps,
): RepoAutomationExecutionResult {
  const forwarded = buildPushDownCodexAndAgentsCustomizationsOptions(input);
  return pushDownCodexAndAgentsCustomizationsServiceCall({
    fs: deps.fs,
    extensionRoot: deps.extensionRoot,
    workspaceRoot: forwarded.workspaceRoot,
    log: deps.log,
    ...(forwarded.packs === undefined ? {} : { packs: forwarded.packs }),
    ...(forwarded.csharpVariant === undefined
      ? {}
      : { csharpVariant: forwarded.csharpVariant }),
    ...(forwarded.memoryMode === undefined
      ? {}
      : { memoryMode: forwarded.memoryMode }),
  });
}

/**
 * Run the in-process Claude push-down service call from a service input.
 *
 * Keeps the optional pack/variant/memory forwarding out of the service file so
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
  const forwarded = buildPushDownClaudeCustomizationsOptions(input);
  return pushDownClaudeCustomizationsServiceCall({
    fs: deps.fs,
    extensionRoot: deps.extensionRoot,
    workspaceRoot: forwarded.workspaceRoot,
    log: deps.log,
    ...(forwarded.packs === undefined ? {} : { packs: forwarded.packs }),
    ...(forwarded.csharpVariant === undefined
      ? {}
      : { csharpVariant: forwarded.csharpVariant }),
    ...(forwarded.memoryMode === undefined
      ? {}
      : { memoryMode: forwarded.memoryMode }),
  });
}
