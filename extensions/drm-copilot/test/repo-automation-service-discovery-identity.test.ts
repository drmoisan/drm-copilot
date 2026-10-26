/**
 * Prove the host-principal identity options come only from the trusted
 * authority provider and that a bound request without an agent identity is
 * refused instead of being downgraded to local-user.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import {
  hostInvocationOptions,
  invocationOptions,
} from "../src/repo-automation-service-discovery-identity";
import { seeded } from "./discovery-invocation-test-support";
import { provider } from "./repo-automation-service-discovery-test-support";

const AGENT = { agentId: "agent-alpha", role: "legacy-parity-analyst" };

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
