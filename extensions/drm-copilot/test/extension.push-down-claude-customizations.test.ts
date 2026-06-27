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
  fsMock,
  resetExtensionHarnessState,
  showQuickPickMock,
} from "./extension-test-harness";

interface PackQuickPickItem {
  readonly label: string;
  readonly pack: string;
  readonly picked: boolean;
}

const EXT = "C:/extension";
const WS = "C:/workspace";
const BUNDLE = `${EXT}/resources/claude-customizations`;

/**
 * Seed the harness `node:fs` mock to back the in-process push-down filesystem
 * with a minimal bundled `.claude` tree, a legacy C# variant subtree, and pack
 * manifests, plus an existing destination workspace directory.
 *
 * Records destination writes so the test can assert which files were published.
 *
 * @returns A map of written destination paths to their content.
 */
function seedInProcessFileSystem(): Map<string, string> {
  const files = new Map<string, string>([
    [`${BUNDLE}/.claude/rules/typescript.md`, "# TS\n"],
    [`${BUNDLE}/.claude/rules/csharp.md`, "# Modern C#\n"],
    [`${BUNDLE}/.claude/agents/orchestrator.md`, "# Orchestrator\n"],
    [
      `${BUNDLE}/.claude-variants/csharp-legacy/rules/csharp.md`,
      "# Legacy C#\n",
    ],
    [
      `${BUNDLE}/pack-manifests/core.json`,
      JSON.stringify({
        name: "core",
        label: "Core",
        paths: [".claude/agents/orchestrator.md"],
      }),
    ],
    [
      `${BUNDLE}/pack-manifests/typescript.json`,
      JSON.stringify({
        name: "typescript",
        label: "TypeScript",
        paths: [".claude/rules/typescript.md"],
      }),
    ],
    [
      `${BUNDLE}/pack-manifests/csharp-legacy.json`,
      JSON.stringify({
        name: "csharp-legacy",
        label: "C# (legacy)",
        paths: [".claude/rules/csharp.md"],
      }),
    ],
  ]);
  const dirs = new Set<string>([WS]);
  // Register every ancestor directory of each seeded file as a directory.
  for (const filePath of files.keys()) {
    const segments = filePath.split("/");
    for (let index = 1; index < segments.length; index += 1) {
      dirs.add(segments.slice(0, index).join("/"));
    }
  }

  const writes = new Map<string, string>();

  fsMock.statSync.mockImplementation((rawPath: string) => {
    const path = rawPath.replace(/\\/g, "/").replace(/\/+$/, "");
    if (files.has(path) || writes.has(path)) {
      return { isFile: () => true, isDirectory: () => false };
    }
    if (dirs.has(path)) {
      return { isFile: () => false, isDirectory: () => true };
    }
    throw new Error(`ENOENT: ${path}`);
  });

  fsMock.readdirSync.mockImplementation((rawDir: string) => {
    const dir = rawDir.replace(/\\/g, "/").replace(/\/+$/, "");
    const children = new Map<string, boolean>();
    // Collect immediate children (files and subdirectories) of the directory.
    for (const filePath of [...files.keys(), ...writes.keys()]) {
      if (filePath.startsWith(`${dir}/`)) {
        const remainder = filePath.slice(dir.length + 1);
        const slash = remainder.indexOf("/");
        if (slash === -1) {
          children.set(remainder, false);
        } else {
          children.set(remainder.slice(0, slash), true);
        }
      }
    }
    return [...children.entries()].map(([name, isDir]) => ({
      name,
      isDirectory: () => isDir,
      isFile: () => !isDir,
    }));
  });

  fsMock.readFileSync.mockImplementation((rawPath: string) => {
    const path = rawPath.replace(/\\/g, "/").replace(/\/+$/, "");
    const content = writes.get(path) ?? files.get(path);
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  });

  fsMock.writeFileSync.mockImplementation(
    (rawPath: string, content: string) => {
      writes.set(rawPath.replace(/\\/g, "/").replace(/\/+$/, ""), content);
    },
  );

  fsMock.mkdirSync.mockReturnValue(undefined as never);

  return writes;
}

/**
 * Queue the push-down command's QuickPick prompt responses in order.
 *
 * @param input The pack selection and optional variant/memory responses.
 */
function queuePushDownPrompts(input: {
  readonly packs: ReadonlyArray<string> | undefined;
  readonly csharpVariant?: string | undefined;
  readonly memoryMode?: string | undefined;
}): void {
  const responses: unknown[] = [];
  if (input.packs === undefined) {
    responses.push(undefined);
  } else {
    responses.push(
      input.packs.map(
        (pack): PackQuickPickItem => ({ label: pack, pack, picked: true }),
      ),
    );
    if (input.packs.includes("csharp")) {
      responses.push(input.csharpVariant);
    }
    responses.push(input.memoryMode);
  }

  let callIndex = 0;
  showQuickPickMock.mockImplementation(async () => {
    const response = responses[callIndex];
    callIndex += 1;
    return response;
  });
}

describe("drm-copilot pushDownClaudeCustomizations command", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers the command 'drmCopilotExtension.pushDownClaudeCustomizations' when activate() runs", () => {
    // activateAndGetHandler throws if the command is not registered.
    activateAndGetHandler("drmCopilotExtension.pushDownClaudeCustomizations");
  });

  it("maps pack and memory selections through to the in-process port", async () => {
    // Arrange
    const writes = seedInProcessFileSystem();
    queuePushDownPrompts({
      packs: ["typescript"],
      memoryMode: "merge",
    });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    // Assert: the selected pack (plus always-core) reaches the in-process port,
    // reflected in the destination writes.
    expect(writes.has(`${WS}/.claude/rules/typescript.md`)).toBe(true);
    expect(writes.has(`${WS}/.claude/agents/orchestrator.md`)).toBe(true);
    // csharp was not selected, so its canonical path is not published.
    expect(writes.has(`${WS}/.claude/rules/csharp.md`)).toBe(false);
  });

  it("skips the C# variant prompt when C# is not selected", async () => {
    // Arrange
    seedInProcessFileSystem();
    queuePushDownPrompts({
      packs: ["typescript"],
      memoryMode: "overwrite",
    });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    // Assert: only two QuickPick prompts (packs, memory) without the variant.
    expect(showQuickPickMock.mock.calls).toHaveLength(2);
  });

  it("prompts for the C# variant when C# is selected", async () => {
    // Arrange
    seedInProcessFileSystem();
    queuePushDownPrompts({
      packs: ["csharp"],
      csharpVariant: "legacy",
      memoryMode: "overwrite",
    });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    // Assert: three prompts fire (packs, variant, memory).
    expect(showQuickPickMock.mock.calls).toHaveLength(3);
  });

  it("aborts without publishing when the pack selection is cancelled", async () => {
    // Arrange
    const writes = seedInProcessFileSystem();
    queuePushDownPrompts({ packs: undefined });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    // Assert: no destination files were written.
    expect(writes.size).toBe(0);
    expect(showQuickPickMock.mock.calls).toHaveLength(1);
  });

  it("aborts without publishing when the C# variant prompt is cancelled", async () => {
    // Arrange
    const writes = seedInProcessFileSystem();
    queuePushDownPrompts({
      packs: ["csharp"],
      csharpVariant: undefined,
      memoryMode: "overwrite",
    });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    // Assert
    expect(writes.size).toBe(0);
  });

  it("aborts without publishing when the memory-mode prompt is cancelled", async () => {
    // Arrange
    const writes = seedInProcessFileSystem();
    queuePushDownPrompts({
      packs: ["typescript"],
      memoryMode: undefined,
    });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    // Assert
    expect(writes.size).toBe(0);
  });
});
