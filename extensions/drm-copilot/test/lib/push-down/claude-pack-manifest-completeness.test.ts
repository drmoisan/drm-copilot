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
 */

const CLAUDE_ROOT = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "resources",
  "claude-customizations",
  ".claude",
);
const MANIFEST_DIR = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "resources",
  "claude-customizations",
  "pack-manifests",
);

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

  return results.sort();
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
