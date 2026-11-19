/**
 * Integration-needed writer of the push-down (issue #1051, S1, S7, S10 to
 * S14).
 *
 * Purpose:
 *     After a push-down run, collect each decision the push-down cannot make
 *     mechanically: report entries with action `conflict`, `unmanaged-conflict`
 *     or `deleted-locally`, the #1050 workflow-name collisions, and the shared
 *     conflict core evaluated over the destination as it is after the run. An
 *     apply run writes `.push-down-integration-needed.json` through the
 *     write-if-changed decorator; both modes return the items.
 *
 * Invariants / Constraints:
 *     - A dry run never writes: its post-run view is a read-only overlay of the
 *       planned write set over the destination.
 *     - The file is never a manifest entry and never a payload path.
 *
 * Side effects:
 *     An apply run may write the integration-needed file.
 */

import { compareCodePoint } from "../string-ordering";
import { evaluateDestinationConflicts } from "../push-down-integration/integration-detect";
import {
  createIntegrationItem,
  HOOK_PATH_PREFIXES,
  INTEGRATION_NEEDED_RELATIVE_PATH,
  type IntegrationItem,
  type IntegrationItemKind,
  mergeIntegrationItems,
  renderIntegrationNeeded,
} from "../push-down-integration/integration-items";
import { type PushDownFileSystem, toPosixPath } from "./filesystem-adapter";
import { buildNextManifest } from "./push-down-apply";
import { findCiWorkflowNameCollisions } from "./push-down-ci-layer";
import { CI_DATA_FILE_RELATIVE_PATH } from "./push-down-ci-workflows";
import {
  DESTINATION_MANIFEST_RELATIVE_PATH,
  normalizeLineEndings,
  renderDestinationManifest,
} from "./push-down-destination-manifest";
import { joinPosix, type PushDownPipelineResult } from "./push-down-pipeline";
import { type PushDownReport } from "./push-down-report";
import { WriteIfChangedFileSystem } from "./push-down-write-if-changed";

/** The `push_down_report.integration_needed` value (S14). */
export interface IntegrationNeededResult {
  /** Destination-relative path of the file. */
  readonly path: string;
  readonly items: ReadonlyArray<IntegrationItem>;
  /** True only when this run wrote the file. */
  readonly written: boolean;
}

/** A push-down report that may carry `integration_needed`. */
export type PushDownReportWithIntegration = PushDownReport & {
  readonly integration_needed?: IntegrationNeededResult;
};

/** Kinds the push-down takes from the shared conflict core (S10). */
export const PUSH_DOWN_CONFLICT_CORE_KINDS: ReadonlyArray<IntegrationItemKind> =
  [
    "existing-ci-workflow",
    "missing-required-check",
    "version-matrix-difference",
    "workflow-name-collision",
  ];

/** Inputs of {@link recordIntegrationNeeded}. */
export interface IntegrationNeededInput {
  /** Pipeline result of the run. */
  readonly planned: PushDownPipelineResult;
  /** Report of the run (dry-run or apply). */
  readonly report: PushDownReport;
  /** True after an apply run; false for a dry run. */
  readonly apply: boolean;
  /** Raw destination adapter. */
  readonly fs: PushDownFileSystem;
  readonly destinationRoot: string;
  readonly extensionRoot: string;
  readonly payloadVersion: string;
}

/** Read-only overlay of planned writes over a destination adapter (S11). */
export class PostRunOverlayFileSystem implements PushDownFileSystem {
  /**
   * @param inner Destination adapter.
   * @param planned Absolute POSIX path to the text the run would write.
   */
  constructor(
    private readonly inner: PushDownFileSystem,
    private readonly planned: ReadonlyMap<string, string>,
  ) {}

  listFiles(root: string): string[] {
    const prefix = `${toPosixPath(root).replace(/\/+$/, "")}/`;
    const paths = new Set(this.inner.listFiles(root).map(toPosixPath));
    for (const path of this.planned.keys()) {
      if (path.startsWith(prefix)) {
        paths.add(path);
      }
    }
    return [...paths].sort(compareCodePoint);
  }

  isDir(path: string): boolean {
    const prefix = `${toPosixPath(path).replace(/\/+$/, "")}/`;
    return (
      this.inner.isDir(path) ||
      [...this.planned.keys()].some((planned) => planned.startsWith(prefix))
    );
  }

  isFile(path: string): boolean {
    return this.planned.has(toPosixPath(path)) || this.inner.isFile(path);
  }

  readTextFile(path: string): string {
    return this.planned.get(toPosixPath(path)) ?? this.inner.readTextFile(path);
  }

  writeTextFile(path: string): void {
    throw new Error(`The post-run overlay is read-only: ${path}`);
  }

  ensureDir(path: string): void {
    throw new Error(`The post-run overlay is read-only: ${path}`);
  }
}

/**
 * Return the texts an apply run of the plan would write: payload copies,
 * merged deliveries and the destination manifest.
 *
 * @param input Writer input.
 * @returns Absolute POSIX path to written text.
 */
export function plannedWriteSet(
  input: Pick<
    IntegrationNeededInput,
    "planned" | "fs" | "destinationRoot" | "payloadVersion"
  >,
): Map<string, string> {
  const writes = new Map<string, string>();
  for (const entry of input.planned.plan.entries) {
    const path = toPosixPath(entry.destinationPath);
    if (entry.kind === "delivery") {
      const current =
        writes.get(path) ??
        (input.fs.isFile(path) ? input.fs.readTextFile(path) : "");
      writes.set(path, normalizeLineEndings(entry.delivery.merge(current)));
    } else if (!entry.merged && entry.classification?.write === true) {
      writes.set(path, normalizeLineEndings(entry.payloadText));
    }
  }
  writes.set(
    joinPosix(input.destinationRoot, DESTINATION_MANIFEST_RELATIVE_PATH),
    renderDestinationManifest(
      buildNextManifest(input.planned, input.payloadVersion),
    ),
  );
  return writes;
}

/**
 * Turn report entries into items (S10).
 *
 * @param report Report of the run.
 * @returns One item per `conflict`, `unmanaged-conflict` or `deleted-locally`.
 */
export function collectReportItems(report: PushDownReport): IntegrationItem[] {
  return report.files.flatMap((file) => {
    switch (file.action) {
      case "conflict":
        return [
          createIntegrationItem(
            "destination-edited-file",
            file.path,
            "push-down",
            {
              is_hook: HOOK_PATH_PREFIXES.some((prefix) =>
                file.path.startsWith(prefix),
              ),
            },
          ),
        ];
      case "unmanaged-conflict":
      case "deleted-locally":
        return [createIntegrationItem(file.action, file.path, "push-down")];
      default:
        return [];
    }
  });
}

/**
 * Turn #1050 workflow-name collisions into items (S10). The collision check
 * applies only when the post-run view holds the CI data file.
 *
 * @param view Post-run view.
 * @param destinationRoot Destination root.
 * @returns One item per colliding workflow.
 */
function collectCollisionItems(
  view: PushDownFileSystem,
  destinationRoot: string,
): IntegrationItem[] {
  if (!view.isFile(joinPosix(destinationRoot, CI_DATA_FILE_RELATIVE_PATH))) {
    return [];
  }
  return findCiWorkflowNameCollisions(view, destinationRoot).flatMap((line) => {
    const match = /^push-down conflict: workflow-name (.+) \(layer /.exec(line);
    return match?.[1] === undefined
      ? []
      : [
          createIntegrationItem(
            "workflow-name-collision",
            match[1],
            "push-down",
            {
              existing_name: "CI",
            },
          ),
        ];
  });
}

/**
 * Collect the run's items and, in apply mode, write the file (S12, S14).
 *
 * @param input Pipeline result, report, mode, adapter, roots and version.
 * @returns The `integration_needed` value, or undefined when the run has no
 *   item and wrote no file.
 */
export function recordIntegrationNeeded(
  input: IntegrationNeededInput,
): IntegrationNeededResult | undefined {
  const view = input.apply
    ? input.fs
    : new PostRunOverlayFileSystem(input.fs, plannedWriteSet(input));
  const items = mergeIntegrationItems(
    collectReportItems(input.report),
    collectCollisionItems(view, input.destinationRoot),
    evaluateDestinationConflicts({
      fs: view,
      destinationRoot: input.destinationRoot,
      extensionRoot: input.extensionRoot,
      source: "push-down",
      kinds: PUSH_DOWN_CONFLICT_CORE_KINDS,
    }),
  );
  const target = joinPosix(
    input.destinationRoot,
    INTEGRATION_NEEDED_RELATIVE_PATH,
  );
  let written = false;
  if (input.apply && (items.length > 0 || input.fs.isFile(target))) {
    const writer = new WriteIfChangedFileSystem(input.fs);
    writer.writeTextFile(
      target,
      renderIntegrationNeeded(items, input.payloadVersion),
    );
    written = writer.writtenPaths.length > 0;
  }
  return items.length > 0 || written
    ? { path: INTEGRATION_NEEDED_RELATIVE_PATH, items, written }
    : undefined;
}

/**
 * Attach the integration-needed value to a report when it is present.
 *
 * @param report Report of the run.
 * @param result Value returned by {@link recordIntegrationNeeded}.
 * @returns The report, with `integration_needed` only when `result` exists.
 */
export function attachIntegrationNeeded(
  report: PushDownReport,
  result: IntegrationNeededResult | undefined,
): PushDownReportWithIntegration {
  return result === undefined
    ? report
    : { ...report, integration_needed: result };
}
