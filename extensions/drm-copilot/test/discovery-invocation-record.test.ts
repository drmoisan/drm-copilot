/**
 * Prove protected invocation records are loaded strictly from their partition.
 *
 * Missing records, records copied into another session's partition, tampered
 * fields and non-prepared states are all refused.
 */

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  decodeDiscoveryInvocation,
  INVOCATION_RECORD_FILE,
  loadPreparedInvocation,
  prepareDiscoveryInvocation,
} from "../src/discovery-invocation";
import {
  codeOf,
  LOCATION,
  options,
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
describe("loadPreparedInvocation and decodeDiscoveryInvocation", () => {
  it("reports a missing invocation and a record in the wrong partition", () => {
    const io = seeded();
    const prepared = prepareDiscoveryInvocation(options(io));
    expect(
      codeOf(() =>
        loadPreparedInvocation({
          location: LOCATION,
          io,
          sessionId: "session-alpha",
          invocationId: "invocation-missing",
        }),
      ),
    ).toBe("INVOCATION_MISSING");
    const foreign = invocationDirectory(
      LOCATION,
      "session-beta",
      prepared.record.invocation_id,
    );
    io.files.set(
      `${foreign}/${INVOCATION_RECORD_FILE}`,
      io.files.get(prepared.protectedPaths[0]!)!,
    );
    expect(
      codeOf(() =>
        loadPreparedInvocation({
          location: LOCATION,
          io,
          sessionId: "session-beta",
          invocationId: prepared.record.invocation_id,
        }),
      ),
    ).toBe("INVOCATION_RECORD_INVALID");
  });

  it.each([
    ["not JSON", "{"],
    ["array", "[]"],
    [
      "extra key",
      (record: Record<string, unknown>) => ({ ...record, extra: 1 }),
    ],
    [
      "write count",
      (record: Record<string, unknown>) => ({
        ...record,
        production_write_count: 1,
      }),
    ],
    [
      "unknown state",
      (record: Record<string, unknown>) => ({ ...record, state: "running" }),
    ],
    [
      "started without agent",
      (record: Record<string, unknown>) => ({
        ...record,
        state: "prepared",
        agent_id: "agent-x",
      }),
    ],
    [
      "foreign role",
      (record: Record<string, unknown>) => ({ ...record, role: "native-root" }),
    ],
    [
      "unknown skill",
      (record: Record<string, unknown>) => ({ ...record, skill_id: "deploy" }),
    ],
    [
      "other workspace",
      (record: Record<string, unknown>) => ({
        ...record,
        workspace: { ...WORKSPACE, workspace_sha256: "0".repeat(64) },
      }),
    ],
  ])("rejects a tampered record: %s", (_label, mutate) => {
    const prepared = prepareDiscoveryInvocation(options(seeded()));
    const text =
      typeof mutate === "string"
        ? mutate
        : JSON.stringify(
            mutate(prepared.record as unknown as Record<string, unknown>),
          );
    expect(
      codeOf(() =>
        decodeDiscoveryInvocation(text, {
          workspaceSha256: LOCATION.workspaceSha256,
        }),
      ),
    ).toBe("INVOCATION_RECORD_INVALID");
  });

  it("rejects a protected record whose state is no longer prepared", () => {
    const io = seeded();
    const prepared = prepareDiscoveryInvocation(options(io));
    const started = {
      ...prepared.record,
      state: "started",
      agent_id: "agent-alpha",
      start_attestation_ref: "start-alpha-00000000000001",
    };
    io.files.set(prepared.protectedPaths[0]!, JSON.stringify(started));
    expect(
      codeOf(() =>
        loadPreparedInvocation({
          location: LOCATION,
          io,
          sessionId: "session-alpha",
          invocationId: prepared.record.invocation_id,
        }),
      ),
    ).toBe("INVOCATION_RECORD_INVALID");
  });
});
