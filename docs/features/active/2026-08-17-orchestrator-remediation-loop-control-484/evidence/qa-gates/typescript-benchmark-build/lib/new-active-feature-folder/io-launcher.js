"use strict";
/**
 * VS Code launcher seam for active feature folder creation.
 *
 * Purpose:
 *     Holds the injectable VS Code launcher portion of the bundled
 *     `dev_tools/new_active_feature_folder_io.py` port: PATH probing,
 *     environment-based Insiders detection, CLI resolution, and the
 *     `--reuse-window` launch invocation. Extracted from `io.ts` so each module
 *     stays within the production file-size limit. `io.ts` re-exports these
 *     symbols so every prior `./io` import path resolves unchanged.
 *
 * Seams:
 *     - The launcher uses injectable env + which lookups and an injectable
 *       runner so tests never touch the real environment, PATH, or `code`.
 *
 * This module must not import from `io.ts`; the dependency direction is
 * `io.ts` -> `io-launcher.ts` only, preventing a circular import.
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
exports.INSIDERS_SIGNAL_NAMES = void 0;
exports.defaultWhichLookup = defaultWhichLookup;
exports.defaultEnvLookup = defaultEnvLookup;
exports.isInsidersSession = isInsidersSession;
exports.resolveCodeCli = resolveCodeCli;
exports.defaultCodeLauncher = defaultCodeLauncher;
const fs = __importStar(require("node:fs"));
const nodePath = __importStar(require("node:path"));
const subprocess_runner_1 = require("../subprocess-runner");
const file_system_1 = require("../file-system");
/** VS Code session signal variables consulted for Insiders detection (exact order). */
exports.INSIDERS_SIGNAL_NAMES = [
    "TERM_PROGRAM_VERSION",
    "VSCODE_GIT_ASKPASS_MAIN",
    "TERM_PROGRAM",
    "VSCODE_IPC_HOOK_CLI",
];
/**
 * Probe the current process PATH for an executable and return its path.
 *
 * Mirrors `shutil.which` using the same PATH/PATHEXT probing approach as
 * `command-runtime.ts` and the F6 `new-potential-bug-entry` port. Injectable so
 * tests never touch the real PATH.
 *
 * @param executable Executable name to probe (without extension on Windows).
 * @returns The resolved absolute path when found; otherwise `undefined`.
 */
function defaultWhichLookup(executable) {
    const pathValue = process.env["PATH"] ?? "";
    const pathParts = pathValue
        .split(nodePath.delimiter)
        .filter((part) => part.length > 0);
    const pathExtensions = process.platform === "win32"
        ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
            .split(";")
            .filter((part) => part.length > 0)
        : [""];
    // Probe each PATH directory against each allowed extension so resolution
    // behaves consistently across Windows and non-Windows environments.
    for (const directory of pathParts) {
        for (const extension of pathExtensions) {
            const candidate = nodePath.join(directory, process.platform === "win32" ? `${executable}${extension}` : executable);
            if (fs.existsSync(candidate)) {
                return candidate;
            }
        }
    }
    return undefined;
}
/**
 * Return a non-blank environment variable value, or `undefined`.
 *
 * Provides a small environment seam for VS Code session detection without
 * treating blank variables as meaningful signals.
 *
 * @param name Environment variable name.
 * @returns The value when present and non-blank, otherwise `undefined`.
 */
function defaultEnvLookup(name) {
    const value = process.env[name];
    return value && value.trim() ? value : undefined;
}
/**
 * Return whether the current process appears to be inside VS Code Insiders.
 *
 * Mirrors Python `_is_insiders_session`: any known signal value (read through
 * the injectable lookup) containing `insider` (case-insensitive) indicates an
 * Insiders session.
 *
 * @param envLookup Optional injectable environment lookup.
 * @returns True when an Insiders signal is detected.
 */
function isInsidersSession(envLookup = defaultEnvLookup) {
    // Check the documented VS Code signals in a stable order so launcher behavior
    // stays deterministic across bundled and root copies.
    for (const variableName of exports.INSIDERS_SIGNAL_NAMES) {
        const value = envLookup(variableName);
        if (value && value.toLowerCase().includes("insider")) {
            return true;
        }
    }
    return false;
}
/**
 * Resolve the best VS Code CLI executable path for the current session.
 *
 * Mirrors Python `_resolve_code_cli`: prefers `code-insiders` then `code` in an
 * Insiders session, else `code` then `code-insiders`, resolving via the
 * injectable PATH lookup.
 *
 * @param whichLookup Optional injectable PATH lookup.
 * @param envLookup Optional injectable environment lookup.
 * @returns The resolved CLI path, or `undefined` when none is available.
 */
function resolveCodeCli(whichLookup = defaultWhichLookup, envLookup = defaultEnvLookup) {
    // Prefer the CLI matching the current session, then fall back to the other
    // supported name to preserve graceful behavior.
    const candidateNames = isInsidersSession(envLookup)
        ? ["code-insiders", "code"]
        : ["code", "code-insiders"];
    for (const candidateName of candidateNames) {
        const resolvedCommand = whichLookup(candidateName);
        if (resolvedCommand) {
            return resolvedCommand;
        }
    }
    return undefined;
}
/**
 * Open created files in VS Code when available.
 *
 * Mirrors Python `default_code_launcher`: resolves the CLI, returns `false`
 * when none is found, else runs `<cli> --reuse-window <file...>` (each path in
 * forward-slash form) through the injected runner and returns `true`.
 *
 * The runner/which/env seams are injected (defaulting to the production
 * defaults) so tests never touch the real environment, PATH, or `code`. In the
 * service/MCP path the launcher is replaced with a no-op returning `false`.
 *
 * @param files Files to open.
 * @param deps Optional injected runner / which / env seams.
 * @returns True when a CLI was resolved and invoked; otherwise false.
 */
function defaultCodeLauncher(files, deps = {
    runner: new subprocess_runner_1.SubprocessRunner(),
    whichLookup: defaultWhichLookup,
    envLookup: defaultEnvLookup,
}) {
    const codeCmd = resolveCodeCli(deps.whichLookup, deps.envLookup);
    if (!codeCmd) {
        return false;
    }
    // Invoke the resolved CLI with `--reuse-window` and forward-slash file paths,
    // matching the Python source. allowError preserves the boolean success
    // contract once a CLI is resolved.
    deps.runner.run([
        codeCmd,
        "--reuse-window",
        ...files.map((filePath) => (0, file_system_1.toPosixPath)(filePath)),
    ], { allowError: true });
    return true;
}
