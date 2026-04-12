import * as fs from "node:fs";
import * as path from "node:path";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  type CallToolResult,
} from "@modelcontextprotocol/sdk/types.js";
import { createBufferedOutput } from "./command-runtime";
import {
  dispatchRepoAutomationTool,
  isRepoAutomationToolName,
  listRepoAutomationTools,
  type RepoAutomationMcpToolResult,
} from "./mcp-tools";
import {
  createRepoAutomationService,
  type RepoAutomationService,
} from "./repo-automation-service";

export interface RepoAutomationMcpServerOptions {
  readonly extensionRoot?: string;
  readonly createService?: (output: {
    appendLine(line: string): void;
  }) => RepoAutomationService;
}

function resolveExtensionRoot(): string {
  return path.resolve(__dirname, "..");
}

function readPackageVersion(extensionRoot: string): string {
  const packageJsonPath = path.join(extensionRoot, "package.json");
  try {
    const packageJson = JSON.parse(
      fs.readFileSync(packageJsonPath, "utf-8"),
    ) as { readonly version?: string };
    return packageJson.version ?? "0.0.1";
  } catch {
    return "0.0.1";
  }
}

function toCallToolResult(result: RepoAutomationMcpToolResult): CallToolResult {
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(result, null, 2),
      },
    ],
    structuredContent: result,
    isError: !result.ok,
  };
}

/**
 * Creates the stdio MCP server that exposes semantic repo-automation tools.
 *
 * @param options Optional construction overrides used by unit tests.
 * @returns A configured MCP server ready to connect to a transport.
 */
export function createRepoAutomationMcpServer(
  options: RepoAutomationMcpServerOptions = {},
): Server {
  const extensionRoot = options.extensionRoot ?? resolveExtensionRoot();
  const createService =
    options.createService ??
    ((output: { appendLine(line: string): void }) =>
      createRepoAutomationService({
        extensionRoot,
        output,
      }));
  const server = new Server(
    {
      name: "drmCopilotExtension",
      version: readPackageVersion(extensionRoot),
    },
    {
      capabilities: {
        tools: {},
      },
    },
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: listRepoAutomationTools(),
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const toolName = request.params.name;
    if (!isRepoAutomationToolName(toolName)) {
      return {
        content: [
          {
            type: "text",
            text: `Unknown repo-automation tool '${toolName}'.`,
          },
        ],
        isError: true,
      };
    }

    const { output } = createBufferedOutput();
    const service = createService(output);
    const result = await dispatchRepoAutomationTool(
      toolName,
      request.params.arguments,
      service,
    );
    return toCallToolResult(result);
  });

  return server;
}

/**
 * Runs the stdio MCP server until the parent process terminates.
 *
 * @returns A promise that resolves after the server transport is connected.
 */
export async function main(): Promise<void> {
  const server = createRepoAutomationMcpServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

if (require.main === module) {
  void main().catch((error: unknown) => {
    const detail =
      error instanceof Error ? (error.stack ?? error.message) : String(error);
    process.stderr.write(`${detail}\n`);
    process.exitCode = 1;
  });
}
