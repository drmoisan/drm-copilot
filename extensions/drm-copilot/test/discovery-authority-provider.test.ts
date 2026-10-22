/**
 * Prove the Node authority provider maps host values onto the trusted seams.
 *
 * Environment, platform, home directory, clock and nonce are injected so the
 * mapping is checked without reading the real process.
 */

import { describe, expect, it } from "@jest/globals";

import {
  authorityPlatform,
  createNodeDiscoveryAuthorityProvider,
  DISCOVERY_ENVIRONMENT_KEYS,
  trustedHostEnvironment,
} from "../src/discovery-authority-provider";
import {
  MemoryInputReader,
  MemoryStoreIO,
} from "./discovery-store-test-helpers";

const ENV = {
  [DISCOVERY_ENVIRONMENT_KEYS.host]: "codex",
  [DISCOVERY_ENVIRONMENT_KEYS.sessionId]: "session-alpha",
  [DISCOVERY_ENVIRONMENT_KEYS.parentAgentId]: "root-alpha",
  [DISCOVERY_ENVIRONMENT_KEYS.parentRole]: "orchestrator",
  [DISCOVERY_ENVIRONMENT_KEYS.agentId]: "agent-alpha",
  [DISCOVERY_ENVIRONMENT_KEYS.agentRole]: "legacy-parity-analyst",
  [DISCOVERY_ENVIRONMENT_KEYS.localAppData]: "C:/Users/Example/AppData/Local",
};

describe("createNodeDiscoveryAuthorityProvider", () => {
  it("maps the launch context, agent identity and injected seams", () => {
    const io = new MemoryStoreIO();
    const reader = new MemoryInputReader();
    const now = new Date("2026-10-22T12:00:00Z");
    const provider = createNodeDiscoveryAuthorityProvider({
      env: ENV,
      platform: "win32",
      homedir: "C:/Users/Example",
      io,
      reader,
      now: () => now,
      nonce: () => "0123456789abcdef",
      component: "standalone-mcp",
      buildSha256: "b".repeat(64),
    });
    expect(provider.context).toEqual({
      host: "codex",
      sessionId: "session-alpha",
      parentAgentId: "root-alpha",
      parentRole: "orchestrator",
    });
    expect(provider.agent).toEqual({
      agentId: "agent-alpha",
      role: "legacy-parity-analyst",
    });
    expect(provider.io).toBe(io);
    expect(provider.reader).toBe(reader);
    expect(provider.now()).toBe(now);
    expect(provider.nonce()).toBe("0123456789abcdef");
    expect(provider.writer).toEqual({
      component: "standalone-mcp",
      id: "gateway-0123456789abcdef",
      build_sha256: "b".repeat(64),
    });
    const location = provider.location("C:/Users/Example/Repos/Workspace");
    expect(location.root).toBe(
      "C:/Users/Example/AppData/Local/drm-copilot/discovery",
    );
    expect(provider.activation(location).envelope).toBeDefined();
    expect(() => provider.activation(location).envelope()).toThrow(
      "absent or deactivated",
    );
  });

  it("reports no agent and empty context values when the environment is bare", () => {
    const provider = createNodeDiscoveryAuthorityProvider({
      env: {},
      platform: "linux",
      homedir: "/home/example",
      io: new MemoryStoreIO(),
      reader: new MemoryInputReader(),
    });
    expect(provider.agent).toBeNull();
    expect(provider.context).toEqual({
      host: "",
      sessionId: "",
      parentAgentId: "",
      parentRole: null,
    });
    expect(provider.writer.component).toBe("extension");
    expect(provider.writer.id).toMatch(/^gateway-[0-9a-f]{32}$/u);
    expect(provider.writer.build_sha256).toBe("0".repeat(64));
    expect(provider.nonce()).toMatch(/^[0-9a-f]{32}$/u);
    expect(provider.now()).toBeInstanceOf(Date);
    expect(provider.location("/home/example/repo").root).toBe(
      "/home/example/.local/state/drm-copilot/discovery",
    );
  });

  it("maps platforms and state roots the way the Python resolver does", () => {
    expect(authorityPlatform("win32")).toBe("windows");
    expect(authorityPlatform("darwin")).toBe("macos");
    expect(authorityPlatform("linux")).toBe("linux");
    expect(authorityPlatform("freebsd")).toBe("linux");
    expect(trustedHostEnvironment("darwin", "/Users/example", {})).toEqual({
      platform: "macos",
      userHome: "/Users/example",
      localAppData: null,
      xdgStateHome: null,
    });
    const linux = createNodeDiscoveryAuthorityProvider({
      env: { [DISCOVERY_ENVIRONMENT_KEYS.xdgStateHome]: "/var/state" },
      platform: "linux",
      homedir: "/home/example",
      io: new MemoryStoreIO(),
      reader: new MemoryInputReader(),
    });
    expect(linux.location("/srv/repo").root).toBe(
      "/var/state/drm-copilot/discovery",
    );
  });

  it("defaults to the real process when no seams are injected", () => {
    const provider = createNodeDiscoveryAuthorityProvider();
    expect(typeof provider.context.host).toBe("string");
    expect(provider.io.readText).toBeDefined();
    expect(provider.reader.readBytes).toBeDefined();
  });
});
