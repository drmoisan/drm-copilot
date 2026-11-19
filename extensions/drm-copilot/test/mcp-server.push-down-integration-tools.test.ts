/**
 * MCP transport test of the push-down integration tools (issue #1051, S50).
 *
 * An in-memory client that declares no capability calls both tools against a
 * real service over an in-memory destination; every message the server sends
 * to the client is recorded, so a server-to-client request would be seen.
 */

import { afterEach, describe, expect, it, jest } from "@jest/globals";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationMcpServer } from "../src/mcp-server";
import { createRepoAutomationService } from "../src/repo-automation-service";
import {
  DATA_FILE_TEXT,
  DEST,
  destination,
  EXT,
} from "./lib/push-down-integration/integration-test-helpers";

/** A connected client and server with a recorder of server requests. */
interface Session {
  readonly client: Client;
  readonly server: Server;
  readonly serverRequests: string[];
}

const sessions: Session[] = [];

/** Connect a capability-free client to a server and record server requests. */
async function connect(server: Server): Promise<Session> {
  const client = new Client(
    { name: "test-client", version: "1.0.0" },
    { capabilities: {} },
  );
  const [clientTransport, serverTransport] =
    InMemoryTransport.createLinkedPair();
  await server.connect(serverTransport);
  await client.connect(clientTransport);
  const serverRequests: string[] = [];
  const deliver = clientTransport.onmessage;
  clientTransport.onmessage = (message, extra) => {
    if ("method" in message && "id" in message) {
      serverRequests.push(message.method);
    }
    deliver?.(message, extra);
  };
  const session = { client, server, serverRequests };
  sessions.push(session);
  return session;
}

/** A repo-automation server over a real service and an in-memory destination. */
function integrationServer(): Server {
  const fs = destination({
    ".github/drm-copilot/ci-required-checks.json": DATA_FILE_TEXT,
    ".github/workflows/ci.yml": "name: CI\non: push\n",
  });
  return createRepoAutomationMcpServer({
    extensionRoot: EXT,
    createService: (output) =>
      createRepoAutomationService({
        extensionRoot: EXT,
        output,
        pushDownFileSystem: fs,
      }),
  });
}

afterEach(async () => {
  for (const session of sessions.splice(0)) {
    await session.client.close();
    await session.server.close();
  }
});

describe("push-down integration tools over the MCP transport", () => {
  it("S50 positive: the server declares only tools and both calls complete with no server request", async () => {
    const session = await connect(integrationServer());

    const detect = await session.client.callTool({
      name: "detect_push_down_integration",
      arguments: { workspace_root: DEST },
    });
    const validate = await session.client.callTool({
      name: "validate_push_down_integration",
      arguments: { workspace_root: DEST },
    });

    expect(Object.keys(session.client.getServerCapabilities() ?? {})).toEqual([
      "tools",
    ]);
    expect(detect.isError).toBe(false);
    expect(validate.isError).toBe(false);
    expect(detect.structuredContent).toMatchObject({
      ok: true,
      tool: "detect_push_down_integration",
    });
    expect(validate.structuredContent).toMatchObject({
      ok: true,
      integration: { verdict: "fail" },
    });
    expect(session.serverRequests).toEqual([]);
  });

  it("S50 negative: a server-to-client request and an extra capability are both observable", async () => {
    const other = new Server(
      { name: "other", version: "1.0.0" },
      { capabilities: { tools: {}, logging: {} } },
    );
    const session = await connect(other);

    await session.server.ping();

    expect(session.serverRequests).toEqual(["ping"]);
    expect(
      Object.keys(session.client.getServerCapabilities() ?? {}).sort(),
    ).toEqual(["logging", "tools"]);
  });
});
