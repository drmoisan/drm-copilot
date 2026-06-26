import { afterEach, describe, expect, it, jest } from "@jest/globals";
import { spawnSync } from "node:child_process";

import { SubprocessRunner } from "../../src/lib/subprocess-runner";

jest.mock("node:child_process", () => ({ spawnSync: jest.fn() }));

// Typed reference to the mocked spawnSync for arranging return values.
const spawnSyncMock = spawnSync as jest.MockedFunction<typeof spawnSync>;

/**
 * Build a minimal spawnSync return object for tests. Only the fields consumed
 * by SubprocessRunner are populated; the cast satisfies the broad return type.
 */
function spawnResult(
  status: number | null,
  stdout: Buffer,
  stderr: Buffer,
): ReturnType<typeof spawnSync> {
  return {
    status,
    stdout,
    stderr,
    pid: 1,
    output: [null, stdout, stderr],
    signal: null,
  } as ReturnType<typeof spawnSync>;
}

describe("SubprocessRunner", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  it("returns a result with trailing newline stripped on success", () => {
    // Arrange
    spawnSyncMock.mockReturnValue(
      spawnResult(0, Buffer.from("out\n"), Buffer.from("")),
    );
    const runner = new SubprocessRunner();

    // Act
    const result = runner.run(["git", "status"]);

    // Assert
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("out");
    expect(result.stderr).toBe("");
  });

  it("returns the result without throwing when allowError is true", () => {
    // Arrange
    spawnSyncMock.mockReturnValue(
      spawnResult(2, Buffer.from("partial"), Buffer.from("warned")),
    );
    const runner = new SubprocessRunner();

    // Act
    const result = runner.run(["git", "diff"], { allowError: true });

    // Assert
    expect(result.code).toBe(2);
    expect(result.stdout).toBe("partial");
    expect(result.stderr).toBe("warned");
  });

  it("throws with the git.py message format on non-zero exit by default", () => {
    // Arrange
    spawnSyncMock.mockReturnValue(
      spawnResult(128, Buffer.from("oops"), Buffer.from("fatal: bad")),
    );
    const runner = new SubprocessRunner();

    // Act / Assert: message is `${args.join(" ")} failed (${code}): ${joined}`.
    expect(() => runner.run(["git", "rev-parse", "HEAD"])).toThrow(
      "git rev-parse HEAD failed (128): oops\nfatal: bad",
    );
  });

  it("captures and decodes stderr with trailing newline stripped", () => {
    // Arrange
    spawnSyncMock.mockReturnValue(
      spawnResult(0, Buffer.from(""), Buffer.from("warning text\n")),
    );
    const runner = new SubprocessRunner();

    // Act
    const result = runner.run(["git", "log"]);

    // Assert
    expect(result.stderr).toBe("warning text");
  });

  it("replaces undecodable UTF-8 bytes rather than throwing", () => {
    // Arrange: 0xff 0xfe is an invalid UTF-8 sequence.
    spawnSyncMock.mockReturnValue(
      spawnResult(0, Buffer.from([0xff, 0xfe]), Buffer.from("")),
    );
    const runner = new SubprocessRunner();

    // Act
    const result = runner.run(["git", "show"]);

    // Assert: U+FFFD replacement characters appear in the decoded output.
    expect(result.stdout).toContain("�");
    expect(result.code).toBe(0);
  });

  it("treats a null status as a non-zero failure", () => {
    // Arrange
    spawnSyncMock.mockReturnValue(
      spawnResult(null, Buffer.from(""), Buffer.from("killed")),
    );
    const runner = new SubprocessRunner();

    // Act / Assert: null status maps to code 1 and triggers the throw path.
    expect(() => runner.run(["git", "fetch"])).toThrow(
      "git fetch failed (1): killed",
    );
  });

  it("passes cwd through to spawnSync when provided", () => {
    // Arrange
    spawnSyncMock.mockReturnValue(
      spawnResult(0, Buffer.from("ok"), Buffer.from("")),
    );
    const runner = new SubprocessRunner();

    // Act
    runner.run(["git", "status"], { cwd: "/work" });

    // Assert
    expect(spawnSyncMock).toHaveBeenCalledWith(
      "git",
      ["status"],
      expect.objectContaining({ cwd: "/work", shell: false }),
    );
  });
});
