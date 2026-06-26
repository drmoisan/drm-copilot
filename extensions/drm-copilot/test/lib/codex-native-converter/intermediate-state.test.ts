import { beforeEach, describe, expect, it } from "@jest/globals";

import {
  type IntermediateState,
  writeIntermediateStateArtifacts,
} from "../../../src/lib/codex-native-converter/intermediate-state";
import {
  SectionIntentKind,
  SemanticCueKind,
  type SourceArtifact,
  SourceEcosystem,
  SourceKind,
  TargetRole,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const ARTIFACT_ROOT = "/repo/artifacts/codex-native-converter";

function emptyState(): IntermediateState {
  return {
    sourceArtifacts: [],
    sectionIntents: [],
    plannedEmissions: [],
    translationTraces: [],
  };
}

function populatedState(): IntermediateState {
  const artifact: SourceArtifact = {
    sourcePath: ".github/prompts/x.prompt.md",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind: SourceKind.LAUNCHER_PROMPT,
    frontmatter: { mode: "agent", applyTo: "**" },
    rawText: "raw",
    sections: [
      {
        sectionId: ".github/prompts/x.prompt.md#workflow-3",
        heading: "Workflow",
        level: 2,
        content: "1. do",
        startLine: 3,
        endLine: 4,
        cues: [{ kind: SemanticCueKind.HEADING, value: "Workflow" }],
      },
    ],
  };
  return {
    sourceArtifacts: [artifact],
    sectionIntents: [
      {
        sourcePath: ".github/prompts/x.prompt.md",
        sectionId: ".github/prompts/x.prompt.md#workflow-3",
        heading: "Workflow",
        intentKind: SectionIntentKind.SHARED_WORKFLOW,
        notes: ["note"],
      },
    ],
    plannedEmissions: [
      {
        sourcePath: ".github/prompts/x.prompt.md",
        sectionId: ".github/prompts/x.prompt.md#workflow-3",
        heading: "Workflow",
        intentKind: SectionIntentKind.SHARED_WORKFLOW,
        targetRole: TargetRole.SHARED_SKILL,
        targetPath: ".agents/skills/x/SKILL.md",
        notes: [],
      },
    ],
    translationTraces: [
      {
        sourcePath: ".github/prompts/x.prompt.md",
        sectionId: ".github/prompts/x.prompt.md#__launcher__",
        heading: "Launcher Surface",
        intentKind: SectionIntentKind.LAUNCHER_ONLY,
        targetRole: TargetRole.LAUNCHER,
        targetPath: null,
        notes: [],
      },
    ],
  };
}

describe("writeIntermediateStateArtifacts", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
  });

  it("creates the intermediate directory and writes exactly four named JSON files", () => {
    const paths = writeIntermediateStateArtifacts(
      fs,
      emptyState(),
      ARTIFACT_ROOT,
    );

    expect(paths).toEqual([
      `${ARTIFACT_ROOT}/intermediate/source-artifacts.json`,
      `${ARTIFACT_ROOT}/intermediate/section-intents.json`,
      `${ARTIFACT_ROOT}/intermediate/planned-emissions.json`,
      `${ARTIFACT_ROOT}/intermediate/translation-traces.json`,
    ]);
    expect(fs.ensuredDirs).toContain(`${ARTIFACT_ROOT}/intermediate`);
    for (const path of paths) {
      expect(JSON.parse(fs.readTextFile(path))).toEqual([]);
    }
  });

  it("serializes populated state with sorted keys and round-trips to the expected shapes", () => {
    const paths = writeIntermediateStateArtifacts(
      fs,
      populatedState(),
      ARTIFACT_ROOT,
    );

    const sourceArtifacts = JSON.parse(fs.readTextFile(paths[0])) as unknown[];
    expect(sourceArtifacts).toEqual([
      {
        frontmatter: { applyTo: "**", mode: "agent" },
        sections: [
          {
            cues: [{ kind: "heading", value: "Workflow" }],
            end_line: 4,
            heading: "Workflow",
            level: 2,
            section_id: ".github/prompts/x.prompt.md#workflow-3",
            start_line: 3,
          },
        ],
        source_ecosystem: "github-copilot",
        source_kind: "launcher-prompt",
        source_path: ".github/prompts/x.prompt.md",
      },
    ]);

    const traces = JSON.parse(fs.readTextFile(paths[3])) as Array<{
      target_path: string | null;
    }>;
    expect(traces[0]?.target_path).toBeNull();
  });

  it("emits byte-identical JSON on successive calls with the same state (determinism)", () => {
    const state = populatedState();
    writeIntermediateStateArtifacts(fs, state, ARTIFACT_ROOT);
    const firstContents = [
      fs.readTextFile(`${ARTIFACT_ROOT}/intermediate/source-artifacts.json`),
      fs.readTextFile(`${ARTIFACT_ROOT}/intermediate/section-intents.json`),
    ];

    const secondFs = new InMemoryFileSystem();
    writeIntermediateStateArtifacts(secondFs, state, ARTIFACT_ROOT);
    const secondContents = [
      secondFs.readTextFile(
        `${ARTIFACT_ROOT}/intermediate/source-artifacts.json`,
      ),
      secondFs.readTextFile(
        `${ARTIFACT_ROOT}/intermediate/section-intents.json`,
      ),
    ];

    expect(secondContents).toEqual(firstContents);
    // Two-space indentation is used (matching json.dumps indent=2): the array
    // opens with a 2-space-indented object brace.
    expect(firstContents[0]).toContain("[\n  {");
  });
});
