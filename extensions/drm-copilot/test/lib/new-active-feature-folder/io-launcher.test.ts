import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock("node:fs", () => ({ existsSync: jest.fn() }));

import { delimiter, join } from "node:path";

import {
  defaultCodeLauncher,
  defaultEnvLookup,
  defaultWhichLookup,
  isInsidersSession,
  resolveCodeCli,
} from "../../../src/lib/new-active-feature-folder/io-launcher";
import { FakeCommandRunner } from "./fakes";

/**
 * Default-helper and launcher-seam tests for `io-launcher.ts`, kept beside
 * `io.test.ts` (which sits near the 500-line limit). `node:fs` is mocked and
 * every other seam is injected; no real PATH probing or subprocess is used.
 */

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(candidate: string) => boolean>;
};

const SIGNAL_VARIABLE = "LAUNCHER_GAP_TEST_SIGNAL";

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

/** Run `body` with `SIGNAL_VARIABLE` set (or unset when `value` is undefined). */
function withSignalVariable(value: string | undefined, body: () => void): void {
  const previous = process.env[SIGNAL_VARIABLE];
  if (value === undefined) {
    delete process.env[SIGNAL_VARIABLE];
  } else {
    process.env[SIGNAL_VARIABLE] = value;
  }
  try {
    body();
  } finally {
    if (previous === undefined) {
      delete process.env[SIGNAL_VARIABLE];
    } else {
      process.env[SIGNAL_VARIABLE] = previous;
    }
  }
}

describe("launcher-gap: defaultWhichLookup", () => {
  afterEach(() => {
    fsMock.existsSync.mockReset();
  });

  it("launcher-gap: defaultWhichLookup returns undefined for an empty PATH", () => {
    // Arrange: an empty PATH yields no directories to probe.
    fsMock.existsSync.mockImplementation(() => true);

    withProcessState({ platform: "linux", path: "" }, () => {
      // Act
      const resolved = defaultWhichLookup("code");

      // Assert
      expect(resolved).toBeUndefined();
      expect(fsMock.existsSync).not.toHaveBeenCalled();
    });
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

describe("launcher-gap: defaultEnvLookup", () => {
  it("launcher-gap: defaultEnvLookup returns the value when set", () => {
    withSignalVariable("present", () => {
      // Act
      const value = defaultEnvLookup(SIGNAL_VARIABLE);

      // Assert
      expect(value).toBe("present");
    });
  });

  it("launcher-gap: defaultEnvLookup returns undefined when blank", () => {
    withSignalVariable("   ", () => {
      // Act
      const value = defaultEnvLookup(SIGNAL_VARIABLE);

      // Assert
      expect(value).toBeUndefined();
    });
  });

  it("launcher-gap: defaultEnvLookup returns undefined when unset", () => {
    withSignalVariable(undefined, () => {
      // Act
      const value = defaultEnvLookup(SIGNAL_VARIABLE);

      // Assert
      expect(value).toBeUndefined();
    });
  });
});

describe("launcher-gap: Insiders detection and CLI resolution", () => {
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
});

describe("launcher-gap: defaultCodeLauncher", () => {
  it("launcher-gap: defaultCodeLauncher with default deps returns false when PATH is empty", () => {
    // Arrange: an empty PATH leaves the default whichLookup nothing to resolve,
    // so the default SubprocessRunner is never invoked.
    const previousPath = process.env["PATH"];
    process.env["PATH"] = "";
    try {
      // Act
      const launched = defaultCodeLauncher(["file.md"]);

      // Assert
      expect(launched).toBe(false);
    } finally {
      if (previousPath === undefined) {
        delete process.env["PATH"];
      } else {
        process.env["PATH"] = previousPath;
      }
    }
  });

  it("launcher-gap: defaultCodeLauncher passes every file after --reuse-window in order", () => {
    // Arrange
    const runner = new FakeCommandRunner();

    // Act
    const launched = defaultCodeLauncher(["a.md", "b\\c.md", "d.md"], {
      runner,
      whichLookup: () => "/usr/bin/code",
      envLookup: () => undefined,
    });

    // Assert
    expect(launched).toBe(true);
    expect(runner.calls).toEqual([
      ["/usr/bin/code", "--reuse-window", "a.md", "b/c.md", "d.md"],
    ]);
  });
});
