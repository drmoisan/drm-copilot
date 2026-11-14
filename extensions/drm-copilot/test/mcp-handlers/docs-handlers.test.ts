/**
 * Tests for the docs MCP tool handler (issue #1036). Each test builds its own
 * mock service; no process is launched and no file is read or written.
 */

import { describe, expect, it } from "@jest/globals";

import type { DocsCommandEnvelope } from "../../src/docs-command-envelope";
import { handleDocsTool } from "../../src/mcp-handlers/docs-handlers";
import {
  VIRTUAL_WORKSPACE_ROOT,
  createMockService,
  type MockService,
} from "../mcp-server-test-service";

function envelope(
  command: string,
  exitCode: 0 | 1 | 2 | 3,
  result: unknown = null,
): DocsCommandEnvelope {
  return {
    command,
    exit_code: exitCode,
    findings:
      exitCode === 0
        ? []
        : [
            {
              code: "DOCS_SAMPLE",
              severity: "error",
              artifact_path: null,
              pointer: "",
              related_ids: [],
              related_paths: [],
              message: "Sample finding.",
              next_action: "Fix the sample.",
            },
            {
              code: "DOCS_SAMPLE_NOTE",
              severity: "warning",
              artifact_path: "docs/index.md",
              pointer: "/pages/0",
              related_ids: [],
              related_paths: [],
              message: "Sample warning.",
              next_action: "Review the sample.",
            },
          ],
    ok: exitCode === 0,
    result,
  };
}

function serviceReturning(
  outcome: DocsCommandEnvelope,
  stderr = "",
): MockService {
  const service = createMockService();
  service.runDocsCommand?.mockResolvedValue({ envelope: outcome, stderr });
  return service;
}

const CHECK_INPUT = { workspace_root: VIRTUAL_WORKSPACE_ROOT };

describe("handleDocsTool", () => {
  it("maps exit 0 to ok true with the envelope in docs", async () => {
    // Arrange
    const outcome = envelope("check", 0, { pages: 3 });
    const service = serviceReturning(outcome);

    // Act
    const result = await handleDocsTool("run_docs_check", CHECK_INPUT, service);

    // Assert
    expect(result).toEqual({
      ok: true,
      tool: "run_docs_check",
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      summary: "check: exit=0 errors=0 warnings=0 infos=0",
      docs: outcome,
    });
    expect(service.runDocsCommand).toHaveBeenCalledWith({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      subcommand: "check",
      options: [],
    });
  });

  it("maps exit 1, 2 and 3 to ok false results carrying docs and the summary line", async () => {
    for (const exitCode of [1, 2, 3] as const) {
      // Arrange
      const outcome = envelope("coverage", exitCode);
      const service = serviceReturning(outcome);

      // Act
      const result = await handleDocsTool(
        "run_docs_coverage",
        CHECK_INPUT,
        service,
      );

      // Assert
      expect({ exitCode, ok: result.ok, docs: result.docs }).toEqual({
        exitCode,
        ok: false,
        docs: outcome,
      });
      expect(result.summary).toBe(
        `coverage: exit=${String(exitCode)} errors=1 warnings=1 infos=0`,
      );
    }
  });

  it("adds stderr_excerpt only for exit 3", async () => {
    // Arrange
    const stderr = "\nfirst line\n\nsecond line\n";
    const cases = [
      { exitCode: 2 as const, stderr, expected: undefined },
      { exitCode: 3 as const, stderr, expected: "first line\nsecond line" },
      { exitCode: 3 as const, stderr: " \n", expected: undefined },
    ];

    for (const entry of cases) {
      const service = serviceReturning(
        envelope("check", entry.exitCode),
        entry.stderr,
      );

      // Act
      const result = await handleDocsTool(
        "run_docs_check",
        CHECK_INPUT,
        service,
      );

      // Assert
      expect({ entry, excerpt: result.stderr_excerpt }).toEqual({
        entry,
        excerpt: entry.expected,
      });
      expect(Object.hasOwn(result, "stderr_excerpt")).toBe(
        entry.expected !== undefined,
      );
    }
  });

  it("fails with DOCS_RUNTIME_UNAVAILABLE when the service has no runDocsCommand", async () => {
    // Arrange
    const service = createMockService();
    delete service.runDocsCommand;

    // Act
    const call = handleDocsTool("run_docs_check", CHECK_INPUT, service);

    // Assert
    await expect(call).rejects.toThrow(/^DOCS_RUNTIME_UNAVAILABLE: /);
  });

  it("does not call runDocsCommand when the resolver rejects the input", async () => {
    // Arrange
    const service = serviceReturning(envelope("check", 0));

    // Act
    const call = handleDocsTool(
      "run_docs_check",
      { ...CHECK_INPUT, unknown_field: true },
      service,
    );

    // Assert
    await expect(call).rejects.toThrow(/^DOCS_INPUT_INVALID: /);
    expect(service.runDocsCommand).not.toHaveBeenCalled();
  });

  it("passes the envelope through unchanged", async () => {
    // Arrange
    const outcome = envelope("inventory", 1, {
      snapshot: { surfaces: [{ id: "cli-command-x" }] },
    });
    const service = serviceReturning(outcome);

    // Act
    const result = await handleDocsTool(
      "run_docs_inventory",
      CHECK_INPUT,
      service,
    );

    // Assert
    expect(result.docs).toBe(outcome);
  });

  it("returns inventory snapshot diagnostics, including DOCS_INPUT_NOT_UTF8, with an unchanged count (issue #1173 B10)", async () => {
    // Arrange
    const diagnostics = [
      {
        id: "docs-capture-1",
        code: "DOCS_INPUT_NOT_UTF8",
        severity: "warning",
        blocking: false,
        path: "src/legacy/latin1.py",
        analyzer_id: "docs-capture",
      },
      {
        id: "docs-inventory-1",
        code: "ENV_FILE_NOT_CAPTURED",
        severity: "warning",
        blocking: false,
        path: "config/.env",
        analyzer_id: "docs-inventory",
      },
    ];
    const outcome = envelope("inventory", 0, {
      snapshot: { inputs: [], elements: [], diagnostics },
      snapshot_path:
        "docs/documentation-estate/surface-inventory-snapshot.json",
      written: false,
    });
    const service = serviceReturning(outcome);

    // Act
    const result = await handleDocsTool(
      "run_docs_inventory",
      CHECK_INPUT,
      service,
    );
    const returned = (
      result.docs?.result as { snapshot: { diagnostics: { code: string }[] } }
    ).snapshot.diagnostics;

    // Assert
    expect(result.ok).toBe(true);
    expect(returned).toHaveLength(diagnostics.length);
    expect(returned.map((item) => item.code)).toContain("DOCS_INPUT_NOT_UTF8");
    expect(returned).toEqual(diagnostics);
  });

  it("passes the resolved operations stdin to runDocsCommand unchanged (issue #1173 B2.5)", async () => {
    // Arrange
    const service = serviceReturning(envelope("update-ledger", 0));
    const operations = [{ operation: "bind-page-refs" }];

    // Act
    await handleDocsTool(
      "update_docs_ledger",
      {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        operations,
        actor_kind: "agent",
        actor_id: "docs-reconciler",
      },
      service,
    );
    const request = service.runDocsCommand?.mock.calls[0]?.[0];

    // Assert
    expect(request?.options).toEqual([
      "-Operations",
      "-",
      "-ActorKind",
      "agent",
      "-ActorId",
      "docs-reconciler",
    ]);
    expect(JSON.parse(request?.stdin ?? "")).toEqual({ operations });
  });

  it("pins the generate_docs_reference result key set of the 1024 contract", async () => {
    // Arrange
    const outcome = envelope("generate-reference", 0, {
      mode: "dry-run",
      output_directory: null,
      pages: [],
      summary: { added: 0, removed: 0, unchanged: 0, updated: 0 },
      unrendered: [],
    });
    const service = serviceReturning(outcome);

    // Act
    const result = await handleDocsTool(
      "generate_docs_reference",
      CHECK_INPUT,
      service,
    );
    const docsResult = result.docs?.result;
    const keys =
      typeof docsResult === "object" && docsResult !== null
        ? Object.keys(docsResult).sort()
        : [];

    // Assert
    // Source: the 1024 spec section "### `-Json` envelope and `result`"
    // (docs-reference-generator-1024), which fixes this exact key set.
    expect(keys).toEqual([
      "mode",
      "output_directory",
      "pages",
      "summary",
      "unrendered",
    ]);
    expect(service.runDocsCommand).toHaveBeenCalledWith(
      expect.objectContaining({ subcommand: "generate-reference" }),
    );
  });
});
