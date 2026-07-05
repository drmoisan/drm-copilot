import { describe, expect, it } from "@jest/globals";
import { scanTranscripts } from "../../../src/lib/subagent-tree/transcript-scanner";
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

describe("scanTranscripts", () => {
  it("scans a root session with two direct subagent transcripts", () => {
    // Arrange: a root transcript spawning two subagents, each with its own
    // meta.json and .jsonl transcript under the sibling `subagents` dir.
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
        worktreePath: "/worktrees/bbb",
        worktreeBranch: "feature/bbb",
      }),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-1/subagents/agent-bbb.jsonl",
      JSON.stringify({ message: { model: "claude-opus-4" } }),
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert
    expect(scanned.subagents).toHaveLength(2);
    const byAgentId = new Map(
      scanned.subagents.map((subagent) => [subagent.meta.agentId, subagent]),
    );
    expect(byAgentId.get("aaa")?.meta).toEqual({
      agentId: "aaa",
      agentType: "atomic-executor",
      description: "Execute plan",
      toolUseId: "toolu_a",
      spawnDepth: 1,
    });
    expect(byAgentId.get("bbb")?.meta).toEqual({
      agentId: "bbb",
      agentType: "atomic-planner",
      description: "Plan the work",
      toolUseId: "toolu_b",
      spawnDepth: 1,
      worktreePath: "/worktrees/bbb",
      worktreeBranch: "feature/bbb",
    });
    expect(scanned.root.agentToolUseIds).toEqual(["toolu_a", "toolu_b"]);
  });

  it("returns an empty subagents array when the subagents directory does not exist", () => {
    // Arrange: only the root transcript is seeded; no `subagents` directory.
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-2.jsonl";
    fileSystem.addFile(
      rootSessionPath,
      JSON.stringify({ message: { model: "claude-sonnet-5" } }),
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert: no throw, and an empty subagents array.
    expect(scanned.subagents).toEqual([]);
  });

  it("scans a grandchild subagent whose spawning tool-use lives in its parent's transcript", () => {
    // Arrange: root spawns "mid"; "mid"'s own transcript spawns "grandchild".
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-3.jsonl";
    fileSystem.addFile(
      rootSessionPath,
      agentToolUseLine("claude-sonnet-5", "toolu_mid"),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-3/subagents/agent-mid.meta.json",
      JSON.stringify({
        agentType: "atomic-executor",
        description: "Mid-level agent",
        toolUseId: "toolu_mid",
        spawnDepth: 1,
      }),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-3/subagents/agent-mid.jsonl",
      agentToolUseLine("claude-sonnet-5", "toolu_grandchild"),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-3/subagents/agent-grandchild.meta.json",
      JSON.stringify({
        agentType: "atomic-executor",
        description: "Grandchild agent",
        toolUseId: "toolu_grandchild",
        spawnDepth: 2,
      }),
    );
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-3/subagents/agent-grandchild.jsonl",
      JSON.stringify({ message: { model: "claude-opus-4" } }),
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert: both subagents are present with their own parsed transcripts.
    expect(scanned.subagents).toHaveLength(2);
    const byAgentId = new Map(
      scanned.subagents.map((subagent) => [subagent.meta.agentId, subagent]),
    );
    expect(byAgentId.get("mid")?.transcript.agentToolUseIds).toEqual([
      "toolu_grandchild",
    ]);
    expect(byAgentId.get("grandchild")?.transcript.models).toEqual([
      "claude-opus-4",
    ]);
  });

  it("throws a fail-fast error when rootSessionPath does not end in .jsonl", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();

    // Act / Assert
    expect(() =>
      scanTranscripts("/workspace/session-1.txt", fileSystem),
    ).toThrow(/must end in ".jsonl"/);
  });

  it("skips a meta path whose filename does not carry a non-empty agentId", () => {
    // Arrange: "agent-.meta.json" satisfies the glob ("*" may match zero
    // characters) but fails the stricter agentId-capturing filename pattern.
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-4.jsonl";
    fileSystem.addFile(rootSessionPath, "");
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-4/subagents/agent-.meta.json",
      JSON.stringify({
        agentType: "atomic-executor",
        description: "no id",
        toolUseId: "toolu_x",
        spawnDepth: 1,
      }),
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert: the unparsable filename is skipped rather than throwing.
    expect(scanned.subagents).toEqual([]);
  });

  it("skips a subagent whose meta.json is not valid JSON", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-5.jsonl";
    fileSystem.addFile(rootSessionPath, "");
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-5/subagents/agent-bad.meta.json",
      "{not valid json",
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert
    expect(scanned.subagents).toEqual([]);
  });

  it("skips a subagent whose meta.json parses to a non-object value", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-6.jsonl";
    fileSystem.addFile(rootSessionPath, "");
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-6/subagents/agent-num.meta.json",
      "42",
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert
    expect(scanned.subagents).toEqual([]);
  });

  it("skips a subagent whose meta.json is missing a required field", () => {
    // Arrange: `toolUseId` is a number instead of the required string type.
    const fileSystem = new InMemoryFileSystem();
    const rootSessionPath = "/workspace/.claude/projects/proj/session-7.jsonl";
    fileSystem.addFile(rootSessionPath, "");
    fileSystem.addFile(
      "/workspace/.claude/projects/proj/session-7/subagents/agent-bad2.meta.json",
      JSON.stringify({
        agentType: "atomic-executor",
        description: "wrong types",
        toolUseId: 123,
        spawnDepth: 1,
      }),
    );

    // Act
    const scanned = scanTranscripts(rootSessionPath, fileSystem);

    // Assert
    expect(scanned.subagents).toEqual([]);
  });
});
