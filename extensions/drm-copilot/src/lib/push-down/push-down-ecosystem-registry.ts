/**
 * Ecosystem registry of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Map each ecosystem name to its bundle directory, its declared roots, and
 *     the builder of its layer, and guard that no layer root or root-file
 *     destination can capture the destination manifest path or the
 *     integration-needed file (issue #1051).
 *
 * Invariants / Constraints:
 *     The guard runs once at module load over the declared roots and again in
 *     the harness over the layers it builds. No core pipeline module imports
 *     this registry.
 */

import { assertManifestPathIsRootLevel } from "./claude-exclusion-manifest";
import {
  buildClaudeLayer,
  ROOT_FOLDERS as CLAUDE_ROOT_FOLDERS,
} from "./claude-customizations";
import {
  buildCodexLayer,
  ROOT_FOLDERS as CODEX_ROOT_FOLDERS,
  VIRTUAL_ROOT_FOLDERS,
} from "./codex-agents-customizations";
import { buildCopilotLayer } from "./copilot-customizations";
import { COPILOT_ROOT_FOLDERS } from "./copilot-customizations-engine";
import { type DirectoryLister } from "./claude-blast-radius-derive";
import { type PushDownFileSystem } from "./filesystem-adapter";
import { DESTINATION_MANIFEST_RELATIVE_PATH } from "./push-down-destination-manifest";
import {
  type EcosystemName,
  LAYER_ROOT_FILES,
  type LayerName,
  type PushDownLayer,
  type RootFilePair,
} from "./push-down-layer";
import { SHARED_LAYER_ROOT_FOLDERS } from "./push-down-shared-layer";
import { INTEGRATION_NEEDED_RELATIVE_PATH } from "../push-down-integration/integration-items";

/** Bundle directory under the extension `resources` root, per ecosystem. */
export const ECOSYSTEM_BUNDLE_DIRECTORIES: Readonly<
  Record<EcosystemName, string>
> = {
  claude: "claude-customizations",
  codex: "codex-and-agents-customizations",
  copilot: "customizations",
};

/** Declared root folders per layer. */
export const LAYER_ROOT_FOLDERS: Readonly<
  Record<LayerName, ReadonlyArray<string>>
> = {
  shared: SHARED_LAYER_ROOT_FOLDERS,
  claude: CLAUDE_ROOT_FOLDERS,
  codex: [...CODEX_ROOT_FOLDERS, ...VIRTUAL_ROOT_FOLDERS],
  copilot: COPILOT_ROOT_FOLDERS,
};

/** Inputs every ecosystem layer builder receives. */
export interface EcosystemLayerBuildInput {
  /** Bundle root of the ecosystem. */
  readonly bundleRoot: string;
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  /** Selected packs, or `null` for the full tree. */
  readonly packs: ReadonlyArray<string> | null;
  readonly csharpVariant: "modern" | "legacy";
  readonly memoryMode: "overwrite" | "merge" | "skip";
  /** Destination lister for the Claude blast-radius derivation. */
  readonly listEntries?: DirectoryLister;
}

/** Layer builder per ecosystem. */
export const ECOSYSTEM_LAYER_BUILDERS: Readonly<
  Record<EcosystemName, (input: EcosystemLayerBuildInput) => PushDownLayer>
> = {
  claude: (input) =>
    buildClaudeLayer({
      repoRoot: input.bundleRoot,
      sourceRoot: input.bundleRoot,
      bundleRoot: input.bundleRoot,
      destinationRoot: input.destinationRoot,
      fs: input.fs,
      packs: input.packs === null ? null : new Set(input.packs),
      csharpVariant: input.csharpVariant,
      memoryMode: input.memoryMode,
      ...(input.listEntries === undefined
        ? {}
        : { listEntries: input.listEntries }),
    }),
  codex: (input) =>
    buildCodexLayer({
      repoRoot: input.bundleRoot,
      sourceRoot: input.bundleRoot,
      bundleRoot: input.bundleRoot,
      destinationRoot: input.destinationRoot,
      fs: input.fs,
      packs: input.packs === null ? null : new Set(input.packs),
      csharpVariant: input.csharpVariant,
      memoryMode: input.memoryMode,
    }),
  copilot: (input) =>
    buildCopilotLayer({
      repoRoot: input.bundleRoot,
      sourceRoot: input.bundleRoot,
      bundleRoot: input.bundleRoot,
      destinationRoot: input.destinationRoot,
      fs: input.fs,
      packs: input.packs,
    }),
};

/** Roots and root files of one layer, as the guard reads them. */
export interface LayerRootDeclaration {
  readonly name: string;
  readonly rootFolders: ReadonlyArray<string>;
  readonly rootFiles: ReadonlyArray<RootFilePair>;
}

/**
 * Root-level destination paths no layer may capture: the destination manifest
 * and the integration-needed file (issue #1051).
 */
export const RESERVED_ROOT_LEVEL_PATHS: ReadonlyArray<string> = [
  DESTINATION_MANIFEST_RELATIVE_PATH,
  INTEGRATION_NEEDED_RELATIVE_PATH,
];

/**
 * Assert that no layer root or root-file destination captures a reserved
 * root-level path.
 *
 * @param layers Layers (or layer declarations) to check.
 * @throws Error When a root folder could contain a reserved path or a root
 *   file is published at one.
 */
export function assertDestinationManifestOutsideLayers(
  layers: ReadonlyArray<LayerRootDeclaration>,
): void {
  for (const layer of layers) {
    for (const reserved of RESERVED_ROOT_LEVEL_PATHS) {
      assertManifestPathIsRootLevel(reserved, layer.rootFolders);
    }
    for (const [destination] of layer.rootFiles) {
      if (RESERVED_ROOT_LEVEL_PATHS.includes(destination)) {
        throw new Error(
          `Layer ${layer.name} publishes a root file at a reserved root-level path: ${destination}`,
        );
      }
    }
  }
}

// The destination manifest must sit outside every declared root.
assertDestinationManifestOutsideLayers(
  (Object.keys(LAYER_ROOT_FOLDERS) as LayerName[]).map((name) => ({
    name,
    rootFolders: LAYER_ROOT_FOLDERS[name],
    rootFiles: LAYER_ROOT_FILES[name],
  })),
);
