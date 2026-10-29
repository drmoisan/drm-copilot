/**
 * Prove the host-principal identity options come only from the one-use
 * authorization the gate consumed for the request's invocation, and that a
 * bound request without a consumed record is refused instead of being
 * downgraded to local-user.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  AUTHORIZATIONS_PARTITION,
  type ConsumedAuthorization,
  decodeToolAuthorization,
} from "../src/discovery-authorization";
import {
  consumeHostToolAuthorization,
  hostInvocationOptions,
  invocationOptions,
} from "../src/repo-automation-service-discovery-identity";
import { refusalCode } from "./discovery-authorization-test-support";
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
  seeded,
  WORKSPACE,
} from "./discovery-invocation-test-support";
import {
  buildServiceResult,
  FakeLauncher,
  successOutcome,
} from "./discovery-test-helpers";
import {
  provider,
  service,
} from "./repo-automation-service-discovery-test-support";

const CONSUME_AT = new Date("2026-10-22T12:01:00Z");

function readInput(invocationRef: string) {
  return {
    workspace_root: WORKSPACE.workspace_root,
    read_operation: "list",
    paths: ["src"],
    invocation_ref: invocationRef,
  };
}

function consumeInput(invocationRef: string) {
  return {
    workspaceRoot: WORKSPACE.workspace_root,
    tool: "read_discovery_source",
    operation: "read-source",
    inputs: readInput(invocationRef),
    invocationRef,
  };
}

/** A started invocation holding one issued grant for its read call. */
function granted(): PreparedStore {
  const store = startedStore();
  issueAuthorization(store.io, {
    invocationId: store.invocationId,
    tool: "read_discovery_source",
    operation: "read-source",
    inputs: readInput(store.invocationId),
  });
  return store;
}

function recordPath(store: PreparedStore): string {
  return `${invocationDirectory(LOCATION, CONTEXT.sessionId, store.invocationId)}/${AUTHORIZATIONS_PARTITION}/${AUTHORIZATION_REF}.json`;
}

function consume(store: PreparedStore): ConsumedAuthorization {
  return consumeHostToolAuthorization(
    provider(store.io, { now: () => CONSUME_AT }),
    consumeInput(store.invocationId),
  );
}

describe("consumeHostToolAuthorization", () => {
  it("consumes the grant bound to the started invocation and returns its identity", () => {
    const store = granted();

    const consumed = consume(store);

    expect(consumed.authorizationRef).toBe(AUTHORIZATION_REF);
    expect(consumed.identity).toEqual({
      host: CONTEXT.host,
      session_id: CONTEXT.sessionId,
      agent_id: AGENT_ID,
      role: AGENT_ROLE,
      invocation_id: store.invocationId,
    });
    expect(
      decodeToolAuthorization(store.io.files.get(recordPath(store))!).state,
    ).toBe("consumed");
    expect(store.io.files.has(`${recordPath(store)}.consumed`)).toBe(true);
  });

  it("refuses when the invocation has not started and when no invocation exists", () => {
    const prepared = preparedStore();
    issueAuthorization(prepared.io, {
      invocationId: prepared.invocationId,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: readInput(prepared.invocationId),
    });

    expect(refusalCode(() => consume(prepared))).toBe("AUTHORIZATION_IDENTITY");
    expect(
      refusalCode(() =>
        consumeHostToolAuthorization(
          provider(seeded()),
          consumeInput("invocation-0123456789abcdef0001"),
        ),
      ),
    ).toBe("AUTHORIZATION_MISSING");
  });
});

describe("service consumeDiscoveryToolAuthorization", () => {
  it("consumes the bound grant through the service without launching the runtime", () => {
    const store = granted();
    const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
    const subject = service(
      launcher,
      provider(store.io, { now: () => CONSUME_AT }),
    );

    const reference = subject.consumeDiscoveryToolAuthorization!(
      consumeInput(store.invocationId),
    );

    expect(reference).toBe(AUTHORIZATION_REF);
    expect(store.io.files.has(`${recordPath(store)}.consumed`)).toBe(true);
    expect(launcher.captures).toHaveLength(0);
  });

  it("refuses through the service when no invocation binds the reference", () => {
    const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
    const subject = service(launcher, provider(seeded()));

    expect(() =>
      subject.consumeDiscoveryToolAuthorization!(
        consumeInput("invocation-0123456789abcdef0001"),
      ),
    ).toThrow("No protected invocation");
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("hostInvocationOptions", () => {
  it("returns the host principal with the consumed record's agent, session, host and role", () => {
    const consumed = consume(granted());

    expect(hostInvocationOptions(consumed)).toEqual({
      principal: "host",
      authorId: AGENT_ID,
      sessionId: CONTEXT.sessionId,
      hostName: CONTEXT.host,
      agentRole: AGENT_ROLE,
    });
  });
});

describe("invocationOptions", () => {
  it("returns no identity for a root request", () => {
    expect(invocationOptions(undefined, undefined)).toEqual({});
  });

  it("returns the host identity for a request bound to the consumed invocation", () => {
    const store = granted();
    const consumed = consume(store);

    expect(invocationOptions(consumed, store.invocationId)).toMatchObject({
      principal: "host",
      authorId: AGENT_ID,
    });
  });

  it("refuses a bound request without a consumed record", () => {
    expect(() =>
      invocationOptions(undefined, "invocation-0123456789abcdef0001"),
    ).toThrow("DISCOVERY_HOST_BINDING_REQUIRED");
  });

  it("refuses a consumed record that binds another invocation", () => {
    const consumed = consume(granted());

    expect(() =>
      invocationOptions(consumed, "invocation-other-000000001"),
    ).toThrow("AUTHORIZATION_IDENTITY");
  });
});
