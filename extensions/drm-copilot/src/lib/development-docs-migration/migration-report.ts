/**
 * Dry-run report rendering (issue #1016, spec "Dry-run report contents").
 *
 * The report holds repository-relative paths only; the workspace root is never
 * part of the plan, so it cannot reach the output.
 */
import { buildDecisionSkeleton } from "./migration-decisions";
import type { MigrationPlan, RewriteCandidate } from "./migration-plan";

/** Report context beyond the plan. */
export interface MigrationReportContext {
  /** File name of the JSON report, or null when no file is written. */
  readonly reportName: string | null;
  /** Current `development_docs_root`, reported only. */
  readonly resolvedRoot: string;
  readonly refusals: ReadonlyArray<string>;
}

/** The JSON report object. */
export type MigrationReport = Readonly<Record<string, unknown>> & {
  readonly summary: Readonly<Record<string, number | string>>;
};

/** Report categories, in rendering order, with their Markdown headings. */
export const REPORT_CATEGORIES: ReadonlyArray<readonly [string, string]> = [
  ["moves", "Planned directory moves"],
  ["renames", "Mechanical and decided folder renames"],
  [
    "held_items",
    "Held items (non-matching, multi-folder issue numbers, formatter errors, collisions)",
  ],
  ["kept_folders", "Folders kept without a recoverable issue number"],
  ["unmapped_entries", "Unmapped entries under docs/features/"],
  ["retained_documentation", "Retained production documentation under docs/"],
  ["rewrites_outside_moved_trees", "Files to rewrite outside the moved trees"],
  [
    "rewrites_in_tree_references_and_links",
    "In-tree rewrites: references-and-links",
  ],
  ["rewrites_in_tree_links_only", "In-tree rewrites: links-only"],
  ["rewrites_in_tree_none", "In-tree rewrites: none"],
  ["excluded_files", "Excluded files"],
  [
    "protected_occurrences",
    "Protected occurrences (Write( and Edit( literals)",
  ],
  ["mapping_record_candidates", "Mapping-record candidates"],
  ["broken_links", "Broken relative links"],
  ["backslash_occurrences", "Backslash-separated occurrences"],
  ["untracked_files", "Untracked and ignored files"],
  ["skipped_files", "Skipped files (NUL byte or invalid UTF-8)"],
  ["conflicts", "Move and rename conflicts"],
  ["discovery_alternative", "OQ-1 alternative target, entry by entry"],
  ["commit_split_orderings", "OQ-12 orderings"],
  ["refusals", "Refusals"],
];

function occurrences(items: ReadonlyArray<RewriteCandidate>): number {
  return items.reduce((total, item) => total + item.references + item.links, 0);
}

/**
 * Build the report object from a plan.
 *
 * @param plan The migration plan.
 * @param context Report name, resolved root and refusals.
 * @returns The JSON-ready report.
 */
export function buildMigrationReport(
  plan: MigrationPlan,
  context: MigrationReportContext,
): MigrationReport {
  const rewrites =
    plan.outsideRewrites.length + plan.inTreeReferencesAndLinks.length;
  const summary: Record<string, number | string> = {
    moves: plan.moves.length,
    renames: plan.renames.length,
    held_items: plan.held.length,
    formatter_errors: plan.held.filter(
      (item) => item.reason === "formatter-error",
    ).length,
    collisions:
      plan.held.filter((item) => item.reason === "collision").length +
      plan.conflicts.length,
    files_to_rewrite: rewrites,
    rewrite_occurrences:
      occurrences(plan.outsideRewrites) +
      occurrences(plan.inTreeReferencesAndLinks),
    excluded_files: plan.excluded.length,
    protected_occurrences: plan.protectedOccurrences.reduce(
      (total, item) => total + item.count,
      0,
    ),
    broken_links: plan.brokenLinks.length,
    untracked_files: plan.untracked.length,
    retained_documentation: plan.retained.length,
    kept_folders: plan.kept.length,
    open_choices: plan.openChoices.length,
    source_digest: plan.sourceDigest,
  };
  const movesStep = `apply call: ${String(plan.moves.length)} moves and ${String(plan.renames.length)} renames`;
  const rewriteStep = `apply call: ${String(rewrites)} file rewrites and docs/README.md`;
  return {
    mode: plan.mode,
    resolved_root: context.resolvedRoot,
    discovery_target: plan.discoveryTarget,
    source_digest: plan.sourceDigest,
    summary,
    moves: plan.moves,
    renames: plan.renames,
    held_items: plan.held.map((item) => ({
      source: item.source,
      reason: item.reason,
      candidate: item.candidate,
      detail: item.detail ?? null,
    })),
    kept_folders: plan.kept,
    unmapped_entries: plan.unmapped,
    retained_documentation: plan.retained,
    rewrites_outside_moved_trees: plan.outsideRewrites,
    rewrites_in_tree_references_and_links: plan.inTreeReferencesAndLinks,
    rewrites_in_tree_links_only: plan.inTreeLinksOnly,
    rewrites_in_tree_none: [],
    excluded_files: plan.excluded,
    protected_occurrences: plan.protectedOccurrences,
    mapping_record_candidates: plan.mappingRecordCandidates,
    broken_links: plan.brokenLinks,
    backslash_occurrences: plan.backslashOccurrences,
    untracked_files: plan.untracked,
    skipped_files: plan.skipped,
    conflicts: plan.conflicts,
    discovery_alternative: plan.discoveryAlternative,
    commit_split_orderings: {
      single: [
        `${movesStep}, plus ${rewriteStep.slice("apply call: ".length)}; one commit`,
      ],
      "moves-then-rewrites": [movesStep, "commit", rewriteStep, "commit"],
    },
    required_choices: plan.requiredChoices,
    open_choices: plan.openChoices,
    docs_readme: plan.readmeExisting
      ? "exists (left unchanged)"
      : "created in apply mode",
    refusals: context.refusals,
    decision_skeleton: buildDecisionSkeleton({
      dryRunReport: context.reportName,
      sourceDigest: plan.sourceDigest,
      heldSources: plan.held.map((item) => item.source),
    }),
  };
}

/**
 * Render the JSON report.
 *
 * @param report The report object.
 * @returns Pretty-printed JSON with a trailing newline.
 */
export function renderMigrationReportJson(report: MigrationReport): string {
  return `${JSON.stringify(report, null, 2)}\n`;
}

/** Render one category value as Markdown bullet lines. */
function renderValue(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value.length === 0
      ? ["- none"]
      : value.map(
          (item) =>
            `- ${typeof item === "string" ? `\`${item}\`` : JSON.stringify(item)}`,
        );
  }
  return [`- ${JSON.stringify(value)}`];
}

/**
 * Render the Markdown summary and every category.
 *
 * @param report The report object.
 * @returns Markdown text.
 */
export function renderMigrationReportMarkdown(report: MigrationReport): string {
  const lines = ["# Development Docs Migration Dry Run", "", "## Summary", ""];
  for (const [key, value] of Object.entries(report.summary)) {
    lines.push(`- ${key}: ${String(value)}`);
  }
  lines.push(
    "",
    `- mode: ${String(report["mode"])}`,
    `- resolved_root: ${String(report["resolved_root"])}`,
  );
  lines.push(
    `- discovery_target: ${String(report["discovery_target"])}`,
    `- docs/README.md: ${String(report["docs_readme"])}`,
  );
  for (const [key, heading] of REPORT_CATEGORIES) {
    const value = report[key];
    const count = Array.isArray(value) ? ` (${String(value.length)})` : "";
    lines.push("", `## ${heading}${count}`, "", ...renderValue(value));
  }
  lines.push(
    "",
    "## Decision skeleton",
    "",
    "```json",
    JSON.stringify(report["decision_skeleton"], null, 2),
    "```",
    "",
  );
  return lines.join("\n");
}

/**
 * Report file stem from an injected clock, `dev-docs-migration-dry-run.<yyyy-MM-ddTHH-mm>` in UTC.
 *
 * @param now Clock reading.
 * @returns The file stem without extension.
 */
export function migrationReportFileName(now: Date): string {
  const stamp = now.toISOString().slice(0, 16).replace(":", "-");
  return `dev-docs-migration-dry-run.${stamp}`;
}
