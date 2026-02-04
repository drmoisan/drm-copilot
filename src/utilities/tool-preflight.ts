import * as fs from "fs";
import * as path from "path";

/**
 * Resolves an executable name to its full path by scanning PATH.
 *
 * Purpose:
 *     Before executing external tools (gh, poetry, pwsh, etc.), we need to verify
 *     they exist and resolve their full paths. This function scans process.env.PATH
 *     to locate the executable, applying platform-specific conventions.
 *
 * Args:
 *     executableName (string): The name of the executable to resolve (e.g., "gh", "poetry").
 *
 * Returns:
 *     string | undefined: The full path to the executable if found, undefined otherwise.
 *
 * Side Effects:
 *     Performs synchronous filesystem checks on PATH directories.
 */
export function resolveExecutable(executableName: string): string | undefined {
  const pathEnv = process.env["PATH"] ?? "";
  if (!pathEnv) {
    return undefined;
  }

  const pathSeparator = process.platform === "win32" ? ";" : ":";
  const pathDirs = pathEnv.split(pathSeparator).filter((dir) => dir.length > 0);

  // On Windows, try both with and without .exe suffix
  const candidates =
    process.platform === "win32"
      ? [executableName, `${executableName}.exe`]
      : [executableName];

  for (const dir of pathDirs) {
    for (const candidate of candidates) {
      const fullPath = path.join(dir, candidate);
      try {
        if (fs.existsSync(fullPath)) {
          const stats = fs.statSync(fullPath);
          if (stats.isFile()) {
            return fullPath;
          }
        }
      } catch {
        // Ignore errors (e.g., permission denied) and continue scanning
        continue;
      }
    }
  }

  return undefined;
}
