import { afterEach, describe, expect, it, jest } from "@jest/globals";

// Mock node:child_process so defaultGhPathLookup's execSync-based gh resolution
// can be exercised without touching the real PATH.
jest.mock("node:child_process", () => ({
  execSync: jest.fn(),
  spawnSync: jest.fn(),
}));

import {
  defaultGhPathLookup,
  FEATURE_LABEL_COLOR,
  FEATURE_LABEL_DESCRIPTION,
  GH_NOT_FOUND_MESSAGE,
  type GhCommandResult,
  type GhCommandRunner,
  RealGhClient,
} from "../../../src/lib/potential-to-issue/gh-client";

const childProcessMock = jest.requireMock("node:child_process") as {
  execSync: jest.Mock;
  spawnSync: jest.Mock;
};

/**
 * Tests for the `gh` client seam ported from the bundled
 * `potential_to_issue.py`. A fake {@link GhCommandRunner} records argument
 * vectors and stdin bodies and returns seeded results. The `gh`-path lookup is
 * injected, so no real `gh` and no real PATH access occur.
 */

/** Recorded invocation captured by the fake runner. */
interface RecordedCall {
  readonly ghPath: string;
  readonly args: string[];
  readonly input: string | undefined;
}

/**
 * Fake {@link GhCommandRunner} that records calls and returns seeded results.
 *
 * @param resultFor Maps an argument vector to a seeded {@link GhCommandResult};
 *   defaults to a zero-exit empty result.
 */
function makeRunner(
  calls: RecordedCall[],
  resultFor: (args: readonly string[]) => GhCommandResult = () => ({
    stdout: "",
    stderr: "",
    code: 0,
  }),
): GhCommandRunner {
  return {
    run(ghPath, args, input): GhCommandResult {
      calls.push({ ghPath, args: [...args], input });
      return resultFor(args);
    },
  };
}

const GH_PATH = "/usr/bin/gh";
const lookup = (): string => GH_PATH;

describe("RealGhClient — construction", () => {
  it("throws the byte-identical message when gh is not found", () => {
    // Arrange / Act / Assert
    expect(
      () =>
        new RealGhClient({ runner: makeRunner([]), ghPathLookup: () => null }),
    ).toThrow(GH_NOT_FOUND_MESSAGE);
  });

  it("constructs when the gh path resolves", () => {
    expect(
      () => new RealGhClient({ runner: makeRunner([]), ghPathLookup: lookup }),
    ).not.toThrow();
  });
});

describe("RealGhClient — isAuthenticated", () => {
  it("returns true when gh auth status exits zero", () => {
    // Arrange
    const calls: RecordedCall[] = [];
    const client = new RealGhClient({
      runner: makeRunner(calls, () => ({ stdout: "ok", stderr: "", code: 0 })),
      ghPathLookup: lookup,
    });

    // Act
    const authed = client.isAuthenticated();

    // Assert
    expect(authed).toBe(true);
    expect(calls[0]?.args).toEqual(["auth", "status"]);
  });

  it("returns false when gh auth status exits non-zero", () => {
    const client = new RealGhClient({
      runner: makeRunner([], () => ({ stdout: "", stderr: "no", code: 1 })),
      ghPathLookup: lookup,
    });
    expect(client.isAuthenticated()).toBe(false);
  });
});

describe("RealGhClient — issueCreate", () => {
  it("builds the exact arg vector and passes the body on stdin", () => {
    // Arrange
    const calls: RecordedCall[] = [];
    const client = new RealGhClient({
      runner: makeRunner(calls, () => ({
        stdout: "Created: https://example.com/issues/1",
        stderr: "",
        code: 0,
      })),
      ghPathLookup: lookup,
    });

    // Act
    const result = client.issueCreate("My Title", "Body text", "feature");

    // Assert: exact arg ordering and stdin body.
    expect(calls[0]?.args).toEqual([
      "issue",
      "create",
      "--title",
      "My Title",
      "--body-file",
      "-",
      "--label",
      "feature",
    ]);
    expect(calls[0]?.input).toBe("Body text");
    expect(result.exitCode).toBe(0);
    expect(result.output).toEqual(["Created: https://example.com/issues/1"]);
  });
});

describe("RealGhClient — ensureLabel", () => {
  it("builds the label create vector with canonical color and description", () => {
    // Arrange
    const calls: RecordedCall[] = [];
    const client = new RealGhClient({
      runner: makeRunner(calls),
      ghPathLookup: lookup,
    });

    // Act
    client.ensureLabel("feature");

    // Assert
    expect(calls[0]?.args).toEqual([
      "label",
      "create",
      "feature",
      "--color",
      FEATURE_LABEL_COLOR,
      "--description",
      FEATURE_LABEL_DESCRIPTION,
    ]);
    expect(FEATURE_LABEL_COLOR).toBe("0e8a16");
    expect(FEATURE_LABEL_DESCRIPTION).toBe("Feature work");
  });
});

describe("RealGhClient — issueView", () => {
  it("builds the issue view vector with the canonical --json field list", () => {
    // Arrange
    const calls: RecordedCall[] = [];
    const client = new RealGhClient({
      runner: makeRunner(calls),
      ghPathLookup: lookup,
    });

    // Act
    client.issueView("123");

    // Assert
    expect(calls[0]?.args).toEqual([
      "issue",
      "view",
      "123",
      "--json",
      "number,title,url,author,updatedAt",
    ]);
  });
});

describe("RealGhClient — output handling", () => {
  it("splits combined stdout+stderr into lines", () => {
    // Arrange: stdout and stderr both contribute lines.
    const client = new RealGhClient({
      runner: makeRunner([], () => ({
        stdout: "line1\nline2\n",
        stderr: "err1\n",
        code: 0,
      })),
      ghPathLookup: lookup,
    });

    // Act
    const result = client.issueView("5");

    // Assert: combined output split, no trailing empty element.
    expect(result.output).toEqual(["line1", "line2", "err1"]);
  });

  it("does not throw on a non-zero exit (allowError semantics)", () => {
    // Arrange: a non-zero exit must surface as a GhResult, not an exception.
    const client = new RealGhClient({
      runner: makeRunner([], () => ({
        stdout: "could not add label: 'feature' not found",
        stderr: "",
        code: 1,
      })),
      ghPathLookup: lookup,
    });

    // Act
    const result = client.issueCreate("t", "b", "feature");

    // Assert: the non-zero result is returned, not thrown.
    expect(result.exitCode).toBe(1);
    expect(result.output).toEqual(["could not add label: 'feature' not found"]);
  });
});

describe("defaultGhPathLookup", () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it("returns the first non-empty resolved path", () => {
    // Arrange: the locator prints the gh path followed by a blank line.
    childProcessMock.execSync.mockReturnValue("/usr/local/bin/gh\n");

    // Act / Assert
    expect(defaultGhPathLookup()).toBe("/usr/local/bin/gh");
  });

  it("returns null when the locator output is empty/whitespace", () => {
    // Arrange: no usable line in the locator output.
    childProcessMock.execSync.mockReturnValue("\n   \n");

    // Act / Assert
    expect(defaultGhPathLookup()).toBeNull();
  });

  it("returns null when the locator throws (gh absent)", () => {
    // Arrange: a non-zero locator exit raises, mirroring an absent gh.
    childProcessMock.execSync.mockImplementation(() => {
      throw new Error("not found");
    });

    // Act / Assert
    expect(defaultGhPathLookup()).toBeNull();
  });
});
