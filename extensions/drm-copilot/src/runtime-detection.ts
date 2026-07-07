import * as fs from "node:fs";
import * as path from "node:path";

/**
 * Identifies which interpreter family is required to launch a bundled script.
 *
 * Only PowerShell remains: all formerly-interpreted commands run in-process in
 * TypeScript, so no interpreter is detected or spawned beyond PowerShell.
 */
export type RuntimeKind = "powershell";

/**
 * Describes the executable and fixed argument prefix needed to launch a script.
 */
export interface RuntimeResolution {
  readonly executable: string;
  readonly argsPrefix: ReadonlyArray<string>;
}

/**
 * Determines whether an executable can be resolved from the current process PATH.
 *
 * @param executable The executable name to probe, without a file extension.
 * @returns True when a matching file exists in one of the PATH directories.
 * @remarks On Windows the lookup also tries each PATHEXT suffix to mirror shell resolution.
 */
function executableExists(executable: string): boolean {
  return findExecutableOnPath(executable) !== undefined;
}

function getPathExtensions(): ReadonlyArray<string> {
  return process.platform === "win32"
    ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
        .split(";")
        .filter((part) => part.length > 0)
    : [""];
}

function findExecutableOnPath(executable: string): string | undefined {
  const pathValue = process.env["PATH"] ?? "";
  const pathParts = pathValue
    .split(path.delimiter)
    .filter((part) => part.length > 0);
  const pathExtensions = getPathExtensions();

  // Probe each PATH directory against each allowed extension so runtime detection
  // behaves consistently across Windows and non-Windows environments.
  for (const directory of pathParts) {
    for (const extension of pathExtensions) {
      const candidate = path.join(
        directory,
        process.platform === "win32" ? `${executable}${extension}` : executable,
      );
      if (fs.existsSync(candidate)) {
        return candidate.replace(/\\/g, "/");
      }
    }
  }

  return undefined;
}

function normalizeExecutablePath(executablePath: string): string {
  return executablePath.replace(/\\/g, "/");
}

function buildCodexExecutableCandidates(
  extensionRoot: string,
): ReadonlyArray<string> {
  const normalizedRoot = normalizeExecutablePath(extensionRoot).replace(
    /\/+$/,
    "",
  );
  const pathExtensions = getPathExtensions();
  const relativeCandidates =
    process.platform === "win32"
      ? ["bin/windows-x86_64/codex", "bin/codex", "codex"]
      : ["bin/codex", "codex"];

  return relativeCandidates.flatMap((relativePath) =>
    pathExtensions.map(
      (extension) => `${normalizedRoot}/${relativePath}${extension}`,
    ),
  );
}

function findCodexInInstalledExtensionRoots(
  installedExtensionCandidateRoots: ReadonlyArray<string>,
): string | undefined {
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
export function resolveCodexExecutable(
  configuredExecutable: string | undefined,
  installedExtensionCandidateRoots: ReadonlyArray<string> = [],
): string {
  const trimmedConfiguredExecutable = configuredExecutable?.trim() ?? "";
  if (trimmedConfiguredExecutable.length > 0) {
    const normalizedConfiguredExecutable = trimmedConfiguredExecutable.replace(
      /\\/g,
      "/",
    );
    const isPathLike = /[\\/]/.test(trimmedConfiguredExecutable);
    if (isPathLike) {
      if (fs.existsSync(trimmedConfiguredExecutable)) {
        return normalizedConfiguredExecutable;
      }

      throw new Error(
        "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
      );
    }

    const resolvedConfiguredExecutable = findExecutableOnPath(
      trimmedConfiguredExecutable,
    );
    if (resolvedConfiguredExecutable !== undefined) {
      return resolvedConfiguredExecutable;
    }

    throw new Error(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
  }

  const resolvedCodex = findExecutableOnPath("codex");
  if (resolvedCodex !== undefined) {
    return resolvedCodex;
  }

  const resolvedInstalledExtensionCodex = findCodexInInstalledExtensionRoots(
    installedExtensionCandidateRoots,
  );
  if (resolvedInstalledExtensionCodex !== undefined) {
    return resolvedInstalledExtensionCodex;
  }

  throw new Error(
    "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
  );
}

/**
 * Resolves the PowerShell interpreter required to execute a bundled script.
 *
 * PowerShell is the only supported runtime: every formerly-Python command now
 * runs in-process in TypeScript, so this function resolves only PowerShell and
 * never probes a Python interpreter.
 *
 * @param runtimeKind The runtime family requested by the command (always
 *   `"powershell"`).
 * @returns The executable name and fixed argument prefix needed to launch the script.
 * @throws Error when neither `pwsh` nor `powershell` can be found on PATH.
 */
export function detectRuntime(runtimeKind: RuntimeKind): RuntimeResolution {
  // The parameter is retained so call sites remain explicit about the runtime
  // they request; only the PowerShell family is supported.
  void runtimeKind;

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

  throw new Error(
    "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
  );
}
