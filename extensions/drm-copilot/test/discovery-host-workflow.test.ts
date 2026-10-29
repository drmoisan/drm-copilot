/**
 * Prove the host side of the completion path end to end over memory stores.
 *
 * Prepare persists the baseline result in the protected partition, the gate
 * consumes exactly one native authorization bound to the trusted identity and
 * refuses the replay, finalization mints a receipt from a recorded
 * Python-shaped result and refuses a second finalization, and the receipt goes
 * stale when an input changes. The shared vectors live in
 * tests/fixtures/discovery_host/host-workflow.json.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  authorizationsDirectory,
  type ToolAuthorizationRecord,
} from "../src/discovery-authorization";
import { consumeToolAuthorizationByBinding } from "../src/discovery-authorization-binding";
import { computeInputDigest } from "../src/discovery-authorization-record";
import { finalizeDiscoveryInvocation } from "../src/discovery-finalization";
import { requireCurrentReceipt } from "../src/discovery-finalization";
import { workspacePath } from "../src/discovery-input-manifest";
import { prepareDiscoveryInvocation } from "../src/discovery-invocation";
import type {
  DiscoveryArtifactStatus,
  DiscoveryExitCode,
  DiscoveryMode,
  DiscoveryOperation,
  DiscoveryServiceResult,
} from "../src/discovery-service-types";
import {
  refusalCode,
  vectors as authorizationVectors,
} from "./discovery-authorization-test-support";
import {
  ACTIVATION,
  codeOf,
  entry,
  MISSING,
  NOW,
  PROFILE_TEXT,
  SOURCE,
  SOURCE_TEXT,
  WRITER,
  WS,
} from "./discovery-finalization-test-support";
import {
  capability,
  CONTEXT,
  LOCATION,
  options,
  request,
  RUNTIME,
  seeded,
} from "./discovery-invocation-test-support";
import { startInvocation } from "./discovery-grant-test-support";
import { digestOf, MemoryInputReader } from "./discovery-store-test-helpers";
import { buildServiceResult } from "./discovery-test-helpers";

interface HostWorkflowVectors {
  identity: {
    host: string;
    session_id: string;
    agent_id: string;
    role: string;
    invocation_id: string;
  };
  skill_id: string;
  authorizations: Record<string, { tool: string; authorization_ref: string }>;
  host_transitions: {
    name: string;
    protected_files?: number;
    state?: string;
    validation_result?: string;
    output_valid?: boolean;
    planning_authorized?: boolean;
  }[];
  host_refusals: { name: string; code: string }[];
  finalize_result: {
    operation: DiscoveryOperation;
    mode: DiscoveryMode;
    ok: boolean;
    exit_code: DiscoveryExitCode;
    summary: {
      message: string;
      validation_result: "pass" | "fail";
      receipt_ref: null;
    };
    artifact_status: {
      new_output: DiscoveryArtifactStatus;
      existing_output: DiscoveryArtifactStatus;
    };
  };
}

const VECTORS = JSON.parse(
  fs.readFileSync(
    path.resolve(
      __dirname,
      "..",
      "..",
      "..",
      "tests",
      "fixtures",
      "discovery_host",
      "host-workflow.json",
    ),
    "utf8",
  ),
) as HostWorkflowVectors;
const CONSUME_AT = new Date("2026-10-22T12:15:00Z");
const READ_INPUT = {
  workspace_root: WS.workspace_root,
  read_operation: "read",
  paths: [SOURCE],
};

function transition(name: string) {
  return VECTORS.host_transitions.find((row) => row.name === name)!;
}

function refusal(name: string): string {
  return VECTORS.host_refusals.find((row) => row.name === name)!.code;
}

describe("discovery host workflow", () => {
  it("prepares, consumes once, finalizes once and goes stale on drift", () => {
    // Arrange: a supported session and the root prepare with the baseline result.
    const io = seeded(capability({ workspace: WS }));
    const prepared = prepareDiscoveryInvocation(
      options(io, {
        activation: ACTIVATION,
        request: request(VECTORS.skill_id),
      }),
    );
    const invocationId = prepared.record.invocation_id;
    const directory = invocationDirectory(
      LOCATION,
      CONTEXT.sessionId,
      invocationId,
    );
    // The prepared partition is counted before any grant, receipt or latch is added.
    const preparedFiles = [...io.files.keys()].filter((file) =>
      file.startsWith(`${directory}/`),
    );
    const identity = {
      host: CONTEXT.host,
      session_id: CONTEXT.sessionId,
      agent_id: VECTORS.identity.agent_id,
      role: prepared.record.role,
      invocation_id: invocationId,
    };
    // The native start hook binds the agent; the gate then consumes by invocation_ref.
    startInvocation(io, invocationId, VECTORS.identity.agent_id);
    const grant = VECTORS.authorizations["read-source"]!;
    const record: ToolAuthorizationRecord = {
      ...authorizationVectors.records.issued,
      authorization_ref: grant.authorization_ref,
      workspace: WS,
      identity,
      tool: "read_discovery_source",
      operation: "read-source",
      input_sha256: computeInputDigest(grant.tool, "read-source", READ_INPUT),
      invocation_ref: invocationId,
      issued_at: "2026-10-22T12:10:00Z",
      expires_at: "2026-10-22T12:40:00Z",
      state: "issued",
      consumed_at: null,
      writer: {
        ...authorizationVectors.records.issued.writer,
        host: CONTEXT.host,
      },
    };
    const recordPath = `${authorizationsDirectory(LOCATION, identity)}/${grant.authorization_ref}.json`;
    io.files.set(recordPath, JSON.stringify(record));
    const output = prepared.record.required_outputs.outputs[0]!;
    const outputText = `{"kind": "${output.artifact_kind}"}\n`;
    const reader = new MemoryInputReader();
    reader.write(
      workspacePath(WS.workspace_root, WS.profile_path),
      PROFILE_TEXT,
    );
    reader.write(workspacePath(WS.workspace_root, SOURCE), SOURCE_TEXT);
    reader.write(workspacePath(WS.workspace_root, output.path), outputText);
    const recorded: DiscoveryServiceResult = buildServiceResult({
      operation: VECTORS.finalize_result.operation,
      mode: VECTORS.finalize_result.mode,
      ok: VECTORS.finalize_result.ok,
      exit_code: VECTORS.finalize_result.exit_code,
      artifacts: [
        {
          path: output.path,
          kind: output.artifact_kind,
          status: VECTORS.finalize_result.artifact_status.new_output,
          sha256: digestOf(outputText),
        },
      ],
      summary: {
        ...VECTORS.finalize_result.summary,
        counts: [],
        invocation_ref: invocationId,
      },
      input_manifest: {
        entries: [
          entry(WS.profile_path, PROFILE_TEXT, "profile"),
          entry(SOURCE, SOURCE_TEXT, "source"),
        ],
        missing_paths: [MISSING],
        source_repositories: [{ id: "legacy-crm", revision: "a".repeat(40) }],
        target_repositories: [],
        sha256: "0".repeat(64),
      },
      runtime: RUNTIME,
    });
    const finalizeOptions = () => ({
      location: LOCATION,
      io,
      reader,
      activation: ACTIVATION,
      identity,
      requestId: "request-finalize",
      result: recorded,
      writer: WRITER,
      now: NOW,
      nonce: () => "fedcba9876543210",
    });

    // Act: consume the grant, replay it, finalize, replay finalization, drift.
    const consumed = consumeToolAuthorizationByBinding({
      location: LOCATION,
      io,
      request: {
        tool: grant.tool,
        operation: "read-source",
        inputs: READ_INPUT,
        invocationRef: invocationId,
      },
      workspace: WS,
      now: CONSUME_AT,
    });
    const replay = refusalCode(() =>
      consumeToolAuthorizationByBinding({
        location: LOCATION,
        io,
        request: {
          tool: grant.tool,
          operation: "read-source",
          inputs: READ_INPUT,
          invocationRef: invocationId,
        },
        workspace: WS,
        now: CONSUME_AT,
      }),
    );
    const finalized = finalizeDiscoveryInvocation(finalizeOptions());
    const finalizeReplay = codeOf(() =>
      finalizeDiscoveryInvocation(finalizeOptions()),
    );
    const fresh = codeOf(() =>
      requireCurrentReceipt({ receipt: finalized.receipt, reader }),
    );
    reader.write(workspacePath(WS.workspace_root, SOURCE), "mutated\n");
    const stale = codeOf(() =>
      requireCurrentReceipt({ receipt: finalized.receipt, reader }),
    );

    // Assert: each fixture transition and refusal, all inside the partition.
    const prepare = transition("prepare");
    expect(preparedFiles).toHaveLength(prepare.protected_files!);
    expect(io.files.has(`${directory}/baseline-result.json`)).toBe(true);
    expect(consumed.authorizationRef).toBe(grant.authorization_ref);
    expect(consumed.record.state).toBe(transition("consume").state);
    expect(io.files.has(`${recordPath}.consumed`)).toBe(true);
    expect(replay).toBe(refusal("authorization-replay"));
    const finalize = transition("finalize");
    expect(finalized.receipt.validation_result).toBe(
      finalize.validation_result,
    );
    expect(finalized.receipt.output_valid).toBe(finalize.output_valid);
    expect(finalized.planningAuthorized).toBe(finalize.planning_authorized);
    expect(finalized.receipt.identity.invocation_id).toBe(invocationId);
    expect(finalized.receipt.identity.agent_id).toBe(VECTORS.identity.agent_id);
    expect(finalized.receiptPath.startsWith(`${directory}/receipts/`)).toBe(
      true,
    );
    expect(finalized.record.state).toBe("finalized");
    expect(finalizeReplay).toBe(refusal("finalize-replay"));
    expect(fresh).toBe("NO_ERROR");
    expect(stale).toBe(refusal("stale-receipt"));
    expect(
      io.writtenPaths().every((written) => written.startsWith(directory)),
    ).toBe(true);
  });
});
