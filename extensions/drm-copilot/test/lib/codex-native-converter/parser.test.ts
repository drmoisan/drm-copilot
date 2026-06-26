import { beforeEach, describe, expect, it } from "@jest/globals";

import { parseSourceArtifact } from "../../../src/lib/codex-native-converter/parser";
import {
  SemanticCueKind,
  SourceEcosystem,
  SourceKind,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo";

const MIXED_PROMPT = [
  "---",
  "agent: orchestrator",
  'description: "Fixture prompt for parser tests"',
  "---",
  "# Mixed runtime prompt",
  "",
  "Intro text.",
  "",
  "## Hard Gate",
  "",
  "Execution MUST NOT begin until preflight passes.",
  "",
  "## Workflow",
  "",
  "1. discover",
  "2. classify",
  "3. report",
  "",
  "## Launch Template",
  "",
  "```bash",
  "npx run",
  "```",
].join("\n");

const SINGLE_SECTION_INSTRUCTION = [
  "---",
  'applyTo: "**"',
  "name: fixture-general-policy",
  "---",
  "## Fixture instruction",
  "",
  "Some instruction body.",
].join("\n");

describe("parseSourceArtifact", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
    fs.addFile(
      `${SOURCE_ROOT}/.github/prompts/mixed-runtime.prompt.md`,
      MIXED_PROMPT,
    );
    fs.addFile(
      `${SOURCE_ROOT}/.github/instructions/general.instructions.md`,
      SINGLE_SECTION_INSTRUCTION,
    );
  });

  it("parses frontmatter and heading-based sections from a mixed prompt", () => {
    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/mixed-runtime.prompt.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert
    expect(artifact.frontmatter.agent).toBe("orchestrator");
    expect(artifact.frontmatter.description).toBe(
      "Fixture prompt for parser tests",
    );
    expect(artifact.sections.map((section) => section.heading)).toEqual([
      "Mixed runtime prompt",
      "Hard Gate",
      "Workflow",
      "Launch Template",
    ]);
  });

  it("parses frontmatter and a single section deterministically", () => {
    // Act
    const first = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/instructions/general.instructions.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.PATH_SCOPED_INSTRUCTION,
    );
    const second = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/instructions/general.instructions.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.PATH_SCOPED_INSTRUCTION,
    );

    // Assert
    expect(second).toEqual(first);
    expect(first.frontmatter.applyTo).toBe("**");
    expect(first.frontmatter.name).toBe("fixture-general-policy");
    expect(first.sections).toHaveLength(1);
    expect(first.sections[0]?.heading).toBe("Fixture instruction");
  });

  it("attaches HEADING, FORBIDDEN_PATTERN, and NUMBERED_WORKFLOW cues", () => {
    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/mixed-runtime.prompt.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert: build heading -> cue-kind-set lookup.
    const cuesByHeading = new Map<string, Set<string>>();
    for (const section of artifact.sections) {
      cuesByHeading.set(
        section.heading,
        new Set(section.cues.map((cue) => cue.kind)),
      );
    }
    for (const [, kinds] of cuesByHeading) {
      expect(kinds.has(SemanticCueKind.HEADING)).toBe(true);
    }
    expect(
      cuesByHeading.get("Hard Gate")?.has(SemanticCueKind.FORBIDDEN_PATTERN),
    ).toBe(true);
    expect(
      cuesByHeading.get("Workflow")?.has(SemanticCueKind.NUMBERED_WORKFLOW),
    ).toBe(true);
  });

  it("treats a file with no headings as a single Body section with id #body-1", () => {
    // Arrange
    fs.addFile(
      `${SOURCE_ROOT}/.github/prompts/no-heading.md`,
      "Just prose, no headings here.",
    );

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/no-heading.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert
    expect(artifact.sections).toHaveLength(1);
    expect(artifact.sections[0]?.heading).toBe("Body");
    expect(artifact.sections[0]?.sectionId).toBe(
      ".github/prompts/no-heading.md#body-1",
    );
  });

  it("returns empty frontmatter when no frontmatter block is present", () => {
    // Arrange
    fs.addFile(`${SOURCE_ROOT}/.github/prompts/plain.md`, "# Title\n\nBody.");

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/plain.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert
    expect(artifact.frontmatter).toEqual({});
    expect(artifact.sections[0]?.heading).toBe("Title");
  });

  it("ignores an unterminated frontmatter block", () => {
    // Arrange: a leading --- with no closing boundary is not frontmatter.
    fs.addFile(
      `${SOURCE_ROOT}/.github/prompts/unterminated.md`,
      "---\nkey: value\n# Heading\n\nBody",
    );

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/unterminated.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert
    expect(artifact.frontmatter).toEqual({});
  });

  it("parses an empty file into a single empty Body section", () => {
    // Arrange
    fs.addFile(`${SOURCE_ROOT}/.github/prompts/empty.md`, "");

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/empty.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert: the no-heading fallback yields one Body section.
    expect(artifact.rawText).toBe("");
    expect(artifact.sections).toHaveLength(1);
    expect(artifact.sections[0]?.heading).toBe("Body");
  });

  it("skips frontmatter lines without a colon and detects hard-gate, launcher, and tool cues", () => {
    // Arrange: frontmatter has a no-colon line; body triggers multiple cues.
    const content = [
      "---",
      "mode: agent",
      "a-line-without-colon",
      "---",
      "# Required Tools",
      "",
      "You MUST use the approved tools: list before starting.",
      "Run via `npx run` and reference mcp__server__tool here.",
    ].join("\n");
    fs.addFile(`${SOURCE_ROOT}/.github/prompts/cues.md`, content);

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/cues.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert: no-colon line skipped; cues detected.
    expect(artifact.frontmatter).toEqual({ mode: "agent" });
    const kinds = new Set(
      (artifact.sections[0]?.cues ?? []).map((cue) => cue.kind),
    );
    expect(kinds.has(SemanticCueKind.HARD_GATE)).toBe(true);
    expect(kinds.has(SemanticCueKind.LAUNCHER_WRAPPER)).toBe(true);
    expect(kinds.has(SemanticCueKind.TOOL_REQUIREMENT)).toBe(true);
  });

  it("truncates a long launcher-wrapper cue value to 60 characters", () => {
    // Arrange: a fenced code block longer than 60 characters.
    const longCode = "x".repeat(120);
    const content = ["# Launch", "", "```", longCode, "```"].join("\n");
    fs.addFile(`${SOURCE_ROOT}/.github/prompts/long.md`, content);

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/long.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert
    const launcherCue = artifact.sections[0]?.cues.find(
      (cue) => cue.kind === SemanticCueKind.LAUNCHER_WRAPPER,
    );
    expect(launcherCue?.value.length).toBe(60);
  });

  it("skips an empty leading section before the first heading", () => {
    // Arrange: blank lines before the first heading must not create a section.
    fs.addFile(
      `${SOURCE_ROOT}/.github/prompts/leading-blank.md`,
      "\n\n# First\n\nBody text.",
    );

    // Act
    const artifact = parseSourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/prompts/leading-blank.md",
      SourceEcosystem.GITHUB_COPILOT,
      SourceKind.LAUNCHER_PROMPT,
    );

    // Assert
    expect(artifact.sections.map((section) => section.heading)).toEqual([
      "First",
    ]);
  });
});
