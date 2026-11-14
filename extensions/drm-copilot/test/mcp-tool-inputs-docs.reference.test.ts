/**
 * Tests for the `generate_docs_reference` `path_prefixes` row (issue #1173 B5).
 * The array maps to one `-PathPrefix <value>` pair per element in array order;
 * each element must be a repository-relative path. Every case is in memory.
 */

import { describe, expect, it } from "@jest/globals";

import {
  DocsInputError,
  resolveDocsToolInput,
} from "../src/mcp-tool-inputs-docs";

const ROOT = "/virtual/workspace";

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

describe("generate_docs_reference path_prefixes", () => {
  it("emits one -PathPrefix pair per prefix in array order after the other options", () => {
    // Act
    const resolved = resolveDocsToolInput("generate_docs_reference", {
      workspace_root: ROOT,
      path_prefixes: ["pkg/core", "pkg/io"],
      output_directory: "docs/reference",
    });

    // Assert
    expect(resolved.subcommand).toBe("generate-reference");
    expect(resolved.options).toEqual([
      "-OutputDirectory",
      "docs/reference",
      "-PathPrefix",
      "pkg/core",
      "-PathPrefix",
      "pkg/io",
    ]);
  });

  it("emits no -PathPrefix option when the field is omitted or empty", () => {
    // Act
    const omitted = resolveDocsToolInput("generate_docs_reference", {
      workspace_root: ROOT,
    });
    const empty = resolveDocsToolInput("generate_docs_reference", {
      workspace_root: ROOT,
      path_prefixes: [],
    });

    // Assert
    expect(omitted.options).toEqual([]);
    expect(empty.options).toEqual([]);
  });

  it("rejects a prefix that is not a repository-relative path with DOCS_INPUT_INVALID", () => {
    for (const prefix of [
      "../pkg",
      "/pkg",
      "C:/pkg",
      "pkg\\core",
      "",
      "-Write",
    ]) {
      // Act
      const error = captureError(() =>
        resolveDocsToolInput("generate_docs_reference", {
          workspace_root: ROOT,
          path_prefixes: [prefix],
        }),
      );

      // Assert
      expect({ prefix, message: error.message.slice(0, 20) }).toEqual({
        prefix,
        message: "DOCS_INPUT_INVALID: ",
      });
      expect(error).toBeInstanceOf(DocsInputError);
    }
  });

  it("rejects a non-array path_prefixes value with DOCS_INPUT_INVALID", () => {
    // Act
    const error = captureError(() =>
      resolveDocsToolInput("generate_docs_reference", {
        workspace_root: ROOT,
        path_prefixes: "pkg/core",
      }),
    );

    // Assert
    expect(error).toBeInstanceOf(DocsInputError);
  });
});
