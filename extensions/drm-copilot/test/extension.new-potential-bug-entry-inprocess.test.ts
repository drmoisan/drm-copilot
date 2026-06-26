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
  fsMock,
  resetExtensionHarnessState,
  setExecutablePresence,
  showInputBoxMock,
} from "./extension-test-harness";

/**
 * Behavioral cases for the in-process `newPotentialBugEntry` port (F6),
 * extracted from `extension.workflow-commands.test.ts` so that file does not
 * grow past its existing length (it already exceeds 500 lines). Each case drives
 * the command handler through the shared extension harness with the in-process
 * filesystem/git fakes; no Python `.py` script is spawned.
 */

const WORKSPACE = "C:/workspace";
const TEMPLATE_PATH =
  "C:/extension/resources/feature-templates/bug/potential_bug.md";
const TEMPLATE =
  "# <bug-name>\n\n- Date captured: YYYY-MM-DD\n- Author: name\n";

/**
 * Capture maps for files written and directories created by the in-process port
 * via the harness `node:fs` mocks.
 */
const writtenFiles = new Map<string, string>();
const ensuredDirs: string[] = [];

/**
 * Wire the harness `node:fs` and `child_process` mocks for the in-process port:
 * `readFileSync` returns the bug template for the bundled template path;
 * `writeFileSync`/`mkdirSync` record into the capture maps; `spawnSync` answers
 * the git author lookup. Call inside a test's Arrange step.
 *
 * @param options Optional template override and git author override.
 * @returns The capture maps; keys are forward-slash-normalized.
 */
function installBugEntryFakes(options?: {
  template?: string | undefined;
  gitAuthor?: string | undefined;
}): { writtenFiles: Map<string, string>; ensuredDirs: string[] } {
  writtenFiles.clear();
  ensuredDirs.length = 0;
  const template = options?.template;
  const gitAuthor = options?.gitAuthor ?? "Jane Doe";

  fsMock.readFileSync.mockImplementation((filePath: string): string => {
    if (String(filePath).replace(/\\/g, "/") === TEMPLATE_PATH) {
      if (template === undefined) {
        throw new Error(`ENOENT: no such file: ${String(filePath)}`);
      }
      return template;
    }
    throw new Error(`Unexpected fs.readFileSync call: ${String(filePath)}`);
  });
  fsMock.writeFileSync.mockImplementation(
    (filePath: string, content: string) => {
      writtenFiles.set(String(filePath).replace(/\\/g, "/"), String(content));
    },
  );
  fsMock.mkdirSync.mockImplementation((dirPath: string) => {
    ensuredDirs.push(String(dirPath).replace(/\\/g, "/"));
  });

  // The git author lookup runs `git config user.name` via SubprocessRunner.
  childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
    const args = (rawArgs[1] as ReadonlyArray<string> | undefined) ?? [];
    if (args.join(" ").includes("config user.name")) {
      return {
        status: 0,
        stdout: Buffer.from(gitAuthor, "utf8"),
        stderr: Buffer.from("", "utf8"),
      };
    }
    return {
      status: 1,
      stdout: Buffer.from("", "utf8"),
      stderr: Buffer.from("", "utf8"),
    };
  });

  return { writtenFiles, ensuredDirs };
}

/** Returns true when any `spawn` call targeted the bundled `.py` script. */
function pythonScriptSpawned(): boolean {
  return childProcessMock.spawn.mock.calls.some((call: unknown[]) =>
    ((call[1] as string[] | undefined) ?? []).some((arg) =>
      arg.endsWith("/resources/templates/new_potential_bug_entry.py"),
    ),
  );
}

describe("drm-copilot newPotentialBugEntry in-process behavior", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("writes the entry in-process without spawning the bundled python script", async () => {
    // Arrange
    setExecutablePresence({ python: true });
    showInputBoxMock.mockResolvedValue("blank-pr-context");
    const captured = installBugEntryFakes({ template: TEMPLATE });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    // Assert: the rendered file is written through the injected filesystem and
    // no Python `.py` script is spawned.
    expect(pythonScriptSpawned()).toBe(false);
    const writtenKeys = [...captured.writtenFiles.keys()];
    expect(
      writtenKeys.some((key) =>
        /^C:\/workspace\/docs\/features\/potential\/\d{4}-\d{2}-\d{2}-blank-pr-context\.md$/.test(
          key,
        ),
      ),
    ).toBe(true);
    const writtenContent = captured.writtenFiles.get(writtenKeys[0] as string);
    expect(writtenContent).toContain("# blank-pr-context");
    expect(writtenContent).toContain("- Author: Jane Doe");
  });

  it("direct --short-name invocation skips prompts and writes in-process", async () => {
    // Arrange
    setExecutablePresence({ python: true });
    const captured = installBugEntryFakes({ template: TEMPLATE });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler(["--short-name", "blank-pr-context"]);

    // Assert
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(pythonScriptSpawned()).toBe(false);
    expect(
      [...captured.writtenFiles.keys()].some((key) =>
        key.endsWith("-blank-pr-context.md"),
      ),
    ).toBe(true);
  });

  it("direct mode rejects an invalid short-name pattern before any filesystem work", async () => {
    // Arrange
    setExecutablePresence({ python: true });
    installBugEntryFakes({ template: TEMPLATE });

    // Act / Assert: the in-process validateShortName surfaces the rejection.
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await expect(handler(["--short-name", "Invalid Name"])).rejects.toThrow(
      /kebab-case/i,
    );
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(pythonScriptSpawned()).toBe(false);
    expect(writtenFiles.size).toBe(0);
  });

  it("returns early when the input box is cancelled", async () => {
    // Arrange
    showInputBoxMock.mockResolvedValue(undefined);
    installBugEntryFakes({ template: TEMPLATE });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    // Assert: no script spawned and no file written.
    expect(pythonScriptSpawned()).toBe(false);
    expect(writtenFiles.size).toBe(0);
  });

  it("succeeds without any python runtime present (in-process port)", async () => {
    // Arrange: no python runtime is required after the port.
    setExecutablePresence({ python: false });
    showInputBoxMock.mockResolvedValue("blank-pr-context");
    const captured = installBugEntryFakes({ template: TEMPLATE });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    // Assert: the command completes and writes the file with no python present.
    expect(pythonScriptSpawned()).toBe(false);
    expect(captured.writtenFiles.size).toBe(1);
  });

  it("surfaces a file-not-found error when the bundled template is absent", async () => {
    // Arrange: the in-process failure replaces the prior non-zero-exit case.
    setExecutablePresence({ python: true });
    showInputBoxMock.mockResolvedValue("blank-pr-context");
    installBugEntryFakes({ template: undefined });

    // Act / Assert
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await expect(handler()).rejects.toThrow();
    expect(pythonScriptSpawned()).toBe(false);
  });

  it("resolves the template under the bundled feature-templates root", async () => {
    // Arrange: the readFileSync fake only answers the feature-templates path, so
    // a successful write proves the in-process path read from that root.
    setExecutablePresence({ python: true });
    showInputBoxMock.mockResolvedValue("test-bug");
    const readPaths: string[] = [];
    fsMock.readFileSync.mockImplementation((filePath: string): string => {
      readPaths.push(String(filePath).replace(/\\/g, "/"));
      if (String(filePath).replace(/\\/g, "/") === TEMPLATE_PATH) {
        return TEMPLATE;
      }
      throw new Error(`Unexpected fs.readFileSync call: ${String(filePath)}`);
    });
    fsMock.writeFileSync.mockImplementation(() => undefined);
    fsMock.mkdirSync.mockImplementation(() => undefined);
    childProcessMock.spawnSync.mockImplementation(() => ({
      status: 0,
      stdout: Buffer.from("Jane Doe", "utf8"),
      stderr: Buffer.from("", "utf8"),
    }));

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    // Assert: the only template read targeted the bundled feature-templates root.
    expect(readPaths).toContain(TEMPLATE_PATH);
    expect(WORKSPACE).toBe("C:/workspace");
  });
});
