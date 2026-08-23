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
exports.VALIDATOR_CAPABILITY_COMPARISON_CODES = exports.REMEDIATION_LOOP_SCHEMA_VERSIONS = exports.VALIDATOR_CONTRACT_VERSION = exports.VALIDATOR_CAPABILITY_KEY = void 0;
exports.buildValidatorCapability = buildValidatorCapability;
exports.listRepoAutomationMcpTools = listRepoAutomationMcpTools;
exports.assertRepoAutomationMcpVersionConsistency = assertRepoAutomationMcpVersionConsistency;
exports.compareValidatorCapabilities = compareValidatorCapabilities;
exports.createRepoAutomationMcpServer = createRepoAutomationMcpServer;
exports.main = main;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const node_crypto_1 = require("node:crypto");
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
const command_runtime_1 = require("./command-runtime");
const mcp_tools_1 = require("./mcp-tools");
const repo_automation_service_1 = require("./repo-automation-service");
const mcp_validator_catalog_1 = require("./mcp-validator-catalog");
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
exports.VALIDATOR_CAPABILITY_KEY = "drm-copilot/validator";
exports.VALIDATOR_CONTRACT_VERSION = 1;
exports.REMEDIATION_LOOP_SCHEMA_VERSIONS = [2];
const PENDING_BUNDLE_SHA256 = `sha256:${"0".repeat(64)}`;
const BUNDLE_SHA256 = typeof __DRM_MCP_BUNDLE_SHA256__ === "string"
    ? __DRM_MCP_BUNDLE_SHA256__
    : PENDING_BUNDLE_SHA256;
exports.VALIDATOR_CAPABILITY_COMPARISON_CODES = Object.freeze({
    missing: "ORCH_VALIDATOR_CAPABILITY_MISSING",
    contract: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:CONTRACT",
    schema: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:SCHEMA",
    flag: "ORCH_VALIDATOR_CAPABILITY_MISSING:FLAG",
    artifact: "ORCH_VALIDATOR_CAPABILITY_MISSING:ARTIFACT",
    package: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:PACKAGE",
    bundle: "ORCH_VALIDATOR_VERSION_INCOMPATIBLE:BUNDLE",
    routing: "ORCH_ROUTING_POLICY_DIGEST_MISMATCH",
});
const REQUIRED_VALIDATOR_CAPABILITY_FIELDS = [
    "validator_contract_version",
    "remediation_loop_schema_versions",
    "supported_artifact_types",
    "supported_validation_flags",
    "routing_policy_sha256",
    "package_version",
    "bundle_sha256",
];
function readRoutingPolicySha256(extensionRoot) {
    const resourcePath = path.join(extensionRoot, "resources", "config", "orchestration-routing.json");
    return `sha256:${(0, node_crypto_1.createHash)("sha256")
        .update(fs.readFileSync(resourcePath))
        .digest("hex")}`;
}
/** Build the complete validator capability shape for MCP initialization. */
function buildValidatorCapability(packageVersion, routingPolicySha256) {
    return {
        validator_contract_version: exports.VALIDATOR_CONTRACT_VERSION,
        remediation_loop_schema_versions: exports.REMEDIATION_LOOP_SCHEMA_VERSIONS,
        supported_artifact_types: [...mcp_validator_catalog_1.VALIDATOR_ARTIFACT_TYPES],
        supported_validation_flags: [...mcp_validator_catalog_1.VALIDATOR_VALIDATION_FLAGS],
        routing_policy_sha256: routingPolicySha256,
        package_version: packageVersion,
        bundle_sha256: BUNDLE_SHA256,
    };
}
/** Return the same public tool list exposed by the MCP list-tools handler. */
function listRepoAutomationMcpTools() {
    return (0, mcp_tools_1.listRepoAutomationTools)();
}
function resolveExtensionRoot() {
    return path.resolve(__dirname, "..");
}
function readPackageVersion(packageJsonPath) {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf-8"));
    if (typeof packageJson.version !== "string" ||
        packageJson.version.trim().length === 0) {
        throw new Error(`Package manifest '${packageJsonPath}' has no version.`);
    }
    return packageJson.version;
}
/** Reject any version drift across the MCP initialization contract. */
function assertRepoAutomationMcpVersionConsistency(contract) {
    const entries = [
        ["serverInfo.version", contract.serverInfoVersion],
        ["capability.package_version", contract.capabilityPackageVersion],
        ["extensions/drm-copilot/package.json", contract.extensionManifestVersion],
        ["packages/mcp-server/package.json", contract.packageManifestVersion],
    ];
    if (new Set(entries.map(([, version]) => version)).size !== 1) {
        throw new Error(`MCP package version mismatch: ${entries
            .map(([source, version]) => `${source}=${version}`)
            .join("; ")}.`);
    }
    return contract.serverInfoVersion;
}
function isRecord(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function includesEveryString(actual, required) {
    return (Array.isArray(actual) &&
        actual.every((value) => typeof value === "string") &&
        required.every((value) => actual.includes(value)));
}
function includesNumber(actual, required) {
    return (Array.isArray(actual) &&
        actual.every((value) => typeof value === "number") &&
        actual.includes(required));
}
/** Compare active MCP validator metadata in stable diagnostic order. */
function compareValidatorCapabilities(input) {
    const { capability, requirements } = input;
    if (!isRecord(capability)) {
        return [exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.missing];
    }
    const codes = [];
    if (REQUIRED_VALIDATOR_CAPABILITY_FIELDS.some((field) => !Object.hasOwn(capability, field))) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.missing);
    }
    if (Object.hasOwn(capability, "validator_contract_version") &&
        capability["validator_contract_version"] !==
            requirements.validatorContractVersion) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.contract);
    }
    if (Object.hasOwn(capability, "remediation_loop_schema_versions") &&
        !includesNumber(capability["remediation_loop_schema_versions"], requirements.remediationLoopSchemaVersion)) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.schema);
    }
    if (Object.hasOwn(capability, "supported_validation_flags") &&
        !includesEveryString(capability["supported_validation_flags"], requirements.requiredValidationFlags)) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.flag);
    }
    if (Object.hasOwn(capability, "supported_artifact_types") &&
        !includesEveryString(capability["supported_artifact_types"], requirements.requiredArtifactTypes)) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.artifact);
    }
    if (Object.hasOwn(capability, "package_version") &&
        (capability["package_version"] !== requirements.packageVersion ||
            input.serverInfoVersion !== requirements.packageVersion ||
            capability["package_version"] !== input.serverInfoVersion)) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.package);
    }
    if (Object.hasOwn(capability, "bundle_sha256") &&
        capability["bundle_sha256"] !== requirements.bundleSha256) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.bundle);
    }
    if (Object.hasOwn(capability, "routing_policy_sha256") &&
        capability["routing_policy_sha256"] !== requirements.routingPolicySha256) {
        codes.push(exports.VALIDATOR_CAPABILITY_COMPARISON_CODES.routing);
    }
    return codes;
}
function resolvePackageVersion(extensionRoot) {
    const runtimeManifestPath = path.join(extensionRoot, "package.json");
    const runtimeVersion = readPackageVersion(runtimeManifestPath);
    const repositoryRoot = path.resolve(extensionRoot, "..", "..");
    const extensionManifestPath = path.join(repositoryRoot, "extensions", "drm-copilot", "package.json");
    const packageManifestPath = path.join(repositoryRoot, "packages", "mcp-server", "package.json");
    const hasRepositoryManifests = fs.existsSync(extensionManifestPath) && fs.existsSync(packageManifestPath);
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
    const packageVersion = resolvePackageVersion(extensionRoot);
    const routingPolicySha256 = readRoutingPolicySha256(extensionRoot);
    const server = new index_js_1.Server({
        name: "drmCopilotExtension",
        version: packageVersion,
    }, {
        capabilities: {
            tools: {},
            experimental: {
                [exports.VALIDATOR_CAPABILITY_KEY]: buildValidatorCapability(packageVersion, routingPolicySha256),
            },
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
