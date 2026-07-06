import { describe, expect, it } from "@jest/globals";
import { assembleTree } from "../../../src/lib/subagent-tree/tree-assembler";
import type {
  ScannedSession,
  ScannedSubagent,
} from "../../../src/lib/subagent-tree/types";

/** Build a `ScannedSubagent` fixture with sensible defaults. */
function subagent(overrides: {
  readonly agentId: string;
  readonly toolUseId: string;
  readonly agentType?: string;
  readonly description?: string;
  readonly spawnDepth?: number;
  readonly models?: readonly string[];
  readonly agentToolUseIds?: readonly string[];
}): ScannedSubagent {
  return {
    meta: {
      agentId: overrides.agentId,
      agentType: overrides.agentType ?? "atomic-executor",
      description: overrides.description ?? `${overrides.agentId} description`,
      toolUseId: overrides.toolUseId,
      spawnDepth: overrides.spawnDepth ?? 1,
    },
    transcript: {
      models: overrides.models ?? ["claude-sonnet-5"],
      agentToolUseIds: overrides.agentToolUseIds ?? [],
    },
  };
}

describe("assembleTree", () => {
  it("assembles a root with two direct subagent children in the expected order", () => {
    // Arrange: root spawns "toolu_a" then "toolu_b", each matched to a subagent.
    const scanned: ScannedSession = {
      root: {
        models: ["claude-sonnet-5"],
        agentToolUseIds: ["toolu_a", "toolu_b"],
      },
      subagents: [
        subagent({ agentId: "a", toolUseId: "toolu_a" }),
        subagent({ agentId: "b", toolUseId: "toolu_b" }),
      ],
    };

    // Act
    const tree = assembleTree(scanned);

    // Assert
    expect(tree.children).toHaveLength(2);
    expect(tree.children.map((child) => child.description)).toEqual([
      "a description",
      "b description",
    ]);
  });

  it("assembles an empty children array when there are no subagents", () => {
    // Arrange
    const scanned: ScannedSession = {
      root: { models: ["claude-sonnet-5"], agentToolUseIds: [] },
      subagents: [],
    };

    // Act
    const tree = assembleTree(scanned);

    // Assert
    expect(tree.children).toEqual([]);
    expect(tree.depth).toBe(0);
  });

  it("sorts a subagent node's multiple models ascending", () => {
    // Arrange: one subagent whose transcript carries two distinct models.
    const scanned: ScannedSession = {
      root: { models: [], agentToolUseIds: ["toolu_a"] },
      subagents: [
        subagent({
          agentId: "a",
          toolUseId: "toolu_a",
          models: ["claude-sonnet-5", "claude-opus-4"],
        }),
      ],
    };

    // Act
    const tree = assembleTree(scanned);

    // Assert: sorted ascending, not insertion order.
    expect(tree.children[0]?.models).toEqual([
      "claude-opus-4",
      "claude-sonnet-5",
    ]);
  });

  it("places a grandchild inside its direct parent's children, not the root's", () => {
    // Arrange: root spawns "mid"; "mid" itself spawns "grandchild".
    const scanned: ScannedSession = {
      root: { models: [], agentToolUseIds: ["toolu_mid"] },
      subagents: [
        subagent({
          agentId: "mid",
          toolUseId: "toolu_mid",
          agentToolUseIds: ["toolu_grandchild"],
        }),
        subagent({ agentId: "grandchild", toolUseId: "toolu_grandchild" }),
      ],
    };

    // Act
    const tree = assembleTree(scanned);

    // Assert: root has exactly one child ("mid"); the grandchild is nested.
    expect(tree.children).toHaveLength(1);
    expect(tree.children[0]?.children).toHaveLength(1);
    expect(tree.children[0]?.children[0]?.description).toBe(
      "grandchild description",
    );
  });

  it("attaches an orphan (unmatched toolUseId) as a root child after matched children, without throwing", () => {
    // Arrange: root only spawns "toolu_a"; "orphan" claims a toolUseId nobody emitted.
    const scanned: ScannedSession = {
      root: { models: [], agentToolUseIds: ["toolu_a"] },
      subagents: [
        subagent({ agentId: "a", toolUseId: "toolu_a" }),
        subagent({ agentId: "orphan", toolUseId: "toolu_missing" }),
      ],
    };

    // Act
    const build = (): ReturnType<typeof assembleTree> => assembleTree(scanned);

    // Assert: does not throw, and the orphan is appended after "a".
    expect(build).not.toThrow();
    const tree = build();
    expect(tree.children).toHaveLength(2);
    expect(tree.children.map((child) => child.description)).toEqual([
      "a description",
      "orphan description",
    ]);
  });

  it("orders siblings by spawn line order, not alphabetical agentId order", () => {
    // Arrange: "toolu_second" is spawned first in the parent transcript, but
    // its subagent's agentId ("bravo") sorts after "alpha" alphabetically.
    const scanned: ScannedSession = {
      root: {
        models: [],
        agentToolUseIds: ["toolu_second", "toolu_first"],
      },
      subagents: [
        subagent({ agentId: "alpha", toolUseId: "toolu_first" }),
        subagent({ agentId: "bravo", toolUseId: "toolu_second" }),
      ],
    };

    // Act
    const tree = assembleTree(scanned);

    // Assert: "bravo" (toolu_second) comes first, matching line order.
    expect(tree.children.map((child) => child.description)).toEqual([
      "bravo description",
      "alpha description",
    ]);
  });
});
