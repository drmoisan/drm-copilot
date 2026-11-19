/**
 * Planning half of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Validate the destination, read `.push-down-exclusions` and
 *     `.push-down-manifest.json`, build the layers, enumerate every layer in
 *     order (an earlier layer's claim on a path wins), classify every path, and
 *     build the report, all before any write. A dry run stops here; an apply
 *     run hands the returned plan to `applyPushDownPlan`.
 *
 * Invariants / Constraints:
 *     - This module performs no write.
 *     - It imports no ecosystem module; layers are supplied by the caller.
 *
 * Side effects:
 *     Reads source, bundle, and destination files through the adapters.
 */

import { type PushDownFileSystem, toPosixPath } from "./filesystem-adapter";
import {
  type Clock,
  enumerateSourceFiles,
  type PushDownFileResult,
  type PushDownSummary,
  validateDestination,
} from "./copilot-customizations-engine";
import {
  buildExclusionReport,
  ExclusionFilterFileSystem,
  type ExclusionReport,
  readExclusionManifest,
  renderExclusionLines,
} from "./claude-exclusion-filter";
import {
  type ExclusionManifest,
  matchesExclusionEntry,
  type SkippedPath,
} from "./claude-exclusion-manifest";
import {
  type DestinationManifest,
  hashPayloadText,
  readDestinationManifest,
} from "./push-down-destination-manifest";
import {
  classifyPayloadFile,
  type PayloadClassification,
  PUSH_DOWN_ACTION_REASONS,
} from "./push-down-plan-comparator";
import {
  buildPushDownReport,
  type PushDownReport,
  type PushDownReportEcosystem,
  type PushDownReportFile,
  renderPushDownConflictLines,
} from "./push-down-report";
import { type MergedDelivery, type PushDownLayer } from "./push-down-layer";

/** Options of {@link runPushDownPipeline}. */
export interface PushDownPipelineOptions {
  /** Source repository root; the destination must differ from it. */
  readonly repoRoot: string;
  /** Destination workspace root (POSIX path). */
  readonly destinationRoot: string;
  /** Raw destination adapter (no decorators). */
  readonly fs: PushDownFileSystem;
  /**
   * Build the layers, shared layer first, after the destination manifest is
   * read; any failure here still precedes every write.
   */
  readonly buildLayers: (
    previousManifest: DestinationManifest | undefined,
  ) => ReadonlyArray<PushDownLayer>;
  /** Plan and report only. */
  readonly dryRun?: boolean;
  /** Overwrite `unmanaged-conflict` files (O-4 opt-in). */
  readonly overwriteUnmanaged?: boolean;
  /** Clock for the summary timestamps. */
  readonly clock?: Clock;
}

/** One planned path of a layer. */
export type PlannedEntry =
  | {
      readonly kind: "payload";
      readonly layer: PushDownLayer;
      readonly relativePath: string;
      readonly destinationPath: string;
      readonly payloadText: string;
      /** Layer adapter the file was read through (writes use it too). */
      readonly fs: PushDownFileSystem;
      readonly merged: boolean;
      readonly classification: PayloadClassification | undefined;
    }
  | {
      readonly kind: "delivery";
      readonly layer: PushDownLayer;
      readonly relativePath: string;
      readonly destinationPath: string;
      readonly delivery: MergedDelivery;
    };

/** Plan an apply run executes. */
export interface PushDownPlan {
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  readonly layers: ReadonlyArray<PushDownLayer>;
  readonly entries: ReadonlyArray<PlannedEntry>;
  readonly previousManifest: DestinationManifest | undefined;
  readonly exclusionManifest: ExclusionManifest | undefined;
}

/** Result of {@link runPushDownPipeline}. */
export interface PushDownPipelineResult {
  readonly report: PushDownReport;
  /** Run summary; `artifactPath` is empty until an apply run writes it. */
  readonly summary: PushDownSummary;
  /** Exclusion report, present only when the destination has a manifest. */
  readonly exclusions?: ExclusionReport;
  /** Exclusion lines, then push-down conflict lines. */
  readonly warnings: ReadonlyArray<string>;
  readonly plan: PushDownPlan;
}

/**
 * Join a root and a relative path with one forward slash.
 *
 * @param root Base path.
 * @param relative Relative path.
 * @returns The joined POSIX path.
 */
export function joinPosix(root: string, relative: string): string {
  const normalizedRoot = toPosixPath(root).replace(/\/+$/, "");
  const normalizedRelative = toPosixPath(relative).replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedRelative
    : `${normalizedRoot}/${normalizedRelative}`;
}

/** Mutable state accumulated while the layers are enumerated. */
interface PlanningState {
  readonly claimed: Set<string>;
  readonly entries: PlannedEntry[];
  readonly reportFiles: PushDownReportFile[];
  readonly skipped: SkippedPath[];
  readonly summaryFiles: PushDownFileResult[];
  readonly unmatchedReferences: string[];
  rewrittenReferenceCount: number;
  placeholderRewriteCount: number;
}

/** Fixed context of one planning run. */
interface PlanningContext {
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  readonly previous: DestinationManifest | undefined;
  readonly exclusion: ExclusionManifest | undefined;
  readonly overwriteUnmanaged: boolean;
}

/**
 * Return the first exclusion entry matching a path as a skip record.
 *
 * @param context Planning context.
 * @param relativePath Destination-relative path.
 * @returns The skip record, or `undefined` when the path is not excluded.
 */
function exclusionSkip(
  context: PlanningContext,
  relativePath: string,
): SkippedPath | undefined {
  const entry = context.exclusion?.entries.find((candidate) =>
    matchesExclusionEntry(candidate, relativePath),
  );
  if (entry === undefined) {
    return undefined;
  }
  return {
    relativePath,
    entry: entry.normalized,
    line: entry.line,
    destinationStatus: context.fs.isFile(
      joinPosix(context.destinationRoot, relativePath),
    )
      ? "present"
      : "absent",
  };
}

/**
 * Record an excluded path unless an earlier layer claimed it.
 *
 * @param state Planning state.
 * @param layer Layer that offered the path.
 * @param skip Skip record.
 */
function recordExcluded(
  state: PlanningState,
  layer: PushDownLayer,
  skip: SkippedPath,
): void {
  if (state.claimed.has(skip.relativePath)) {
    return;
  }
  state.claimed.add(skip.relativePath);
  state.skipped.push(skip);
  state.reportFiles.push({
    path: skip.relativePath,
    layer: layer.name,
    pack: layer.ownerPack(skip.relativePath),
    action: "excluded",
    reason: PUSH_DOWN_ACTION_REASONS.excluded,
  });
}

/**
 * Plan one source-backed payload file.
 *
 * @param context Planning context.
 * @param state Planning state.
 * @param layer Owning layer.
 * @param layerFs Layer adapter used for the read.
 * @param relativePath Destination-relative path.
 * @param sourcePath Absolute source path.
 */
function planPayloadFile(
  context: PlanningContext,
  state: PlanningState,
  layer: PushDownLayer,
  layerFs: PushDownFileSystem,
  relativePath: string,
  sourcePath: string,
): void {
  if (state.claimed.has(relativePath)) {
    return;
  }
  state.claimed.add(relativePath);
  const destinationPath = joinPosix(context.destinationRoot, relativePath);
  const [payloadText, rewritten, placeholders, unmatched] = layer.rewrite(
    layerFs.readTextFile(sourcePath),
  );
  state.rewrittenReferenceCount += rewritten;
  state.placeholderRewriteCount += placeholders;
  for (const reference of unmatched) {
    if (!state.unmatchedReferences.includes(reference)) {
      state.unmatchedReferences.push(reference);
    }
  }
  const present = context.fs.isFile(destinationPath);
  const merged = layer.mergedPaths.includes(relativePath);
  // A protected path (issue #1050) never takes the overwrite opt-in.
  const overwriteUnmanaged =
    context.overwriteUnmanaged &&
    !(layer.unmanagedProtectedPaths?.includes(relativePath) ?? false);
  const classification = merged
    ? undefined
    : classifyPayloadFile({
        destinationHash: present
          ? hashPayloadText(context.fs.readTextFile(destinationPath))
          : undefined,
        manifestHash: context.previous?.files[relativePath]?.sha256,
        payloadHash: hashPayloadText(payloadText),
        overwriteUnmanaged,
      });
  state.entries.push({
    kind: "payload",
    layer,
    relativePath,
    destinationPath,
    payloadText,
    fs: layerFs,
    merged,
    classification,
  });
  state.reportFiles.push({
    path: relativePath,
    layer: layer.name,
    pack: layer.ownerPack(relativePath),
    action: classification?.action ?? "merge",
    reason: classification?.reason ?? PUSH_DOWN_ACTION_REASONS.merge,
  });
  state.summaryFiles.push({
    relativePath,
    destinationStatus: present ? "overwritten" : "created",
    rewrittenReferenceCount: rewritten,
    placeholderRewriteCount: placeholders,
    unmatchedReferences: unmatched,
  });
}

/**
 * Plan every path one layer offers.
 *
 * @param context Planning context.
 * @param state Planning state.
 * @param layer Layer to plan.
 */
function planLayer(
  context: PlanningContext,
  state: PlanningState,
  layer: PushDownLayer,
): void {
  const filter =
    context.exclusion === undefined
      ? undefined
      : new ExclusionFilterFileSystem(
          layer.fs,
          layer.sourceRoot,
          context.destinationRoot,
          context.exclusion,
          layer.artifactDirectory,
        );
  const layerFs = filter ?? layer.fs;
  const sourcePrefix = `${toPosixPath(layer.sourceRoot).replace(/\/+$/, "")}/`;
  for (const sourcePath of enumerateSourceFiles(
    layerFs,
    layer.sourceRoot,
    layer.rootFolders,
  )) {
    planPayloadFile(
      context,
      state,
      layer,
      layerFs,
      sourcePath.slice(sourcePrefix.length),
      sourcePath,
    );
  }
  for (const skip of filter?.skipped ?? []) {
    recordExcluded(state, layer, skip);
  }
  for (const [relativePath, resourcePath] of layer.rootFiles) {
    const sourcePath = joinPosix(layer.resourcesRoot, resourcePath);
    // D14: a root-file pair whose source is absent from the bundle is skipped.
    if (!layer.fs.isFile(sourcePath)) {
      continue;
    }
    const skip = exclusionSkip(context, relativePath);
    if (skip === undefined) {
      planPayloadFile(context, state, layer, layerFs, relativePath, sourcePath);
    } else {
      recordExcluded(state, layer, skip);
    }
  }
  for (const delivery of layer.mergedDeliveries) {
    const skip = exclusionSkip(context, delivery.relativePath);
    if (skip !== undefined) {
      recordExcluded(state, layer, skip);
      continue;
    }
    if (state.claimed.has(delivery.relativePath)) {
      continue;
    }
    state.claimed.add(delivery.relativePath);
    state.entries.push({
      kind: "delivery",
      layer,
      relativePath: delivery.relativePath,
      destinationPath: joinPosix(
        context.destinationRoot,
        delivery.relativePath,
      ),
      delivery,
    });
    state.reportFiles.push({
      path: delivery.relativePath,
      layer: layer.name,
      pack: layer.ownerPack(delivery.relativePath),
      action: "merge",
      reason: PUSH_DOWN_ACTION_REASONS.merge,
    });
  }
}

/**
 * Report manifest entries of in-run layers that have no payload counterpart.
 *
 * @param context Planning context.
 * @param state Planning state.
 * @param layers Layers of the run.
 */
function planOrphans(
  context: PlanningContext,
  state: PlanningState,
  layers: ReadonlyArray<PushDownLayer>,
): void {
  const inRun = new Set<string>(layers.map((layer) => layer.name));
  for (const [path, entry] of Object.entries(context.previous?.files ?? {})) {
    if (!inRun.has(entry.layer) || state.claimed.has(path)) {
      continue;
    }
    state.reportFiles.push({
      path,
      layer: entry.layer,
      pack: entry.pack,
      action: "orphaned",
      reason: PUSH_DOWN_ACTION_REASONS.orphaned,
    });
  }
}

/**
 * Build the report's ecosystem map from the ecosystem layers of the run.
 *
 * @param layers Layers of the run.
 * @returns Selection per ecosystem, in report (snake_case) form.
 */
export function reportEcosystems(
  layers: ReadonlyArray<PushDownLayer>,
): Record<string, PushDownReportEcosystem> {
  const ecosystems: Record<string, PushDownReportEcosystem> = {};
  for (const layer of layers) {
    const selection = layer.selection;
    if (selection === undefined) {
      continue;
    }
    ecosystems[layer.name] = {
      packs: [...selection.packs],
      ...(selection.csharpVariant === undefined
        ? {}
        : { csharp_variant: selection.csharpVariant }),
      ...(selection.memoryMode === undefined
        ? {}
        : { memory_mode: selection.memoryMode }),
    };
  }
  return ecosystems;
}

/**
 * Plan a push-down run; write nothing.
 *
 * @param options Roots, adapter, layer builder, and run options.
 * @returns The report, summary, exclusion report, warnings, and plan.
 * @throws Error When the destination is missing or equals the source, the
 *   exclusion or destination manifest is invalid, or a layer cannot be built.
 */
export function runPushDownPipeline(
  options: PushDownPipelineOptions,
): PushDownPipelineResult {
  const destinationRoot = toPosixPath(options.destinationRoot);
  const fs = options.fs;
  validateDestination(destinationRoot, options.repoRoot, fs);
  const now = options.clock ?? (() => new Date());
  const startedAt = now();
  const exclusion = readExclusionManifest(fs, destinationRoot);
  const previous = readDestinationManifest(fs, destinationRoot);
  const layers = options.buildLayers(previous);
  const context: PlanningContext = {
    destinationRoot,
    fs,
    previous,
    exclusion,
    overwriteUnmanaged: options.overwriteUnmanaged === true,
  };
  const state: PlanningState = {
    claimed: new Set(),
    entries: [],
    reportFiles: [],
    skipped: [],
    summaryFiles: [],
    unmatchedReferences: [],
    rewrittenReferenceCount: 0,
    placeholderRewriteCount: 0,
  };
  for (const layer of layers) {
    planLayer(context, state, layer);
  }
  planOrphans(context, state, layers);
  const report = buildPushDownReport({
    mode: options.dryRun === true ? "dry-run" : "apply",
    ecosystems: reportEcosystems(layers),
    files: state.reportFiles,
  });
  const exclusions =
    exclusion === undefined
      ? undefined
      : buildExclusionReport(exclusion, state.skipped);
  const summary: PushDownSummary = {
    repoRoot: toPosixPath(options.repoRoot),
    destinationRoot,
    startedAt,
    finishedAt: now(),
    createdCount: state.summaryFiles.filter(
      (file) => file.destinationStatus === "created",
    ).length,
    overwrittenCount: state.summaryFiles.filter(
      (file) => file.destinationStatus === "overwritten",
    ).length,
    rewrittenReferenceCount: state.rewrittenReferenceCount,
    placeholderRewriteCount: state.placeholderRewriteCount,
    unmatchedReferences: state.unmatchedReferences,
    files: state.summaryFiles,
    artifactPath: "",
  };
  return {
    report,
    summary,
    ...(exclusions === undefined ? {} : { exclusions }),
    warnings: [
      ...(exclusions === undefined ? [] : renderExclusionLines(exclusions)),
      ...renderPushDownConflictLines(report),
    ],
    plan: {
      destinationRoot,
      fs,
      layers,
      entries: state.entries,
      previousManifest: previous,
      exclusionManifest: exclusion,
    },
  };
}
