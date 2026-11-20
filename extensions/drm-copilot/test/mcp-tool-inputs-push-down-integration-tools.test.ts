/**
 * Tests of the push-down integration input resolver (issue #1051, S42 input
 * errors).
 */

import { resolvePushDownIntegrationToolInput } from "../src/mcp-tool-inputs-push-down-integration";

describe("resolvePushDownIntegrationToolInput", () => {
  it("S42 positive: resolves a workspace_root-only input, trimmed", () => {
    expect(
      resolvePushDownIntegrationToolInput({ workspace_root: "  /dest  " }),
    ).toEqual({ workspaceRoot: "/dest" });
  });

  it.each([
    ["missing", {}, /workspace_root is required/],
    ["undefined arguments", undefined, /workspace_root is required/],
    ["a non-string value", { workspace_root: 7 }, /must be a string/],
    ["an empty value", { workspace_root: "   " }, /is required/],
    [
      "an extra property",
      { workspace_root: "/dest", dry_run: true },
      /Unexpected input properties: dry_run/,
    ],
    ["a non-object input", ["/dest"], /must be an object/],
  ])("S42 negative: rejects %s", (_label, rawInput, message) => {
    expect(() => resolvePushDownIntegrationToolInput(rawInput)).toThrow(
      message,
    );
  });
});
