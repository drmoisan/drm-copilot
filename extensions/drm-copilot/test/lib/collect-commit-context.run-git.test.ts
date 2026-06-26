import { describe, expect, it } from "@jest/globals";

import { collectCommitContext } from "../../src/lib/collect-commit-context";
import {
  buildOptions,
  createRunner,
  defaultRoute,
  InMemoryFileSystem,
  OUTPUT_PATH,
} from "./collect-commit-context.test-helpers";

describe("runGit (via collectCommitContext)", () => {
  it("invokes the runner with git args, cwd, and allowError per call", () => {
    // Arrange
    const { runner, calls } = createRunner(defaultRoute);
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert: the first call is the mandatory `git remote -v` with cwd set and
    // allowError false (parity with Python check=True).
    const first = calls[0];
    expect(first?.args).toEqual(["git", "remote", "-v"]);
    expect(first?.options?.cwd).toBe("/workspace");
    expect(first?.options?.allowError).toBe(false);
    // A representative optional call uses allowError true (Python allow_error).
    const upstreamCall = calls.find((call) =>
      call.args.includes("--symbolic-full-name"),
    );
    expect(upstreamCall?.options?.allowError).toBe(true);
  });

  it("propagates a thrown error from a mandatory (allowError false) call", () => {
    // Arrange: the mandatory `remote -v` call fails with a non-zero code.
    const { runner } = createRunner((args) => {
      if (args.includes("remote")) {
        return { stdout: "", code: 1 };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act / Assert
    expect(() => collectCommitContext(buildOptions(runner, fs))).toThrow();
  });

  it("returns the trimmed captured stdout for an allowError call that fails", () => {
    // Arrange: the upstream (allowError true) call fails but returns stdout.
    const { runner } = createRunner((args) => {
      if (args.includes("--symbolic-full-name")) {
        return { stdout: "  origin/main  ", code: 1 };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert: the trimmed captured stdout is rendered under Upstream.
    const body = fs.written.get(OUTPUT_PATH) ?? "";
    expect(body).toContain("===== Upstream =====");
    expect(body).toContain("origin/main");
  });

  it("renders the empty-result placeholder when an allowError call returns empty stdout", () => {
    // Arrange: upstream returns empty stdout on failure.
    const { runner } = createRunner((args) => {
      if (args.includes("--symbolic-full-name")) {
        return { stdout: "", code: 1 };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body = fs.written.get(OUTPUT_PATH) ?? "";
    expect(body).toContain("(no upstream)");
  });
});
