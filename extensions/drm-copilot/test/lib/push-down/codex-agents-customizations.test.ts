import { describe, expect, it } from "@jest/globals";

import {
  ARTIFACT_DIRECTORY,
  ROOT_FOLDERS,
  passthroughRewrite,
  pushDownCustomizations,
} from "../../../src/lib/push-down/codex-agents-customizations";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");
const PORTABLE_CLAUDE_PATHS = [
  ".claude/lib/bash/compute-cohorts.sh",
  ".claude/lib/bash/compute-concurrency-batches.sh",
  ".claude/lib/bash/parallel-cohorts.sh",
  ".claude/lib/bash/parallel-common.sh",
  ".claude/lib/bash/parallel-items-validate.sh",
  ".claude/lib/bash/parallel-manifest-validate.sh",
  ".claude/lib/bash/parallel-yaml-emit.sh",
  ".claude/lib/bash/parallel-yaml-scan.sh",
  ".claude/lib/bash/validate-parallel-manifest.sh",
  ".claude/lib/blast-radius/BlastRadius.psm1",
  ".claude/lib/blast-radius/BlastRadiusConfig.psm1",
  ".claude/lib/blast-radius/BlastRadiusExtraction.psm1",
  ".claude/lib/blast-radius/BlastRadiusGlob.psm1",
  ".claude/lib/blast-radius/BlastRadiusValidation.psm1",
] as const;
const BLAST_RADIUS_CONFIG = "config/blast-radius.json";
const UNRELATED_CLAUDE_PATH = ".claude/rules/parallel-orchestration.md";
const COMMIT_STEWARD_PROFILE_PATHS = [
  ".codex/agents/commit-steward.toml",
  ".codex/agents/commit-steward-c1.toml",
  ".codex/agents/commit-steward-c2.toml",
  ".codex/agents/commit-steward-c3.toml",
  ".codex/agents/commit-steward-c3-elevated.toml",
  ".codex/agents/commit-steward-c4.toml",
] as const;

describe("passthroughRewrite", () => {
  it("returns the text unchanged with zero counts and no unmatched refs", () => {
    // Arrange
    const text = "Run scripts.dev_tools.potential_to_issue here.";

    // Act
    const [out, rewritten, placeholder, unmatched] = passthroughRewrite(text);

    // Assert: the passthrough never rewrites known references.
    expect(out).toBe(text);
    expect(rewritten).toBe(0);
    expect(placeholder).toBe(0);
    expect(unmatched).toEqual([]);
  });
});

describe("pushDownCustomizations (codex/agents)", () => {
  it("copies the .codex and .agents trees in deterministic root then path order", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      {
        "C:/extension/resources/config/orchestration-routing.json":
          '{"version":1}\n',
        "/src/.agents/z.md": "agents z",
        "/src/.agents/a.md": "agents a",
        "/src/.codex/config.md": "codex config",
      },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      bundleRoot: "C:/extension/resources/codex-and-agents-customizations",
      clock: CLOCK,
    });

    // Assert: .codex root enumerated before .agents; .agents sorted a,z.
    expect(summary.files.map((f) => f.relativePath)).toEqual([
      ".codex/config.md",
      ".agents/a.md",
      ".agents/z.md",
      "config/orchestration-routing.json",
    ]);
    expect(fs.readTextFile("/dest/config/orchestration-routing.json")).toBe(
      '{"version":1}\n',
    );
  });

  it("leaves content byte-identical and yields zero rewrite counts", () => {
    // Arrange: content contains a reference the copilot rewrite would change.
    const fs = buildInMemoryFileSystem(
      {
        "/src/.codex/config.md":
          "Run scripts.dev_tools.potential_to_issue then scripts.dev_tools.unknown_x.",
      },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert: passthrough leaves the text untouched and reports no rewrites.
    expect(fs.readTextFile("/dest/.codex/config.md")).toBe(
      "Run scripts.dev_tools.potential_to_issue then scripts.dev_tools.unknown_x.",
    );
    expect(summary.rewrittenReferenceCount).toBe(0);
    expect(summary.placeholderRewriteCount).toBe(0);
    expect(summary.unmatchedReferences).toEqual([]);
  });

  it("writes the artifact under the codex/agents artifact directory", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({ "/src/.codex/config.md": "body" }, [
      "/dest",
    ]);

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert
    expect(summary.artifactPath).toBe(
      "/dest/artifacts/codex-and-agents-customizations/push-down-20260626T001500Z.json",
    );
    expect(ARTIFACT_DIRECTORY).toBe(
      "artifacts/codex-and-agents-customizations",
    );
    expect(ROOT_FOLDERS).toEqual([".codex", ".agents"]);
  });

  it("keeps no-selection full-tree behavior", () => {
    const fs = buildInMemoryFileSystem(
      {
        "/src/.codex/config.md": "core",
        "/src/.agents/skills/python/SKILL.md": "python",
        "/src/.agents/skills/csharp/SKILL.md": "csharp",
      },
      ["/dest"],
    );

    pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    expect(fs.isFile("/dest/.codex/config.md")).toBe(true);
    expect(fs.isFile("/dest/.agents/skills/python/SKILL.md")).toBe(true);
    expect(fs.isFile("/dest/.agents/skills/csharp/SKILL.md")).toBe(true);
  });

  it("writes only core plus TypeScript paths for selected TypeScript packs", () => {
    const fs = buildInMemoryFileSystem(
      {
        "/src/.codex/config.toml": "core",
        "/src/.agents/skills/typescript/SKILL.md": "ts",
        "/src/.agents/skills/python/SKILL.md": "py",
        "/src/.agents/skills/powershell/SKILL.md": "ps",
        "/src/.agents/skills/csharp/SKILL.md": "cs",
        "/src/pack-manifests/core.json": JSON.stringify({
          name: "core",
          paths: [".codex/config.toml"],
        }),
        "/src/pack-manifests/typescript.json": JSON.stringify({
          name: "typescript",
          paths: [".agents/skills/typescript/SKILL.md"],
        }),
      },
      ["/dest"],
    );

    pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      bundleRoot: "/src",
      packs: new Set(["core", "typescript"]),
      clock: CLOCK,
    });

    expect(fs.isFile("/dest/.codex/config.toml")).toBe(true);
    expect(fs.isFile("/dest/.agents/skills/typescript/SKILL.md")).toBe(true);
    expect(fs.isFile("/dest/.agents/skills/python/SKILL.md")).toBe(false);
    expect(fs.isFile("/dest/.agents/skills/powershell/SKILL.md")).toBe(false);
    expect(fs.isFile("/dest/.agents/skills/csharp/SKILL.md")).toBe(false);
  });

  it("publishes the generated family once and additively merges routing", () => {
    const bundleRoot = "/resources/codex-and-agents-customizations";
    const files: Record<string, string> = {
      "/resources/config/orchestration-routing.json": JSON.stringify({
        codex_model_policy: {
          generated_agent_families: ["commit-steward"],
        },
      }),
      "/dest/config/orchestration-routing.json": JSON.stringify({
        routes: { destination: { owner: "destination" } },
        destination_only: true,
      }),
      "/src/.claude/rules/unrelated.md": "unrelated\n",
      [`${bundleRoot}/pack-manifests/core.json`]: JSON.stringify({
        name: "core",
        paths: [
          ...COMMIT_STEWARD_PROFILE_PATHS,
          "config/orchestration-routing.json",
        ],
      }),
    };
    for (const relativePath of COMMIT_STEWARD_PROFILE_PATHS) {
      files[`/src/${relativePath}`] = `profile:${relativePath}\n`;
    }
    const fs = buildInMemoryFileSystem(files, ["/dest"]);

    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      sourceRoot: "/src",
      artifactRoot: "/dest",
      bundleRoot,
      packs: new Set(["core"]),
      fs,
      clock: CLOCK,
    });

    const publishedFamily = summary.files
      .map((file) => file.relativePath)
      .filter((path) => path.startsWith(".codex/agents/commit-steward"));
    expect(publishedFamily).toEqual([...COMMIT_STEWARD_PROFILE_PATHS].sort());
    for (const relativePath of COMMIT_STEWARD_PROFILE_PATHS) {
      expect(
        fs.writtenPaths.filter((path) => path === `/dest/${relativePath}`),
      ).toHaveLength(1);
    }
    expect(fs.isFile("/dest/.claude/rules/unrelated.md")).toBe(false);
    expect(
      JSON.parse(fs.readTextFile("/dest/config/orchestration-routing.json")),
    ).toEqual({
      routes: { destination: { owner: "destination" } },
      destination_only: true,
      codex_model_policy: {
        generated_agent_families: ["commit-steward"],
      },
    });
  });

  it("routes legacy C# source content to canonical paths only", () => {
    const fs = buildInMemoryFileSystem(
      {
        "/src/.codex/config.toml": "core",
        "/src/.agents/skills/csharp/SKILL.md": "modern skill",
        "/src/.codex/agents/csharp-typed-engineer.toml": "modern agent",
        "/src/.agents-variants/csharp-legacy/skills/csharp/SKILL.md":
          "legacy skill",
        "/src/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml":
          "legacy agent",
        "/src/pack-manifests/core.json": JSON.stringify({
          name: "core",
          paths: [".codex/config.toml"],
        }),
        "/src/pack-manifests/csharp-legacy.json": JSON.stringify({
          name: "csharp-legacy",
          paths: [
            ".agents/skills/csharp/SKILL.md",
            ".codex/agents/csharp-typed-engineer.toml",
          ],
        }),
      },
      ["/dest"],
    );

    pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      bundleRoot: "/src",
      packs: new Set(["core", "csharp"]),
      csharpVariant: "legacy",
      clock: CLOCK,
    });

    expect(fs.readTextFile("/dest/.agents/skills/csharp/SKILL.md")).toBe(
      "legacy skill",
    );
    expect(
      fs.readTextFile("/dest/.codex/agents/csharp-typed-engineer.toml"),
    ).toBe("legacy agent");
    expect(
      fs.isFile("/dest/.agents-variants/csharp-legacy/skills/csharp/SKILL.md"),
    ).toBe(false);
    expect(
      fs.isFile(
        "/dest/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml",
      ),
    ).toBe(false);
  });

  it("defaults sourceRoot/artifactRoot to repoRoot and uses a real clock when omitted", () => {
    // Arrange: omit sourceRoot, artifactRoot, and clock to exercise the
    // option-defaulting branches (repoRoot fallback + real Date).
    const fs = buildInMemoryFileSystem({ "/repo/.codex/config.md": "body" }, [
      "/dest-omit",
    ]);

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/repo",
      destinationRoot: "/dest-omit",
      fs,
    });

    // Assert: artifact path is rooted at repoRoot (the default artifact root)
    // and the deterministic JSON shape still holds.
    expect(summary.artifactPath).toContain(
      "/repo/artifacts/codex-and-agents-customizations/push-down-",
    );
    expect(summary.files.map((f) => f.relativePath)).toEqual([
      ".codex/config.md",
    ]);
  });

  it("classifies created vs overwritten files", () => {
    // Arrange: one destination file preexists.
    const fs = buildInMemoryFileSystem(
      {
        "/src/.codex/config.md": "new",
        "/src/.agents/a.md": "new agent",
        "/dest/.codex/config.md": "old",
      },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert
    expect(summary.createdCount).toBe(1);
    expect(summary.overwrittenCount).toBe(1);
    const codexResult = summary.files.find(
      (f) => f.relativePath === ".codex/config.md",
    );
    expect(codexResult?.destinationStatus).toBe("overwritten");
  });

  it("publishes only the fixed portable assets and the generic config", () => {
    const bundleRoot = "/resources/codex-and-agents-customizations";
    const claudeBundle = "/resources/claude-customizations";
    const files: Record<string, string> = {
      "/src/.codex/config.toml": "codex-config\n",
      "/src/config/blast-radius.json": "repo-specific\n",
      [`${claudeBundle}/${BLAST_RADIUS_CONFIG}`]: "generic-default\n",
      [`/src/${UNRELATED_CLAUDE_PATH}`]: "unrelated\n",
      [`${bundleRoot}/pack-manifests/core.json`]: JSON.stringify({
        name: "core",
        paths: [
          ".codex/config.toml",
          ...PORTABLE_CLAUDE_PATHS,
          BLAST_RADIUS_CONFIG,
        ],
      }),
    };
    for (const relativePath of PORTABLE_CLAUDE_PATHS) {
      const content = `portable:${relativePath}\n`;
      files[`/src/${relativePath}`] = content;
      files[`${claudeBundle}/${relativePath}`] = content;
    }
    const fs = buildInMemoryFileSystem(files, ["/dest"]);

    pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      sourceRoot: "/src",
      artifactRoot: "/dest",
      bundleRoot,
      packs: new Set(["core"]),
      fs,
      clock: CLOCK,
    });

    expect(PORTABLE_CLAUDE_PATHS).toHaveLength(14);
    for (const relativePath of PORTABLE_CLAUDE_PATHS) {
      expect(fs.isFile(`/dest/${relativePath}`)).toBe(true);
    }
    expect(fs.readTextFile(`/dest/${BLAST_RADIUS_CONFIG}`)).toBe(
      "generic-default\n",
    );
    expect(fs.isFile(`/dest/${UNRELATED_CLAUDE_PATH}`)).toBe(false);
  });

  it("rejects an unequal existing portable destination collision", () => {
    const bundleRoot = "/resources/codex-and-agents-customizations";
    const portablePath = PORTABLE_CLAUDE_PATHS[0];
    const fs = buildInMemoryFileSystem(
      {
        "/src/.codex/config.toml": "codex-config\n",
        [`/src/${portablePath}`]: "source-owned\n",
        [`/dest/${portablePath}`]: "destination-owned\n",
        [`${bundleRoot}/pack-manifests/core.json`]: JSON.stringify({
          name: "core",
          paths: [".codex/config.toml", portablePath],
        }),
      },
      ["/dest"],
    );

    expect(() =>
      pushDownCustomizations({
        repoRoot: "/src",
        destinationRoot: "/dest",
        sourceRoot: "/src",
        artifactRoot: "/dest",
        bundleRoot,
        packs: new Set(["core"]),
        fs,
        clock: CLOCK,
      }),
    ).toThrow(/portable.*collision/i);
    expect(fs.readTextFile(`/dest/${portablePath}`)).toBe(
      "destination-owned\n",
    );
  });
});
