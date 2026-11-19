/**
 * Tests of the push-down integration service wiring (issue #1051, S48).
 *
 * The destination and the extension bundle are in-memory fakes with POSIX
 * roots; no test mocks the `fs` module or reads a temporary file.
 */

import { jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationService } from "../src/repo-automation-service";
import {
  detectPushDownIntegrationServiceCall,
  validatePushDownIntegrationServiceCall,
} from "../src/repo-automation-service-push-down-integration";
import {
  DATA_FILE_TEXT,
  DEST,
  destination,
  EXT,
  manifestText,
  type RecordingIntegrationFileSystem,
  seedHarnessWorkflows,
} from "./lib/push-down-integration/integration-test-helpers";

/** A destination whose build workflow differs from the TypeScript reference. */
function versionFixture(): RecordingIntegrationFileSystem {
  const fs = destination({
    ".push-down-manifest.json": manifestText({
      codex: { packs: ["core", "typescript"] },
    }),
    ".github/drm-copilot/ci-required-checks.json": DATA_FILE_TEXT,
    ".github/workflows/build.yml":
      "name: Build\non: push\njobs:\n  b:\n    steps:\n      - with:\n          node-version: '20'\n",
  });
  seedHarnessWorkflows(fs);
  return fs;
}

describe("push-down integration service wiring", () => {
  it("S48 positive: detect reads the destination and the bundled references through the seam", () => {
    const fs = versionFixture();

    const result = detectPushDownIntegrationServiceCall(
      { workspaceRoot: DEST },
      { fs, extensionRoot: EXT },
    );

    expect(result.conflicts.map((item) => item.id)).toContain(
      "version-matrix-difference:.github/workflows/build.yml#b.node-version",
    );
    expect(fs.writeCalls).toEqual([]);
  });

  it("S48 positive: the default service delegates both tools to the injected push-down file system", async () => {
    const fs = versionFixture();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: () => undefined },
      pushDownFileSystem: fs,
    });

    const detected = await service.detectPushDownIntegration?.({
      workspaceRoot: DEST,
    });
    const validated = await service.validatePushDownIntegration?.({
      workspaceRoot: DEST,
    });

    expect(detected?.workflows.map((workflow) => workflow.path)).toEqual([
      ".github/workflows/build.yml",
    ]);
    expect(validated?.verdict).toBe("fail");
    expect(fs.writeCalls).toEqual([]);
  });

  it("S48 negative: a workspace_root that is not a directory is a host error for both tools", () => {
    const fs = destination({});
    const deps = { fs, extensionRoot: EXT };

    expect(() =>
      detectPushDownIntegrationServiceCall({ workspaceRoot: "/missing" }, deps),
    ).toThrow("workspace_root is not a directory: /missing");
    expect(() =>
      validatePushDownIntegrationServiceCall(
        { workspaceRoot: "/missing" },
        deps,
      ),
    ).toThrow("workspace_root is not a directory: /missing");
  });

  it("S48 negative: a file system whose writes throw is never written through the seam", () => {
    const fs = versionFixture();
    const throwing = Object.assign(
      Object.create(fs) as RecordingIntegrationFileSystem,
      {
        writeTextFile: (): void => {
          throw new Error("write attempted");
        },
        ensureDir: (): void => {
          throw new Error("write attempted");
        },
      },
    );

    expect(() =>
      validatePushDownIntegrationServiceCall(
        { workspaceRoot: DEST },
        { fs: throwing, extensionRoot: EXT },
      ),
    ).not.toThrow();
  });
});
