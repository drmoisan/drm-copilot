/**
 * Dry-run and apply report of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Build the `push_down_report` returned by every push-down call and render
 *     the conflict lines returned in `warnings`. Both functions are pure.
 *
 * Invariants / Constraints:
 *     - `files` is sorted by path in code-point order and holds destination-
 *       relative POSIX paths only.
 *     - `counts` has one key per action that occurs.
 *     - Conflict lines use {@link PUSH_DOWN_CONFLICT_LINE_PREFIX}, which is
 *       distinct from the exclusion-conflict prefix, so existing exclusion
 *       counting is unchanged.
 */

import { compareCodePoint } from "../string-ordering";
import { describeInvalidRelativePath } from "./push-down-destination-manifest";
import { type PushDownAction } from "./push-down-plan-comparator";

/** Prefix of every rendered push-down conflict line. */
export const PUSH_DOWN_CONFLICT_LINE_PREFIX = "push-down conflict:";

/** Actions rendered as conflict lines. */
const CONFLICT_ACTIONS: ReadonlySet<PushDownAction> = new Set<PushDownAction>([
  "conflict",
  "unmanaged-conflict",
  "deleted-locally",
]);

/** Report mode. */
export type PushDownReportMode = "dry-run" | "apply";

/** One reported path. */
export interface PushDownReportFile {
  readonly path: string;
  readonly layer: string;
  readonly pack: string;
  readonly action: PushDownAction;
  readonly reason: string;
}

/** Recorded selection of one ecosystem, in report (snake_case) form. */
export interface PushDownReportEcosystem {
  readonly packs: ReadonlyArray<string>;
  readonly csharp_variant?: string;
  readonly memory_mode?: string;
}

/** The `push_down_report` of one run. */
export interface PushDownReport {
  readonly mode: PushDownReportMode;
  readonly ecosystems: Readonly<Record<string, PushDownReportEcosystem>>;
  readonly files: ReadonlyArray<PushDownReportFile>;
  readonly counts: Readonly<Partial<Record<PushDownAction, number>>>;
}

/** Input of {@link buildPushDownReport}. */
export interface PushDownReportInput {
  readonly mode: PushDownReportMode;
  readonly ecosystems: Readonly<Record<string, PushDownReportEcosystem>>;
  readonly files: ReadonlyArray<PushDownReportFile>;
}

/**
 * Build a report with sorted files and per-action counts.
 *
 * @param input Mode, ecosystem selections, and reported files in any order.
 * @returns The report.
 * @throws Error When a path is not a destination-relative POSIX path or a
 *   path is reported twice.
 */
export function buildPushDownReport(
  input: PushDownReportInput,
): PushDownReport {
  const seen = new Set<string>();
  for (const file of input.files) {
    const invalid = describeInvalidRelativePath(file.path);
    if (invalid !== undefined) {
      throw new Error(`Invalid push-down report path: ${invalid}`);
    }
    if (seen.has(file.path)) {
      throw new Error(`Push-down report path reported twice: ${file.path}`);
    }
    seen.add(file.path);
  }
  const files = [...input.files].sort((left, right) =>
    compareCodePoint(left.path, right.path),
  );
  const counts: Partial<Record<PushDownAction, number>> = {};
  for (const file of files) {
    counts[file.action] = (counts[file.action] ?? 0) + 1;
  }
  return { mode: input.mode, ecosystems: input.ecosystems, files, counts };
}

/**
 * Render one warning line per conflict, unmanaged conflict, and local deletion.
 *
 * @param report Report to render.
 * @returns The lines in report (path) order; empty when none applies.
 */
export function renderPushDownConflictLines(report: PushDownReport): string[] {
  return report.files
    .filter((file) => CONFLICT_ACTIONS.has(file.action))
    .map(
      (file) =>
        `${PUSH_DOWN_CONFLICT_LINE_PREFIX} ${file.action} ${file.path} (layer ${file.layer}, pack ${file.pack}): ${file.reason}`,
    );
}
