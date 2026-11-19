/**
 * Unit tests for the integration-needed item model (issue #1051, S2 to S9).
 */

import {
  createIntegrationItem,
  DETAIL_KEYS_BY_KIND,
  formatIntegrationItemId,
  INTEGRATION_ITEM_KINDS,
  INTEGRATION_NEEDED_RELATIVE_PATH,
  INTEGRATION_NEEDED_SCHEMA_VERSION,
  type IntegrationItem,
  mergeIntegrationItems,
  renderIntegrationNeeded,
  RESOLUTION_OPTIONS_BY_KIND,
} from "../../../src/lib/push-down-integration/integration-items";

/** One item of every kind, with realistic detail values. */
function itemOfEveryKind(): IntegrationItem[] {
  return [
    createIntegrationItem(
      "workflow-name-collision",
      ".github/workflows/ci.yml",
      "push-down",
      { existing_name: "CI" },
    ),
    createIntegrationItem(
      "existing-ci-workflow",
      ".github/workflows/ci.yml",
      "push-down",
    ),
    createIntegrationItem(
      "job-name-overlap",
      ".github/workflows/b.yml",
      "detect",
      {
        job_id: "python",
        matched: "python",
      },
    ),
    createIntegrationItem(
      "missing-required-check",
      ".github/workflows/drm-copilot-ci.yml",
      "push-down",
      {
        context: "CI Required Gate",
        workflow_file: ".github/workflows/drm-copilot-ci.yml",
      },
    ),
    createIntegrationItem(
      "version-matrix-difference",
      ".github/workflows/b.yml",
      "push-down",
      {
        job_id: "build",
        key: "node-version",
        found: ["20"],
        expected: "26.13.0",
      },
    ),
    createIntegrationItem(
      "destination-edited-file",
      ".claude/hooks/a.ps1",
      "push-down",
      {
        is_hook: true,
      },
    ),
    createIntegrationItem("unmanaged-conflict", "AGENTS.md", "push-down"),
    createIntegrationItem(
      "deleted-locally",
      ".agents/skills/x/SKILL.md",
      "push-down",
    ),
    createIntegrationItem(
      "yaml-unsupported",
      ".github/workflows/c.yml",
      "detect",
      {
        line: 4,
        construct: "anchor",
      },
    ),
  ];
}

/** Parse rendered text into a plain record. */
function parse(text: string): Record<string, unknown> {
  return JSON.parse(text) as Record<string, unknown>;
}

describe("integration-needed item model", () => {
  it("S2 positive: renders exactly items, payload_version and schema_version", () => {
    const document = parse(renderIntegrationNeeded(itemOfEveryKind(), "9.8.7"));

    expect(Object.keys(document).sort()).toEqual([
      "items",
      "payload_version",
      "schema_version",
    ]);
    expect(document["schema_version"]).toBe("1.0.0");
    expect(INTEGRATION_NEEDED_SCHEMA_VERSION).toBe("1.0.0");
    expect(document["payload_version"]).toBe("9.8.7");
    expect(INTEGRATION_NEEDED_RELATIVE_PATH).toBe(
      ".push-down-integration-needed.json",
    );
  });

  it("S2 negative: a different payload version changes payload_version", () => {
    const first = parse(renderIntegrationNeeded([], "1.0.0"));
    const second = parse(renderIntegrationNeeded([], "2.0.0"));

    expect(second["payload_version"]).not.toBe(first["payload_version"]);
  });

  it("S3 positive: each item has exactly the six item keys and its source", () => {
    for (const item of itemOfEveryKind()) {
      expect(Object.keys(item).sort()).toEqual([
        "detail",
        "id",
        "kind",
        "path",
        "resolution_options",
        "source",
      ]);
    }
    expect(itemOfEveryKind()[2]?.source).toBe("detect");
    expect(itemOfEveryKind()[0]?.source).toBe("push-down");
  });

  it("S3 negative: a detail with an extra or a missing key is rejected", () => {
    expect(() =>
      createIntegrationItem("unmanaged-conflict", "AGENTS.md", "push-down", {
        extra: "x",
      }),
    ).toThrow(/detail keys/);
    expect(() =>
      createIntegrationItem("destination-edited-file", "a.md", "push-down"),
    ).toThrow(/detail keys/);
  });

  it("S4 positive: every kind carries its ordered options and its detail keys", () => {
    expect(INTEGRATION_ITEM_KINDS).toHaveLength(9);
    for (const item of itemOfEveryKind()) {
      expect(item.resolution_options).toEqual(
        RESOLUTION_OPTIONS_BY_KIND[item.kind],
      );
      expect(Object.keys(item.detail).sort()).toEqual([
        ...DETAIL_KEYS_BY_KIND[item.kind],
      ]);
    }
    expect(RESOLUTION_OPTIONS_BY_KIND["existing-ci-workflow"]).toEqual([
      "keep-both-workflows",
      "retire-existing-workflow",
    ]);
    expect(RESOLUTION_OPTIONS_BY_KIND["yaml-unsupported"]).toEqual([
      "rewrite-in-supported-subset",
    ]);
  });

  it("S4 negative: the detail keys of another kind are rejected", () => {
    expect(() =>
      createIntegrationItem(
        "job-name-overlap",
        ".github/workflows/b.yml",
        "detect",
        {
          context: "x",
          workflow_file: "y",
        },
      ),
    ).toThrow(/job_id, matched/);
  });

  it("S5 positive: ids carry a discriminator for repeatable kinds", () => {
    expect(itemOfEveryKind().map((item) => item.id)).toEqual([
      "workflow-name-collision:.github/workflows/ci.yml",
      "existing-ci-workflow:.github/workflows/ci.yml",
      "job-name-overlap:.github/workflows/b.yml#python",
      "missing-required-check:.github/workflows/drm-copilot-ci.yml#CI Required Gate",
      "version-matrix-difference:.github/workflows/b.yml#build.node-version",
      "destination-edited-file:.claude/hooks/a.ps1",
      "unmanaged-conflict:AGENTS.md",
      "deleted-locally:.agents/skills/x/SKILL.md",
      "yaml-unsupported:.github/workflows/c.yml#L4",
    ]);
  });

  it("S5 negative: kinds without a discriminator never carry '#'", () => {
    const plain = itemOfEveryKind().filter((item) =>
      [
        "workflow-name-collision",
        "existing-ci-workflow",
        "destination-edited-file",
        "unmanaged-conflict",
        "deleted-locally",
      ].includes(item.kind),
    );

    expect(plain.every((item) => !item.id.includes("#"))).toBe(true);
    expect(formatIntegrationItemId("unmanaged-conflict", "a")).toBe(
      "unmanaged-conflict:a",
    );
  });

  it("S6 positive: merging sorts by id in code-point order", () => {
    const merged = mergeIntegrationItems([...itemOfEveryKind()].reverse());

    const ids = merged.map((item) => item.id);
    expect(ids).toEqual([...ids].sort());
    expect(ids[0]).toBe("deleted-locally:.agents/skills/x/SKILL.md");
  });

  it("S6 negative: two sources with the same id keep one item, the first", () => {
    const fromCollisions = createIntegrationItem(
      "workflow-name-collision",
      ".github/workflows/ci.yml",
      "push-down",
      { existing_name: "CI" },
    );
    const fromCore = createIntegrationItem(
      "workflow-name-collision",
      ".github/workflows/ci.yml",
      "push-down",
      { existing_name: "Other" },
    );

    const merged = mergeIntegrationItems([fromCollisions], [fromCore]);

    expect(merged).toEqual([fromCollisions]);
  });

  it("S8 positive: renders sorted keys, two-space indentation and one trailing LF", () => {
    const text = renderIntegrationNeeded(
      [createIntegrationItem("unmanaged-conflict", "AGENTS.md", "push-down")],
      "1.0.0",
    );

    expect(text).toBe(
      [
        "{",
        '  "items": [',
        "    {",
        '      "detail": {},',
        '      "id": "unmanaged-conflict:AGENTS.md",',
        '      "kind": "unmanaged-conflict",',
        '      "path": "AGENTS.md",',
        '      "resolution_options": [',
        '        "adopt-payload",',
        '        "declare-destination-owned"',
        "      ],",
        '      "source": "push-down"',
        "    }",
        "  ],",
        '  "payload_version": "1.0.0",',
        '  "schema_version": "1.0.0"',
        "}",
        "",
      ].join("\n"),
    );
  });

  it("S8 negative: the rendering differs from an unsorted serialization", () => {
    const items = [
      createIntegrationItem("unmanaged-conflict", "AGENTS.md", "push-down"),
    ];
    const unsorted = `${JSON.stringify(
      { schema_version: "1.0.0", payload_version: "1.0.0", items },
      null,
      2,
    )}\n`;

    const rendered = renderIntegrationNeeded(items, "1.0.0");

    expect(rendered).not.toBe(unsorted);
    expect(rendered.includes("\r")).toBe(false);
    expect(rendered.endsWith("}\n")).toBe(true);
    expect(rendered.endsWith("\n\n")).toBe(false);
  });

  it("S9 positive: a rendered file holds no root part, no absolute path and no date-time", () => {
    const root = "/dest/user-x";
    const items = itemOfEveryKind();

    const text = renderIntegrationNeeded(items, "9.8.7");

    expect(text).not.toContain("/dest");
    expect(text).not.toContain("user-x");
    expect(text).not.toMatch(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/);
    expect(text).not.toContain(root);
    for (const item of items) {
      expect(item.path.startsWith("/")).toBe(false);
    }
  });

  it.each([
    ["an absolute path", "/dest/user-x/AGENTS.md"],
    ["a drive letter", "C:/repo/AGENTS.md"],
    ["a UNC prefix", "\\\\server\\share\\a.md"],
    ["a '..' segment", "docs/../AGENTS.md"],
  ])("S9 negative: rejects an item path with %s", (_label, path) => {
    expect(() =>
      createIntegrationItem("unmanaged-conflict", path, "push-down"),
    ).toThrow(/Invalid integration item path/);
  });
});
