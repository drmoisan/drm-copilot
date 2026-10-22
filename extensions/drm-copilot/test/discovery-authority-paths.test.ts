/**
 * Replay the shared authority-location vectors and prove containment rules.
 *
 * `tests/fixtures/discovery_authority/authority-vectors.json` is generated from
 * the Python runtime (`RegistryLocation.for_host`); every location row must
 * resolve to the same canonical workspace, digest and directory here.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import {
  activationRecordPath,
  assertProtectedDestination,
  type AuthorityLocation,
  type AuthorityPlatform,
  DiscoveryAuthorityPathError,
  invocationDirectory,
  isInsideAuthority,
  isInsideWorkspace,
  mutationLockPath,
  partitionName,
  resolveAuthorityLocation,
  sessionDirectory,
  sha256Hex,
  type TrustedHostEnvironment,
} from "../src/discovery-authority-paths";

interface LocationRow {
  readonly platform: AuthorityPlatform;
  readonly workspace_root: string;
  readonly user_home: string;
  readonly local_app_data: string | null;
  readonly xdg_state_home: string | null;
  readonly workspace: string;
  readonly workspace_sha256: string;
  readonly directory: string;
}

interface AuthorityVectors {
  readonly record_file: string;
  readonly lock_file: string;
  readonly locations: LocationRow[];
  readonly invalid_locations: Omit<
    LocationRow,
    "workspace" | "workspace_sha256" | "directory"
  >[];
}

const FIXTURE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "discovery_authority",
  "authority-vectors.json",
);
const vectors = JSON.parse(
  fs.readFileSync(FIXTURE_PATH, "utf8"),
) as AuthorityVectors;

function environment(
  row: Pick<
    LocationRow,
    "platform" | "user_home" | "local_app_data" | "xdg_state_home"
  >,
): TrustedHostEnvironment {
  return {
    platform: row.platform,
    userHome: row.user_home,
    localAppData: row.local_app_data,
    xdgStateHome: row.xdg_state_home,
  };
}

const WINDOWS: TrustedHostEnvironment = {
  platform: "windows",
  userHome: "C:/Users/Example",
  localAppData: "C:/Users/Example/AppData/Local",
};
const LINUX: TrustedHostEnvironment = {
  platform: "linux",
  userHome: "/home/example",
};

function windowsLocation(): AuthorityLocation {
  return resolveAuthorityLocation("C:/Users/Example/Repos/Workspace", WINDOWS);
}

describe("resolveAuthorityLocation fixture parity", () => {
  it("has location rows for every platform", () => {
    const platforms = new Set(vectors.locations.map((row) => row.platform));
    expect([...platforms].sort()).toEqual(["linux", "macos", "windows"]);
    expect(vectors.record_file).toBe("activation.json");
    expect(vectors.lock_file).toBe("mutation.lock");
  });

  it.each(
    vectors.locations.map((row) => [row.platform, row.workspace_root, row]),
  )("resolves %s %s to the Python location", (_platform, _root, row) => {
    const location = resolveAuthorityLocation(
      row.workspace_root,
      environment(row),
    );
    expect(location.workspace).toBe(row.workspace);
    expect(location.workspaceSha256).toBe(row.workspace_sha256);
    expect(location.directory).toBe(row.directory);
    expect(row.directory.startsWith(`${location.root}/workspaces/`)).toBe(true);
  });

  it.each(vectors.invalid_locations.map((row) => [JSON.stringify(row), row]))(
    "rejects %s before any I/O",
    (_label, row) => {
      expect(() =>
        resolveAuthorityLocation(row.workspace_root, environment(row)),
      ).toThrow(DiscoveryAuthorityPathError);
    },
  );
});

describe("resolveAuthorityLocation canonical identity", () => {
  it("hashes the lowercase native Windows spelling", () => {
    const location = windowsLocation();
    expect(location.workspaceSha256).toBe(
      sha256Hex("c:\\users\\example\\repos\\workspace"),
    );
    expect(location.root).toBe(
      "C:/Users/Example/AppData/Local/drm-copilot/discovery",
    );
  });

  it("treats Windows case and separator aliases as one workspace", () => {
    const aliases = [
      "C:/Users/Example/Repos/Workspace",
      "c:\\USERS\\example\\repos\\workspace\\",
      "C:/Users//Example/./Repos/Workspace/",
    ];
    const digests = new Set(
      aliases.map(
        (alias) => resolveAuthorityLocation(alias, WINDOWS).workspaceSha256,
      ),
    );
    expect(digests.size).toBe(1);
  });

  it("supports UNC workspace roots on Windows", () => {
    const location = resolveAuthorityLocation(
      "\\\\server\\share\\Repo",
      WINDOWS,
    );
    expect(location.workspace).toBe("//server/share/Repo");
    expect(location.workspaceSha256).toBe(sha256Hex("\\\\server\\share\\repo"));
  });

  it("preserves POSIX case and collapses repeated separators", () => {
    const lower = resolveAuthorityLocation("/home/example/repo", LINUX);
    const upper = resolveAuthorityLocation("/home/Example/Repo", LINUX);
    const dotted = resolveAuthorityLocation("/home//example/./repo/", LINUX);
    expect(lower.workspaceSha256).not.toBe(upper.workspaceSha256);
    expect(dotted.workspaceSha256).toBe(lower.workspaceSha256);
    expect(dotted.workspace).toBe("/home/example/repo");
    expect(lower.directory).toBe(
      `/home/example/.local/state/drm-copilot/discovery/workspaces/${lower.workspaceSha256}`,
    );
  });

  it("keeps a double-slash POSIX root distinct from a single root", () => {
    const double = resolveAuthorityLocation("//net/repo", LINUX);
    const single = resolveAuthorityLocation("/net/repo", LINUX);
    expect(double.workspace).toBe("//net/repo");
    expect(double.workspaceSha256).not.toBe(single.workspaceSha256);
  });

  it("uses macOS Application Support and honours XDG_STATE_HOME on Linux", () => {
    const mac = resolveAuthorityLocation("/Users/example/repo", {
      platform: "macos",
      userHome: "/Users/example",
    });
    const linux = resolveAuthorityLocation("/home/example/repo", {
      ...LINUX,
      xdgStateHome: "/var/state",
    });
    expect(mac.root).toBe(
      "/Users/example/Library/Application Support/drm-copilot/discovery",
    );
    expect(linux.root).toBe("/var/state/drm-copilot/discovery");
  });

  it.each([
    ["relative workspace", "repo", LINUX, "AUTHORITY_PATH_NOT_CANONICAL"],
    [
      "parent reference",
      "/home/../repo",
      LINUX,
      "AUTHORITY_PATH_NOT_CANONICAL",
    ],
    [
      "relative home",
      "/repo",
      { ...LINUX, userHome: "home" },
      "AUTHORITY_PATH_NOT_CANONICAL",
    ],
    [
      "drive-relative Windows",
      "C:repo",
      WINDOWS,
      "AUTHORITY_PATH_NOT_CANONICAL",
    ],
    [
      "missing LocalAppData",
      "C:/Repo",
      { ...WINDOWS, localAppData: null },
      "AUTHORITY_STATE_ROOT_MISSING",
    ],
    [
      "state inside workspace",
      "/home/example",
      LINUX,
      "AUTHORITY_INSIDE_WORKSPACE",
    ],
    [
      "Windows state inside workspace by case",
      "c:/users/EXAMPLE/appdata",
      WINDOWS,
      "AUTHORITY_INSIDE_WORKSPACE",
    ],
    [
      "XDG inside workspace",
      "/repo",
      { ...LINUX, xdgStateHome: "/repo/state" },
      "AUTHORITY_INSIDE_WORKSPACE",
    ],
    [
      "unsupported platform",
      "/repo",
      { platform: "freebsd" as AuthorityPlatform, userHome: "/home/example" },
      "AUTHORITY_PLATFORM_UNSUPPORTED",
    ],
  ])("rejects %s", (_label, root, env, code) => {
    let caught: unknown;
    try {
      resolveAuthorityLocation(root, env);
    } catch (error) {
      caught = error;
    }
    expect(caught).toBeInstanceOf(DiscoveryAuthorityPathError);
    expect((caught as DiscoveryAuthorityPathError).code).toBe(code);
  });
});

describe("session and invocation partitions", () => {
  it("derives deterministic digest partitions under the workspace directory", () => {
    const location = windowsLocation();
    const session = sessionDirectory(location, "sess:2026-10-22:abc");
    const invocation = invocationDirectory(
      location,
      "sess:2026-10-22:abc",
      "inv.001",
    );
    expect(session).toBe(
      `${location.directory}/sessions/${sha256Hex("sess:2026-10-22:abc")}`,
    );
    expect(invocation).toBe(`${session}/invocations/${sha256Hex("inv.001")}`);
    expect(partitionName("A")).toBe(partitionName("A"));
    expect(partitionName("A")).not.toBe(partitionName("a"));
  });

  it.each([
    "",
    "-leading",
    "has space",
    "slash/inside",
    "dot..dot/",
    "x".repeat(257),
  ])("rejects partition identifier %j", (identifier) => {
    let caught: unknown;
    try {
      partitionName(identifier);
    } catch (error) {
      caught = error;
    }
    expect((caught as DiscoveryAuthorityPathError).code).toBe(
      "AUTHORITY_PARTITION_INVALID",
    );
  });

  it("names the fixed record and lock files", () => {
    const location = windowsLocation();
    expect(activationRecordPath(location)).toBe(
      `${location.directory}/activation.json`,
    );
    expect(mutationLockPath(location)).toBe(
      `${location.directory}/mutation.lock`,
    );
  });
});

describe("external containment", () => {
  it("classifies workspace, authority and foreign paths", () => {
    const location = windowsLocation();
    expect(
      isInsideWorkspace(
        location,
        "c:\\users\\example\\repos\\WORKSPACE\\.drm\\x",
      ),
    ).toBe(true);
    expect(
      isInsideWorkspace(location, "C:/Users/Example/Repos/Workspace2"),
    ).toBe(false);
    expect(
      isInsideAuthority(location, `${location.directory}/activation.json`),
    ).toBe(true);
    expect(isInsideAuthority(location, location.root)).toBe(false);
    expect(
      isInsideWorkspace(location, "D:/Users/Example/Repos/Workspace"),
    ).toBe(false);
  });

  it("accepts a destination inside the protected directory", () => {
    const location = windowsLocation();
    const destination = assertProtectedDestination(
      location,
      `${location.directory}\\sessions\\x\\receipt.json`,
    );
    expect(destination).toBe(`${location.directory}/sessions/x/receipt.json`);
  });

  it.each([
    [
      "workspace mirror",
      "C:/Users/Example/Repos/Workspace/.drm-copilot/activation.json",
    ],
    ["sibling workspace", "C:/Users/Example/Repos/Other/activation.json"],
    [
      "authority root of another workspace",
      "C:/Users/Example/AppData/Local/drm-copilot/discovery/workspaces/0000/activation.json",
    ],
    ["relative path", "activation.json"],
  ])("rejects %s as a destination", (_label, destination) => {
    const location = windowsLocation();
    let caught: unknown;
    try {
      assertProtectedDestination(location, destination);
    } catch (error) {
      caught = error;
    }
    expect(caught).toBeInstanceOf(DiscoveryAuthorityPathError);
    expect((caught as DiscoveryAuthorityPathError).code).toMatch(
      /AUTHORITY_DESTINATION_REJECTED|AUTHORITY_PATH_NOT_CANONICAL/u,
    );
  });

  it("uses exact case for POSIX containment", () => {
    const location = resolveAuthorityLocation("/home/example/repo", LINUX);
    expect(isInsideWorkspace(location, "/home/example/repo/sub")).toBe(true);
    expect(isInsideWorkspace(location, "/home/example/Repo/sub")).toBe(false);
    expect(isInsideWorkspace(location, "/home/example/repository")).toBe(false);
  });
});
