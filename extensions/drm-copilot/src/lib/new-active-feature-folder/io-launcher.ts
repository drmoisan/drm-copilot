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

import * as fs from "node:fs";
import * as nodePath from "node:path";

import { type CommandRunner, SubprocessRunner } from "../subprocess-runner";
import { toPosixPath } from "../file-system";

/** VS Code session signal variables consulted for Insiders detection (exact order). */
export const INSIDERS_SIGNAL_NAMES = [
  "TERM_PROGRAM_VERSION",
  "VSCODE_GIT_ASKPASS_MAIN",
  "TERM_PROGRAM",
  "VSCODE_IPC_HOOK_CLI",
] as const;

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
export function defaultWhichLookup(executable: string): string | undefined {
  const pathValue = process.env["PATH"] ?? "";
  const pathParts = pathValue
    .split(nodePath.delimiter)
    .filter((part) => part.length > 0);
  const pathExtensions =
    process.platform === "win32"
      ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
          .split(";")
          .filter((part) => part.length > 0)
      : [""];

  // Probe each PATH directory against each allowed extension so resolution
  // behaves consistently across Windows and non-Windows environments.
  for (const directory of pathParts) {
    for (const extension of pathExtensions) {
      const candidate = nodePath.join(
        directory,
        process.platform === "win32" ? `${executable}${extension}` : executable,
      );
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
export function defaultEnvLookup(name: string): string | undefined {
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
export function isInsidersSession(
  envLookup: (name: string) => string | undefined = defaultEnvLookup,
): boolean {
  // Check the documented VS Code signals in a stable order so launcher behavior
  // stays deterministic across bundled and root copies.
  for (const variableName of INSIDERS_SIGNAL_NAMES) {
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
export function resolveCodeCli(
  whichLookup: (name: string) => string | undefined = defaultWhichLookup,
  envLookup: (name: string) => string | undefined = defaultEnvLookup,
): string | undefined {
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

/** Injectable dependencies for {@link defaultCodeLauncher}. */
export interface CodeLauncherDeps {
  /** Command runner used to invoke the resolved CLI executable. */
  readonly runner: CommandRunner;
  /** PATH lookup resolving a CLI name to an executable path. */
  readonly whichLookup: (name: string) => string | undefined;
  /** Environment lookup used for Insiders-session detection. */
  readonly envLookup: (name: string) => string | undefined;
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
export function defaultCodeLauncher(
  files: readonly string[],
  deps: CodeLauncherDeps = {
    runner: new SubprocessRunner(),
    whichLookup: defaultWhichLookup,
    envLookup: defaultEnvLookup,
  },
): boolean {
  const codeCmd = resolveCodeCli(deps.whichLookup, deps.envLookup);
  if (!codeCmd) {
    return false;
  }
  // Invoke the resolved CLI with `--reuse-window` and forward-slash file paths,
  // matching the Python source. allowError preserves the boolean success
  // contract once a CLI is resolved.
  deps.runner.run(
    [
      codeCmd,
      "--reuse-window",
      ...files.map((filePath) => toPosixPath(filePath)),
    ],
    { allowError: true },
  );
  return true;
}
