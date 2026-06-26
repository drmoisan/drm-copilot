/**
 * In-process wiring for the `collectPrContext` service method.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.collectPrContext` delegates to,
 *     so the service file stays within the 500-line limit while preserving the
 *     method's observable return contract exactly. Mirrors the
 *     `new-potential-bug-entry-service-call.ts` precedent.
 *
 * Responsibilities:
 *     - Invoke the in-process {@link collectAndWrite} port with the service's
 *       injected runner/filesystem against the workspace root.
 *     - Build the preserved service result record
 *       (`tool`/`workspaceRoot`/`summary`) and the two normalized artifact paths.
 *
 * Side effects:
 *     Writes `artifacts/pr_context.summary.txt` and
 *     `artifacts/pr_context.appendix.txt` through the injected
 *     {@link FileSystem}; runs git/gh through the injected {@link CommandRunner}.
 */

import { join } from "node:path";

import { type FileSystem } from "../file-system";
import { type CommandRunner } from "../subprocess-runner";
import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import { collectAndWrite } from "./collector-output";

/** Repo-relative summary artifact path written by the collector. */
const SUMMARY_OUT = "artifacts/pr_context.summary.txt";
/** Repo-relative appendix artifact path written by the collector. */
const APPENDIX_OUT = "artifacts/pr_context.appendix.txt";

/** Input for {@link collectPrContextServiceCall}. */
export interface CollectPrContextServiceCallInput {
  /** Command runner used for git/gh invocations. */
  readonly runner: CommandRunner;
  /** Filesystem used for discovery and the output writes. */
  readonly fileSystem: FileSystem;
  /** Workspace root the collector runs against and output paths resolve to. */
  readonly workspaceRoot: string;
  /** Base ref the PR context is computed against. */
  readonly base: string;
  /** Optional log sink wired to the service output channel. */
  readonly log?: (message: string) => void;
}

/** Preserved result of the collect-pr-context service call. */
export interface CollectPrContextServiceCallResult {
  readonly tool: "collect_pr_context";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
}

/**
 * Collect PR context in-process and return the preserved service result.
 *
 * Calls {@link collectAndWrite} with the workspace root as the repo root, the
 * two default artifact paths, overwrite mode, untracked files included, and the
 * default real clock. Returns the result record matching the prior
 * Python-spawn shape: `tool`, `workspaceRoot`, the exact summary string, and
 * both normalized artifact paths joined to the workspace root.
 *
 * @param input Runner, filesystem, workspace root, base ref, and optional log.
 * @returns The preserved result record with both artifact paths.
 */
export function collectPrContextServiceCall(
  input: CollectPrContextServiceCallInput,
): CollectPrContextServiceCallResult {
  collectAndWrite({
    base: input.base,
    repoRoot: input.workspaceRoot,
    out: SUMMARY_OUT,
    appendixOut: APPENDIX_OUT,
    append: false,
    includeUntracked: true,
    fs: input.fileSystem,
    runner: input.runner,
    ...(input.log === undefined ? {} : { log: input.log }),
  });

  return {
    tool: "collect_pr_context",
    workspaceRoot: input.workspaceRoot,
    summary: `Collected PR context against base '${input.base}'.`,
    artifacts: [
      normalizeGeneratedPath(join(input.workspaceRoot, SUMMARY_OUT)),
      normalizeGeneratedPath(join(input.workspaceRoot, APPENDIX_OUT)),
    ],
  };
}
