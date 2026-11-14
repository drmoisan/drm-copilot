/**
 * MCP server tests for the six docs tools (issue #1036), exercised through an
 * `InMemoryTransport` pair and a per-test mock service. No process is
 * launched and no file is written.
 */

import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";

jest.mock("vscode", () => ({}), { virtual: true });

import {
  DocsHostError,
  type DocsCommandEnvelope,
  type DocsHostErrorCode,
} from "../src/docs-command-envelope";
import { createRepoAutomationMcpServer } from "../src/mcp-server";
import {
  VIRTUAL_WORKSPACE_ROOT,
  createMockService,
  type MockService,
} from "./mcp-server-test-service";

const DOCS_TOOLS = [
  "run_docs_check",
  "run_docs_inventory",
  "run_docs_coverage",
  "update_docs_ledger",
  "generate_docs_reference",
  "validate_docs_artifacts",
];

function envelope(exitCode: 0 | 1 | 2 | 3): DocsCommandEnvelope {
  return {
    command: "check",
    exit_code: exitCode,
    findings: [],
    ok: exitCode === 0,
    result: null,
  };
}

interface ToolCallResult {
  readonly isError?: boolean;
  readonly structuredContent?: Readonly<Record<string, unknown>>;
}

describe("repo automation MCP server docs tools", () => {
  let client: Client;
  let service: MockService;
  let server: ReturnType<typeof createRepoAutomationMcpServer>;

  beforeEach(async () => {
    service = createMockService();
    server = createRepoAutomationMcpServer({ createService: () => service });
    client = new Client(
      { name: "test-client", version: "1.0.0" },
      { capabilities: {} },
    );
    const [clientTransport, serverTransport] =
      InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);
    await client.connect(clientTransport);
  });

  afterEach(async () => {
    await client.close();
    await server.close();
    jest.clearAllMocks();
  });

  async function callCheck(
    args: Readonly<Record<string, unknown>> = {
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
    },
  ): Promise<ToolCallResult> {
    return (await client.callTool({
      name: "run_docs_check",
      arguments: args,
    })) as ToolCallResult;
  }

  it("lists the six docs tools with their annotations", async () => {
    // Act
    const result = await client.listTools();
    const docsTools = result.tools.filter((tool) =>
      DOCS_TOOLS.includes(tool.name),
    );

    // Assert
    expect(docsTools.map((tool) => tool.name)).toEqual(DOCS_TOOLS);
    for (const tool of docsTools) {
      const expected =
        tool.name === "update_docs_ledger"
          ? { readOnlyHint: false, destructiveHint: true, openWorldHint: false }
          : { readOnlyHint: true, openWorldHint: false };
      expect({ name: tool.name, annotations: tool.annotations }).toEqual({
        name: tool.name,
        annotations: expected,
      });
    }
  });

  it("returns structuredContent.docs and isError per exit code", async () => {
    for (const exitCode of [0, 1, 2, 3] as const) {
      // Arrange
      const outcome = envelope(exitCode);
      service.runDocsCommand?.mockResolvedValueOnce({
        envelope: outcome,
        stderr: "",
      });

      // Act
      const result = await callCheck();

      // Assert
      expect({
        exitCode,
        isError: result.isError,
        ok: result.structuredContent?.["ok"],
        docs: result.structuredContent?.["docs"],
      }).toEqual({
        exitCode,
        isError: exitCode !== 0,
        ok: exitCode === 0,
        docs: outcome,
      });
    }
  });

  it("passes an update_docs_ledger operations batch to runDocsCommand with -Operations - and the document as stdin (issue #1173)", async () => {
    // Arrange
    service.runDocsCommand?.mockResolvedValueOnce({
      envelope: envelope(0),
      stderr: "",
    });
    const operations = [{ operation: "bind-page-refs" }];

    // Act
    const result = (await client.callTool({
      name: "update_docs_ledger",
      arguments: {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        operations,
        actor_kind: "agent",
        actor_id: "docs-reconciler",
      },
    })) as ToolCallResult;
    const request = service.runDocsCommand?.mock.calls[0]?.[0];

    // Assert
    expect(result.isError).toBeFalsy();
    expect(request?.options.slice(0, 2)).toEqual(["-Operations", "-"]);
    expect(JSON.parse(request?.stdin ?? "")).toEqual({ operations });
  });

  it("returns isError for invalid input without calling runDocsCommand", async () => {
    // Act
    const result = await callCheck({
      workspace_root: VIRTUAL_WORKSPACE_ROOT,
      paths: ["-x"],
    });

    // Assert
    expect(result.isError).toBe(true);
    expect(String(result.structuredContent?.["summary"])).toMatch(
      /^DOCS_INPUT_INVALID: /,
    );
    expect(service.runDocsCommand).not.toHaveBeenCalled();
  });

  it("returns a code-prefixed failure without docs for each host failure code", async () => {
    // Arrange
    const thrownCodes: ReadonlyArray<DocsHostErrorCode> = [
      "DOCS_ENTRY_SCRIPT_MISSING",
      "DOCS_PWSH_UNAVAILABLE",
      "DOCS_ENVELOPE_EMPTY",
      "DOCS_ENVELOPE_MALFORMED",
      "DOCS_ENVELOPE_EXIT_MISMATCH",
      "DOCS_ENVELOPE_COMMAND_MISMATCH",
    ];
    const observed: Array<{
      readonly code: string;
      readonly isError: boolean | undefined;
      readonly prefixed: boolean;
      readonly hasDocs: boolean;
    }> = [];
    const record = (code: string, result: ToolCallResult): void => {
      observed.push({
        code,
        isError: result.isError,
        prefixed: String(result.structuredContent?.["summary"]).startsWith(
          `${code}: `,
        ),
        hasDocs: result.structuredContent?.["docs"] !== undefined,
      });
    };

    // Act
    record(
      "DOCS_WORKSPACE_ROOT_INVALID",
      await callCheck({ paths: ["docs/index.md"] }),
    );
    for (const code of thrownCodes) {
      service.runDocsCommand?.mockRejectedValueOnce(
        new DocsHostError(code, "simulated host failure."),
      );
      record(code, await callCheck());
    }
    delete service.runDocsCommand;
    record("DOCS_RUNTIME_UNAVAILABLE", await callCheck());

    // Assert
    expect(observed.map((entry) => entry.code).sort()).toEqual(
      [
        "DOCS_WORKSPACE_ROOT_INVALID",
        ...thrownCodes,
        "DOCS_RUNTIME_UNAVAILABLE",
      ].sort(),
    );
    for (const entry of observed) {
      expect(entry).toEqual({
        code: entry.code,
        isError: true,
        prefixed: true,
        hasDocs: false,
      });
    }
  });
});
