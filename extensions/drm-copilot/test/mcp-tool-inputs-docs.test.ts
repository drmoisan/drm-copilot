/**
 * Tests for the declarative docs tool input tables and resolvers (issue #1036).
 * Every case is in memory; the grammar parity test reads the committed
 * docs-common schema read-only.
 */

import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import * as path from "node:path";

import { DocsHostError } from "../src/docs-command-envelope";
import {
  DOCS_ELEMENT_ID_PATTERN,
  DOCS_IDENTIFIER_PATTERN,
  DOCS_RELATIVE_PATH_PATTERN,
  DOCS_REVISION_PATTERN,
  DOCS_TEXT_PATTERN,
  DOCS_TOOL_INPUT_TABLES,
  DocsInputError,
  matchesDocsGrammar,
  resolveDocsToolInput,
  type DocsToolName,
} from "../src/mcp-tool-inputs-docs";

const ROOT = "/virtual/workspace";
const REVISION = "a".repeat(40);
const ELEMENT = `cli-command-${"b".repeat(64)}`;
const REPO_ROOT = path.resolve(__dirname, "..", "..", "..");
const RESERVED = ["-Command", "-Json", "-Help", "-RepositoryRoot"];

function resolve(toolName: DocsToolName, input: Record<string, unknown>) {
  return resolveDocsToolInput(toolName, { workspace_root: ROOT, ...input });
}

function captureError(action: () => unknown): Error {
  try {
    action();
  } catch (error) {
    if (error instanceof Error) {
      return error;
    }
    throw error;
  }
  throw new Error("Expected the resolver to throw.");
}

/** One maximal accepted input per tool, used by several tests. */
const FULL_INPUTS: ReadonlyArray<
  readonly [DocsToolName, Record<string, unknown>, ReadonlyArray<string>]
> = [
  [
    "run_docs_check",
    { profile: "docs/profile.json", paths: ["docs/a.md", "docs/b.md"] },
    [
      "-Profile",
      "docs/profile.json",
      "-Path",
      "docs/a.md",
      "-Path",
      "docs/b.md",
    ],
  ],
  [
    "run_docs_inventory",
    { revision: REVISION, analyzers: ["python-cli"], profile: "p.json" },
    ["-Profile", "p.json", "-Analyzer", "python-cli", "-Revision", REVISION],
  ],
  ["run_docs_coverage", { profile: "p.json" }, ["-Profile", "p.json"]],
  [
    "update_docs_ledger",
    {
      write: true,
      actor_id: "docs-reconciler",
      actor_kind: "agent",
      target: "Release 2",
      owner: "docs-team",
      rationale: "Covered by the guide.",
      pages: ["docs/guide.md#usage", "docs/ref.md"],
      disposition: "documented",
      element: ELEMENT,
      operation: "set-disposition",
      profile: "p.json",
    },
    [
      "-Profile",
      "p.json",
      "-Operation",
      "set-disposition",
      "-Element",
      ELEMENT,
      "-Disposition",
      "documented",
      "-Page",
      "docs/guide.md#usage",
      "-Page",
      "docs/ref.md",
      "-Rationale",
      "Covered by the guide.",
      "-Owner",
      "docs-team",
      "-Target",
      "Release 2",
      "-ActorKind",
      "agent",
      "-ActorId",
      "docs-reconciler",
      "-Write",
    ],
  ],
  [
    "generate_docs_reference",
    {
      output_directory: "docs/reference",
      snapshot: "docs/snapshot.json",
      profile: "p.json",
    },
    [
      "-Profile",
      "p.json",
      "-Snapshot",
      "docs/snapshot.json",
      "-OutputDirectory",
      "docs/reference",
    ],
  ],
  [
    "validate_docs_artifacts",
    { revision: REVISION, mode: "ledger", profile: "p.json" },
    ["-Profile", "p.json", "-Mode", "ledger", "-Revision", REVISION],
  ],
];

describe("resolveDocsToolInput option mapping", () => {
  it("maps each tool to its subcommand and declarative option order", () => {
    // Arrange: the spec `### Example invocations` inputs.
    const examples: ReadonlyArray<
      readonly [
        DocsToolName,
        Record<string, unknown>,
        string,
        ReadonlyArray<string>,
      ]
    > = [
      [
        "run_docs_check",
        { paths: ["docs/index.md"] },
        "check",
        ["-Path", "docs/index.md"],
      ],
      [
        "run_docs_inventory",
        { analyzers: ["python-cli"] },
        "inventory",
        ["-Analyzer", "python-cli"],
      ],
      ["run_docs_coverage", {}, "coverage", []],
      [
        "update_docs_ledger",
        {
          operation: "sync-refs",
          actor_kind: "agent",
          actor_id: "docs-reconciler",
        },
        "update-ledger",
        [
          "-Operation",
          "sync-refs",
          "-ActorKind",
          "agent",
          "-ActorId",
          "docs-reconciler",
        ],
      ],
      [
        "generate_docs_reference",
        { output_directory: "docs/reference" },
        "generate-reference",
        ["-OutputDirectory", "docs/reference"],
      ],
      [
        "validate_docs_artifacts",
        { mode: "docs-complete", revision: REVISION },
        "validate",
        ["-Mode", "docs-complete", "-Revision", REVISION],
      ],
    ];

    for (const [toolName, input, subcommand, options] of examples) {
      // Act
      const resolved = resolve(toolName, input);

      // Assert
      expect(resolved).toEqual({ workspaceRoot: ROOT, subcommand, options });
    }
    for (const [toolName, input, options] of FULL_INPUTS) {
      expect(resolve(toolName, input).options).toEqual(options);
      expect(resolve(toolName, input).subcommand).toBe(
        DOCS_TOOL_INPUT_TABLES[toolName].subcommand,
      );
    }
  });

  it("emits one -<Name> <value> pair per multi element in array order", () => {
    // Act
    const check = resolve("run_docs_check", {
      paths: ["c.md", "a.md", "b.md"],
    });
    const inventory = resolve("run_docs_inventory", {
      analyzers: ["typescript-cli", "python-cli"],
    });

    // Assert
    expect(check.options).toEqual([
      "-Path",
      "c.md",
      "-Path",
      "a.md",
      "-Path",
      "b.md",
    ]);
    expect(inventory.options).toEqual([
      "-Analyzer",
      "typescript-cli",
      "-Analyzer",
      "python-cli",
    ]);
  });

  it("emits -Write for update_docs_ledger only when write is true", () => {
    // Arrange
    const base = { operation: "sync-refs", actor_kind: "tool", actor_id: "ci" };

    // Act
    const omitted = resolve("update_docs_ledger", base).options;
    const disabled = resolve("update_docs_ledger", {
      ...base,
      write: false,
    }).options;
    const enabled = resolve("update_docs_ledger", {
      ...base,
      write: true,
    }).options;

    // Assert
    expect(omitted).not.toContain("-Write");
    expect(disabled).not.toContain("-Write");
    expect(enabled.filter((token) => token === "-Write")).toEqual(["-Write"]);
    expect(enabled[enabled.length - 1]).toBe("-Write");
  });

  it("never emits -Write for run_docs_inventory or generate_docs_reference, or -WriteReceipt for validate_docs_artifacts", () => {
    // Arrange
    const writeAttempts: ReadonlyArray<readonly [DocsToolName, string]> = [
      ["run_docs_inventory", "write"],
      ["generate_docs_reference", "write"],
      ["validate_docs_artifacts", "write_receipt"],
      ["validate_docs_artifacts", "write"],
    ];

    for (const [toolName, input] of FULL_INPUTS.map(
      ([name, value]) => [name, value] as const,
    )) {
      // Act
      const options = resolve(toolName, input).options;

      // Assert
      if (toolName !== "update_docs_ledger") {
        expect(options).not.toContain("-Write");
        expect(options).not.toContain("-WriteReceipt");
      }
    }
    for (const [toolName, field] of writeAttempts) {
      const baseInput =
        FULL_INPUTS.find(([name]) => name === toolName)?.[1] ?? {};
      expect(
        captureError(() => resolve(toolName, { ...baseInput, [field]: true })),
      ).toBeInstanceOf(DocsInputError);
    }
  });

  it("never emits a reserved option name and emits nothing for an omitted field or empty array", () => {
    // Arrange
    const reservedKeys = [
      "Command",
      "Json",
      "Help",
      "RepositoryRoot",
      "command",
      "json",
    ];

    // Act and Assert: accepted inputs never carry a reserved option.
    for (const [toolName, input] of FULL_INPUTS.map(
      ([name, value]) => [name, value] as const,
    )) {
      const options = resolve(toolName, input).options;
      for (const reserved of RESERVED) {
        expect(options).not.toContain(reserved);
      }
      for (const key of reservedKeys) {
        expect(
          captureError(() => resolve(toolName, { ...input, [key]: "x" })),
        ).toBeInstanceOf(DocsInputError);
      }
    }
    expect(resolve("run_docs_check", { paths: [] }).options).toEqual([]);
    expect(resolve("run_docs_inventory", { analyzers: [] }).options).toEqual(
      [],
    );
    expect(resolve("run_docs_coverage", {}).options).toEqual([]);
  });
});

describe("resolveDocsToolInput rejections", () => {
  it("rejects invalid input with DOCS_INPUT_INVALID", () => {
    // Arrange
    const C: DocsToolName = "run_docs_check";
    const I: DocsToolName = "run_docs_inventory";
    const G: DocsToolName = "generate_docs_reference";
    const L: DocsToolName = "update_docs_ledger";
    const V: DocsToolName = "validate_docs_artifacts";
    const sync = { operation: "sync-refs", actor_kind: "agent", actor_id: "d" };
    const sd = {
      ...sync,
      operation: "set-disposition",
      element: ELEMENT,
      disposition: "documented",
    };
    const pin = {
      ...sync,
      operation: "pin",
      element: ELEMENT,
      pages: ["a.md"],
    };
    const cases: Array<readonly [string, DocsToolName, object]> = [
      ["unknown key", C, { root: "docs" }],
      ["wrong type string", C, { profile: 7 }],
      ["wrong type array", C, { paths: "a.md" }],
      ["wrong type array item", C, { paths: [1] }],
      ["wrong type boolean", L, { ...sync, write: "true" }],
      ["enum outside list", V, { mode: "all", revision: REVISION }],
      ["enum wrong type", L, { ...sync, actor_kind: 1 }],
      ["empty array item", C, { paths: [""] }],
      ["relative path grammar", C, { paths: ["../a.md"] }],
      ["absolute path grammar", C, { profile: "/etc/p.json" }],
      ["backslash path grammar", C, { profile: "docs\\p.json" }],
      ["drive path grammar", C, { profile: "C:/p.json" }],
      ["identifier grammar", I, { analyzers: ["Python"] }],
      ["revision grammar", I, { revision: "abc" }],
      ["element id grammar", L, { ...sd, element: "cli-command-xyz" }],
      ["page reference grammar", L, { ...sd, pages: ["docs/a.md#"] }],
      ["text grammar", L, { ...sd, rationale: "   " }],
      ["leading dash in array", C, { paths: ["-Write"] }],
      ["duplicate pages", L, { ...sd, pages: ["a.md", "a.md"] }],
      ["validate without mode", V, { revision: REVISION }],
      ["validate without revision", V, { mode: "profile" }],
      ["ledger without operation", L, { actor_kind: "agent", actor_id: "d" }],
    ];
    const stringFields: ReadonlyArray<readonly [DocsToolName, object, string]> =
      [
        [C, {}, "profile"],
        [I, {}, "revision"],
        [G, {}, "snapshot"],
        [G, {}, "output_directory"],
        [V, { mode: "ledger" }, "revision"],
        [L, sync, "actor_id"],
        [L, sd, "element"],
        [L, sd, "rationale"],
        [L, sd, "target"],
        [L, sd, "owner"],
        [L, pin, "claim"],
      ];
    for (const [toolName, base, field] of stringFields) {
      cases.push([`empty ${field}`, toolName, { ...base, [field]: "" }]);
      cases.push([`dash ${field}`, toolName, { ...base, [field]: "-Write" }]);
    }
    const inputs: ReadonlyArray<readonly [string, DocsToolName, unknown]> = [
      ...cases.map(
        ([label, tool, input]) =>
          [label, tool, { workspace_root: ROOT, ...input }] as const,
      ),
      ["not an object", C, [ROOT]],
      ["null input", C, null],
    ];

    for (const [label, toolName, input] of inputs) {
      // Act
      const error = captureError(() => resolveDocsToolInput(toolName, input));

      // Assert
      expect({ label, message: error.message.slice(0, 20) }).toEqual({
        label,
        message: "DOCS_INPUT_INVALID: ",
      });
      expect(error).toBeInstanceOf(DocsInputError);
    }
  });

  it("rejects a missing or non-string workspace_root with DOCS_WORKSPACE_ROOT_INVALID", () => {
    for (const input of [
      {},
      { workspace_root: 42 },
      { workspace_root: "  " },
    ]) {
      // Act
      const error = captureError(() =>
        resolveDocsToolInput("run_docs_coverage", input),
      );

      // Assert
      expect(error).toBeInstanceOf(DocsHostError);
      expect(error.message.startsWith("DOCS_WORKSPACE_ROOT_INVALID: ")).toBe(
        true,
      );
    }
  });
});

describe("docs grammar parity", () => {
  it("keeps each grammar pattern equal to the committed common schema pattern", () => {
    // Arrange
    const schemaPath = path.join(
      REPO_ROOT,
      "schemas",
      "docs",
      "v1",
      "common.schema.json",
    );
    const schema = JSON.parse(readFileSync(schemaPath, "utf-8")) as {
      readonly $defs: Readonly<Record<string, { readonly pattern?: string }>>;
    };
    const pinned: ReadonlyArray<readonly [string, string]> = [
      ["relative-path", DOCS_RELATIVE_PATH_PATTERN],
      ["identifier", DOCS_IDENTIFIER_PATTERN],
      ["revision", DOCS_REVISION_PATTERN],
      ["element-id", DOCS_ELEMENT_ID_PATTERN],
      ["text", DOCS_TEXT_PATTERN],
    ];

    // Act and Assert: string equality with the committed pattern values.
    for (const [definition, pattern] of pinned) {
      expect({ definition, pattern }).toEqual({
        definition,
        pattern: schema.$defs[definition]?.pattern,
      });
    }

    // The page-reference grammar has no schema definition; literal cases pin it.
    const accepted = [
      "docs/a.md",
      "docs/a.md#usage",
      "a.md#x#y",
      "docs/a b.md#Section 2",
    ];
    const rejected = [
      "docs/a.md#",
      "docs/a.md#   ",
      "#usage",
      "../a.md",
      "/a.md",
      "a\\b.md#x",
      "docs//a.md",
    ];
    for (const reference of accepted) {
      expect({
        reference,
        ok: matchesDocsGrammar("page-reference", reference),
      }).toEqual({
        reference,
        ok: true,
      });
    }
    for (const reference of rejected) {
      expect({
        reference,
        ok: matchesDocsGrammar("page-reference", reference),
      }).toEqual({
        reference,
        ok: false,
      });
    }
    expect(matchesDocsGrammar("limit", "diagnostic-python-1")).toBe(true);
    expect(matchesDocsGrammar("limit", "python-1")).toBe(false);
  });
});
