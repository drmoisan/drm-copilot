import { beforeEach, describe, expect, it } from "@jest/globals";

import {
  mermaidLabel,
  renderDestinationToRepeatedSourceChart,
  renderSourceToDestinationChart,
  renderSourceToRepeatedDestinationChart,
} from "../../../src/lib/codex-native-converter/reporting-topology";
import { buildPromptTranslationTraces } from "../../../src/lib/codex-native-converter/pipeline-traces";
import {
  ConversionClass,
  type MappingRecord,
  type RunOptions,
  SectionIntentKind,
  SourceEcosystem,
  SourceKind,
  TargetRole,
  type TopologyEdge,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

/**
 * Build an edge value.
 *
 * @param sourcePath Source path.
 * @param destinationPath Destination path.
 * @returns A topology edge.
 */
function edge(sourcePath: string, destinationPath: string): TopologyEdge {
  return { sourcePath, destinationPath };
}

/**
 * Parse `node_id["label"]` declarations from a Mermaid block.
 *
 * @param block Rendered Mermaid lines.
 * @returns Map of node id to label.
 */
function nodeLabels(block: ReadonlyArray<string>): Map<string, string> {
  const labels = new Map<string, string>();
  const pattern = /^\s*(\w+)\["(.+?)"\]\s*$/u;
  for (const line of block) {
    const match = pattern.exec(line);
    if (match) {
      labels.set(match[1] as string, match[2] as string);
    }
  }
  return labels;
}

/**
 * Resolve labeled edges from a Mermaid block.
 *
 * @param block Rendered Mermaid lines.
 * @returns Set of `source->destination` label pairs.
 */
function labeledEdges(block: ReadonlyArray<string>): Set<string> {
  const labels = nodeLabels(block);
  const edges = new Set<string>();
  const pattern = /^\s*(\w+)\s+-->\s+(\w+)\s*$/u;
  for (const line of block) {
    const match = pattern.exec(line);
    if (match) {
      const source = labels.get(match[1] as string) ?? "";
      const destination = labels.get(match[2] as string) ?? "";
      edges.add(`${source}->${destination}`);
    }
  }
  return edges;
}

describe("mermaidLabel", () => {
  it("escapes labels without surrounding quotes", () => {
    // Arrange & Act & Assert
    expect(mermaidLabel('a"b')).toBe('a\\"b');
    expect(mermaidLabel("plain")).toBe("plain");
  });
});

describe("renderSourceToDestinationChart", () => {
  it("deduplicates both source and destination nodes", () => {
    // Arrange
    const edges = [
      edge("src-a", "dest-x"),
      edge("src-a", "dest-x"),
      edge("src-b", "dest-x"),
    ];

    // Act
    const block = renderSourceToDestinationChart(edges);

    // Assert: shared destination node reused; two source nodes; three arrows.
    expect(block[0]).toBe("```mermaid");
    expect(block[1]).toBe("graph LR");
    const labels = nodeLabels(block);
    const destinationNodes = [...labels.values()].filter(
      (value) => value === "dest-x",
    );
    expect(destinationNodes).toHaveLength(1);
    const arrows = block.filter((line) => line.includes("-->"));
    expect(arrows).toHaveLength(3);
    expect(labeledEdges(block)).toContain("src-a->dest-x");
    expect(labeledEdges(block)).toContain("src-b->dest-x");
  });

  it("renders only the fences for an empty edge set", () => {
    // Arrange & Act
    const block = renderSourceToDestinationChart([]);

    // Assert
    expect(block).toEqual(["```mermaid", "graph LR", "```"]);
  });
});

describe("renderSourceToRepeatedDestinationChart", () => {
  it("collapses source nodes but repeats destination nodes per edge", () => {
    // Arrange
    const edges = [
      edge("src-a", "dest-x"),
      edge("src-a", "dest-x"),
      edge("src-a", "dest-y"),
    ];

    // Act
    const block = renderSourceToRepeatedDestinationChart(edges);

    // Assert: one source node, three destination nodes, three arrows.
    const labels = nodeLabels(block);
    const sourceNodes = [...labels.values()].filter(
      (value) => value === "src-a",
    );
    expect(sourceNodes).toHaveLength(1);
    const destinationNodes = [...labels.values()].filter((value) =>
      value.startsWith("dest-"),
    );
    expect(destinationNodes).toHaveLength(3);
    const arrows = block.filter((line) => line.includes("-->"));
    expect(arrows).toHaveLength(3);
  });

  it("renders only the fences for an empty edge set", () => {
    // Arrange & Act
    const block = renderSourceToRepeatedDestinationChart([]);

    // Assert
    expect(block).toEqual(["```mermaid", "graph LR", "```"]);
  });
});

describe("renderDestinationToRepeatedSourceChart", () => {
  it("collapses destination nodes but repeats source nodes per edge", () => {
    // Arrange
    const edges = [
      edge("src-a", "dest-x"),
      edge("src-b", "dest-x"),
      edge("src-c", "dest-y"),
    ];

    // Act
    const block = renderDestinationToRepeatedSourceChart(edges);

    // Assert: two destination nodes, three source nodes, arrows reversed.
    const labels = nodeLabels(block);
    const destinationNodes = [...labels.values()].filter((value) =>
      value.startsWith("dest-"),
    );
    expect(destinationNodes).toHaveLength(2);
    const sourceNodes = [...labels.values()].filter((value) =>
      value.startsWith("src-"),
    );
    expect(sourceNodes).toHaveLength(3);
    expect(labeledEdges(block)).toContain("dest-x->src-a");
    expect(labeledEdges(block)).toContain("dest-x->src-b");
    expect(labeledEdges(block)).toContain("dest-y->src-c");
  });

  it("renders only the fences for an empty edge set", () => {
    // Arrange & Act
    const block = renderDestinationToRepeatedSourceChart([]);

    // Assert
    expect(block).toEqual(["```mermaid", "graph LR", "```"]);
  });
});

describe("buildPromptTranslationTraces", () => {
  let fileSystem: InMemoryFileSystem;
  const SOURCE_ROOT = "/repo";
  const PROMPT_PATH = ".github/prompts/example.prompt.md";

  beforeEach(() => {
    fileSystem = new InMemoryFileSystem();
  });

  function runOptions(overrides: Partial<RunOptions> = {}): RunOptions {
    return {
      mode: "review",
      sourceRoot: SOURCE_ROOT,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      selectedPaths: [],
      destinationRoot: null,
      artifactRoot: `${SOURCE_ROOT}/artifacts`,
      enableRepoPrompts: true,
      emitIntermediateState: false,
      ...overrides,
    };
  }

  function launcherRecord(): MappingRecord {
    return {
      sourcePath: PROMPT_PATH,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.LAUNCHER_PROMPT,
      conversionClass: ConversionClass.DECOMPOSED,
      targetRole: TargetRole.LAUNCHER,
      targetPath: ".codex/prompts/example.md",
      notes: [],
      isRequired: true,
    };
  }

  it("returns an empty array for non-launcher records", () => {
    // Arrange
    const record: MappingRecord = {
      ...launcherRecord(),
      sourceKind: SourceKind.STANDING_INSTRUCTION,
    };

    // Act
    const traces = buildPromptTranslationTraces(
      fileSystem,
      runOptions(),
      record,
    );

    // Assert
    expect(traces).toEqual([]);
  });

  it("emits a launcher trace plus workflow and hook section traces", () => {
    // Arrange
    fileSystem.addFile(
      `${SOURCE_ROOT}/${PROMPT_PATH}`,
      [
        "# Example Prompt",
        "",
        "## Workflow",
        "1. discover",
        "2. classify",
        "3. report",
        "",
        "## Hard Gate",
        "Execution MUST NOT begin until preflight passes.",
        "",
      ].join("\n"),
    );

    // Act
    const traces = buildPromptTranslationTraces(
      fileSystem,
      runOptions(),
      launcherRecord(),
    );

    // Assert
    const launcher = traces.find(
      (trace) => trace.intentKind === SectionIntentKind.LAUNCHER_ONLY,
    );
    expect(launcher?.heading).toBe("Launcher Surface");
    expect(launcher?.targetRole).toBe(TargetRole.LAUNCHER);
    expect(
      traces.some(
        (trace) =>
          trace.targetRole === TargetRole.SHARED_SKILL &&
          trace.intentKind === SectionIntentKind.SHARED_WORKFLOW,
      ),
    ).toBe(true);
    expect(
      traces.some(
        (trace) =>
          trace.targetRole === TargetRole.HOOK &&
          trace.intentKind === SectionIntentKind.HOOK_CANDIDATE,
      ),
    ).toBe(true);
    // Traces are sorted by (sourcePath, sectionId, targetRole).
    const sectionIds = traces.map((trace) => trace.sectionId);
    expect([...sectionIds]).toEqual(
      [...sectionIds].sort((left, right) =>
        left < right ? -1 : left > right ? 1 : 0,
      ),
    );
  });

  it("records the disabled-prompt note when repo prompts are off", () => {
    // Arrange
    fileSystem.addFile(
      `${SOURCE_ROOT}/${PROMPT_PATH}`,
      "# Example Prompt\n\nNeutral prose.\n",
    );

    // Act
    const traces = buildPromptTranslationTraces(
      fileSystem,
      runOptions({ enableRepoPrompts: false }),
      launcherRecord(),
    );

    // Assert
    const launcher = traces.find(
      (trace) => trace.intentKind === SectionIntentKind.LAUNCHER_ONLY,
    );
    expect(launcher?.targetPath).toBeNull();
    expect(launcher?.notes).toContain(
      "Repository-convention prompt output is disabled for this run.",
    );
  });
});
