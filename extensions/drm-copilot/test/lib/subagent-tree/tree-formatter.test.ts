import { describe, expect, it } from "@jest/globals";
import { formatTree } from "../../../src/lib/subagent-tree/tree-formatter";
import type { TreeNode } from "../../../src/lib/subagent-tree/types";

describe("formatTree", () => {
  it("renders a two-level tree with the child indented two spaces relative to the root", () => {
    // Arrange: root at depth 0 with one child at depth 1.
    const tree: TreeNode = {
      agentType: "root",
      description: "",
      depth: 0,
      models: ["claude-sonnet-5"],
      children: [
        {
          agentType: "atomic-executor",
          description: "Execute plan",
          depth: 1,
          models: ["claude-sonnet-5"],
          children: [],
        },
      ],
    };

    // Act
    const rendered = formatTree(tree);

    // Assert
    const lines = rendered.split("\n");
    expect(lines).toHaveLength(2);
    expect(lines[0]).toBe("root · [claude-sonnet-5] · 0 · ");
    expect(lines[1]).toBe(
      "  atomic-executor · [claude-sonnet-5] · 1 · Execute plan",
    );
  });

  it("renders a node's multiple models comma-joined and sorted ascending", () => {
    // Arrange: a node whose models array is not already in ascending order.
    const tree: TreeNode = {
      agentType: "atomic-executor",
      description: "Mid-session model switch",
      depth: 0,
      models: ["claude-sonnet-5", "claude-opus-4"],
      children: [],
    };

    // Act
    const rendered = formatTree(tree);

    // Assert: ascending order regardless of input order.
    expect(rendered).toBe(
      "atomic-executor · [claude-opus-4,claude-sonnet-5] · 0 · Mid-session model switch",
    );
  });

  it("renders exactly one line for a root node with no children", () => {
    // Arrange
    const tree: TreeNode = {
      agentType: "root",
      description: "",
      depth: 0,
      models: [],
      children: [],
    };

    // Act
    const rendered = formatTree(tree);

    // Assert
    expect(rendered.split("\n")).toHaveLength(1);
    expect(rendered).toBe("root · [] · 0 · ");
  });
});
