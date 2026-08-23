"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveSourceEcosystem = resolveSourceEcosystem;
exports.resolveRunOptions = resolveRunOptions;
exports.printRunSummary = printRunSummary;
exports.review = review;
exports.apply = apply;
const file_system_1 = require("../file-system");
const engine_1 = require("./engine");
const models_1 = require("./models");
/**
 * Strip a single trailing slash for normalized path joining.
 *
 * @param value POSIX path.
 * @returns The path without a trailing slash.
 */
function stripTrailingSlash(value) {
    return value.replace(/\/+$/, "");
}
/**
 * Join a POSIX root with a child segment.
 *
 * @param root POSIX root path.
 * @param child Child path segment.
 * @returns The combined POSIX path.
 */
function joinPosix(root, child) {
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
function resolveSourceEcosystem(sourceEcosystem) {
    const supported = [
        models_1.SourceEcosystem.GITHUB_COPILOT,
        models_1.SourceEcosystem.CLAUDE,
    ];
    if (!supported.includes(sourceEcosystem)) {
        throw new Error("source_ecosystem must be 'github-copilot' or 'claude'.");
    }
    return sourceEcosystem;
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
function resolveRunOptions(fileSystem, options) {
    const resolvedSourceRoot = stripTrailingSlash((0, file_system_1.toPosixPath)(options.sourceRoot));
    if (!fileSystem.exists(resolvedSourceRoot) ||
        !fileSystem.isDirectory(resolvedSourceRoot)) {
        throw new Error("source_root must point to an existing directory.");
    }
    if (options.mode === "apply" && (options.destinationRoot ?? null) === null) {
        throw new Error("apply mode requires --destination-root.");
    }
    const resolvedDestinationRoot = options.destinationRoot != null && options.destinationRoot !== ""
        ? stripTrailingSlash((0, file_system_1.toPosixPath)(options.destinationRoot))
        : null;
    const resolvedArtifactRoot = options.artifactRoot != null && options.artifactRoot !== ""
        ? stripTrailingSlash((0, file_system_1.toPosixPath)(options.artifactRoot))
        : joinPosix(resolvedSourceRoot, "artifacts/codex-native-converter");
    return {
        mode: options.mode,
        sourceRoot: resolvedSourceRoot,
        sourceEcosystem: resolveSourceEcosystem(options.sourceEcosystem),
        selectedPaths: (options.selectedPaths ?? []).map((path) => (0, file_system_1.toPosixPath)(path)),
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
function reportParent(conversionReportPath) {
    const normalized = (0, file_system_1.toPosixPath)(conversionReportPath);
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
function printRunSummary(result, log) {
    const blockingFindings = result.validationFindings.filter((finding) => finding.blocking).length;
    log(`Artifact root: ${reportParent(result.reportPaths.conversionReport)}`);
    log("Validation outcome: " +
        (blockingFindings === 0
            ? "pass"
            : `fail (${String(blockingFindings)} blocking findings)`));
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
function review(fileSystem, options, log) {
    const runOptions = resolveRunOptions(fileSystem, {
        ...options,
        mode: "review",
        destinationRoot: null,
    });
    const result = (0, engine_1.runReviewMode)(fileSystem, runOptions);
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
function apply(fileSystem, options, log) {
    const runOptions = resolveRunOptions(fileSystem, {
        ...options,
        mode: "apply",
    });
    const result = (0, engine_1.runApplyMode)(fileSystem, runOptions);
    printRunSummary(result, log);
    const anyBlocking = result.validationFindings.some((finding) => finding.blocking);
    const exitCode = !result.wroteDestination && anyBlocking ? 1 : 0;
    return { result, exitCode };
}
