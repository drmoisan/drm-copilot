/**
 * Unit tests for `packages/mcp-server/prepack.cjs` (issue #697).
 *
 * `packages/mcp-server` has no test runner, so the build script is tested from
 * the extension Jest suite, which CI executes. The script destructures
 * `cpSync` from `node:fs` when it loads, so a no-op spy is installed on the
 * shared `node:fs` object before the script is required: requiring the script
 * must copy nothing, and `shouldCopy` is exercised with path strings only.
 */

import { afterAll, describe, expect, it, jest } from "@jest/globals";
import type * as NodeFs from "node:fs";
import * as path from "node:path";

interface PrepackModule {
  readonly SOURCE_DIR: string;
  readonly shouldCopy: (source: string) => boolean;
}

// eslint-disable-next-line @typescript-eslint/no-require-imports -- the spy must patch the shared CommonJS node:fs object that prepack.cjs destructures at load; an ES namespace import yields an interop copy the spy would not reach
const nodeFs = require("node:fs") as typeof NodeFs;
const cpSyncSpy = jest.spyOn(nodeFs, "cpSync").mockImplementation(() => {
  return undefined;
});
const PREPACK_PATH = "../../../../packages/mcp-server/prepack.cjs";
// eslint-disable-next-line @typescript-eslint/no-require-imports -- prepack.cjs is a CommonJS build script run by node; require loads the same module object that packaging executes
const prepack = require(PREPACK_PATH) as PrepackModule;

/** Build an absolute resource path from POSIX-style segments. */
function resource(relative: string): string {
  return path.join(prepack.SOURCE_DIR, ...relative.split("/"));
}

afterAll(() => {
  cpSyncSpy.mockRestore();
});

describe("mcp-server prepack", () => {
  it("exports shouldCopy and performs no copy when required", () => {
    // Assert: loading the module is side-effect free.
    expect(cpSyncSpy).not.toHaveBeenCalled();
    expect(typeof prepack.shouldCopy).toBe("function");
  });

  it("copies the codex resolver wrappers and epic-child scripts", () => {
    // Arrange: every nested `.codex/scripts` entry the Codex bundle ships.
    const scripts = [
      "Resolve-CodexTopology.ps1",
      "Resolve-CodexDeployment.ps1",
      "codex-routing-cli-common.ps1",
      "epic-child-launch-contract.ps1",
      "epic-child-launch-runtime.ps1",
      "epic-child-persistence-runtime.ps1",
      "epic-child-sandbox-preflight.ps1",
      "launch-epic-child-wave.ps1",
      "resume-epic-child.ps1",
    ];

    // Act / Assert
    for (const name of scripts) {
      const source = resource(
        `codex-and-agents-customizations/.codex/scripts/${name}`,
      );
      expect(prepack.shouldCopy(source)).toBe(true);
    }
  });

  it("excludes the resources-root scripts subtree", () => {
    for (const relative of [
      "scripts",
      "scripts/tool.ps1",
      "scripts/nested/deeper/data.json",
    ]) {
      expect(prepack.shouldCopy(resource(relative))).toBe(false);
    }
  });

  it("excludes Python files at every depth", () => {
    for (const relative of [
      "tool.py",
      "scripts/tool.py",
      "codex-and-agents-customizations/.codex/scripts/helper.py",
      "a/b/c/d.py",
    ]) {
      expect(prepack.shouldCopy(resource(relative))).toBe(false);
    }
  });
});
