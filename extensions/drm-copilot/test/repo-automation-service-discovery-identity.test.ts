/**
 * Prove the host-principal identity options come only from the trusted
 * authority provider and that a bound request without an agent identity is
 * refused instead of being downgraded to local-user.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  AUTHORIZATIONS_PARTITION,
  computeInputDigest,
  decodeToolAuthorization,
} from "../src/discovery-authorization";
import {
  consumeHostToolAuthorization,
  hostInvocationOptions,
  invocationOptions,
} from "../src/repo-automation-service-discovery-identity";
import { vectors } from "./discovery-authorization-test-support";
import {
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

const AGENT = { agentId: "agent-alpha", role: "legacy-parity-analyst" };
const INVOCATION_REF = "invocation-0123456789abcdef0001";
const READ_INPUT = {
  workspace_root: WORKSPACE.workspace_root,
  read_operation: "list",
  paths: ["src"],
  invocation_ref: INVOCATION_REF,
};
const RECORD_PATH = `${invocationDirectory(LOCATION, "session-alpha", INVOCATION_REF)}/${AUTHORIZATIONS_PARTITION}/authz-alpha.json`;

/** An issued grant bound to the provider's workspace, identity and the read call. */
function issuedGrant() {
  return {
    ...vectors.records.issued,
    workspace: WORKSPACE,
    identity: {
      host: "codex",
      session_id: "session-alpha",
      agent_id: AGENT.agentId,
      role: AGENT.role,
      invocation_id: INVOCATION_REF,
    },
    tool: "read_discovery_source" as const,
    operation: "read-source",
    input_sha256: computeInputDigest(
      "read_discovery_source",
      "read-source",
      READ_INPUT,
    ),
    invocation_ref: INVOCATION_REF,
  };
}

describe("consumeHostToolAuthorization", () => {
  it("consumes the grant bound to the provider identity and the request", () => {
    const io = seeded();
    io.files.set(RECORD_PATH, JSON.stringify(issuedGrant()));
    const authority = provider(io, {
      agent: AGENT,
      now: () => new Date("2026-10-22T12:01:00Z"),
    });

    const reference = consumeHostToolAuthorization(authority, {
      workspaceRoot: WORKSPACE.workspace_root,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: READ_INPUT,
      invocationRef: INVOCATION_REF,
    });

    expect(reference).toBe(vectors.records.issued.authorization_ref);
    expect(decodeToolAuthorization(io.files.get(RECORD_PATH)!).state).toBe(
      "consumed",
    );
    expect(io.files.has(`${RECORD_PATH}.consumed`)).toBe(true);
  });

  it("refuses without an agent identity and without a grant", () => {
    const io = seeded();
    const input = {
      workspaceRoot: WORKSPACE.workspace_root,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: READ_INPUT,
      invocationRef: INVOCATION_REF,
    };

    expect(() => consumeHostToolAuthorization(provider(io), input)).toThrow(
      "DISCOVERY_AGENT_IDENTITY_REQUIRED",
    );
    expect(() =>
      consumeHostToolAuthorization(provider(io, { agent: AGENT }), input),
    ).toThrow("No native authorization exists");
  });
});

describe("service consumeDiscoveryToolAuthorization", () => {
  const input = {
    workspaceRoot: WORKSPACE.workspace_root,
    tool: "read_discovery_source",
    operation: "read-source",
    inputs: READ_INPUT,
    invocationRef: INVOCATION_REF,
  };

  it("consumes the bound grant through the service's trusted provider", () => {
    const io = seeded();
    io.files.set(RECORD_PATH, JSON.stringify(issuedGrant()));
    const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
    const subject = service(
      launcher,
      provider(io, {
        agent: AGENT,
        now: () => new Date("2026-10-22T12:01:00Z"),
      }),
    );

    const reference = subject.consumeDiscoveryToolAuthorization?.(input);

    expect(reference).toBe(vectors.records.issued.authorization_ref);
    expect(io.files.has(`${RECORD_PATH}.consumed`)).toBe(true);
    expect(launcher.captures).toHaveLength(0);
  });

  it("refuses through the service when the provider has no agent identity", () => {
    const launcher = new FakeLauncher(successOutcome(buildServiceResult()));
    const subject = service(launcher, provider(seeded()));

    expect(() => subject.consumeDiscoveryToolAuthorization?.(input)).toThrow(
      "DISCOVERY_AGENT_IDENTITY_REQUIRED",
    );
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("hostInvocationOptions", () => {
  it("returns the host principal with the trusted agent, session, host and role", () => {
    const authority = provider(seeded(), { agent: AGENT });

    const options = hostInvocationOptions(authority);

    expect(options).toEqual({
      principal: "host",
      authorId: "agent-alpha",
      sessionId: "session-alpha",
      hostName: "codex",
      agentRole: "legacy-parity-analyst",
    });
  });

  it("refuses a process without a trusted agent identity", () => {
    const authority = provider(seeded());

    expect(() => hostInvocationOptions(authority)).toThrow(
      "DISCOVERY_AGENT_IDENTITY_REQUIRED",
    );
  });
});

describe("invocationOptions", () => {
  it("returns no identity for a root request without consulting the provider", () => {
    let consulted = 0;

    const options = invocationOptions(() => {
      consulted += 1;
      return provider(seeded(), { agent: AGENT });
    }, undefined);

    expect(options).toEqual({});
    expect(consulted).toBe(0);
  });

  it("returns the host identity for a request bound to an invocation", () => {
    const options = invocationOptions(
      () => provider(seeded(), { agent: AGENT }),
      "invocation-alpha-0000000001",
    );

    expect(options).toMatchObject({
      principal: "host",
      authorId: "agent-alpha",
    });
  });

  it("refuses a bound request without a trusted agent identity", () => {
    expect(() =>
      invocationOptions(
        () => provider(seeded()),
        "invocation-alpha-0000000001",
      ),
    ).toThrow("DISCOVERY_AGENT_IDENTITY_REQUIRED");
  });
});
