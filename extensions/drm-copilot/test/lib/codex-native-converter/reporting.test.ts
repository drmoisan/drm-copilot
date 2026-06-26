import { beforeEach, describe, expect, it } from "@jest/globals";

import { writeConversionReportSet } from "../../../src/lib/codex-native-converter/reporting";
import { renderConversionReport } from "../../../src/lib/codex-native-converter/reporting-render";
import {
  ConversionClass,
  type MappingRecord,
  type RunOptions,
  SectionIntentKind,
  SourceEcosystem,
  SourceKind,
  TargetRole,
  type TopologyEdge,
  type TranslationTrace,
  type ValidationFinding,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const ARTIFACT_ROOT = "fixtures/artifacts";

/**
 * Build a run-options value with review defaults for report tests.
 *
 * @param overrides Field overrides.
 * @returns A run-options value.
 */
function runOptions(overrides: Partial<RunOptions> = {}): RunOptions {
  return {
    mode: "review",
    sourceRoot: "fixtures/source",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    selectedPaths: [],
    destinationRoot: null,
    artifactRoot: ARTIFACT_ROOT,
    enableRepoPrompts: false,
    emitIntermediateState: false,
    ...overrides,
  };
}

/**
 * Build a mapping record with sensible defaults.
 *
 * @param overrides Field overrides (sourcePath required).
 * @returns A mapping record.
 */
function record(
  overrides: Partial<MappingRecord> & { sourcePath: string },
): MappingRecord {
  return {
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind: SourceKind.STANDING_INSTRUCTION,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.STANDING_GUIDANCE,
    targetPath: "AGENTS.md",
    notes: [],
    isRequired: true,
    ...overrides,
  };
}

const STANDING_RECORD = record({
  sourcePath: ".github/copilot-instructions.md",
  targetPath: "AGENTS.md",
});
const AGENT_RECORD = record({
  sourcePath: ".github/agents/5.1-Beast-adjusted.agent.md",
  sourceKind: SourceKind.AGENT_MANIFEST,
  conversionClass: ConversionClass.DECOMPOSED,
  targetRole: TargetRole.SUBAGENT,
  targetPath: ".codex/agents/5.1-Beast-adjusted.toml",
});
const INSTRUCTION_RECORD = record({
  sourcePath: ".github/instructions/python-code-change.instructions.md",
  sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
  conversionClass: ConversionClass.DECOMPOSED,
  targetRole: TargetRole.SHARED_SKILL,
  targetPath: ".agents/skills/python-code-change/SKILL.md",
});

const TOPOLOGY_EDGES: ReadonlyArray<TopologyEdge> = [
  {
    sourcePath: ".github/copilot-instructions.md",
    destinationPath: "AGENTS.md",
  },
  {
    sourcePath: ".github/agents/5.1-Beast-adjusted.agent.md",
    destinationPath: ".codex/agents/5.1-Beast-adjusted.toml",
  },
  {
    sourcePath: ".github/agents/5.1-Beast-adjusted.agent.md",
    destinationPath: "AGENTS.md",
  },
  {
    sourcePath: ".github/agents/5.1-Beast-adjusted.agent.md",
    destinationPath: ".agents/skills/python-code-change/SKILL.md",
  },
  {
    sourcePath: ".github/instructions/python-code-change.instructions.md",
    destinationPath: ".agents/skills/python-code-change/SKILL.md",
  },
];

const TRACE: TranslationTrace = {
  sourcePath: ".github/agents/5.1-Beast-adjusted.agent.md",
  sectionId: ".github/agents/5.1-Beast-adjusted.agent.md#workflow",
  heading: "Workflow",
  intentKind: SectionIntentKind.SHARED_WORKFLOW,
  targetRole: TargetRole.SHARED_SKILL,
  targetPath: ".agents/skills/python-code-change/SKILL.md",
  notes: [],
};

describe("renderConversionReport", () => {
  it("includes three Mermaid topology charts before the mapping table", () => {
    // Arrange
    const reportText = renderConversionReport(
      runOptions(),
      [STANDING_RECORD, AGENT_RECORD, INSTRUCTION_RECORD],
      TOPOLOGY_EDGES,
      [TRACE],
      [],
    );

    // Act
    const mermaidCount = reportText.split("```mermaid").length - 1;

    // Assert
    expect(reportText).toContain("## Mapping Topology");
    expect(reportText).toContain("### Shared Destination Nodes");
    expect(reportText).toContain("### Repeated Destination Nodes");
    expect(reportText).toContain("### Repeated Source Nodes");
    expect(reportText).toContain("## Section Mappings");
    expect(mermaidCount).toBe(3);
    expect(reportText).toContain(".github/agents/5.1-Beast-adjusted.agent.md");
    expect(reportText).toContain(".codex/agents/5.1-Beast-adjusted.toml");
  });

  it("renders the run summary header lines verbatim", () => {
    // Arrange
    const finding: ValidationFinding = {
      code: "unsupported-source",
      severity: "error",
      blocking: true,
      sourcePath: ".github/copilot-instructions.md",
      targetPath: null,
      message: "Source is unsupported.",
      recommendedAction: "Remove the source.",
    };

    // Act
    const reportText = renderConversionReport(
      runOptions({ destinationRoot: "fixtures/dest", mode: "apply" }),
      [STANDING_RECORD],
      [],
      [],
      [finding],
    );

    // Assert
    expect(reportText).toContain("# Conversion Report");
    expect(reportText).toContain("- Mode: `apply`");
    expect(reportText).toContain("- Source ecosystem: `github-copilot`");
    expect(reportText).toContain("- Source root: `fixtures/source`");
    expect(reportText).toContain("- Destination root: `fixtures/dest`");
    expect(reportText).toContain("- Artifact root: `fixtures/artifacts`");
    expect(reportText).toContain("- Mapping records: 1");
    expect(reportText).toContain("- Validation findings: 1 (1 blocking)");
    expect(reportText).toContain(
      "- `unsupported-source`: Source is unsupported.",
    );
  });

  it("renders review-only destination and empty sections placeholders", () => {
    // Arrange & Act
    const reportText = renderConversionReport(runOptions(), [], [], [], []);

    // Assert
    expect(reportText).toContain("- Destination root: `review-only`");
    expect(reportText).toContain("## Section Mappings\n\n- None");
    expect(reportText).toContain("## Validation Findings\n\n- None");
    expect(reportText.endsWith("\n")).toBe(true);
  });

  it("joins multiple notes with <br> in the mapping table", () => {
    // Arrange
    const noted = record({
      sourcePath: "a.md",
      notes: ["first note", "second note"],
    });

    // Act
    const reportText = renderConversionReport(
      runOptions(),
      [noted],
      [],
      [],
      [],
    );

    // Assert
    expect(reportText).toContain("first note<br>second note");
  });
});

describe("writeConversionReportSet", () => {
  let fileSystem: InMemoryFileSystem;

  beforeEach(() => {
    fileSystem = new InMemoryFileSystem();
  });

  it("writes the report, catalogs, and proposed tree at stable paths", () => {
    // Arrange
    const generatedOutput = {
      "AGENTS.md": "merged guidance\n",
      ".codex/agents/5.1-Beast-adjusted.toml": "toml content\n",
    };

    // Act
    const reportPaths = writeConversionReportSet(
      fileSystem,
      runOptions(),
      [STANDING_RECORD, AGENT_RECORD],
      TOPOLOGY_EDGES,
      [TRACE],
      [],
      generatedOutput,
    );

    // Assert
    expect(reportPaths.conversionReport).toBe(
      "fixtures/artifacts/conversion-report.md",
    );
    expect(reportPaths.mappingCatalog).toBe(
      "fixtures/artifacts/mapping-catalog.json",
    );
    expect(reportPaths.validationResults).toBe(
      "fixtures/artifacts/validation-results.json",
    );
    expect(reportPaths.proposedTreeRoot).toBe(
      "fixtures/artifacts/proposed-tree",
    );
    expect(fileSystem.isFile(reportPaths.conversionReport)).toBe(true);
    expect(
      fileSystem.isFile("fixtures/artifacts/proposed-tree/AGENTS.md"),
    ).toBe(true);
    expect(
      fileSystem.isFile(
        "fixtures/artifacts/proposed-tree/.codex/agents/5.1-Beast-adjusted.toml",
      ),
    ).toBe(true);
  });

  it("collapses relative segments and a drive prefix in the artifact root", () => {
    // Arrange & Act
    const reportPaths = writeConversionReportSet(
      fileSystem,
      runOptions({ artifactRoot: "C:/repo/./out/../artifacts" }),
      [STANDING_RECORD],
      [],
      [],
      [],
      {},
    );

    // Assert: `.` is dropped, `..` pops a segment, and the drive prefix stays.
    expect(reportPaths.conversionReport).toBe(
      "C:/repo/artifacts/conversion-report.md",
    );
    expect(reportPaths.proposedTreeRoot).toBe(
      "C:/repo/artifacts/proposed-tree",
    );
  });

  it("collapses an absolute POSIX artifact root", () => {
    // Arrange & Act
    const reportPaths = writeConversionReportSet(
      fileSystem,
      runOptions({ artifactRoot: "/repo/out/../artifacts" }),
      [STANDING_RECORD],
      [],
      [],
      [],
      {},
    );

    // Assert: leading slash is preserved and `..` collapses one segment.
    expect(reportPaths.conversionReport).toBe(
      "/repo/artifacts/conversion-report.md",
    );
  });

  it("resolves an empty artifact root to root-relative artifact paths", () => {
    // Arrange & Act
    const reportPaths = writeConversionReportSet(
      fileSystem,
      runOptions({ artifactRoot: "" }),
      [STANDING_RECORD],
      [],
      [],
      [],
      {},
    );

    // Assert: an empty root yields bare artifact filenames.
    expect(reportPaths.conversionReport).toBe("conversion-report.md");
    expect(reportPaths.proposedTreeRoot).toBe("proposed-tree");
  });

  it("creates the artifact and proposed-tree directories", () => {
    // Arrange & Act
    writeConversionReportSet(
      fileSystem,
      runOptions(),
      [STANDING_RECORD],
      [],
      [],
      [],
      {},
    );

    // Assert
    expect(fileSystem.ensuredDirs).toContain("fixtures/artifacts");
    expect(fileSystem.ensuredDirs).toContain(
      "fixtures/artifacts/proposed-tree",
    );
  });

  it("serializes the mapping catalog with sorted keys and trailing newline", () => {
    // Arrange & Act
    writeConversionReportSet(
      fileSystem,
      runOptions(),
      [AGENT_RECORD, STANDING_RECORD],
      [],
      [],
      [],
      {},
    );

    // Assert
    const catalog = fileSystem.readTextFile(
      "fixtures/artifacts/mapping-catalog.json",
    );
    expect(catalog.endsWith("\n")).toBe(true);
    const parsed = JSON.parse(catalog) as Array<{ source_path: string }>;
    // Records are emitted in sorted source-path order.
    expect(parsed[0]?.source_path).toBe(
      ".github/agents/5.1-Beast-adjusted.agent.md",
    );
    expect(parsed[1]?.source_path).toBe(".github/copilot-instructions.md");
    // Object keys are alphabetically sorted to match Python `sort_keys=True`.
    const firstKeys = Object.keys(parsed[0] as Record<string, unknown>);
    expect(firstKeys).toEqual([...firstKeys].sort());
  });

  it("serializes validation results sorted by code", () => {
    // Arrange
    const findings: ReadonlyArray<ValidationFinding> = [
      {
        code: "z-finding",
        severity: "warning",
        blocking: false,
        sourcePath: null,
        targetPath: null,
        message: "z",
        recommendedAction: "",
      },
      {
        code: "a-finding",
        severity: "error",
        blocking: true,
        sourcePath: null,
        targetPath: null,
        message: "a",
        recommendedAction: "",
      },
    ];

    // Act
    writeConversionReportSet(
      fileSystem,
      runOptions(),
      [],
      [],
      [],
      findings,
      {},
    );

    // Assert
    const results = fileSystem.readTextFile(
      "fixtures/artifacts/validation-results.json",
    );
    const parsed = JSON.parse(results) as Array<{ code: string }>;
    expect(parsed[0]?.code).toBe("a-finding");
    expect(parsed[1]?.code).toBe("z-finding");
  });
});
