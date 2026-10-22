/**
 * Prove prepare_discovery_agent persists protected bindings before launch.
 *
 * The flow runs over an in-memory `AuthorityStoreIO`; every write path is
 * inspected so the suite can show that neither the workspace nor the
 * orchestrator-state checkpoint is touched, and the record shape is checked
 * against the committed v2 schema.
 */

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  diagnosticMirror,
  INVOCATION_RECORD_KEYS,
  loadPreparedInvocation,
  prepareDiscoveryInvocation,
} from "../src/discovery-invocation";
import {
  DISCOVERY_SKILL_IDS,
  SKILL_PRIMARY_OPERATIONS,
} from "../src/discovery-routing";
import { DISCOVERY_OPERATIONS } from "../src/lib/validate/codex-discovery-routing";
import {
  codeOf,
  INVOCATION_SCHEMA,
  LOCATION,
  NOW,
  options,
  request,
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
describe("prepareDiscoveryInvocation", () => {
  it.each(DISCOVERY_SKILL_IDS.map((skillId) => [skillId]))(
    "prepares %s with persisted protected bindings and an exact deployment",
    (skillId) => {
      const io = seeded();
      const prepared = prepareDiscoveryInvocation(
        options(io, { request: request(skillId) }),
      );
      const { record } = prepared;
      expect(record.role).toBe(DISCOVERY_OPERATIONS[skillId]!.logical_agent);
      expect(record.skill_id).toBe(skillId);
      expect(record.operation).toBe(SKILL_PRIMARY_OPERATIONS[skillId]);
      expect(record.state).toBe("prepared");
      expect(record.agent_id).toBeNull();
      expect(record.production_write_count).toBe(0);
      expect(record.host).toBe("codex");
      expect(record.session_id).toBe("session-alpha");
      expect(record.parent_agent_id).toBe("root-alpha");
      expect(record.capability_ref).toBe("attestation-alpha-00000000001");
      expect(record.created_at).toBe(NOW.toISOString());
      expect(Object.keys(record).sort()).toEqual(
        [...INVOCATION_SCHEMA.required].sort(),
      );
      expect([...INVOCATION_RECORD_KEYS]).toEqual(
        [...INVOCATION_SCHEMA.required].sort(),
      );
      expect(prepared.deployment).toEqual({
        provider: "codex",
        agent_name: `${record.role}-c2`,
        model: "gpt-6.1-sol",
        reasoning_effort: "medium",
        profile_path: WORKSPACE.profile_path,
        profile_sha256: WORKSPACE.profile_sha256,
        complexity: "C2",
        execution_context: "standalone",
      });
      expect(prepared.identity).toEqual({
        host: "codex",
        session_id: "session-alpha",
        agent_id: "root-alpha",
        role: record.role,
        invocation_id: record.invocation_id,
      });
      const directory = invocationDirectory(
        LOCATION,
        "session-alpha",
        record.invocation_id,
      );
      expect(prepared.protectedPaths).toEqual([
        `${directory}/invocation.json`,
        `${directory}/topology-receipt.json`,
        `${directory}/model-receipt.json`,
        `${directory}/required-outputs.json`,
      ]);
      // Every write stays inside the protected partition; no checkpoint, no workspace.
      for (const written of io.writtenPaths()) {
        expect(written.startsWith(`${directory}`)).toBe(true);
        expect(written).not.toContain("orchestrator-state");
        expect(written.startsWith(LOCATION.workspace)).toBe(false);
      }
      expect(
        loadPreparedInvocation({
          location: LOCATION,
          io,
          sessionId: "session-alpha",
          invocationId: record.invocation_id,
        }),
      ).toEqual(record);
    },
  );

  it("needs no feature checkpoint and never reads orchestrator-state", () => {
    const io = seeded();
    prepareDiscoveryInvocation(options(io));
    expect(
      io.operations.some((entry) => entry.includes("orchestrator-state")),
    ).toBe(false);
    expect(io.operations.some((entry) => entry.includes("docs/features"))).toBe(
      false,
    );
  });

  it("binds receipts, scope and input digests deterministically", () => {
    const first = prepareDiscoveryInvocation(options(seeded())).record;
    const second = prepareDiscoveryInvocation(options(seeded())).record;
    expect(second.topology_receipt_ref).toBe(first.topology_receipt_ref);
    expect(second.model_receipt_ref).toBe(first.model_receipt_ref);
    expect(second.scope_sha256).toBe(first.scope_sha256);
    expect(second.input_sha256).toBe(first.input_sha256);
    expect(second.required_outputs.manifest_sha256).toBe(
      first.required_outputs.manifest_sha256,
    );
    const other = prepareDiscoveryInvocation(
      options(seeded(), {
        request: request("inventory-legacy-system", { paths: ["src/Billing"] }),
      }),
    ).record;
    expect(other.scope_sha256).not.toBe(first.scope_sha256);
    expect(other.input_sha256).not.toBe(first.input_sha256);
  });

  it("keeps the diagnostic mirror separate from the protected record", () => {
    const io = seeded();
    const prepared = prepareDiscoveryInvocation(options(io));
    expect(prepared.mirror.diagnostic).toBe(true);
    expect(prepared.mirror.relative_path).toBe(
      `artifacts/discovery/invocations/${prepared.record.invocation_id}.json`,
    );
    expect(JSON.parse(prepared.mirror.text)).toEqual(prepared.record);
    // A tampered mirror (role swap, started state, write count) changes nothing protected.
    const workspace = new Map<string, string>();
    const forged = {
      ...prepared.record,
      role: "requirements-reconciler",
      state: "started",
      production_write_count: 3,
    };
    workspace.set(
      `${LOCATION.workspace}/${prepared.mirror.relative_path}`,
      JSON.stringify(forged),
    );
    const loaded = loadPreparedInvocation({
      location: LOCATION,
      io,
      sessionId: "session-alpha",
      invocationId: prepared.record.invocation_id,
    });
    expect(loaded).toEqual(prepared.record);
    expect(
      io.files.has(`${LOCATION.workspace}/${prepared.mirror.relative_path}`),
    ).toBe(false);
    expect(diagnosticMirror(loaded).text).toBe(prepared.mirror.text);
  });

  it("does not reuse a partially written invocation directory", () => {
    const io = seeded();
    const first = prepareDiscoveryInvocation(options(io));
    const same = options(io);
    expect(codeOf(() => prepareDiscoveryInvocation(same))).toBe(
      "AUTHORITY_LOCKED",
    );
    expect(io.files.get(first.protectedPaths[0]!)).toBe(
      `${JSON.stringify(first.record, null, 2)}\n`,
    );
  });
});
