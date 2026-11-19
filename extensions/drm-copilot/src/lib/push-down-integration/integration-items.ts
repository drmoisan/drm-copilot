/**
 * Integration-needed item model (issue #1051, rules S2 to S9).
 *
 * Purpose:
 *     Define the `.push-down-integration-needed.json` file: its path, schema
 *     version, the item kind vocabulary with each kind's `detail` keys and
 *     ordered `resolution_options`, the item id format, the merge rule (one
 *     item per id, code-point order) and the rendering rule. The writer, the
 *     detect tool and the skill contract test share these constants.
 *
 * Invariants / Constraints:
 *     Pure: no I/O and no module-level mutable state. Every item path is a
 *     destination-relative POSIX path, so a rendered file never holds an
 *     absolute path or any part of the destination root.
 */

import { compareCodePoint } from "../string-ordering";
import { stringifySorted } from "../push-down/copilot-customizations-engine";
import { describeInvalidRelativePath } from "../push-down/push-down-destination-manifest";

/** Destination-relative path of the integration-needed file (S1). */
export const INTEGRATION_NEEDED_RELATIVE_PATH =
  ".push-down-integration-needed.json";

/** `schema_version` of the integration-needed file (S2). */
export const INTEGRATION_NEEDED_SCHEMA_VERSION = "1.0.0";

/** Item kinds, in the order of the S4 table. */
export const INTEGRATION_ITEM_KINDS = [
  "workflow-name-collision",
  "existing-ci-workflow",
  "job-name-overlap",
  "missing-required-check",
  "version-matrix-difference",
  "destination-edited-file",
  "unmanaged-conflict",
  "deleted-locally",
  "yaml-unsupported",
] as const;

/** One item kind. */
export type IntegrationItemKind = (typeof INTEGRATION_ITEM_KINDS)[number];

/** Ordered resolution options per kind (S4). */
export const RESOLUTION_OPTIONS_BY_KIND: Readonly<
  Record<IntegrationItemKind, ReadonlyArray<string>>
> = {
  "workflow-name-collision": [
    "rename-existing-workflow",
    "retire-existing-workflow",
  ],
  "existing-ci-workflow": ["keep-both-workflows", "retire-existing-workflow"],
  "job-name-overlap": ["rename-existing-job", "keep-overlapping-job"],
  "missing-required-check": ["add-producing-job", "restore-pushed-caller"],
  "version-matrix-difference": [
    "align-to-harness-version",
    "keep-destination-version",
  ],
  "destination-edited-file": ["revert-to-payload", "declare-destination-owned"],
  "unmanaged-conflict": ["adopt-payload", "declare-destination-owned"],
  "deleted-locally": ["restore-from-payload", "declare-destination-owned"],
  "yaml-unsupported": ["rewrite-in-supported-subset"],
};

/** `detail` keys per kind, sorted (S4). */
export const DETAIL_KEYS_BY_KIND: Readonly<
  Record<IntegrationItemKind, ReadonlyArray<string>>
> = {
  "workflow-name-collision": ["existing_name"],
  "existing-ci-workflow": [],
  "job-name-overlap": ["job_id", "matched"],
  "missing-required-check": ["context", "workflow_file"],
  "version-matrix-difference": ["expected", "found", "job_id", "key"],
  "destination-edited-file": ["is_hook"],
  "unmanaged-conflict": [],
  "deleted-locally": [],
  "yaml-unsupported": ["construct", "line"],
};

/** Producer of an item (S3). */
export type IntegrationItemSource = "push-down" | "detect";

/** One `detail` value. */
export type IntegrationDetailValue =
  string | number | boolean | ReadonlyArray<string>;

/** One integration item (S3). */
export interface IntegrationItem {
  readonly detail: Readonly<Record<string, IntegrationDetailValue>>;
  readonly id: string;
  readonly kind: IntegrationItemKind;
  readonly path: string;
  readonly resolution_options: ReadonlyArray<string>;
  readonly source: IntegrationItemSource;
}

/** Hook roots whose edited files carry `detail.is_hook: true` (S10). */
export const HOOK_PATH_PREFIXES: ReadonlyArray<string> = [
  ".claude/hooks/",
  ".codex/hooks/",
  ".github/hooks/",
];

/**
 * Format an item id (S5).
 *
 * @param kind Item kind.
 * @param path Destination-relative path.
 * @param discriminator Discriminator, for kinds that can repeat per path.
 * @returns `<kind>:<path>` with an optional `#<discriminator>`.
 */
export function formatIntegrationItemId(
  kind: IntegrationItemKind,
  path: string,
  discriminator?: string,
): string {
  const base = `${kind}:${path}`;
  return discriminator === undefined ? base : `${base}#${discriminator}`;
}

/**
 * Return the S5 discriminator of an item from its kind and detail.
 *
 * @param kind Item kind.
 * @param detail Item detail.
 * @returns The discriminator, or undefined for kinds without one.
 */
function discriminatorOf(
  kind: IntegrationItemKind,
  detail: Readonly<Record<string, IntegrationDetailValue>>,
): string | undefined {
  const text = (key: string): string => String(detail[key]);
  switch (kind) {
    case "job-name-overlap":
      return text("job_id");
    case "missing-required-check":
      return text("context");
    case "version-matrix-difference":
      return `${text("job_id")}.${text("key")}`;
    case "yaml-unsupported":
      return `L${text("line")}`;
    default:
      return undefined;
  }
}

/**
 * Build one item with the kind's options and id.
 *
 * @param kind Item kind.
 * @param path Destination-relative POSIX path.
 * @param source Producer of the item.
 * @param detail Detail values; the keys must equal the kind's detail keys.
 * @returns The item.
 * @throws Error When the path is not destination-relative or the detail keys
 *   differ from {@link DETAIL_KEYS_BY_KIND}.
 */
export function createIntegrationItem(
  kind: IntegrationItemKind,
  path: string,
  source: IntegrationItemSource,
  detail: Readonly<Record<string, IntegrationDetailValue>> = {},
): IntegrationItem {
  const invalid = describeInvalidRelativePath(path);
  if (invalid !== undefined) {
    throw new Error(`Invalid integration item path: ${invalid}`);
  }
  const keys = Object.keys(detail).sort(compareCodePoint).join(",");
  if (keys !== DETAIL_KEYS_BY_KIND[kind].join(",")) {
    throw new Error(
      `Integration item ${kind} detail keys must be [${DETAIL_KEYS_BY_KIND[kind].join(", ")}]; received [${keys}].`,
    );
  }
  return {
    detail,
    id: formatIntegrationItemId(kind, path, discriminatorOf(kind, detail)),
    kind,
    path,
    resolution_options: RESOLUTION_OPTIONS_BY_KIND[kind],
    source,
  };
}

/**
 * Merge item lists: one item per id, sorted by id in code-point order (S6).
 *
 * @param lists Item lists in priority order; the first item of an id is kept.
 * @returns The merged items.
 */
export function mergeIntegrationItems(
  ...lists: ReadonlyArray<ReadonlyArray<IntegrationItem>>
): IntegrationItem[] {
  const byId = new Map<string, IntegrationItem>();
  for (const item of lists.flat()) {
    if (!byId.has(item.id)) {
      byId.set(item.id, item);
    }
  }
  return [...byId.values()].sort((left, right) =>
    compareCodePoint(left.id, right.id),
  );
}

/**
 * Render the integration-needed file (S2, S8).
 *
 * @param items Merged items.
 * @param payloadVersion The run's `payload_version`.
 * @returns Sorted-key, two-space JSON with LF endings and one trailing LF.
 */
export function renderIntegrationNeeded(
  items: ReadonlyArray<IntegrationItem>,
  payloadVersion: string,
): string {
  return `${stringifySorted(
    {
      items,
      payload_version: payloadVersion,
      schema_version: INTEGRATION_NEEDED_SCHEMA_VERSION,
    },
    2,
  )}\n`;
}
