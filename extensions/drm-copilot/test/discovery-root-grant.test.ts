/**
 * Prove one-use root grant consumption: a root call is admitted only by the
 * single live grant the native gate issued for its exact tool, operation and
 * input digest; replays, expired, ambiguous and malformed grants and calls no
 * grant admits are refused with distinct codes, and the grant's host, session
 * and parent are the only identity the server takes.
 */

import { DiscoveryAuthorityError } from "../src/discovery-authority";
import { DiscoveryAuthorizationError } from "../src/discovery-authorization";
import {
  consumeRootGrant,
  decodeRootGrant,
  ROOT_GRANT_RECORD_KEYS,
  rootGrantsDirectory,
} from "../src/discovery-root-grant";
import {
  issueRootGrant,
  ROOT_GRANT_REF,
  rootGrantPath,
} from "./discovery-grant-test-support";
import { CONTEXT, LOCATION, seeded } from "./discovery-invocation-test-support";
import type { MemoryStoreIO } from "./discovery-store-test-helpers";

const NOW = new Date("2026-10-22T12:00:00Z");
const PREPARE_RAW = {
  workspace_root: LOCATION.workspace,
  skill_id: "inventory-legacy-system",
};
const PREPARE = {
  tool: "prepare_discovery_agent",
  operation: "prepare-agent",
  inputs: PREPARE_RAW,
};

function granted(record: Record<string, unknown> = {}): MemoryStoreIO {
  const io = seeded();
  issueRootGrant(io, { ...PREPARE, record });
  return io;
}

function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (
      error instanceof DiscoveryAuthorizationError ||
      error instanceof DiscoveryAuthorityError
    ) {
      return error.code;
    }
    throw error;
  }
  return "ADMITTED";
}

function attempt(
  io: MemoryStoreIO,
  overrides: {
    tool?: string;
    operation?: string;
    inputs?: unknown;
    now?: Date;
  } = {},
): string {
  return codeOf(() =>
    consumeRootGrant({
      location: LOCATION,
      io,
      tool: overrides.tool ?? PREPARE.tool,
      operation: overrides.operation ?? PREPARE.operation,
      inputs: overrides.inputs ?? PREPARE.inputs,
      now: overrides.now ?? NOW,
    }),
  );
}

function latches(io: MemoryStoreIO): string[] {
  return [...io.files.keys()].filter((key) => key.endsWith(".consumed"));
}

describe("consumeRootGrant admission", () => {
  it("consumes the unique grant for the call and returns the host, session and parent it binds", () => {
    const io = granted();

    const consumed = consumeRootGrant({
      location: LOCATION,
      io,
      ...PREPARE,
      now: NOW,
    });

    expect(consumed).toMatchObject({
      rootGrantRef: ROOT_GRANT_REF,
      host: CONTEXT.host,
      sessionId: CONTEXT.sessionId,
      parentAgentId: CONTEXT.parentAgentId,
      path: rootGrantPath(),
    });
    expect(consumed.record.grant_ref).toBe(ROOT_GRANT_REF);
    expect(io.files.has(`${rootGrantPath()}.consumed`)).toBe(true);
    expect(io.files.get(`${rootGrantPath()}.consumed`)).toContain(
      ROOT_GRANT_REF,
    );
    // The second call for the same input finds the latched grant and is refused.
    expect(attempt(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("ignores grants issued for other calls and consumes the matching one", () => {
    const io = granted();
    issueRootGrant(io, {
      tool: "run_discovery_doctor",
      operation: "doctor",
      inputs: { workspace_root: LOCATION.workspace },
      ref: "grant-0123456789abcdef0002",
    });

    expect(attempt(io)).toBe("ADMITTED");
    expect(latches(io)).toEqual([`${rootGrantPath()}.consumed`]);
  });

  it("consumes a controlled tool's grant with the derived operation", () => {
    const io = seeded();
    const inputs = {
      workspace_root: LOCATION.workspace,
      report_type: "coverage",
    };
    issueRootGrant(io, {
      tool: "run_discovery_report",
      operation: "coverage-report",
      inputs,
    });

    expect(
      attempt(io, {
        tool: "run_discovery_report",
        operation: "coverage-report",
        inputs,
      }),
    ).toBe("ADMITTED");
  });

  it("consumes the current grant beside an expired one issued for the same call", () => {
    const io = granted();
    issueRootGrant(io, {
      ...PREPARE,
      ref: "grant-0123456789abcdef0003",
      record: {
        issued_at: "2026-10-22T11:00:00Z",
        expires_at: "2026-10-22T11:05:00Z",
      },
    });

    expect(attempt(io)).toBe("ADMITTED");
    expect(latches(io)).toEqual([`${rootGrantPath()}.consumed`]);
  });
});

describe("consumeRootGrant refusals", () => {
  it("reports the host binding as required when no grant matches the call", () => {
    expect(attempt(seeded())).toBe("DISCOVERY_HOST_BINDING_REQUIRED");
    expect(
      attempt(granted(), {
        inputs: { ...PREPARE_RAW, skill_id: "extract-feature-contract" },
      }),
    ).toBe("DISCOVERY_HOST_BINDING_REQUIRED");
    expect(
      attempt(granted(), { tool: "run_discovery_doctor", operation: "doctor" }),
    ).toBe("DISCOVERY_HOST_BINDING_REQUIRED");
  });

  it.each([
    ["a consumed grant", { state: "consumed" }],
    ["a revoked grant", { state: "revoked" }],
  ])("refuses %s as consumed", (_label, record) => {
    const io = granted(record);
    expect(attempt(io)).toBe("AUTHORIZATION_CONSUMED");
    expect(latches(io)).toEqual([]);
  });

  it("treats a latched grant as consumed even when it still reads issued", () => {
    const io = granted();
    io.files.set(`${rootGrantPath()}.consumed`, "{}\n");

    expect(attempt(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("refuses an expired grant and a grant not yet valid", () => {
    expect(attempt(granted(), { now: new Date("2026-10-22T11:58:59Z") })).toBe(
      "AUTHORIZATION_EXPIRED",
    );
    expect(attempt(granted(), { now: new Date("2026-10-22T12:04:00Z") })).toBe(
      "AUTHORIZATION_EXPIRED",
    );
  });

  it("refuses two live grants for the same call as ambiguous without latching", () => {
    const io = granted();
    issueRootGrant(io, { ...PREPARE, ref: "grant-0123456789abcdef0004" });

    expect(attempt(io)).toBe("AUTHORIZATION_AMBIGUOUS");
    expect(latches(io)).toEqual([]);
  });

  it.each([
    ["prepare with the doctor operation", "prepare_discovery_agent", "doctor"],
    ["the sentinel tool", "discovery_capability_sentinel", "sentinel"],
    ["a root setup tool", "configure_discovery_workspace", "configure"],
    [
      "a controlled tool with a foreign operation",
      "read_discovery_source",
      "inventory",
    ],
  ])(
    "refuses %s as not root-grantable before any lookup",
    (_label, tool, operation) => {
      const io = granted();
      const listed = io.operations.length;
      expect(attempt(io, { tool, operation })).toBe(
        "AUTHORIZATION_REQUEST_INVALID",
      );
      expect(io.operations).toHaveLength(listed);
    },
  );

  it("rejects a malformed grant in the partition instead of skipping it", () => {
    const io = granted();
    io.files.set(`${rootGrantsDirectory(LOCATION)}/junk.json`, "{");

    expect(attempt(io)).toBe("AUTHORIZATION_RECORD_INVALID");
    expect(latches(io)).toEqual([]);
  });

  it("reports a lost latch race as consumed and propagates other store failures", () => {
    const raced = granted();
    raced.createExclusive = () => {
      throw new DiscoveryAuthorityError("AUTHORITY_LOCKED", "race");
    };
    expect(attempt(raced)).toBe("AUTHORIZATION_CONSUMED");

    const failing = granted();
    failing.createExclusive = () => {
      throw new Error("disk full");
    };
    expect(() => attempt(failing)).toThrow("disk full");
  });
});

describe("decodeRootGrant", () => {
  function record(overrides: Record<string, unknown> = {}): string {
    const io = granted(overrides);
    return io.files.get(rootGrantPath())!;
  }

  it("decodes a schema-valid grant with exactly the schema keys", () => {
    const decoded = decodeRootGrant(record());
    expect(Object.keys(decoded).sort()).toEqual([...ROOT_GRANT_RECORD_KEYS]);
    expect(decoded).toMatchObject({
      artifact_kind: "root-grant",
      tool: "prepare_discovery_agent",
      operation: "prepare-agent",
      tool_use_id: "toolu-0123456789abcdef",
      state: "issued",
    });
    expect(
      decodeRootGrant(record({ tool_use_id: null })).tool_use_id,
    ).toBeNull();
  });

  it.each([
    ["not JSON", "{"],
    ["an array", "[]"],
    ["a missing key", JSON.stringify({ ...JSON.parse(record()), extra: 1 })],
    ["a foreign host", record({ host: "cursor" })],
    ["a malformed session", record({ session_id: "" })],
    [
      "a non-grantable tool",
      record({ tool: "discovery_capability_sentinel", operation: "sentinel" }),
    ],
    ["an operation the tool cannot perform", record({ operation: "doctor" })],
    ["a short digest", record({ input_sha256: "abc" })],
    ["a malformed tool_use_id", record({ tool_use_id: "bad id" })],
    ["a malformed timestamp", record({ expires_at: "soon" })],
    ["an unknown state", record({ state: "pending" })],
  ])("rejects %s as a malformed record", (_label, text) => {
    expect(() => decodeRootGrant(text)).toThrow(
      "Root grant record is malformed",
    );
  });
});
