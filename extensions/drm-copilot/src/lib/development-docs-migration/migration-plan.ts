/**
 * Pure migration planner (issue #1016, spec "Refusal rules", "Exclusions (D-15
 * and mapping records)", "Untracked-file reporting", "Design Rule for
 * Unresolved Owner Questions", decisions A1 and A3).
 *
 * Inputs are repository-relative paths and an injected text reader, so the
 * planner touches no file system and no process.
 */
import { compileGlob } from "../file-system";
import {
  planFolderRenames,
  splitFolderPath,
  type HeldFolder,
  type KeptFolder,
} from "./folder-rename-plan";
import {
  DISCOVERY_TEMPLATES_ALTERNATIVE_TARGET,
  FOLDER_RENAME_AREAS,
  LEGACY_LAYOUT_MAP,
  mapLegacyPath,
  rowTarget,
} from "./layout-map";
import {
  computeSourceDigest,
  consumedChoiceValue,
  validateMigrationDecisions,
  type CommitSplit,
  type ConsumedChoice,
  type InTreeRewriteScope,
  type MigrationDecisions,
} from "./migration-decisions";
import {
  buildRewritePrefixes,
  recomputeRelativeLinks,
  rewritePrefixes,
  type FolderNameRename,
} from "./reference-rewrite";

/** Tool mode. */
export type MigrationMode = "dry-run" | "apply";

/** Planner inputs. */
export interface MigrationPlanInputs {
  readonly mode: MigrationMode;
  readonly insideWorkTree: boolean;
  readonly hasUncommittedTrackedChanges: boolean;
  /** Every tracked file of the repository. */
  readonly trackedFiles: ReadonlyArray<string>;
  /** Untracked and ignored files under the source trees. */
  readonly untrackedFiles: ReadonlyArray<string>;
  /** Text of a tracked file, or undefined when it cannot be read. */
  readonly readText: (path: string) => string | undefined;
  /** Parsed decision file, or null when none was supplied. */
  readonly decisions: MigrationDecisions | null;
  /** OQ-1 dry-run default, `developmentDocsPath(".dev", "discovery-templates")`. */
  readonly defaultDiscoveryTarget: string;
}

/** One `git mv`. */
export interface PlannedMove {
  readonly from: string;
  readonly to: string;
}

/** One file rewrite, at the file's post-move path. */
export interface PlannedRewrite {
  readonly path: string;
  readonly text: string;
}

/** A file that would change, with its occurrence counts. */
export interface RewriteCandidate {
  readonly path: string;
  readonly references: number;
  readonly links: number;
}

/** A per-file count of protected or backslash occurrences. */
export interface PathCount {
  readonly path: string;
  readonly count: number;
}

/** The migration plan and every report category. */
export interface MigrationPlan {
  readonly mode: MigrationMode;
  readonly discoveryTarget: string;
  readonly moves: ReadonlyArray<PlannedMove>;
  readonly renames: ReadonlyArray<PlannedMove>;
  readonly rewrites: ReadonlyArray<PlannedRewrite>;
  readonly held: ReadonlyArray<HeldFolder>;
  readonly kept: ReadonlyArray<KeptFolder>;
  readonly unmapped: ReadonlyArray<string>;
  readonly retained: ReadonlyArray<string>;
  readonly outsideRewrites: ReadonlyArray<RewriteCandidate>;
  readonly inTreeReferencesAndLinks: ReadonlyArray<RewriteCandidate>;
  readonly inTreeLinksOnly: ReadonlyArray<RewriteCandidate>;
  readonly excluded: ReadonlyArray<string>;
  readonly protectedOccurrences: ReadonlyArray<PathCount>;
  readonly backslashOccurrences: ReadonlyArray<PathCount>;
  readonly brokenLinks: ReadonlyArray<string>;
  readonly mappingRecordCandidates: ReadonlyArray<string>;
  readonly skipped: ReadonlyArray<string>;
  readonly untracked: ReadonlyArray<string>;
  readonly conflicts: ReadonlyArray<string>;
  readonly discoveryAlternative: {
    readonly target: string;
    readonly moves: ReadonlyArray<PlannedMove>;
  };
  readonly candidateFolders: ReadonlyArray<string>;
  readonly sourceDigest: string;
  readonly requiredChoices: ReadonlyArray<ConsumedChoice>;
  readonly openChoices: ReadonlyArray<ConsumedChoice>;
  readonly inTreeRewriteScope: InTreeRewriteScope | null;
  readonly commitSplit: CommitSplit | null;
  readonly createReadme: boolean;
  readonly readmeExisting: boolean;
}

/** Planner result: the plan and the refusals that stop the tool. */
export interface MigrationPlanResult {
  readonly plan: MigrationPlan;
  readonly refusals: ReadonlyArray<string>;
}

/** Tool reports and decision files, always excluded (built-in default). */
export const ALWAYS_EXCLUDED_GLOBS: ReadonlyArray<string> = [
  "**/dev-docs-migration-dry-run.*",
  "**/folder-rename-decisions.*.json",
];

/** Dry-run defaults used when no decision file is supplied (D-15). */
export const DRY_RUN_DEFAULT_EXCLUDED_GLOBS: ReadonlyArray<string> = [
  "tests/fixtures/**/*.json",
  "tests/fixtures/blast_radius/historical-runs/**",
];

/** The README created in apply mode when absent. */
export const DOCS_README_PATH = "docs/README.md";

/** Directory prefixes of a path, nearest last (`a/b/c.md` gives `a`, `a/b`). */
function parentDirectories(path: string): string[] {
  const segments = path.split("/");
  const result: string[] = [];
  for (let index = 1; index < segments.length; index += 1) {
    result.push(segments.slice(0, index).join("/"));
  }
  return result;
}

/** Simulated path existence, exact and case-insensitive. */
class PathIndex {
  private readonly exact = new Set<string>();
  private readonly lower = new Map<string, string>();

  add(path: string): void {
    for (const entry of [...parentDirectories(path), path]) {
      this.exact.add(entry);
      this.lower.set(entry.toLowerCase(), entry);
    }
  }

  has(path: string): boolean {
    return this.exact.has(path);
  }

  /** The existing spelling of a path that differs only in case, if any. */
  caseVariant(path: string): string | undefined {
    const found = this.lower.get(path.toLowerCase());
    return found !== undefined && found !== path ? found : undefined;
  }
}

/**
 * Plan the directory moves, merging into an existing target entry by entry.
 *
 * @returns The moves (tagged with the discovery flag) and the conflicts.
 */
function planMoves(
  files: ReadonlyArray<string>,
  discoveryTarget: string,
): { moves: Array<PlannedMove & { discovery: boolean }>; conflicts: string[] } {
  const index = new PathIndex();
  files.forEach((file) => {
    index.add(file);
  });
  const moves: Array<PlannedMove & { discovery: boolean }> = [];
  const conflicts: string[] = [];
  // The discovery row is planned last, so its OQ-1 alternative `.dev/templates`
  // is merged entry by entry into the templates moved by the table row.
  const rows = [
    ...LEGACY_LAYOUT_MAP.filter((row) => !row.discovery),
    ...LEGACY_LAYOUT_MAP.filter((row) => row.discovery),
  ];
  for (const row of rows) {
    const source = row.kind === "file" ? row.from : row.from.slice(0, -1);
    const members = files.filter(
      (file) => file === source || file.startsWith(`${source}/`),
    );
    if (members.length === 0) {
      continue;
    }
    const target =
      row.kind === "file"
        ? row.to
        : rowTarget(row, discoveryTarget).slice(0, -1);
    const variant = index.caseVariant(target);
    let pairs: PlannedMove[] = [{ from: source, to: target }];
    if (variant !== undefined) {
      conflicts.push(
        `move target collides case-insensitively with ${variant}: ${target}`,
      );
      continue;
    }
    if (index.has(target)) {
      const children = [
        ...new Set(
          members.map(
            (file) => file.slice(source.length + 1).split("/")[0] ?? "",
          ),
        ),
      ];
      pairs = children.map((child) => ({
        from: `${source}/${child}`,
        to: `${target}/${child}`,
      }));
    }
    for (const pair of pairs) {
      if (index.has(pair.to) || index.caseVariant(pair.to) !== undefined) {
        conflicts.push(`move target exists and is non-empty: ${pair.to}`);
        continue;
      }
      moves.push({ ...pair, discovery: row.discovery });
      members
        .filter(
          (file) => file === pair.from || file.startsWith(`${pair.from}/`),
        )
        .forEach((file) => {
          index.add(pair.to + file.slice(pair.from.length));
        });
    }
  }
  return { moves, conflicts };
}

/** Direct child folders of the three rename areas, under either root. */
function findCandidateFolders(files: ReadonlyArray<string>): string[] {
  const folders = new Set<string>();
  for (const file of files) {
    for (const area of FOLDER_RENAME_AREAS) {
      for (const root of [`docs/features/${area}/`, `.dev/${area}/`]) {
        if (file.startsWith(root)) {
          const rest = file.slice(root.length).split("/");
          if (rest.length > 1) {
            folders.add(root + (rest[0] ?? ""));
          }
        }
      }
    }
  }
  return [...folders].sort();
}

/** Final renames after decisions, with post-move paths and collision conflicts. */
function finalRenames(
  folders: ReadonlyArray<string>,
  mechanical: ReadonlyArray<{ source: string; to: string }>,
  decisions: MigrationDecisions | null,
): {
  renames: Array<{ source: string; area: string; from: string; to: string }>;
  conflicts: string[];
} {
  const targets = new Map<string, string>();
  mechanical.forEach((rename) => targets.set(rename.source, rename.to));
  for (const decision of decisions?.decisions ?? []) {
    if (decision.action === "rename") {
      targets.set(decision.source, decision.target);
    } else {
      targets.delete(decision.source);
    }
  }
  const remaining = folders
    .filter((folder) => !targets.has(folder))
    .map((folder) => splitFolderPath(folder).name.toLowerCase());
  const conflicts: string[] = [];
  const seen = new Set<string>(remaining);
  const renames: Array<{
    source: string;
    area: string;
    from: string;
    to: string;
  }> = [];
  for (const [source, to] of [...targets].sort()) {
    const { area, name } = splitFolderPath(source);
    if (seen.has(to.toLowerCase())) {
      conflicts.push(
        `rename target collides case-insensitively: ${to} (from ${source})`,
      );
      continue;
    }
    seen.add(to.toLowerCase());
    renames.push({ source, area, from: name, to });
  }
  return { renames, conflicts };
}

/** Mutable report accumulators for the rewrite scan. */
interface RewriteScan {
  outside: RewriteCandidate[];
  inTreeBoth: RewriteCandidate[];
  inTreeLinks: RewriteCandidate[];
  rewrites: PlannedRewrite[];
  excluded: string[];
  protectedOccurrences: PathCount[];
  backslash: PathCount[];
  broken: string[];
  mappingRecords: string[];
  skipped: string[];
}

/**
 * Build the migration plan and the refusals.
 *
 * @param inputs Tracked paths, git state, text reader and decisions.
 * @returns The plan with every report category, and the refusal reasons.
 */
export function buildMigrationPlan(
  inputs: MigrationPlanInputs,
): MigrationPlanResult {
  const { decisions, mode } = inputs;
  const tracked = [...inputs.trackedFiles].sort();
  const discoveryTarget = (
    decisions?.discoveryTemplatesTarget ?? inputs.defaultDiscoveryTarget
  ).replace(/\/+$/, "");
  const unmapped = new Set<string>();
  const retained: string[] = [];
  for (const path of tracked) {
    const kind = mapLegacyPath(path, discoveryTarget).kind;
    if (kind === "unmapped") {
      unmapped.add(path.split("/").slice(0, 3).join("/"));
    } else if (kind === "retained") {
      retained.push(path);
    }
  }
  const movePlan = planMoves(
    [...tracked, ...inputs.untrackedFiles],
    discoveryTarget,
  );
  const alternative = planMoves(
    [...tracked, ...inputs.untrackedFiles],
    DISCOVERY_TEMPLATES_ALTERNATIVE_TARGET,
  );
  const candidateFolders = findCandidateFolders(tracked);
  const folderPlan = planFolderRenames(candidateFolders);
  const renamePlan = finalRenames(
    candidateFolders,
    folderPlan.renames,
    decisions,
  );
  const renameList: FolderNameRename[] = renamePlan.renames.map(
    ({ area, from, to }) => ({ area, from, to }),
  );
  const renameIndex = new Map(
    renameList.map((rename) => [
      `.dev/${rename.area}/${rename.from}`,
      `.dev/${rename.area}/${rename.to}`,
    ]),
  );
  const mapPath = (path: string): string => {
    const mapped = mapLegacyPath(path, discoveryTarget);
    const moved = mapped.kind === "mapped" ? mapped.target : path;
    const folder = moved.split("/").slice(0, 3).join("/");
    const renamed = renameIndex.get(folder);
    return renamed === undefined ? moved : renamed + moved.slice(folder.length);
  };
  const scope = decisions?.inTreeRewriteScope ?? null;
  const scan = scanRewrites(
    inputs,
    tracked,
    discoveryTarget,
    renameList,
    mapPath,
    scope,
  );

  const hasMoves = movePlan.moves.length + renamePlan.renames.length > 0;
  const appliedInTree =
    scope === null
      ? scan.inTreeBoth.length
      : scope === "links-only"
        ? scan.inTreeLinks.length
        : scope === "none"
          ? 0
          : scan.inTreeBoth.length;
  const required: ConsumedChoice[] = [];
  if (tracked.some((path) => path.startsWith("docs/discovery/"))) {
    required.push("discovery_templates_target");
  }
  if (scan.inTreeBoth.length > 0) {
    required.push("in_tree_rewrite_scope");
  }
  if (hasMoves && scan.outside.length + appliedInTree > 0) {
    required.push("commit_split");
  }
  const openChoices = required.filter(
    (choice) =>
      decisions === null || consumedChoiceValue(decisions, choice) === null,
  );
  const sourceDigest = computeSourceDigest(candidateFolders);
  const conflicts = [...movePlan.conflicts, ...renamePlan.conflicts];

  const refusals: string[] = [];
  if (!inputs.insideWorkTree) {
    refusals.push("workspace_root is not inside a git work tree");
  }
  if (mode === "apply") {
    if (inputs.hasUncommittedTrackedChanges) {
      refusals.push("tracked files have uncommitted changes");
    }
    refusals.push(...conflicts);
    for (const entry of unmapped) {
      refusals.push(`unmapped entry under docs/features/: ${entry}`);
    }
    if (
      decisions === null &&
      (folderPlan.held.length > 0 || openChoices.length > 0)
    ) {
      refusals.push(
        `a decision file is required: ${String(folderPlan.held.length)} held items, open choices: ${openChoices.join(", ") || "none"}`,
      );
    }
    if (decisions !== null) {
      refusals.push(
        ...validateMigrationDecisions(decisions, {
          reportedFolders: candidateFolders,
          heldSources: folderPlan.held.map((item) => item.source),
          sourceDigest,
          requiredChoices: required,
        }),
      );
    }
  }

  const plan: MigrationPlan = {
    mode,
    discoveryTarget,
    moves: movePlan.moves.map(({ from, to }) => ({ from, to })),
    renames: renamePlan.renames.map((rename) => ({
      from: `.dev/${rename.area}/${rename.from}`,
      to: `.dev/${rename.area}/${rename.to}`,
    })),
    rewrites: mode === "apply" ? scan.rewrites : [],
    held: folderPlan.held,
    kept: folderPlan.kept,
    unmapped: [...unmapped],
    retained,
    outsideRewrites: scan.outside,
    inTreeReferencesAndLinks: scan.inTreeBoth,
    inTreeLinksOnly: scan.inTreeLinks,
    excluded: scan.excluded,
    protectedOccurrences: scan.protectedOccurrences,
    backslashOccurrences: scan.backslash,
    brokenLinks: scan.broken,
    mappingRecordCandidates: scan.mappingRecords,
    skipped: scan.skipped,
    untracked: [...inputs.untrackedFiles].sort(),
    conflicts,
    discoveryAlternative: {
      target: DISCOVERY_TEMPLATES_ALTERNATIVE_TARGET,
      moves: alternative.moves
        .filter((move) => move.discovery)
        .map(({ from, to }) => ({ from, to })),
    },
    candidateFolders,
    sourceDigest,
    requiredChoices: required,
    openChoices,
    inTreeRewriteScope: scope,
    commitSplit: decisions?.commitSplit ?? null,
    createReadme: !tracked.includes(DOCS_README_PATH),
    readmeExisting: tracked.includes(DOCS_README_PATH),
  };
  return { plan, refusals };
}

/**
 * Scan every tracked text file for rewrite candidates and, in apply mode, the
 * rewritten text under the chosen in-tree scope.
 */
function scanRewrites(
  inputs: MigrationPlanInputs,
  tracked: ReadonlyArray<string>,
  discoveryTarget: string,
  renames: ReadonlyArray<FolderNameRename>,
  mapPath: (path: string) => string,
  scope: InTreeRewriteScope | null,
): RewriteScan {
  const scan: RewriteScan = {
    outside: [],
    inTreeBoth: [],
    inTreeLinks: [],
    rewrites: [],
    excluded: [],
    protectedOccurrences: [],
    backslash: [],
    broken: [],
    mappingRecords: [],
    skipped: [],
  };
  const globs = [...ALWAYS_EXCLUDED_GLOBS];
  if (inputs.mode === "dry-run" && inputs.decisions === null) {
    globs.push(...DRY_RUN_DEFAULT_EXCLUDED_GLOBS);
  }
  globs.push(...(inputs.decisions?.rewriteExclusions ?? []));
  const matchers = globs.map((glob) => compileGlob(glob));
  const known = new Set<string>();
  tracked.forEach((path) => {
    [...parentDirectories(path), path].forEach((entry) => known.add(entry));
  });
  const prefixes = buildRewritePrefixes(discoveryTarget);
  const recordPairs = LEGACY_LAYOUT_MAP.map(
    (row) => [row.from, rowTarget(row, discoveryTarget)] as const,
  );
  for (const path of tracked) {
    // Decision A1: retained production documentation is never rewritten.
    if (mapLegacyPath(path, discoveryTarget).kind === "retained") {
      continue;
    }
    if (matchers.some((matcher) => matcher.test(path))) {
      scan.excluded.push(path);
      continue;
    }
    const text = inputs.readText(path);
    if (text === undefined || text.includes("\0") || text.includes("�")) {
      scan.skipped.push(path);
      continue;
    }
    const sourceNew = mapPath(path);
    const links = path.endsWith(".md")
      ? recomputeRelativeLinks(text, {
          sourceOld: path,
          sourceNew,
          mapPath,
          exists: (entry) => known.has(entry),
        })
      : { text, recomputed: 0, broken: [] };
    const both = rewritePrefixes(links.text, prefixes, renames);
    scan.broken.push(...links.broken);
    if (both.protectedOccurrences > 0) {
      scan.protectedOccurrences.push({
        path,
        count: both.protectedOccurrences,
      });
    }
    if (both.backslashOccurrences > 0) {
      scan.backslash.push({ path, count: both.backslashOccurrences });
    }
    if (
      recordPairs.some(([from, to]) => text.includes(from) && text.includes(to))
    ) {
      scan.mappingRecords.push(path);
    }
    const candidate = {
      path,
      references: both.occurrences + both.renamedBasenames,
      links: links.recomputed,
    };
    if (candidate.references + candidate.links === 0) {
      continue;
    }
    if (sourceNew === path) {
      scan.outside.push(candidate);
      scan.rewrites.push({ path: sourceNew, text: both.text });
      continue;
    }
    scan.inTreeBoth.push(candidate);
    if (candidate.links > 0) {
      scan.inTreeLinks.push(candidate);
    }
    if (scope === "references-and-links") {
      scan.rewrites.push({ path: sourceNew, text: both.text });
    } else if (scope === "links-only" && candidate.links > 0) {
      scan.rewrites.push({ path: sourceNew, text: links.text });
    }
  }
  return scan;
}
