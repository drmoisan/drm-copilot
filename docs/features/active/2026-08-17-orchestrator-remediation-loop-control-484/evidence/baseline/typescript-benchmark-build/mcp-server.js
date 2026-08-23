"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.createRepoAutomationMcpServer = createRepoAutomationMcpServer;
exports.main = main;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
const command_runtime_1 = require("./command-runtime");
const mcp_tools_1 = require("./mcp-tools");
const repo_automation_service_1 = require("./repo-automation-service");
function resolveExtensionRoot() {
    return path.resolve(__dirname, "..");
}
function readPackageVersion(extensionRoot) {
    const packageJsonPath = path.join(extensionRoot, "package.json");
    try {
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));
        return packageJson.version ?? "0.0.1";
    }
    catch {
        return "0.0.1";
    }
}
function toCallToolResult(result) {
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
function createRepoAutomationMcpServer(options = {}) {
    const extensionRoot = options.extensionRoot ?? resolveExtensionRoot();
    const createService = options.createService ??
        ((output) => (0, repo_automation_service_1.createRepoAutomationService)({
            extensionRoot,
            output,
        }));
    const server = new index_js_1.Server({
        name: "drmCopilotExtension",
        version: readPackageVersion(extensionRoot),
    }, {
        capabilities: {
            tools: {},
        },
    });
    server.setRequestHandler(types_js_1.ListToolsRequestSchema, async () => ({
        tools: (0, mcp_tools_1.listRepoAutomationTools)(),
    }));
    server.setRequestHandler(types_js_1.CallToolRequestSchema, async (request) => {
        const toolName = request.params.name;
        if (!(0, mcp_tools_1.isRepoAutomationToolName)(toolName)) {
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
        const { output } = (0, command_runtime_1.createBufferedOutput)();
        const service = createService(output);
        const result = await (0, mcp_tools_1.dispatchRepoAutomationTool)(toolName, request.params.arguments, service);
        return toCallToolResult(result);
    });
    return server;
}
/**
 * Runs the stdio MCP server until the parent process terminates.
 *
 * @returns A promise that resolves after the server transport is connected.
 */
async function main() {
    const server = createRepoAutomationMcpServer();
    const transport = new stdio_js_1.StdioServerTransport();
    await server.connect(transport);
}
if (require.main === module) {
    void main().catch((error) => {
        const detail = error instanceof Error ? (error.stack ?? error.message) : String(error);
        process.stderr.write(`${detail}\n`);
        process.exitCode = 1;
    });
}
