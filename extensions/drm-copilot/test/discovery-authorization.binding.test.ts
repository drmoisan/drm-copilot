/**
 * Prove one-use authorization consumption by trusted binding: the MCP gate
 * holds the raw tool input but no caller request id, so the grant is located
 * through the trusted session, the request's invocation reference and the
 * exact tool, operation and input digest.
 */

import {
  authorizationsDirectory,
  consumeToolAuthorizationByBinding,
  decodeToolAuthorization,
  type ToolAuthorizationRecord,
  type TrustedBinding,
} from "../src/discovery-authorization";
import {
  LOCATION,
  MemoryAuthorizationIO,
  NOW,
  refusalCode,
  REORDERED,
  seeded,
  SORTED,
  UNSORTED,
  vectors,
} from "./discovery-authorization-test-support";

/** The request's invocation reference names the partition the grants live in. */
const INVOCATION_REF = vectors.records.issued.invocation_ref;
const BOUND: TrustedBinding = {
  workspace: vectors.workspace,
  identity: { ...vectors.identity, invocation_id: INVOCATION_REF },
};
const DIRECTORY = authorizationsDirectory(LOCATION, BOUND.identity);

function store(
  entries: Record<string, ToolAuthorizationRecord | string> = {
    "authz-alpha.json": vectors.records.issued,
  },
): MemoryAuthorizationIO {
  return seeded(entries, DIRECTORY);
}

function attemptBound(
  io: MemoryAuthorizationIO,
  overrides: {
    tool?: string;
    operation?: string;
    inputs?: unknown;
    invocationRef?: string;
    trusted?: TrustedBinding;
    now?: Date;
  } = {},
): string {
  return refusalCode(() =>
    consumeToolAuthorizationByBinding({
      location: LOCATION,
      io,
      request: {
        tool: overrides.tool ?? UNSORTED!.tool,
        operation: overrides.operation ?? UNSORTED!.operation,
        inputs: overrides.inputs ?? UNSORTED!.inputs,
        invocationRef: overrides.invocationRef ?? INVOCATION_REF,
      },
      trusted: overrides.trusted ?? BOUND,
      now: overrides.now ?? NOW,
    }),
  );
}

describe("consumeToolAuthorizationByBinding admission", () => {
  it("consumes the unique grant bound to the identity, tool, operation and input", () => {
    const io = store();

    const result = consumeToolAuthorizationByBinding({
      location: LOCATION,
      io,
      request: {
        tool: UNSORTED!.tool,
        operation: UNSORTED!.operation,
        inputs: UNSORTED!.inputs,
        invocationRef: INVOCATION_REF,
      },
      trusted: BOUND,
      now: NOW,
    });

    expect(result.authorizationRef).toBe(
      vectors.records.issued.authorization_ref,
    );
    expect(result.inputSha256).toBe(SORTED!.input_sha256);
    expect(result.record.state).toBe("consumed");
    expect(decodeToolAuthorization(io.files.get(result.path)!)).toEqual(
      result.record,
    );
    expect(io.files.has(`${result.path}.consumed`)).toBe(true);
    // The second call with the same input finds the latched record and is refused.
    expect(attemptBound(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("ignores grants issued for other requests in the same invocation", () => {
    const other = {
      ...vectors.records.issued,
      id: "authz-other",
      request_id: "request-other",
      operation: "inventory",
      tool: "run_discovery_dotnet_analyzer" as const,
    };
    const io = store({
      "other.json": other,
      "authz-alpha.json": vectors.records.issued,
    });

    expect(attemptBound(io)).toBe("ADMITTED");
    expect(
      decodeToolAuthorization(io.files.get(`${DIRECTORY}/other.json`)!).state,
    ).toBe("issued");
  });

  it("refuses two live grants for the same call as ambiguous without consuming", () => {
    const io = store({
      "a.json": vectors.records.issued,
      "b.json": { ...vectors.records.issued, id: "authz-alpha-two" },
    });

    expect(attemptBound(io)).toBe("AUTHORIZATION_AMBIGUOUS");
    expect(io.operations).toEqual([]);
  });

  it.each([
    ["a consumed record", vectors.records.consumed],
    ["a revoked record", vectors.records.revoked],
  ])("refuses %s as consumed", (_label, record) => {
    expect(attemptBound(store({ "x.json": record }))).toBe(
      "AUTHORIZATION_CONSUMED",
    );
  });

  it("treats a latched record as consumed even when it still reads issued", () => {
    const io = store();
    io.files.set(`${DIRECTORY}/authz-alpha.json.consumed`, "{}\n");

    expect(attemptBound(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("consumes the current grant beside an expired one issued for the same call", () => {
    // A tool call retried after its first grant expired has two issued records;
    // the expired one is not live and must not make the retry ambiguous.
    const io = store({
      "stale.json": {
        ...vectors.records.expired,
        id: "authz-stale",
        request_id: vectors.records.issued.request_id,
        tool: vectors.records.issued.tool,
        operation: vectors.records.issued.operation,
        input_sha256: vectors.records.issued.input_sha256,
      },
      "fresh.json": vectors.records.issued,
    });

    expect(attemptBound(io)).toBe("ADMITTED");
    expect(io.files.has(`${DIRECTORY}/fresh.json.consumed`)).toBe(true);
    expect(io.files.has(`${DIRECTORY}/stale.json.consumed`)).toBe(false);
  });

  it("refuses an expired grant and a grant not yet valid", () => {
    expect(
      attemptBound(store({ "d.json": vectors.records.expired }), {
        inputs: UNSORTED!.inputs,
      }),
    ).toBe("AUTHORIZATION_EXPIRED");
    expect(
      attemptBound(store(), { now: new Date("2026-10-22T11:59:59Z") }),
    ).toBe("AUTHORIZATION_EXPIRED");
    expect(
      attemptBound(store(), { now: new Date("2026-10-22T12:05:00Z") }),
    ).toBe("AUTHORIZATION_EXPIRED");
  });
});

describe("consumeToolAuthorizationByBinding refusals", () => {
  it("reports missing when the invocation holds no grant at all", () => {
    expect(attemptBound(new MemoryAuthorizationIO())).toBe(
      "AUTHORIZATION_MISSING",
    );
    expect(
      attemptBound(store(), { invocationRef: "invocation-other-000001" }),
    ).toBe("AUTHORIZATION_REQUEST_INVALID");
  });

  it("refuses an invocation reference that is not the trusted invocation", () => {
    const trusted = {
      ...BOUND,
      identity: { ...BOUND.identity, invocation_id: "invocation-other-000001" },
    };
    expect(attemptBound(store(), { trusted })).toBe(
      "AUTHORIZATION_REQUEST_INVALID",
    );
  });

  it.each([
    ["agent id", { agent_id: "agent-beta" }],
    ["role", { role: "requirements-reconciler" }],
    ["host", { host: "codex" }],
  ])(
    "refuses a grant whose %s differs from the trusted identity",
    (_label, change) => {
      const trusted = { ...BOUND, identity: { ...BOUND.identity, ...change } };
      const io = store();

      expect(attemptBound(io, { trusted })).toBe("AUTHORIZATION_IDENTITY");
      expect(io.operations).toEqual([]);
    },
  );

  it("looks only in the trusted session's partition, so another session finds nothing", () => {
    const trusted = {
      ...BOUND,
      identity: { ...BOUND.identity, session_id: "session-beta" },
    };
    const io = store();

    expect(attemptBound(io, { trusted })).toBe("AUTHORIZATION_MISSING");
    expect(io.operations).toEqual([]);
  });

  it("refuses a grant bound to another workspace or profile", () => {
    const foreign = { ...vectors.workspace, profile_sha256: "0".repeat(64) };
    expect(
      attemptBound(store(), { trusted: { ...BOUND, workspace: foreign } }),
    ).toBe("AUTHORIZATION_WORKSPACE");
  });

  it.each([
    ["another tool", { tool: "run_discovery_dotnet_analyzer" }],
    ["reordered list input", { inputs: REORDERED!.inputs }],
    ["an extra input key", { inputs: { ...UNSORTED!.inputs, extra: 1 } }],
  ])(
    "refuses %s as an input mismatch without consuming",
    (_label, overrides) => {
      const io = store();

      expect(attemptBound(io, overrides)).toBe("AUTHORIZATION_INPUT");
      expect(io.operations).toEqual([]);
    },
  );

  it("refuses another operation of the same tool as an input mismatch", () => {
    const io = store({
      "c.json": {
        ...vectors.records.issued,
        tool: "create_discovery_artifact",
        operation: "new-contract",
      },
    });

    expect(
      attemptBound(io, {
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
    const io = store();
    expect(attemptBound(io, { operation })).toBe(code);
    expect(io.operations).toEqual([]);
  });

  it("refuses caller identity and authority claims in the raw input", () => {
    expect(
      attemptBound(store(), {
        inputs: { ...UNSORTED!.inputs, role: "native-root" },
      }),
    ).toBe("AUTHORIZATION_REQUEST_INVALID");
    expect(
      attemptBound(store(), {
        inputs: { ...UNSORTED!.inputs, authorization_ref: "x".repeat(20) },
      }),
    ).toBe("AUTHORITY_CLAIM_REJECTED");
  });

  it("rejects a malformed record in the partition instead of skipping it", () => {
    const io = store({
      "authz-alpha.json": vectors.records.issued,
      "junk.json": "{",
    });
    expect(attemptBound(io)).toBe("AUTHORIZATION_RECORD_INVALID");
    expect(io.operations).toEqual([]);
  });
});
