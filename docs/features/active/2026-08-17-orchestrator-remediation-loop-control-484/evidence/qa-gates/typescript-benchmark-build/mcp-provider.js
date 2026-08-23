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
exports.registerMcpProvider = registerMcpProvider;
const vscode = __importStar(require("vscode"));
/**
 * Registers the MCP server definition provider for the drm-copilot extension.
 *
 * Purpose:
 *   Isolates the MCP provider registration and callback logic so that
 *   `extension.ts` stays within the 500-line policy limit and the MCP
 *   behavior can be tested independently.
 *
 * @param context The extension lifecycle context supplied by VS Code.
 * @returns Array of disposables created during registration. The caller is
 *   responsible for pushing them to `context.subscriptions`.
 */
function registerMcpProvider(context) {
    // Create the event emitter that signals provider change events to VS Code.
    const mcpDidChangeEmitter = new vscode.EventEmitter();
    // Register the MCP provider, wiring up the callback that constructs the
    // stdio server definition on demand.
    const mcpProviderDisposable = vscode.lm.registerMcpServerDefinitionProvider("drmCopilotMcpProvider", {
        onDidChangeMcpServerDefinitions: mcpDidChangeEmitter.event,
        provideMcpServerDefinitions: async () => {
            // Build the server definition pointing at the compiled MCP server entry
            // point in the extension's output directory.
            // Use "node" from PATH as the runtime command. In VS Code's extension
            // host, process.execPath resolves to the Electron binary (e.g.,
            // Code - Insiders.exe), which cannot run standalone .js scripts.
            const serverDef = new vscode.McpStdioServerDefinition("drmCopilotExtension", "node", [
                vscode.Uri.joinPath(context.extensionUri, "out", "mcp-server.js")
                    .fsPath,
            ]);
            // Assign the workspace as the working directory when one is open so
            // the MCP server resolves relative paths correctly in that context.
            const workspaceCwd = vscode.workspace.workspaceFolders?.[0]?.uri;
            if (workspaceCwd) {
                serverDef.cwd = workspaceCwd;
            }
            return [serverDef];
        },
        resolveMcpServerDefinition: async (server) => server,
    });
    const disposables = [
        mcpDidChangeEmitter,
        mcpProviderDisposable,
    ];
    // Push to context.subscriptions so VS Code disposes them on deactivation.
    context.subscriptions.push(...disposables);
    return disposables;
}
