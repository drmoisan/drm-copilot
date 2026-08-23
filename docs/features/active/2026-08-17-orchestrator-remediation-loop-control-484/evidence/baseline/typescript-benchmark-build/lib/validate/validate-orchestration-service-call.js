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
exports.validateOrchestrationServiceCall = validateOrchestrationServiceCall;
const path = __importStar(require("node:path"));
const file_system_1 = require("../file-system");
const orchestration_artifacts_1 = require("./orchestration-artifacts");
/**
 * Validate an orchestration artifact in-process.
 *
 * @param input Filesystem, workspace root, artifact type/path, and optional
 *     completion flag.
 * @returns The preserved success result object on success.
 * @throws Error When the selected validator reports one or more errors; the
 *     message lists the validation errors using the preserved format.
 */
function validateOrchestrationServiceCall(input) {
    // Resolve the artifact path relative to the workspace root, matching the
    // Python `Path(args.path)` semantics, then validate in-process. The path is
    // normalized to forward slashes to match the F1 FileSystem path convention.
    const artifactFullPath = (0, file_system_1.toPosixPath)(path.join(input.workspaceRoot, input.artifactPath));
    const text = input.fileSystem.readTextFile(artifactFullPath);
    const errors = (0, orchestration_artifacts_1.validateArtifact)({
        artifactType: input.artifactType,
        text,
        ...(input.requireComplete === undefined
            ? {}
            : { requireComplete: input.requireComplete }),
        ...(input.requireModelRouting === undefined
            ? {}
            : { requireModelRouting: input.requireModelRouting }),
        ...(input.requireCodexModelRouting === undefined
            ? {}
            : { requireCodexModelRouting: input.requireCodexModelRouting }),
        ...(input.requireCodexTopology === undefined
            ? {}
            : { requireCodexTopology: input.requireCodexTopology }),
        ...(input.requireReadyForExecution === undefined
            ? {}
            : { requireReadyForExecution: input.requireReadyForExecution }),
        artifactPath: artifactFullPath,
        ...(input.runner === undefined ? {} : { runner: input.runner }),
        fs: input.fileSystem,
        root: input.workspaceRoot,
    });
    // Surface validation failure as a thrown error so the MCP handler reports a
    // non-zero outcome, mirroring the Python stderr-per-line, exit-1 behavior.
    if (errors.length > 0) {
        throw new Error(`Validation failed for ${input.artifactType} artifact at ` +
            `'${input.artifactPath}':\n${errors.join("\n")}`);
    }
    // Preserve the existing success summary string.
    return {
        tool: "validate_orchestration_artifacts",
        workspaceRoot: input.workspaceRoot,
        summary: `Validated ${input.artifactType} artifact at '${input.artifactPath}'.`,
    };
}
