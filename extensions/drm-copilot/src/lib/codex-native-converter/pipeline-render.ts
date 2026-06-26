/**
 * Native content rendering for the Codex-native converter pipeline.
 *
 * Purpose:
 *     Hold the content-rendering half of the pipeline (per-record, merged
 *     standing-guidance, and section-level emission rendering) ported from
 *     `pipeline.py`, split out of `pipeline.ts` so neither file exceeds the
 *     500-line policy. Source reads flow through the injected {@link FileSystem}.
 *
 * Invariants:
 *     Rendered content text is preserved verbatim from the Python source. This
 *     module does not import from `engine.ts` to avoid circular dependencies.
 */

import { type FileSystem } from "../file-system";
import {
  type MappingRecord,
  type PlannedEmission,
  type RunOptions,
  type SourceSection,
  TargetRole,
} from "./models";
import { rewriteSupportedAutomationReference } from "./rewrites";

/**
 * Read one source artifact from the source root through the filesystem.
 *
 * Mirrors `_read_source_text`.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source tree root.
 * @param sourcePath Source-root-relative artifact path.
 * @returns Source text decoded as UTF-8.
 * @throws Error When the source file cannot be read.
 */
function readSourceText(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
): string {
  const normalizedRoot = sourceRoot.replace(/\/+$/, "");
  const normalizedRelative = sourcePath.replace(/^\/+/, "");
  const absolute =
    normalizedRoot === ""
      ? normalizedRelative
      : `${normalizedRoot}/${normalizedRelative}`;
  return fileSystem.readTextFile(absolute);
}

/**
 * Return the final path segment (basename) of a POSIX path.
 *
 * @param posixPath POSIX path.
 * @returns The basename.
 */
function posixName(posixPath: string): string {
  const trimmed = posixPath.replace(/\/+$/, "");
  const index = trimmed.lastIndexOf("/");
  return index >= 0 ? trimmed.slice(index + 1) : trimmed;
}

/**
 * Return the stem (basename without final extension) of a POSIX path.
 *
 * @param posixPath POSIX path.
 * @returns The basename without its final extension.
 */
function posixStem(posixPath: string): string {
  const name = posixName(posixPath);
  const dot = name.lastIndexOf(".");
  return dot > 0 ? name.slice(0, dot) : name;
}

/**
 * Strip trailing whitespace, matching Python `str.rstrip()`.
 *
 * @param value Value to strip.
 * @returns The value without trailing whitespace.
 */
function rstrip(value: string): string {
  return value.replace(/\s+$/u, "");
}

/**
 * Rewrite one source text block and summarize applied rewrites.
 *
 * Mirrors `_rewrite_text`.
 *
 * @param runOptions Requested run options.
 * @param sourceText Text to rewrite.
 * @param standingGuidanceSourcePaths Standing-guidance source paths.
 * @returns The rewritten (rstripped) text and a Markdown rewrite summary.
 */
function rewriteText(
  runOptions: RunOptions,
  sourceText: string,
  standingGuidanceSourcePaths: ReadonlyArray<string>,
): [string, string] {
  const [rewrittenText, appliedRewrites] = rewriteSupportedAutomationReference(
    sourceText,
    {
      enableRepoPrompts: runOptions.enableRepoPrompts,
      standingGuidanceSourcePaths,
    },
  );
  const rewriteSummary =
    appliedRewrites.length > 0
      ? appliedRewrites.map((description) => `- ${description}`).join("\n")
      : "- None";
  return [rstrip(rewrittenText), rewriteSummary];
}

/**
 * Wrap rewritten text in the target-role-specific native output shape.
 *
 * Mirrors `_wrap_rendered_target_content`, preserving every literal template.
 *
 * @param options Target role/path, rewritten text, and rewrite summary.
 * @returns The wrapped native output text.
 */
function wrapRenderedTargetContent(options: {
  readonly targetRole: TargetRole;
  readonly targetPath: string | null;
  readonly rewrittenText: string;
  readonly rewriteSummary: string;
}): string {
  const { targetRole, targetPath, rewrittenText, rewriteSummary } = options;

  if (targetRole === TargetRole.STANDING_GUIDANCE) {
    return (
      "# Converted standing guidance\n\n" +
      `Applied rewrites:\n${rewriteSummary}\n\n` +
      `${rewrittenText}\n`
    );
  }

  if (targetRole === TargetRole.SHARED_SKILL) {
    return (
      "# Converted skill\n\n" +
      `Applied rewrites:\n${rewriteSummary}\n\n` +
      `${rewrittenText}\n`
    );
  }

  if (targetRole === TargetRole.SUBAGENT) {
    const agentName = posixStem(targetPath ?? "agent.toml");
    return (
      `name = "${agentName}"\n` +
      'description = "Converted subagent"\n' +
      "developer_instructions = '''\n" +
      `Applied rewrites:\n${rewriteSummary}\n\n` +
      `${rewrittenText}\n` +
      "'''\n"
    );
  }

  if (targetRole === TargetRole.MCP_CONFIG) {
    return (
      "# Review and merge native MCP, hook, and approval settings " +
      "intentionally.\n\n" +
      `${rewrittenText}\n`
    );
  }

  if (targetRole === TargetRole.HOOK) {
    return (
      "# Converted hook\n" +
      "# Review the generated hook behavior before enabling it.\n\n" +
      `${rewrittenText}\n`
    );
  }

  if (targetRole === TargetRole.APPROVAL_RULE) {
    return (
      "# Converted approval rule candidate\n" +
      "# Review the generated rule semantics before enforcement.\n\n" +
      `${rewrittenText}\n`
    );
  }

  if (targetRole === TargetRole.LAUNCHER) {
    return `# Converted launcher prompt\n\n${rewrittenText}\n`;
  }

  return `${rewrittenText}\n`;
}

/**
 * Render one generated target file for the mapping record.
 *
 * Mirrors `render_target_content`.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecord Planned mapping record.
 * @param standingGuidanceSourcePaths Standing-guidance source paths.
 * @returns Rendered output text for the target path.
 * @throws Error When the source file cannot be read.
 */
export function renderTargetContent(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecord: MappingRecord,
  standingGuidanceSourcePaths: ReadonlyArray<string>,
): string {
  const sourceText = readSourceText(
    fileSystem,
    runOptions.sourceRoot,
    mappingRecord.sourcePath,
  );
  const [rewrittenText, rewriteSummary] = rewriteText(
    runOptions,
    sourceText,
    standingGuidanceSourcePaths,
  );
  return wrapRenderedTargetContent({
    targetRole: mappingRecord.targetRole,
    targetPath: mappingRecord.targetPath,
    rewrittenText,
    rewriteSummary,
  });
}

/**
 * Render one merged `AGENTS.md` output from standing-guidance sources.
 *
 * Mirrors `render_merged_standing_guidance`.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecords Standing-guidance mapping records targeting AGENTS.md.
 * @returns One merged `AGENTS.md` output body.
 * @throws Error When a required source file cannot be read.
 */
export function renderMergedStandingGuidance(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
): string {
  const standingGuidanceSourcePaths = mappingRecords.map(
    (record) => record.sourcePath,
  );

  // Pre-rewrite each human-readable source label so header listings cannot
  // reintroduce a raw source-runtime reference that the validator would flag.
  const labelFor = (sourcePath: string): string => {
    const [rewrittenLabel] = rewriteSupportedAutomationReference(
      posixName(sourcePath),
      {
        enableRepoPrompts: runOptions.enableRepoPrompts,
        standingGuidanceSourcePaths,
      },
    );
    return rewrittenLabel;
  };

  const renderedSections: string[] = [
    "# Converted standing guidance",
    "",
    "Merged standing-guidance sources:",
    ...mappingRecords.map((record) => `- \`${labelFor(record.sourcePath)}\``),
    "",
  ];

  // Append one rewritten section per standing-guidance source, in order.
  for (const mappingRecord of mappingRecords) {
    const renderedText = rstrip(
      renderTargetContent(
        fileSystem,
        runOptions,
        mappingRecord,
        standingGuidanceSourcePaths,
      ),
    );
    const sectionLabel = labelFor(mappingRecord.sourcePath);
    renderedSections.push(
      `## Source: \`${sectionLabel}\``,
      "",
      renderedText,
      "",
    );
  }

  return rstrip(renderedSections.join("\n")) + "\n";
}

/**
 * Render one merged native output from section-level planned emissions.
 *
 * Mirrors `render_section_emission_content`.
 *
 * @param runOptions Requested run options.
 * @param targetPath Target path the emissions resolve to.
 * @param plannedEmissions Section-level planned emissions for the target.
 * @param sectionLookupById Lookup of parsed sections by section id.
 * @param standingGuidanceSourcePaths Standing-guidance source paths.
 * @returns The rendered merged native output, or an empty string when no
 *   emissions are provided.
 */
export function renderSectionEmissionContent(
  runOptions: RunOptions,
  targetPath: string,
  plannedEmissions: ReadonlyArray<PlannedEmission>,
  sectionLookupById: ReadonlyMap<string, SourceSection>,
  standingGuidanceSourcePaths: ReadonlyArray<string>,
): string {
  if (plannedEmissions.length === 0) {
    return "";
  }

  const targetRole = plannedEmissions[0]!.targetRole;
  const mergedSections: string[] = [];
  const allRewriteDescriptions: string[] = [];
  // Preserve first-seen source-path order (Python dict.fromkeys).
  const sourcePaths = [
    ...new Set(plannedEmissions.map((emission) => emission.sourcePath)),
  ];

  for (const plannedEmission of plannedEmissions) {
    const sourceSection = sectionLookupById.get(plannedEmission.sectionId);
    if (sourceSection === undefined) {
      continue;
    }
    const [rewrittenText, rewriteSummary] = rewriteText(
      runOptions,
      sourceSection.content,
      standingGuidanceSourcePaths,
    );
    const rewriteLines = rewriteSummary
      .split("\n")
      .filter((line) => line !== "" && line !== "- None");
    allRewriteDescriptions.push(...rewriteLines);
    mergedSections.push(
      `## Source section: \`${plannedEmission.heading}\``,
      "",
      "Applied rewrites:",
      ...(rewriteLines.length > 0 ? rewriteLines : ["- None"]),
      "",
      rewrittenText,
      "",
    );
  }

  const uniqueRewriteDescriptions = [...new Set(allRewriteDescriptions)];
  const rewriteSummary =
    uniqueRewriteDescriptions.length > 0
      ? uniqueRewriteDescriptions.join("\n")
      : "- None";
  const mergedText = rstrip(
    [
      "Derived prompt sections:",
      ...plannedEmissions.map((emission) => `- \`${emission.heading}\``),
      "",
      "Source artifacts:",
      ...sourcePaths.map((sourcePath) => `- \`${posixName(sourcePath)}\``),
      "",
      ...mergedSections,
    ].join("\n"),
  );
  return wrapRenderedTargetContent({
    targetRole,
    targetPath,
    rewrittenText: mergedText,
    rewriteSummary,
  });
}
