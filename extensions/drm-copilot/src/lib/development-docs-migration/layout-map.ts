/**
 * Legacy-to-`.dev` layout map (issue #1016, spec "Mapping table (research section 5)").
 *
 * Paths are repository-relative with forward slashes. The table is applied
 * longest prefix first. `docs/discovery/` holds only `templates/`, so its row
 * maps the `templates/` contents to the OQ-1 target directory supplied by the
 * caller (`global_decisions.discovery_templates_target`).
 */

/** Whether a row maps a directory prefix or one file. */
export type LayoutRowKind = "directory" | "file";

/** One row of the mapping table. */
export interface LayoutMapRow {
  /** Old prefix (directories end with `/`). */
  readonly from: string;
  /** New prefix; empty for the discovery row, whose target is an input. */
  readonly to: string;
  readonly kind: LayoutRowKind;
  /** True for `active`, `completed` and `archive`, whose folders are renamed. */
  readonly renamesFolders: boolean;
  /** True for the discovery-templates row (OQ-1). */
  readonly discovery: boolean;
}

/** Areas whose direct child folders are renamed to `<NNNN>-<feature>`. */
export const FOLDER_RENAME_AREAS: ReadonlyArray<string> = [
  "active",
  "completed",
  "archive",
];

/** Source of the discovery templates (OQ-1). */
export const DISCOVERY_TEMPLATES_SOURCE = "docs/discovery/templates/";

/** The OQ-1 alternative target that the dry run also plans entry by entry. */
export const DISCOVERY_TEMPLATES_ALTERNATIVE_TARGET = ".dev/templates";

/** Generic prefix rewrite applied after the table rows (spec "Prefix rewrite"). */
export const GENERIC_FEATURES_PREFIX = {
  from: "docs/features/",
  to: ".dev/",
} as const;

const RAW_ROWS: ReadonlyArray<LayoutMapRow> = [
  directory("docs/features/potential/", ".dev/potential/"),
  directory("docs/features/active/", ".dev/active/", true),
  directory("docs/features/completed/", ".dev/completed/", true),
  directory("docs/features/archive/", ".dev/archive/", true),
  directory("docs/features/epics/", ".dev/epics/"),
  directory("docs/features/parallel/", ".dev/parallel/"),
  directory("docs/features/templates/", ".dev/templates/"),
  directory("docs/features/research/", ".dev/research/"),
  {
    from: "docs/features/backlog.md",
    to: ".dev/backlog.md",
    kind: "file",
    renamesFolders: false,
    discovery: false,
  },
  directory("docs/research/", ".dev/research/"),
  directory("docs/engineering/", ".dev/engineering/"),
  {
    from: DISCOVERY_TEMPLATES_SOURCE,
    to: "",
    kind: "directory",
    renamesFolders: false,
    discovery: true,
  },
];

/** The mapping table, longest prefix first (ties in alphabetical order). */
export const LEGACY_LAYOUT_MAP: ReadonlyArray<LayoutMapRow> = [
  ...RAW_ROWS,
].sort(
  (left, right) =>
    right.from.length - left.from.length || left.from.localeCompare(right.from),
);

/**
 * Build a directory row.
 *
 * @param from Old directory prefix ending with `/`.
 * @param to New directory prefix ending with `/`.
 * @param renamesFolders Whether the row's direct child folders are renamed.
 * @returns The row.
 */
function directory(
  from: string,
  to: string,
  renamesFolders = false,
): LayoutMapRow {
  return { from, to, kind: "directory", renamesFolders, discovery: false };
}

/** Classification of a repository path (decision A1). */
export type LegacyPathClass =
  | {
      readonly kind: "mapped";
      readonly target: string;
      readonly row: LayoutMapRow;
    }
  | { readonly kind: "unmapped" }
  | { readonly kind: "retained" }
  | { readonly kind: "outside" };

/**
 * Return the new prefix of a row, substituting the OQ-1 target for the discovery row.
 *
 * @param row A mapping-table row.
 * @param discoveryTarget Repository-relative OQ-1 target directory.
 * @returns The new prefix (directories end with `/`).
 */
export function rowTarget(row: LayoutMapRow, discoveryTarget: string): string {
  return row.discovery ? `${discoveryTarget.replace(/\/+$/, "")}/` : row.to;
}

/**
 * Classify a path and, when mapped, compute its new path.
 *
 * @param path Repository-relative forward-slash path of a file or directory.
 * @param discoveryTarget Repository-relative OQ-1 target directory.
 * @returns `mapped` with the target; `unmapped` under `docs/features/` with no
 *     row; `retained` for any other path under `docs/`; `outside` otherwise.
 */
export function mapLegacyPath(
  path: string,
  discoveryTarget: string,
): LegacyPathClass {
  for (const row of LEGACY_LAYOUT_MAP) {
    const target = rowTarget(row, discoveryTarget);
    if (row.kind === "file") {
      if (path === row.from) {
        return { kind: "mapped", target, row };
      }
      continue;
    }
    if (path.startsWith(row.from)) {
      return {
        kind: "mapped",
        target: target + path.slice(row.from.length),
        row,
      };
    }
    if (path === row.from.slice(0, -1)) {
      return { kind: "mapped", target: target.slice(0, -1), row };
    }
  }
  if (path.startsWith("docs/features/")) {
    return { kind: "unmapped" };
  }
  if (path.startsWith("docs/")) {
    return { kind: "retained" };
  }
  return { kind: "outside" };
}
