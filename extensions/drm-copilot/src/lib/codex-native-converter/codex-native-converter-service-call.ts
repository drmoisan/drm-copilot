/**
 * In-process wiring for the `runCodexNativeConverter` service method.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.runCodexNativeConverter`
 *     delegates to, so the service file stays within the 500-line limit while
 *     preserving the method's observable return contract exactly. Mirrors the
 *     `new-potential-bug-entry-service-call.ts` and `pr-context-service-call.ts`
 *     precedents. Replaces the prior Python spawn of
 *     `resources/templates/codex_native_converter.py` with a direct in-process
 *     call to the ported engine.
 *
 * Responsibilities:
 *     - Resolve `sourceRoot` against the workspace root, default `artifactRoot`
 *       to `<sourceRoot>/artifacts/codex-native-converter`, and resolve
 *       `destinationRoot`, exactly as the Python `_resolve_run_options` did.
 *     - Run `runReviewMode` or `runApplyMode` from the ported engine with the
 *       injected {@link FileSystem}.
 *     - Build the preserved result record (tool/workspaceRoot/exact summary) and
 *       expose the conversion-report parent directory as the single artifact,
 *       matching the value the prior Python `Artifact root:` stdout pattern
 *       produced.
 *
 * Side effects:
 *     Reads source files and writes report artifacts (and, in clean apply runs,
 *     destination files) through the injected {@link FileSystem}.
 */

import * as path from "node:path";

import { type FileSystem, toPosixPath } from "../file-system";
import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import { type RunOptions, type SourceEcosystem } from "./models";
import { runApplyMode, runReviewMode } from "./engine";

/** Input for {@link runCodexNativeConverterServiceCall}. */
export interface RunCodexNativeConverterServiceCallInput {
  /** Injected filesystem for source reads and artifact/destination writes. */
  readonly fileSystem: FileSystem;
  /** Workspace root that relative source/output paths resolve against. */
  readonly workspaceRoot: string;
  /** Requested converter mode. */
  readonly mode: "review" | "apply";
  /** Declared source ecosystem. */
  readonly sourceEcosystem: "github-copilot" | "claude";
  /** Source runtime root, resolved against the workspace root when relative. */
  readonly sourceRoot: string;
  /** Optional source-root-relative path filter. */
  readonly selectedPaths?: ReadonlyArray<string> | undefined;
  /** Optional destination root for native output (required by apply mode). */
  readonly destinationRoot?: string | undefined;
  /** Optional artifact output root. */
  readonly artifactRoot?: string | undefined;
  /** Whether repository-convention `.codex/prompts` output is enabled. */
  readonly enableRepoPrompts?: boolean | undefined;
  /** Optional log sink wired to the service output channel. */
  readonly log?: ((message: string) => void) | undefined;
}

/** Preserved result of the run-codex-native-converter service call. */
export interface RunCodexNativeConverterServiceCallResult {
  readonly tool: "run_codex_native_converter";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
}

/**
 * Determine whether a path is already absolute (POSIX root or Windows drive).
 *
 * @param value Candidate path.
 * @returns True when the path is absolute.
 */
function isAbsolutePath(value: string): boolean {
  return value.startsWith("/") || /^[A-Za-z]:/.test(value);
}

/**
 * Resolve a possibly-relative path against the workspace root and normalize it
 * to POSIX text, mirroring the Python CLI's `Path.resolve()` behavior. An
 * already-absolute path (POSIX root or Windows drive) is normalized in place so
 * the host current-drive is not prepended to POSIX-absolute inputs.
 *
 * @param workspaceRoot Workspace root used as the resolution base.
 * @param value Path that may be absolute or workspace-relative.
 * @returns The absolute POSIX path.
 */
function resolveAgainstWorkspace(workspaceRoot: string, value: string): string {
  const normalizedValue = toPosixPath(value);
  if (isAbsolutePath(normalizedValue)) {
    return normalizedValue.replace(/\/+$/, "");
  }
  return toPosixPath(
    path.posix.join(toPosixPath(workspaceRoot), normalizedValue),
  ).replace(/\/+$/, "");
}

/**
 * Derive the parent directory of the conversion-report path.
 *
 * Mirrors the Python `conversion_report.parent.as_posix()` value that the prior
 * `Artifact root:` stdout pattern captured.
 *
 * @param conversionReportPath POSIX path to the conversion report.
 * @returns The POSIX parent directory of the report.
 */
function reportParent(conversionReportPath: string): string {
  const normalized = toPosixPath(conversionReportPath);
  const slashIndex = normalized.lastIndexOf("/");
  return slashIndex >= 0 ? normalized.slice(0, slashIndex) : "";
}

/**
 * Run the Codex-native converter in-process and return the preserved service
 * result record.
 *
 * Builds {@link RunOptions} from the input (resolving roots against the
 * workspace and defaulting the artifact root), runs the requested engine mode
 * with the injected filesystem, and returns the preserved result with the
 * conversion-report parent directory as the single artifact.
 *
 * @param input Filesystem, workspace root, mode, ecosystem, roots, filters,
 *   flags, and optional log sink.
 * @returns The preserved result record (`tool`, `workspaceRoot`, exact
 *   `summary`) enriched with the artifact-root directory as one `artifacts`
 *   entry.
 * @throws Error When a required source file cannot be read or an artifact
 *   cannot be written.
 */
export function runCodexNativeConverterServiceCall(
  input: RunCodexNativeConverterServiceCallInput,
): RunCodexNativeConverterServiceCallResult {
  const sourceRoot = resolveAgainstWorkspace(
    input.workspaceRoot,
    input.sourceRoot,
  );
  const destinationRoot =
    input.destinationRoot !== undefined && input.destinationRoot !== ""
      ? resolveAgainstWorkspace(input.workspaceRoot, input.destinationRoot)
      : null;
  const artifactRoot =
    input.artifactRoot !== undefined && input.artifactRoot !== ""
      ? resolveAgainstWorkspace(input.workspaceRoot, input.artifactRoot)
      : `${sourceRoot}/artifacts/codex-native-converter`;

  const runOptions: RunOptions = {
    mode: input.mode,
    sourceRoot,
    sourceEcosystem: input.sourceEcosystem as SourceEcosystem,
    selectedPaths: (input.selectedPaths ?? []).map((selectedPath) =>
      toPosixPath(selectedPath),
    ),
    destinationRoot,
    artifactRoot,
    enableRepoPrompts: input.enableRepoPrompts ?? false,
    emitIntermediateState: false,
  };

  // Review mode never mutates a destination; apply mode writes only when the
  // plan is clean. The engine enforces both behaviors.
  const result =
    input.mode === "apply"
      ? runApplyMode(input.fileSystem, runOptions)
      : runReviewMode(input.fileSystem, runOptions);

  if (input.log !== undefined) {
    input.log(
      `Ran bundled codex-native-converter in ${input.mode} mode for '${input.sourceEcosystem}'.`,
    );
  }

  return {
    tool: "run_codex_native_converter",
    workspaceRoot: input.workspaceRoot,
    summary: `Ran bundled codex-native-converter in ${input.mode} mode for '${input.sourceEcosystem}'.`,
    artifacts: [
      normalizeGeneratedPath(reportParent(result.reportPaths.conversionReport)),
    ],
  };
}
