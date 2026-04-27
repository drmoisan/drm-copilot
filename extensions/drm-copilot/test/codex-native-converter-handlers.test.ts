import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { handleRunCodexNativeConverter } from "../src/mcp-handlers/codex-native-converter-handlers";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../src/repo-automation-service";

describe("handleRunCodexNativeConverter", () => {
  it("forwards normalized converter input to the repo automation service", async () => {
    const expected: RepoAutomationExecutionResult = {
      tool: "run_codex_native_converter",
      workspaceRoot: "C:/workspace",
      artifacts: ["C:/workspace/artifacts/codex-native-converter"],
      summary:
        "Ran bundled codex-native-converter in review mode for 'claude'.",
    };
    const service = {
      runCodexNativeConverter:
        jest.fn<() => Promise<RepoAutomationExecutionResult>>(),
    };
    service.runCodexNativeConverter.mockResolvedValue(expected);

    const result = await handleRunCodexNativeConverter(
      {
        workspace_root: "C:/workspace",
        mode: "review",
        source_ecosystem: "claude",
        source_root: "fixtures/source",
      },
      service as unknown as RepoAutomationService,
    );

    expect(service.runCodexNativeConverter).toHaveBeenCalledTimes(1);
    expect(service.runCodexNativeConverter).toHaveBeenCalledWith({
      workspaceRoot: "C:/workspace",
      mode: "review",
      sourceEcosystem: "claude",
      sourceRoot: "C:/workspace/fixtures/source",
    });
    expect(result).toBe(expected);
  });
});
