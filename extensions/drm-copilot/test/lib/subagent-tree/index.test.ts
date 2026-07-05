import { describe, expect, it } from "@jest/globals";
import {
  buildSubagentTree,
  formatTree,
} from "../../../src/lib/subagent-tree/index";
import { InMemoryFileSystem } from "./in-memory-file-system";

/** Build a root transcript line containing one `Agent` tool-use block. */
function agentToolUseLine(model: string, toolUseId: string): string {
  return JSON.stringify({
    message: {
      model,
      content: [{ type: "tool_use", name: "Agent", id: toolUseId }],
    },
  });
}

describe("buildSubagentTree (end-to-end scanner + assembler composition)", () => {
  it("composes the scanner and assembler for a multi-agent session and round-trips through formatTree", () => {
    // Arrange: a root session spawning two subagents against the in-memory
    // FileSystem fixture, mirroring the positive multi-agent scenario.
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-1.jsonl";
    fileSystem.addFile(
      rootSessionPath,
      [
        agentToolUseLine("claude-sonnet-5", "toolu_a"),
        agentToolUseLine("claude-sonnet-5", "toolu_b"),
      ].join("\n"),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-1/subagents/agent-aaa.meta.json",
      JSON.stringify({
        agentType: "atomic-executor",
        description: "Execute plan",
        toolUseId: "toolu_a",
        spawnDepth: 1,
      }),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-1/subagents/agent-aaa.jsonl",
      JSON.stringify({ message: { model: "claude-sonnet-5" } }),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-1/subagents/agent-bbb.meta.json",
      JSON.stringify({
        agentType: "atomic-planner",
        description: "Plan the work",
        toolUseId: "toolu_b",
        spawnDepth: 1,
      }),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-1/subagents/agent-bbb.jsonl",
      JSON.stringify({ message: { model: "claude-opus-4" } }),
    );

    // Act
    const tree = buildSubagentTree(rootSessionPath, { fileSystem });
    const rendered = (): string => formatTree(tree);

    // Assert: the composed tree has both subagents as root children, and
    // formatTree renders it without throwing.
    expect(tree.children).toHaveLength(2);
    expect(rendered).not.toThrow();
    const lines = rendered().split("\n");
    expect(lines).toHaveLength(3);
    expect(lines[1]).toContain("Execute plan");
    expect(lines[2]).toContain("Plan the work");
  });
});
