import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  activateAndGetHandler,
  childProcessMock,
  resetExtensionHarnessState,
  setExecutablePresence,
} from "./extension-test-harness";
import {
  installInProcessFsCaptures,
  setCollectCommitContextGitOutput,
} from "./collect-commit-context-test-support";

/**
 * Behavioral cases for the in-process `collectCommitContext` port (F4),
 * extracted from `extension.workflow-commands.test.ts` so that file does not
 * grow past its existing length. Each case drives the command handler through
 * the shared extension harness with the in-process spawnSync/filesystem fakes.
 */
describe("drm-copilot collectCommitContext in-process behavior", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("does not require a python runtime (in-process port)", async () => {
    // Arrange: no python runtime present; the in-process TS port must still run.
    setExecutablePresence({ python: false });
    setCollectCommitContextGitOutput();
    installInProcessFsCaptures();

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    // Assert: no Python `.py` script is spawned; the in-process path uses
    // spawnSync for git instead.
    const spawnedPyScripts = childProcessMock.spawn.mock.calls.filter(
      (call: unknown[]) =>
        ((call[1] as string[] | undefined) ?? []).some((arg) =>
          arg.endsWith("/resources/templates/collect_commit_context.py"),
        ),
    );
    expect(spawnedPyScripts).toHaveLength(0);
    expect(childProcessMock.spawnSync).toHaveBeenCalled();
  });

  it("writes the artifact in-process without spawning the bundled script", async () => {
    // Arrange
    setExecutablePresence({ python: true });
    setCollectCommitContextGitOutput();
    const { writtenFiles } = installInProcessFsCaptures();

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    // Assert: the artifact is written to the workspace path via the injected
    // filesystem, not produced by a spawned `.py` script.
    expect(writtenFiles.has("C:/workspace/artifacts/commit_context.txt")).toBe(
      true,
    );
    const pySpawned = childProcessMock.spawn.mock.calls.some(
      (call: unknown[]) =>
        ((call[1] as string[] | undefined) ?? []).some((arg) =>
          arg.endsWith("/resources/templates/collect_commit_context.py"),
        ),
    );
    expect(pySpawned).toBe(false);
  });

  it("runs git with the workspace cwd", async () => {
    // Arrange
    setExecutablePresence({ python: true });
    setCollectCommitContextGitOutput();
    installInProcessFsCaptures();

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    // Assert: every git invocation runs with cwd set to the workspace root.
    const gitCalls = childProcessMock.spawnSync.mock.calls.filter(
      (call: unknown[]) => call[0] === "git",
    );
    expect(gitCalls.length).toBeGreaterThan(0);
    for (const call of gitCalls) {
      const options = call[2] as { cwd?: string; shell?: boolean };
      expect(options.cwd).toBe("C:/workspace");
      expect(options.shell).toBe(false);
    }
  });

  it("throws when a mandatory git call exits non-zero", async () => {
    // Arrange: the mandatory `remote -v` call (allowError false) fails.
    setExecutablePresence({ python: true });
    setCollectCommitContextGitOutput((joined) =>
      joined.includes("remote")
        ? { status: 1, stdout: "", stderr: "fatal: not a git repository" }
        : null,
    );
    installInProcessFsCaptures();

    // Act / Assert
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow();
  });

  it("surfaces git stderr details in the thrown error", async () => {
    // Arrange: the mandatory `remote -v` call fails with stderr detail.
    setExecutablePresence({ python: true });
    setCollectCommitContextGitOutput((joined) =>
      joined.includes("remote")
        ? { status: 1, stdout: "", stderr: "fatal: not a git repository" }
        : null,
    );
    installInProcessFsCaptures();

    // Act / Assert: the SubprocessRunner error message includes the stderr.
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("fatal: not a git repository");
  });
});
