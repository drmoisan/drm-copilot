/**
 * Prove one-use authorization consumption by invocation reference: the MCP
 * server holds the raw tool input but no caller request id and no identity of
 * its own, so the request's `invocation_ref` selects the started invocation
 * across every session, the record identity must equal that invocation's, and
 * the exact tool, operation and input digest select the grant.
 */

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  type ControlledTool,
  decodeToolAuthorization,
  type ToolAuthorizationRecord,
} from "../src/discovery-authorization";
import { consumeToolAuthorizationByBinding } from "../src/discovery-authorization-binding";
import {
  refusalCode,
  REORDERED,
  UNSORTED,
} from "./discovery-authorization-test-support";
import {
  AGENT_ID,
  AGENT_ROLE,
  AUTHORIZATION_REF,
  issueAuthorization,
  type PreparedStore,
  preparedStore,
  startedStore,
} from "./discovery-grant-test-support";
import {
  CONTEXT,
  LOCATION,
  WORKSPACE,
} from "./discovery-invocation-test-support";
import type { MemoryStoreIO } from "./discovery-store-test-helpers";

const NOW = new Date("2026-10-22T12:01:00Z");
const TOOL = UNSORTED!.tool as ControlledTool;
const OPERATION = UNSORTED!.operation;
const INPUTS = UNSORTED!.inputs;

/** A started invocation holding one issued grant for the vector call. */
function granted(
  overrides: Partial<Parameters<typeof issueAuthorization>[1]> = {},
): PreparedStore & { ref: string } {
  const store = startedStore();
  const ref = issueAuthorization(store.io, {
    invocationId: store.invocationId,
    tool: TOOL,
    operation: OPERATION,
    inputs: INPUTS,
    ...overrides,
  });
  return { ...store, ref };
}

function latches(io: MemoryStoreIO): string[] {
  return [...io.files.keys()].filter((key) => key.endsWith(".consumed"));
}

function attempt(
  store: PreparedStore,
  overrides: {
    tool?: string;
    operation?: string;
    inputs?: unknown;
    invocationRef?: string;
    workspace?: ToolAuthorizationRecord["workspace"];
    now?: Date;
  } = {},
): string {
  return refusalCode(() =>
    consumeToolAuthorizationByBinding({
      location: LOCATION,
      io: store.io,
      request: {
        tool: overrides.tool ?? TOOL,
        operation: overrides.operation ?? OPERATION,
        inputs: overrides.inputs ?? INPUTS,
        invocationRef: overrides.invocationRef ?? store.invocationId,
      },
      workspace: overrides.workspace ?? WORKSPACE,
      now: overrides.now ?? NOW,
    }),
  );
}

describe("consumeToolAuthorizationByBinding admission", () => {
  it("consumes the unique grant of the started invocation and returns its identity", () => {
    const store = granted();

    const result = consumeToolAuthorizationByBinding({
      location: LOCATION,
      io: store.io,
      request: {
        tool: TOOL,
        operation: OPERATION,
        inputs: INPUTS,
        invocationRef: store.invocationId,
      },
      workspace: WORKSPACE,
      now: NOW,
    });

    expect(result.authorizationRef).toBe(AUTHORIZATION_REF);
    expect(result.identity).toEqual({
      host: CONTEXT.host,
      session_id: CONTEXT.sessionId,
      agent_id: AGENT_ID,
      role: AGENT_ROLE,
      invocation_id: store.invocationId,
    });
    expect(result.record.state).toBe("consumed");
    expect(decodeToolAuthorization(store.io.files.get(result.path)!)).toEqual(
      result.record,
    );
    expect(store.io.files.has(`${result.path}.consumed`)).toBe(true);
    // The second call with the same input finds the latched record and is refused.
    expect(attempt(store)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("ignores grants issued for other calls of the same invocation", () => {
    const store = granted();
    issueAuthorization(store.io, {
      invocationId: store.invocationId,
      tool: "run_discovery_dotnet_analyzer",
      operation: "inventory",
      inputs: INPUTS,
      ref: "authz-other-0000000000000001",
    });

    expect(attempt(store)).toBe("ADMITTED");
    const directory = `${invocationDirectory(LOCATION, CONTEXT.sessionId, store.invocationId)}/authorizations`;
    expect(
      decodeToolAuthorization(
        store.io.files.get(`${directory}/authz-other-0000000000000001.json`)!,
      ).state,
    ).toBe("issued");
  });

  it("refuses two live grants for the same call as ambiguous without consuming", () => {
    const store = granted();
    issueAuthorization(store.io, {
      invocationId: store.invocationId,
      tool: TOOL,
      operation: OPERATION,
      inputs: INPUTS,
      ref: "authz-alpha-0000000000000002",
    });

    expect(attempt(store)).toBe("AUTHORIZATION_AMBIGUOUS");
    expect(latches(store.io)).toEqual([]);
  });

  it.each([
    [
      "a consumed record",
      { state: "consumed", consumed_at: "2026-10-22T12:00:30Z" },
    ],
    ["a revoked record", { state: "revoked" }],
  ] as const)("refuses %s as consumed", (_label, record) => {
    expect(attempt(granted({ record }))).toBe("AUTHORIZATION_CONSUMED");
  });

  it("treats a latched record as consumed even when it still reads issued", () => {
    const store = granted();
    const directory = `${invocationDirectory(LOCATION, CONTEXT.sessionId, store.invocationId)}/authorizations`;
    store.io.files.set(
      `${directory}/${AUTHORIZATION_REF}.json.consumed`,
      "{}\n",
    );

    expect(attempt(store)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("consumes the current grant beside an expired one issued for the same call", () => {
    // A tool call retried after its first grant expired has two issued records;
    // the expired one is not live and must not make the retry ambiguous.
    const store = granted();
    issueAuthorization(store.io, {
      invocationId: store.invocationId,
      tool: TOOL,
      operation: OPERATION,
      inputs: INPUTS,
      ref: "authz-stale-0000000000000001",
      record: {
        issued_at: "2026-10-22T11:00:00Z",
        expires_at: "2026-10-22T11:05:00Z",
      },
    });

    expect(attempt(store)).toBe("ADMITTED");
    expect(latches(store.io)).toHaveLength(1);
    expect(latches(store.io)[0]).toContain(AUTHORIZATION_REF);
  });

  it("refuses an expired grant and a grant not yet valid", () => {
    expect(attempt(granted(), { now: new Date("2026-10-22T11:58:59Z") })).toBe(
      "AUTHORIZATION_EXPIRED",
    );
    expect(attempt(granted(), { now: new Date("2026-10-22T12:30:00Z") })).toBe(
      "AUTHORIZATION_EXPIRED",
    );
  });
});

describe("consumeToolAuthorizationByBinding refusals", () => {
  it("reports missing when no session holds the invocation", () => {
    const store = granted();
    expect(attempt(store, { invocationRef: "invocation-other-000001" })).toBe(
      "AUTHORIZATION_MISSING",
    );
    expect(attempt(store, { invocationRef: "not a correlation id" })).toBe(
      "AUTHORIZATION_REQUEST_INVALID",
    );
  });

  it("refuses an invocation that is prepared but not started: no agent is bound yet", () => {
    const store = preparedStore();
    issueAuthorization(store.io, {
      invocationId: store.invocationId,
      tool: TOOL,
      operation: OPERATION,
      inputs: INPUTS,
    });

    expect(attempt(store)).toBe("AUTHORIZATION_IDENTITY");
    expect(latches(store.io)).toEqual([]);
  });

  it("refuses an invocation reference that two sessions both hold as ambiguous", () => {
    const store = granted();
    const own = `${invocationDirectory(LOCATION, CONTEXT.sessionId, store.invocationId)}/invocation.json`;
    const foreign = `${invocationDirectory(LOCATION, "session-beta", store.invocationId)}/invocation.json`;
    store.io.files.set(foreign, store.io.files.get(own)!);

    expect(attempt(store)).toBe("AUTHORIZATION_AMBIGUOUS");
    expect(latches(store.io)).toEqual([]);
  });

  it.each([
    ["agent id", { agentId: "agent-beta" }],
    ["role", { role: "requirements-reconciler" }],
    ["host", { host: "claude-code" }],
  ])(
    "refuses a grant whose %s differs from the started invocation",
    (_label, change) => {
      const store = granted(change);

      expect(attempt(store)).toBe("AUTHORIZATION_IDENTITY");
      expect(latches(store.io)).toEqual([]);
    },
  );

  it("refuses a grant bound to another workspace or profile", () => {
    const foreign = { ...WORKSPACE, profile_sha256: "0".repeat(64) };
    expect(attempt(granted(), { workspace: foreign })).toBe(
      "AUTHORIZATION_WORKSPACE",
    );
  });

  it.each([
    ["another tool", { tool: "run_discovery_dotnet_analyzer" }],
    ["reordered list input", { inputs: REORDERED!.inputs }],
    ["an extra input key", { inputs: { ...UNSORTED!.inputs, extra: 1 } }],
  ])(
    "refuses %s as an input mismatch without consuming",
    (_label, overrides) => {
      const store = granted();

      expect(attempt(store, overrides)).toBe("AUTHORIZATION_INPUT");
      expect(latches(store.io)).toEqual([]);
    },
  );

  it("refuses another operation of the same tool as an input mismatch", () => {
    const store = granted({
      tool: "create_discovery_artifact",
      operation: "new-contract",
    });

    expect(
      attempt(store, {
        tool: "create_discovery_artifact",
        operation: "new-scenario",
      }),
    ).toBe("AUTHORIZATION_INPUT");
  });

  it.each([
    ["configure", "AUTHORIZATION_ROOT_ONLY"],
    ["prepare-agent", "AUTHORIZATION_ROOT_ONLY"],
    ["exec", "AUTHORIZATION_OPERATION_UNKNOWN"],
    ["read-source", "AUTHORIZATION_TOOL_OPERATION"],
  ])("refuses operation %s before any lookup", (operation, code) => {
    const store = granted();
    const listed = store.io.operations.length;
    expect(attempt(store, { operation })).toBe(code);
    expect(store.io.operations).toHaveLength(listed);
  });

  it("refuses caller identity and authority claims in the raw input", () => {
    expect(
      attempt(granted(), {
        inputs: { ...UNSORTED!.inputs, role: "native-root" },
      }),
    ).toBe("AUTHORIZATION_REQUEST_INVALID");
    expect(
      attempt(granted(), {
        inputs: { ...UNSORTED!.inputs, authorization_ref: "x".repeat(20) },
      }),
    ).toBe("AUTHORITY_CLAIM_REJECTED");
  });

  it("rejects a malformed record in the partition instead of skipping it", () => {
    const store = granted();
    const directory = `${invocationDirectory(LOCATION, CONTEXT.sessionId, store.invocationId)}/authorizations`;
    store.io.files.set(`${directory}/junk.json`, "{");

    expect(attempt(store)).toBe("AUTHORIZATION_RECORD_INVALID");
    expect(latches(store.io)).toEqual([]);
  });

  it("rejects a malformed invocation record instead of attributing the call", () => {
    const store = granted();
    const path = `${invocationDirectory(LOCATION, CONTEXT.sessionId, store.invocationId)}/invocation.json`;
    store.io.files.set(path, "{}");

    expect(attempt(store)).toBe("AUTHORIZATION_RECORD_INVALID");
    expect(latches(store.io)).toEqual([]);
  });
});
