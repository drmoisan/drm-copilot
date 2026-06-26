import { describe, expect, it } from "@jest/globals";

import { classifySectionIntent } from "../../../src/lib/codex-native-converter/section-intent";
import {
  SectionIntentKind,
  type SemanticCue,
  SemanticCueKind,
  type SourceArtifact,
  SourceEcosystem,
  SourceKind,
  type SourceSection,
} from "../../../src/lib/codex-native-converter/models";

function makeSection(
  heading: string,
  cues: ReadonlyArray<SemanticCue>,
  content = "",
): SourceSection {
  const stem = heading.toLowerCase().replace(/ /g, "-") || "body";
  return {
    sectionId: `fixture.md#${stem}-1`,
    heading,
    level: 2,
    content,
    startLine: 1,
    endLine: Math.max(1, content.split("\n").length),
    cues,
  };
}

function makeArtifact(
  sourceKind: SourceKind = SourceKind.STANDING_INSTRUCTION,
): SourceArtifact {
  return {
    sourcePath: "fixture.md",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind,
    frontmatter: {},
    rawText: "",
    sections: [],
  };
}

const headingCue: SemanticCue = {
  kind: SemanticCueKind.HEADING,
  value: "h",
};

describe("classifySectionIntent", () => {
  it("returns launcher_only for a launcher-prompt section with only a launcher-wrapper cue", () => {
    const section = makeSection("Launch", [
      { kind: SemanticCueKind.LAUNCHER_WRAPPER, value: "npx run" },
    ]);
    const intent = classifySectionIntent(
      section,
      makeArtifact(SourceKind.LAUNCHER_PROMPT),
    );
    expect(intent.intentKind).toBe(SectionIntentKind.LAUNCHER_ONLY);
  });

  it("returns hook_candidate for hard-gate cues", () => {
    const section = makeSection("Hard Gate", [
      headingCue,
      { kind: SemanticCueKind.HARD_GATE, value: "you MUST" },
    ]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.HOOK_CANDIDATE);
  });

  it("returns hook_candidate for forbidden-pattern cues", () => {
    const section = makeSection("Constraints", [
      { kind: SemanticCueKind.FORBIDDEN_PATTERN, value: "MUST NOT" },
    ]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.HOOK_CANDIDATE);
  });

  it("returns shared_workflow for numbered-workflow cues", () => {
    const section = makeSection("Steps", [
      { kind: SemanticCueKind.NUMBERED_WORKFLOW, value: "1." },
    ]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.SHARED_WORKFLOW);
  });

  it("returns config_candidate for tool-requirement cue with a config heading", () => {
    const section = makeSection("Config", [
      { kind: SemanticCueKind.TOOL_REQUIREMENT, value: "tools:" },
    ]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.CONFIG_CANDIDATE);
  });

  it("returns rule_candidate for tool-requirement cue with a rule heading", () => {
    const section = makeSection("Policy", [
      { kind: SemanticCueKind.TOOL_REQUIREMENT, value: "tools:" },
    ]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.RULE_CANDIDATE);
  });

  it("returns rule_candidate for a rule heading without tool requirements", () => {
    const section = makeSection("Convention", [headingCue]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.RULE_CANDIDATE);
  });

  it("returns config_candidate for a config heading without tool requirements", () => {
    const section = makeSection("Environment", [headingCue]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.CONFIG_CANDIDATE);
  });

  it("returns identity for an identity heading", () => {
    const section = makeSection("Overview", [headingCue]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.IDENTITY);
  });

  it("returns standing_guidance for a plain headed section", () => {
    const section = makeSection("Agent Behavior", [headingCue]);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.STANDING_GUIDANCE);
    expect(intent.sourcePath).toBe("fixture.md");
    expect(intent.notes.length).toBeGreaterThan(0);
  });

  it("returns unsupported for a section with no heading cue and no signals", () => {
    // An empty-heading section with no cues falls through to unsupported.
    const section = makeSection("", []);
    const intent = classifySectionIntent(section, makeArtifact());
    expect(intent.intentKind).toBe(SectionIntentKind.UNSUPPORTED);
  });
});
