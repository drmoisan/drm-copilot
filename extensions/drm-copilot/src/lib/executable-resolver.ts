/**
 * PATH-based executable resolution for host-spawned CLIs (issue #588).
 *
 * Purpose:
 *     Resolve an executable name such as `gh` to the first matching file on
 *     PATH, so callers can spawn it by absolute path. The pure resolver takes
 *     PATH, PATHEXT, the platform, and an existence predicate as parameters;
 *     {@link defaultWhichGh} binds them to the running process.
 *
 * Windows semantics:
 *     On `win32`, PATHEXT extensions are tried case-insensitively and in order
 *     (falling back to `.COM;.EXE;.BAT;.CMD` when PATHEXT is unset), after the
 *     bare name when it already ends in one of them.
 *
 * Limitation (D5):
 *     Node releases patched for CVE-2024-27980 refuse to spawn `.cmd` and
 *     `.bat` files with `shell: false`. A PATHEXT hit on a `gh.cmd` or
 *     `gh.bat` shim therefore surfaces downstream as a not-authenticated
 *     status rather than a spawn. Official `gh` installers ship `gh.exe`, so
 *     no special handling is applied here.
 */

import { existsSync } from "node:fs";
import { posix, win32 } from "node:path";

/** PATHEXT fallback used on win32 when the variable is unset or empty. */
const DEFAULT_PATHEXT = ".COM;.EXE;.BAT;.CMD";

/** Inputs for {@link resolveExecutableOnPath}. */
export interface ResolveExecutableOptions {
  /** Executable name to resolve, for example `gh`. */
  readonly name: string;
  /** The PATH value; `undefined` or empty resolves nothing. */
  readonly pathValue: string | undefined;
  /** The PATHEXT value; consulted on `win32` only. */
  readonly pathExtValue: string | undefined;
  /** Platform whose path rules apply. */
  readonly platform: NodeJS.Platform;
  /** Existence predicate for a candidate file path. */
  readonly exists: (candidate: string) => boolean;
}

/** Split a delimited list, dropping empty entries. */
function splitNonEmpty(value: string, delimiter: string): string[] {
  return value.split(delimiter).filter((entry) => entry.length > 0);
}

/**
 * Build the candidate file names for one PATH directory, in try order.
 *
 * @param name Executable name.
 * @param platform Platform whose rules apply.
 * @param pathExtValue PATHEXT value (win32 only).
 * @returns The names to join with each PATH directory.
 */
function candidateNames(
  name: string,
  platform: NodeJS.Platform,
  pathExtValue: string | undefined,
): string[] {
  if (platform !== "win32") {
    return [name];
  }
  const extensions = splitNonEmpty(
    pathExtValue === undefined || pathExtValue === ""
      ? DEFAULT_PATHEXT
      : pathExtValue,
    ";",
  );
  const lowerName = name.toLowerCase();
  const hasKnownExtension = extensions.some((ext) =>
    lowerName.endsWith(ext.toLowerCase()),
  );
  const withExtensions = extensions.map((ext) => `${name}${ext}`);
  return hasKnownExtension ? [name, ...withExtensions] : withExtensions;
}

/**
 * Resolve an executable name to the first existing candidate on PATH.
 *
 * @param options Name, PATH, PATHEXT, platform, and existence predicate.
 * @returns The first candidate path for which `exists` is true, or
 *     `undefined` when PATH is unset or empty or no candidate exists.
 */
export function resolveExecutableOnPath(
  options: ResolveExecutableOptions,
): string | undefined {
  const { name, pathValue, pathExtValue, platform, exists } = options;
  if (pathValue === undefined || pathValue === "") {
    return undefined;
  }
  const pathApi = platform === "win32" ? win32 : posix;
  const names = candidateNames(name, platform, pathExtValue);
  for (const directory of splitNonEmpty(pathValue, pathApi.delimiter)) {
    for (const candidateName of names) {
      const candidate = pathApi.join(directory, candidateName);
      if (exists(candidate)) {
        return candidate;
      }
    }
  }
  return undefined;
}

/**
 * Resolve `gh` from the running process's PATH, PATHEXT, and platform.
 *
 * Reads the environment at call time and checks candidates with
 * `fs.existsSync`.
 *
 * @returns The resolved `gh` path, or `undefined` when none is found.
 */
export function defaultWhichGh(): string | undefined {
  return resolveExecutableOnPath({
    name: "gh",
    pathValue: process.env.PATH,
    pathExtValue: process.env.PATHEXT,
    platform: process.platform,
    exists: existsSync,
  });
}
