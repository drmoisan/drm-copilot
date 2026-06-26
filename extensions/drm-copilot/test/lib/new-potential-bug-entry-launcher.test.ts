import { describe, expect, it } from "@jest/globals";

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
