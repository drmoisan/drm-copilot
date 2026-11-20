import { describe, expect, it } from "@jest/globals";

import {
  applyMigrationPlan,
  DOCS_README_TEXT,
} from "../../../src/lib/development-docs-migration/migration-apply";
import {
  computeSourceDigest,
  parseMigrationDecisions,
  RECORD_ONLY_KEYS,
  type CommitSplit,
  type MigrationDecisions,
} from "../../../src/lib/development-docs-migration/migration-decisions";
import {
  buildMigrationPlan,
  type MigrationPlan,
} from "../../../src/lib/development-docs-migration/migration-plan";
import { FakeMigrationGit, InMemoryFileSystem } from "./migration-test-fakes";

const ROOT = "repo";
const FOO = "docs/features/active/2026-10-30-foo-1016";

/** A fixture repository with moves, a rename, references, links and no held item. */
function fixture(extra: Record<string, string> = {}): InMemoryFileSystem {
  const files: Record<string, string> = {
    [`${FOO}/spec.md`]: "[a](../../../../.github/instructions/a.md)\n",
    [`${FOO}/v1/plan.md`]: "v1",
    "docs/features/templates/feature/plan.md": "template",
    "README.md": `[s](${FOO}/spec.md) and docs/features/templates/`,
    ".github/instructions/a.md": "policy",
    ...extra,
  };
  const rooted: Record<string, string> = {};
  for (const [path, text] of Object.entries(files)) {
    rooted[`${ROOT}/${path}`] = text;
  }
  return new InMemoryFileSystem(rooted);
}

function decisions(
  fs: InMemoryFileSystem,
  split: CommitSplit,
): MigrationDecisions {
  const folders = plan(fs, null).candidateFolders;
  const globals: Record<string, unknown> = {
    discovery_templates_target: ".dev/discovery/templates",
    in_tree_rewrite_scope: "references-and-links",
    commit_split: split,
  };
  for (const key of RECORD_ONLY_KEYS) {
    globals[key] = "recorded";
  }
  return parseMigrationDecisions(
    JSON.stringify({
      version: 1,
      source_digest: computeSourceDigest(folders),
      global_decisions: globals,
    }),
  );
}

function plan(
  fs: InMemoryFileSystem,
  decided: MigrationDecisions | null,
): MigrationPlan {
  const git = new FakeMigrationGit(fs, { root: ROOT });
  return buildMigrationPlan({
    mode: "apply",
    insideWorkTree: true,
    hasUncommittedTrackedChanges: false,
    trackedFiles: git.listTrackedFiles([]),
    untrackedFiles: [],
    readText: (path) => fs.files.get(`${ROOT}/${path}`),
    decisions: decided,
    defaultDiscoveryTarget: ".dev/discovery/templates",
  }).plan;
}

describe("applyMigrationPlan", () => {
  it("applies moves, renames, rewrites, link recomputation and README creation in one single-split call", () => {
    // Arrange
    const fs = fixture();
    const git = new FakeMigrationGit(fs, { root: ROOT });

    // Act
    const result = applyMigrationPlan(plan(fs, decisions(fs, "single")), {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });

    // Assert
    expect(result).toEqual({
      phase: "all",
      moved: 2,
      renamed: 1,
      rewritten: 2,
      readmeCreated: true,
      readmeExisting: false,
    });
    expect([...fs.files.keys()].sort()).toEqual([
      "repo/.dev/active/1016-foo/spec.md",
      "repo/.dev/active/1016-foo/v1/plan.md",
      "repo/.dev/templates/feature/plan.md",
      "repo/.github/instructions/a.md",
      "repo/README.md",
      "repo/docs/README.md",
    ]);
    expect(fs.files.get("repo/.dev/active/1016-foo/spec.md")).toBe(
      "[a](../../../.github/instructions/a.md)\n",
    );
    expect(fs.files.get("repo/README.md")).toBe(
      "[s](.dev/active/1016-foo/spec.md) and .dev/templates/",
    );
    expect(fs.files.get("repo/docs/README.md")).toBe(DOCS_README_TEXT);
  });

  it("calls ensureDir on each destination parent before its move", () => {
    // Arrange
    const fs = fixture();
    const git = new FakeMigrationGit(fs, { root: ROOT });

    // Act
    applyMigrationPlan(plan(fs, decisions(fs, "single")), {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });

    // Assert
    const moves = fs.events.filter((event) => event.startsWith("move:"));
    expect(moves).toHaveLength(3);
    for (const move of moves) {
      const target = move.split("->")[1] ?? "";
      const parent = `ensureDir:repo/${target.split("/").slice(0, -1).join("/")}`;
      expect(fs.events.indexOf(parent)).toBeGreaterThanOrEqual(0);
      expect(fs.events.indexOf(parent)).toBeLessThan(fs.events.indexOf(move));
    }
  });

  it("yields an empty plan on a second apply, with no move call and no write", () => {
    // Arrange
    const fs = fixture();
    const git = new FakeMigrationGit(fs, { root: ROOT });
    applyMigrationPlan(plan(fs, decisions(fs, "single")), {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });
    const movesBefore = git.moves.length;
    const writesBefore = fs.writes.length;

    // Act
    const second = plan(fs, null);
    const result = applyMigrationPlan(second, {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });

    // Assert
    expect(second.moves).toEqual([]);
    expect(second.renames).toEqual([]);
    expect(second.rewrites).toEqual([]);
    expect(git.moves).toHaveLength(movesBefore);
    expect(fs.writes).toHaveLength(writesBefore);
    expect(result).toMatchObject({
      moved: 0,
      renamed: 0,
      rewritten: 0,
      readmeCreated: false,
    });
  });

  it("performs moves on the first moves-then-rewrites call and rewrites on the second", () => {
    // Arrange
    const fs = fixture();
    const git = new FakeMigrationGit(fs, { root: ROOT });
    const split = decisions(fs, "moves-then-rewrites");

    // Act
    const first = applyMigrationPlan(plan(fs, split), {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });
    const writesAfterFirst = fs.writes.length;
    const second = applyMigrationPlan(plan(fs, split), {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });

    // Assert
    expect(first).toMatchObject({
      phase: "moves",
      moved: 2,
      renamed: 1,
      rewritten: 0,
    });
    expect(writesAfterFirst).toBe(0);
    expect(second).toMatchObject({
      phase: "all",
      moved: 0,
      renamed: 0,
      readmeCreated: true,
    });
    expect(second.rewritten).toBeGreaterThan(0);
    // The second call re-plans against the moved tree (spec H2), so only the
    // prefix rewrite of unmoved files remains for it.
    expect(fs.files.get("repo/README.md")).toContain("and .dev/templates/");
  });

  it("leaves an existing docs/README.md unchanged and reports it", () => {
    // Arrange
    const fs = fixture({ "docs/README.md": "existing production index" });
    const git = new FakeMigrationGit(fs, { root: ROOT });

    // Act
    const result = applyMigrationPlan(plan(fs, decisions(fs, "single")), {
      git,
      fileSystem: fs,
      workspaceRoot: ROOT,
    });

    // Assert
    expect(result).toMatchObject({
      readmeCreated: false,
      readmeExisting: true,
    });
    expect(fs.files.get("repo/docs/README.md")).toBe(
      "existing production index",
    );
  });
});
