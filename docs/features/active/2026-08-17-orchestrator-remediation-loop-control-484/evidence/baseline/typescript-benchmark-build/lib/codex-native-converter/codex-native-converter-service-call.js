"use strict";
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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.runCodexNativeConverterServiceCall = runCodexNativeConverterServiceCall;
const path = __importStar(require("node:path"));
const file_system_1 = require("../file-system");
const repo_automation_service_support_1 = require("../../repo-automation-service-support");
const engine_1 = require("./engine");
/**
 * Determine whether a path is already absolute (POSIX root or Windows drive).
 *
 * @param value Candidate path.
 * @returns True when the path is absolute.
 */
function isAbsolutePath(value) {
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
function resolveAgainstWorkspace(workspaceRoot, value) {
    const normalizedValue = (0, file_system_1.toPosixPath)(value);
    if (isAbsolutePath(normalizedValue)) {
        return normalizedValue.replace(/\/+$/, "");
    }
    return (0, file_system_1.toPosixPath)(path.posix.join((0, file_system_1.toPosixPath)(workspaceRoot), normalizedValue)).replace(/\/+$/, "");
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
function reportParent(conversionReportPath) {
    const normalized = (0, file_system_1.toPosixPath)(conversionReportPath);
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
function runCodexNativeConverterServiceCall(input) {
    const sourceRoot = resolveAgainstWorkspace(input.workspaceRoot, input.sourceRoot);
    const destinationRoot = input.destinationRoot !== undefined && input.destinationRoot !== ""
        ? resolveAgainstWorkspace(input.workspaceRoot, input.destinationRoot)
        : null;
    const artifactRoot = input.artifactRoot !== undefined && input.artifactRoot !== ""
        ? resolveAgainstWorkspace(input.workspaceRoot, input.artifactRoot)
        : `${sourceRoot}/artifacts/codex-native-converter`;
    const runOptions = {
        mode: input.mode,
        sourceRoot,
        sourceEcosystem: input.sourceEcosystem,
        selectedPaths: (input.selectedPaths ?? []).map((selectedPath) => (0, file_system_1.toPosixPath)(selectedPath)),
        destinationRoot,
        artifactRoot,
        enableRepoPrompts: input.enableRepoPrompts ?? false,
        emitIntermediateState: false,
    };
    // Review mode never mutates a destination; apply mode writes only when the
    // plan is clean. The engine enforces both behaviors.
    const result = input.mode === "apply"
        ? (0, engine_1.runApplyMode)(input.fileSystem, runOptions)
        : (0, engine_1.runReviewMode)(input.fileSystem, runOptions);
    if (input.log !== undefined) {
        input.log(`Ran bundled codex-native-converter in ${input.mode} mode for '${input.sourceEcosystem}'.`);
    }
    return {
        tool: "run_codex_native_converter",
        workspaceRoot: input.workspaceRoot,
        summary: `Ran bundled codex-native-converter in ${input.mode} mode for '${input.sourceEcosystem}'.`,
        artifacts: [
            (0, repo_automation_service_support_1.normalizeGeneratedPath)(reportParent(result.reportPaths.conversionReport)),
        ],
    };
}
