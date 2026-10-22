/**
 * Validate the v2 discovery service result read from the fixed runtime.
 *
 * The gateway prints exactly one JSON document. This module decides whether
 * that document is a structurally valid `service-result` whose exit code
 * agrees with the process exit, and converts it into the host execution
 * result. Malformed, truncated, unsupported-version or inconsistent output is
 * a blocking transport error; it is never reported as a successful operation.
 * No human-readable sentence is parsed to discover paths or outcomes.
 */

import type { RepoAutomationExecutionResult } from "./repo-automation-service-contract";
import type { RepoAutomationToolName } from "./repo-automation-tool-names";
import type {
  DiscoveryArtifact,
  DiscoveryExitCode,
  DiscoveryFinding,
  DiscoveryMode,
  DiscoveryOperation,
  DiscoveryRuntimeIdentity,
  DiscoveryServiceResult,
  DiscoverySummary,
} from "./discovery-service-types";

export const SUPPORTED_RESULT_VERSION = "2.0.0";
export const SUPPORTED_RUNTIME_PACKAGE_VERSION = "2.0.0";
export const SUPPORTED_RUNTIME_SCHEMA_VERSION = "2.0.0";

export const DISCOVERY_OPERATIONS: ReadonlyArray<DiscoveryOperation> = [
  "init",
  "configure",
  "profile",
  "inventory",
  "new-contract",
  "new-scenario",
  "update-artifact",
  "link-evidence",
  "validate-profile",
  "validate-feature-contract",
  "validate-coverage-ledger",
  "validate-runtime-scenario",
  "validate-parity-matrix",
  "validate-unspecified-behavior",
  "validate-product-decision",
  "validate-evidence-reference",
  "validate-decisions",
  "validate-all",
  "coverage-report",
  "parity-report",
  "completion-report",
  "generate-acceptance",
  "snapshot-export",
  "snapshot-import",
  "import-inventory",
  "migrate",
  "doctor",
  "read-source",
  "prepare-agent",
  "finalize-agent",
];
export const DISCOVERY_MODES: ReadonlyArray<DiscoveryMode> = [
  "structural",
  "agent-output",
  "discovery-complete",
  "parity-complete",
  "planning",
];
const SEVERITIES: ReadonlyArray<string> = ["error", "warning", "info"];
const ARTIFACT_STATUSES: ReadonlyArray<string> = [
  "planned",
  "created",
  "updated",
  "skipped",
  "conflict",
];
const EXIT_CODES: ReadonlyArray<number> = [0, 1, 2, 3];
const SHA256 = /^[0-9a-f]{64}$/;

export type DiscoveryTransportErrorCode =
  | "DISCOVERY_RESULT_EMPTY"
  | "DISCOVERY_RESULT_MALFORMED"
  | "DISCOVERY_RESULT_VERSION_UNSUPPORTED"
  | "DISCOVERY_RESULT_EXIT_MISMATCH"
  | "DISCOVERY_RUNTIME_INCOMPATIBLE"
  | "DISCOVERY_RUNTIME_MISSING"
  | "DISCOVERY_INTERPRETER_UNAVAILABLE"
  | "DISCOVERY_WORKSPACE_ROOT_INVALID"
  | "DISCOVERY_REQUEST_INVALID";

/** Blocking transport failure between the host and the fixed runtime. */
export class DiscoveryTransportError extends Error {
  readonly code: DiscoveryTransportErrorCode;
  readonly stderr: string;
  readonly exitCode: number | null;

  constructor(input: {
    readonly code: DiscoveryTransportErrorCode;
    readonly message: string;
    readonly stderr?: string;
    readonly exitCode?: number | null;
  }) {
    super(`${input.code}: ${input.message}`);
    this.name = "DiscoveryTransportError";
    this.code = input.code;
    this.stderr = input.stderr ?? "";
    this.exitCode = input.exitCode ?? null;
  }
}

/** A structurally valid result whose operation did not succeed (exit 1, 2 or 3). */
export class DiscoveryOperationError extends Error {
  readonly result: DiscoveryServiceResult;

  constructor(result: DiscoveryServiceResult) {
    const blocking = result.findings.find(
      (finding) => finding.severity === "error",
    );
    super(
      `Discovery ${result.operation ?? "request"} failed with exit ${String(result.exit_code)}` +
        (blocking === undefined
          ? "."
          : `: ${blocking.code}: ${blocking.message}`),
    );
    this.name = "DiscoveryOperationError";
    this.result = result;
  }
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isStringArray(value: unknown): value is ReadonlyArray<string> {
  return (
    Array.isArray(value) && value.every((item) => typeof item === "string")
  );
}

function malformed(detail: string, context: ResultContext): never {
  throw new DiscoveryTransportError({
    code: "DISCOVERY_RESULT_MALFORMED",
    message: `The discovery runtime result is not a valid service-result: ${detail}.`,
    stderr: context.stderr,
    exitCode: context.exitCode,
  });
}

/** Process facts the result must agree with. */
export interface ResultContext {
  readonly exitCode: number | null;
  readonly stderr: string;
}

function validateFinding(
  value: unknown,
  context: ResultContext,
): DiscoveryFinding {
  if (
    !isObject(value) ||
    typeof value["code"] !== "string" ||
    !SEVERITIES.includes(String(value["severity"])) ||
    (value["artifact_path"] !== null &&
      typeof value["artifact_path"] !== "string") ||
    typeof value["pointer"] !== "string" ||
    !isStringArray(value["related_ids"]) ||
    !isStringArray(value["related_paths"]) ||
    typeof value["message"] !== "string" ||
    typeof value["next_action"] !== "string"
  ) {
    return malformed("a finding is missing a required field", context);
  }
  return value as unknown as DiscoveryFinding;
}

function validateArtifact(
  value: unknown,
  context: ResultContext,
): DiscoveryArtifact {
  if (
    !isObject(value) ||
    typeof value["path"] !== "string" ||
    typeof value["kind"] !== "string" ||
    !ARTIFACT_STATUSES.includes(String(value["status"])) ||
    typeof value["sha256"] !== "string" ||
    !SHA256.test(value["sha256"]) ||
    (value["content"] !== undefined && typeof value["content"] !== "string")
  ) {
    return malformed("an artifact is missing a required field", context);
  }
  return value as unknown as DiscoveryArtifact;
}

function validateSummary(
  value: unknown,
  context: ResultContext,
): DiscoverySummary {
  if (
    !isObject(value) ||
    typeof value["message"] !== "string" ||
    !Array.isArray(value["counts"]) ||
    (value["validation_result"] !== null &&
      typeof value["validation_result"] !== "string") ||
    (value["receipt_ref"] !== null &&
      typeof value["receipt_ref"] !== "string") ||
    (value["invocation_ref"] !== null &&
      typeof value["invocation_ref"] !== "string")
  ) {
    return malformed("the summary is missing a required field", context);
  }
  // Every count is a named non-negative integer; anything else is malformed.
  for (const count of value["counts"]) {
    if (
      !isObject(count) ||
      typeof count["name"] !== "string" ||
      typeof count["value"] !== "number" ||
      !Number.isInteger(count["value"]) ||
      count["value"] < 0
    ) {
      return malformed("a summary count is invalid", context);
    }
  }
  return value as unknown as DiscoverySummary;
}

function validateRuntime(
  value: unknown,
  context: ResultContext,
): DiscoveryRuntimeIdentity | null {
  if (value === null) {
    return null;
  }
  if (
    !isObject(value) ||
    typeof value["package_version"] !== "string" ||
    typeof value["schema_version"] !== "string" ||
    typeof value["build_sha256"] !== "string" ||
    !SHA256.test(value["build_sha256"]) ||
    typeof value["policy_version"] !== "number" ||
    typeof value["policy_sha256"] !== "string" ||
    !SHA256.test(value["policy_sha256"])
  ) {
    return malformed("the runtime identity is incomplete", context);
  }
  // The host supports exactly one runtime package/schema version pair.
  if (
    value["package_version"] !== SUPPORTED_RUNTIME_PACKAGE_VERSION ||
    value["schema_version"] !== SUPPORTED_RUNTIME_SCHEMA_VERSION
  ) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_RUNTIME_INCOMPATIBLE",
      message:
        `Installed discovery runtime ${value["package_version"]} (schema ${value["schema_version"]}) ` +
        `is not the supported ${SUPPORTED_RUNTIME_PACKAGE_VERSION}/${SUPPORTED_RUNTIME_SCHEMA_VERSION}; ` +
        "install the matching wheel into the configured interpreter.",
      stderr: context.stderr,
      exitCode: context.exitCode,
    });
  }
  return value as unknown as DiscoveryRuntimeIdentity;
}

/**
 * Parse and validate the gateway stdout as a v2 service result.
 *
 * @param stdout The complete stdout text of the runtime process.
 * @param context The observed process exit code and stderr.
 * @returns The validated result, including non-ok results with exit 1, 2 or 3.
 * @throws DiscoveryTransportError for empty, malformed, truncated, wrong-version
 *   or process-inconsistent output.
 */
export function parseDiscoveryResult(
  stdout: string,
  context: ResultContext,
): DiscoveryServiceResult {
  const trimmed = stdout.trim();
  if (trimmed.length === 0) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_RESULT_EMPTY",
      message: "The discovery runtime produced no result document.",
      stderr: context.stderr,
      exitCode: context.exitCode,
    });
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(trimmed);
  } catch {
    return malformed("stdout is not one complete JSON document", context);
  }
  if (!isObject(parsed)) {
    return malformed("the document is not an object", context);
  }
  if (parsed["result_version"] !== SUPPORTED_RESULT_VERSION) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_RESULT_VERSION_UNSUPPORTED",
      message: `Result version ${JSON.stringify(parsed["result_version"])} is not supported; expected ${SUPPORTED_RESULT_VERSION}.`,
      stderr: context.stderr,
      exitCode: context.exitCode,
    });
  }
  const operation = parsed["operation"];
  const mode = parsed["mode"];
  const exitCode = parsed["exit_code"];
  if (
    (operation !== null &&
      !DISCOVERY_OPERATIONS.includes(operation as DiscoveryOperation)) ||
    (mode !== null && !DISCOVERY_MODES.includes(mode as DiscoveryMode)) ||
    typeof parsed["ok"] !== "boolean" ||
    typeof exitCode !== "number" ||
    !EXIT_CODES.includes(exitCode) ||
    !Array.isArray(parsed["findings"]) ||
    !Array.isArray(parsed["artifacts"]) ||
    !("input_manifest" in parsed) ||
    !("runtime" in parsed)
  ) {
    return malformed(
      "a required envelope field is missing or invalid",
      context,
    );
  }
  const findings = parsed["findings"].map((item) =>
    validateFinding(item, context),
  );
  const artifacts = parsed["artifacts"].map((item) =>
    validateArtifact(item, context),
  );
  const summary = validateSummary(parsed["summary"], context);
  const inputManifest = parsed["input_manifest"];
  if (inputManifest !== null && !isObject(inputManifest)) {
    return malformed("the input manifest is invalid", context);
  }
  const runtime = validateRuntime(parsed["runtime"], context);
  // The envelope's own ok/exit pair must be consistent and must agree with the
  // process exit; a disagreement means the output cannot be trusted.
  if ((parsed["ok"] && exitCode !== 0) || (!parsed["ok"] && exitCode === 0)) {
    return malformed("ok and exit_code disagree", context);
  }
  if (context.exitCode !== exitCode) {
    throw new DiscoveryTransportError({
      code: "DISCOVERY_RESULT_EXIT_MISMATCH",
      message: `The result reports exit ${String(exitCode)} but the process exited with ${String(context.exitCode)}.`,
      stderr: context.stderr,
      exitCode: context.exitCode,
    });
  }
  return {
    result_version: SUPPORTED_RESULT_VERSION,
    operation: operation as DiscoveryOperation | null,
    mode: mode as DiscoveryMode | null,
    ok: parsed["ok"],
    exit_code: exitCode as DiscoveryExitCode,
    findings,
    artifacts,
    summary,
    input_manifest:
      inputManifest === null
        ? null
        : (inputManifest as unknown as DiscoveryServiceResult["input_manifest"]),
    runtime,
  };
}

/**
 * Convert a successful validated result into the host execution result.
 *
 * @throws DiscoveryOperationError when the result is structurally valid but
 *   the operation did not succeed; the typed result travels on the error.
 */
export function toExecutionResult(
  result: DiscoveryServiceResult,
  tool: RepoAutomationToolName,
  workspaceRoot: string,
): RepoAutomationExecutionResult {
  if (!result.ok) {
    throw new DiscoveryOperationError(result);
  }
  const artifacts = result.artifacts.map((artifact) => artifact.path);
  return {
    tool,
    workspaceRoot,
    summary: result.summary.message,
    ...(artifacts.length === 0 ? {} : { artifacts }),
    discovery: result,
  };
}
