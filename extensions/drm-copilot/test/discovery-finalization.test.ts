/**
 * Prove finalize_discovery_agent mints receipts only for current, bound results.
 *
 * The receipt must be bound to the exact invocation, output set and gate, carry
 * the independently recomputed input manifest, and go stale as soon as an
 * input changes. A reviewer's valid failing review is accepted without
 * authorizing planning.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  invocationDirectory,
  sha256Hex,
} from "../src/discovery-authority-paths";
import { canonicalJson } from "../src/discovery-authorization-record";
import {
  finalizeDiscoveryInvocation,
  requireCurrentReceipt,
  type ValidationReceipt,
} from "../src/discovery-finalization";
import {
  inputManifestDigest,
  workspacePath,
} from "../src/discovery-input-manifest";
import { DISCOVERY_OPERATIONS } from "../src/lib/validate/codex-discovery-routing";
import {
  codeOf,
  failingResult,
  finalizeOptions,
  MISSING,
  NOW,
  scenario,
  SOURCE,
  WRITER,
  WS,
} from "./discovery-finalization-test-support";
import { LOCATION, RUNTIME } from "./discovery-invocation-test-support";
const RECEIPT_SCHEMA = JSON.parse(
  fs.readFileSync(
    path.resolve(
      __dirname,
      "..",
      "..",
      "..",
      "schemas",
      "discovery",
      "v2",
      "validation-receipt.schema.json",
    ),
    "utf8",
  ),
) as { required: string[]; $defs: { principal: { required: string[] } } };

describe("finalizeDiscoveryInvocation", () => {
  it("mints a protected receipt bound to the invocation, outputs and gate", () => {
    const scene = scenario();
    const before = scene.io.writtenPaths().length;
    const finalized = finalizeDiscoveryInvocation(finalizeOptions(scene));
    const { receipt } = finalized;
    expect(Object.keys(receipt).sort()).toEqual(
      [...RECEIPT_SCHEMA.required].sort(),
    );
    expect(Object.keys(receipt.identity).sort()).toEqual(
      [...RECEIPT_SCHEMA.$defs.principal.required].sort(),
    );
    expect(receipt.identity).toEqual({
      kind: "discovery-agent",
      host: "codex",
      session_id: "session-alpha",
      agent_id: "agent-alpha",
      role: scene.role,
      invocation_id: scene.invocationId,
      request_id: "request-finalize",
    });
    expect(receipt.mode).toBe("agent-output");
    expect(receipt.output_valid).toBe(true);
    expect(receipt.validation_result).toBe("pass");
    expect(receipt.workspace).toEqual(WS);
    expect(receipt.activation_sha256).toBe("e".repeat(64));
    expect(receipt.runtime).toEqual(RUNTIME);
    expect(receipt.required_outputs.invocation_id).toBe(scene.invocationId);
    expect(receipt.writer).toEqual({
      ...WRITER,
      kind: "host-gateway",
      host: "codex",
    });
    expect(receipt.issued_at).toBe(NOW.toISOString());
    expect(finalized.planningAuthorized).toBe(true);
    // The receipt carries the independently recomputed manifest, not the runtime digest.
    const { sha256, ...members } = receipt.input_manifest;
    expect(sha256).toBe(inputManifestDigest(members));
    expect(sha256).not.toBe("0".repeat(64));
    expect(receipt.input_manifest.missing_paths).toEqual([MISSING]);
    const { receipt_ref: ref, ...body } = receipt;
    expect(ref).toBe(`receipt-${sha256Hex(canonicalJson(body))}`);
    // Persistence: receipt under the invocation partition, record finalized in place.
    const directory = invocationDirectory(
      LOCATION,
      "session-alpha",
      scene.invocationId,
    );
    expect(finalized.receiptPath).toBe(`${directory}/receipts/${ref}.json`);
    expect(JSON.parse(scene.io.files.get(finalized.receiptPath)!)).toEqual(
      receipt,
    );
    const stored = JSON.parse(
      scene.io.files.get(`${directory}/invocation.json`)!,
    ) as { state: string; completion_receipt_ref: string; agent_id: string };
    expect(stored.state).toBe("finalized");
    expect(stored.completion_receipt_ref).toBe(ref);
    expect(stored.agent_id).toBe("agent-alpha");
    expect(finalized.record).toEqual(stored);
    expect(
      scene.io
        .writtenPaths()
        .slice(before)
        .every((written) => written.startsWith(directory)),
    ).toBe(true);
    expect(scene.io.files.has(`${directory}/invocation.json.staged`)).toBe(
      false,
    );
  });

  it("accepts a reviewer's valid failing review without authorizing planning", () => {
    const scene = scenario("review-discovery-coverage");
    expect(scene.role).toBe("migration-coverage-reviewer");
    const finalized = finalizeDiscoveryInvocation(
      finalizeOptions(scene, { result: failingResult(scene) }),
    );
    expect(finalized.receipt.validation_result).toBe("fail");
    expect(finalized.receipt.output_valid).toBe(true);
    expect(finalized.receipt.findings).toHaveLength(1);
    expect(finalized.planningAuthorized).toBe(false);
    expect(finalized.record.state).toBe("finalized");
  });

  it("records an analyst's failing result as invalid output", () => {
    const scene = scenario("extract-feature-contract");
    const finalized = finalizeDiscoveryInvocation(
      finalizeOptions(scene, { result: failingResult(scene) }),
    );
    expect(finalized.receipt.validation_result).toBe("fail");
    expect(finalized.receipt.output_valid).toBe(false);
    expect(finalized.planningAuthorized).toBe(false);
  });

  it("refuses to finalize the same invocation twice", () => {
    const scene = scenario();
    finalizeDiscoveryInvocation(finalizeOptions(scene));
    expect(
      codeOf(() => finalizeDiscoveryInvocation(finalizeOptions(scene))),
    ).toBe("FINALIZATION_INVOCATION_STATE");
  });

  it.each(Object.keys(DISCOVERY_OPERATIONS).map((skillId) => [skillId]))(
    "finalizes %s with its own role and output kind",
    (skillId) => {
      const scene = scenario(skillId);
      const finalized = finalizeDiscoveryInvocation(finalizeOptions(scene));
      expect(finalized.receipt.identity.role).toBe(
        DISCOVERY_OPERATIONS[skillId]!.logical_agent,
      );
      expect(finalized.receipt.required_outputs.outputs[0]!.artifact_kind).toBe(
        scene.outputKind,
      );
    },
  );
});
describe("requireCurrentReceipt", () => {
  it("accepts a receipt whose inputs are unchanged and refuses one after mutation", () => {
    const scene = scenario();
    const { receipt } = finalizeDiscoveryInvocation(finalizeOptions(scene));
    expect(() =>
      requireCurrentReceipt({ receipt, reader: scene.reader }),
    ).not.toThrow();
    scene.reader.write(workspacePath(WS.workspace_root, SOURCE), "mutated\n");
    expect(
      codeOf(() => requireCurrentReceipt({ receipt, reader: scene.reader })),
    ).toBe("FINALIZATION_RECEIPT_STALE");
    const stale: ValidationReceipt = {
      ...receipt,
      workspace: { ...receipt.workspace, profile_sha256: "5".repeat(64) },
    };
    expect(
      codeOf(() =>
        requireCurrentReceipt({ receipt: stale, reader: scenario().reader }),
      ),
    ).toBe("FINALIZATION_RECEIPT_STALE");
  });
});
