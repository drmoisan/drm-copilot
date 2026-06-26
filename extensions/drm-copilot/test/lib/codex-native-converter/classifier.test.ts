import { beforeEach, describe, expect, it } from "@jest/globals";

import { classifySourceArtifact } from "../../../src/lib/codex-native-converter/classifier";
import {
  ConversionClass,
  SourceEcosystem,
  SourceKind,
  TargetRole,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo";

function seed(fs: InMemoryFileSystem): void {
  // GitHub Copilot surfaces.
  fs.addFile(`${SOURCE_ROOT}/.github/copilot-instructions.md`, "standing");
  fs.addFile(
    `${SOURCE_ROOT}/.github/instructions/repo-wide.instructions.md`,
    'applyTo: "**"\n\nrule text',
  );
  fs.addFile(
    `${SOURCE_ROOT}/.github/instructions/path-scoped.instructions.md`,
    "applyTo: src/**\n\nrule text",
  );
  fs.addFile(`${SOURCE_ROOT}/.github/skills/README.md`, "index");
  fs.addFile(`${SOURCE_ROOT}/.github/skills/review/SKILL.md`, "skill");
  fs.addFile(
    `${SOURCE_ROOT}/.github/agents/handoff.agent.md`,
    "This agent uses handoff semantics.",
  );
  fs.addFile(`${SOURCE_ROOT}/.github/agents/plain.agent.md`, "plain agent");
  fs.addFile(`${SOURCE_ROOT}/.github/prompts/launch.prompt.md`, "prompt");
  fs.addFile(`${SOURCE_ROOT}/.github/prompts/template.md`, "template");
  fs.addFile(`${SOURCE_ROOT}/.github/unknown/file.md`, "unknown");

  // Claude surfaces.
  fs.addFile(`${SOURCE_ROOT}/CLAUDE.md`, "standing");
  fs.addFile(`${SOURCE_ROOT}/.claude/skills/research/SKILL.md`, "skill");
  fs.addFile(
    `${SOURCE_ROOT}/.claude/agents/orchestrator.md`,
    "This agent has handoff semantics.",
  );
  fs.addFile(`${SOURCE_ROOT}/.claude/agents/plain.md`, "plain");
  fs.addFile(`${SOURCE_ROOT}/.claude/hooks/pre-session.ps1`, "hook");
  fs.addFile(`${SOURCE_ROOT}/.claude/settings.json`, "{}");
  fs.addFile(
    `${SOURCE_ROOT}/.claude/rules/repo-wide.md`,
    'paths:\n  - "**"\n\nrule',
  );
  fs.addFile(
    `${SOURCE_ROOT}/.claude/rules/path-scoped.md`,
    "paths:\n  - src/**\n\nrule",
  );
  fs.addFile(`${SOURCE_ROOT}/.claude/unknown.txt`, "unknown");
}

interface MatrixCase {
  readonly ecosystem: SourceEcosystem;
  readonly path: string;
  readonly kind: SourceKind;
  readonly conversionClass: ConversionClass;
  readonly targetRole: TargetRole;
  readonly isRequired: boolean;
}

const GITHUB_CASES: ReadonlyArray<MatrixCase> = [
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/copilot-instructions.md",
    kind: SourceKind.STANDING_INSTRUCTION,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.STANDING_GUIDANCE,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/instructions/repo-wide.instructions.md",
    kind: SourceKind.PATH_SCOPED_INSTRUCTION,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.STANDING_GUIDANCE,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/instructions/path-scoped.instructions.md",
    kind: SourceKind.PATH_SCOPED_INSTRUCTION,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.SHARED_SKILL,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/skills/README.md",
    kind: SourceKind.UNKNOWN,
    conversionClass: ConversionClass.UNSUPPORTED,
    targetRole: TargetRole.UNSUPPORTED,
    isRequired: false,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/skills/review/SKILL.md",
    kind: SourceKind.REUSABLE_SKILL,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.SHARED_SKILL,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/agents/plain.agent.md",
    kind: SourceKind.AGENT_MANIFEST,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.SUBAGENT,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/prompts/launch.prompt.md",
    kind: SourceKind.LAUNCHER_PROMPT,
    conversionClass: ConversionClass.REPO_CONVENTION,
    targetRole: TargetRole.LAUNCHER,
    isRequired: false,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/prompts/template.md",
    kind: SourceKind.LAUNCHER_PROMPT,
    conversionClass: ConversionClass.REPO_CONVENTION,
    targetRole: TargetRole.LAUNCHER,
    isRequired: false,
  },
  {
    ecosystem: SourceEcosystem.GITHUB_COPILOT,
    path: ".github/unknown/file.md",
    kind: SourceKind.UNKNOWN,
    conversionClass: ConversionClass.UNSUPPORTED,
    targetRole: TargetRole.UNSUPPORTED,
    isRequired: true,
  },
];

const CLAUDE_CASES: ReadonlyArray<MatrixCase> = [
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: "CLAUDE.md",
    kind: SourceKind.STANDING_INSTRUCTION,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.STANDING_GUIDANCE,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/skills/research/SKILL.md",
    kind: SourceKind.REUSABLE_SKILL,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.SHARED_SKILL,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/agents/plain.md",
    kind: SourceKind.AGENT_MANIFEST,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.SUBAGENT,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/hooks/pre-session.ps1",
    kind: SourceKind.HOOK_DEFINITION,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.HOOK,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/settings.json",
    kind: SourceKind.PERMISSIONS_OR_SETTINGS,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.MCP_CONFIG,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/rules/repo-wide.md",
    kind: SourceKind.PATH_SCOPED_INSTRUCTION,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.STANDING_GUIDANCE,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/rules/path-scoped.md",
    kind: SourceKind.PATH_SCOPED_INSTRUCTION,
    conversionClass: ConversionClass.DECOMPOSED,
    targetRole: TargetRole.SHARED_SKILL,
    isRequired: true,
  },
  {
    ecosystem: SourceEcosystem.CLAUDE,
    path: ".claude/unknown.txt",
    kind: SourceKind.UNKNOWN,
    conversionClass: ConversionClass.UNSUPPORTED,
    targetRole: TargetRole.UNSUPPORTED,
    isRequired: true,
  },
];

describe("classifySourceArtifact classification matrix", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
    seed(fs);
  });

  it.each([...GITHUB_CASES, ...CLAUDE_CASES])(
    "classifies $path as $kind / $conversionClass / $targetRole",
    (matrixCase) => {
      // Act
      const record = classifySourceArtifact(
        fs,
        SOURCE_ROOT,
        matrixCase.path,
        matrixCase.ecosystem,
      );

      // Assert
      expect(record.sourceKind).toBe(matrixCase.kind);
      expect(record.conversionClass).toBe(matrixCase.conversionClass);
      expect(record.targetRole).toBe(matrixCase.targetRole);
      expect(record.isRequired).toBe(matrixCase.isRequired);
    },
  );
});

describe("classifySourceArtifact notes and invariants", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
    seed(fs);
  });

  it("adds a repo-wide note for repo-wide github instructions", () => {
    const record = classifySourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/instructions/repo-wide.instructions.md",
      SourceEcosystem.GITHUB_COPILOT,
    );
    expect(
      record.notes.some((note) => note.toLowerCase().includes("repo-wide")),
    ).toBe(true);
  });

  it("adds a handoff note for github agent manifests with handoff semantics", () => {
    const record = classifySourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/agents/handoff.agent.md",
      SourceEcosystem.GITHUB_COPILOT,
    );
    expect(
      record.notes.some((note) => note.toLowerCase().includes("handoff")),
    ).toBe(true);
  });

  it("adds a handoff note for claude agent manifests with handoff semantics", () => {
    const record = classifySourceArtifact(
      fs,
      SOURCE_ROOT,
      ".claude/agents/orchestrator.md",
      SourceEcosystem.CLAUDE,
    );
    expect(
      record.notes.some((note) => note.toLowerCase().includes("handoff")),
    ).toBe(true);
  });

  it("adds a repo-wide note for repo-wide claude rules", () => {
    const record = classifySourceArtifact(
      fs,
      SOURCE_ROOT,
      ".claude/rules/repo-wide.md",
      SourceEcosystem.CLAUDE,
    );
    expect(
      record.notes.some((note) => note.toLowerCase().includes("repo-wide")),
    ).toBe(true);
  });

  it("invariant: classification is deterministic for identical inputs", () => {
    // A T1 classifier invariant: identical inputs must yield an identical record.
    const first = classifySourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/agents/handoff.agent.md",
      SourceEcosystem.GITHUB_COPILOT,
    );
    const second = classifySourceArtifact(
      fs,
      SOURCE_ROOT,
      ".github/agents/handoff.agent.md",
      SourceEcosystem.GITHUB_COPILOT,
    );
    expect(second).toEqual(first);
  });

  it("invariant: every matrix path yields exactly one record with a defined SourceKind", () => {
    // A T1 classifier invariant: every discovered path classifies to exactly
    // one MappingRecord whose SourceKind is one of the defined enum values.
    const definedKinds = new Set<string>(Object.values(SourceKind));
    for (const matrixCase of [...GITHUB_CASES, ...CLAUDE_CASES]) {
      const record = classifySourceArtifact(
        fs,
        SOURCE_ROOT,
        matrixCase.path,
        matrixCase.ecosystem,
      );
      expect(record.sourcePath).toBe(matrixCase.path);
      expect(definedKinds.has(record.sourceKind)).toBe(true);
    }
  });
});
