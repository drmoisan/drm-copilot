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
  type PushDownSummary,
} from "./copilot-customizations-engine";
import {
  rewriteTextReferences,
  type RewriteFunction,
} from "./reference-rewrites";
import { LAYER_ROOT_FILES, type PushDownLayer } from "./push-down-layer";
import {
  PublishedPathFilterFileSystem,
  resolveLayerPublishedPaths,
} from "./push-down-pack-resolver";
import { runPushDownPipeline } from "./push-down-pipeline";
import { applyPushDownPlan, UNKNOWN_PAYLOAD_VERSION } from "./push-down-apply";
import { WriteIfChangedFileSystem } from "./push-down-write-if-changed";

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
  /** Copilot pack selection; omitted or empty publishes the full tree. */
  readonly packs?: ReadonlyArray<string> | null;
  /** Bundle root holding `pack-manifests/`; defaults to the source root. */
  readonly bundleRoot?: string;
  /** Overwrite `unmanaged-conflict` files (O-4 opt-in, issue #1029). */
  readonly overwriteUnmanaged?: boolean;
}

/**
 * Return the parent directory of a POSIX path.
 *
 * @param path POSIX path.
 * @returns The parent path, or `""` for a bare name.
 */
function parentPosix(path: string): string {
  const normalized = path.replace(/\\/g, "/").replace(/\/+$/, "");
  return normalized.slice(0, Math.max(normalized.lastIndexOf("/"), 0));
}

/**
 * Build the Copilot layer (issue #1029).
 *
 * @param options Public options (roots, filesystem, selection, overrides).
 * @returns The Copilot layer for the push-down pipeline.
 * @throws ManifestError When a selected manifest is missing or malformed or a
 *   pack name is unknown.
 */
export function buildCopilotLayer(
  options: PushDownCustomizationsOptions,
): PushDownLayer {
  const sourceRoot = options.sourceRoot ?? options.repoRoot;
  const resolved = resolveLayerPublishedPaths({
    ecosystem: "copilot",
    packs: options.packs ?? null,
    csharpVariant: "modern",
    memoryMode: "overwrite",
    bundleRoot: options.bundleRoot ?? sourceRoot,
    fs: options.fs,
  });
  return {
    name: "copilot",
    sourceRoot,
    resourcesRoot: parentPosix(sourceRoot),
    rootFolders: options.rootFolders ?? COPILOT_ROOT_FOLDERS,
    rootFiles: LAYER_ROOT_FILES.copilot,
    fs: new PublishedPathFilterFileSystem(
      new WriteIfChangedFileSystem(options.fs),
      sourceRoot,
      resolved.publishedPaths,
    ),
    rewrite: options.rewriteReferences ?? rewriteTextReferences,
    mergedPaths: [],
    mergedDeliveries: [],
    ownerPack: resolved.ownerPack,
    selection: resolved.selection,
    artifactDirectory: options.artifactDirectory ?? ARTIFACT_DIRECTORY,
  };
}

/**
 * Public Copilot push-down entry point.
 *
 * A single-layer adapter over the push-down pipeline (no shared layer).
 * Defaults `rewriteReferences` to {@link rewriteTextReferences} and
 * `rootFolders` to the inlined copilot tuple.
 *
 * @param options Public options (roots, filesystem, optional overrides).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
export function pushDownCustomizations(
  options: PushDownCustomizationsOptions,
): PushDownSummary {
  const planned = runPushDownPipeline({
    repoRoot: options.repoRoot,
    destinationRoot: options.destinationRoot,
    fs: options.fs,
    buildLayers: () => [buildCopilotLayer(options)],
    overwriteUnmanaged: options.overwriteUnmanaged === true,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
  return applyPushDownPlan(planned, {
    payloadVersion: UNKNOWN_PAYLOAD_VERSION,
    artifactRoot: options.artifactRoot ?? options.repoRoot,
    artifactDirectory: options.artifactDirectory ?? ARTIFACT_DIRECTORY,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  }).summary;
}
