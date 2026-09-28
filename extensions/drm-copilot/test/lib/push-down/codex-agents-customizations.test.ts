import { describe, expect, it } from "@jest/globals";

import {
  ARTIFACT_DIRECTORY,
  ROOT_FOLDERS,
  passthroughRewrite,
  pushDownCustomizations,
} from "../../../src/lib/push-down/codex-agents-customizations";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");

/** Extension resources directory: the parent of the bundle root below. */
const RESOURCES = "C:/extension/resources";
const BUNDLE_ROOT = `${RESOURCES}/codex-and-agents-customizations`;

/** Destination path to distinct resource content, one entry per virtual pair. */
const VIRTUAL_CONTENT: Readonly<Record<string, string>> = {
  "config/orchestration-routing.json": '{"version":1}\n',
  "config/orchestration-handoff-registry.json": '{"registry":1}\n',
  "config/orchestration-handoff.schema.json": '{"schema":1}\n',
  ".codex/lib/codex-routing/CodexTopology.psm1": "# topology module\n",
  ".codex/lib/codex-routing/CodexDeployment.psm1": "# deployment module\n",
};

/**
 * Build resource-seed entries for every virtual pair under a resources root.
 *
 * @param resourcesRoot Directory holding `config/` and `lib/codex-routing/`.
 * @returns File seeds keyed by resource path.
 */
function seedVirtualResources(resourcesRoot: string): Record<string, string> {
  const seeds: Record<string, string> = {};
  for (const [destination, content] of Object.entries(VIRTUAL_CONTENT)) {
    const resource = destination.replace(/^\.codex\//, "");
    seeds[`${resourcesRoot}/${resource}`] = content;
  }
  return seeds;
}

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
        ...seedVirtualResources(RESOURCES),
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
      bundleRoot: BUNDLE_ROOT,
      clock: CLOCK,
    });

    // Assert: roots in declaration order; each root sorted by code unit.
    expect(summary.files.map((f) => f.relativePath)).toEqual([
      ".codex/config.md",
      ".agents/a.md",
      ".agents/z.md",
      "config/orchestration-handoff-registry.json",
      "config/orchestration-handoff.schema.json",
      "config/orchestration-routing.json",
      ".codex/lib/codex-routing/CodexDeployment.psm1",
      ".codex/lib/codex-routing/CodexTopology.psm1",
    ]);
    expect(fs.readTextFile("/dest/config/orchestration-routing.json")).toBe(
      '{"version":1}\n',
    );
  });

  it("publishes every virtual resource pair in full-tree mode", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      { ...seedVirtualResources(RESOURCES), "/src/.codex/config.md": "body" },
      ["/dest"],
    );

    // Act
    pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      bundleRoot: BUNDLE_ROOT,
      clock: CLOCK,
    });

    // Assert: each destination carries its own resource bytes.
    for (const [destination, content] of Object.entries(VIRTUAL_CONTENT)) {
      expect(fs.readTextFile(`/dest/${destination}`)).toBe(content);
    }
  });

  it("publishes every virtual resource pair in pack mode", () => {
    // Arrange: the bundle root sits two levels below `/` so its parent
    // (`/repo`) keeps resource paths absolute.
    const fs = buildInMemoryFileSystem(
      {
        ...seedVirtualResources("/repo"),
        "/repo/bundle/.codex/config.toml": "core",
        "/repo/bundle/pack-manifests/core.json": JSON.stringify({
          name: "core",
          paths: [".codex/config.toml"],
        }),
        "/repo/bundle/pack-manifests/typescript.json": JSON.stringify({
          name: "typescript",
          paths: [".codex/config.toml"],
        }),
      },
      ["/dest"],
    );

    // Act
    pushDownCustomizations({
      repoRoot: "/repo/bundle",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/repo/bundle",
      artifactRoot: "/dest",
      bundleRoot: "/repo/bundle",
      packs: new Set(["core", "typescript"]),
      clock: CLOCK,
    });

    // Assert
    expect(fs.isFile("/dest/.codex/config.toml")).toBe(true);
    for (const [destination, content] of Object.entries(VIRTUAL_CONTENT)) {
      expect(fs.readTextFile(`/dest/${destination}`)).toBe(content);
    }
  });

  it("does not publish an unmapped file under a virtual root or resource directory", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      {
        ...seedVirtualResources(RESOURCES),
        "/src/.codex/config.md": "body",
        "/src/config/unrelated.json": "{}\n",
        [`${RESOURCES}/lib/codex-routing/Extra.psm1`]: "# extra\n",
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
      bundleRoot: BUNDLE_ROOT,
      clock: CLOCK,
    });

    // Assert
    const published = summary.files.map((f) => f.relativePath);
    expect(published).not.toContain("config/unrelated.json");
    expect(published).not.toContain(".codex/lib/codex-routing/Extra.psm1");
    expect(fs.isFile("/dest/config/unrelated.json")).toBe(false);
    expect(fs.isFile("/dest/.codex/lib/codex-routing/Extra.psm1")).toBe(false);
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
});
