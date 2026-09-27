import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock("node:fs", () => ({ existsSync: jest.fn() }));

import {
  defaultWhichGh,
  resolveExecutableOnPath,
} from "../../src/lib/executable-resolver";

/**
 * Tests for the PATH executable resolver (issue #588). Windows semantics are
 * exercised through the `platform`, `pathValue`, and `pathExtValue`
 * parameters with drive-letter-free paths, so the suite behaves the same on a
 * Windows host and on Linux CI. `node:fs` is mocked; no file is touched.
 */

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(candidate: string) => boolean>;
};

/** Build a recording `exists` fake over a set of existing paths. */
function recordingExists(
  existing: readonly string[],
  options: { caseInsensitive?: boolean } = {},
): { exists: (candidate: string) => boolean; calls: string[] } {
  const normalize = (value: string): string =>
    options.caseInsensitive === true ? value.toLowerCase() : value;
  const present = new Set(existing.map(normalize));
  const calls: string[] = [];
  return {
    calls,
    exists: (candidate: string) => {
      calls.push(candidate);
      return present.has(normalize(candidate));
    },
  };
}

describe("resolveExecutableOnPath", () => {
  it("returns the gh.exe candidate for a win32 PATH and PATHEXT", () => {
    // Arrange
    const fake = recordingExists(["\\apps\\github cli\\gh.exe"], {
      caseInsensitive: true,
    });

    // Act
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "\\tools\\bin;\\apps\\GitHub CLI",
      pathExtValue: ".COM;.EXE;.BAT;.CMD",
      platform: "win32",
      exists: fake.exists,
    });

    // Assert: PATHEXT casing is kept; the file is `<dir>\gh.exe` ignoring case.
    expect(result).toBe("\\apps\\GitHub CLI\\gh.EXE");
    expect(result?.toLowerCase()).toBe("\\apps\\github cli\\gh.exe");
  });

  it("matches a lower-case PATHEXT entry against an existing gh.exe", () => {
    const fake = recordingExists(["\\apps\\gh\\gh.exe"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "\\apps\\gh",
      pathExtValue: ".exe",
      platform: "win32",
      exists: fake.exists,
    });
    expect(result).toBe("\\apps\\gh\\gh.exe");
  });

  it("tries a name that already ends in a PATHEXT extension as-is", () => {
    const fake = recordingExists(["\\apps\\gh\\gh.exe"], {
      caseInsensitive: true,
    });
    const result = resolveExecutableOnPath({
      name: "gh.EXE",
      pathValue: "\\apps\\gh",
      pathExtValue: ".exe;.cmd",
      platform: "win32",
      exists: fake.exists,
    });
    expect(result).toBe("\\apps\\gh\\gh.EXE");
    expect(fake.calls[0]).toBe("\\apps\\gh\\gh.EXE");
  });

  it("returns the posix candidate from the first PATH directory that contains the name", () => {
    const fake = recordingExists(["/opt/gh-bin/gh"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "/usr/local/bin:/opt/gh-bin",
      pathExtValue: undefined,
      platform: "linux",
      exists: fake.exists,
    });
    expect(result).toBe("/opt/gh-bin/gh");
  });

  it("ignores PATHEXT on non-win32 platforms", () => {
    const fake = recordingExists(["/opt/gh-bin/gh", "/opt/gh-bin/gh.EXE"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "/opt/gh-bin",
      pathExtValue: ".EXE",
      platform: "linux",
      exists: fake.exists,
    });
    expect(result).toBe("/opt/gh-bin/gh");
    expect(fake.calls).toEqual(["/opt/gh-bin/gh"]);
  });

  it("returns the earlier directory's match when several directories contain the name", () => {
    const fake = recordingExists(["/first/gh", "/second/gh"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "/first:/second",
      pathExtValue: undefined,
      platform: "linux",
      exists: fake.exists,
    });
    expect(result).toBe("/first/gh");
  });

  it("returns undefined when no candidate exists", () => {
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "/opt/gh-bin",
      pathExtValue: undefined,
      platform: "linux",
      exists: () => false,
    });
    expect(result).toBeUndefined();
  });

  it("returns undefined for an undefined PATH", () => {
    const fake = recordingExists(["/opt/gh-bin/gh"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: undefined,
      pathExtValue: undefined,
      platform: "linux",
      exists: fake.exists,
    });
    expect(result).toBeUndefined();
    expect(fake.calls).toEqual([]);
  });

  it("returns undefined for an empty PATH", () => {
    const fake = recordingExists(["/opt/gh-bin/gh"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "",
      pathExtValue: undefined,
      platform: "linux",
      exists: fake.exists,
    });
    expect(result).toBeUndefined();
    expect(fake.calls).toEqual([]);
  });

  it("skips empty PATH entries", () => {
    const fake = recordingExists(["/opt/gh-bin/gh"]);
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "::/opt/gh-bin:",
      pathExtValue: undefined,
      platform: "linux",
      exists: fake.exists,
    });
    expect(fake.calls).toEqual(["/opt/gh-bin/gh"]);
    expect(result).toBe("/opt/gh-bin/gh");
  });

  it("falls back to the default PATHEXT list when PATHEXT is unset", () => {
    const fake = recordingExists(["\\apps\\gh\\gh.bat"], {
      caseInsensitive: true,
    });
    const result = resolveExecutableOnPath({
      name: "gh",
      pathValue: "\\apps\\gh",
      pathExtValue: undefined,
      platform: "win32",
      exists: fake.exists,
    });
    expect(result).toBe("\\apps\\gh\\gh.BAT");
    expect(fake.calls).toEqual([
      "\\apps\\gh\\gh.COM",
      "\\apps\\gh\\gh.EXE",
      "\\apps\\gh\\gh.BAT",
    ]);
  });
});

describe("defaultWhichGh", () => {
  const originalPlatform = Object.getOwnPropertyDescriptor(process, "platform");
  const originalPath = process.env.PATH;
  const originalPathExt = process.env.PATHEXT;

  afterEach(() => {
    if (originalPlatform) {
      Object.defineProperty(process, "platform", originalPlatform);
    }
    if (originalPath === undefined) {
      delete process.env.PATH;
    } else {
      process.env.PATH = originalPath;
    }
    if (originalPathExt === undefined) {
      delete process.env.PATHEXT;
    } else {
      process.env.PATHEXT = originalPathExt;
    }
    jest.resetAllMocks();
  });

  it("resolves gh from process PATH, PATHEXT, and platform through fs.existsSync", () => {
    // Arrange
    Object.defineProperty(process, "platform", { value: "linux" });
    process.env.PATH = "/opt/gh-bin";
    delete process.env.PATHEXT;
    fsMock.existsSync.mockImplementation(
      (candidate: string) => candidate === "/opt/gh-bin/gh",
    );

    // Act
    const result = defaultWhichGh();

    // Assert
    expect(result).toBe("/opt/gh-bin/gh");
    expect(fsMock.existsSync).toHaveBeenCalledWith("/opt/gh-bin/gh");
  });

  it("returns undefined when fs.existsSync reports no candidate", () => {
    Object.defineProperty(process, "platform", { value: "linux" });
    process.env.PATH = "/opt/gh-bin";
    delete process.env.PATHEXT;
    fsMock.existsSync.mockReturnValue(false);

    expect(defaultWhichGh()).toBeUndefined();
  });
});
