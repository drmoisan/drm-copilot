import { describe, expect, it, jest } from "@jest/globals";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import * as fs from "node:fs";
import * as path from "node:path";

jest.mock("vscode", () => ({ window: {} }), { virtual: true });

import {
  assertRepoAutomationMcpVersionConsistency,
  createRepoAutomationMcpServer,
  VALIDATOR_CAPABILITY_KEY,
  type RepoAutomationMcpVersionContract,
} from "../src/mcp-server";

function readManifestVersion(packageJsonPath: string): string {
  const manifest = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8")) as {
    readonly version: string;
  };
  return manifest.version;
}

describe("MCP server version consistency", () => {
  it("reports the same version from both manifests, serverInfo, and capability metadata", async () => {
    const extensionVersion = readManifestVersion(
      path.resolve(__dirname, "..", "package.json"),
    );
    const packageVersion = readManifestVersion(
      path.resolve(
        __dirname,
        "..",
        "..",
        "..",
        "packages",
        "mcp-server",
        "package.json",
      ),
    );
    const server = createRepoAutomationMcpServer();
    const client = new Client(
      { name: "version-contract-test", version: "1.0.0" },
      { capabilities: {} },
    );
    const [clientTransport, serverTransport] =
      InMemoryTransport.createLinkedPair();

    try {
      await server.connect(serverTransport);
      await client.connect(clientTransport);
      const capability = client.getServerCapabilities()?.experimental?.[
        VALIDATOR_CAPABILITY_KEY
      ] as { readonly package_version?: unknown } | undefined;

      expect(extensionVersion).toBe(packageVersion);
      expect(client.getServerVersion()?.version).toBe(extensionVersion);
      expect(capability?.package_version).toBe(extensionVersion);
    } finally {
      await client.close();
      await server.close();
    }
  });

  it.each<keyof RepoAutomationMcpVersionContract>([
    "serverInfoVersion",
    "capabilityPackageVersion",
    "extensionManifestVersion",
    "packageManifestVersion",
  ])("rejects a %s mismatch", (field) => {
    const contract: RepoAutomationMcpVersionContract = {
      serverInfoVersion: "1.0.24",
      capabilityPackageVersion: "1.0.24",
      extensionManifestVersion: "1.0.24",
      packageManifestVersion: "1.0.24",
      [field]: "9.9.9",
    };

    expect(() => assertRepoAutomationMcpVersionConsistency(contract)).toThrow(
      "MCP package version mismatch",
    );
  });
});
