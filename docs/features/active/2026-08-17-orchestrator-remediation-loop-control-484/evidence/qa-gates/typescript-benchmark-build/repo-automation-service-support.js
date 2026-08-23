"use strict";
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
exports.POSH_QC_TOOL_CONFIG = void 0;
exports.normalizeGeneratedPath = normalizeGeneratedPath;
exports.runCollectCommitContext = runCollectCommitContext;
exports.parseFirstArtifactPath = parseFirstArtifactPath;
const path = __importStar(require("node:path"));
const collect_commit_context_1 = require("./lib/collect-commit-context");
exports.POSH_QC_TOOL_CONFIG = {
    run_poshqc_format: {
        bundledRelativePath: "resources/templates/run-poshqc-format.ps1",
        summaryWithoutFolders: "Ran bundled PoshQC format against '{workspaceRoot}'.",
        summaryWithFolders: "Ran bundled PoshQC format against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
    },
    run_poshqc_analyze: {
        bundledRelativePath: "resources/templates/run-poshqc-analyze.ps1",
        summaryWithoutFolders: "Ran bundled PoshQC analyze against '{workspaceRoot}'.",
        summaryWithFolders: "Ran bundled PoshQC analyze against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
    },
    run_poshqc_test: {
        bundledRelativePath: "resources/templates/run-poshqc-test.ps1",
        summaryWithoutFolders: "Ran bundled PoshQC test against '{workspaceRoot}'.",
        summaryWithFolders: "Ran bundled PoshQC test against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
    },
    run_poshqc_analyze_autofix: {
        bundledRelativePath: "resources/templates/run-poshqc-analyze-autofix.ps1",
        summaryWithoutFolders: "Ran bundled PoshQC analyze autofix against '{workspaceRoot}'.",
        summaryWithFolders: "Ran bundled PoshQC analyze autofix against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
    },
    run_poshqc_suite: {
        bundledRelativePath: "resources/templates/run-poshqc-suite.ps1",
        summaryWithoutFolders: "Ran the bundled PoshQC suite against '{workspaceRoot}'.",
        summaryWithFolders: "Ran the bundled PoshQC suite against '{workspaceRoot}' with {scanFolderCount} selected scan folder(s).",
    },
};
function normalizeGeneratedPath(filePath) {
    return filePath.replace(/\\/g, "/");
}
/**
 * Run the in-process `collect_commit_context.py` port (F4) and build the
 * service result.
 *
 * Purpose:
 *     Keep the `RepoAutomationService.collectCommitContext` method thin by
 *     centralizing output-path construction, the library invocation, the log
 *     callback wiring, and the result record here.
 *
 * Side effects:
 *     Runs git child processes through `runner` and writes one file through
 *     `fileSystem` (delegated to {@link collectCommitContext}).
 *
 * @param input Dependencies and workspace root for the run.
 * @returns The collect-commit-context result record with the normalized
 *   artifact path.
 */
function runCollectCommitContext(input) {
    const outputPath = path.join(input.workspaceRoot, "artifacts/commit_context.txt");
    (0, collect_commit_context_1.collectCommitContext)({
        runner: input.runner,
        fileSystem: input.fileSystem,
        cwd: input.workspaceRoot,
        outputPath,
        log: input.log,
    });
    return {
        tool: "collect_commit_context",
        workspaceRoot: input.workspaceRoot,
        summary: "Collected commit context into artifacts/commit_context.txt.",
        artifacts: [normalizeGeneratedPath(outputPath)],
    };
}
function parseFirstArtifactPath(execution, pattern) {
    const match = execution.stdout.match(pattern);
    const capturedPath = match?.[1]?.trim();
    return capturedPath && capturedPath.length > 0
        ? normalizeGeneratedPath(capturedPath)
        : undefined;
}
