import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

/**
 * Real-filesystem completeness check for `.claude` pack manifests.
 *
 * Purpose:
 *     Regression coverage for issue #279: `computePublishedPaths()` only
 *     publishes files listed in a selected pack manifest's `paths` array, so a
 *     bundled `.claude` agent, skill, or hook that is never added to any
 *     manifest is silently dropped from a manifest-scoped push-down. Unlike the
 *     sibling tests in this directory, this suite intentionally reads the real
 *     bundled `.claude` tree and the real `pack-manifests/*.json` files from
 *     disk (via `node:fs`/`node:path` resolved from `__dirname`) rather than
 *     the `InMemoryPushDownFileSystem` fake, so it fails whenever the actual
 *     bundle and the actual manifests drift apart.
 *
 * Scope note:
 *     Three bundled files (`.claude/agents/pr-author.md`,
 *     `.claude/hooks/enforce-completion-helpers.ps1`,
 *     `.claude/hooks/validate-pr-author-output.ps1`) were already absent from
 *     every pack manifest before issue #279 and are unrelated to the
 *     epic-orchestrate feature (issue #275) this issue addresses. They are
 *     tracked as pre-existing, out-of-scope exceptions below so this test can
 *     assert real completeness without silently absorbing an unrelated
 *     production fix into this change. Do not add further entries here to mask
 *     a new regression; open a follow-up issue instead.
 *
 * Issue #462 extension:
 *     The enumeration originally covered only `agents/`, `hooks/`, and
 *     `skills/`, so a bundled `rules/*.md` or `lib/**` file absent from every
 *     manifest was invisible. It now also enumerates those two trees. The
 *     bundled `config/` tree is a sibling of `.claude` under the bundle root
 *     rather than a child of it, so extending `CLAUDE_ROOT`'s walk alone would
 *     have enumerated nothing for it; a second root constant walks the bundle
 *     root and emits bundle-root-relative `config/...` paths matching the
 *     `core.json` entry spelling. A non-empty floor on the `config/` walk makes
 *     a broken glob fail rather than pass vacuously.
 */

const BUNDLE_ROOT = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "resources",
  "claude-customizations",
);
const CLAUDE_ROOT = path.join(BUNDLE_ROOT, ".claude");
const MANIFEST_DIR = path.join(BUNDLE_ROOT, "pack-manifests");

/** Bundled `config/` tree, a sibling of `.claude` under the bundle root. */
const CONFIG_ROOT = path.join(BUNDLE_ROOT, "config");

/**
 * Floor on the bundled `config/` walk (issue #462).
 *
 * The destination-portability payload must carry both
 * `config/orchestration-routing.json` and `config/blast-radius.json`, so a walk
 * that finds fewer than two files means the tree moved or the glob broke, not
 * that the manifests are complete.
 */
const MINIMUM_CONFIG_FILE_COUNT = 2;

/** Pre-existing, unrelated manifest gaps out of scope for issue #279. */
const PRE_EXISTING_UNRELATED_EXCEPTIONS: ReadonlySet<string> = new Set([
  ".claude/agents/pr-author.md",
  ".claude/hooks/enforce-completion-helpers.ps1",
  ".claude/hooks/validate-pr-author-output.ps1",
]);

/**
 * Enumerate every bundled `.claude`-relative agent, skill, and hook path.
 *
 * @returns Sorted `.claude`-relative POSIX paths found on disk.
 */
function enumerateBundledClaudeRelativePaths(): string[] {
  const results: string[] = [];

  const agentsDir = path.join(CLAUDE_ROOT, "agents");
  for (const entry of fs.readdirSync(agentsDir)) {
    if (entry.endsWith(".md")) {
      results.push(`.claude/agents/${entry}`);
    }
  }

  const hooksDir = path.join(CLAUDE_ROOT, "hooks");
  for (const entry of fs.readdirSync(hooksDir)) {
    if (entry.endsWith(".ps1")) {
      results.push(`.claude/hooks/${entry}`);
    }
  }

  const skillsDir = path.join(CLAUDE_ROOT, "skills");
  for (const entry of fs.readdirSync(skillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      continue;
    }
    const skillFile = path.join(skillsDir, entry.name, "SKILL.md");
    if (fs.existsSync(skillFile)) {
      results.push(`.claude/skills/${entry.name}/SKILL.md`);
    }
  }

  // Issue #462: rules carry repository policy the destination runtime reads,
  // and lib carries the PowerShell and bash libraries the skills invoke. Both
  // trees were previously unenumerated, so a bundled file could be absent from
  // every manifest without this suite noticing.
  const rulesDir = path.join(CLAUDE_ROOT, "rules");
  for (const entry of fs.readdirSync(rulesDir)) {
    if (entry.endsWith(".md")) {
      results.push(`.claude/rules/${entry}`);
    }
  }

  // The lib walk is recursive and deliberately not extension-filtered: a
  // published library file of any kind must be manifest-listed to reach a
  // pack-scoped destination.
  for (const relative of walkFilesRelative(path.join(CLAUDE_ROOT, "lib"))) {
    results.push(`.claude/lib/${relative}`);
  }

  return results.sort();
}

/**
 * Recursively enumerate every file beneath a directory.
 *
 * @param root Absolute directory to walk; a missing directory yields nothing.
 * @returns Forward-slash paths relative to `root`, in directory-walk order.
 */
function walkFilesRelative(root: string): string[] {
  if (!fs.existsSync(root)) {
    return [];
  }
  const results: string[] = [];
  // A depth-first walk keeps the implementation independent of any glob
  // library and cannot silently skip a nested directory.
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      for (const nested of walkFilesRelative(path.join(root, entry.name))) {
        results.push(`${entry.name}/${nested}`);
      }
      continue;
    }
    if (entry.isFile()) {
      results.push(entry.name);
    }
  }
  return results;
}

/**
 * Enumerate every bundled `config/`-relative path (issue #462).
 *
 * Paths are emitted relative to the bundle root rather than to `.claude`,
 * because that is the spelling `core.json` uses for these entries and the
 * spelling the push-down engine derives from the `config` root folder.
 *
 * @returns Sorted bundle-root-relative POSIX paths under `config/`.
 */
function enumerateBundledConfigRelativePaths(): string[] {
  return walkFilesRelative(CONFIG_ROOT)
    .map((relative) => `config/${relative}`)
    .sort();
}

/**
 * Parse every `pack-manifests/*.json` file and union their `paths` arrays.
 *
 * @returns The set of every `.claude`-relative path listed by any manifest.
 */
function unionOfManifestPaths(): ReadonlySet<string> {
  const union = new Set<string>();
  for (const entry of fs.readdirSync(MANIFEST_DIR)) {
    if (!entry.endsWith(".json")) {
      continue;
    }
    const rawText = fs.readFileSync(path.join(MANIFEST_DIR, entry), "utf8");
    const parsed: unknown = JSON.parse(rawText);
    if (parsed === null || typeof parsed !== "object") {
      continue;
    }
    const paths = (parsed as Record<string, unknown>)["paths"];
    if (!Array.isArray(paths)) {
      continue;
    }
    for (const candidate of paths) {
      if (typeof candidate === "string") {
        union.add(candidate);
      }
    }
  }
  return union;
}

describe("claude pack manifest completeness (real filesystem)", () => {
  it("lists every bundled .claude agent, skill, and hook file in some pack manifest", () => {
    // Arrange: enumerate the real bundle and the real manifest union.
    const onDiskPaths = enumerateBundledClaudeRelativePaths();
    const manifestUnion = unionOfManifestPaths();

    // Act: compute bundled paths absent from every manifest, excluding the
    // documented pre-existing, out-of-scope exceptions.
    const missing = onDiskPaths.filter(
      (candidate) =>
        !manifestUnion.has(candidate) &&
        !PRE_EXISTING_UNRELATED_EXCEPTIONS.has(candidate),
    );

    // Assert: no bundled file is silently dropped from every manifest.
    expect(missing).toEqual([]);
  });

  it("lists every bundled config/ file in some pack manifest", () => {
    // Arrange: the config tree is a sibling of .claude, so it is enumerated
    // from its own root rather than through the .claude walk.
    const onDiskPaths = enumerateBundledConfigRelativePaths();
    const manifestUnion = unionOfManifestPaths();

    // Assert the floor first so a broken walk fails loudly rather than passing
    // vacuously with an empty enumeration.
    expect(onDiskPaths.length).toBeGreaterThanOrEqual(
      MINIMUM_CONFIG_FILE_COUNT,
    );

    // Act
    const missing = onDiskPaths.filter(
      (candidate) => !manifestUnion.has(candidate),
    );

    // Assert
    expect(missing).toEqual([]);
  });

  it.each([
    "config/orchestration-routing.json",
    "config/blast-radius.json",
    ".claude/rules/parallel-orchestration.md",
    ".claude/rules/shell.md",
    ".claude/lib/bash/compute-cohorts.sh",
    ".claude/lib/bash/compute-concurrency-batches.sh",
    ".claude/lib/bash/validate-parallel-manifest.sh",
    ".claude/lib/bash/report-lane-assertion.sh",
  ])(
    "issue #462: %s is present in the union of pack-manifest paths",
    (expectedPath) => {
      // Arrange
      const manifestUnion = unionOfManifestPaths();

      // Act / Assert
      expect(manifestUnion.has(expectedPath)).toBe(true);
    },
  );

  it.each([
    ".claude/agents/epic-orchestrator.md",
    ".claude/skills/epic-orchestrate/SKILL.md",
    ".claude/hooks/enforce-epic-merge-gate.ps1",
    ".claude/hooks/enforce-epic-wave-barrier.ps1",
    ".claude/hooks/enforce-epic-worktree-removal-gate.ps1",
    ".claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1",
  ])(
    "issue #279 AC1: %s is present in the union of pack-manifest paths",
    (expectedPath) => {
      // Arrange
      const manifestUnion = unionOfManifestPaths();

      // Act / Assert
      expect(manifestUnion.has(expectedPath)).toBe(true);
    },
  );
});
