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

/**
 * Verify one artifact write by reading the file back and comparing content.
 *
 * This is a read-back comparison against the exact text this invocation
 * rendered, not an existence check. An existence check is satisfied by a file
 * left behind by a prior invocation, which is the hazard under repair: a stale
 * pair at the expected paths passes existence and misdescribes the branch.
 *
 * @param fileSystem Filesystem the write was performed through.
 * @param artifactPath Absolute path this invocation wrote.
 * @param expected The exact text this invocation rendered for that path.
 * @throws Error naming `artifactPath` when the read fails or content differs.
 */
function verifyWrittenArtifact(
  fileSystem: FileSystem,
  artifactPath: string,
  expected: string,
): void {
  let actual: string;
  try {
    actual = fileSystem.readTextFile(artifactPath);
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new Error(
      `Failed to verify PR context artifact '${artifactPath}': the file could not be read back after writing (${detail}).`,
    );
  }
  if (actual !== expected) {
    throw new Error(
      `Failed to verify PR context artifact '${artifactPath}': the content read back is not the content this invocation rendered (expected ${String(expected.length)} characters, read back ${String(actual.length)}).`,
    );
  }
}

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
  // Each absolute output path is evaluated exactly once, here. The same
  // variable is the write target, the verification read target, the log-line
  // value, and the reported artifact entry, so the written set and the reported
  // set cannot drift apart. Normalizing before the write rather than after it is
  // required: `join` emits backslash separators on Windows, so a write using the
  // raw joined value while the report used the normalized value would remain two
  // different strings. Node accepts forward-slash separators on Windows, so the
  // write is unaffected.
  const summaryOut = normalizeGeneratedPath(
    join(input.workspaceRoot, SUMMARY_OUT),
  );
  const appendixOut = normalizeGeneratedPath(
    join(input.workspaceRoot, APPENDIX_OUT),
  );

  const rendered = collectAndWrite({
    base: input.base,
    repoRoot: input.workspaceRoot,
    out: summaryOut,
    appendixOut,
    append: false,
    includeUntracked: true,
    fs: input.fileSystem,
    runner: input.runner,
    ...(input.log === undefined ? {} : { log: input.log }),
  });

  verifyWrittenArtifact(input.fileSystem, summaryOut, rendered.summaryText);
  verifyWrittenArtifact(input.fileSystem, appendixOut, rendered.appendixText);

  return {
    tool: "collect_pr_context",
    workspaceRoot: input.workspaceRoot,
    summary: `Collected PR context against base '${input.base}'.`,
    artifacts: [summaryOut, appendixOut],
  };
}
