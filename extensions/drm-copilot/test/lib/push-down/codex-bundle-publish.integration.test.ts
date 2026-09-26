/**
 * Real-bundle integration tests for the Codex/agents publisher (issue #697).
 *
 * Drives `pushDownCodexAndAgentsCustomizationsServiceCall` over the real
 * `extensions/drm-copilot/resources` tree with an in-memory destination, so the
 * published payload is checked end to end without creating any temporary file.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { describe, expect, it } from "@jest/globals";

import { pushDownCodexAndAgentsCustomizationsServiceCall } from "../../../src/lib/push-down/push-down-service-call";
import { toPosixPath } from "../../../src/lib/push-down/filesystem-adapter";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";
import {
  collectRegisteredHookClosure,
  ReadThroughPushDownFileSystem,
} from "./real-bundle-filesystem.test-helpers";

const EXTENSION_ROOT = toPosixPath(path.resolve(__dirname, "..", "..", ".."));
const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");
const BUNDLE_ROOT = path.join(
  EXTENSION_ROOT,
  "resources",
  "codex-and-agents-customizations",
);
const CLOCK = fixedClock("2026-09-25T00:00:00.000Z");

/** Build a destination filesystem that reads the real extension tree. */
function newFileSystem(): ReadThroughPushDownFileSystem {
  return new ReadThroughPushDownFileSystem(
    EXTENSION_ROOT,
    buildInMemoryFileSystem({}, ["/dest"]),
  );
}

describe("Codex bundle publish (real bundle, in-memory destination)", () => {
  it("publishes the config and codex-routing resources from the real bundle in full-tree mode", () => {
    // Arrange
    const fsDouble = newFileSystem();

    // Act
    pushDownCodexAndAgentsCustomizationsServiceCall({
      fs: fsDouble,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: "/dest",
      clock: CLOCK,
    });

    // Assert: every self-sufficiency resource reaches the destination.
    for (const destination of [
      "config/orchestration-routing.json",
      "config/orchestration-handoff-registry.json",
      "config/orchestration-handoff.schema.json",
      ".codex/lib/codex-routing/CodexTopology.psm1",
      ".codex/lib/codex-routing/CodexDeployment.psm1",
      ".codex/scripts/Resolve-CodexTopology.ps1",
      ".codex/scripts/Resolve-CodexDeployment.ps1",
    ]) {
      expect(fsDouble.isFile(`/dest/${destination}`)).toBe(true);
    }
    for (const moduleName of ["CodexTopology.psm1", "CodexDeployment.psm1"]) {
      const published = Buffer.from(
        fsDouble.readTextFile(`/dest/.codex/lib/codex-routing/${moduleName}`),
        "utf8",
      );
      const canonical = fs.readFileSync(
        path.join(REPO_ROOT, ".claude", "lib", "codex-routing", moduleName),
      );
      expect(published.equals(canonical)).toBe(true);
    }
    expect(fsDouble.memory.writtenPaths.length).toBeGreaterThan(0);
    for (const written of fsDouble.memory.writtenPaths) {
      expect(written.startsWith("/dest/")).toBe(true);
    }
  });

  it("publishes every registered hook and its dot-source closure in typescript pack mode", () => {
    // Arrange
    const fsDouble = newFileSystem();
    const required = collectRegisteredHookClosure(BUNDLE_ROOT);

    // Act
    pushDownCodexAndAgentsCustomizationsServiceCall({
      fs: fsDouble,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: "/dest",
      packs: ["typescript"],
      clock: CLOCK,
    });

    // Assert
    expect(required.length).toBeGreaterThan(21);
    const missing = required.filter(
      (relative) => !fsDouble.isFile(`/dest/${relative}`),
    );
    expect(missing).toEqual([]);
  });

  it("publishes the corrected csharp-legacy role file", () => {
    // Arrange
    const fsDouble = newFileSystem();

    // Act
    pushDownCodexAndAgentsCustomizationsServiceCall({
      fs: fsDouble,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: "/dest",
      packs: ["csharp"],
      csharpVariant: "legacy",
      clock: CLOCK,
    });

    // Assert
    const roleText = fsDouble.readTextFile(
      "/dest/.codex/agents/csharp-typed-engineer.toml",
    );
    expect(roleText).toContain('model = "gpt-5.6-terra"');
    expect(roleText).not.toMatch(/^variant\s*=/m);
  });
});
