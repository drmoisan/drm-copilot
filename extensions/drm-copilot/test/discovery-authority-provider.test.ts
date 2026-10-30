/**
 * Prove the Node authority provider maps host values onto the trusted seams
 * and exposes no identity of its own.
 *
 * Platform, home directory, state-directory environment, clock and nonce are
 * injected so the mapping is checked without reading the real process. The
 * provider carries no host, session, parent or agent field: those values come
 * only from the one-use records the native hooks write.
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

/** An environment carrying identity-shaped variables the provider must ignore. */
const ENV = {
  [DISCOVERY_ENVIRONMENT_KEYS.localAppData]: "C:/Users/Example/AppData/Local",
  UNRELATED_HOST: "codex",
  UNRELATED_SESSION_ID: "session-alpha",
  UNRELATED_AGENT_ID: "agent-alpha",
  UNRELATED_AGENT_ROLE: "legacy-parity-analyst",
};

describe("createNodeDiscoveryAuthorityProvider", () => {
  it("maps the injected seams and reads no identity from the environment", () => {
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
    expect(Object.keys(provider).sort()).toEqual([
      "activation",
      "io",
      "location",
      "nonce",
      "now",
      "reader",
      "writer",
    ]);
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

  it("keeps only the two state-directory keys in its environment contract", () => {
    expect(DISCOVERY_ENVIRONMENT_KEYS).toEqual({
      localAppData: "LOCALAPPDATA",
      xdgStateHome: "XDG_STATE_HOME",
    });
    expect(Object.keys(DISCOVERY_ENVIRONMENT_KEYS)).toHaveLength(2);
  });

  it("derives the writer defaults and the XDG state root when the environment is bare", () => {
    const provider = createNodeDiscoveryAuthorityProvider({
      env: {},
      platform: "linux",
      homedir: "/home/example",
      io: new MemoryStoreIO(),
      reader: new MemoryInputReader(),
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
    expect(provider.io.readText).toBeDefined();
    expect(provider.reader.readBytes).toBeDefined();
    expect(provider.location(process.cwd()).root.length).toBeGreaterThan(0);
  });
});
