import * as fs from "node:fs";
import * as path from "node:path";
import { createHash } from "node:crypto";
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
import {
  VALIDATOR_ARTIFACT_TYPES,
  VALIDATOR_VALIDATION_FLAGS,
} from "./mcp-validator-catalog";

declare const __DRM_MCP_BUNDLE_SHA256__: string | undefined;

export interface RepoAutomationMcpServerOptions {
  readonly extensionRoot?: string;
  readonly createService?: (output: {
    appendLine(line: string): void;
  }) => RepoAutomationService;
}

export interface RepoAutomationMcpVersionContract {
  readonly serverInfoVersion: string;
  readonly capabilityPackageVersion: string;
  readonly extensionManifestVersion: string;
  readonly packageManifestVersion: string;
}

export interface ValidatorCapabilityComparisonRequirements {
  readonly validatorContractVersion: number;
  readonly remediationLoopSchemaVersion: number;
  readonly requiredValidationFlags: ReadonlyArray<string>;
  readonly requiredArtifactTypes: ReadonlyArray<string>;
  readonly packageVersion: string;
  readonly bundleSha256: string;
  readonly routingPolicySha256: string;
}

export interface ValidatorCapabilityComparisonInput {
  readonly serverInfoVersion: unknown;
  readonly capability: unknown;
  readonly requirements: ValidatorCapabilityComparisonRequirements;
}

/**
 * Public validator contract summary.
 *
 * `REVIEW_VERDICT`, `REMEDIATION_ACTION`, fingerprint, and path fields feed
 * remediation-loop schema version 2, whose attempts are distinct from cycles
 * completed only after commit and R4.
 * Non-actionable reviews stop before R1; unchanged blockers stop for stagnation
 * unless an exact unused exception applies. The sole unresolved three-cycle
 * status is `blocked_remediation_loop_limit`; `blocked_cycle_limit` is rejected
 * legacy input. Stable `ORCH_*` codes preserve diagnostic and routing-gate
 * identity. Research uses a tracked feature `research/` folder or
 * `docs/research/`. `require_pr_creation_ready` excludes PR, CI, and pr-author
 * gates, while `require_complete` retains them. Local source, built, and packed
 * candidates must have
 * parity before release; incompatible published runtimes are external-runtime
 * evidence and do not authorize publication or consumer-pin changes.
 */
export const VALIDATOR_CAPABILITY_KEY = "drm-copilot/validator";
export const VALIDATOR_CONTRACT_VERSION = 1;
export const REMEDIATION_LOOP_SCHEMA_VERSIONS = [2] as const;
const PENDING_BUNDLE_SHA256 = `sha256:${"0".repeat(64)}`;
const BUNDLE_SHA256 =
  typeof __DRM_MCP_BUNDLE_SHA256__ === "string"
    ? __DRM_MCP_BUNDLE_SHA256__
    : PENDING_BUNDLE_SHA256;
export const VALIDATOR_CAPABILITY_COMPARISON_CODES = Object.freeze({
  missing: "ORCH_VALIDATOR_CAPABILITY_MISSING",
  contract: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:CONTRACT",
  schema: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:SCHEMA",
  flag: "ORCH_VALIDATOR_CAPABILITY_MISSING:FLAG",
  artifact: "ORCH_VALIDATOR_CAPABILITY_MISSING:ARTIFACT",
  package: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:PACKAGE",
  bundle: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:BUNDLE",
  routing: "ORCH_ROUTING_POLICY_DIGEST_MISMATCH",
});
export type ValidatorCapabilityComparisonCode =
  (typeof VALIDATOR_CAPABILITY_COMPARISON_CODES)[keyof typeof VALIDATOR_CAPABILITY_COMPARISON_CODES];
const REQUIRED_VALIDATOR_CAPABILITY_FIELDS = [
  "validator_contract_version",
  "remediation_loop_schema_versions",
  "supported_artifact_types",
  "supported_validation_flags",
  "routing_policy_sha256",
  "package_version",
  "bundle_sha256",
] as const;

function readRoutingPolicySha256(extensionRoot: string): string {
  const resourcePath = path.join(
    extensionRoot,
    "resources",
    "config",
    "orchestration-routing.json",
  );
  return `sha256:${createHash("sha256")
    .update(fs.readFileSync(resourcePath))
    .digest("hex")}`;
}

/** Build the complete validator capability shape for MCP initialization. */
export function buildValidatorCapability(
  packageVersion: string,
  routingPolicySha256: string,
) {
  return {
    validator_contract_version: VALIDATOR_CONTRACT_VERSION,
    remediation_loop_schema_versions: REMEDIATION_LOOP_SCHEMA_VERSIONS,
    supported_artifact_types: [...VALIDATOR_ARTIFACT_TYPES],
    supported_validation_flags: [...VALIDATOR_VALIDATION_FLAGS],
    routing_policy_sha256: routingPolicySha256,
    package_version: packageVersion,
    bundle_sha256: BUNDLE_SHA256,
  };
}

/** Return the same public tool list exposed by the MCP list-tools handler. */
export function listRepoAutomationMcpTools() {
  return listRepoAutomationTools();
}

function resolveExtensionRoot(): string {
  return path.resolve(__dirname, "..");
}

function readPackageVersion(packageJsonPath: string): string {
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8")) as {
    readonly version?: unknown;
  };
  if (
    typeof packageJson.version !== "string" ||
    packageJson.version.trim().length === 0
  ) {
    throw new Error(`Package manifest '${packageJsonPath}' has no version.`);
  }
  return packageJson.version;
}

/** Reject any version drift across the MCP initialization contract. */
export function assertRepoAutomationMcpVersionConsistency(
  contract: RepoAutomationMcpVersionContract,
): string {
  const entries = [
    ["serverInfo.version", contract.serverInfoVersion],
    ["capability.package_version", contract.capabilityPackageVersion],
    ["extensions/drm-copilot/package.json", contract.extensionManifestVersion],
    ["packages/mcp-server/package.json", contract.packageManifestVersion],
  ] as const;
  if (new Set(entries.map(([, version]) => version)).size !== 1) {
    throw new Error(
      `MCP package version mismatch: ${entries
        .map(([source, version]) => `${source}=${version}`)
        .join("; ")}.`,
    );
  }
  return contract.serverInfoVersion;
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function includesEveryString(
  actual: unknown,
  required: ReadonlyArray<string>,
): boolean {
  return (
    Array.isArray(actual) &&
    actual.every((value) => typeof value === "string") &&
    required.every((value) => actual.includes(value))
  );
}

function includesNumber(actual: unknown, required: number): boolean {
  return (
    Array.isArray(actual) &&
    actual.every((value) => typeof value === "number") &&
    actual.includes(required)
  );
}

/** Compare active MCP validator metadata in stable diagnostic order. */
export function compareValidatorCapabilities(
  input: ValidatorCapabilityComparisonInput,
): ReadonlyArray<ValidatorCapabilityComparisonCode> {
  const { capability, requirements } = input;
  if (!isRecord(capability)) {
    return [VALIDATOR_CAPABILITY_COMPARISON_CODES.missing];
  }

  const codes: ValidatorCapabilityComparisonCode[] = [];
  if (
    REQUIRED_VALIDATOR_CAPABILITY_FIELDS.some(
      (field) => !Object.hasOwn(capability, field),
    )
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.missing);
  }
  if (
    Object.hasOwn(capability, "validator_contract_version") &&
    capability["validator_contract_version"] !==
      requirements.validatorContractVersion
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.contract);
  }
  if (
    Object.hasOwn(capability, "remediation_loop_schema_versions") &&
    !includesNumber(
      capability["remediation_loop_schema_versions"],
      requirements.remediationLoopSchemaVersion,
    )
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.schema);
  }
  if (
    Object.hasOwn(capability, "supported_validation_flags") &&
    !includesEveryString(
      capability["supported_validation_flags"],
      requirements.requiredValidationFlags,
    )
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.flag);
  }
  if (
    Object.hasOwn(capability, "supported_artifact_types") &&
    !includesEveryString(
      capability["supported_artifact_types"],
      requirements.requiredArtifactTypes,
    )
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.artifact);
  }
  if (
    Object.hasOwn(capability, "package_version") &&
    (capability["package_version"] !== requirements.packageVersion ||
      input.serverInfoVersion !== requirements.packageVersion ||
      capability["package_version"] !== input.serverInfoVersion)
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.package);
  }
  if (
    Object.hasOwn(capability, "bundle_sha256") &&
    capability["bundle_sha256"] !== requirements.bundleSha256
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.bundle);
  }
  if (
    Object.hasOwn(capability, "routing_policy_sha256") &&
    capability["routing_policy_sha256"] !== requirements.routingPolicySha256
  ) {
    codes.push(VALIDATOR_CAPABILITY_COMPARISON_CODES.routing);
  }
  return codes;
}

function resolvePackageVersion(extensionRoot: string): string {
  const runtimeManifestPath = path.join(extensionRoot, "package.json");
  const runtimeVersion = readPackageVersion(runtimeManifestPath);
  const repositoryRoot = path.resolve(extensionRoot, "..", "..");
  const extensionManifestPath = path.join(
    repositoryRoot,
    "extensions",
    "drm-copilot",
    "package.json",
  );
  const packageManifestPath = path.join(
    repositoryRoot,
    "packages",
    "mcp-server",
    "package.json",
  );
  const hasRepositoryManifests =
    fs.existsSync(extensionManifestPath) && fs.existsSync(packageManifestPath);
  const extensionManifestVersion = hasRepositoryManifests
    ? readPackageVersion(extensionManifestPath)
    : runtimeVersion;
  const packageManifestVersion = hasRepositoryManifests
    ? readPackageVersion(packageManifestPath)
    : runtimeVersion;
  return assertRepoAutomationMcpVersionConsistency({
    serverInfoVersion: runtimeVersion,
    capabilityPackageVersion: runtimeVersion,
    extensionManifestVersion,
    packageManifestVersion,
  });
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
  const packageVersion = resolvePackageVersion(extensionRoot);
  const routingPolicySha256 = readRoutingPolicySha256(extensionRoot);
  const server = new Server(
    {
      name: "drmCopilotExtension",
      version: packageVersion,
    },
    {
      capabilities: {
        tools: {},
        experimental: {
          [VALIDATOR_CAPABILITY_KEY]: buildValidatorCapability(
            packageVersion,
            routingPolicySha256,
          ),
        },
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
