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
import {
  type DestinationManifest,
  type DestinationManifestSelection,
} from "./push-down-destination-manifest";
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
import {
  attachIntegrationNeeded,
  type PushDownReportWithIntegration,
  recordIntegrationNeeded,
} from "./push-down-integration-needed";
import { buildSharedLayer } from "./push-down-shared-layer";
import {
  buildCiWorkflowsContribution,
  withCiWorkflows,
} from "./push-down-ci-layer";
import {
  type CiSelectionRecord,
  type CiWorkflowsMode,
  inferCiWorkflowsMode,
} from "./push-down-ci-workflows";

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
  /**
   * Destination CI mode (issue #1050); omitted reuses the mode inferred from
   * the destination manifest, which is `off` without a CI data-file entry.
   */
  readonly ciWorkflows?: CiWorkflowsMode;
}

/** Result of {@link pushDownHarness}. */
export interface PushDownHarnessResult {
  /** Report; carries `integration_needed` when the run has items (#1051). */
  readonly report: PushDownReportWithIntegration;
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
 * Return the selection union the CI caller covers: the selections this run
 * resolved plus the recorded selections of ecosystems outside the run.
 *
 * @param ecosystemLayers Ecosystem layers of the run.
 * @param previous Destination manifest, when present.
 * @returns One selection record per ecosystem.
 */
function ciSelectionUnion(
  ecosystemLayers: ReadonlyArray<PushDownLayer>,
  previous: DestinationManifest | undefined,
): CiSelectionRecord[] {
  const inRun = new Set<string>(ecosystemLayers.map((layer) => layer.name));
  const recorded = Object.entries(previous?.selection ?? {})
    .filter(([ecosystem]) => !inRun.has(ecosystem))
    .map(([, selection]) => selection);
  // Every ecosystem layer records a selection; the guard narrows the type.
  const resolved = ecosystemLayers
    .map((layer) => layer.selection)
    .filter(
      (selection): selection is DestinationManifestSelection =>
        selection !== undefined,
    );
  return [...resolved, ...recorded];
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
  // Each selected ecosystem keeps its input, so no later lookup can miss it.
  const selected = ECOSYSTEM_NAMES.flatMap((name) => {
    const input = options.ecosystems[name];
    return input === undefined ? [] : [{ name, input }];
  });
  const lastEcosystem = selected[selected.length - 1]?.name;
  if (lastEcosystem === undefined) {
    throw new Error("Push-down harness requires at least one ecosystem.");
  }
  const resourcesRoot = joinPosix(options.extensionRoot, "resources");
  const bundleRoot = (name: EcosystemName): string =>
    joinPosix(resourcesRoot, ECOSYSTEM_BUNDLE_DIRECTORIES[name]);
  const payloadVersion = resolvePayloadVersion(
    options.fs,
    options.extensionRoot,
  );
  // Workflow-name collision lines of the CI contribution, filled while the
  // layers are built so a dry run reports them too.
  const ciWarnings: string[] = [];
  const buildLayers = (
    previous: DestinationManifest | undefined,
  ): PushDownLayer[] => {
    const ecosystemLayers = selected.map(({ name, input }) =>
      ECOSYSTEM_LAYER_BUILDERS[name]({
        bundleRoot: bundleRoot(name),
        destinationRoot: options.destinationRoot,
        fs: options.fs,
        ...effectiveSelection(input, previous, name),
        ...(options.listEntries === undefined
          ? {}
          : { listEntries: options.listEntries }),
      }),
    );
    const sharedLayer = buildSharedLayer({
      bundleRoot: bundleRoot("codex"),
      resourcesRoot,
      destinationRoot: options.destinationRoot,
      fs: options.fs,
      artifactDirectory:
        ecosystemLayers[ecosystemLayers.length - 1]?.artifactDirectory ??
        "artifacts/push-down",
    });
    // An explicit mode wins; otherwise the recorded mode is reused (O-5).
    const mode = options.ciWorkflows ?? inferCiWorkflowsMode(previous);
    const contribution =
      mode === "off"
        ? undefined
        : buildCiWorkflowsContribution({
            fs: options.fs,
            resourcesRoot,
            destinationRoot: options.destinationRoot,
            mode,
            selectionRecords: ciSelectionUnion(ecosystemLayers, previous),
            payloadVersion,
          });
    ciWarnings.push(...(contribution?.warnings ?? []));
    const layers = [
      contribution === undefined
        ? sharedLayer
        : withCiWorkflows(sharedLayer, contribution),
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
  const applied =
    options.dryRun === true
      ? undefined
      : applyPushDownPlan(planned, {
          payloadVersion,
          artifactRoot: options.destinationRoot,
          ...(options.clock === undefined ? {} : { clock: options.clock }),
        });
  const outcome = applied ?? planned;
  // Issue #1051: record the decisions the run could not make mechanically.
  const integration = recordIntegrationNeeded({
    planned,
    report: outcome.report,
    apply: applied !== undefined,
    fs: options.fs,
    destinationRoot: options.destinationRoot,
    extensionRoot: options.extensionRoot,
    payloadVersion,
  });
  return {
    report: attachIntegrationNeeded(outcome.report, integration),
    summary: outcome.summary,
    ...(outcome.exclusions === undefined
      ? {}
      : { exclusions: outcome.exclusions }),
    warnings: [...outcome.warnings, ...ciWarnings],
  };
}
