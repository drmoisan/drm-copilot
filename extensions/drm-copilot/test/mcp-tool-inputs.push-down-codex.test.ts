import { describe, expect, it } from "@jest/globals";

import { resolvePushDownCodexAndAgentsCustomizationsToolInput } from "../src/mcp-tool-inputs";

/**
 * `resolvePushDownCodexAndAgentsCustomizationsToolInput` coverage, split into
 * its own file so `mcp-tool-inputs.test.ts` stays under the 500-line
 * production/test file limit, matching the split precedent already set by
 * `mcp-tool-inputs.workspace-root.test.ts` and
 * `mcp-tool-inputs.codex-native-converter.test.ts`.
 */
describe("resolvePushDownCodexAndAgentsCustomizationsToolInput", () => {
  it("returns workspaceRoot from explicit value", () => {
    expect(
      resolvePushDownCodexAndAgentsCustomizationsToolInput({
        workspace_root: "C:/ws",
      }),
    ).toEqual({ workspaceRoot: "C:/ws" });
  });

  it("returns optional packs, csharp variant, and memory mode when provided", () => {
    expect(
      resolvePushDownCodexAndAgentsCustomizationsToolInput({
        workspace_root: "C:/ws",
        packs: ["typescript", "csharp"],
        csharp_variant: "legacy",
        memory_mode: "skip",
      }),
    ).toEqual({
      workspaceRoot: "C:/ws",
      packs: ["typescript", "csharp"],
      csharpVariant: "legacy",
      memoryMode: "skip",
    });
  });

  it("rejects invalid Codex selection fields", () => {
    expect(() =>
      resolvePushDownCodexAndAgentsCustomizationsToolInput({
        workspace_root: "C:/ws",
        packs: "typescript",
      }),
    ).toThrow("Field 'packs' must be an array of strings when provided.");
    expect(() =>
      resolvePushDownCodexAndAgentsCustomizationsToolInput({
        workspace_root: "C:/ws",
        csharp_variant: "current",
      }),
    ).toThrow("Field 'csharp_variant' must be 'modern' or 'legacy'.");
    expect(() =>
      resolvePushDownCodexAndAgentsCustomizationsToolInput({
        workspace_root: "C:/ws",
        memory_mode: "replace",
      }),
    ).toThrow("Field 'memory_mode' must be 'overwrite', 'merge', or 'skip'.");
  });
});
