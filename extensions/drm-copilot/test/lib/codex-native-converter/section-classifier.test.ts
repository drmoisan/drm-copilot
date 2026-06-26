import { describe, expect, it } from "@jest/globals";

import { classifyPromptSections } from "../../../src/lib/codex-native-converter/classifier";
import {
  SectionIntentKind,
  type SourceArtifact,
  SourceEcosystem,
  SourceKind,
  type SourceSection,
} from "../../../src/lib/codex-native-converter/models";

function section(
  heading: string,
  content: string,
  startLine: number,
): SourceSection {
  return {
    sectionId: `.github/prompts/mixed.prompt.md#${heading.toLowerCase().replace(/[^a-z0-9]+/g, "-")}-${startLine}`,
    heading,
    level: 2,
    content,
    startLine,
    endLine: startLine + 2,
    cues: [],
  };
}

function promptArtifact(
  sections: ReadonlyArray<SourceSection>,
  sourceKind: SourceKind = SourceKind.LAUNCHER_PROMPT,
): SourceArtifact {
  return {
    sourcePath: ".github/prompts/mixed.prompt.md",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind,
    frontmatter: {},
    rawText: "raw",
    sections,
  };
}

describe("classifyPromptSections", () => {
  it("classifies enforcement sections as hook candidates and workflow sections as shared workflows", () => {
    // Arrange
    const artifact = promptArtifact([
      section(
        "Hard Gate",
        "Execution MUST NOT begin until preflight passes.",
        1,
      ),
      section("Workflow", "1. discover\n2. classify\n3. report", 5),
    ]);

    // Act
    const intents = classifyPromptSections(artifact);

    // Assert
    expect(
      intents.some(
        (intent) =>
          intent.heading === "Hard Gate" &&
          intent.intentKind === SectionIntentKind.HOOK_CANDIDATE,
      ),
    ).toBe(true);
    expect(
      intents.some(
        (intent) =>
          intent.heading === "Workflow" &&
          intent.intentKind === SectionIntentKind.SHARED_WORKFLOW,
      ),
    ).toBe(true);
  });

  it("classifies a workflow by heading keyword even without numbered steps", () => {
    // Arrange
    const artifact = promptArtifact([
      section("Output Format", "Return a JSON object.", 1),
    ]);

    // Act
    const intents = classifyPromptSections(artifact);

    // Assert
    expect(intents).toHaveLength(1);
    expect(intents[0]?.intentKind).toBe(SectionIntentKind.SHARED_WORKFLOW);
  });

  it("skips sections that match neither enforcement nor workflow signals", () => {
    // Arrange
    const artifact = promptArtifact([
      section("Background", "Some neutral prose without signals.", 1),
    ]);

    // Act
    const intents = classifyPromptSections(artifact);

    // Assert: an unmatched section is dropped, mirroring the Python continue.
    expect(intents).toEqual([]);
  });

  it("returns an empty list when the source kind is not a launcher prompt", () => {
    // Arrange
    const artifact = promptArtifact(
      [section("Workflow", "1. a\n2. b", 1)],
      SourceKind.REUSABLE_SKILL,
    );

    // Act
    const intents = classifyPromptSections(artifact);

    // Assert
    expect(intents).toEqual([]);
  });
});
