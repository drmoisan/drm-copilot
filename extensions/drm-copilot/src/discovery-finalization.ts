/**
 * Finalize a discovery role's output and mint a fresh gate-specific receipt.
 *
 * `finalize_discovery_agent` is the only path that produces a protected
 * `validation-receipt` for an agent-output gate. The gateway loads the
 * protected invocation record, checks the trusted identity against it, takes
 * the validated Python `finalize-agent` result, refuses forged success,
 * recomputes the complete input manifest from the workspace, verifies every
 * required output exists with the digest the runtime reported and that no
 * other artifact was written, then writes the receipt and marks the
 * invocation finalized. A reviewer may finalize a valid failing review; that
 * yields a receipt whose `validation_result` is `fail` and never authorizes
 * planning. Source mutation after the result invalidates the receipt.
 */

import type { DiscoveryServiceResult } from "./discovery-service-types";
import type {
  AuthorityStoreIO,
  ProtectedEnvelope,
} from "./discovery-authority";
import {
  type AuthorityLocation,
  invocationDirectory,
  sha256Hex,
} from "./discovery-authority-paths";
import {
  canonicalJson,
  type NativeIdentity,
} from "./discovery-authorization-record";
import {
  decodeDiscoveryInvocation,
  type DiscoveryInvocationRecord,
  INVOCATION_RECORD_FILE,
} from "./discovery-invocation-record";
import {
  type InputBytesReader,
  type InputManifest,
  recomputeInputManifest,
  requireFreshInputs,
  validateInputManifest,
  workspacePath,
} from "./discovery-input-manifest";
import type { RequiredOutputManifest } from "./discovery-routing";

import { createHash } from "node:crypto";

export const VALIDATION_RECEIPT_SCHEMA =
  "urn:drm-copilot:discovery:2.0.0:validation-receipt";
export const RECEIPTS_PARTITION = "receipts";
export const REVIEWER_ROLE = "migration-coverage-reviewer";
const CORRELATION_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]*$/u;
const NONCE = /^[a-z0-9]{8,64}$/u;

export type DiscoveryFinalizationCode =
  | "FINALIZATION_INVOCATION_MISSING"
  | "FINALIZATION_INVOCATION_STATE"
  | "FINALIZATION_IDENTITY"
  | "FINALIZATION_GATE"
  | "FINALIZATION_RESULT_FORGED"
  | "FINALIZATION_RUNTIME_DRIFT"
  | "FINALIZATION_WORKSPACE_CHANGED"
  | "FINALIZATION_OUTPUT_MISSING"
  | "FINALIZATION_OUTPUT_MISMATCH"
  | "FINALIZATION_OUTPUT_UNEXPECTED"
  | "FINALIZATION_RECEIPT_STALE"
  | "FINALIZATION_REQUEST_INVALID";

/** Raised when a finalization cannot produce or confirm a protected receipt. */
export class DiscoveryFinalizationError extends Error {
  readonly code: DiscoveryFinalizationCode;

  constructor(code: DiscoveryFinalizationCode, message: string) {
    super(message);
    this.name = "DiscoveryFinalizationError";
    this.code = code;
  }
}

export interface ReceiptPrincipal extends NativeIdentity {
  readonly kind: "discovery-agent";
  readonly request_id: string;
}

export interface ReceiptWriter {
  readonly kind: "host-gateway";
  readonly component: "extension" | "standalone-mcp";
  readonly host: string;
  readonly id: string;
  readonly build_sha256: string;
}

/** Protected `validation-receipt` for an agent-output gate. */
export interface ValidationReceipt {
  readonly $schema: typeof VALIDATION_RECEIPT_SCHEMA;
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "validation-receipt";
  readonly id: string;
  readonly receipt_version: "2.0.0";
  readonly receipt_ref: string;
  readonly workspace: DiscoveryInvocationRecord["workspace"];
  readonly activation_sha256: string;
  readonly input_manifest: InputManifest;
  readonly runtime: DiscoveryInvocationRecord["runtime"];
  readonly mode: "agent-output";
  readonly identity: ReceiptPrincipal;
  readonly required_outputs: RequiredOutputManifest;
  readonly output_valid: boolean;
  readonly validation_result: "pass" | "fail";
  readonly findings: DiscoveryServiceResult["findings"];
  readonly issued_at: string;
  readonly writer: ReceiptWriter;
}

export interface FinalizationOptions {
  readonly location: AuthorityLocation;
  readonly io: AuthorityStoreIO;
  readonly reader: InputBytesReader;
  readonly activation: { envelope(): ProtectedEnvelope };
  readonly identity: NativeIdentity;
  readonly requestId: string;
  readonly result: DiscoveryServiceResult;
  readonly writer: Omit<ReceiptWriter, "kind" | "host">;
  readonly now: Date;
  readonly nonce: () => string;
}

export interface FinalizedInvocation {
  readonly receipt: ValidationReceipt;
  readonly record: DiscoveryInvocationRecord;
  readonly receiptPath: string;
  /** True only for a passing result with valid outputs; a failing review is false. */
  readonly planningAuthorized: boolean;
}

function refuse(
  code: DiscoveryFinalizationCode,
  message: string,
): DiscoveryFinalizationError {
  return new DiscoveryFinalizationError(code, message);
}

function loadInvocation(
  location: AuthorityLocation,
  io: AuthorityStoreIO,
  identity: NativeIdentity,
): { record: DiscoveryInvocationRecord; path: string } {
  const directory = invocationDirectory(
    location,
    identity.session_id,
    identity.invocation_id,
  );
  const path = `${directory}/${INVOCATION_RECORD_FILE}`;
  const text = io.readText(path);
  if (text === null) {
    throw refuse(
      "FINALIZATION_INVOCATION_MISSING",
      `No protected invocation ${identity.invocation_id} exists for this session.`,
    );
  }
  const record = decodeDiscoveryInvocation(text, {
    workspaceSha256: location.workspaceSha256,
  });
  if (record.state !== "prepared" && record.state !== "started") {
    throw refuse(
      "FINALIZATION_INVOCATION_STATE",
      `Invocation ${record.invocation_id} is ${record.state} and cannot be finalized.`,
    );
  }
  return { record, path };
}

/** Compare the host-verified identity with the protected record's bindings. */
function requireIdentity(
  record: DiscoveryInvocationRecord,
  identity: NativeIdentity,
): void {
  if (
    record.host !== identity.host ||
    record.session_id !== identity.session_id ||
    record.invocation_id !== identity.invocation_id ||
    record.role !== identity.role ||
    (record.agent_id !== null && record.agent_id !== identity.agent_id)
  ) {
    throw refuse(
      "FINALIZATION_IDENTITY",
      "Trusted identity does not match the protected invocation.",
    );
  }
}

/**
 * Refuse results that are not the authoritative finalize-agent output for
 * this invocation, or whose success claims contradict their own content.
 */
function requireAuthoritativeResult(
  record: DiscoveryInvocationRecord,
  result: DiscoveryServiceResult,
): "pass" | "fail" {
  if (
    result.operation !== "finalize-agent" ||
    result.mode !== "agent-output" ||
    result.summary.invocation_ref !== record.invocation_id
  ) {
    throw refuse(
      "FINALIZATION_GATE",
      "Result is not a finalize-agent agent-output result for this invocation.",
    );
  }
  const verdict = result.summary.validation_result;
  const errors = result.findings.filter(
    (finding) => finding.severity === "error",
  );
  // Success claims are derived from content; a result that asserts a receipt,
  // claims pass with blocking findings, or claims ok on failure is forged.
  if (
    result.summary.receipt_ref !== null ||
    (verdict !== "pass" && verdict !== "fail") ||
    (verdict === "pass" &&
      (errors.length > 0 || !result.ok || result.exit_code !== 0)) ||
    (verdict === "fail" &&
      (errors.length === 0 || result.ok || result.exit_code === 0))
  ) {
    throw refuse(
      "FINALIZATION_RESULT_FORGED",
      "Result success claims contradict its findings or carry a receipt reference.",
    );
  }
  if (
    result.runtime === null ||
    canonicalJson(result.runtime) !== canonicalJson(record.runtime)
  ) {
    throw refuse(
      "FINALIZATION_RUNTIME_DRIFT",
      "Result runtime differs from the invocation's schema/runtime/build/policy binding.",
    );
  }
  return verdict;
}

/** Every required output must exist with the digest the runtime reported. */
function requireOutputs(
  record: DiscoveryInvocationRecord,
  result: DiscoveryServiceResult,
  reader: InputBytesReader,
): void {
  const required = new Map(
    record.required_outputs.outputs.map((output) => [output.path, output]),
  );
  // Artifacts outside the granted output rows are writes the role never held.
  for (const artifact of result.artifacts) {
    const output = required.get(artifact.path);
    if (output === undefined || output.artifact_kind !== artifact.kind) {
      throw refuse(
        "FINALIZATION_OUTPUT_UNEXPECTED",
        `Artifact ${artifact.path} is outside the required outputs.`,
      );
    }
  }
  const reported = new Map(
    result.artifacts.map((artifact) => [artifact.path, artifact]),
  );
  for (const output of record.required_outputs.outputs) {
    const bytes = reader.readBytes(
      workspacePath(record.workspace.workspace_root, output.path),
    );
    const artifact = reported.get(output.path);
    if (bytes === null || artifact === undefined) {
      throw refuse(
        "FINALIZATION_OUTPUT_MISSING",
        `Required output ${output.path} was not produced.`,
      );
    }
    const digest = createHash("sha256").update(bytes).digest("hex");
    if (digest !== artifact.sha256 || artifact.status === "conflict") {
      throw refuse(
        "FINALIZATION_OUTPUT_MISMATCH",
        `Required output ${output.path} differs from the reported artifact.`,
      );
    }
  }
}

/**
 * Finalize the invocation and mint its protected receipt.
 *
 * Order: trusted identity against the record, authoritative result, current
 * activation binding, independent input recomputation, required outputs,
 * exclusive receipt creation, then the invocation state transition.
 */
export function finalizeDiscoveryInvocation(
  options: FinalizationOptions,
): FinalizedInvocation {
  const { location, io, reader, identity, result, now } = options;
  if (!CORRELATION_ID.test(options.requestId)) {
    throw refuse(
      "FINALIZATION_REQUEST_INVALID",
      "Request id must be a correlation id.",
    );
  }
  const { record, path } = loadInvocation(location, io, identity);
  requireIdentity(record, identity);
  const verdict = requireAuthoritativeResult(record, result);
  const envelope = options.activation.envelope();
  if (canonicalJson(envelope.workspace) !== canonicalJson(record.workspace)) {
    throw refuse(
      "FINALIZATION_WORKSPACE_CHANGED",
      "Protected activation no longer matches the invocation's workspace or profile.",
    );
  }
  if (result.input_manifest === null) {
    throw refuse("FINALIZATION_GATE", "Result carries no input manifest.");
  }
  const manifest = requireFreshInputs({
    manifest: validateInputManifest(result.input_manifest),
    reader,
    workspaceRoot: record.workspace.workspace_root,
    profile: {
      path: record.workspace.profile_path,
      sha256: record.workspace.profile_sha256,
    },
  });
  requireOutputs(record, result, reader);
  const nonce = options.nonce();
  if (!NONCE.test(nonce)) {
    throw refuse(
      "FINALIZATION_REQUEST_INVALID",
      "Receipt nonce must be lowercase hex.",
    );
  }
  const outputValid = verdict === "pass" || record.role === REVIEWER_ROLE;
  const body = {
    $schema: VALIDATION_RECEIPT_SCHEMA,
    schema_version: "2.0.0",
    artifact_kind: "validation-receipt",
    id: `receipt-${nonce}`,
    receipt_version: "2.0.0",
    workspace: { ...record.workspace },
    activation_sha256: envelope.activation_sha256,
    input_manifest: manifest,
    runtime: { ...record.runtime },
    mode: "agent-output",
    identity: {
      kind: "discovery-agent",
      ...identity,
      request_id: options.requestId,
    },
    required_outputs: record.required_outputs,
    output_valid: outputValid,
    validation_result: verdict,
    findings: [...result.findings],
    issued_at: now.toISOString(),
    writer: {
      kind: "host-gateway",
      component: options.writer.component,
      host: identity.host,
      id: options.writer.id,
      build_sha256: options.writer.build_sha256,
    },
  } as const;
  const receipt: ValidationReceipt = {
    ...body,
    receipt_ref: `receipt-${sha256Hex(canonicalJson(body))}`,
  };
  const directory = invocationDirectory(
    location,
    identity.session_id,
    identity.invocation_id,
  );
  io.ensureDirectory(`${directory}/${RECEIPTS_PARTITION}`);
  const receiptPath = `${directory}/${RECEIPTS_PARTITION}/${receipt.receipt_ref}.json`;
  io.createExclusive(receiptPath, `${JSON.stringify(receipt, null, 2)}\n`);
  const finalized: DiscoveryInvocationRecord = {
    ...record,
    state: "finalized",
    agent_id: record.agent_id ?? identity.agent_id,
    start_attestation_ref: record.start_attestation_ref ?? `start-${nonce}`,
    completion_receipt_ref: receipt.receipt_ref,
  };
  const staged = `${path}.staged`;
  io.remove(staged);
  io.createExclusive(staged, `${JSON.stringify(finalized, null, 2)}\n`);
  try {
    io.publish(staged, path, true);
  } catch (error) {
    io.remove(staged);
    throw error;
  }
  return {
    receipt,
    record: finalized,
    receiptPath,
    planningAuthorized: verdict === "pass" && outputValid,
  };
}

/**
 * Confirm a receipt still describes the workspace before stop or planning.
 *
 * Any input drift since the receipt was issued makes it stale; the caller
 * must finalize again rather than reuse it.
 */
export function requireCurrentReceipt(options: {
  readonly receipt: ValidationReceipt;
  readonly reader: InputBytesReader;
}): void {
  const { receipt, reader } = options;
  const recomputed = recomputeInputManifest({
    manifest: receipt.input_manifest,
    reader,
    workspaceRoot: receipt.workspace.workspace_root,
    profile: {
      path: receipt.workspace.profile_path,
      sha256: receipt.workspace.profile_sha256,
    },
  });
  if (recomputed.drift.length > 0) {
    const summary = recomputed.drift
      .map((item) => `${item.kind}:${item.path}`)
      .join(", ");
    throw refuse(
      "FINALIZATION_RECEIPT_STALE",
      `Receipt ${receipt.receipt_ref} predates input changes: ${summary}`,
    );
  }
}
