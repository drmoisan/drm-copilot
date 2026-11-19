/**
 * In-memory end-to-end case of the integration loop (issue #1051, S44).
 *
 * One destination runs through a CI-enabled push-down apply, detect, validate,
 * a scripted resolution edit, a second apply, and validate again. The bundles
 * are seeded in memory; the CI bundle is read once from the tracked
 * `resources/ci-workflows/` folder.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { pushDownHarness } from "../../../src/lib/push-down/push-down-harness";
import { detectPushDownIntegration } from "../../../src/lib/push-down-integration/integration-detect";
import { validatePushDownIntegration } from "../../../src/lib/push-down-integration/integration-validate";
import { type InMemoryPushDownFileSystem } from "../push-down/push-down.test-helpers";
import {
  SEED_EXTENSION_ROOT,
  seedThreeBundles,
} from "../push-down/push-down-pipeline.test-helpers";

const RESOURCES = join(__dirname, "..", "..", "..", "resources");
const CI_FILES = [
  "ci-workflows/caller/drm-copilot-ci.template.yml",
  "ci-workflows/caller/jobs/python.yml",
  "ci-workflows/ci-required-checks.json",
  "ci-workflows/Set-CiRequiredChecks.ps1",
  "ci-workflows/workflows/harness-python.yml",
] as const;
const FILE = "/dest/.push-down-integration-needed.json";

/** Seed the three bundles plus the CI files the python job needs. */
function seed(): InMemoryPushDownFileSystem {
  const fs = seedThreeBundles();
  for (const path of CI_FILES) {
    fs.seedFile(
      `${SEED_EXTENSION_ROOT}/resources/${path}`,
      readFileSync(join(RESOURCES, ...path.split("/")), "utf8"),
    );
  }
  return fs;
}

/** Run a Copilot python push-down apply against `/dest`. */
function pushDown(
  fs: InMemoryPushDownFileSystem,
  ecosystems: Parameters<typeof pushDownHarness>[0]["ecosystems"],
  ciWorkflows?: "reference",
) {
  return pushDownHarness({
    extensionRoot: SEED_EXTENSION_ROOT,
    destinationRoot: "/dest",
    fs,
    ecosystems,
    listEntries: () => [],
    ...(ciWorkflows === undefined ? {} : { ciWorkflows }),
  });
}

/** Item ids recorded in the integration-needed file. */
function fileIds(fs: InMemoryPushDownFileSystem): string[] {
  const document = JSON.parse(fs.readTextFile(FILE)) as {
    items: Array<{ id: string }>;
  };
  return document.items.map((item) => item.id);
}

const READ = { destinationRoot: "/dest", extensionRoot: SEED_EXTENSION_ROOT };

describe("integration loop end to end", () => {
  it("S44 positive: push-down, detect, validate, resolve, push-down and validate again", () => {
    const fs = seed();
    fs.seedFile(
      "/dest/.github/workflows/ci.yml",
      "name: CI\non: push\njobs:\n  build:\n    name: Build\n    runs-on: ubuntu-latest\n",
    );
    const python = { copilot: { packs: ["python"] } };

    pushDown(fs, python, "reference");
    const first = fileIds(fs);
    const detected = detectPushDownIntegration({ fs, ...READ });
    const failing = validatePushDownIntegration({
      fs,
      destinationRoot: "/dest",
    });

    expect(first).toEqual([
      "existing-ci-workflow:.github/workflows/ci.yml",
      "missing-required-check:.github/workflows/drm-copilot-ci.yml#CI Required Gate",
      "workflow-name-collision:.github/workflows/ci.yml",
    ]);
    expect(detected.conflicts.map((item) => item.id)).toEqual(first);
    expect(detected.conflicts.every((item) => item.source === "detect")).toBe(
      true,
    );
    expect(failing.verdict).toBe("fail");
    expect(failing.rules[2]?.status).toBe("fail");

    // Decision keep-both-workflows: rename the existing workflow only.
    fs.seedFile(
      "/dest/.github/workflows/ci.yml",
      "name: Legacy CI\non: push\njobs:\n  build:\n    name: Build\n    runs-on: ubuntu-latest\n",
    );
    pushDown(fs, python);
    const passing = validatePushDownIntegration({
      fs,
      destinationRoot: "/dest",
    });

    expect(fs.isFile("/dest/.github/workflows/drm-copilot-ci.yml")).toBe(true);
    expect(passing.verdict).toBe("pass");
    expect(fileIds(fs)).toEqual([
      "existing-ci-workflow:.github/workflows/ci.yml",
    ]);
  });

  it("S44 positive: a destination with no prior workflow rewrites the file with items [] once its only item is resolved", () => {
    const fs = seed();
    pushDown(fs, { codex: {} });
    fs.seedFile("/dest/AGENTS.md", "local edit\n");
    pushDown(fs, { codex: {} });
    expect(fileIds(fs)).toEqual(["destination-edited-file:AGENTS.md"]);

    fs.seedFile("/dest/AGENTS.md", "agents\n");
    pushDown(fs, { codex: {} });

    expect(fileIds(fs)).toEqual([]);
  });

  it("S44 negative: without the resolution edit, a second push-down keeps the collision and validate still fails", () => {
    const fs = seed();
    fs.seedFile("/dest/.github/workflows/ci.yml", "name: CI\non: push\n");
    const python = { copilot: { packs: ["python"] } };

    pushDown(fs, python, "reference");
    pushDown(fs, python);

    expect(fileIds(fs)).toContain(
      "workflow-name-collision:.github/workflows/ci.yml",
    );
    expect(
      validatePushDownIntegration({ fs, destinationRoot: "/dest" }).verdict,
    ).toBe("fail");
  });
});
