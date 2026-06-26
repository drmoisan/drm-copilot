/**
 * Classify source artifacts for the Codex-native converter (github-copilot path
 * plus the public dispatcher and shared helpers).
 *
 * Purpose:
 *     Assign a deterministic source kind, conversion class, and target role to
 *     each supported source artifact before path mapping occurs. Ported from
 *     `classifier.py`; the claude classification path and section-level
 *     classification live in `classifier-claude.ts` so neither file exceeds the
 *     500-line policy.
 *
 * Invariants:
 *     Classification is deterministic and path-driven. Unsupported surfaces are
 *     marked explicitly rather than inferred. File reads flow through the
 *     injected {@link FileSystem}.
 */

import { type FileSystem } from "../file-system";
import {
  ConversionClass,
  type MappingRecord,
  SourceEcosystem,
  SourceKind,
  TargetRole,
} from "./models";
import { classifyClaude } from "./classifier-claude";

// Detect a repo-wide `applyTo: "**"` declaration in an instruction file.
const REPO_WIDE_APPLY_TO_PATTERN = /^applyTo:\s*(["'])?\*\*(?:\1)?\s*$/m;
// Detect a repo-wide YAML list-form `paths:` block whose only entry is `**`.
const REPO_WIDE_PATHS_PATTERN = /^paths:\s*\n\s*-\s*(["'])?\*\*(?:\1)?\s*$/m;

/**
 * Join a POSIX source root and a relative source path.
 *
 * @param sourceRoot POSIX source root.
 * @param sourcePath Source-root-relative POSIX path.
 * @returns The combined POSIX path.
 */
function joinSource(sourceRoot: string, sourcePath: string): string {
  const normalizedRoot = sourceRoot.replace(/\/+$/, "");
  const normalizedRelative = sourcePath.replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedRelative
    : `${normalizedRoot}/${normalizedRelative}`;
}

/**
 * Read source text when note generation requires content inspection.
 *
 * Mirrors `_read_optional_text`: returns the file's UTF-8 content, or an empty
 * string when the file cannot be read (Python catches `OSError`).
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root.
 * @param sourcePath Source-root-relative POSIX path to inspect.
 * @returns The file content, or an empty string on read failure.
 */
export function readOptionalText(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
): string {
  try {
    return fileSystem.readTextFile(joinSource(sourceRoot, sourcePath));
  } catch {
    // A missing or unreadable file yields empty text rather than raising,
    // matching the Python OSError -> "" behavior.
    return "";
  }
}

/**
 * Determine whether one instruction file applies repo-wide.
 *
 * Mirrors `_has_repo_wide_apply_to`.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root.
 * @param sourcePath Source-root-relative POSIX path to inspect.
 * @returns True when the instruction declares `applyTo: "**"`.
 */
function hasRepoWideApplyTo(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
): boolean {
  return REPO_WIDE_APPLY_TO_PATTERN.test(
    readOptionalText(fileSystem, sourceRoot, sourcePath),
  );
}

/**
 * Determine whether one rule file declares repo-wide YAML `paths` scope.
 *
 * Mirrors `_has_repo_wide_paths_yaml`.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root.
 * @param sourcePath Source-root-relative POSIX path to inspect.
 * @returns True when the rule declares a list-form `paths:` block whose only
 *   entry is `**`.
 */
export function hasRepoWidePathsYaml(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
): boolean {
  return REPO_WIDE_PATHS_PATTERN.test(
    readOptionalText(fileSystem, sourceRoot, sourcePath),
  );
}

/**
 * Classify one GitHub Copilot source artifact.
 *
 * Mirrors `_classify_github_copilot`, preserving every `SourceKind`,
 * `ConversionClass`, `TargetRole`, note string, and branch ordering verbatim.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root that bounds the artifact.
 * @param sourcePath Source-root-relative artifact path.
 * @returns The classification result with an unresolved target path.
 */
function classifyGithubCopilot(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
): MappingRecord {
  const pathText = sourcePath;
  const notes: string[] = [];

  if (pathText === ".github/copilot-instructions.md") {
    return {
      sourcePath: pathText,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.STANDING_INSTRUCTION,
      conversionClass: ConversionClass.DIRECT,
      targetRole: TargetRole.STANDING_GUIDANCE,
      targetPath: null,
      notes: [],
      isRequired: true,
    };
  }

  if (
    pathText.startsWith(".github/instructions/") &&
    pathText.endsWith(".instructions.md")
  ) {
    // Repo-wide instructions merge into standing guidance; path-scoped ones
    // decompose into shared skills.
    if (hasRepoWideApplyTo(fileSystem, sourceRoot, sourcePath)) {
      return {
        sourcePath: pathText,
        sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
        sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
        conversionClass: ConversionClass.DECOMPOSED,
        targetRole: TargetRole.STANDING_GUIDANCE,
        targetPath: null,
        notes: [
          "Repo-wide instruction applies to all files and merges into " +
            "standing guidance.",
        ],
        isRequired: true,
      };
    }
    return {
      sourcePath: pathText,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
      conversionClass: ConversionClass.DECOMPOSED,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath: null,
      notes: [
        "Path-scoped instruction requires decomposition into shared " +
          "skills or standing guidance.",
      ],
      isRequired: true,
    };
  }

  if (pathText === ".github/skills/README.md") {
    return {
      sourcePath: pathText,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.UNKNOWN,
      conversionClass: ConversionClass.UNSUPPORTED,
      targetRole: TargetRole.UNSUPPORTED,
      targetPath: null,
      notes: [
        "Skills index documentation has no native runtime surface in v1.",
      ],
      isRequired: false,
    };
  }

  if (
    pathText.includes("/SKILL.md") &&
    pathText.startsWith(".github/skills/")
  ) {
    return {
      sourcePath: pathText,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.REUSABLE_SKILL,
      conversionClass: ConversionClass.DIRECT,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath: null,
      notes: [],
      isRequired: true,
    };
  }

  if (
    pathText.startsWith(".github/agents/") &&
    pathText.endsWith(".agent.md")
  ) {
    const sourceText = readOptionalText(fileSystem, sourceRoot, sourcePath);
    if (
      sourceText.toLowerCase().includes("handoff") ||
      sourceText.toLowerCase().includes("handoffs:")
    ) {
      notes.push(
        "Agent manifest contains handoff semantics that require " +
          "validation before apply mode.",
      );
    }
    return {
      sourcePath: pathText,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.AGENT_MANIFEST,
      conversionClass: ConversionClass.DECOMPOSED,
      targetRole: TargetRole.SUBAGENT,
      targetPath: null,
      notes,
      isRequired: true,
    };
  }

  if (pathText.startsWith(".github/prompts/") && pathText.endsWith(".md")) {
    return {
      sourcePath: pathText,
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.LAUNCHER_PROMPT,
      conversionClass: ConversionClass.REPO_CONVENTION,
      targetRole: TargetRole.LAUNCHER,
      targetPath: null,
      notes: [
        "Launcher prompts map only to the repository-convention " +
          ".codex/prompts surface when explicitly enabled.",
      ],
      isRequired: false,
    };
  }

  return {
    sourcePath: pathText,
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind: SourceKind.UNKNOWN,
    conversionClass: ConversionClass.UNSUPPORTED,
    targetRole: TargetRole.UNSUPPORTED,
    targetPath: null,
    notes: [
      "No supported GitHub Copilot v1 mapping rule matched this artifact.",
    ],
    isRequired: true,
  };
}

/**
 * Classify one source artifact into conversion and target taxonomy.
 *
 * Mirrors `classify_source_artifact`: routes by ecosystem to the github-copilot
 * or claude classification path.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX root directory that bounds the source artifact.
 * @param sourcePath Source-root-relative artifact path.
 * @param sourceEcosystem Declared source ecosystem.
 * @returns Classification details for the source artifact with an unresolved
 *   target path.
 */
export function classifySourceArtifact(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
  sourceEcosystem: SourceEcosystem,
): MappingRecord {
  if (sourceEcosystem === SourceEcosystem.GITHUB_COPILOT) {
    return classifyGithubCopilot(fileSystem, sourceRoot, sourcePath);
  }
  return classifyClaude(fileSystem, sourceRoot, sourcePath);
}

export { classifyPromptSections } from "./classifier-claude";
