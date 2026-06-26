/**
 * TypeScript argument-parser surface for the Codex-native converter CLI.
 *
 * Purpose:
 *     Port the Typer CLI surface of `cli.py` to a host-neutral argument layer
 *     (`resolveSourceEcosystem`, `resolveRunOptions`, `printRunSummary`, and the
 *     `review`/`apply` command functions). The Typer dependency is replaced by
 *     plain functions plus an injected log sink. Filesystem checks flow through
 *     the injected {@link FileSystem}.
 *
 * Invariants:
 *     Input-validation error strings and summary lines are preserved verbatim.
 *     Apply mode reports a non-zero exit code when destination output was not
 *     written and a blocking finding remains.
 */

import { type FileSystem, toPosixPath } from "../file-system";
import {
  type ConversionRunResult,
  runApplyMode,
  runReviewMode,
} from "./engine";
import {
  type RunOptions,
  type SourceEcosystem,
  SourceEcosystem as SourceEcosystemValues,
} from "./models";

/** Options shared by the review and apply command functions. */
export interface ConverterCommandOptions {
  readonly sourceRoot: string;
  readonly sourceEcosystem: string;
  readonly selectedPaths?: ReadonlyArray<string>;
  readonly destinationRoot?: string | null;
  readonly artifactRoot?: string | null;
  readonly enableRepoPrompts?: boolean;
  readonly emitIntermediateState?: boolean;
}

/** Outcome of one CLI command: the engine result and an exit-code value. */
export interface ConverterCommandOutcome {
  readonly result: ConversionRunResult;
  readonly exitCode: number;
}

/**
 * Strip a single trailing slash for normalized path joining.
 *
 * @param value POSIX path.
 * @returns The path without a trailing slash.
 */
function stripTrailingSlash(value: string): string {
  return value.replace(/\/+$/, "");
}

/**
 * Join a POSIX root with a child segment.
 *
 * @param root POSIX root path.
 * @param child Child path segment.
 * @returns The combined POSIX path.
 */
function joinPosix(root: string, child: string): string {
  const normalizedRoot = stripTrailingSlash(root);
  const normalizedChild = child.replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedChild
    : `${normalizedRoot}/${normalizedChild}`;
}

/**
 * Resolve one CLI source-ecosystem string into the typed enum value.
 *
 * Mirrors `_resolve_source_ecosystem`.
 *
 * @param sourceEcosystem CLI-provided source ecosystem value.
 * @returns The resolved ecosystem value.
 * @throws Error When the ecosystem value is unsupported. The message is
 *   preserved verbatim: `source_ecosystem must be 'github-copilot' or 'claude'.`
 */
export function resolveSourceEcosystem(
  sourceEcosystem: string,
): SourceEcosystem {
  const supported: ReadonlyArray<string> = [
    SourceEcosystemValues.GITHUB_COPILOT,
    SourceEcosystemValues.CLAUDE,
  ];
  if (!supported.includes(sourceEcosystem)) {
    throw new Error("source_ecosystem must be 'github-copilot' or 'claude'.");
  }
  return sourceEcosystem as SourceEcosystem;
}

/**
 * Validate CLI input and build one run-options value.
 *
 * Mirrors `_resolve_run_options`: validates the source root exists as a
 * directory, requires a destination root for apply mode, defaults the artifact
 * root to `<sourceRoot>/artifacts/codex-native-converter`, and normalizes paths
 * to POSIX text.
 *
 * @param fileSystem Injected filesystem.
 * @param options Command options including the requested mode.
 * @returns Validated run options for the engine.
 * @throws Error When a required input is missing or invalid. Messages are
 *   preserved verbatim from the Python CLI.
 */
export function resolveRunOptions(
  fileSystem: FileSystem,
  options: ConverterCommandOptions & { readonly mode: string },
): RunOptions {
  const resolvedSourceRoot = stripTrailingSlash(
    toPosixPath(options.sourceRoot),
  );
  if (
    !fileSystem.exists(resolvedSourceRoot) ||
    !fileSystem.isDirectory(resolvedSourceRoot)
  ) {
    throw new Error("source_root must point to an existing directory.");
  }

  if (options.mode === "apply" && (options.destinationRoot ?? null) === null) {
    throw new Error("apply mode requires --destination-root.");
  }

  const resolvedDestinationRoot =
    options.destinationRoot != null && options.destinationRoot !== ""
      ? stripTrailingSlash(toPosixPath(options.destinationRoot))
      : null;
  const resolvedArtifactRoot =
    options.artifactRoot != null && options.artifactRoot !== ""
      ? stripTrailingSlash(toPosixPath(options.artifactRoot))
      : joinPosix(resolvedSourceRoot, "artifacts/codex-native-converter");

  return {
    mode: options.mode,
    sourceRoot: resolvedSourceRoot,
    sourceEcosystem: resolveSourceEcosystem(options.sourceEcosystem),
    selectedPaths: (options.selectedPaths ?? []).map((path) =>
      toPosixPath(path),
    ),
    destinationRoot: resolvedDestinationRoot,
    artifactRoot: resolvedArtifactRoot,
    enableRepoPrompts: options.enableRepoPrompts ?? false,
    emitIntermediateState: options.emitIntermediateState ?? false,
  };
}

/**
 * Derive the parent directory of the conversion-report path.
 *
 * Mirrors `result.report_paths.conversion_report.parent.as_posix()`.
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
 * Emit the required CLI summary lines for one converter run.
 *
 * Mirrors `_print_run_summary`: prints the artifact-root line and the
 * validation-outcome line through the injected log sink.
 *
 * @param result Completed review or apply result.
 * @param log Log sink that receives one line per call.
 */
export function printRunSummary(
  result: ConversionRunResult,
  log: (message: string) => void,
): void {
  const blockingFindings = result.validationFindings.filter(
    (finding) => finding.blocking,
  ).length;
  log(`Artifact root: ${reportParent(result.reportPaths.conversionReport)}`);
  log(
    "Validation outcome: " +
      (blockingFindings === 0
        ? "pass"
        : `fail (${String(blockingFindings)} blocking findings)`),
  );
}

/**
 * Run the converter in non-mutating review mode.
 *
 * Mirrors the Typer `review` command.
 *
 * @param fileSystem Injected filesystem.
 * @param options Review command options.
 * @param log Log sink for the summary lines.
 * @returns The review outcome with an exit code of 0.
 * @throws Error When required inputs are invalid.
 */
export function review(
  fileSystem: FileSystem,
  options: ConverterCommandOptions,
  log: (message: string) => void,
): ConverterCommandOutcome {
  const runOptions = resolveRunOptions(fileSystem, {
    ...options,
    mode: "review",
    destinationRoot: null,
  });
  const result = runReviewMode(fileSystem, runOptions);
  printRunSummary(result, log);
  return { result, exitCode: 0 };
}

/**
 * Run the converter in mutating apply mode.
 *
 * Mirrors the Typer `apply` command, including the non-zero exit when no
 * destination was written and a blocking finding remains.
 *
 * @param fileSystem Injected filesystem.
 * @param options Apply command options.
 * @param log Log sink for the summary lines.
 * @returns The apply outcome with an exit code of 1 when destination output was
 *   suppressed by a blocking finding, otherwise 0.
 * @throws Error When required inputs are invalid.
 */
export function apply(
  fileSystem: FileSystem,
  options: ConverterCommandOptions,
  log: (message: string) => void,
): ConverterCommandOutcome {
  const runOptions = resolveRunOptions(fileSystem, {
    ...options,
    mode: "apply",
  });
  const result = runApplyMode(fileSystem, runOptions);
  printRunSummary(result, log);
  const anyBlocking = result.validationFindings.some(
    (finding) => finding.blocking,
  );
  const exitCode = !result.wroteDestination && anyBlocking ? 1 : 0;
  return { result, exitCode };
}
