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

import * as nodePath from "node:path";

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  ARTIFACT_DIRECTORY as ENGINE_ARTIFACT_DIRECTORY,
  type Clock,
  COPILOT_ROOT_FOLDERS,
  type PushDownFileResult,
  pushDownCustomizations as enginePushDown,
  type PushDownSummary,
} from "./copilot-customizations-engine";
import {
  rewriteTextReferences,
  type RewriteFunction,
} from "./reference-rewrites";

export { type PushDownFileResult, type PushDownSummary, type Clock };

/** Default artifact directory for the Copilot push-down summary. */
export const ARTIFACT_DIRECTORY = ENGINE_ARTIFACT_DIRECTORY;

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
export function resolveCliPath(pathValue: string): string {
  const rawValue = pathValue;
  // Detect a Windows-absolute path: a drive-letter root or a UNC path. On a
  // POSIX host, Node's path.resolve would mangle these, so return them as-is.
  const isWindowsAbsolute =
    /^[A-Za-z]:[\\/]/.test(rawValue) || /^\\\\/.test(rawValue);
  if (process.platform !== "win32" && isWindowsAbsolute) {
    return rawValue;
  }
  return nodePath.resolve(rawValue);
}

/** Options for the public Copilot {@link pushDownCustomizations} wrapper. */
export interface PushDownCustomizationsOptions {
  readonly repoRoot: string;
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  readonly sourceRoot?: string;
  readonly artifactRoot?: string;
  readonly rootFolders?: ReadonlyArray<string>;
  readonly artifactDirectory?: string;
  readonly rewriteReferences?: RewriteFunction;
  readonly clock?: Clock;
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
export function pushDownCustomizations(
  options: PushDownCustomizationsOptions,
): PushDownSummary {
  return enginePushDown({
    repoRoot: options.repoRoot,
    destinationRoot: options.destinationRoot,
    fs: options.fs,
    ...(options.sourceRoot === undefined
      ? {}
      : { sourceRoot: options.sourceRoot }),
    ...(options.artifactRoot === undefined
      ? {}
      : { artifactRoot: options.artifactRoot }),
    rootFolders: options.rootFolders ?? COPILOT_ROOT_FOLDERS,
    artifactDirectory: options.artifactDirectory ?? ARTIFACT_DIRECTORY,
    rewriteReferences: options.rewriteReferences ?? rewriteTextReferences,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
}
