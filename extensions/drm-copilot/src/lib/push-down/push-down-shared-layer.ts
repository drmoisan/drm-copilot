/**
 * Shared layer of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Build the layer every push-down run installs first: `AGENTS.md`, the
 *     shared `.agents/skills/<name>/` files listed by `shared.json`, and the
 *     three shared configuration files, with `config/orchestration-routing.json`
 *     merged rather than overwritten (D2).
 *
 * Invariants / Constraints:
 *     - The shared path set is exactly `shared.json` `paths` (D15).
 *     - No path of {@link SHARED_LAYER_ECOSYSTEM_EXCEPTIONS} may be listed by
 *       `shared.json`; those files stay in their ecosystem layer (D16).
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import { ManifestError } from "./claude-pack-selection";
import { RoutingMergeFileSystem } from "./claude-routing-merge";
import {
  passthroughRewrite,
  RoutingConfigFileSystem,
  ROUTING_CONFIG_RELATIVE_PATH,
} from "./codex-agents-customizations";
import { MANIFEST_CORE_PACK } from "./push-down-destination-manifest";
import { LAYER_ROOT_FILES, type PushDownLayer } from "./push-down-layer";
import {
  loadSharedLayerPaths,
  PACK_MANIFEST_DIRECTORY,
  PublishedPathFilterFileSystem,
} from "./push-down-pack-resolver";
import { WriteIfChangedFileSystem } from "./push-down-write-if-changed";

/** One file of a shared skill folder that stays in an ecosystem layer. */
export interface SharedLayerEcosystemException {
  /** Destination-relative path under a shared skill folder. */
  readonly path: string;
  /** Layer that keeps the file. */
  readonly layer: "claude" | "codex" | "copilot";
  /** Why the file cannot be shared. */
  readonly reason: string;
}

/** Ecosystem-layer exceptions of the shared set (D16, spec amendment A-1). */
export const SHARED_LAYER_ECOSYSTEM_EXCEPTIONS: ReadonlyArray<SharedLayerEcosystemException> =
  Object.freeze([
    Object.freeze({
      path: ".agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1",
      layer: "codex",
      reason:
        "imports the repository PoshQC module and is reached only through the test-execution launcher",
    }),
    Object.freeze({
      path: ".agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1",
      layer: "codex",
      reason:
        "dot-sources its helpers from .claude/hooks or .codex/hooks and reads config/test-execution-policy.json, none of which is in the shared set",
    }),
    Object.freeze({
      path: ".agents/skills/test-execution-policy/scripts/run-test-suite.sh",
      layer: "codex",
      reason: "runs the sibling Invoke-TestSuite.ps1",
    }),
  ] as const);

/** Root folders of the shared layer. */
export const SHARED_LAYER_ROOT_FOLDERS: ReadonlyArray<string> = [
  ".agents",
  "config",
];

/** Inputs of {@link buildSharedLayer}. */
export interface SharedLayerOptions {
  /** Codex bundle root holding `.agents`, `AGENTS.md`, and `pack-manifests`. */
  readonly bundleRoot: string;
  /** Extension `resources` root (the parent of the bundle root). */
  readonly resourcesRoot: string;
  /** Destination workspace root. */
  readonly destinationRoot: string;
  /** Raw destination and source adapter. */
  readonly fs: PushDownFileSystem;
  /** Artifact directory of the run's ecosystem. */
  readonly artifactDirectory: string;
}

/**
 * Build the shared layer.
 *
 * @param options Bundle and resources roots, destination, adapter.
 * @returns The shared layer.
 * @throws ManifestError When `shared.json` is missing or malformed, or lists
 *   an ecosystem-layer exception.
 */
export function buildSharedLayer(options: SharedLayerOptions): PushDownLayer {
  const manifestDir = `${options.bundleRoot.replace(/\\/g, "/").replace(/\/+$/, "")}/${PACK_MANIFEST_DIRECTORY}`;
  const sharedPaths = loadSharedLayerPaths(manifestDir, options.fs);
  const listed = SHARED_LAYER_ECOSYSTEM_EXCEPTIONS.filter((exception) =>
    sharedPaths.has(exception.path),
  );
  if (listed.length > 0) {
    throw new ManifestError(
      `Shared-layer manifest lists ecosystem-layer exception(s): ${listed.map((exception) => exception.path).join(", ")}`,
    );
  }
  const merging = new RoutingMergeFileSystem(
    new WriteIfChangedFileSystem(options.fs),
    options.destinationRoot,
    ROUTING_CONFIG_RELATIVE_PATH,
  );
  const routing = new RoutingConfigFileSystem(merging, {
    sourceRoot: options.bundleRoot,
    bundleRoot: options.bundleRoot,
  });
  return {
    name: "shared",
    sourceRoot: options.bundleRoot,
    resourcesRoot: options.resourcesRoot,
    rootFolders: SHARED_LAYER_ROOT_FOLDERS,
    rootFiles: LAYER_ROOT_FILES.shared,
    fs: new PublishedPathFilterFileSystem(
      routing,
      options.bundleRoot,
      sharedPaths,
    ),
    rewrite: passthroughRewrite,
    mergedPaths: [ROUTING_CONFIG_RELATIVE_PATH],
    mergedDeliveries: [],
    ownerPack: () => MANIFEST_CORE_PACK,
    selection: undefined,
    artifactDirectory: options.artifactDirectory,
  };
}
