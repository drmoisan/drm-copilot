import { beforeEach, describe, expect, it } from "@jest/globals";

import {
  discoverSourceArtifacts,
  normalizeSelectedPaths,
} from "../../../src/lib/codex-native-converter/inventory";
import { SourceEcosystem } from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo";

function seedGithubTree(fs: InMemoryFileSystem): void {
  fs.addFile(`${SOURCE_ROOT}/.github/copilot-instructions.md`, "instructions");
  fs.addFile(
    `${SOURCE_ROOT}/.github/instructions/general-code-change.instructions.md`,
    "rule",
  );
  fs.addFile(`${SOURCE_ROOT}/.github/skills/review-workflow/SKILL.md`, "skill");
  fs.addFile(`${SOURCE_ROOT}/.github/agents/orchestrator.agent.md`, "agent");
  fs.addFile(`${SOURCE_ROOT}/.github/agents/beast-topology.agent.md`, "agent");
  fs.addFile(
    `${SOURCE_ROOT}/.github/prompts/launch-review.prompt.md`,
    "prompt",
  );
  fs.addFile(
    `${SOURCE_ROOT}/.github/prompts/mixed-runtime.prompt.md`,
    "prompt",
  );
  // An unsupported directory must not be discovered.
  fs.addFile(`${SOURCE_ROOT}/docs/readme.md`, "doc");
}

function seedClaudeTree(fs: InMemoryFileSystem): void {
  fs.addFile(`${SOURCE_ROOT}/CLAUDE.md`, "standing");
  fs.addFile(`${SOURCE_ROOT}/.claude/skills/research/SKILL.md`, "skill");
  fs.addFile(`${SOURCE_ROOT}/.claude/agents/atomic-executor.md`, "agent");
  fs.addFile(`${SOURCE_ROOT}/.claude/hooks/pre-claude-session.ps1`, "hook");
  fs.addFile(`${SOURCE_ROOT}/.claude/settings.json`, "{}");
  fs.addFile(`${SOURCE_ROOT}/.claude/rules/typescript.md`, "rule");
}

describe("discoverSourceArtifacts", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
  });

  it("returns supported github-copilot artifacts in normalized path order", () => {
    // Arrange
    seedGithubTree(fs);

    // Act
    const discovered = discoverSourceArtifacts(
      fs,
      SOURCE_ROOT,
      SourceEcosystem.GITHUB_COPILOT,
    );

    // Assert
    expect(discovered).toEqual([
      ".github/agents/beast-topology.agent.md",
      ".github/agents/orchestrator.agent.md",
      ".github/copilot-instructions.md",
      ".github/instructions/general-code-change.instructions.md",
      ".github/prompts/launch-review.prompt.md",
      ".github/prompts/mixed-runtime.prompt.md",
      ".github/skills/review-workflow/SKILL.md",
    ]);
  });

  it("returns supported claude artifacts in normalized path order", () => {
    // Arrange
    seedClaudeTree(fs);

    // Act
    const discovered = discoverSourceArtifacts(
      fs,
      SOURCE_ROOT,
      SourceEcosystem.CLAUDE,
    );

    // Assert
    expect(discovered).toEqual([
      ".claude/agents/atomic-executor.md",
      ".claude/hooks/pre-claude-session.ps1",
      ".claude/rules/typescript.md",
      ".claude/settings.json",
      ".claude/skills/research/SKILL.md",
      "CLAUDE.md",
    ]);
  });

  it("filters to files directly selected and files beneath selected directories", () => {
    // Arrange
    seedGithubTree(fs);

    // Act
    const discovered = discoverSourceArtifacts(
      fs,
      SOURCE_ROOT,
      SourceEcosystem.GITHUB_COPILOT,
      [".github/agents", ".github/copilot-instructions.md"],
    );

    // Assert: both agents (under the dir) plus the directly-selected file.
    expect(discovered).toEqual([
      ".github/agents/beast-topology.agent.md",
      ".github/agents/orchestrator.agent.md",
      ".github/copilot-instructions.md",
    ]);
  });

  it("returns all artifacts when the selection normalizes to empty", () => {
    // Arrange
    seedGithubTree(fs);

    // Act: an empty selection means no filter is applied.
    const discovered = discoverSourceArtifacts(
      fs,
      SOURCE_ROOT,
      SourceEcosystem.GITHUB_COPILOT,
      [],
    );

    // Assert
    expect(discovered.length).toBe(7);
  });

  it("returns an empty list for an empty source root", () => {
    // Arrange: no files seeded.

    // Act
    const discovered = discoverSourceArtifacts(
      fs,
      SOURCE_ROOT,
      SourceEcosystem.GITHUB_COPILOT,
    );

    // Assert
    expect(discovered).toEqual([]);
  });
});

describe("normalizeSelectedPaths", () => {
  it("throws with the exact escape-root message when a path escapes the source root", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    seedGithubTree(fs);

    // Act / Assert
    expect(() =>
      normalizeSelectedPaths(SOURCE_ROOT, ["../outside.md"]),
    ).toThrow("Selected path escapes the declared source root: ../outside.md");
  });

  it("normalizes and sorts unique relative paths beneath the root", () => {
    // Act
    const normalized = normalizeSelectedPaths(SOURCE_ROOT, [
      ".github/prompts",
      ".github/agents",
      ".github/agents",
    ]);

    // Assert: deduplicated and sorted by POSIX text.
    expect(normalized).toEqual([".github/agents", ".github/prompts"]);
  });
});
