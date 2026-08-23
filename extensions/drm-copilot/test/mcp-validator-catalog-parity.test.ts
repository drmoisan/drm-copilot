import { createHash } from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import { gunzipSync } from "node:zlib";
import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({ window: {} }), { virtual: true });

import { toolDefinitions } from "../src/mcp-tool-definitions";
import { REPO_AUTOMATION_TOOL_DEFINITIONS } from "../src/mcp-repo-automation-tool-definitions";
import {
  assertValidatorCatalogParity,
  VALIDATOR_ARTIFACT_TYPES,
  VALIDATOR_FLAG_DEFINITIONS,
  VALIDATOR_VALIDATION_FLAGS,
} from "../src/mcp-validator-catalog";
import {
  REMEDIATION_LOOP_SCHEMA_VERSIONS,
  VALIDATOR_CONTRACT_VERSION,
} from "../src/mcp-server";
import { VALIDATE_ORCHESTRATION_BUILDER_FLAG_OPTIONS } from "../src/lib/validate/build-validate-orchestration-service-call-input";
import { VALIDATE_ORCHESTRATION_SERVICE_CALL_FLAG_OPTIONS } from "../src/lib/validate/validate-orchestration-service-call";

interface CapabilityMetadata {
  readonly validator_contract_version: number;
  readonly remediation_loop_schema_versions: ReadonlyArray<number>;
  readonly supported_artifact_types: ReadonlyArray<string>;
  readonly supported_validation_flags: ReadonlyArray<string>;
  readonly routing_policy_sha256: string;
  readonly package_version: string;
  readonly bundle_sha256: string;
}

interface BundleExports {
  buildValidatorCapability(
    packageVersion: string,
    routingPolicySha256: string,
  ): CapabilityMetadata;
  listRepoAutomationMcpTools(): ReadonlyArray<{
    readonly name: string;
    readonly inputSchema: unknown;
  }>;
}

const REPOSITORY_ROOT = path.resolve(__dirname, "..", "..", "..");
const EXTENSION_BUNDLE_PATH = path.join(
  REPOSITORY_ROOT,
  "extensions",
  "drm-copilot",
  "out",
  "mcp-server.js",
);
const PACKAGE_BUNDLE_PATH = path.join(
  REPOSITORY_ROOT,
  "packages",
  "mcp-server",
  "out",
  "mcp-server.js",
);
const PACKAGE_MANIFEST_PATH = path.join(
  REPOSITORY_ROOT,
  "packages",
  "mcp-server",
  "package.json",
);
const packageManifest = JSON.parse(
  fs.readFileSync(PACKAGE_MANIFEST_PATH, "utf8"),
) as { readonly version: string };
const TARBALL_PATH = path.join(
  REPOSITORY_ROOT,
  "docs",
  "features",
  "active",
  "2026-08-17-orchestrator-remediation-loop-control-484",
  "evidence",
  "regression-testing",
  `danmoisan-drm-copilot-mcp-${packageManifest.version}.tgz`,
);

function validatorSchema(
  definitions: ReadonlyArray<{
    readonly name: string;
    readonly inputSchema: unknown;
  }>,
): unknown {
  return definitions.find(
    ({ name }) => name === "validate_orchestration_artifacts",
  )?.inputSchema;
}

function executeBundle(bundle: Buffer, filename: string): BundleExports {
  const source = bundle.toString("utf8").replace(/^#![^\r\n]*(?:\r?\n)/, "");
  const moduleRecord: { exports: Record<string, unknown> } = { exports: {} };
  const execute = new Function(
    "exports",
    "require",
    "module",
    "__filename",
    "__dirname",
    source,
  ) as (
    exports: Record<string, unknown>,
    requireFunction: NodeRequire,
    module: { exports: Record<string, unknown> },
    moduleFilename: string,
    moduleDirectory: string,
  ) => void;
  execute(
    moduleRecord.exports,
    require,
    moduleRecord,
    filename,
    path.dirname(filename),
  );
  const exported = moduleRecord.exports as Partial<BundleExports>;
  if (
    typeof exported.buildValidatorCapability !== "function" ||
    typeof exported.listRepoAutomationMcpTools !== "function"
  ) {
    throw new Error("Built MCP bundle does not expose validator contracts.");
  }
  return exported as BundleExports;
}

function readTarEntries(tarball: Buffer): ReadonlyMap<string, Buffer> {
  const tar = gunzipSync(tarball);
  const entries = new Map<string, Buffer>();
  let offset = 0;
  while (offset + 512 <= tar.length) {
    const header = tar.subarray(offset, offset + 512);
    if (header.every((value) => value === 0)) {
      break;
    }
    const readText = (start: number, end: number) =>
      header.subarray(start, end).toString("utf8").replace(/\0.*$/s, "");
    const name = readText(0, 100);
    const prefix = readText(345, 500);
    const entryName = prefix.length > 0 ? `${prefix}/${name}` : name;
    const size = Number.parseInt(readText(124, 136).trim() || "0", 8);
    const contentOffset = offset + 512;
    entries.set(entryName, tar.subarray(contentOffset, contentOffset + size));
    offset = contentOffset + Math.ceil(size / 512) * 512;
  }
  return entries;
}

function requireEntry(entries: ReadonlyMap<string, Buffer>, name: string) {
  const entry = entries.get(name);
  if (entry === undefined) {
    throw new Error(`Packed MCP tarball is missing '${name}'.`);
  }
  return entry;
}

describe("validator catalog parity", () => {
  it("derives builder and service-call options from the canonical catalog", () => {
    const optionNames = VALIDATOR_FLAG_DEFINITIONS.map(
      ({ optionName }) => optionName,
    );
    expect(VALIDATE_ORCHESTRATION_BUILDER_FLAG_OPTIONS).toEqual(optionNames);
    expect(VALIDATE_ORCHESTRATION_SERVICE_CALL_FLAG_OPTIONS).toEqual(
      optionNames,
    );
    expect(validatorSchema(toolDefinitions)).toEqual(
      validatorSchema(REPO_AUTOMATION_TOOL_DEFINITIONS),
    );
  });

  it("rejects any value or order divergence with a deterministic code", () => {
    expect(() =>
      assertValidatorCatalogParity(
        {
          name: "canonical",
          artifactTypes: VALIDATOR_ARTIFACT_TYPES,
          validationFlags: VALIDATOR_VALIDATION_FLAGS,
        },
        [
          {
            name: "divergent",
            artifactTypes: [...VALIDATOR_ARTIFACT_TYPES].reverse(),
            validationFlags: VALIDATOR_VALIDATION_FLAGS,
          },
        ],
      ),
    ).toThrow(
      "ORCH_VALIDATOR_CATALOG_DIVERGENCE: 'divergent' does not match 'canonical'.",
    );
  });

  const artifactsAvailable = [
    EXTENSION_BUNDLE_PATH,
    PACKAGE_BUNDLE_PATH,
    TARBALL_PATH,
  ].every((artifactPath) => fs.existsSync(artifactPath));

  (artifactsAvailable ? it : it.skip)(
    "matches schema and capability metadata across source, built, and packed bundles",
    () => {
      const extensionBundle = fs.readFileSync(EXTENSION_BUNDLE_PATH);
      const packageBundle = fs.readFileSync(PACKAGE_BUNDLE_PATH);
      const tarEntries = readTarEntries(fs.readFileSync(TARBALL_PATH));
      const packedBundle = requireEntry(
        tarEntries,
        "package/out/mcp-server.js",
      );
      const canonicalRouting = fs.readFileSync(
        path.join(REPOSITORY_ROOT, "config", "orchestration-routing.json"),
      );
      const packedRouting = requireEntry(
        tarEntries,
        "package/resources/config/orchestration-routing.json",
      );
      const packedManifest = JSON.parse(
        requireEntry(tarEntries, "package/package.json").toString("utf8"),
      ) as { readonly version: string };
      const routingSha256 = `sha256:${createHash("sha256")
        .update(canonicalRouting)
        .digest("hex")}`;
      const modules = [
        executeBundle(extensionBundle, EXTENSION_BUNDLE_PATH),
        executeBundle(packageBundle, PACKAGE_BUNDLE_PATH),
        executeBundle(packedBundle, "package/out/mcp-server.js"),
      ];
      const capabilities = modules.map((bundleModule) =>
        bundleModule.buildValidatorCapability(
          packageManifest.version,
          routingSha256,
        ),
      );

      expect(packageBundle).toEqual(extensionBundle);
      expect(packedBundle).toEqual(extensionBundle);
      expect(packedRouting).toEqual(canonicalRouting);
      expect(packedManifest.version).toBe(packageManifest.version);
      for (const bundleModule of modules) {
        expect(
          validatorSchema(bundleModule.listRepoAutomationMcpTools()),
        ).toEqual(validatorSchema(toolDefinitions));
      }
      expect(capabilities[0]).toMatchObject({
        validator_contract_version: VALIDATOR_CONTRACT_VERSION,
        remediation_loop_schema_versions: [...REMEDIATION_LOOP_SCHEMA_VERSIONS],
        supported_artifact_types: [...VALIDATOR_ARTIFACT_TYPES],
        supported_validation_flags: [...VALIDATOR_VALIDATION_FLAGS],
        routing_policy_sha256: routingSha256,
        package_version: packageManifest.version,
        bundle_sha256: expect.stringMatching(/^sha256:[0-9a-f]{64}$/),
      });
      expect(capabilities[1]).toEqual(capabilities[0]);
      expect(capabilities[2]).toEqual(capabilities[0]);
      assertValidatorCatalogParity(
        {
          name: "canonical",
          artifactTypes: VALIDATOR_ARTIFACT_TYPES,
          validationFlags: VALIDATOR_VALIDATION_FLAGS,
        },
        capabilities.map((capability, index) => ({
          name: `bundle-${index}`,
          artifactTypes: capability.supported_artifact_types,
          validationFlags: capability.supported_validation_flags,
        })),
      );
    },
  );
});
