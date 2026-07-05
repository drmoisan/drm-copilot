import { describe, expect, it } from "@jest/globals";
import { parseTranscriptLines } from "../../../src/lib/subagent-tree/transcript-parser";

describe("parseTranscriptLines", () => {
  it("collects Agent tool-use ids in file line order and the single observed model", () => {
    // Arrange: three lines, two distinct Agent tool-use blocks, one model value.
    const lines = [
      JSON.stringify({
        message: {
          model: "claude-sonnet-5",
          content: [{ type: "text", text: "hello" }],
        },
      }),
      JSON.stringify({
        message: {
          model: "claude-sonnet-5",
          content: [
            { type: "tool_use", name: "Agent", id: "toolu_1" },
            { type: "tool_use", name: "Bash", id: "toolu_bash" },
          ],
        },
      }),
      JSON.stringify({
        message: {
          content: [{ type: "tool_use", name: "Agent", id: "toolu_2" }],
        },
      }),
    ];

    // Act
    const result = parseTranscriptLines(lines);

    // Assert
    expect(result.agentToolUseIds).toEqual(["toolu_1", "toolu_2"]);
    expect(result.models).toEqual(["claude-sonnet-5"]);
  });

  it("collects both distinct truthy models across turns", () => {
    // Arrange: two turns carry two different truthy message.model values.
    const lines = [
      JSON.stringify({ message: { model: "claude-sonnet-5" } }),
      JSON.stringify({ message: { model: "claude-opus-4" } }),
      JSON.stringify({ message: { model: "claude-sonnet-5" } }),
    ];

    // Act
    const result = parseTranscriptLines(lines);

    // Assert
    expect(result.models).toEqual(["claude-sonnet-5", "claude-opus-4"]);
  });

  it("ignores blank lines, non-JSON lines, and lines whose message is a string", () => {
    // Arrange: a blank line, a non-JSON line, and a string `message` field.
    const lines = [
      "",
      "not json at all {{{",
      JSON.stringify({ message: "plain text turn" }),
      JSON.stringify({
        message: {
          model: "claude-sonnet-5",
          content: [{ type: "tool_use", name: "Agent", id: "toolu_3" }],
        },
      }),
    ];

    // Act
    const result = parseTranscriptLines(lines);

    // Assert: only the well-formed final line contributes output.
    expect(result.models).toEqual(["claude-sonnet-5"]);
    expect(result.agentToolUseIds).toEqual(["toolu_3"]);
  });

  it("returns Agent tool-use ids in file line order even when alphabetical order differs", () => {
    // Arrange: "toolu_z" appears before "toolu_a" in file line order.
    const lines = [
      JSON.stringify({
        message: {
          content: [{ type: "tool_use", name: "Agent", id: "toolu_z" }],
        },
      }),
      JSON.stringify({
        message: {
          content: [{ type: "tool_use", name: "Agent", id: "toolu_a" }],
        },
      }),
    ];

    // Act
    const result = parseTranscriptLines(lines);

    // Assert: file line order is preserved, not alphabetical order.
    expect(result.agentToolUseIds).toEqual(["toolu_z", "toolu_a"]);
  });
});
