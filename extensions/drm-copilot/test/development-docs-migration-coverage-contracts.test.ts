/**
 * Coverage-threshold contract for the thirteen development-docs migration
 * production files (issue #1016). The per-file thresholds live in
 * `jest.development-docs-migration-coverage.json` and are merged into the
 * `coverageThreshold` map of `jest.config.cjs`.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { describe, expect, it } from "@jest/globals";

const EXTENSION_ROOT = path.resolve(__dirname, "..");
const THRESHOLD_MAP_PATH = path.join(
  EXTENSION_ROOT,
  "jest.development-docs-migration-coverage.json",
);

/** The thirteen new production files of issue #1016 stage A. */
const MIGRATION_MODULES: ReadonlyArray<string> = [
  "./src/lib/development-docs-migration/folder-rename-plan.ts",
  "./src/lib/development-docs-migration/layout-map.ts",
  "./src/lib/development-docs-migration/migrate-development-docs-service-call.ts",
  "./src/lib/development-docs-migration/migration-apply.ts",
  "./src/lib/development-docs-migration/migration-decisions.ts",
  "./src/lib/development-docs-migration/migration-git.ts",
  "./src/lib/development-docs-migration/migration-plan.ts",
  "./src/lib/development-docs-migration/migration-report.ts",
  "./src/lib/development-docs-migration/reference-rewrite.ts",
  "./src/mcp-development-docs-tool-definitions.ts",
  "./src/mcp-handlers/development-docs-migration-handler.ts",
  "./src/mcp-tool-inputs-development-docs.ts",
  "./src/migrate-development-docs-cli.ts",
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

describe("development-docs migration coverage threshold map", () => {
  it("gates each of the thirteen new files at 85% lines and 75% branches", () => {
    const map = loadThresholdMap();
    expect(Object.keys(map).sort()).toEqual([...MIGRATION_MODULES].sort());
    for (const modulePath of MIGRATION_MODULES) {
      expect(map[modulePath]).toEqual({ lines: 85, branches: 75 });
    }
  });

  it("names only existing production files and no global key", () => {
    const map = loadThresholdMap();
    expect(Object.keys(map)).not.toContain("global");
    for (const modulePath of Object.keys(map)) {
      expect(fs.existsSync(path.join(EXTENSION_ROOT, modulePath))).toBe(true);
    }
  });

  it("is merged into the Jest coverageThreshold map", () => {
    const merged = loadJestCoverageThreshold();
    expect(merged).not.toHaveProperty("global");
    for (const [modulePath, entry] of Object.entries(loadThresholdMap())) {
      expect(merged[modulePath]).toEqual(entry);
    }
  });
});
