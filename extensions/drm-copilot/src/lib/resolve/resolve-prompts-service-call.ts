/**
 * In-process wiring for the two resolve-prompt service methods.
 *
 * Purpose:
 *     Hold the bodies that `RepoAutomationService.resolveExecuteHardLockPrompt`
 *     and `resolveAtomicPlanPrompt` delegate to, so the service file stays
 *     within the 500-line limit while preserving each method's observable
 *     return contract exactly. Mirrors the F2 `validate-orchestration-service-
 *     call.ts` precedent.
 *
 * Responsibilities:
 *     - Resolve the injected template root / template path from `extensionRoot`
 *       (the values the bundled wrappers inject).
 *     - Invoke the in-process resolvers with a no-op clipboard seam so the
 *       quiet/MCP path performs no real OS clipboard interaction.
 *     - Build the preserved service result records and surface non-zero command
 *       outcomes as thrown errors.
 *
 * Side effects:
 *     Reads templates/targets and writes the hard-lock output file through the
 *     injected {@link FileSystem}; performs no other I/O.
 */

import * as path from "node:path";
import { type FileSystem, toPosixPath } from "../file-system";
import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import { isAbsolutePathLike } from "../../workflow-command-arguments";
import { resolveExecuteHardLockCommand } from "./hard-lock-prompt";
import { resolveAtomicPlanCommand } from "./file-prompt-core";

/** Input for {@link resolveExecuteHardLockPromptServiceCall}. */
export interface ResolveExecuteHardLockPromptServiceCallInput {
  /** Injected filesystem used for template/target reads and the output write. */
  readonly fileSystem: FileSystem;
  /** Extension root used to resolve the bundled hard-lock template root. */
  readonly extensionRoot: string;
  /** Workspace root the target/output paths are resolved against. */
  readonly workspaceRoot: string;
  /** Target plan file path. */
  readonly target: string;
  /** Optional output path; relative paths resolve against the workspace root. */
  readonly output?: string | undefined;
  /** When true, suppress stdout/clipboard (requires `output`). */
  readonly quiet?: boolean | undefined;
  /** Optional log sink wired to the service output channel. */
  readonly log?: ((message: string) => void) | undefined;
}

/** Preserved result of the hard-lock service call. */
export interface ResolveExecuteHardLockPromptServiceCallResult {
  readonly tool: "resolve_execute_hard_lock_prompt";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: ReadonlyArray<string>;
}

/** Input for {@link resolveAtomicPlanPromptServiceCall}. */
export interface ResolveAtomicPlanPromptServiceCallInput {
  /** Injected filesystem used for template/target reads. */
  readonly fileSystem: FileSystem;
  /** Extension root used to resolve the bundled atomic-plan template path. */
  readonly extensionRoot: string;
  /** Workspace root the target path is resolved against. */
  readonly workspaceRoot: string;
  /** Target plan file path. */
  readonly target: string;
  /** Optional log sink wired to the service output channel. */
  readonly log?: (message: string) => void;
}

/** Preserved result of the atomic-plan service call. */
export interface ResolveAtomicPlanPromptServiceCallResult {
  readonly tool: "resolve_atomic_plan_prompt";
  readonly workspaceRoot: string;
  readonly summary: string;
}

/**
 * Resolve the execute hard-lock prompt in-process.
 *
 * Enforces the preserved TS-layer guard (`quiet` requires `output`) before any
 * file work, resolves the bundled hard-lock template root from `extensionRoot`,
 * invokes {@link resolveExecuteHardLockCommand} with a no-op clipboard seam,
 * surfaces a non-zero command outcome as a thrown error, and returns the
 * preserved result record (with `artifacts` computed exactly as the prior
 * `buildResolveExecuteHardLockPromptArguments`).
 *
 * @param input Filesystem, extension/workspace roots, target, and optional
 *   output/quiet/log.
 * @returns The preserved hard-lock service result record.
 * @throws Error When `quiet` is set without `output`, or when the command
 *   reports a non-zero exit (the message carries the command's error text).
 */
export function resolveExecuteHardLockPromptServiceCall(
  input: ResolveExecuteHardLockPromptServiceCallInput,
): ResolveExecuteHardLockPromptServiceCallResult {
  // Preserve the existing TS-layer guard message verbatim; it must run before
  // any file work, matching the prior builder-level guard and its test.
  if (input.quiet === true && input.output === undefined) {
    throw new Error(
      "resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.",
    );
  }

  const templateRoot = toPosixPath(
    path.join(
      input.extensionRoot,
      "resources",
      "customizations",
      ".github",
      "codex",
    ),
  );

  // Capture the command's emitted lines so a non-zero exit can be surfaced as a
  // thrown error while still forwarding output to the service log sink.
  const emittedLines: string[] = [];
  const log = (message: string): void => {
    emittedLines.push(message);
    input.log?.(message);
  };

  const result = resolveExecuteHardLockCommand({
    targetPath: input.target,
    workspaceRoot: input.workspaceRoot,
    templateKind: "execute",
    templateRoot,
    ...(input.output === undefined ? {} : { output: input.output }),
    ...(input.quiet === undefined ? {} : { quiet: input.quiet }),
    fs: input.fileSystem,
    copyToClipboard: () => false,
    log,
  });

  if (result.exitCode !== 0) {
    throw new Error(
      `resolve_execute_hard_lock_prompt failed:\n${emittedLines.join("\n")}`,
    );
  }

  const artifacts =
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
    tool: "resolve_execute_hard_lock_prompt",
    workspaceRoot: input.workspaceRoot,
    summary: `Resolved the execute hard-lock prompt for '${input.target}'.`,
    ...(artifacts === undefined ? {} : { artifacts }),
  };
}

/**
 * Resolve the atomic-plan prompt in-process.
 *
 * Resolves the bundled atomic-plan template path from `extensionRoot`, resolves
 * the target against the workspace root when relative (absolute used verbatim),
 * invokes {@link resolveAtomicPlanCommand} with a no-op clipboard seam (so the
 * "could not copy" branch is the deterministic outcome), surfaces a non-zero
 * command outcome as a thrown error, and returns the preserved result record
 * with no `artifacts` field.
 *
 * @param input Filesystem, extension/workspace roots, target, and optional log.
 * @returns The preserved atomic-plan service result record.
 * @throws Error When the command reports a non-zero exit (the message carries
 *   the command's error text).
 */
export function resolveAtomicPlanPromptServiceCall(
  input: ResolveAtomicPlanPromptServiceCallInput,
): ResolveAtomicPlanPromptServiceCallResult {
  const templatePath = toPosixPath(
    path.join(
      input.extensionRoot,
      "resources",
      "customizations",
      ".github",
      "prompts",
      "generate-atomic-plan.prompt.md",
    ),
  );

  const targetPath = isAbsolutePathLike(input.target)
    ? toPosixPath(input.target)
    : toPosixPath(path.join(input.workspaceRoot, input.target));

  const emittedLines: string[] = [];
  const log = (message: string): void => {
    emittedLines.push(message);
    input.log?.(message);
  };

  const result = resolveAtomicPlanCommand({
    templatePath,
    targetPath,
    workspaceRoot: input.workspaceRoot,
    fs: input.fileSystem,
    copyToClipboard: () => false,
    log,
  });

  if (result.exitCode !== 0) {
    throw new Error(
      `resolve_atomic_plan_prompt failed:\n${emittedLines.join("\n")}`,
    );
  }

  return {
    tool: "resolve_atomic_plan_prompt",
    workspaceRoot: input.workspaceRoot,
    summary: `Resolved the atomic-plan prompt for '${input.target}'.`,
  };
}
