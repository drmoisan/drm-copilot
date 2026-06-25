import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import {
  handlePushDownClaudeCustomizations,
  handlePushDownCopilotCustomizations,
} from "../src/mcp-handlers/push-down-handlers";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../src/repo-automation-service";

function createMockService(): jest.Mocked<
  Pick<RepoAutomationService, "pushDownClaudeCustomizations">
> {
  return {
    pushDownClaudeCustomizations: jest.fn(),
  };
}

describe("handlePushDownClaudeCustomizations", () => {
  it("resolves input via resolvePushDownClaudeCustomizationsToolInput and calls service.pushDownClaudeCustomizations exactly once with the resolved input", async () => {
    const mockResult: RepoAutomationExecutionResult = {
      tool: "push_down_claude_customizations",
      workspaceRoot: "C:/workspace",
      artifacts: [],
      summary: "Pushed bundled Claude Code customizations.",
    };
    const service = createMockService();
    service.pushDownClaudeCustomizations.mockResolvedValue(mockResult);

    const result = await handlePushDownClaudeCustomizations(
      { workspace_root: "C:/workspace" },
      service as unknown as RepoAutomationService,
    );

    // Verify the service method was called exactly once with the resolved input.
    expect(service.pushDownClaudeCustomizations).toHaveBeenCalledTimes(1);
    expect(service.pushDownClaudeCustomizations).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
    });
    expect(result).toBe(mockResult);
  });

  it("forwards resolved packs, csharp_variant, and memory_mode to the service", async () => {
    const mockResult: RepoAutomationExecutionResult = {
      tool: "push_down_claude_customizations",
      workspaceRoot: "C:/workspace",
      artifacts: [],
      summary: "Pushed bundled Claude Code customizations.",
    };
    const service = createMockService();
    service.pushDownClaudeCustomizations.mockResolvedValue(mockResult);

    await handlePushDownClaudeCustomizations(
      {
        workspace_root: "C:/workspace",
        packs: ["core", "typescript"],
        csharp_variant: "legacy",
        memory_mode: "merge",
      },
      service as unknown as RepoAutomationService,
    );

    // The resolved input maps the raw snake_case fields to camelCase service
    // fields and forwards them to the service.
    expect(service.pushDownClaudeCustomizations).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      packs: ["core", "typescript"],
      csharpVariant: "legacy",
      memoryMode: "merge",
    });
  });

  it("rejects an out-of-range memory_mode enum value", async () => {
    const service = createMockService();

    await expect(
      handlePushDownClaudeCustomizations(
        { workspace_root: "C:/workspace", memory_mode: "replace" },
        service as unknown as RepoAutomationService,
      ),
    ).rejects.toThrow(/memory_mode/);

    expect(service.pushDownClaudeCustomizations).not.toHaveBeenCalled();
  });

  it("rejects an out-of-range csharp_variant enum value", async () => {
    const service = createMockService();

    await expect(
      handlePushDownClaudeCustomizations(
        { workspace_root: "C:/workspace", csharp_variant: "vintage" },
        service as unknown as RepoAutomationService,
      ),
    ).rejects.toThrow(/csharp_variant/);

    expect(service.pushDownClaudeCustomizations).not.toHaveBeenCalled();
  });

  it("propagates rejection when the resolver throws on missing workspace_root", async () => {
    const service = createMockService();

    // Pass a non-object input to trigger the resolver validation error.
    await expect(
      handlePushDownClaudeCustomizations(
        null,
        service as unknown as RepoAutomationService,
      ),
    ).rejects.toThrow();

    expect(service.pushDownClaudeCustomizations).not.toHaveBeenCalled();
  });
});

describe("handlePushDownCopilotCustomizations", () => {
  it("resolves input and calls service.pushDownCopilotCustomizations exactly once with the resolved input", async () => {
    const mockResult: RepoAutomationExecutionResult = {
      tool: "push_down_copilot_customizations",
      workspaceRoot: "C:/workspace",
      artifacts: [],
      summary: "Pushed bundled Copilot customizations.",
    };
    const service = {
      pushDownCopilotCustomizations:
        jest.fn<() => Promise<RepoAutomationExecutionResult>>(),
    };
    service.pushDownCopilotCustomizations.mockResolvedValue(mockResult);

    const result = await handlePushDownCopilotCustomizations(
      { workspace_root: "C:/workspace" },
      service as unknown as RepoAutomationService,
    );

    expect(service.pushDownCopilotCustomizations).toHaveBeenCalledTimes(1);
    expect(service.pushDownCopilotCustomizations).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
    });
    expect(result).toBe(mockResult);
  });
});
