import { describe, expect, it } from "@jest/globals";

import { buildMigrationPlan } from "../../../src/lib/development-docs-migration/migration-plan";
import {
  buildMigrationReport,
  migrationReportFileName,
  renderMigrationReportJson,
  renderMigrationReportMarkdown,
  REPORT_CATEGORIES,
} from "../../../src/lib/development-docs-migration/migration-report";

const FILES: Record<string, string> = {
  "docs/features/active/2026-10-30-foo-1016/spec.md": "x",
  "docs/features/archive/subagentstop-envelope-core-897/a.md": "held",
  "docs/features/archive/notes-feature/a.md": "kept",
  "docs/README.md": "production",
  "notes/map.md": "docs/features/active/ became .dev/active/",
  "README.md":
    "Write(docs/features/**) docs\\features\\x [b](docs/features/missing.md)",
};

function report() {
  const { plan, refusals } = buildMigrationPlan({
    mode: "dry-run",
    insideWorkTree: true,
    hasUncommittedTrackedChanges: false,
    trackedFiles: Object.keys(FILES),
    untrackedFiles: ["docs/features/active/2026-10-30-foo-1016/scratch.log"],
    readText: (path) => FILES[path],
    decisions: null,
    defaultDiscoveryTarget: ".dev/discovery/templates",
  });
  return buildMigrationReport(plan, {
    reportName: "dev-docs-migration-dry-run.2026-11-20T07-15.json",
    resolvedRoot: "docs/features",
    refusals,
  });
}

describe("migration report", () => {
  it("contains every report category in both formats", () => {
    // Act
    const built = report();
    const json = JSON.parse(renderMigrationReportJson(built)) as Record<
      string,
      unknown
    >;
    const markdown = renderMigrationReportMarkdown(built);

    // Assert
    for (const [key, heading] of REPORT_CATEGORIES) {
      expect(json).toHaveProperty(key);
      expect(markdown).toContain(`## ${heading}`);
    }
    expect(REPORT_CATEGORIES.map(([key]) => key)).toEqual(
      expect.arrayContaining([
        "retained_documentation",
        "kept_folders",
        "mapping_record_candidates",
        "untracked_files",
      ]),
    );
  });

  it("renders the kept folder, retained documentation, untracked files and mapping records in both formats", () => {
    // Act
    const built = report();
    const json = JSON.parse(renderMigrationReportJson(built)) as Record<
      string,
      unknown
    >;
    const markdown = renderMigrationReportMarkdown(built);

    // Assert
    expect(json["kept_folders"]).toEqual([
      { source: "docs/features/archive/notes-feature", format: "other" },
    ]);
    expect(markdown).toContain("docs/features/archive/notes-feature");
    expect(json["retained_documentation"]).toEqual(["docs/README.md"]);
    expect(markdown).toContain("`docs/README.md`");
    expect(json["untracked_files"]).toEqual([
      "docs/features/active/2026-10-30-foo-1016/scratch.log",
    ]);
    expect(json["mapping_record_candidates"]).toEqual(["notes/map.md"]);
    expect(json["protected_occurrences"]).toEqual([
      { path: "README.md", count: 1 },
    ]);
    expect(json["backslash_occurrences"]).toEqual([
      { path: "README.md", count: 1 },
    ]);
    expect(json["broken_links"]).toEqual([
      "README.md: docs/features/missing.md",
    ]);
    expect(markdown).toContain(
      "## Folders kept without a recoverable issue number (1)",
    );
    expect(markdown).toContain("- none");
  });

  it("carries source, reason and candidate on each held item and a null decision skeleton", () => {
    // Act
    const json = JSON.parse(renderMigrationReportJson(report())) as Record<
      string,
      unknown
    >;

    // Assert
    expect(json["held_items"]).toEqual([
      {
        source: "docs/features/archive/subagentstop-envelope-core-897",
        reason: "non-matching",
        candidate: "0897-subagentstop-envelope-core",
        detail: null,
      },
    ]);
    expect(typeof json["source_digest"]).toBe("string");
    const skeleton = json["decision_skeleton"] as Record<string, unknown>;
    expect(skeleton["dry_run_report"]).toBe(
      "dev-docs-migration-dry-run.2026-11-20T07-15.json",
    );
    expect(
      Object.values(
        skeleton["global_decisions"] as Record<string, unknown>,
      ).every((value) => value === null),
    ).toBe(true);
    expect(skeleton["decisions"]).toEqual([
      {
        source: "docs/features/archive/subagentstop-envelope-core-897",
        action: null,
        target: null,
      },
    ]);
  });

  it("summarizes every count and the source digest", () => {
    // Act
    const built = report();

    // Assert
    expect(Object.keys(built.summary)).toEqual([
      "moves",
      "renames",
      "held_items",
      "formatter_errors",
      "collisions",
      "files_to_rewrite",
      "rewrite_occurrences",
      "excluded_files",
      "protected_occurrences",
      "broken_links",
      "untracked_files",
      "retained_documentation",
      "kept_folders",
      "open_choices",
      "source_digest",
    ]);
    expect(built.summary["held_items"]).toBe(1);
    expect(built.summary["kept_folders"]).toBe(1);
    expect(renderMigrationReportMarkdown(built)).toContain(
      `- source_digest: ${String(built.summary["source_digest"])}`,
    );
  });

  it("names the report file from the injected clock in UTC", () => {
    expect(migrationReportFileName(new Date("2026-11-20T02:05:59-05:00"))).toBe(
      "dev-docs-migration-dry-run.2026-11-20T07-05",
    );
  });

  it("holds repository-relative paths only, never a workspace root", () => {
    // Act
    const text =
      renderMigrationReportJson(report()) +
      renderMigrationReportMarkdown(report());

    // Assert
    expect(text).not.toContain("C:/");
    expect(text).not.toContain("/home/");
    expect(text).not.toMatch(/"\/[A-Za-z]/);
  });
});
