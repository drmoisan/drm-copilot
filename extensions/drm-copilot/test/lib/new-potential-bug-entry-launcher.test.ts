import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock("node:fs", () => ({ existsSync: jest.fn() }));

import { delimiter, join } from "node:path";

import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../src/lib/subprocess-runner";
import {
  defaultCodeLauncher,
  defaultWhichLookup,
  isInsidersSession,
  resolveCodeCli,
} from "../../src/lib/new-potential-bug-entry";

/**
 * Editor-launcher and PATH-probe tests for the `new-potential-bug-entry` port
 * (F6), split from `new-potential-bug-entry.test.ts` to keep both files under
 * the 500-line limit. All seams are injected; no real PATH/subprocess is used.
 */

/**
 * Build a {@link CommandRunner} stub that returns a fixed result and records the
 * argument lists it was invoked with.
 */
function makeRunner(
  result: CommandResult,
  recorded: { args: string[][]; options: (CommandRunOptions | undefined)[] },
): CommandRunner {
  return {
    run(args: readonly string[], options?: CommandRunOptions): CommandResult {
      recorded.args.push([...args]);
      recorded.options.push(options);
      return result;
    },
  };
}

describe("isInsidersSession / resolveCodeCli", () => {
  it("prefers code-insiders when an insiders signal env var is set", () => {
    // Arrange: insiders signal present; record which CLI names are probed.
    const envLookup = (name: string): string | undefined =>
      name === "TERM_PROGRAM_VERSION" ? "1.110.0-insider" : undefined;
    const lookedUp: string[] = [];
    const whichLookup = (name: string): string | undefined => {
      lookedUp.push(name);
      return name === "code-insiders"
        ? "/usr/bin/code-insiders"
        : "/usr/bin/code";
    };

    // Act
    const resolved = resolveCodeCli(whichLookup, envLookup);

    // Assert
    expect(isInsidersSession(envLookup)).toBe(true);
    expect(resolved).toBe("/usr/bin/code-insiders");
    expect(lookedUp[0]).toBe("code-insiders");
  });

  it("probes code first for a non-insiders session", () => {
    // Arrange: no insiders signal; record probe order.
    const envLookup = (): string | undefined => undefined;
    const lookedUp: string[] = [];
    const whichLookup = (name: string): string | undefined => {
      lookedUp.push(name);
      return "/usr/bin/code";
    };

    // Act
    const resolved = resolveCodeCli(whichLookup, envLookup);

    // Assert
    expect(isInsidersSession(envLookup)).toBe(false);
    expect(resolved).toBe("/usr/bin/code");
    expect(lookedUp[0]).toBe("code");
  });
});

describe("defaultCodeLauncher", () => {
  it("returns true and invokes the resolved CLI with --reuse-window and the file path", () => {
    // Arrange
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner({ stdout: "", stderr: "", code: 0 }, recorded);
    const whichLookup = (name: string): string | undefined =>
      name === "code" ? "/usr/bin/code" : undefined;
    const envLookup = (): string | undefined => undefined;

    // Act
    const launched = defaultCodeLauncher(["C:/ws/file.md"], {
      runner,
      whichLookup,
      envLookup,
    });

    // Assert
    expect(launched).toBe(true);
    expect(recorded.args[0]).toEqual([
      "/usr/bin/code",
      "--reuse-window",
      "C:/ws/file.md",
    ]);
  });

  it("returns false when no CLI resolves (probe order ['code', 'code-insiders'])", () => {
    // Arrange: no CLI resolves for a non-insiders session.
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner({ stdout: "", stderr: "", code: 0 }, recorded);
    const lookedUp: string[] = [];
    const whichLookup = (name: string): string | undefined => {
      lookedUp.push(name);
      return undefined;
    };
    const envLookup = (): string | undefined => undefined;

    // Act
    const launched = defaultCodeLauncher(["file.md"], {
      runner,
      whichLookup,
      envLookup,
    });

    // Assert
    expect(launched).toBe(false);
    expect(lookedUp).toEqual(["code", "code-insiders"]);
    expect(recorded.args).toHaveLength(0);
  });
});

describe("defaultWhichLookup", () => {
  it("returns undefined when PATH is empty", () => {
    // Arrange: an empty PATH yields no candidate directories to probe.
    const previousPath = process.env["PATH"];
    process.env["PATH"] = "";
    try {
      // Act
      const resolved = defaultWhichLookup("code");
      // Assert
      expect(resolved).toBeUndefined();
    } finally {
      // Restore prior PATH so the test leaves no global side effect.
      if (previousPath === undefined) {
        delete process.env["PATH"];
      } else {
        process.env["PATH"] = previousPath;
      }
    }
  });
});

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(candidate: string) => boolean>;
};

/** Run `body` with PATH, PATHEXT, and platform overridden; restore all three. */
function withProcessState(
  state: { platform: NodeJS.Platform; path: string; pathExt?: string },
  body: () => void,
): void {
  const previousPath = process.env["PATH"];
  const previousPathExt = process.env["PATHEXT"];
  const platformDescriptor = Object.getOwnPropertyDescriptor(
    process,
    "platform",
  );
  process.env["PATH"] = state.path;
  if (state.pathExt === undefined) {
    delete process.env["PATHEXT"];
  } else {
    process.env["PATHEXT"] = state.pathExt;
  }
  Object.defineProperty(process, "platform", { value: state.platform });
  try {
    body();
  } finally {
    if (platformDescriptor !== undefined) {
      Object.defineProperty(process, "platform", platformDescriptor);
    }
    if (previousPathExt === undefined) {
      delete process.env["PATHEXT"];
    } else {
      process.env["PATHEXT"] = previousPathExt;
    }
    if (previousPath === undefined) {
      delete process.env["PATH"];
    } else {
      process.env["PATH"] = previousPath;
    }
  }
}

describe("launcher-gap: launcher argument and CLI selection", () => {
  afterEach(() => {
    fsMock.existsSync.mockReset();
  });

  it("launcher-gap: converts backslash file paths to forward slashes", () => {
    // Arrange
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner({ stdout: "", stderr: "", code: 0 }, recorded);

    // Act
    const launched = defaultCodeLauncher(["C:\\ws\\file.md"], {
      runner,
      whichLookup: () => "/usr/bin/code",
      envLookup: () => undefined,
    });

    // Assert
    expect(launched).toBe(true);
    expect(recorded.args[0]).toEqual([
      "/usr/bin/code",
      "--reuse-window",
      "C:/ws/file.md",
    ]);
  });

  it("launcher-gap: passes every file after --reuse-window in order", () => {
    // Arrange
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner({ stdout: "", stderr: "", code: 0 }, recorded);

    // Act
    defaultCodeLauncher(["a.md", "b\\c.md", "d.md"], {
      runner,
      whichLookup: () => "/usr/bin/code",
      envLookup: () => undefined,
    });

    // Assert
    expect(recorded.args[0]).toEqual([
      "/usr/bin/code",
      "--reuse-window",
      "a.md",
      "b/c.md",
      "d.md",
    ]);
  });

  it("launcher-gap: defaultCodeLauncher prefers code-insiders in an Insiders session", () => {
    // Arrange
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner({ stdout: "", stderr: "", code: 0 }, recorded);
    const whichLookup = (name: string): string | undefined =>
      name === "code-insiders" ? "/usr/bin/code-insiders" : "/usr/bin/code";
    const envLookup = (name: string): string | undefined =>
      name === "TERM_PROGRAM_VERSION" ? "1.110.0-insider" : undefined;

    // Act
    const launched = defaultCodeLauncher(["file.md"], {
      runner,
      whichLookup,
      envLookup,
    });

    // Assert
    expect(launched).toBe(true);
    expect(recorded.args[0]?.[0]).toBe("/usr/bin/code-insiders");
  });

  it("launcher-gap: resolveCodeCli falls back to code when code-insiders is missing", () => {
    // Arrange: Insiders session where only `code` resolves.
    const lookedUp: string[] = [];
    const whichLookup = (name: string): string | undefined => {
      lookedUp.push(name);
      return name === "code" ? "/usr/bin/code" : undefined;
    };
    const envLookup = (): string | undefined => "1.110.0-insider";

    // Act
    const resolved = resolveCodeCli(whichLookup, envLookup);

    // Assert
    expect(resolved).toBe("/usr/bin/code");
    expect(lookedUp).toEqual(["code-insiders", "code"]);
  });

  it("launcher-gap: resolveCodeCli falls back to code-insiders when code is missing", () => {
    // Arrange: non-Insiders session where only `code-insiders` resolves.
    const lookedUp: string[] = [];
    const whichLookup = (name: string): string | undefined => {
      lookedUp.push(name);
      return name === "code-insiders" ? "/usr/bin/code-insiders" : undefined;
    };
    const envLookup = (): string | undefined => undefined;

    // Act
    const resolved = resolveCodeCli(whichLookup, envLookup);

    // Assert
    expect(resolved).toBe("/usr/bin/code-insiders");
    expect(lookedUp).toEqual(["code", "code-insiders"]);
  });

  it.each([
    "TERM_PROGRAM_VERSION",
    "VSCODE_GIT_ASKPASS_MAIN",
    "TERM_PROGRAM",
    "VSCODE_IPC_HOOK_CLI",
  ])(
    "launcher-gap: isInsidersSession is true for signal variable %s",
    (signalName) => {
      // Arrange: only the named variable carries an insider marker.
      const envLookup = (name: string): string | undefined =>
        name === signalName ? "1.110.0-insider" : undefined;

      // Act
      const result = isInsidersSession(envLookup);

      // Assert
      expect(result).toBe(true);
    },
  );

  it("launcher-gap: isInsidersSession is false when no value contains insider", () => {
    // Arrange
    const envLookup = (): string | undefined => "vscode";

    // Act
    const result = isInsidersSession(envLookup);

    // Assert
    expect(result).toBe(false);
  });

  it("launcher-gap: defaultWhichLookup returns the first existing PATH candidate on linux", () => {
    // Arrange: both directories hold the executable; the first one must win.
    const firstDirectory = join("first", "bin");
    const secondDirectory = join("second", "bin");
    const firstCandidate = join(firstDirectory, "code");
    const secondCandidate = join(secondDirectory, "code");
    fsMock.existsSync.mockImplementation(
      (candidate) =>
        candidate === firstCandidate || candidate === secondCandidate,
    );

    withProcessState(
      {
        platform: "linux",
        path: [firstDirectory, secondDirectory].join(delimiter),
      },
      () => {
        // Act
        const resolved = defaultWhichLookup("code");

        // Assert
        expect(resolved).toBe(firstCandidate);
      },
    );
  });

  it("launcher-gap: defaultWhichLookup applies PATHEXT candidates on win32", () => {
    // Arrange: only the `.CMD` extension candidate exists.
    const directory = join("tools", "bin");
    const cmdCandidate = join(directory, "code.CMD");
    const probed: string[] = [];
    fsMock.existsSync.mockImplementation((candidate) => {
      probed.push(candidate);
      return candidate === cmdCandidate;
    });

    withProcessState(
      { platform: "win32", path: directory, pathExt: ".EXE;.CMD" },
      () => {
        // Act
        const resolved = defaultWhichLookup("code");

        // Assert
        expect(resolved).toBe(cmdCandidate);
        expect(probed).toEqual([join(directory, "code.EXE"), cmdCandidate]);
      },
    );
  });
});
