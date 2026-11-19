/**
 * Harness-level tests of the destination CI workflows (issue #1050).
 *
 * Every test seeds fresh in-memory bundles through `seedThreeBundles` plus the
 * CI bundle, whose text is read once, read-only, from the tracked
 * `resources/ci-workflows/` folder. No test writes to disk.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import {
  hashPayloadText,
  parseDestinationManifest,
  renderDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";
import {
  pushDownHarness,
  type PushDownHarnessOptions,
} from "../../../src/lib/push-down/push-down-harness";
import { type InMemoryPushDownFileSystem } from "./push-down.test-helpers";
import {
  SEED_EXTENSION_ROOT,
  seedThreeBundles,
  snapshotTree,
} from "./push-down-pipeline.test-helpers";

const RESOURCES = join(__dirname, "..", "..", "..", "resources");
const CI_BUNDLE_FILES = [
  "ci-workflows/caller/drm-copilot-ci.template.yml",
  "ci-workflows/caller/jobs/python.yml",
  "ci-workflows/caller/jobs/powershell.yml",
  "ci-workflows/caller/jobs/typescript.yml",
  "ci-workflows/caller/jobs/dotnet.yml",
  "ci-workflows/ci-required-checks.json",
  "ci-workflows/Set-CiRequiredChecks.ps1",
  "ci-workflows/workflows/harness-python.yml",
  "ci-workflows/workflows/harness-powershell.yml",
  "ci-workflows/workflows/harness-typescript.yml",
  "ci-workflows/workflows/harness-dotnet.yml",
] as const;
const CI_BUNDLE_TEXT: ReadonlyMap<string, string> = new Map(
  CI_BUNDLE_FILES.map((path) => [
    path,
    readFileSync(join(RESOURCES, ...path.split("/")), "utf8"),
  ]),
);

const CALLER = ".github/workflows/drm-copilot-ci.yml";
const DATA = ".github/drm-copilot/ci-required-checks.json";
const COMMAND = ".github/drm-copilot/Set-CiRequiredChecks.ps1";
const DATA_TEXT =
  JSON.stringify(
    {
      required_contexts: ["CI Required Gate"],
      schema_version: "1.0.0",
      workflow: "CI",
      workflow_file: ".github/workflows/drm-copilot-ci.yml",
    },
    null,
    2,
  ) + "\n";

/** Seed the three bundles plus the CI bundle. */
function seed(): InMemoryPushDownFileSystem {
  const fs = seedThreeBundles();
  for (const [path, text] of CI_BUNDLE_TEXT) {
    fs.seedFile(`${SEED_EXTENSION_ROOT}/resources/${path}`, text);
  }
  return fs;
}

/** Run the harness against `/dest`. */
function run(
  fs: InMemoryPushDownFileSystem,
  ecosystems: PushDownHarnessOptions["ecosystems"],
  extra: Partial<PushDownHarnessOptions> = {},
) {
  return pushDownHarness({
    extensionRoot: SEED_EXTENSION_ROOT,
    destinationRoot: "/dest",
    fs,
    ecosystems,
    listEntries: () => [],
    ...extra,
  });
}

/** Read the destination manifest. */
function manifest(fs: InMemoryPushDownFileSystem) {
  return parseDestinationManifest(
    fs.readTextFile("/dest/.push-down-manifest.json"),
  );
}

/** Return the report action of a path. */
function action(
  result: ReturnType<typeof run>,
  path: string,
): string | undefined {
  return result.report.files.find((file) => file.path === path)?.action;
}

/** Return the CI paths a report lists. */
function ciPaths(result: ReturnType<typeof run>): string[] {
  return result.report.files
    .map((file) => file.path)
    .filter(
      (path) =>
        path.startsWith(".github/drm-copilot/") ||
        path.startsWith(".github/workflows/drm-copilot-"),
    );
}

const PYTHON = { copilot: { packs: ["python"] } } as const;

describe("pushDownHarness ci_workflows", () => {
  it("plans no CI path when ci_workflows is omitted and no data-file entry exists", () => {
    const fs = seed();

    const result = run(fs, PYTHON);

    expect(ciPaths(result)).toEqual([]);
    expect(fs.listFiles("/dest/.github/workflows")).toEqual([]);
  });

  it("explicit off plans no CI file", () => {
    const fs = seed();

    const result = run(fs, PYTHON, { ciWorkflows: "off" });

    expect(ciPaths(result)).toEqual([]);
    expect(fs.isFile(`/dest/${DATA}`)).toBe(false);
  });

  it("reuses recorded reference mode", () => {
    const fs = seed();
    run(fs, PYTHON, { ciWorkflows: "reference" });

    const second = run(fs, PYTHON);

    expect(ciPaths(second).sort()).toEqual([COMMAND, DATA, CALLER].sort());
    expect(action(second, CALLER)).toBe("unchanged");
  });

  it("reuses recorded copy mode", () => {
    const fs = seed();
    run(fs, PYTHON, { ciWorkflows: "copy" });

    const second = run(fs, PYTHON);

    expect(action(second, ".github/workflows/drm-copilot-python.yml")).toBe(
      "unchanged",
    );
    expect(fs.readTextFile(`/dest/${CALLER}`)).toContain(
      "uses: ./.github/workflows/drm-copilot-python.yml",
    );
  });

  it("explicit off after a delivery leaves the CI files in place as orphaned", () => {
    const fs = seed();
    run(fs, PYTHON, { ciWorkflows: "copy" });
    const delivered = [
      CALLER,
      DATA,
      COMMAND,
      ".github/workflows/drm-copilot-python.yml",
    ];

    const second = run(fs, PYTHON, { ciWorkflows: "off" });

    for (const path of delivered) {
      expect(action(second, path)).toBe("orphaned");
      expect(fs.isFile(`/dest/${path}`)).toBe(true);
    }
  });

  it("rejects a selection union holding both C# variants", () => {
    const fs = seed();
    fs.seedFile(
      "/dest/.push-down-manifest.json",
      renderDestinationManifest({
        schemaVersion: "1.0.0",
        payloadVersion: "9.8.7",
        selection: {
          claude: { packs: ["core", "csharp-modern"], csharpVariant: "modern" },
          codex: { packs: ["core", "csharp"], csharpVariant: "legacy" },
        },
        files: {},
      }),
    );

    expect(() => run(fs, PYTHON, { ciWorkflows: "reference" })).toThrow(
      "C# mutual exclusion violated",
    );
    expect(fs.writtenPaths).toEqual([]);
  });

  it("reference mode plans no drm-copilot copy", () => {
    const fs = seed();

    const result = run(fs, { claude: {} }, { ciWorkflows: "reference" });

    expect(ciPaths(result).sort()).toEqual([COMMAND, DATA, CALLER].sort());
    const caller = fs.readTextFile(`/dest/${CALLER}`);
    expect(caller).toContain(
      "uses: drmoisan/drm-copilot/.github/workflows/harness-python.yml@v9.8.7",
    );
    expect(caller).toContain("harness_ref: v9.8.7");
  });

  it("copy mode writes selected copies with shared-layer manifest entries", () => {
    const fs = seed();

    run(fs, { claude: { packs: ["python"] } }, { ciWorkflows: "copy" });

    const recorded = manifest(fs);
    expect(recorded.schemaVersion).toBe("1.0.0");
    const expected: Array<readonly [string, string]> = [
      [CALLER, "core"],
      [DATA, "core"],
      [".github/workflows/drm-copilot-python.yml", "python"],
    ];
    for (const [path, pack] of expected) {
      expect(recorded.files[path]).toEqual({
        layer: "shared",
        pack,
        sha256: hashPayloadText(fs.readTextFile(`/dest/${path}`)),
      });
    }
    expect(
      fs.readTextFile("/dest/.github/workflows/drm-copilot-python.yml"),
    ).toBe(CI_BUNDLE_TEXT.get("ci-workflows/workflows/harness-python.yml"));
    expect(
      fs.isFile("/dest/.github/workflows/drm-copilot-powershell.yml"),
    ).toBe(false);
  });

  it.each(["reference", "copy"] as const)(
    "delivers Set-CiRequiredChecks.ps1 byte-equal with layer shared and pack core in reference and copy modes (%s)",
    (mode) => {
      const fs = seed();

      run(fs, PYTHON, { ciWorkflows: mode });

      expect(fs.readTextFile(`/dest/${COMMAND}`)).toBe(
        CI_BUNDLE_TEXT.get("ci-workflows/Set-CiRequiredChecks.ps1"),
      );
      expect(manifest(fs).files[COMMAND]).toMatchObject({
        layer: "shared",
        pack: "core",
      });
    },
  );

  it("writes the data file exactly in reference, copy, and withheld-caller runs", () => {
    const reference = seed();
    const copy = seed();
    const withheld = seed();
    withheld.seedFile("/dest/.github/workflows/build.yml", "name: CI\n");

    run(reference, PYTHON, { ciWorkflows: "reference" });
    run(copy, PYTHON, { ciWorkflows: "copy" });
    run(withheld, PYTHON, { ciWorkflows: "reference" });

    for (const fs of [reference, copy, withheld]) {
      expect(fs.readTextFile(`/dest/${DATA}`)).toBe(DATA_TEXT);
    }
    expect(withheld.isFile(`/dest/${CALLER}`)).toBe(false);
  });

  it("second identical apply reports every CI file unchanged", () => {
    const fs = seed();
    run(fs, PYTHON, { ciWorkflows: "copy" });

    const second = run(fs, PYTHON, { ciWorkflows: "copy" });

    const paths = ciPaths(second);
    expect(paths.length).toBe(4);
    for (const path of paths) {
      expect(action(second, path)).toBe("unchanged");
    }
  });

  it("dry run writes no file and no manifest", () => {
    const fs = seed();
    const before = snapshotTree(fs, "/dest");

    const result = run(fs, PYTHON, { ciWorkflows: "copy", dryRun: true });

    expect(action(result, CALLER)).toBe("create");
    expect(snapshotTree(fs, "/dest")).toEqual(before);
    expect(fs.isFile("/dest/.push-down-manifest.json")).toBe(false);
  });

  it("a payload_version change reports an unedited caller update and rewrites it", () => {
    const fs = seed();
    run(fs, PYTHON, { ciWorkflows: "reference" });
    fs.seedFile(`${SEED_EXTENSION_ROOT}/package.json`, '{"version":"9.9.0"}');

    const second = run(fs, PYTHON);

    expect(action(second, CALLER)).toBe("update");
    expect(fs.readTextFile(`/dest/${CALLER}`)).toContain("@v9.9.0");
  });

  it.each([DATA, CALLER])(
    "reports unmanaged-conflict at a CI path even with overwriteUnmanaged true (%s)",
    (path) => {
      const fs = seed();
      fs.seedFile(`/dest/${path}`, "local\n");

      const result = run(fs, PYTHON, {
        ciWorkflows: "reference",
        overwriteUnmanaged: true,
      });

      expect(action(result, path)).toBe("unmanaged-conflict");
      expect(fs.readTextFile(`/dest/${path}`)).toBe("local\n");
    },
  );

  it("keeps an edited managed caller as conflict", () => {
    const fs = seed();
    run(fs, PYTHON, { ciWorkflows: "reference" });
    fs.seedFile(`/dest/${CALLER}`, "name: CI\n# edited\n");

    const second = run(fs, PYTHON);

    expect(action(second, CALLER)).toBe("conflict");
    expect(fs.readTextFile(`/dest/${CALLER}`)).toBe("name: CI\n# edited\n");
  });

  it("writes no workflows path other than the caller and selected copies", () => {
    const fs = seed();
    fs.seedFile("/dest/.github/workflows/other.yml", "name: Other\n");

    run(fs, PYTHON, { ciWorkflows: "copy" });

    const written = fs.writtenPaths.filter((path) =>
      path.startsWith("/dest/.github/workflows/"),
    );
    expect([...new Set(written)].sort()).toEqual([
      `/dest/${CALLER}`,
      "/dest/.github/workflows/drm-copilot-python.yml",
    ]);
    expect(fs.readTextFile("/dest/.github/workflows/other.yml")).toBe(
      "name: Other\n",
    );
  });

  it("withholds the caller when another workflow is named CI, including in a dry run", () => {
    const fs = seed();
    fs.seedFile(
      "/dest/.github/workflows/build.yml",
      'name: "CI"\r\non: push\r\n',
    );

    const dryRun = run(fs, PYTHON, { ciWorkflows: "copy", dryRun: true });
    const apply = run(fs, PYTHON, { ciWorkflows: "copy" });

    for (const result of [dryRun, apply]) {
      expect(
        result.warnings.some(
          (line) =>
            line.startsWith("push-down conflict:") &&
            line.includes(".github/workflows/build.yml"),
        ),
      ).toBe(true);
      expect(action(result, CALLER)).toBeUndefined();
    }
    expect(fs.isFile(`/dest/${CALLER}`)).toBe(false);
    expect(fs.readTextFile(`/dest/${DATA}`)).toBe(DATA_TEXT);
    expect(fs.isFile("/dest/.github/workflows/drm-copilot-python.yml")).toBe(
      true,
    );
  });
});
