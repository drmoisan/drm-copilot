/**
 * Apply half of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Execute a plan produced by `runPushDownPipeline`: write `create`,
 *     `update`, and opted-in `unmanaged-conflict` files, run merged paths and
 *     merged deliveries through the write-if-changed base, write the
 *     destination manifest only when its text changed, and write the summary
 *     artifact with a per-file `action`.
 *
 * Invariants / Constraints:
 *     - No file the plan did not mark for writing is written.
 *     - Manifest entries of layers not in the run, and selection entries of
 *       ecosystems not selected, are copied unchanged.
 *     - Nothing is deleted.
 */

import {
  type Clock,
  type PushDownSummary,
  writeSummaryArtifact,
} from "./copilot-customizations-engine";
import { appendExclusionsToArtifact } from "./claude-exclusion-filter";
import {
  DESTINATION_MANIFEST_RELATIVE_PATH,
  DESTINATION_MANIFEST_SCHEMA_VERSION,
  type DestinationManifest,
  type DestinationManifestFileEntry,
  type DestinationManifestSelection,
  renderDestinationManifest,
} from "./push-down-destination-manifest";
import {
  joinPosix,
  type PlannedEntry,
  type PushDownPipelineResult,
} from "./push-down-pipeline";
import { type PushDownReport } from "./push-down-report";
import { WriteIfChangedFileSystem } from "./push-down-write-if-changed";

/** `payload_version` used when the extension version is not known (D6). */
export const UNKNOWN_PAYLOAD_VERSION = "0.0.0";

/** Options of {@link applyPushDownPlan}. */
export interface PushDownApplyOptions {
  /** Extension version recorded as `payload_version`. */
  readonly payloadVersion: string;
  /** Root of the summary artifact; defaults to the summary's repo root. */
  readonly artifactRoot?: string;
  /** Artifact directory; defaults to the last layer's directory. */
  readonly artifactDirectory?: string;
  /** Clock for the summary finish time. */
  readonly clock?: Clock;
}

/** Result of {@link applyPushDownPlan}. */
export interface PushDownApplyResult {
  readonly report: PushDownReport;
  /** Run summary with the written artifact path and per-file actions. */
  readonly summary: PushDownSummary;
  readonly exclusions?: PushDownPipelineResult["exclusions"];
  readonly warnings: ReadonlyArray<string>;
}

/**
 * Return the parent directory of a POSIX path.
 *
 * @param path POSIX path.
 * @returns The parent path.
 */
function parentOf(path: string): string {
  return path.slice(0, path.lastIndexOf("/"));
}

/**
 * Write one planned entry, when the plan calls for a write.
 *
 * @param entry Planned entry.
 * @param base Write-if-changed adapter over the raw destination adapter.
 */
function applyEntry(entry: PlannedEntry, base: WriteIfChangedFileSystem): void {
  if (entry.kind === "delivery") {
    const current = base.isFile(entry.destinationPath)
      ? base.readTextFile(entry.destinationPath)
      : "";
    base.writeTextFile(entry.destinationPath, entry.delivery.merge(current));
    return;
  }
  if (!entry.merged && entry.classification?.write !== true) {
    return;
  }
  const parent = parentOf(entry.destinationPath);
  if (!entry.fs.isDir(parent)) {
    entry.fs.ensureDir(parent);
  }
  entry.fs.writeTextFile(entry.destinationPath, entry.payloadText);
}

/**
 * Build the next destination manifest.
 *
 * @param result Pipeline result.
 * @param payloadVersion Extension version.
 * @returns The manifest to write.
 */
export function buildNextManifest(
  result: PushDownPipelineResult,
  payloadVersion: string,
): DestinationManifest {
  const previous = result.plan.previousManifest;
  const inRun = new Set<string>(result.plan.layers.map((layer) => layer.name));
  const files: Record<string, DestinationManifestFileEntry> = {};
  for (const [path, entry] of Object.entries(previous?.files ?? {})) {
    if (!inRun.has(entry.layer)) {
      files[path] = entry;
    }
  }
  for (const file of result.report.files) {
    const kept = previous?.files[file.path];
    if (file.action === "orphaned" && kept !== undefined) {
      files[file.path] = kept;
    }
  }
  for (const entry of result.plan.entries) {
    if (entry.kind !== "payload" || entry.classification === undefined) {
      continue;
    }
    const { action, recordHash } = entry.classification;
    const kept = previous?.files[entry.relativePath];
    if ((action === "conflict" || action === "deleted-locally") && kept) {
      files[entry.relativePath] = kept;
    } else if (recordHash !== undefined) {
      files[entry.relativePath] = {
        layer: entry.layer.name,
        pack: entry.layer.ownerPack(entry.relativePath),
        sha256: recordHash,
      };
    }
  }
  const selection: Record<string, DestinationManifestSelection> = {
    ...(previous?.selection ?? {}),
  };
  for (const layer of result.plan.layers) {
    if (layer.selection !== undefined) {
      selection[layer.name] = layer.selection;
    }
  }
  return {
    schemaVersion: DESTINATION_MANIFEST_SCHEMA_VERSION,
    payloadVersion,
    selection,
    files,
  };
}

/**
 * Execute a planned push-down run.
 *
 * @param result Pipeline result of a non-dry run.
 * @param options Payload version and artifact options.
 * @returns The apply-mode report, the summary with the artifact path, the
 *   exclusion report, and the warnings.
 */
export function applyPushDownPlan(
  result: PushDownPipelineResult,
  options: PushDownApplyOptions,
): PushDownApplyResult {
  const plan = result.plan;
  const base = new WriteIfChangedFileSystem(plan.fs);
  for (const entry of plan.entries) {
    applyEntry(entry, base);
  }
  const manifestText = renderDestinationManifest(
    buildNextManifest(result, options.payloadVersion),
  );
  base.writeTextFile(
    joinPosix(plan.destinationRoot, DESTINATION_MANIFEST_RELATIVE_PATH),
    manifestText,
  );
  const actions = new Map(
    result.report.files.map((file) => [file.path, file.action] as const),
  );
  const lastLayer = plan.layers[plan.layers.length - 1];
  const now = options.clock ?? (() => new Date());
  const provisional: PushDownSummary = {
    ...result.summary,
    finishedAt: now(),
    files: result.summary.files.map((file) => ({
      ...file,
      action: actions.get(file.relativePath) ?? "merge",
    })),
  };
  const artifactPath = writeSummaryArtifact(
    plan.fs,
    provisional,
    options.artifactRoot ?? result.summary.repoRoot,
    options.artifactDirectory ??
      lastLayer?.artifactDirectory ??
      "artifacts/push-down",
  );
  if (result.exclusions !== undefined) {
    appendExclusionsToArtifact(plan.fs, artifactPath, result.exclusions);
  }
  return {
    report: { ...result.report, mode: "apply" },
    summary: { ...provisional, artifactPath },
    ...(result.exclusions === undefined
      ? {}
      : { exclusions: result.exclusions }),
    warnings: result.warnings,
  };
}
