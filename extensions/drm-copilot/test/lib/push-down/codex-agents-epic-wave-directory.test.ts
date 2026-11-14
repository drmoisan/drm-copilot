import { describe, expect, it } from "@jest/globals";

import {
  VIRTUAL_RESOURCE_DIRECTORIES,
  VIRTUAL_ROOT_FOLDERS,
  pushDownCustomizations,
} from "../../../src/lib/push-down/codex-agents-customizations";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-11-08T00:00:00.000Z");
const RESOURCES = "C:/extension/resources";
const BUNDLE_ROOT = `${RESOURCES}/codex-and-agents-customizations`;

describe("epic-wave virtual resource directory (issue #1129)", () => {
  it("maps .codex/lib/epic-wave to the stored lib/epic-wave resources", () => {
    // Arrange / Act / Assert: the pair and the virtual root are both present.
    expect(VIRTUAL_RESOURCE_DIRECTORIES).toContainEqual([
      ".codex/lib/epic-wave",
      "lib/epic-wave",
    ]);
    expect(VIRTUAL_ROOT_FOLDERS).toContain(".codex/lib/epic-wave");
  });

  it("publishes every stored epic-wave file under .codex/lib/epic-wave", () => {
    // Arrange: two files with distinct bytes prove the mapping is per file.
    const stored: Record<string, string> = {
      "lib/epic-wave/EpicWave.psm1": "# wave module\n",
      "lib/epic-wave/Invoke-EpicWave.ps1": "# wave cli\n",
    };
    const seeds: Record<string, string> = { "/src/.codex/config.md": "body" };
    for (const [resource, content] of Object.entries(stored)) {
      seeds[`${RESOURCES}/${resource}`] = content;
    }
    const fs = buildInMemoryFileSystem(seeds, ["/dest"]);

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
    for (const [resource, content] of Object.entries(stored)) {
      const destination = `.codex/${resource}`;
      expect(published).toContain(destination);
      expect(fs.readTextFile(`/dest/${destination}`)).toBe(content);
    }
  });
});
