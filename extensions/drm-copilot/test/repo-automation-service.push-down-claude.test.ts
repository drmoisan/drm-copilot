import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import { InMemoryPushDownFileSystem } from "./lib/push-down/push-down.test-helpers";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationService } from "../src/repo-automation-service";

const EXT = "C:/extension";
const WS = "C:/workspace";
const BUNDLE = `${EXT}/resources/claude-customizations`;

/**
 * Build an in-memory push-down filesystem seeded with a minimal `.claude`
 * tree, a legacy C# variant subtree, and pack manifests.
 *
 * @returns A seeded in-memory push-down filesystem with the workspace ensured.
 */
function seedClaudeBundle(): InMemoryPushDownFileSystem {
  const fs = new InMemoryPushDownFileSystem();
  fs.seedDir(WS);
  fs.seedFile(`${BUNDLE}/.claude/rules/typescript.md`, "# TS\n");
  fs.seedFile(`${BUNDLE}/.claude/rules/csharp.md`, "# Modern C#\n");
  fs.seedFile(`${BUNDLE}/.claude/agents/orchestrator.md`, "# Orchestrator\n");
  fs.seedFile(
    `${BUNDLE}/.claude-variants/csharp-legacy/rules/csharp.md`,
    "# Legacy C#\n",
  );
  fs.seedFile(
    `${BUNDLE}/pack-manifests/core.json`,
    JSON.stringify({
      name: "core",
      label: "Core",
      paths: [".claude/agents/orchestrator.md"],
    }),
  );
  fs.seedFile(
    `${BUNDLE}/pack-manifests/typescript.json`,
    JSON.stringify({
      name: "typescript",
      label: "TypeScript",
      paths: [".claude/rules/typescript.md"],
    }),
  );
  fs.seedFile(
    `${BUNDLE}/pack-manifests/csharp-legacy.json`,
    JSON.stringify({
      name: "csharp-legacy",
      label: "C# Legacy",
      paths: [".claude/rules/csharp.md"],
      source_prefix: ".claude-variants/csharp-legacy",
    }),
  );
  return fs;
}

describe("repo automation service pushDownClaudeCustomizations (in-process)", () => {
  beforeEach(() => {
    appendLineMock.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("returns the preserved tool, summary, and a single artifact entry", async () => {
    // Arrange
    const pushDownFileSystem = seedClaudeBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    // Act
    const result = await service.pushDownClaudeCustomizations({
      workspaceRoot: WS,
      invocationId: "push_down_claude_customizations",
    });

    // Assert: the in-process port preserves the return contract.
    expect(result.tool).toBe("push_down_claude_customizations");
    expect(result.summary).toContain(
      "Pushed bundled Claude Code customizations",
    );
    expect(result.workspaceRoot).toBe(WS);
    expect(result.artifacts).toHaveLength(1);
    expect(result.artifacts?.[0]).toContain(
      "artifacts/claude-customizations/push-down-",
    );
  });

  it("defaults to the in-process port when invocationId is omitted", async () => {
    // Arrange
    const pushDownFileSystem = seedClaudeBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    // Act
    const result = await service.pushDownClaudeCustomizations({
      workspaceRoot: WS,
    });

    // Assert
    expect(result.tool).toBe("push_down_claude_customizations");
  });

  it("preserves the canonical tool name even with an explicit invocationId", async () => {
    // Arrange
    const pushDownFileSystem = seedClaudeBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    // Act
    const result = await service.pushDownClaudeCustomizations({
      workspaceRoot: WS,
      invocationId: "custom-id-123",
    });

    // Assert
    expect(result.tool).toBe("push_down_claude_customizations");
    expect(result.workspaceRoot).toBe(WS);
  });

  it("threads packs, csharpVariant, and memoryMode into the in-process port", async () => {
    // Arrange: select csharp-legacy with the legacy variant.
    const pushDownFileSystem = seedClaudeBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    // Act
    await service.pushDownClaudeCustomizations({
      workspaceRoot: WS,
      packs: ["core", "csharp-legacy"],
      csharpVariant: "legacy",
      memoryMode: "merge",
    });

    // Assert: pack filtering and legacy variant routing are reflected in the
    // copied destination files (the in-process port received the inputs).
    expect(
      pushDownFileSystem.readTextFile(`${WS}/.claude/rules/csharp.md`),
    ).toBe("# Legacy C#\n");
    expect(
      pushDownFileSystem.isFile(`${WS}/.claude/agents/orchestrator.md`),
    ).toBe(true);
    // typescript was not selected, so it is excluded from the published set.
    expect(pushDownFileSystem.isFile(`${WS}/.claude/rules/typescript.md`)).toBe(
      false,
    );
  });

  it("publishes the full tree for a no-field input (backward compatible)", async () => {
    // Arrange
    const pushDownFileSystem = seedClaudeBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    // Act
    await service.pushDownClaudeCustomizations({ workspaceRoot: WS });

    // Assert: no pack selection publishes everything under `.claude`.
    expect(pushDownFileSystem.isFile(`${WS}/.claude/rules/typescript.md`)).toBe(
      true,
    );
    expect(pushDownFileSystem.isFile(`${WS}/.claude/rules/csharp.md`)).toBe(
      true,
    );
  });

  it("publishes the full tree when the packs array is empty", async () => {
    // Arrange
    const pushDownFileSystem = seedClaudeBundle();
    const service = createRepoAutomationService({
      extensionRoot: EXT,
      output: { appendLine: appendLineMock },
      pushDownFileSystem,
    });

    // Act
    await service.pushDownClaudeCustomizations({
      workspaceRoot: WS,
      packs: [],
    });

    // Assert: an empty packs array behaves like no selection (publish all).
    expect(pushDownFileSystem.isFile(`${WS}/.claude/rules/typescript.md`)).toBe(
      true,
    );
  });
});
