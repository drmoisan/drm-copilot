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
exports.resolveCodexExecutable = resolveCodexExecutable;
exports.detectRuntime = detectRuntime;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
/**
 * Determines whether an executable can be resolved from the current process PATH.
 *
 * @param executable The executable name to probe, without a file extension.
 * @returns True when a matching file exists in one of the PATH directories.
 * @remarks On Windows the lookup also tries each PATHEXT suffix to mirror shell resolution.
 */
function executableExists(executable) {
    return findExecutableOnPath(executable) !== undefined;
}
function getPathExtensions() {
    return process.platform === "win32"
        ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
            .split(";")
            .filter((part) => part.length > 0)
        : [""];
}
function findExecutableOnPath(executable) {
    const pathValue = process.env["PATH"] ?? "";
    const pathParts = pathValue
        .split(path.delimiter)
        .filter((part) => part.length > 0);
    const pathExtensions = getPathExtensions();
    // Probe each PATH directory against each allowed extension so runtime detection
    // behaves consistently across Windows and non-Windows environments.
    for (const directory of pathParts) {
        for (const extension of pathExtensions) {
            const candidate = path.join(directory, process.platform === "win32" ? `${executable}${extension}` : executable);
            if (fs.existsSync(candidate)) {
                return candidate.replace(/\\/g, "/");
            }
        }
    }
    return undefined;
}
function normalizeExecutablePath(executablePath) {
    return executablePath.replace(/\\/g, "/");
}
function buildCodexExecutableCandidates(extensionRoot) {
    const normalizedRoot = normalizeExecutablePath(extensionRoot).replace(/\/+$/, "");
    const pathExtensions = getPathExtensions();
    const relativeCandidates = process.platform === "win32"
        ? ["bin/windows-x86_64/codex", "bin/codex", "codex"]
        : ["bin/codex", "codex"];
    return relativeCandidates.flatMap((relativePath) => pathExtensions.map((extension) => `${normalizedRoot}/${relativePath}${extension}`));
}
function findCodexInInstalledExtensionRoots(installedExtensionCandidateRoots) {
    for (const extensionRoot of installedExtensionCandidateRoots) {
        const trimmedRoot = extensionRoot.trim();
        if (trimmedRoot.length === 0) {
            continue;
        }
        for (const candidate of buildCodexExecutableCandidates(trimmedRoot)) {
            if (fs.existsSync(candidate)) {
                return normalizeExecutablePath(candidate);
            }
        }
    }
    return undefined;
}
/**
 * Resolves the Codex CLI executable before a terminal is created.
 *
 * @param configuredExecutable Optional configured command name or executable path.
 * @returns The resolved command or path to invoke through PowerShell.
 * @throws Error when the configured executable or PATH fallback cannot be found.
 */
function resolveCodexExecutable(configuredExecutable, installedExtensionCandidateRoots = []) {
    const trimmedConfiguredExecutable = configuredExecutable?.trim() ?? "";
    if (trimmedConfiguredExecutable.length > 0) {
        const normalizedConfiguredExecutable = trimmedConfiguredExecutable.replace(/\\/g, "/");
        const isPathLike = /[\\/]/.test(trimmedConfiguredExecutable);
        if (isPathLike) {
            if (fs.existsSync(trimmedConfiguredExecutable)) {
                return normalizedConfiguredExecutable;
            }
            throw new Error("Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.");
        }
        const resolvedConfiguredExecutable = findExecutableOnPath(trimmedConfiguredExecutable);
        if (resolvedConfiguredExecutable !== undefined) {
            return resolvedConfiguredExecutable;
        }
        throw new Error("Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.");
    }
    const resolvedCodex = findExecutableOnPath("codex");
    if (resolvedCodex !== undefined) {
        return resolvedCodex;
    }
    const resolvedInstalledExtensionCodex = findCodexInInstalledExtensionRoots(installedExtensionCandidateRoots);
    if (resolvedInstalledExtensionCodex !== undefined) {
        return resolvedInstalledExtensionCodex;
    }
    throw new Error("Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.");
}
/**
 * Builds the workspace `.venv` interpreter candidate path for the current platform.
 *
 * @param workspaceRoot The workspace root that may contain a `.venv` directory.
 * @returns The forward-slash-normalized candidate interpreter path.
 */
function buildVenvInterpreterCandidate(workspaceRoot) {
    const normalizedRoot = workspaceRoot.replace(/\\/g, "/").replace(/\/+$/, "");
    const relativeInterpreter = process.platform === "win32"
        ? ".venv/Scripts/python.exe"
        : ".venv/bin/python";
    return `${normalizedRoot}/${relativeInterpreter}`;
}
/**
 * Resolves a Python interpreter used to invoke the workspace discovery CLI.
 *
 * Resolution order: the workspace `.venv` interpreter (when a workspace root is
 * supplied), then `py`, then `python` on PATH via {@link findExecutableOnPath}.
 * The returned `argsPrefix` is empty because the discovery service-call helper
 * composes the interpreter argv itself (`[pythonExe, "-c", ...]`).
 *
 * @param workspaceRoot Optional workspace root probed for a `.venv` interpreter.
 * @returns The resolved interpreter path and an empty argument prefix.
 * @throws Error when no workspace `.venv` interpreter and neither `py` nor
 *   `python` can be found.
 */
function detectPythonRuntime(workspaceRoot) {
    if (workspaceRoot !== undefined && workspaceRoot.trim().length > 0) {
        const venvInterpreter = buildVenvInterpreterCandidate(workspaceRoot);
        if (fs.existsSync(venvInterpreter)) {
            return {
                executable: venvInterpreter,
                argsPrefix: [],
            };
        }
    }
    // Prefer the Windows `py` launcher, then a plain `python` on PATH, mirroring
    // the PowerShell probe's ordered fallback across developer environments.
    const resolvedPy = findExecutableOnPath("py");
    if (resolvedPy !== undefined) {
        return {
            executable: resolvedPy,
            argsPrefix: [],
        };
    }
    const resolvedPython = findExecutableOnPath("python");
    if (resolvedPython !== undefined) {
        return {
            executable: resolvedPython,
            argsPrefix: [],
        };
    }
    throw new Error("Python runtime not found. Expected a workspace '.venv' interpreter or 'py' or 'python' on PATH.");
}
/**
 * Resolves the interpreter required to launch a script for the requested runtime.
 *
 * `"powershell"` resolves PowerShell Core (`pwsh`) then Windows PowerShell
 * (`powershell`); every formerly-Python in-process command still uses this
 * family. `"python"` resolves a Python interpreter (workspace `.venv`, then
 * `py`, then `python`) used to invoke the workspace discovery CLI via an
 * interpreter `-c` entry-point call.
 *
 * @param runtimeKind The runtime family requested by the command.
 * @param workspaceRoot Optional workspace root probed for a `.venv` interpreter
 *   when `runtimeKind` is `"python"`; ignored for PowerShell.
 * @returns The executable name and fixed argument prefix needed to launch the script.
 * @throws Error when the requested runtime cannot be resolved.
 */
function detectRuntime(runtimeKind, workspaceRoot) {
    if (runtimeKind === "python") {
        return detectPythonRuntime(workspaceRoot);
    }
    // Prefer PowerShell Core when available, then fall back to Windows PowerShell
    // so the extension works across newer and older developer environments.
    if (executableExists("pwsh")) {
        return {
            executable: "pwsh",
            argsPrefix: [
                "-NoLogo",
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
            ],
        };
    }
    if (executableExists("powershell")) {
        return {
            executable: "powershell",
            argsPrefix: [
                "-NoLogo",
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
            ],
        };
    }
    throw new Error("PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.");
}
