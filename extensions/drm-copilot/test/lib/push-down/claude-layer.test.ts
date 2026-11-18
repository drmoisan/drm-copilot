/**
 * Unit tests for the Claude layer composition (issue #1029, D10).
 *
 * Each test builds a fresh in-memory adapter.
 */

import { type PushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";
import {
  buildClaudeLayer,
  MERGED_RELATIVE_PATHS,
  ROOT_FOLDERS,
} from "../../../src/lib/push-down/claude-customizations";
import { mergeClaudeGitignore } from "../../../src/lib/push-down/claude-gitignore-merge";
import {
  composeClaudeLayer,
  type ClaudeLayerWriteDecorator,
} from "../../../src/lib/push-down/claude-layer";
import { WriteIfChangedFileSystem } from "../../../src/lib/push-down/push-down-write-if-changed";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

const BUNDLE = "/ext/resources/claude-customizations";

describe("composeClaudeLayer", () => {
  it("declares MERGED_RELATIVE_PATHS and the .gitignore delivery as merged", () => {
    const fs = buildInMemoryFileSystem({}, ["/dest"]);

    const layer = buildClaudeLayer({
      repoRoot: BUNDLE,
      sourceRoot: BUNDLE,
      bundleRoot: BUNDLE,
      destinationRoot: "/dest",
      fs,
    });

    expect(layer.mergedPaths).toEqual(MERGED_RELATIVE_PATHS);
    expect(
      layer.mergedDeliveries.map((delivery) => delivery.relativePath),
    ).toEqual([".gitignore"]);
    expect(layer.mergedDeliveries[0]?.merge("")).toBe(mergeClaudeGitignore(""));
    expect(layer.rootFolders).toEqual(ROOT_FOLDERS);
    expect(layer.rootFiles).toEqual([
      [".mcp.json", "claude-dir-customizations/.mcp.json"],
    ]);
    expect(layer.resourcesRoot).toBe("/ext/resources");
    expect(layer.artifactDirectory).toBe("artifacts/claude-customizations");
    expect(layer.selection).toEqual({
      packs: ["core", "csharp-modern", "powershell", "python", "typescript"],
      csharpVariant: "modern",
      memoryMode: "overwrite",
    });
  });

  it("resolves the selected packs and the owning pack of each path", () => {
    const fs = buildInMemoryFileSystem({
      [`${BUNDLE}/pack-manifests/core.json`]: JSON.stringify({
        name: "core",
        label: "Core",
        paths: [".claude/a.md"],
      }),
      [`${BUNDLE}/pack-manifests/python.json`]: JSON.stringify({
        name: "python",
        label: "Python",
        paths: [".claude/p.md"],
      }),
      [`${BUNDLE}/.claude/a.md`]: "a",
      [`${BUNDLE}/.claude/p.md`]: "p",
      [`${BUNDLE}/.claude/other.md`]: "o",
    });

    const layer = buildClaudeLayer({
      repoRoot: BUNDLE,
      destinationRoot: "/dest",
      fs,
      bundleRoot: BUNDLE,
      packs: new Set(["python"]),
      csharpVariant: "legacy",
      memoryMode: "skip",
    });

    expect(layer.fs.listFiles(`${BUNDLE}/.claude`)).toEqual([
      `${BUNDLE}/.claude/a.md`,
      `${BUNDLE}/.claude/p.md`,
    ]);
    expect(layer.ownerPack(".claude/p.md")).toBe("python");
    expect(layer.selection).toEqual({
      packs: ["core", "python"],
      csharpVariant: "legacy",
      memoryMode: "skip",
    });
  });

  it("folds the write decorators over the write-if-changed base, innermost first", () => {
    const fs = buildInMemoryFileSystem({}, ["/dest"]);
    const seen: string[] = [];
    const recording = (name: string): ClaudeLayerWriteDecorator => ({
      relativePath: name,
      wrap: (inner: PushDownFileSystem, destinationRoot, options) => {
        seen.push(
          `${name}:${inner instanceof WriteIfChangedFileSystem ? "base" : "decorated"}:${destinationRoot}:${options.listEntries === undefined ? "none" : "lister"}`,
        );
        return inner;
      },
    });

    composeClaudeLayer(
      {
        rootFolders: [".claude"],
        excludedRelativePaths: [],
        mergedRelativePaths: [],
        destinationWriteDecorators: [recording("first"), recording("second")],
        artifactDirectory: "artifacts/x",
      },
      {
        repoRoot: "/src",
        sourceRoot: "/src",
        bundleRoot: "/src",
        resourcesRoot: "/",
        destinationRoot: "/dest",
        fs,
        packs: null,
        csharpVariant: "modern",
        memoryMode: "overwrite",
        listEntries: () => [],
      },
    );

    expect(seen).toEqual([
      "first:base:/dest:lister",
      "second:base:/dest:lister",
    ]);
  });
});
