/**
 * In-process service wiring for the three push-down command variants.
 *
 * Purpose:
 *     Hold the bodies that the three `RepoAutomationService` push-down methods
 *     delegate to, so the service file stays within the 500-line limit while
 *     preserving each method's observable return contract. Each function calls
 *     the unified push-down harness with exactly its own ecosystem (issue #1029)
 *     and returns a `RepoAutomationExecutionResult`-shaped record preserving the
 *     prior `tool`, `summary`, and single-element `artifacts` contract, plus the
 *     optional `pushDownReport`.
 *
 * Side effects:
 *     Reads bundled source files and, unless the call is a dry run, writes
 *     destination files, the destination manifest, and the summary artifact
 *     through the injected {@link PushDownFileSystem}.
 */

import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import { type RepoAutomationToolName } from "../../repo-automation-tool-names";
import { type PushDownFileSystem, toPosixPath } from "./filesystem-adapter";
import { type Clock } from "./copilot-customizations-engine";
import {
  type CSharpVariant as CodexCSharpVariant,
  type MemoryMode as CodexMemoryMode,
} from "./codex-pack-selection";
import { type CSharpVariant, type MemoryMode } from "./claude-pack-selection";
import { type CiWorkflowsMode } from "./push-down-ci-workflows";
import { pushDownHarness } from "./push-down-harness";
import {
  type EcosystemName,
  type EcosystemSelectionInput,
} from "./push-down-layer";
import { type PushDownReport } from "./push-down-report";

/** Preserved result shape of a push-down service call. */
export interface PushDownServiceCallResult {
  readonly tool: RepoAutomationToolName;
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
  /** Exclusion and conflict lines; present only when there is at least one. */
  readonly warnings?: ReadonlyArray<string>;
  /** Dry-run or apply report of the push-down pipeline (issue #1029). */
  readonly pushDownReport?: PushDownReport;
}

/** Common input for every push-down service call. */
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
  /** Plan and report only; write nothing. */
  readonly dryRun?: boolean;
  /** Overwrite `unmanaged-conflict` files (O-4 opt-in). */
  readonly overwriteUnmanaged?: boolean;
  /** Destination CI mode (issue #1050); omitted reuses the recorded mode. */
  readonly ciWorkflows?: CiWorkflowsMode;
}

/** Input for the Copilot service call (adds the Copilot pack selection). */
export interface PushDownCopilotServiceCallInput extends PushDownServiceCallInput {
  readonly packs?: ReadonlyArray<string>;
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

/** Per-ecosystem wording of the preserved result. */
interface ServiceCallDescriptor {
  readonly ecosystem: EcosystemName;
  readonly tool: RepoAutomationToolName;
  readonly label: string;
}

/**
 * Copy only the selection fields that are present.
 *
 * @param input Service-call input.
 * @returns The selection input of the harness.
 */
function selectionOf(input: {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}): EcosystemSelectionInput {
  return {
    ...(input.packs === undefined ? {} : { packs: input.packs }),
    ...(input.csharpVariant === undefined
      ? {}
      : { csharpVariant: input.csharpVariant }),
    ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
  };
}

/**
 * Run the harness for exactly one ecosystem and shape the preserved result.
 *
 * @param input Service-call input.
 * @param selection Selection input of the ecosystem.
 * @param descriptor Ecosystem, tool name, and summary label.
 * @returns The preserved result record.
 */
function runServiceCall(
  input: PushDownServiceCallInput,
  selection: EcosystemSelectionInput,
  descriptor: ServiceCallDescriptor,
): PushDownServiceCallResult {
  const result = pushDownHarness({
    extensionRoot: input.extensionRoot,
    destinationRoot: toPosixPath(input.workspaceRoot),
    fs: input.fs,
    ecosystems: { [descriptor.ecosystem]: selection },
    dryRun: input.dryRun === true,
    overwriteUnmanaged: input.overwriteUnmanaged === true,
    ...(input.ciWorkflows === undefined
      ? {}
      : { ciWorkflows: input.ciWorkflows }),
    ...(input.clock === undefined ? {} : { clock: input.clock }),
  });
  // Exclusion and conflict lines reach the output channel through the log
  // sink and the caller through `warnings`; both stay silent when empty.
  for (const line of result.warnings) {
    input.log?.(line);
  }
  const dryRun = input.dryRun === true;
  return {
    tool: descriptor.tool,
    workspaceRoot: input.workspaceRoot,
    summary: dryRun
      ? `Dry run: planned bundled ${descriptor.label} customizations; no file was written.`
      : `Pushed bundled ${descriptor.label} customizations into the destination workspace.`,
    artifacts: dryRun
      ? []
      : [normalizeGeneratedPath(result.summary.artifactPath)],
    ...(result.warnings.length > 0 ? { warnings: result.warnings } : {}),
    pushDownReport: result.report,
  };
}

/**
 * Push the bundled Copilot customizations into the destination workspace.
 *
 * @param input Filesystem, extension root, workspace root, optional packs,
 *   dry-run and overwrite options, clock and log.
 * @returns The preserved result record with the normalized artifact path.
 */
export function pushDownCopilotCustomizationsServiceCall(
  input: PushDownCopilotServiceCallInput,
): PushDownServiceCallResult {
  return runServiceCall(input, selectionOf(input), {
    ecosystem: "copilot",
    tool: "push_down_copilot_customizations",
    label: "Copilot",
  });
}

/**
 * Push the bundled Codex and agents customizations into the workspace.
 *
 * @param input Filesystem, extension root, workspace root, optional selection,
 *   dry-run and overwrite options, clock and log.
 * @returns The preserved result record with the normalized artifact path.
 */
export function pushDownCodexAndAgentsCustomizationsServiceCall(
  input: PushDownCodexServiceCallInput,
): PushDownServiceCallResult {
  return runServiceCall(input, selectionOf(input), {
    ecosystem: "codex",
    tool: "push_down_codex_and_agents_customizations",
    label: "Codex and agents",
  });
}

/**
 * Push the bundled Claude Code customizations into the workspace.
 *
 * @param input Filesystem, extension root, workspace root, and optional
 *   packs/csharpVariant/memoryMode plus dry-run, overwrite, clock and log.
 * @returns The preserved result record with the normalized artifact path.
 */
export function pushDownClaudeCustomizationsServiceCall(
  input: PushDownClaudeServiceCallInput,
): PushDownServiceCallResult {
  return runServiceCall(input, selectionOf(input), {
    ecosystem: "claude",
    tool: "push_down_claude_customizations",
    label: "Claude Code",
  });
}
