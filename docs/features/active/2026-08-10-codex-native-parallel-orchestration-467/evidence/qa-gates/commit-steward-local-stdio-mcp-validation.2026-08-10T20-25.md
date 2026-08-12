# P6-T37 Repository-Local Stdio MCP Validation

Timestamp: 2026-08-11T23:37:25-04:00

Command:

```powershell
@'
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { Client } = require('./extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/client/index.js');
const { StdioClientTransport } = require('./extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/client/stdio.js');

(async () => {
  const workspaceRoot = 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25';
  const bundlePath = 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25\\packages\\mcp-server\\out\\mcp-server.js';
  const bundleSha256 = crypto.createHash('sha256').update(fs.readFileSync(bundlePath)).digest('hex').toUpperCase();
  const callArguments = {
    workspace_root: workspaceRoot,
    artifact_type: 'orchestrator-state',
    artifact_path: 'artifacts/orchestration/orchestrator-state.json',
    require_codex_topology: true,
    require_codex_model_routing: true,
  };
  const stderrChunks = [];
  let client;
  let transport;
  let childProcess;
  let closeResult = 'not-started';
  try {
    client = new Client({ name: 'p6-t37-local-mcp-client', version: '1.0.0' }, { capabilities: {} });
    transport = new StdioClientTransport({
      command: process.execPath,
      args: [bundlePath],
      cwd: workspaceRoot,
      stderr: 'pipe',
    });
    transport.stderr.on('data', (chunk) => stderrChunks.push(Buffer.from(chunk)));
    await client.connect(transport);
    childProcess = transport._process;
    const pid = transport.pid;
    const serverIdentity = client.getServerVersion();
    const serverCapabilities = client.getServerCapabilities();
    if (serverIdentity?.name !== 'drmCopilotExtension') throw new Error(`Unexpected server name: ${serverIdentity?.name}`);
    if (pid === null || pid === undefined) throw new Error('Child PID is null');
    if (!serverCapabilities?.tools) throw new Error('Server does not advertise tools capability');

    const listed = await client.listTools();
    const selected = listed.tools.filter((tool) => tool.name === 'validate_orchestration_artifacts');
    if (selected.length !== 1) throw new Error(`Expected one validation tool, found ${selected.length}`);
    const selectedTool = selected[0];
    const required = selectedTool.inputSchema?.required ?? [];
    const properties = selectedTool.inputSchema?.properties ?? {};
    for (const name of ['workspace_root', 'artifact_type', 'artifact_path']) {
      if (!required.includes(name)) throw new Error(`Missing required schema field: ${name}`);
    }
    for (const name of ['require_codex_topology', 'require_codex_model_routing']) {
      if (!Object.prototype.hasOwnProperty.call(properties, name)) throw new Error(`Missing schema property: ${name}`);
    }

    const toolResult = await client.callTool({
      name: 'validate_orchestration_artifacts',
      arguments: callArguments,
    });
    if (toolResult.isError === true) throw new Error(`Tool returned isError=true: ${JSON.stringify(toolResult)}`);
    if (toolResult.structuredContent?.ok !== true) throw new Error(`Tool returned non-success structured content: ${JSON.stringify(toolResult)}`);

    await client.close();
    closeResult = 'client.close resolved';
    const stderr = Buffer.concat(stderrChunks).toString('utf8');
    const receipt = {
      executable: process.execPath,
      bundle: path.resolve(bundlePath),
      cwd: path.resolve(workspaceRoot),
      bundle_sha256: bundleSha256,
      pid,
      initialized_server_identity: serverIdentity,
      initialized_server_capabilities: serverCapabilities,
      selected_tool_schema: selectedTool,
      call_arguments: callArguments,
      isError: toolResult.isError ?? false,
      structuredContent: toolResult.structuredContent,
      content: toolResult.content,
      stderr,
      close_result: closeResult,
      process_exit_status: {
        exitCode: childProcess?.exitCode ?? null,
        signalCode: childProcess?.signalCode ?? null,
      },
    };
    if (stderr !== '') throw new Error(`Server stderr was not empty: ${JSON.stringify(receipt)}`);
    if (receipt.process_exit_status.exitCode !== 0 || receipt.process_exit_status.signalCode !== null) {
      throw new Error(`Server did not terminate cleanly: ${JSON.stringify(receipt)}`);
    }
    process.stdout.write(`${JSON.stringify(receipt, null, 2)}\n`);
  } catch (error) {
    try {
      if (client) await client.close();
    } catch {}
    const failure = {
      error: error instanceof Error ? error.message : String(error),
      stderr: Buffer.concat(stderrChunks).toString('utf8'),
      close_result: closeResult,
      process_exit_status: {
        exitCode: childProcess?.exitCode ?? null,
        signalCode: childProcess?.signalCode ?? null,
      },
    };
    process.stdout.write(`${JSON.stringify(failure, null, 2)}\n`);
    process.exitCode = 1;
  }
})();
'@ | node -
```

EXIT_CODE: 0

Output Summary: A newly spawned Node process completed MCP `initialize`, `tools/list`, and `tools/call` through the SDK stdio transport. The initialized server was `drmCopilotExtension` version `1.0.23`, advertised tools capability, exposed exactly one `validate_orchestration_artifacts` definition with all required schema fields and both strict flags, and returned `structuredContent.ok=true` with `isError=false`. Stderr was empty and the child exited with code 0 and no signal after `client.close()`.

Complete JSON receipt:

```json
{
  "executable": "C:\\Program Files\\nodejs\\node.exe",
  "bundle": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25\\packages\\mcp-server\\out\\mcp-server.js",
  "cwd": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
  "bundle_sha256": "AF0EBD9D5C77E76AABC113FF4977083B0407EB1DA0D4B1EE07F7AE55AACCB38E",
  "pid": 88460,
  "initialized_server_identity": {
    "name": "drmCopilotExtension",
    "version": "1.0.23"
  },
  "initialized_server_capabilities": {
    "tools": {}
  },
  "selected_tool_schema": {
    "name": "validate_orchestration_artifacts",
    "description": "Validate an orchestration artifact, including epic planner, kickoff, and execution checkpoints, against its structural and semantic invariants.",
    "inputSchema": {
      "type": "object",
      "properties": {
        "workspace_root": {
          "type": "string",
          "description": "Required absolute path to the root of the target checkout or worktree. The MCP server cannot infer the calling agent's checkout, so this value must be supplied explicitly."
        },
        "artifact_type": {
          "type": "string",
          "enum": [
            "plan",
            "policy-audit",
            "code-review",
            "feature-audit",
            "orchestrator-state",
            "epic-orchestrator-state",
            "epic-planner-state",
            "epic-kickoff",
            "parallel-orchestrator-state",
            "parallel-planner-state",
            "parallel-kickoff"
          ],
          "description": "The type of orchestration artifact to validate."
        },
        "artifact_path": {
          "type": "string",
          "description": "Workspace-relative or absolute path to the artifact file."
        },
        "require_complete": {
          "type": "boolean",
          "description": "When true and artifact_type is 'orchestrator-state', 'epic-orchestrator-state', or 'parallel-orchestrator-state', require all phases to be complete."
        },
        "require_model_routing": {
          "type": "boolean",
          "description": "When true and artifact_type is 'orchestrator-state', require a model_routing_receipts entry per delegated agent once a delegation is recorded. The TypeScript side performs the existence check only; the Python validator is authoritative for full per-receipt correctness."
        },
        "require_codex_model_routing": {
          "type": "boolean",
          "description": "When true for an orchestrator checkpoint, require canonical Codex deployment receipts for delegated agents."
        },
        "require_codex_topology": {
          "type": "boolean",
          "description": "When true for an orchestrator checkpoint, require canonical Codex topology receipts for delegated agents and epic roots."
        },
        "require_ready_for_execution": {
          "type": "boolean",
          "description": "When true for 'epic-planner-state', 'parallel-planner-state', or 'parallel-kickoff', require complete preparation and committed execution-readiness evidence."
        }
      },
      "required": [
        "workspace_root",
        "artifact_type",
        "artifact_path"
      ],
      "additionalProperties": false
    }
  },
  "call_arguments": {
    "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
    "artifact_type": "orchestrator-state",
    "artifact_path": "artifacts/orchestration/orchestrator-state.json",
    "require_codex_topology": true,
    "require_codex_model_routing": true
  },
  "isError": false,
  "structuredContent": {
    "ok": true,
    "tool": "validate_orchestration_artifacts",
    "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
    "summary": "Validated orchestrator-state artifact at 'artifacts/orchestration/orchestrator-state.json'."
  },
  "content": [
    {
      "type": "text",
      "text": "{\n  \"ok\": true,\n  \"tool\": \"validate_orchestration_artifacts\",\n  \"workspace_root\": \"C:\\\\Users\\\\DanMoisan\\\\repos\\\\drm-copilot-wt\\\\2026-08-10T19-25\",\n  \"summary\": \"Validated orchestrator-state artifact at 'artifacts/orchestration/orchestrator-state.json'.\"\n}"
    }
  ],
  "stderr": "",
  "close_result": "client.close resolved",
  "process_exit_status": {
    "exitCode": 0,
    "signalCode": null
  }
}
```

Result: PASS — the fresh local bundle is transport-equivalent for the required public strict-validator tool and accepts the checkpoint through actual MCP stdio protocol handling.
