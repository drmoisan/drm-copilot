/**
 * Prove the sentinel tool consumes the one-use sentinel grant the native gate
 * recorded for its exact call and reports only what the host observed: the
 * presence of an agent identity and the agent type. Replays, absent, expired,
 * duplicated or malformed observations yield `observed: false` without ever
 * throwing, because the sentinel produces evidence and grants nothing.
 */

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import {
  consumeSentinelGrant,
  decodeHostObservation,
  type HostObservationRecord,
} from "../src/discovery-sentinel";
import {
  OBSERVATION_REF,
  recordObservation,
} from "./discovery-grant-test-support";
import {
  LOCATION,
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
import type { MemoryStoreIO } from "./discovery-store-test-helpers";

const NOW = new Date("2026-10-22T12:00:00Z");
const INPUTS = { workspace_root: WORKSPACE.workspace_root };
const NOT_OBSERVED = {
  observed: false,
  observationRef: null,
  agentIdPresent: null,
  agentType: null,
};

function consume(io: MemoryStoreIO, now: Date = NOW) {
  return consumeSentinelGrant({ location: LOCATION, io, inputs: INPUTS, now });
}

function latches(io: MemoryStoreIO): string[] {
  return [...io.files.keys()].filter((key) => key.endsWith(".consumed"));
}

describe("consumeSentinelGrant", () => {
  it("consumes the single issued grant and reports the attributed agent identity", () => {
    const io = seeded();
    const path = recordObservation(io);

    const first = consume(io);
    const replay = consume(io);

    expect(first).toEqual({
      observed: true,
      observationRef: OBSERVATION_REF,
      agentIdPresent: true,
      agentType: "discovery-capability-sentinel",
    });
    expect(io.files.has(`${path}.consumed`)).toBe(true);
    expect(replay).toEqual(NOT_OBSERVED);
  });

  it("reports an observation whose payload carried no agent identity", () => {
    const io = seeded();
    recordObservation(io, { agentId: null, agentType: null });

    expect(consume(io)).toEqual({
      observed: true,
      observationRef: OBSERVATION_REF,
      agentIdPresent: false,
      agentType: null,
    });
  });

  it.each([
    ["no observation at all", (io: MemoryStoreIO) => io],
    [
      "an observation without grant fields",
      (io: MemoryStoreIO) => {
        recordObservation(io, { withGrant: false });
        return io;
      },
    ],
    [
      "a grant for another input",
      (io: MemoryStoreIO) => {
        recordObservation(io, { inputs: { workspace_root: "D:/other" } });
        return io;
      },
    ],
    [
      "a consumed grant",
      (io: MemoryStoreIO) => {
        recordObservation(io, { record: { state: "consumed" } });
        return io;
      },
    ],
    [
      "two grants for the same call",
      (io: MemoryStoreIO) => {
        recordObservation(io);
        recordObservation(io, { ref: "observation-0123456789abcdef0124" });
        return io;
      },
    ],
    [
      "a malformed observation beside no valid one",
      (io: MemoryStoreIO) => {
        recordObservation(io, { record: { decision: "maybe" } });
        return io;
      },
    ],
  ])(
    "reports %s as not observed without throwing or latching",
    (_label, seed) => {
      const io = seed(seeded());

      expect(consume(io)).toEqual(NOT_OBSERVED);
      expect(latches(io)).toEqual([]);
    },
  );

  it("reports an expired grant and a grant not yet valid as not observed", () => {
    expect(consume(recordedStore(), new Date("2026-10-22T12:04:00Z"))).toEqual(
      NOT_OBSERVED,
    );
    expect(consume(recordedStore(), new Date("2026-10-22T11:58:00Z"))).toEqual(
      NOT_OBSERVED,
    );
  });

  it("skips non-JSON entries and other sessions' unrelated records while finding the grant", () => {
    const io = seeded();
    recordObservation(io, {
      sessionId: "session-beta",
      inputs: { workspace_root: "D:/other" },
    });
    const path = recordObservation(io);
    io.files.set(`${path}.tmp`, "scratch");

    expect(consume(io).observed).toBe(true);
    expect(latches(io)).toEqual([`${path}.consumed`]);
  });

  it("treats a lost latch race as a replay and propagates other store failures", () => {
    const raced = recordedStore();
    raced.createExclusive = () => {
      throw new DiscoveryAuthorityError("AUTHORITY_LOCKED", "race");
    };
    expect(consume(raced)).toEqual(NOT_OBSERVED);

    const failing = recordedStore();
    failing.createExclusive = () => {
      throw new Error("disk full");
    };
    expect(() => consume(failing)).toThrow("disk full");
  });

  it("propagates a decode failure that is not an authorization refusal", () => {
    const io = recordedStore();
    io.readText = () => {
      throw new Error("unreadable");
    };
    expect(() => consume(io)).toThrow("unreadable");
  });
});

function recordedStore(): MemoryStoreIO {
  const io = seeded();
  recordObservation(io);
  return io;
}

describe("decodeHostObservation", () => {
  function text(options: Parameters<typeof recordObservation>[1] = {}): string {
    const io = seeded();
    return io.files.get(recordObservation(io, options))!;
  }

  it("decodes an observation with and without the sentinel grant fields", () => {
    const granted: HostObservationRecord = decodeHostObservation(text());
    expect(granted.grant).toEqual({
      tool: "discovery_capability_sentinel",
      input_sha256: expect.stringMatching(/^[0-9a-f]{64}$/u) as string,
      expires_at: "2026-10-22T12:04:00Z",
      state: "issued",
    });
    expect(granted.agent_id).toBe("agent-sentinel");
    expect(decodeHostObservation(text({ withGrant: false })).grant).toBeNull();
    expect(
      decodeHostObservation(text({ agentId: null, agentType: null })).agent_id,
    ).toBeNull();
  });

  it.each([
    ["not JSON", "{"],
    ["an array", "[]"],
    ["an extra key", JSON.stringify({ ...JSON.parse(text()), extra: 1 })],
    ["a foreign host", text({ record: { host: "cursor" } })],
    ["a malformed agent id", text({ agentId: "bad id" })],
    ["an unknown decision", text({ record: { decision: "maybe" } })],
    ["a lowercase code", text({ record: { code: "sentinel" } })],
    [
      "a non-boolean tool_use_id_present",
      text({ record: { tool_use_id_present: "yes" } }),
    ],
    ["a malformed timestamp", text({ record: { observed_at: "later" } })],
    [
      "a foreign grant tool",
      text({ record: { tool: "read_discovery_source" } }),
    ],
    ["an unknown grant state", text({ record: { state: "pending" } })],
  ])("rejects %s as a malformed record", (_label, value) => {
    expect(() => decodeHostObservation(value)).toThrow(
      "Host observation record is malformed",
    );
  });
});
