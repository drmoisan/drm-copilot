/**
 * Entry point of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Push the shared layer and the selected ecosystem layers into one
 *     destination: read the destination manifest once, resolve each
 *     ecosystem's selection (explicit `packs` wins; omitted `packs` reuses the
 *     recorded selection; otherwise the full tree is published), build the
 *     shared layer then the selected layers in `ECOSYSTEM_NAMES` order, plan,
 *     and apply unless the run is a dry run.
 *
 * Side effects:
 *     Reads the bundle and the destination; an apply run writes destination
 *     files, the destination manifest, and the summary artifact.
 */

import { type DirectoryLister } from "./claude-blast-radius-derive";
import {
  type Clock,
  type PushDownSummary,
} from "./copilot-customizations-engine";
import { type ExclusionReport } from "./claude-exclusion-filter";
import { type PushDownFileSystem } from "./filesystem-adapter";
import { applyPushDownPlan, UNKNOWN_PAYLOAD_VERSION } from "./push-down-apply";
import { type DestinationManifest } from "./push-down-destination-manifest";
import {
  assertDestinationManifestOutsideLayers,
  ECOSYSTEM_BUNDLE_DIRECTORIES,
  ECOSYSTEM_LAYER_BUILDERS,
} from "./push-down-ecosystem-registry";
import {
  ECOSYSTEM_NAMES,
  type EcosystemName,
  type EcosystemSelectionInput,
  type PushDownLayer,
} from "./push-down-layer";
import { fullTreePacks } from "./push-down-pack-resolver";
import { joinPosix, runPushDownPipeline } from "./push-down-pipeline";
import { type PushDownReport } from "./push-down-report";
import { buildSharedLayer } from "./push-down-shared-layer";

/** Options of {@link pushDownHarness}. */
export interface PushDownHarnessOptions {
  /** Extension root holding `package.json` and `resources/`. */
  readonly extensionRoot: string;
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  /** Selected ecosystems and their selection inputs. */
  readonly ecosystems: Readonly<
    Partial<Record<EcosystemName, EcosystemSelectionInput>>
  >;
  readonly dryRun?: boolean;
  readonly overwriteUnmanaged?: boolean;
  readonly clock?: Clock;
  /** Destination lister for the Claude blast-radius derivation. */
  readonly listEntries?: DirectoryLister;
}

/** Result of {@link pushDownHarness}. */
export interface PushDownHarnessResult {
  readonly report: PushDownReport;
  /** Summary; `artifactPath` is empty for a dry run. */
  readonly summary: PushDownSummary;
  readonly exclusions?: ExclusionReport;
  /** Exclusion lines, then push-down conflict lines. */
  readonly warnings: ReadonlyArray<string>;
}

/**
 * Read `payload_version` from the extension `package.json` (D6).
 *
 * @param fs Adapter used for the read.
 * @param extensionRoot Extension root.
 * @returns The `version` value, or `0.0.0` when absent or unparseable.
 */
export function resolvePayloadVersion(
  fs: PushDownFileSystem,
  extensionRoot: string,
): string {
  const path = joinPosix(extensionRoot, "package.json");
  if (!fs.isFile(path)) {
    return UNKNOWN_PAYLOAD_VERSION;
  }
  try {
    const parsed: unknown = JSON.parse(fs.readTextFile(path));
    const version =
      parsed !== null && typeof parsed === "object"
        ? (parsed as Record<string, unknown>)["version"]
        : undefined;
    return typeof version === "string" && version !== ""
      ? version
      : UNKNOWN_PAYLOAD_VERSION;
  } catch {
    return UNKNOWN_PAYLOAD_VERSION;
  }
}

/**
 * Resolve the packs, variant, and memory mode of one ecosystem.
 *
 * @param input Selection input of the run.
 * @param previous Destination manifest, when present.
 * @param ecosystem Ecosystem name.
 * @returns The effective selection.
 */
function effectiveSelection(
  input: EcosystemSelectionInput,
  previous: DestinationManifest | undefined,
  ecosystem: EcosystemName,
): {
  packs: ReadonlyArray<string> | null;
  csharpVariant: "modern" | "legacy";
  memoryMode: "overwrite" | "merge" | "skip";
} {
  const recorded = previous?.selection[ecosystem];
  const explicit =
    input.packs !== undefined && input.packs.length > 0
      ? input.packs
      : undefined;
  const recordedVariant = recorded?.csharpVariant;
  const recordedMemory = recorded?.memoryMode;
  const csharpVariant =
    input.csharpVariant ?? (recordedVariant === "legacy" ? "legacy" : "modern");
  // A recorded full-tree selection (D5) is reused as the full tree (O-5).
  const recordedPacks =
    recorded === undefined ||
    recorded.packs.join(",") ===
      fullTreePacks(ecosystem, csharpVariant).join(",")
      ? null
      : recorded.packs;
  return {
    packs: explicit ?? recordedPacks,
    csharpVariant,
    memoryMode:
      input.memoryMode ??
      (recordedMemory === "merge" || recordedMemory === "skip"
        ? recordedMemory
        : "overwrite"),
  };
}

/**
 * Push the shared layer and the selected ecosystem layers into a destination.
 *
 * @param options Extension root, destination, adapter, ecosystem selection,
 *   and run options.
 * @returns The report, summary, exclusion report, and warnings.
 * @throws Error When no ecosystem is selected, or for any pipeline failure
 *   (all before the first write).
 */
export function pushDownHarness(
  options: PushDownHarnessOptions,
): PushDownHarnessResult {
  const selected = ECOSYSTEM_NAMES.filter(
    (name) => options.ecosystems[name] !== undefined,
  );
  const lastEcosystem = selected[selected.length - 1];
  if (lastEcosystem === undefined) {
    throw new Error("Push-down harness requires at least one ecosystem.");
  }
  const resourcesRoot = joinPosix(options.extensionRoot, "resources");
  const bundleRoot = (name: EcosystemName): string =>
    joinPosix(resourcesRoot, ECOSYSTEM_BUNDLE_DIRECTORIES[name]);
  const buildLayers = (
    previous: DestinationManifest | undefined,
  ): PushDownLayer[] => {
    const ecosystemLayers = selected.map((name) =>
      ECOSYSTEM_LAYER_BUILDERS[name]({
        bundleRoot: bundleRoot(name),
        destinationRoot: options.destinationRoot,
        fs: options.fs,
        ...effectiveSelection(options.ecosystems[name] ?? {}, previous, name),
        ...(options.listEntries === undefined
          ? {}
          : { listEntries: options.listEntries }),
      }),
    );
    const layers = [
      buildSharedLayer({
        bundleRoot: bundleRoot("codex"),
        resourcesRoot,
        destinationRoot: options.destinationRoot,
        fs: options.fs,
        artifactDirectory:
          ecosystemLayers[ecosystemLayers.length - 1]?.artifactDirectory ??
          "artifacts/push-down",
      }),
      ...ecosystemLayers,
    ];
    assertDestinationManifestOutsideLayers(layers);
    return layers;
  };
  const planned = runPushDownPipeline({
    repoRoot: bundleRoot(lastEcosystem),
    destinationRoot: options.destinationRoot,
    fs: options.fs,
    buildLayers,
    dryRun: options.dryRun === true,
    overwriteUnmanaged: options.overwriteUnmanaged === true,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
  if (options.dryRun === true) {
    return {
      report: planned.report,
      summary: planned.summary,
      ...(planned.exclusions === undefined
        ? {}
        : { exclusions: planned.exclusions }),
      warnings: planned.warnings,
    };
  }
  const applied = applyPushDownPlan(planned, {
    payloadVersion: resolvePayloadVersion(options.fs, options.extensionRoot),
    artifactRoot: options.destinationRoot,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
  return {
    report: applied.report,
    summary: applied.summary,
    ...(applied.exclusions === undefined
      ? {}
      : { exclusions: applied.exclusions }),
    warnings: applied.warnings,
  };
}
