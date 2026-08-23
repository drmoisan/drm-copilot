import { createHash } from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import { describe, expect, it, jest } from "@jest/globals";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";

jest.mock("vscode", () => ({ window: {} }), { virtual: true });

import {
  VALIDATOR_ARTIFACT_TYPES,
  VALIDATOR_VALIDATION_FLAGS,
} from "../src/mcp-validator-catalog";
import {
  buildValidatorCapability,
  createRepoAutomationMcpServer,
  REMEDIATION_LOOP_SCHEMA_VERSIONS,
  VALIDATOR_CAPABILITY_KEY,
  VALIDATOR_CONTRACT_VERSION,
} from "../src/mcp-server";

const EXTENSION_ROOT = path.resolve(__dirname, "..");

function readPackageVersion(): string {
  const manifest = JSON.parse(
    fs.readFileSync(path.join(EXTENSION_ROOT, "package.json"), "utf8"),
  ) as { readonly version: string };
  return manifest.version;
}

function readRoutingPolicySha256(): string {
  const routingPolicy = fs.readFileSync(
    path.join(
      EXTENSION_ROOT,
      "resources",
      "config",
      "orchestration-routing.json",
    ),
  );
  return `sha256:${createHash("sha256").update(routingPolicy).digest("hex")}`;
}

describe("MCP initialize validator capability", () => {
  it("builds the exact seven-field capability from canonical metadata", () => {
    const packageVersion = readPackageVersion();
    const routingPolicySha256 = readRoutingPolicySha256();

    const capability = buildValidatorCapability(
      packageVersion,
      routingPolicySha256,
    );

    expect(capability).toEqual({
      validator_contract_version: VALIDATOR_CONTRACT_VERSION,
      remediation_loop_schema_versions: REMEDIATION_LOOP_SCHEMA_VERSIONS,
      supported_artifact_types: [...VALIDATOR_ARTIFACT_TYPES],
      supported_validation_flags: [...VALIDATOR_VALIDATION_FLAGS],
      routing_policy_sha256: routingPolicySha256,
      package_version: packageVersion,
      bundle_sha256: expect.stringMatching(/^sha256:[0-9a-f]{64}$/),
    });
    expect(Object.keys(capability)).toHaveLength(7);
  });

  it("publishes the complete capability and matching version during initialize", async () => {
    const packageVersion = readPackageVersion();
    const routingPolicySha256 = readRoutingPolicySha256();
    const expectedCapability = buildValidatorCapability(
      packageVersion,
      routingPolicySha256,
    );
    const server = createRepoAutomationMcpServer({
      extensionRoot: EXTENSION_ROOT,
    });
    const client = new Client(
      { name: "validator-capability-test", version: "1.0.0" },
      { capabilities: {} },
    );
    const [clientTransport, serverTransport] =
      InMemoryTransport.createLinkedPair();

    try {
      await server.connect(serverTransport);
      await client.connect(clientTransport);

      expect(client.getServerVersion()?.version).toBe(packageVersion);
      expect(
        client.getServerCapabilities()?.experimental?.[
          VALIDATOR_CAPABILITY_KEY
        ],
      ).toEqual(expectedCapability);
    } finally {
      await client.close();
      await server.close();
    }
  });
});
