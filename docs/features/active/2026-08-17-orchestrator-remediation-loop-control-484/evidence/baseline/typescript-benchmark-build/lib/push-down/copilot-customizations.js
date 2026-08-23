"use strict";
/**
 * Public/CLI-facing surface of the Copilot customization push-down publisher.
 *
 * Purpose:
 *     Port the public entry points of `push_down_copilot_customizations.py`:
 *     `resolveCliPath`, the `ARTIFACT_DIRECTORY` constant, and a public
 *     `pushDownCustomizations` wrapper that defaults the rewrite function and
 *     root folders to the copilot values. The orchestration engine lives in
 *     `copilot-customizations-engine.ts`.
 *
 * Side effects:
 *     Delegates all filesystem I/O to the injected {@link PushDownFileSystem}
 *     via the engine.
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
exports.ARTIFACT_DIRECTORY = void 0;
exports.resolveCliPath = resolveCliPath;
exports.pushDownCustomizations = pushDownCustomizations;
const nodePath = __importStar(require("node:path"));
const copilot_customizations_engine_1 = require("./copilot-customizations-engine");
const reference_rewrites_1 = require("./reference-rewrites");
/** Default artifact directory for the Copilot push-down summary. */
exports.ARTIFACT_DIRECTORY = copilot_customizations_engine_1.ARTIFACT_DIRECTORY;
/**
 * Resolve CLI paths without breaking Windows-absolute paths on POSIX hosts.
 *
 * Purpose:
 *     Port the Python `resolve_cli_path` guard. On a non-Windows host, a
 *     Windows-absolute input (drive-letter or UNC) is returned expanded but not
 *     resolved so test-injected Windows paths stay stable; otherwise the path is
 *     resolved to an absolute form.
 *
 * @param pathValue CLI or test path value to normalize.
 * @returns The expanded path, resolved only when host semantics match.
 */
function resolveCliPath(pathValue) {
    const rawValue = pathValue;
    // Detect a Windows-absolute path: a drive-letter root or a UNC path. On a
    // POSIX host, Node's path.resolve would mangle these, so return them as-is.
    const isWindowsAbsolute = /^[A-Za-z]:[\\/]/.test(rawValue) || /^\\\\/.test(rawValue);
    if (process.platform !== "win32" && isWindowsAbsolute) {
        return rawValue;
    }
    return nodePath.resolve(rawValue);
}
/**
 * Public Copilot push-down entry point.
 *
 * Defaults `rewriteReferences` to {@link rewriteTextReferences} and `rootFolders`
 * to the inlined copilot tuple, then delegates to the shared engine.
 *
 * @param options Public options (roots, filesystem, optional overrides).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
function pushDownCustomizations(options) {
    return (0, copilot_customizations_engine_1.pushDownCustomizations)({
        repoRoot: options.repoRoot,
        destinationRoot: options.destinationRoot,
        fs: options.fs,
        ...(options.sourceRoot === undefined
            ? {}
            : { sourceRoot: options.sourceRoot }),
        ...(options.artifactRoot === undefined
            ? {}
            : { artifactRoot: options.artifactRoot }),
        rootFolders: options.rootFolders ?? copilot_customizations_engine_1.COPILOT_ROOT_FOLDERS,
        artifactDirectory: options.artifactDirectory ?? exports.ARTIFACT_DIRECTORY,
        rewriteReferences: options.rewriteReferences ?? reference_rewrites_1.rewriteTextReferences,
        ...(options.clock === undefined ? {} : { clock: options.clock }),
    });
}
