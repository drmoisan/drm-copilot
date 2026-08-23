#!/usr/bin/env node

"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { spawn, spawnSync } = require("node:child_process");

const PROTOCOL_VERSION = "2025-06-18";
const REQUEST_TIMEOUT_MS = 10_000;
const SHUTDOWN_TIMEOUT_MS = 5_000;
const VALIDATION_PLAN_PATH =
  "docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/plan.2026-08-17T07-06.md";
const CAPABILITY_KEY = "drm-copilot/validator";
const PACKED_EVIDENCE_DIRECTORY =
  "docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing";
const CAPABILITY_FIELDS = [
  "bundle_sha256",
  "package_version",
  "remediation_loop_schema_versions",
  "routing_policy_sha256",
  "supported_artifact_types",
  "supported_validation_flags",
  "validator_contract_version",
];

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function parseArguments(argv) {
  const values = new Map();
  const valueOptions = new Set([
    "--server",
    "--mode",
    "--tarball",
    "--extract-to",
  ]);
  let requirePrCreationReady = false;
  for (let index = 0; index < argv.length; index += 1) {
    const name = argv[index];
    if (name === "--require-pr-creation-ready") {
      requirePrCreationReady = true;
      continue;
    }
    const value = argv[index + 1];
    if (
      !valueOptions.has(name) ||
      value === undefined ||
      value.startsWith("--")
    ) {
      throw new Error(`Invalid command-line argument near '${name ?? ""}'.`);
    }
    if (values.has(name)) {
      throw new Error(`Duplicate command-line argument '${name}'.`);
    }
    values.set(name, value);
    index += 1;
  }
  const server = values.get("--server");
  const mode = values.get("--mode");
  if (mode === undefined) {
    throw new Error("--mode is required.");
  }
  if (mode !== "source" && mode !== "built" && mode !== "packed") {
    throw new Error(`Unsupported smoke-test mode '${mode}'.`);
  }
  const tarball = values.get("--tarball");
  const extractTo = values.get("--extract-to");
  if (mode === "packed") {
    if (
      server !== undefined ||
      tarball === undefined ||
      extractTo === undefined
    ) {
      throw new Error(
        "Packed mode requires --tarball and --extract-to and forbids --server.",
      );
    }
  } else if (
    server === undefined ||
    tarball !== undefined ||
    extractTo !== undefined
  ) {
    throw new Error(
      "Source and built modes require --server and forbid packed options.",
    );
  }
  return {
    server,
    mode,
    tarball,
    extractTo,
    requirePrCreationReady,
  };
}

function extractPackedServer(options, repositoryRoot) {
  const evidenceRoot = path.resolve(repositoryRoot, PACKED_EVIDENCE_DIRECTORY);
  const tarballPath = path.resolve(repositoryRoot, options.tarball);
  const extractRoot = path.resolve(repositoryRoot, options.extractTo);
  const expectedExtractRoot = path.join(evidenceRoot, "packed-mcp");
  assert(
    extractRoot === expectedExtractRoot,
    `Packed extraction target must be '${expectedExtractRoot}'.`,
  );
  assert(
    path.dirname(tarballPath) === evidenceRoot && tarballPath.endsWith(".tgz"),
    `Packed tarball must be a .tgz file under '${evidenceRoot}'.`,
  );
  assert(
    fs.statSync(tarballPath).isFile(),
    `Tarball not found: ${tarballPath}`,
  );

  fs.rmSync(extractRoot, { recursive: true, force: true });
  fs.mkdirSync(extractRoot, { recursive: true });
  const extraction = spawnSync(
    "tar",
    ["-xzf", tarballPath, "-C", extractRoot, "--strip-components", "1"],
    {
      cwd: repositoryRoot,
      encoding: "utf8",
      timeout: REQUEST_TIMEOUT_MS,
      windowsHide: true,
    },
  );
  assert(
    extraction.status === 0,
    `Tarball extraction failed: ${(
      extraction.stderr ||
      extraction.error?.message ||
      "unknown error"
    ).trim()}`,
  );
  const serverPath = path.join(extractRoot, "out", "mcp-server.js");
  assert(
    fs.statSync(serverPath).isFile(),
    `Packed server not found after extraction: ${serverPath}`,
  );
  return { serverPath, tarballPath, extractRoot };
}

function timeoutAfter(milliseconds, message) {
  return new Promise((_, reject) => {
    const timer = setTimeout(() => reject(new Error(message)), milliseconds);
    timer.unref();
  });
}

class JsonRpcProcess {
  constructor(serverPath, repositoryRoot) {
    this.nextId = 1;
    this.pending = new Map();
    this.stdoutBuffer = "";
    this.stderr = "";
    this.exited = false;
    this.child = spawn(process.execPath, [serverPath], {
      cwd: repositoryRoot,
      windowsHide: true,
      stdio: ["pipe", "pipe", "pipe"],
    });
    this.exitPromise = new Promise((resolve) => {
      this.child.once("exit", (code, signal) => {
        this.exited = true;
        const detail = `MCP server exited before completing a request (code=${String(
          code,
        )}, signal=${String(signal)}).`;
        for (const pending of this.pending.values()) {
          pending.reject(new Error(detail));
        }
        this.pending.clear();
        resolve({ code, signal });
      });
    });
    this.child.once("error", (error) => this.rejectAll(error));
    this.child.stdout.on("data", (chunk) => this.consumeStdout(chunk));
    this.child.stderr.on("data", (chunk) => {
      this.stderr += chunk.toString("utf8");
    });
  }

  rejectAll(error) {
    for (const pending of this.pending.values()) {
      pending.reject(error);
    }
    this.pending.clear();
  }

  consumeStdout(chunk) {
    this.stdoutBuffer += chunk.toString("utf8");
    let newline = this.stdoutBuffer.indexOf("\n");
    while (newline >= 0) {
      const line = this.stdoutBuffer.slice(0, newline).replace(/\r$/, "");
      this.stdoutBuffer = this.stdoutBuffer.slice(newline + 1);
      if (line.length > 0) {
        this.consumeMessage(line);
      }
      newline = this.stdoutBuffer.indexOf("\n");
    }
  }

  consumeMessage(line) {
    let message;
    try {
      message = JSON.parse(line);
    } catch (error) {
      this.rejectAll(
        new Error(`MCP server emitted invalid JSON: ${String(error)}`),
      );
      return;
    }
    if (message.id === undefined) {
      return;
    }
    const pending = this.pending.get(message.id);
    if (pending === undefined) {
      this.rejectAll(
        new Error(`Unexpected JSON-RPC response id ${message.id}.`),
      );
      return;
    }
    this.pending.delete(message.id);
    if (message.error !== undefined) {
      pending.reject(
        new Error(
          `JSON-RPC ${message.id} failed: ${JSON.stringify(message.error)}`,
        ),
      );
      return;
    }
    pending.resolve(message.result);
  }

  send(message) {
    assert(!this.exited, "Cannot write to an exited MCP server process.");
    this.child.stdin.write(`${JSON.stringify(message)}\n`);
  }

  request(method, params) {
    const id = this.nextId;
    this.nextId += 1;
    const response = new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
    });
    this.send({ jsonrpc: "2.0", id, method, params });
    return Promise.race([
      response,
      timeoutAfter(
        REQUEST_TIMEOUT_MS,
        `Timed out waiting for JSON-RPC method '${method}'.`,
      ),
    ]);
  }

  notify(method, params = {}) {
    this.send({ jsonrpc: "2.0", method, params });
  }

  async close() {
    this.child.stdin.end();
    const result = await Promise.race([
      this.exitPromise,
      timeoutAfter(SHUTDOWN_TIMEOUT_MS, "MCP server shutdown timed out."),
    ]);
    assert(
      result.code === 0,
      `MCP server exited with code ${String(result.code)}: ${this.stderr.trim()}`,
    );
  }

  async terminate() {
    if (this.exited) {
      return;
    }
    this.child.kill();
    await Promise.race([
      this.exitPromise,
      timeoutAfter(SHUTDOWN_TIMEOUT_MS, "MCP server termination timed out."),
    ]);
  }
}

function validateCapability(initializeResult) {
  const capability =
    initializeResult?.capabilities?.experimental?.[CAPABILITY_KEY];
  assert(
    capability !== null && typeof capability === "object",
    `Initialize response is missing '${CAPABILITY_KEY}'.`,
  );
  assert(
    JSON.stringify(Object.keys(capability).sort()) ===
      JSON.stringify(CAPABILITY_FIELDS),
    "Initialize validator capability does not contain the exact seven fields.",
  );
  assert(
    initializeResult.serverInfo?.version === capability.package_version,
    "Initialize server and capability package versions differ.",
  );
  assert(
    capability.validator_contract_version === 1,
    "Unexpected validator contract version.",
  );
  assert(
    capability.remediation_loop_schema_versions?.includes(2),
    "Initialize capability does not support remediation schema version 2.",
  );
  assert(
    capability.supported_artifact_types?.includes("plan"),
    "Initialize capability does not support plan validation.",
  );
  assert(
    capability.supported_validation_flags?.includes(
      "require_pr_creation_ready",
    ),
    "Initialize capability does not support readiness validation.",
  );
  for (const digestName of ["bundle_sha256", "routing_policy_sha256"]) {
    assert(
      /^sha256:[0-9a-f]{64}$/.test(capability[digestName]),
      `Initialize capability has an invalid ${digestName}.`,
    );
  }
  return capability;
}

function validateToolResult(result, repositoryRoot) {
  assert(result?.isError !== true, "Validation tool reported isError=true.");
  const structured = result?.structuredContent;
  assert(structured?.ok === true, "Validation tool did not report ok=true.");
  assert(
    structured.tool === "validate_orchestration_artifacts",
    "Validation tool returned an unexpected tool name.",
  );
  assert(
    path.resolve(structured.workspace_root) === repositoryRoot,
    "Validation tool returned an unexpected workspace root.",
  );
  assert(
    structured.summary ===
      `Validated plan artifact at '${VALIDATION_PLAN_PATH}'.`,
    "Validation tool returned an unexpected summary.",
  );
  return structured;
}

async function run() {
  const options = parseArguments(process.argv.slice(2));
  const repositoryRoot = path.resolve(process.cwd());
  const packed =
    options.mode === "packed"
      ? extractPackedServer(options, repositoryRoot)
      : undefined;
  const serverPath =
    packed?.serverPath ?? path.resolve(repositoryRoot, options.server);
  assert(fs.statSync(serverPath).isFile(), `Server not found: ${serverPath}`);
  assert(
    fs.statSync(path.join(repositoryRoot, VALIDATION_PLAN_PATH)).isFile(),
    `Validation plan not found under ${repositoryRoot}.`,
  );

  const rpc = new JsonRpcProcess(serverPath, repositoryRoot);
  let closed = false;
  try {
    const initializeResult = await rpc.request("initialize", {
      protocolVersion: PROTOCOL_VERSION,
      capabilities: {},
      clientInfo: { name: "drm-copilot-mcp-smoke", version: "1.0.0" },
    });
    const capability = validateCapability(initializeResult);
    rpc.notify("notifications/initialized");

    const validationArguments = {
      workspace_root: repositoryRoot,
      artifact_type: "plan",
      artifact_path: VALIDATION_PLAN_PATH,
      ...(options.requirePrCreationReady
        ? { require_pr_creation_ready: true }
        : {}),
    };
    const first = await rpc.request("tools/call", {
      name: "validate_orchestration_artifacts",
      arguments: validationArguments,
    });
    const second = await rpc.request("tools/call", {
      name: "validate_orchestration_artifacts",
      arguments: validationArguments,
    });
    const validation = validateToolResult(first, repositoryRoot);
    validateToolResult(second, repositoryRoot);
    assert(
      JSON.stringify(first) === JSON.stringify(second),
      "Repeated validation calls returned different results.",
    );

    await rpc.close();
    closed = true;
    process.stdout.write(
      [
        `MODE=${options.mode}`,
        `SERVER=${serverPath}`,
        ...(packed === undefined
          ? []
          : [
              `TARBALL=${packed.tarballPath}`,
              `EXTRACT_TO=${packed.extractRoot}`,
            ]),
        `MCP_PROTOCOL_VERSION=${initializeResult.protocolVersion}`,
        `MCP_VALIDATOR_CAPABILITY=${JSON.stringify(capability)}`,
        `MCP_VALIDATION_RESULT=${JSON.stringify(validation)}`,
        `MCP_REQUIRE_PR_CREATION_READY=${String(
          options.requirePrCreationReady,
        )}`,
        "MCP_VALIDATION_DETERMINISTIC=true",
        "MCP_NETWORK_ACCESS=false",
        "MCP_SHUTDOWN=clean",
      ].join("\n") + "\n",
    );
  } finally {
    if (!closed) {
      await rpc.terminate();
    }
  }
}

run().catch((error) => {
  process.stderr.write(`${error instanceof Error ? error.stack : error}\n`);
  process.exitCode = 1;
});
