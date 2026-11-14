/**
 * Tests for the pure docs envelope parser (issue #1036). Fixtures are
 * in-memory strings; the only file read is the committed envelope schema,
 * read-only, for the contract test.
 */

import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import * as path from "node:path";

import {
  DOCS_ENVELOPE_KEYS,
  DocsHostError,
  excerptDocsStderr,
  formatDocsSummary,
  parseDocsEnvelope,
  type DocsCommandEnvelope,
} from "../src/docs-command-envelope";

const REPO_ROOT = path.resolve(__dirname, "..", "..", "..");

function finding(
  severity: string,
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    code: "DOCS_SAMPLE",
    severity,
    artifact_path: null,
    pointer: "",
    related_ids: [],
    related_paths: [],
    message: "Sample finding.",
    next_action: "Fix the sample.",
    ...overrides,
  };
}

function envelopeText(
  exitCode: number,
  overrides: Readonly<Record<string, unknown>> = {},
): string {
  const findings = exitCode === 0 ? [] : [finding("error")];
  return JSON.stringify({
    command: "check",
    exit_code: exitCode,
    findings,
    ok: exitCode === 0,
    result: exitCode >= 2 ? null : { pages: 1 },
    ...overrides,
  });
}

function captureError(action: () => unknown): DocsHostError {
  try {
    action();
  } catch (error) {
    if (error instanceof DocsHostError) {
      return error;
    }
    throw error;
  }
  throw new Error("Expected a DocsHostError to be thrown.");
}

function contextFor(exitCode: number | null, command = "check") {
  return { exitCode, stderr: "", command };
}

describe("parseDocsEnvelope", () => {
  it("accepts a valid envelope for exit codes 0, 1, 2 and 3", () => {
    for (const exitCode of [0, 1, 2, 3]) {
      // Arrange
      const stdout = `\n${envelopeText(exitCode)}\n`;

      // Act
      const envelope = parseDocsEnvelope(stdout, contextFor(exitCode));

      // Assert
      expect(envelope.exit_code).toBe(exitCode);
      expect(envelope.ok).toBe(exitCode === 0);
      expect(envelope.command).toBe("check");
      expect(envelope.result).toEqual(exitCode >= 2 ? null : { pages: 1 });
    }
  });

  it("rejects empty or whitespace stdout with DOCS_ENVELOPE_EMPTY", () => {
    for (const stdout of ["", "  \r\n\t "]) {
      // Act
      const error = captureError(() =>
        parseDocsEnvelope(stdout, contextFor(3)),
      );

      // Assert
      expect(error.code).toBe("DOCS_ENVELOPE_EMPTY");
      expect(error.message.startsWith("DOCS_ENVELOPE_EMPTY: ")).toBe(true);
    }
  });

  it("rejects malformed envelopes with DOCS_ENVELOPE_MALFORMED", () => {
    // Arrange
    const valid = JSON.parse(envelopeText(1)) as Record<string, unknown>;
    const withoutResult = { ...valid };
    delete withoutResult["result"];
    const cases: ReadonlyArray<readonly [string, string]> = [
      ["two documents", `${envelopeText(1)}\n${envelopeText(1)}`],
      ["trailing text", `${envelopeText(1)} trailing`],
      ["not an object", "[1, 2]"],
      ["missing key", JSON.stringify(withoutResult)],
      ["extra key", JSON.stringify({ ...valid, extra: true })],
      ["command type", JSON.stringify({ ...valid, command: 7 })],
      ["exit_code type", JSON.stringify({ ...valid, exit_code: "1" })],
      ["exit_code 4", JSON.stringify({ ...valid, exit_code: 4 })],
      ["ok type", JSON.stringify({ ...valid, ok: "false" })],
      ["ok disagrees", JSON.stringify({ ...valid, ok: true })],
      ["findings type", JSON.stringify({ ...valid, findings: {} })],
      [
        "finding extra key",
        JSON.stringify({
          ...valid,
          findings: [finding("error", { line: 3 })],
        }),
      ],
      [
        "finding missing key",
        JSON.stringify({
          ...valid,
          findings: [{ code: "X", severity: "error" }],
        }),
      ],
      [
        "finding severity",
        JSON.stringify({ ...valid, findings: [finding("fatal")] }),
      ],
      [
        "finding artifact_path type",
        JSON.stringify({
          ...valid,
          findings: [finding("error", { artifact_path: 1 })],
        }),
      ],
      [
        "finding related_ids type",
        JSON.stringify({
          ...valid,
          findings: [finding("error", { related_ids: [1] })],
        }),
      ],
      [
        "finding not an object",
        JSON.stringify({ ...valid, findings: ["text"] }),
      ],
    ];

    for (const [label, stdout] of cases) {
      // Act
      const error = captureError(() =>
        parseDocsEnvelope(stdout, contextFor(1)),
      );

      // Assert
      expect({ label, code: error.code }).toEqual({
        label,
        code: "DOCS_ENVELOPE_MALFORMED",
      });
    }
  });

  it("rejects an envelope exit code that differs from the process exit code with DOCS_ENVELOPE_EXIT_MISMATCH", () => {
    for (const processExit of [0, 2, null]) {
      // Act
      const error = captureError(() =>
        parseDocsEnvelope(envelopeText(1), contextFor(processExit)),
      );

      // Assert
      expect(error.code).toBe("DOCS_ENVELOPE_EXIT_MISMATCH");
    }
  });

  it("rejects an envelope command that differs from the requested subcommand with DOCS_ENVELOPE_COMMAND_MISMATCH", () => {
    for (const command of ["inventory", null]) {
      // Arrange
      const stdout = envelopeText(2, { command });

      // Act
      const error = captureError(() =>
        parseDocsEnvelope(stdout, contextFor(2, "check")),
      );

      // Assert
      expect(error.code).toBe("DOCS_ENVELOPE_COMMAND_MISMATCH");
    }
  });
});

describe("formatDocsSummary", () => {
  it("formats the summary line from finding severities", () => {
    // Arrange
    const envelope = parseDocsEnvelope(
      envelopeText(1, {
        findings: [
          finding("error"),
          finding("error"),
          finding("warning"),
          finding("info"),
          finding("info"),
          finding("info"),
        ],
      }),
      contextFor(1),
    );
    const nullCommand: DocsCommandEnvelope = { ...envelope, command: null };

    // Act
    const summary = formatDocsSummary(envelope);

    // Assert
    expect(summary).toBe("check: exit=1 errors=2 warnings=1 infos=3");
    expect(formatDocsSummary(nullCommand)).toBe(
      "unknown: exit=1 errors=2 warnings=1 infos=3",
    );
  });
});

describe("excerptDocsStderr", () => {
  it("takes the first eight non-empty stderr lines as the excerpt", () => {
    // Arrange
    const lines = Array.from(
      { length: 10 },
      (_, index) => `  line ${String(index + 1)}  `,
    );
    const stderr = ["", ...lines.slice(0, 4), "   ", ...lines.slice(4)].join(
      "\r\n",
    );

    // Act
    const excerpt = excerptDocsStderr(stderr);

    // Assert
    expect(excerpt).toBe(
      Array.from({ length: 8 }, (_, index) => `line ${String(index + 1)}`).join(
        "\n",
      ),
    );
    expect(excerptDocsStderr(" \n\n ")).toBeUndefined();
  });
});

describe("docs-command-envelope schema contract", () => {
  it("matches the required set and additionalProperties of the committed docs-command-envelope schema", () => {
    // Arrange
    const schemaPath = path.join(
      REPO_ROOT,
      "schemas",
      "docs",
      "v1",
      "docs-command-envelope.schema.json",
    );
    const schema = JSON.parse(readFileSync(schemaPath, "utf-8")) as {
      readonly required: ReadonlyArray<string>;
      readonly additionalProperties: unknown;
    };

    // Act
    const required = [...schema.required].sort();

    // Assert
    expect(required).toEqual([...DOCS_ENVELOPE_KEYS]);
    expect(schema.additionalProperties).toBe(false);
  });
});
