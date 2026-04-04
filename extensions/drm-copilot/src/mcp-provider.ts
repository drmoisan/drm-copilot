import * as vscode from "vscode";

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
export function registerMcpProvider(
  context: vscode.ExtensionContext,
): vscode.Disposable[] {
  // Create the event emitter that signals provider change events to VS Code.
  const mcpDidChangeEmitter = new vscode.EventEmitter<void>();

  // Register the MCP provider, wiring up the callback that constructs the
  // stdio server definition on demand.
  const mcpProviderDisposable = vscode.lm.registerMcpServerDefinitionProvider(
    "drmCopilotMcpProvider",
    {
      onDidChangeMcpServerDefinitions: mcpDidChangeEmitter.event,

      provideMcpServerDefinitions: async () => {
        // Build the server definition pointing at the compiled MCP server entry
        // point in the extension's output directory.
        const serverDef = new vscode.McpStdioServerDefinition(
          "drmCopilotExtension",
          "node",
          [
            vscode.Uri.joinPath(context.extensionUri, "out", "mcp-server.js")
              .fsPath,
          ],
        );

        // Assign the workspace as the working directory when one is open so
        // the MCP server resolves relative paths correctly in that context.
        const workspaceCwd = vscode.workspace.workspaceFolders?.[0]?.uri;
        if (workspaceCwd) {
          serverDef.cwd = workspaceCwd;
        }

        return [serverDef];
      },

      resolveMcpServerDefinition: async (server) => server,
    },
  );

  const disposables: vscode.Disposable[] = [
    mcpDidChangeEmitter,
    mcpProviderDisposable,
  ];

  // Push to context.subscriptions so VS Code disposes them on deactivation.
  context.subscriptions.push(...disposables);

  return disposables;
}
