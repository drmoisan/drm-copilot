/**
 * Unit tests for the shared conflict core and the detect result (issue #1051,
 * S24 to S33). Every fixture is an in-memory destination under `/dest`.
 */

import {
  detectPushDownIntegration,
  evaluateDestinationConflicts,
} from "../../../src/lib/push-down-integration/integration-detect";
import {
  CALLER_TEXT,
  DATA_FILE_TEXT,
  DEST,
  destination,
  EXT,
  manifestText,
  type RecordingIntegrationFileSystem,
  seedHarnessWorkflows,
} from "./integration-test-helpers";

const DATA = ".github/drm-copilot/ci-required-checks.json";
const CALLER = ".github/workflows/drm-copilot-ci.yml";

/** Detect over a destination. */
function detect(fs: RecordingIntegrationFileSystem) {
  return detectPushDownIntegration({
    fs,
    destinationRoot: DEST,
    extensionRoot: EXT,
  });
}

/** Ids of the detect conflicts. */
function conflictIds(fs: RecordingIntegrationFileSystem): string[] {
  return detect(fs).conflicts.map((item) => item.id);
}

/** A workflow with one job that sets a step `with` version value. */
function versionWorkflow(key: string, value: string): string {
  return [
    "name: Build",
    "on: push",
    "jobs:",
    "  build:",
    "    steps:",
    "      - with:",
    `          ${key}: ${value}`,
    "",
  ].join("\n");
}

describe("detectPushDownIntegration", () => {
  it("S24 positive: returns ecosystems, sorted workflows, conflicts and the file summary", () => {
    const fs = destination({
      ".github/workflows/zeta.yaml":
        "name: Zeta\non: push\njobs:\n  z:\n    needs: a\n",
      ".github/workflows/alpha.yml":
        "name: Alpha\non: [push]\njobs:\n  a:\n    name: A\n",
      ".github/workflows/bad.yml": "name: x\non: *alias\n",
    });

    const result = detect(fs);

    expect(Object.keys(result).sort()).toEqual([
      "conflicts",
      "ecosystems",
      "integration_needed",
      "workflows",
    ]);
    expect(result.workflows).toEqual([
      {
        path: ".github/workflows/alpha.yml",
        name: "Alpha",
        triggers: ["push"],
        parse: "ok",
        findings: [],
        jobs: [{ id: "a", name: "A", uses: null, needs: [] }],
      },
      {
        path: ".github/workflows/bad.yml",
        name: null,
        triggers: [],
        parse: "unsupported",
        findings: [{ line: 2, construct: "alias" }],
        jobs: [],
      },
      {
        path: ".github/workflows/zeta.yaml",
        name: "Zeta",
        triggers: ["push"],
        parse: "ok",
        findings: [],
        jobs: [{ id: "z", name: null, uses: null, needs: ["a"] }],
      },
    ]);
    expect(result.conflicts.every((item) => item.source === "detect")).toBe(
      true,
    );
  });

  it("S24 positive: reports an error finding with its line and message", () => {
    const fs = destination({ ".github/workflows/x.yml": 'name: "open\n' });

    expect(detect(fs).workflows[0]).toMatchObject({
      parse: "error",
      findings: [{ line: 1, message: "unterminated quoted scalar" }],
    });
  });

  it("S24 negative: files outside the top level of .github/workflows or without a YAML extension are not listed", () => {
    const fs = destination({
      ".github/workflows/README.md": "x\n",
      ".github/workflows/nested/x.yml": "name: x\n",
      ".github/other.yml": "name: x\n",
    });

    expect(detect(fs).workflows).toEqual([]);
  });

  it("S25 positive: raises workflow-name-collision for another workflow named as the data file's workflow", () => {
    const fs = destination({
      [DATA]: DATA_FILE_TEXT,
      ".github/workflows/build.yml": "name: CI\non: push\n",
    });

    const item = detect(fs).conflicts.find(
      (entry) => entry.kind === "workflow-name-collision",
    );

    expect(item).toEqual({
      detail: { existing_name: "CI" },
      id: "workflow-name-collision:.github/workflows/build.yml",
      kind: "workflow-name-collision",
      path: ".github/workflows/build.yml",
      resolution_options: [
        "rename-existing-workflow",
        "retire-existing-workflow",
      ],
      source: "detect",
    });
  });

  it.each([
    ["absent", {}],
    ["invalid", { [DATA]: '{"schema_version": "2.0.0"}' }],
  ])("S25 negative: no collision when the data file is %s", (_label, files) => {
    const fs = destination({
      ...files,
      ".github/workflows/build.yml": "name: CI\non: push\n",
    });

    expect(
      conflictIds(fs).some((id) => id.startsWith("workflow-name-collision")),
    ).toBe(false);
  });

  it("S26 positive: raises existing-ci-workflow for ci.yml and ci.yaml beside the data file", () => {
    const fs = destination({
      [DATA]: DATA_FILE_TEXT,
      ".github/workflows/ci.yml": "name: Legacy\non: push\n",
      ".github/workflows/ci.yaml": "name: Other\non: push\n",
    });

    expect(
      conflictIds(fs).filter((id) => id.startsWith("existing-ci-workflow")),
    ).toEqual([
      "existing-ci-workflow:.github/workflows/ci.yaml",
      "existing-ci-workflow:.github/workflows/ci.yml",
    ]);
  });

  it("S26 negative: no existing-ci-workflow without the data file or when ci.yml is the workflow_file", () => {
    const without = destination({ ".github/workflows/ci.yml": "name: CI\n" });
    const managed = destination({
      [DATA]: DATA_FILE_TEXT.replace("drm-copilot-ci.yml", "ci.yml"),
      ".github/workflows/ci.yml": CALLER_TEXT,
    });

    expect(conflictIds(without)).toEqual([]);
    expect(
      conflictIds(managed).some((id) => id.startsWith("existing-ci-workflow")),
    ).toBe(false);
  });

  it("S27 positive: raises job-name-overlap for a job id or name in the pushed set", () => {
    const fs = destination({
      [DATA]: DATA_FILE_TEXT,
      [CALLER]: CALLER_TEXT,
      ".github/workflows/other.yml": [
        "name: Other",
        "on: push",
        "jobs:",
        "  python:",
        "    name: Py",
        "  gate:",
        "    name: CI Required Gate",
        "",
      ].join("\n"),
    });

    const items = detect(fs).conflicts.filter(
      (item) => item.kind === "job-name-overlap",
    );

    expect(items.map((item) => [item.id, item.detail])).toEqual([
      [
        "job-name-overlap:.github/workflows/other.yml#gate",
        { job_id: "gate", matched: "CI Required Gate" },
      ],
      [
        "job-name-overlap:.github/workflows/other.yml#python",
        { job_id: "python", matched: "python" },
      ],
    ]);
  });

  it("S27 positive: uses required_contexts as the pushed set when the caller is absent", () => {
    const fs = destination({
      [DATA]: DATA_FILE_TEXT,
      ".github/workflows/other.yml":
        "name: Other\non: push\njobs:\n  g:\n    name: CI Required Gate\n",
    });

    expect(conflictIds(fs)).toContain(
      "job-name-overlap:.github/workflows/other.yml#g",
    );
  });

  it("S27 negative: no overlap for distinct jobs, a pushed copy, or without the data file", () => {
    const distinct = destination({
      [DATA]: DATA_FILE_TEXT,
      [CALLER]: CALLER_TEXT,
      ".github/workflows/other.yml":
        "name: Other\non: push\njobs:\n  lint:\n    name: Lint\n",
      ".github/workflows/drm-copilot-python.yml":
        "name: Copy\non: push\njobs:\n  python:\n    name: Python QC\n",
    });
    const noData = destination({
      ".github/workflows/other.yml":
        "name: Other\njobs:\n  python:\n    name: CI Required Gate\n",
    });

    expect(
      conflictIds(distinct).some((id) => id.startsWith("job-name-overlap")),
    ).toBe(false);
    expect(conflictIds(noData)).toEqual([]);
  });

  it("S28 positive: raises missing-required-check per context the caller does not produce", () => {
    const fs = destination({
      [DATA]: DATA_FILE_TEXT.replace(
        '"CI Required Gate"',
        '"CI Required Gate",\n    "Extra"',
      ),
      [CALLER]: CALLER_TEXT,
    });

    expect(conflictIds(fs)).toEqual([
      "missing-required-check:.github/workflows/drm-copilot-ci.yml#Extra",
    ]);
  });

  it("S28 positive: raises every context when the workflow_file is absent", () => {
    const fs = destination({ [DATA]: DATA_FILE_TEXT });

    expect(detect(fs).conflicts).toEqual([
      expect.objectContaining({
        kind: "missing-required-check",
        path: CALLER,
        detail: { context: "CI Required Gate", workflow_file: CALLER },
      }),
    ]);
  });

  it("S28 negative: no missing check when a job id produces the context, or for an unusable workflow_file", () => {
    const byId = destination({
      [DATA]: DATA_FILE_TEXT.replace('"CI Required Gate"', '"gate"'),
      [CALLER]: "name: CI\non: pull_request\njobs:\n  gate:\n    runs-on: x\n",
    });
    const absolute = destination({
      [DATA]: DATA_FILE_TEXT.replace(
        ".github/workflows/drm-copilot-ci.yml",
        "/abs/ci.yml",
      ),
    });

    expect(conflictIds(byId)).toEqual([]);
    expect(conflictIds(absolute)).toEqual([]);
  });

  it("S29 positive: raises version-matrix-difference against the selected pack's harness reference", () => {
    const fs = destination({
      ".push-down-manifest.json": manifestText({
        claude: { packs: ["core", "typescript"] },
      }),
      ".github/workflows/build.yml": versionWorkflow("node-version", "20"),
    });
    seedHarnessWorkflows(fs);

    expect(detect(fs).conflicts).toEqual([
      expect.objectContaining({
        id: "version-matrix-difference:.github/workflows/build.yml#build.node-version",
        detail: {
          job_id: "build",
          key: "node-version",
          found: ["20"],
          expected: "26.13.0",
        },
      }),
    ]);
  });

  it.each([
    [
      "a matching literal",
      ".github/workflows/build.yml",
      "node-version",
      '"26.13.0"',
      ["core", "typescript"],
    ],
    [
      "an expression only",
      ".github/workflows/build.yml",
      "node-version",
      "${{ matrix.node }}",
      ["core", "typescript"],
    ],
    [
      "a key with no reference",
      ".github/workflows/build.yml",
      "python-version",
      "3.11",
      ["core", "python"],
    ],
    [
      "an unselected pack",
      ".github/workflows/build.yml",
      "node-version",
      "20",
      ["core", "python"],
    ],
    ["the caller", CALLER, "node-version", "20", ["core", "typescript"]],
    [
      "a pushed copy",
      ".github/workflows/drm-copilot-typescript.yml",
      "node-version",
      "20",
      ["core", "typescript"],
    ],
  ])(
    "S29 negative: no difference for %s",
    (_label, path, key, value, packs) => {
      const fs = destination({
        ".push-down-manifest.json": manifestText({ claude: { packs } }),
        [path]: versionWorkflow(key, value),
      });
      seedHarnessWorkflows(fs);

      expect(conflictIds(fs)).toEqual([]);
    },
  );

  it("S29 negative: a selection holding both C# variants yields no reference", () => {
    const fs = destination({
      ".push-down-manifest.json": manifestText({
        claude: { packs: ["core", "csharp-modern"] },
        codex: { packs: ["core", "csharp-legacy"] },
      }),
      ".github/workflows/build.yml": versionWorkflow("dotnet-version", "8.0.x"),
    });
    seedHarnessWorkflows(fs);

    expect(conflictIds(fs)).toEqual([]);
  });

  it("S30 positive: raises yaml-unsupported with the line and construct", () => {
    const fs = destination({
      ".github/workflows/a.yml": "name: a\non: push\njobs: &j {}\n",
    });

    expect(detect(fs).conflicts).toEqual([
      expect.objectContaining({
        id: "yaml-unsupported:.github/workflows/a.yml#L3",
        detail: { line: 3, construct: "anchor" },
      }),
    ]);
  });

  it("S30 negative: a workflow inside the subset or with an error raises no yaml-unsupported", () => {
    const fs = destination({
      ".github/workflows/a.yml": "name: a\non: push\n",
      ".github/workflows/b.yml": 'name: "x\n',
    });

    expect(conflictIds(fs)).toEqual([]);
  });

  it.each([
    ["absent", {}, { present: false, item_count: null, parse: "absent" }],
    [
      "ok",
      { ".push-down-integration-needed.json": '{"items": [1, {"x": 2}]}' },
      { present: true, item_count: 2, parse: "ok" },
    ],
    [
      "invalid JSON",
      { ".push-down-integration-needed.json": "{" },
      { present: true, item_count: null, parse: "error" },
    ],
  ])(
    "S31 positive: summarizes a file that is %s",
    (_label, files, expected) => {
      expect(detect(destination(files)).integration_needed).toEqual(expected);
    },
  );

  it("S31 negative: a parsed document without an items list is an error, and items are not interpreted", () => {
    const noList = destination({
      ".push-down-integration-needed.json": '{"items": {}}',
    });
    const odd = destination({
      ".push-down-integration-needed.json": '{"items": ["not an item"]}',
    });

    expect(detect(noList).integration_needed.parse).toBe("error");
    expect(detect(odd).integration_needed).toEqual({
      present: true,
      item_count: 1,
      parse: "ok",
    });
    expect(detect(odd).conflicts).toEqual([]);
  });

  it("S32 positive: detect records no write call across fixtures", () => {
    const fixtures = [
      destination({
        [DATA]: DATA_FILE_TEXT,
        ".github/workflows/ci.yml": "name: CI\n",
      }),
      destination({
        ".github/workflows/a.yml": "on: *x\n",
        "pyproject.toml": "x\n",
      }),
      destination({ ".push-down-integration-needed.json": "{}" }),
    ];

    for (const fs of fixtures) {
      seedHarnessWorkflows(fs);
      detect(fs);
      expect(fs.writeCalls).toEqual([]);
    }
  });

  it("S32 negative: the recording fake records a write, so a writing detect would be caught", () => {
    const fs = destination({});

    fs.writeTextFile(`${DEST}/x.json`, "{}");

    expect(fs.writeCalls).toEqual([`${DEST}/x.json`]);
  });

  it("S33 positive: two calls, and a reverse-ordered listing, return deep-equal results", () => {
    const files = {
      ".push-down-manifest.json": manifestText({
        claude: { packs: ["core", "typescript"] },
      }),
      [DATA]: DATA_FILE_TEXT,
      ".github/workflows/ci.yml":
        "name: CI\non: push\njobs:\n  python:\n    name: P\n",
      ".github/workflows/b.yml": versionWorkflow("node-version", "18"),
      ".github/workflows/c.yml": "on: !tag x\n",
      "pyproject.toml": "x\n",
    };
    const forward = destination(files);
    const reverse = destination(files, true);
    seedHarnessWorkflows(forward);
    seedHarnessWorkflows(reverse);

    const first = detect(forward);

    expect(detect(forward)).toEqual(first);
    expect(detect(reverse)).toEqual(first);
    expect(first.conflicts.length).toBeGreaterThan(3);
  });

  it("S33 negative: different content returns a different result", () => {
    const one = destination({ ".github/workflows/a.yml": "name: A\n" });
    const two = destination({ ".github/workflows/a.yml": "name: B\n" });

    expect(detect(two)).not.toEqual(detect(one));
  });

  it("filters the conflict core by kind and source", () => {
    const fs = destination({
      [DATA]: DATA_FILE_TEXT,
      ".github/workflows/ci.yml": "name: CI\non: push\n",
    });

    const items = evaluateDestinationConflicts({
      fs,
      destinationRoot: DEST,
      extensionRoot: EXT,
      source: "push-down",
      kinds: ["existing-ci-workflow"],
    });

    expect(items.map((item) => [item.kind, item.source])).toEqual([
      ["existing-ci-workflow", "push-down"],
    ]);
  });
});
