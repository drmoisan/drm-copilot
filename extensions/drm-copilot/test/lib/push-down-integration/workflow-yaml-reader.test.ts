/**
 * Unit tests for the workflow YAML subset reader (issue #1051, S15 to S19).
 *
 * Fixtures are built in code; CR LF text is produced by joining lines with
 * CR LF, so no committed fixture depends on line-ending attributes.
 */

import {
  readWorkflowText,
  type WorkflowReadOk,
  type WorkflowReadResult,
} from "../../../src/lib/push-down-integration/workflow-yaml-reader";

/** Join lines with LF and a trailing LF. */
function lf(lines: ReadonlyArray<string>): string {
  return `${lines.join("\n")}\n`;
}

/** Narrow a result to status ok, failing the test otherwise. */
function ok(result: WorkflowReadResult): WorkflowReadOk {
  if (result.status !== "ok") {
    throw new Error(`expected status ok, got ${JSON.stringify(result)}`);
  }
  return result;
}

const SUBSET_TEXT = lf([
  "---",
  "# full-line comment",
  "name: 'Build and test' # trailing comment",
  "on:",
  "  pull_request:",
  '    branches: [main, "epic/**"]',
  "  push: {branches: [main]}",
  "env:",
  '  QUOTED: "a \\"b\\" c"',
  "  SINGLE: 'it''s'",
  "jobs:",
  "  build:",
  "    name: Build",
  "    if: ${{ github.event_name == 'push' }}",
  "    runs-on: ubuntu-latest",
  "    steps:",
  "      - name: Literal",
  "        run: |",
  "          echo one",
  "          echo two",
  "      - name: Folded",
  "        run: >-",
  "          first",
  "          second",
  "      - name: Keep",
  "        run: |+",
  "          kept",
  "",
  "      - name: Strip",
  "        run: >",
  "          folded",
]);

describe("readWorkflowText", () => {
  it("S15 positive: returns ok for text that uses every construct of the subset", () => {
    const result = ok(readWorkflowText(SUBSET_TEXT));

    expect(result.name).toBe("Build and test");
    expect(result.triggers).toEqual(["pull_request", "push"]);
    expect(result.jobs.map((job) => job.id)).toEqual(["build"]);
    expect(result.jobs[0]?.if).toBe("${{ github.event_name == 'push' }}");
  });

  it("S15 negative: returns no ok status for a flow collection that spans lines", () => {
    const result = readWorkflowText(lf(["on: [push,", "  pull_request]"]));

    expect(result.status).not.toBe("ok");
  });

  it.each([
    ["tab-indentation", lf(["on:", "\tpush:"]), 2],
    ["anchor", lf(["on: &triggers push"]), 1],
    ["alias", lf(["name: x", "on: *triggers"]), 2],
    ["tag", lf(["name: !custom x"]), 1],
    ["multiple-documents", lf(["name: a", "---", "name: b"]), 2],
    ["multiple-documents", lf(["name: a", "..."]), 2],
    ["complex-key", lf(["? name", ": x"]), 1],
    ["anchor", lf(["steps:", "  - &step run: x"]), 2],
    ["alias", lf(["needs: [*a]"]), 1],
  ] as const)(
    "S16 positive: reports %s at its 1-based line",
    (construct, text, line) => {
      const result = readWorkflowText(text);

      expect(result).toEqual({
        status: "unsupported",
        finding: { line, construct },
      });
    },
  );

  it("S16 positive: reports the first unsupported construct", () => {
    const result = readWorkflowText(
      lf(["name: x", "on: *alias", "jobs: &anchor {}"]),
    );

    expect(result).toEqual({
      status: "unsupported",
      finding: { line: 2, construct: "alias" },
    });
  });

  it("S16 negative: the same characters inside quoted scalars and block scalars stay ok", () => {
    const result = readWorkflowText(
      lf([
        "name: 'a &b *c !d'",
        "on: push",
        "jobs:",
        "  build:",
        "    steps:",
        "      - run: |",
        "          echo &x *y !z",
        "          ? not a key",
        "          ---",
      ]),
    );

    expect(result.status).toBe("ok");
  });

  it.each([
    [
      "inconsistent indentation",
      lf(["jobs:", "  a:", "    name: x", "   b: y"]),
      4,
    ],
    ["an unterminated quoted scalar", lf(['name: "open']), 1],
    ["an unterminated flow collection", lf(["on: [push"]), 1],
    ["a duplicate key", lf(["name: a", "on: push", "name: b"]), 3],
    ["a duplicate flow key", lf(["on: {push: a, push: b}"]), 1],
  ])("S17 positive: returns error for %s", (_label, text, line) => {
    const result = readWorkflowText(text);

    expect(result.status).toBe("error");
    expect(result).toMatchObject({ line });
    expect(result.status === "error" ? result.message : "").not.toBe("");
  });

  it("S17 negative: the same key in two different mappings is not a duplicate", () => {
    const result = readWorkflowText(
      lf(["jobs:", "  a:", "    name: x", "  b:", "    name: y"]),
    );

    expect(result.status).toBe("ok");
  });

  it("S18 positive: extracts name, sorted triggers and sorted jobs with their fields", () => {
    const result = ok(
      readWorkflowText(
        lf([
          "name: CI",
          "on:",
          "  workflow_dispatch:",
          "  push:",
          "jobs:",
          "  zeta:",
          "    name: Zeta",
          "    uses: ./.github/workflows/reusable.yml",
          "    needs: alpha",
          "  alpha:",
          "    if: always()",
          "    needs: [beta, gamma]",
          "    strategy:",
          "      matrix:",
          "        node: [20, 22]",
          "        os: ubuntu-latest",
          "        include:",
          "          - node: 18",
          "    steps:",
          "      - uses: actions/setup-node@v4",
          "        with:",
          "          node-version: ${{ matrix.node }}",
          "      - uses: actions/setup-python@v5",
          "        with:",
          '          python-version: "3.12"',
          "          poetry-version: 2.1.0",
          "      - with:",
          "          dotnet-version: 8.0.x",
          "          node-version: 20",
        ]),
      ),
    );

    expect(result.name).toBe("CI");
    expect(result.triggers).toEqual(["push", "workflow_dispatch"]);
    expect(result.jobs).toEqual([
      {
        id: "alpha",
        name: null,
        uses: null,
        needs: ["beta", "gamma"],
        if: "always()",
        matrix: { node: ["20", "22"], os: ["ubuntu-latest"] },
        with_versions: {
          "dotnet-version": ["8.0.x"],
          "node-version": ["${{ matrix.node }}", "20"],
          "poetry-version": ["2.1.0"],
          "python-version": ["3.12"],
        },
      },
      {
        id: "zeta",
        name: "Zeta",
        uses: "./.github/workflows/reusable.yml",
        needs: ["alpha"],
        if: null,
        matrix: {},
        with_versions: {
          "dotnet-version": [],
          "node-version": [],
          "poetry-version": [],
          "python-version": [],
        },
      },
    ]);
  });

  it.each([
    ["a string", lf(["on: push"]), ["push"]],
    [
      "a sequence",
      lf(["on:", "  - push", "  - pull_request"]),
      ["pull_request", "push"],
    ],
    ["a compact sequence", lf(["on:", "- push"]), ["push"]],
  ])("S18 positive: normalizes on given as %s", (_label, text, triggers) => {
    expect(ok(readWorkflowText(text)).triggers).toEqual(triggers);
  });

  it("S18 negative: absent values are null or empty lists", () => {
    const result = ok(readWorkflowText(lf(["jobs:", "  only:"])));

    expect(result.name).toBeNull();
    expect(result.triggers).toEqual([]);
    expect(result.jobs[0]).toMatchObject({
      name: null,
      uses: null,
      needs: [],
      if: null,
      matrix: {},
    });
  });

  it("S18 negative: a non-mapping root is an error, not an extraction", () => {
    const result = readWorkflowText(lf(["- a", "- b"]));

    expect(result.status).toBe("error");
  });

  it("S19 positive: LF, CR LF and CR forms of the same text return equal results", () => {
    const lines = SUBSET_TEXT.split("\n");

    const fromLf = readWorkflowText(lines.join("\n"));
    const fromCrLf = readWorkflowText(lines.join("\r\n"));
    const fromCr = readWorkflowText(lines.join("\r"));

    expect(fromCrLf).toEqual(fromLf);
    expect(fromCr).toEqual(fromLf);
  });

  it("S19 negative: an earlier read leaves no state that changes a later read", () => {
    const fresh = readWorkflowText(lf(["name: second"]));
    readWorkflowText(SUBSET_TEXT);
    readWorkflowText(lf(["name: x", "on: *bad"]));

    const later = readWorkflowText(lf(["name: second"]));

    expect(later).toEqual(fresh);
    expect(later).not.toEqual(readWorkflowText(lf(["name: first"])));
  });

  it("reads block scalars with each chomping indicator and a plain continuation", () => {
    const result = ok(
      readWorkflowText(
        lf([
          "name: one",
          "  two",
          "jobs:",
          "  a:",
          "    if: >+",
          "      kept",
          "",
          "  b:",
          "    if: |-",
          "      stripped",
          "  c:",
          "    if: |",
          "  d:",
          "    name: x",
        ]),
      ),
    );

    expect(result.name).toBe("one two");
    expect(result.jobs.map((job) => job.if)).toEqual([
      "kept\n\n",
      "stripped",
      "",
      null,
    ]);
  });

  it("returns ok with empty facts for an empty or comment-only text", () => {
    expect(readWorkflowText("")).toEqual({
      status: "ok",
      name: null,
      triggers: [],
      jobs: [],
    });
    expect(ok(readWorkflowText(lf(["# only", "---"]))).jobs).toEqual([]);
  });

  it.each([
    ["an unsupported block scalar header", lf(["name: |2", "  x"])],
    ["text after a quoted value", lf(['name: "a" b'])],
    ["a missing key", lf(["name: a", "plain"])],
    ["a flow mapping without a colon", lf(["on: {push}"])],
    ["a sequence item among keys", lf(["name: a", "- b"])],
  ])("returns error for %s", (_label, text) => {
    expect(readWorkflowText(text).status).toBe("error");
  });

  it("reads nested sequences, empty items and quoted keys", () => {
    const result = ok(
      readWorkflowText(
        lf([
          '"name": quoted',
          "jobs:",
          "  a:",
          "    needs:",
          "      - - nested",
          "      -",
          "      - # comment",
          "        b",
          "      - 'c'",
          "    steps:",
          "      -",
          "        with:",
          "          node-version: '22'",
        ]),
      ),
    );

    expect(result.name).toBe("quoted");
    expect(result.jobs[0]?.needs).toEqual(["b", "c"]);
    expect(result.jobs[0]?.with_versions["node-version"]).toEqual(["22"]);
  });

  it("keeps expressions and comments opaque in sequence and flow items", () => {
    const result = ok(
      readWorkflowText(
        lf([
          "jobs:",
          "  a:",
          "    needs:",
          "      - ${{ matrix.first }}",
          "      - second # trailing comment",
          "  b:",
          "    needs: [${{ inputs.x }}, plain]",
        ]),
      ),
    );

    expect(result.jobs[0]?.needs).toEqual(["${{ matrix.first }}", "second"]);
    expect(result.jobs[1]?.needs).toEqual(["${{ inputs.x }}", "plain"]);
  });

  it("decodes double-quoted escapes and folds more-indented lines", () => {
    const result = ok(
      readWorkflowText(
        lf([
          'name: "a\\nb\\tc\\"d"',
          "jobs:",
          "  a:",
          "    if: >",
          "      first",
          "        indented",
          "      last",
          "  b:",
          "    if: |+",
          "  c:",
          "    if: {[k]: v}",
        ]),
      ),
    );

    expect(result.name).toBe('a\nb\tc"d');
    expect(result.jobs.map((job) => job.if)).toEqual([
      "first\n  indented\nlast\n",
      "",
      null,
    ]);
  });

  it.each([
    [
      "an over-indented sequence item",
      lf(["on:", "  - a", "  # note", "   - b"]),
      "error",
    ],
    [
      "a document marker inside a sequence",
      lf(["on:", "- a", "---"]),
      "unsupported",
    ],
    ["an empty key", lf(["name: a", ": b"]), "error"],
    [
      "a key line inside a plain continuation",
      lf(["jobs:", "  a:", "    name: x", "      y: z"]),
      "error",
    ],
    [
      "a tab before block scalar content",
      lf(["jobs:", "  a:", "    if: |", "\tx"]),
      "unsupported",
    ],
  ])("returns status %s for %s", (_label, text, status) => {
    expect(readWorkflowText(text).status).toBe(status);
  });
});
