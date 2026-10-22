/**
 * Coverage-threshold contract for the discovery host modules (issue #980).
 *
 * `jest.config.cjs` sits at the 500-line limit, so the discovery per-file
 * thresholds live in `jest.discovery-coverage.json` and are merged into the
 * `coverageThreshold` map. These tests pin that every discovery production
 * module has its own entry at the 90% line / 75% branch floor, that the merge
 * reaches the Jest configuration, that no `global` key exists, and that each
 * gated path is a real production file.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { describe, expect, it } from "@jest/globals";

const EXTENSION_ROOT = path.resolve(__dirname, "..");
const THRESHOLD_MAP_PATH = path.join(
  EXTENSION_ROOT,
  "jest.discovery-coverage.json",
);

/** Executable discovery host modules that must carry their own gate. */
const GATED_DISCOVERY_MODULES: ReadonlyArray<string> = [
  "./src/discovery-result.ts",
  "./src/discovery-runtime.ts",
  "./src/repo-automation-execute-discovery.ts",
];

interface ThresholdEntry {
  readonly lines: number;
  readonly branches: number;
}

function loadThresholdMap(): Record<string, ThresholdEntry> {
  return JSON.parse(fs.readFileSync(THRESHOLD_MAP_PATH, "utf8")) as Record<
    string,
    ThresholdEntry
  >;
}

function loadJestCoverageThreshold(): Record<string, unknown> {
  // eslint-disable-next-line @typescript-eslint/no-require-imports -- the Jest configuration is a CommonJS module
  const config = require(path.join(EXTENSION_ROOT, "jest.config.cjs")) as {
    coverageThreshold: Record<string, unknown>;
  };
  return config.coverageThreshold;
}

describe("discovery coverage threshold map", () => {
  it("gates every executable discovery host module at 90% lines and 75% branches", () => {
    const map = loadThresholdMap();

    for (const modulePath of GATED_DISCOVERY_MODULES) {
      const entry = map[modulePath];
      expect(entry).toBeDefined();
      expect(entry?.lines).toBeGreaterThanOrEqual(90);
      expect(entry?.branches).toBeGreaterThanOrEqual(75);
    }
  });

  it("names only existing production files and no global key", () => {
    const map = loadThresholdMap();

    expect(Object.keys(map)).not.toContain("global");
    for (const modulePath of Object.keys(map)) {
      expect(modulePath.startsWith("./src/")).toBe(true);
      expect(fs.existsSync(path.join(EXTENSION_ROOT, modulePath))).toBe(true);
    }
  });

  it("is merged into the Jest coverageThreshold map", () => {
    const map = loadThresholdMap();
    const merged = loadJestCoverageThreshold();

    expect(merged).not.toHaveProperty("global");
    for (const [modulePath, entry] of Object.entries(map)) {
      expect(merged[modulePath]).toEqual(entry);
    }
  });

  it("leaves the type-only service types module ungated but measured", () => {
    const map = loadThresholdMap();
    const typesPath = path.join(
      EXTENSION_ROOT,
      "src",
      "discovery-service-types.ts",
    );
    const source = fs.readFileSync(typesPath, "utf8");

    // A type-only module has no executable statements, so it legitimately has
    // no threshold entry while remaining inside collectCoverageFrom.
    expect(map["./src/discovery-service-types.ts"]).toBeUndefined();
    expect(source).not.toMatch(/^\s*(export\s+)?(const|let|function|class)\s/m);
  });
});
