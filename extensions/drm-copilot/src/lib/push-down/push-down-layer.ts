/**
 * Layer descriptor of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Describe one payload layer (the shared layer or one ecosystem layer) in
 *     the form the pipeline consumes: where its source lives, which roots and
 *     root files it publishes, the composed filesystem that applies its
 *     enumeration filters, variant reads, and destination-write decorators,
 *     its rewrite function, its merged paths and merged deliveries, its
 *     owning-pack lookup, and the selection it records.
 *
 * Invariants / Constraints:
 *     The pipeline imports this module and no ecosystem module; ecosystem
 *     modules build {@link PushDownLayer} values.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import { type DestinationManifestSelection } from "./push-down-destination-manifest";
import { type RewriteFunction } from "./reference-rewrites";

/** Layer names, in pipeline order. */
export type LayerName = "shared" | "claude" | "codex" | "copilot";

/** Ecosystem names. */
export type EcosystemName = "claude" | "codex" | "copilot";

/** Ecosystem names in the order the harness builds their layers. */
export const ECOSYSTEM_NAMES: ReadonlyArray<EcosystemName> = [
  "claude",
  "codex",
  "copilot",
];

/**
 * Narrow a string to an ecosystem name.
 *
 * @param value Candidate name.
 * @returns True when the value is `claude`, `codex`, or `copilot`.
 */
export function isEcosystemName(value: string): value is EcosystemName {
  return (ECOSYSTEM_NAMES as ReadonlyArray<string>).includes(value);
}

/**
 * One root file a layer publishes outside its root folders:
 * `[destination-relative path, resources-relative source path]`.
 */
export type RootFilePair = readonly [string, string];

/** A merged path with no source file behind it (for example `.gitignore`). */
export interface MergedDelivery {
  /** Destination-relative POSIX path. */
  readonly relativePath: string;
  /**
   * Merge the managed content into the current destination text.
   *
   * @param currentText Current destination text, or `""` when absent.
   * @returns The merged text.
   */
  merge(currentText: string): string;
}

/** Selection input for one ecosystem, as the service calls receive it. */
export interface EcosystemSelectionInput {
  /** Selected packs; omitted means "reuse the recorded selection". */
  readonly packs?: ReadonlyArray<string>;
  /** C# variant (`modern` or `legacy`); Claude and Codex only. */
  readonly csharpVariant?: "modern" | "legacy";
  /** Agent-memory mode; Claude and Codex only. */
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

/** One layer as the pipeline consumes it. */
export interface PushDownLayer {
  readonly name: LayerName;
  /** Root the layer's root folders are enumerated under (POSIX path). */
  readonly sourceRoot: string;
  /** Extension `resources` root that root-file sources are relative to. */
  readonly resourcesRoot: string;
  /** Root folders, in enumeration order. */
  readonly rootFolders: ReadonlyArray<string>;
  /** Root files published outside the root folders. */
  readonly rootFiles: ReadonlyArray<RootFilePair>;
  /**
   * Composed filesystem: enumeration filters and variant reads over the
   * destination-write decorators over the write-if-changed base.
   */
  readonly fs: PushDownFileSystem;
  /** Text rewrite applied to every payload file. */
  readonly rewrite: RewriteFunction;
  /** Source-backed destination paths whose write merges instead of copies. */
  readonly mergedPaths: ReadonlyArray<string>;
  /** Merged paths with no source file. */
  readonly mergedDeliveries: ReadonlyArray<MergedDelivery>;
  /**
   * Return the owning pack of a destination-relative path.
   *
   * @param relativePath Destination-relative POSIX path.
   * @returns The owning pack name (`core` for unscoped publishes).
   */
  ownerPack(relativePath: string): string;
  /** Selection recorded for an ecosystem layer; `undefined` for `shared`. */
  readonly selection: DestinationManifestSelection | undefined;
  /** Destination-relative directory of the per-run summary artifact. */
  readonly artifactDirectory: string;
}

/**
 * Root files per layer (O-10). A pair whose source is absent from the bundle
 * is skipped by the pipeline (D14). The Claude layer publishes `.mcp.json`
 * from the location the harness generator assigns it; no `CLAUDE.md` bundle
 * copy exists.
 */
export const LAYER_ROOT_FILES: Readonly<
  Record<LayerName, ReadonlyArray<RootFilePair>>
> = {
  shared: [["AGENTS.md", "codex-and-agents-customizations/AGENTS.md"]],
  claude: [[".mcp.json", "claude-dir-customizations/.mcp.json"]],
  codex: [],
  copilot: [
    [
      ".github/copilot-instructions.md",
      "customizations/.github/copilot-instructions.md",
    ],
  ],
};
