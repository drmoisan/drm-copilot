/**
 * Prove one-use tool authorization consumption over injected store seams.
 *
 * Records and digests come from the shared host fixture; the consumer runs
 * over an in-memory `AuthorizationStoreIO` and the Node adapter is driven
 * through a fake `node:fs`, so no filesystem is touched.
 */

import * as path from "node:path";

import {
  type AuthorizationFileSystemModule,
  consumeToolAuthorization,
  createNodeAuthorizationStoreIO,
  decodeToolAuthorization,
  type DiscoveryAuthorizationError,
} from "../src/discovery-authorization";
import {
  attempt,
  DIRECTORY,
  LOCATION,
  MemoryAuthorizationIO,
  NOW,
  REORDERED,
  seeded,
  SORTED,
  TRUSTED,
  UNSORTED,
  vectors,
} from "./discovery-authorization-test-support";

describe("consumeToolAuthorization admission", () => {
  it("consumes the unique matching grant exactly once", () => {
    const io = seeded();
    const result = consumeToolAuthorization({
      location: LOCATION,
      io,
      request: {
        requestId: "request-alpha",
        tool: UNSORTED!.tool,
        operation: UNSORTED!.operation,
        inputs: UNSORTED!.inputs,
      },
      trusted: TRUSTED,
      now: NOW,
    });
    expect(result.authorizationRef).toBe(
      vectors.records.issued.authorization_ref,
    );
    expect(result.inputSha256).toBe(SORTED!.input_sha256);
    expect(result.record.state).toBe("consumed");
    expect(result.record.consumed_at).toBe(NOW.toISOString());
    const stored = decodeToolAuthorization(io.files.get(result.path)!);
    expect(stored).toEqual(result.record);
    expect(io.files.has(`${result.path}.consumed`)).toBe(true);
    expect(io.files.has(`${result.path}.staged`)).toBe(false);
    // Replay of the same request finds the consumed record and is refused.
    expect(attempt(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("admits at issued_at and refuses at expires_at", () => {
    expect(attempt(seeded(), { now: new Date("2026-10-22T12:00:00Z") })).toBe(
      "ADMITTED",
    );
    expect(attempt(seeded(), { now: new Date("2026-10-22T12:05:00Z") })).toBe(
      "AUTHORIZATION_EXPIRED",
    );
    expect(attempt(seeded(), { now: new Date("2026-10-22T11:59:59Z") })).toBe(
      "AUTHORIZATION_EXPIRED",
    );
    expect(
      attempt(seeded({ "authz-delta.json": vectors.records.expired }), {
        requestId: "request-delta",
      }),
    ).toBe("AUTHORIZATION_EXPIRED");
  });

  it.each([
    ["zero matches", {}, { requestId: "request-zeta" }],
    ["case-different id", {}, { requestId: "Request-Alpha" }],
    [
      "other invocation",
      {},
      {
        trusted: {
          ...TRUSTED,
          identity: { ...vectors.identity, invocation_id: "invocation-beta" },
        },
      },
    ],
  ])("reports missing for %s", (_label, _entries, overrides) => {
    expect(attempt(seeded(), overrides)).toBe("AUTHORIZATION_MISSING");
  });

  it("reports missing when the directory does not exist", () => {
    expect(attempt(new MemoryAuthorizationIO())).toBe("AUTHORIZATION_MISSING");
  });

  it("refuses duplicate issued grants as ambiguous without consuming either", () => {
    const io = seeded({
      "a.json": vectors.records.issued,
      "b.json": { ...vectors.records.issued, id: "authz-alpha-two" },
    });
    expect(attempt(io)).toBe("AUTHORIZATION_AMBIGUOUS");
    expect(io.operations).toEqual([]);
  });

  it("refuses consumed and revoked grants", () => {
    const io = seeded({
      "beta.json": vectors.records.consumed,
      "gamma.json": vectors.records.revoked,
    });
    expect(attempt(io, { requestId: "request-beta" })).toBe(
      "AUTHORIZATION_CONSUMED",
    );
    expect(attempt(io, { requestId: "request-gamma" })).toBe(
      "AUTHORIZATION_CONSUMED",
    );
  });

  it("treats a pre-existing latch as consumed even when the record says issued", () => {
    const io = seeded();
    io.files.set(`${DIRECTORY}/authz-alpha.json.consumed`, "{}\n");
    expect(attempt(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("lets exactly one of two concurrent consumers win", () => {
    const io = seeded();
    let second = "unset";
    io.afterCreate = (created) => {
      if (created.endsWith(".consumed") && second === "unset") {
        second = attempt(io);
      }
    };
    expect(attempt(io)).toBe("ADMITTED");
    expect(second).toBe("AUTHORIZATION_CONSUMED");
    expect(
      decodeToolAuthorization(io.files.get(`${DIRECTORY}/authz-alpha.json`)!)
        .state,
    ).toBe("consumed");
  });

  it("keeps the latch when the consumed rewrite fails so no replay succeeds", () => {
    const io = seeded();
    io.failPublish = true;
    expect(() => attempt(io)).toThrow("publish failed");
    expect(io.files.has(`${DIRECTORY}/authz-alpha.json.consumed`)).toBe(true);
    expect(io.files.has(`${DIRECTORY}/authz-alpha.json.staged`)).toBe(false);
    io.failPublish = false;
    expect(attempt(io)).toBe("AUTHORIZATION_CONSUMED");
  });

  it("rejects a malformed record in the directory instead of skipping it", () => {
    const io = seeded({
      "authz-alpha.json": vectors.records.issued,
      "junk.json": "{",
    });
    expect(attempt(io)).toBe("AUTHORIZATION_RECORD_INVALID");
    expect(io.operations).toEqual([]);
  });

  it("ignores non-JSON entries and entries that vanish between list and read", () => {
    const io = seeded({ "authz-alpha.json": vectors.records.issued });
    io.files.set(`${DIRECTORY}/notes.txt`, "ignored");
    io.files.set(`${DIRECTORY}/ghost.json`, "{}");
    const original = io.readText.bind(io);
    io.readText = (target: string) =>
      target.endsWith("ghost.json") ? null : original(target);
    expect(attempt(io)).toBe("ADMITTED");
  });
});

describe("consumeToolAuthorization binding refusals", () => {
  it("refuses a grant bound to another workspace or profile", () => {
    const foreign = { ...vectors.workspace, profile_sha256: "0".repeat(64) };
    expect(
      attempt(seeded(), { trusted: { ...TRUSTED, workspace: foreign } }),
    ).toBe("AUTHORIZATION_WORKSPACE");
  });

  it("refuses a grant whose identity differs from the trusted identity", () => {
    const io = seeded({
      "epsilon.json": vectors.records["root-identity-forgery"],
    });
    expect(attempt(io, { requestId: "request-epsilon" })).toBe(
      "AUTHORIZATION_IDENTITY",
    );
    const agent = { ...vectors.identity, agent_id: "agent-beta" };
    expect(
      attempt(seeded(), { trusted: { ...TRUSTED, identity: agent } }),
    ).toBe("AUTHORIZATION_IDENTITY");
  });

  it.each([
    ["reordered list input", { inputs: REORDERED!.inputs }],
    ["extra input key", { inputs: { ...UNSORTED!.inputs, extra: 1 } }],
    [
      "another tool for the same operation",
      { tool: "run_discovery_dotnet_analyzer" },
    ],
  ])("refuses %s as an input mismatch", (_label, overrides) => {
    const io = seeded();
    expect(attempt(io, overrides)).toBe("AUTHORIZATION_INPUT");
    expect(io.operations).toEqual([]);
  });

  it.each([
    ["configure", "AUTHORIZATION_ROOT_ONLY"],
    ["prepare-agent", "AUTHORIZATION_ROOT_ONLY"],
    ["init", "AUTHORIZATION_ROOT_ONLY"],
    ["exec", "AUTHORIZATION_OPERATION_UNKNOWN"],
    ["validate", "AUTHORIZATION_OPERATION_UNKNOWN"],
    ["read-source", "AUTHORIZATION_TOOL_OPERATION"],
  ])("refuses operation %s before any lookup", (operation, code) => {
    const io = seeded();
    expect(attempt(io, { operation })).toBe(code);
  });

  it.each([
    ["unknown tool", { tool: "run_shell" }, "AUTHORIZATION_REQUEST_INVALID"],
    ["blank request id", { requestId: "" }, "AUTHORIZATION_REQUEST_INVALID"],
    [
      "request id with space",
      { requestId: "has space" },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
    [
      "caller role claim",
      { inputs: { ...UNSORTED!.inputs, role: "native-root" } },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
    [
      "caller request id claim",
      { inputs: { ...UNSORTED!.inputs, request_id: "request-alpha" } },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
    [
      "authority claim",
      { inputs: { ...UNSORTED!.inputs, authorization_ref: "x".repeat(20) } },
      "AUTHORITY_CLAIM_REJECTED",
    ],
    [
      "identity claim",
      { inputs: { ...UNSORTED!.inputs, identity: vectors.identity } },
      "AUTHORITY_CLAIM_REJECTED",
    ],
    ["non-object inputs", { inputs: "text" }, "AUTHORIZATION_INPUT_INVALID"],
  ])("refuses %s", (_label, overrides, code) => {
    const io = seeded();
    expect(attempt(io, overrides)).toBe(code);
    expect(io.operations).toEqual([]);
  });

  it("does not let a forged record admit a root-only operation", () => {
    const forged = { ...vectors.records.issued, operation: "configure" };
    const io = seeded({ "forged.json": forged });
    expect(attempt(io, { operation: "configure" })).toBe(
      "AUTHORIZATION_ROOT_ONLY",
    );
    expect(attempt(io)).toBe("AUTHORIZATION_RECORD_INVALID");
  });
});

describe("createNodeAuthorizationStoreIO", () => {
  function fakeFs(entries: string[] | Error): AuthorizationFileSystemModule {
    return {
      readFileSync: () => {
        throw Object.assign(new Error("ENOENT"), { code: "ENOENT" });
      },
      writeFileSync: () => undefined,
      renameSync: () => undefined,
      linkSync: () => undefined,
      unlinkSync: () => undefined,
      mkdirSync: () => undefined,
      readdirSync: () => {
        if (entries instanceof Error) {
          throw entries;
        }
        return [...entries];
      },
    };
  }

  it("lists entries sorted and composes the authority adapter", () => {
    const io = createNodeAuthorizationStoreIO(fakeFs(["b.json", "a.json"]));
    expect(io.listEntries("/state")).toEqual(["a.json", "b.json"]);
    expect(io.readText("/state/missing")).toBeNull();
  });

  it("returns no entries for an absent directory and reports other failures", () => {
    const absent = createNodeAuthorizationStoreIO(
      fakeFs(Object.assign(new Error("ENOENT"), { code: "ENOENT" })),
    );
    expect(absent.listEntries("/state")).toEqual([]);
    const denied = createNodeAuthorizationStoreIO(
      fakeFs(Object.assign(new Error("EACCES"), { code: "EACCES" })),
    );
    let code = "NO_ERROR";
    try {
      denied.listEntries("/state");
    } catch (error) {
      code = (error as DiscoveryAuthorizationError).code;
    }
    expect(code).toBe("AUTHORIZATION_IO");
    const odd = createNodeAuthorizationStoreIO(fakeFs(new Error("plain")));
    expect(() => odd.listEntries("/state")).toThrow("plain");
  });

  it("defaults to node:fs and lists nothing for a directory that does not exist", () => {
    const io = createNodeAuthorizationStoreIO();
    expect(io.listEntries(path.join(__dirname, "does-not-exist"))).toEqual([]);
  });
});
