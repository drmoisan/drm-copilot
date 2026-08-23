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
exports.CommandExecutionError = exports.resolveCodexExecutable = exports.detectRuntime = void 0;
exports.createOutputChannel = createOutputChannel;
exports.createBufferedOutput = createBufferedOutput;
exports.getWorkspaceRoot = getWorkspaceRoot;
exports.getClaudeProjectsRoot = getClaudeProjectsRoot;
exports.resolveBundledScriptPath = resolveBundledScriptPath;
exports.runCommandWithOutput = runCommandWithOutput;
exports.executeBundledScriptFromExtensionRoot = executeBundledScriptFromExtensionRoot;
exports.executeBundledScript = executeBundledScript;
exports.getStderrExcerpt = getStderrExcerpt;
const cp = __importStar(require("node:child_process"));
const path = __importStar(require("node:path"));
const vscode = __importStar(require("vscode"));
const runtime_detection_1 = require("./runtime-detection");
var runtime_detection_2 = require("./runtime-detection");
Object.defineProperty(exports, "detectRuntime", { enumerable: true, get: function () { return runtime_detection_2.detectRuntime; } });
Object.defineProperty(exports, "resolveCodexExecutable", { enumerable: true, get: function () { return runtime_detection_2.resolveCodexExecutable; } });
/**
 * Rich error raised when a spawned command exits non-zero.
 */
class CommandExecutionError extends Error {
    executable;
    args;
    cwd;
    exitCode;
    stdout;
    stderr;
    constructor(input) {
        super(`Command exited with code ${input.exitCode ?? "unknown"}.`);
        this.name = "CommandExecutionError";
        this.executable = input.executable;
        this.args = input.args;
        this.cwd = input.cwd;
        this.exitCode = input.exitCode;
        this.stdout = input.stdout;
        this.stderr = input.stderr;
    }
}
exports.CommandExecutionError = CommandExecutionError;
/**
 * Creates the shared output channel used by the extension's command handlers.
 *
 * @returns A VS Code output channel that records command progress and failures.
 */
function createOutputChannel() {
    return vscode.window.createOutputChannel("drm-copilot");
}
/**
 * Creates an in-memory output sink for MCP and unit-test scenarios.
 *
 * @returns A writable sink plus the collected log lines.
 */
function createBufferedOutput() {
    const lines = [];
    return {
        output: {
            appendLine(line) {
                lines.push(line);
            },
        },
        lines,
    };
}
/**
 * Resolves the first open workspace folder as the working directory for commands.
 *
 * @returns The filesystem path for the primary workspace folder.
 * @throws Error when the extension is invoked without an open workspace.
 */
function getWorkspaceRoot() {
    const folder = vscode.workspace.workspaceFolders?.[0];
    if (!folder) {
        throw new Error("No workspace folder is open.");
    }
    return folder.uri.fsPath;
}
/**
 * Resolves the user-global Claude projects directory (`~/.claude/projects`).
 *
 * Claude Code writes session transcripts to a per-user global directory, not
 * inside the open workspace. Resolution order:
 * 1. `env.CLAUDE_CONFIG_DIR` when set (non-empty after trimming) — the
 *    directory's `projects` subfolder is used directly, mirroring Claude
 *    Code's own config-dir override.
 * 2. Otherwise the user's home directory (`env.HOME`, then
 *    `env.USERPROFILE`) plus `.claude/projects`.
 *
 * The `env` parameter defaults to `process.env` but accepts an injected
 * override so unit tests can resolve a fake root without depending on the
 * real `HOME`/`USERPROFILE`/`CLAUDE_CONFIG_DIR` values of the host running
 * the tests.
 *
 * @param env Environment variables to resolve from; defaults to `process.env`.
 * @returns The absolute, forward-slash-normalized path to the user-global
 *   Claude projects directory.
 * @throws Error when neither `CLAUDE_CONFIG_DIR` nor `HOME`/`USERPROFILE` is set.
 */
function getClaudeProjectsRoot(env = process.env) {
    const configDirOverride = env["CLAUDE_CONFIG_DIR"]?.trim();
    if (configDirOverride !== undefined && configDirOverride.length > 0) {
        return path.join(configDirOverride, "projects").replace(/\\/g, "/");
    }
    const home = env["HOME"]?.trim() || env["USERPROFILE"]?.trim();
    if (home === undefined || home.length === 0) {
        throw new Error("Cannot resolve the user-global Claude projects directory: none of CLAUDE_CONFIG_DIR, HOME, or USERPROFILE is set.");
    }
    return path.join(home, ".claude", "projects").replace(/\\/g, "/");
}
/**
 * Builds the absolute path to a bundled script inside the installed extension package.
 *
 * @param extensionRoot The extension installation root.
 * @param bundledRelativePath The bundled resource path relative to the extension root.
 * @returns The resolved absolute path to the bundled resource.
 */
function resolveBundledScriptPath(extensionRoot, bundledRelativePath) {
    const normalizedExtensionRoot = extensionRoot.replace(/\\/g, "/");
    const normalizedBundledRelativePath = bundledRelativePath
        .replace(/\\/g, "/")
        .replace(/^\/+/, "");
    // Preserve Windows drive-prefixed roots as absolute paths even when the host
    // process uses POSIX path semantics, where `path.resolve` would otherwise
    // treat `C:/...` as a relative segment and prefix the checkout directory.
    if (/^[A-Za-z]:\//.test(normalizedExtensionRoot)) {
        return `${normalizedExtensionRoot.replace(/\/+$/, "")}/${normalizedBundledRelativePath}`;
    }
    return path.resolve(extensionRoot, bundledRelativePath).replace(/\\/g, "/");
}
/**
 * Executes a subprocess and streams its stdout/stderr into the output sink.
 *
 * @param output The output sink that should receive process diagnostics.
 * @param executable The executable to launch.
 * @param args The argv array passed to the executable.
 * @param cwd The working directory used for process execution.
 * @returns The aggregated stdout/stderr emitted by the child process.
 * @throws Error when process spawning fails or the command exits non-zero.
 */
function runCommandWithOutput(output, executable, args, cwd) {
    return new Promise((resolve, reject) => {
        const stdoutChunks = [];
        const stderrChunks = [];
        const child = cp.spawn(executable, args, {
            cwd,
            stdio: ["ignore", "pipe", "pipe"],
            shell: false,
        });
        child.stdout.on("data", (chunk) => {
            const text = chunk.toString("utf-8");
            stdoutChunks.push(text);
            const trimmed = text.trimEnd();
            if (trimmed.length > 0) {
                output.appendLine(trimmed);
            }
        });
        child.stderr.on("data", (chunk) => {
            const text = chunk.toString("utf-8");
            stderrChunks.push(text);
            const trimmed = text.trimEnd();
            if (trimmed.length > 0) {
                output.appendLine(trimmed);
            }
        });
        child.on("error", (error) => {
            reject(error);
        });
        child.on("close", (code) => {
            const stdout = stdoutChunks.join("");
            const stderr = stderrChunks.join("");
            if (code === 0) {
                resolve({
                    exitCode: 0,
                    stdout,
                    stderr,
                });
                return;
            }
            reject(new CommandExecutionError({
                executable,
                args,
                cwd,
                exitCode: code,
                stdout,
                stderr,
            }));
        });
    });
}
/**
 * Resolves a bundled script, selects its runtime, and executes it in the workspace.
 *
 * @param output The output sink used for command progress and diagnostics.
 * @param spec The command configuration describing the bundled script to execute.
 * @returns A promise that resolves when the bundled script exits successfully.
 * @throws Error when runtime detection fails or the spawned command exits non-zero.
 */
async function executeBundledScriptFromExtensionRoot(output, spec) {
    output.appendLine(`[${spec.commandId}] runtime probe start`);
    let runtime;
    try {
        runtime = (0, runtime_detection_1.detectRuntime)(spec.runtimeKind);
    }
    catch (error) {
        output.appendLine(`[${spec.commandId}] runtime probe failure`);
        throw error;
    }
    output.appendLine(`[${spec.commandId}] runtime probe success: ${runtime.executable}`);
    // Resolve scripts relative to the installed extension so commands always use the
    // bundled resources rather than depending on workspace copies.
    const scriptPath = resolveBundledScriptPath(spec.extensionRoot, spec.bundledRelativePath);
    output.appendLine(`[${spec.commandId}] resolved script path: ${scriptPath}`);
    const specScriptArgs = spec.args ?? [];
    const args = [...runtime.argsPrefix, scriptPath, ...specScriptArgs];
    output.appendLine(`[${spec.commandId}] command start: ${runtime.executable} ${args.join(" ")}`);
    try {
        const processResult = await runCommandWithOutput(output, runtime.executable, args, spec.workspaceRoot);
        output.appendLine(`[${spec.commandId}] command success`);
        return {
            ...processResult,
            executable: runtime.executable,
            args,
            scriptPath,
            workspaceRoot: spec.workspaceRoot,
        };
    }
    catch (error) {
        output.appendLine(`[${spec.commandId}] command failure`);
        throw error;
    }
}
/**
 * Resolves a bundled script and executes it against the active VS Code workspace.
 *
 * @param context The extension context that provides the extension installation URI.
 * @param output The output sink used for command progress and diagnostics.
 * @param spec The command configuration describing the bundled script to execute.
 * @returns A promise that resolves when the bundled script exits successfully.
 */
function executeBundledScript(context, output, spec) {
    return executeBundledScriptFromExtensionRoot(output, {
        ...spec,
        extensionRoot: context.extensionUri.fsPath,
        workspaceRoot: getWorkspaceRoot(),
    });
}
/**
 * Extracts a short stderr diagnostic snippet from a command-execution failure.
 *
 * @param error The thrown error to inspect.
 * @returns A trimmed stderr excerpt when available.
 */
function getStderrExcerpt(error) {
    if (!(error instanceof CommandExecutionError)) {
        return undefined;
    }
    const trimmed = error.stderr
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
        .slice(0, 8)
        .join("\n");
    return trimmed.length > 0 ? trimmed : undefined;
}
