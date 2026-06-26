/**
 * Atomic-plan prompt resolver core: `resolvePrompt` orchestrator and the
 * bundled `main()` command shell.
 *
 * Purpose:
 *     Port the bundled `resolve_file_prompt.py` `resolve_prompt` orchestrator
 *     and CLI `main()` behavior into host-neutral TypeScript. All file I/O
 *     flows through the injected {@link FileSystem}; clipboard and stdout/stderr
 *     are modeled as injectable seams so the resolver runs hermetically with no
 *     real OS clipboard, subprocess, or process-stdout usage.
 *
 * Responsibilities:
 *     - `resolvePrompt`: apply the exact substitution order (front-matter strip,
 *       `${file}`, folderpath/feature-foldername/name, spec/user-story,
 *       work-mode/fallback-reason, minor-audit overrides, research handling,
 *       user-story clause removal, deterministic substitution).
 *     - `resolveAtomicPlanCommand`: reproduce the bundled `main()` shell
 *       (template/target existence checks, read, resolve, clipboard branch,
 *       returned content/exit code) using injected seams.
 *
 * Parity:
 *     stdout/stderr lines and exit codes match the bundled
 *     `resolve_file_prompt.py`.
 */

import { type FileSystem, toPosixPath } from "../file-system";
import {
  resolveFeatureFoldername,
  resolveFolderpath,
  resolveNameFromFeatureFoldername,
  resolveResearchValue,
  resolveSpecPath,
  resolveUserStoryValue,
  resolveWorkModeFromIssue,
  stripFrontMatter,
  tryRelativeToWorkspace,
} from "./file-prompt-variables";
import {
  applyMinorAuditOverrides,
  removeLinesReferencingVariable,
  removeUserStoryClauseWhenMissing,
  replaceAllVariables,
} from "./file-prompt-transforms";

/**
 * Resolve all supported atomic-plan prompt placeholders.
 *
 * Mirrors the bundled `resolve_file_prompt.py` `resolve_prompt` exactly: strip
 * front matter, compute `${file}` (workspace-relative, forward-slashed),
 * derive folderpath / feature foldername / name, build the base variable map
 * (`file`, `folderpath`, `name`, `spec`, `user-story`), resolve work-mode and
 * fallback-reason from `issue.md`, apply minor-audit overrides when the mode is
 * `minor-audit`, resolve the optional `${research}` value (removing its lines
 * when missing), remove the user-story clause when the user story is missing,
 * then perform deterministic substitution.
 *
 * @param templateContent Raw prompt-template content.
 * @param targetPath Target plan file used for relative substitutions.
 * @param workspaceRoot Workspace root used for relative resolution and lookups.
 * @param fs Injected filesystem for all existence checks and reads.
 * @returns Fully resolved prompt content with no remaining placeholders.
 * @throws Error When required placeholders cannot be resolved (propagated from
 *   {@link replaceAllVariables} or {@link resolveFeatureFoldername}).
 */
export function resolvePrompt(
  templateContent: string,
  targetPath: string,
  workspaceRoot: string,
  fs: FileSystem,
): string {
  let content = stripFrontMatter(templateContent);

  const relativeTarget = tryRelativeToWorkspace(targetPath, workspaceRoot);
  const fileValue = toPosixPath(relativeTarget);

  const folderpath = resolveFolderpath(targetPath, workspaceRoot);
  const featureFoldername = resolveFeatureFoldername(folderpath);
  const name = resolveNameFromFeatureFoldername(featureFoldername);

  const variables: Record<string, string> = {
    file: fileValue,
    folderpath,
    name,
    spec: resolveSpecPath(folderpath),
    "user-story": resolveUserStoryValue(folderpath, workspaceRoot, fs),
  };

  const { mode, fallbackReason } = resolveWorkModeFromIssue(
    folderpath,
    workspaceRoot,
    fs,
  );
  variables["work-mode"] = mode;
  variables["fallback-reason"] = fallbackReason;

  // Minor-audit mode intentionally removes spec/story/research requirements and
  // constrains the plan structure to three phases.
  if (mode === "minor-audit") {
    content = applyMinorAuditOverrides(content);
  }

  // Resolve optional research path; when missing, delete any line referencing
  // it so the prompt does not point at a non-existent document.
  const researchValue = resolveResearchValue(folderpath, workspaceRoot, fs);
  if (researchValue === null) {
    content = removeLinesReferencingVariable(content, "research");
  } else {
    variables["research"] = researchValue;
  }

  // When the user story is missing, remove the clause that assumes it exists.
  if ((variables["user-story"] ?? "").includes("(missing)")) {
    content = removeUserStoryClauseWhenMissing(content);
  }

  return replaceAllVariables(content, variables);
}

/** Input for {@link resolveAtomicPlanCommand}. */
export interface ResolveAtomicPlanCommandInput {
  /** Absolute or workspace-resolved path to the prompt template. */
  readonly templatePath: string;
  /** Absolute or workspace-resolved path to the target plan file. */
  readonly targetPath: string;
  /** Workspace root used for relative resolution and file lookups. */
  readonly workspaceRoot: string;
  /** Injected filesystem for all existence checks and reads. */
  readonly fs: FileSystem;
  /**
   * Optional clipboard seam. Returns true when the copy succeeded. Defaults to
   * a deterministic no-op returning false so the "could not copy" branch is the
   * default outcome and no real OS clipboard is touched.
   */
  readonly copyToClipboard?: (text: string) => boolean;
  /** Optional sink for stdout/stderr lines emitted by the command shell. */
  readonly log?: (message: string) => void;
}

/** Result of {@link resolveAtomicPlanCommand}. */
export interface ResolveAtomicPlanCommandResult {
  /** The resolved prompt content, or null when an error short-circuited. */
  readonly resolved: string | null;
  /** Exit code: 0 on success, 1 on any error path. */
  readonly exitCode: number;
}

/**
 * Reproduce the bundled `resolve_file_prompt.py` `main()` shell in-process.
 *
 * Mirrors the bundled `main()` exactly using injected seams instead of process
 * I/O: missing template → `Error: Template file not found: <path>` + exit 1;
 * missing target → `Error: Target file not found: <path>` + exit 1; template
 * read failure → `Error reading template: <error>` + exit 1; a thrown
 * `resolvePrompt` → `Error processing prompt: <error>` + exit 1. On success,
 * when the clipboard copy succeeds emit
 * `Successfully resolved prompt and copied to clipboard.` then the resolved
 * content; otherwise emit
 * `Could not copy to clipboard; printing resolved prompt to stdout.` then the
 * resolved content; return exit 0 either way.
 *
 * @param input Template/target paths, workspace root, filesystem, and the
 *   optional clipboard/log seams.
 * @returns The resolved content (or null) and the exit code.
 */
export function resolveAtomicPlanCommand(
  input: ResolveAtomicPlanCommandInput,
): ResolveAtomicPlanCommandResult {
  const emit = input.log ?? ((): void => undefined);
  const copyToClipboard = input.copyToClipboard ?? ((): boolean => false);

  // Existence checks mirror the bundled main(): template first, then target.
  if (!input.fs.isFile(input.templatePath)) {
    emit(`Error: Template file not found: ${input.templatePath}`);
    return { resolved: null, exitCode: 1 };
  }

  if (!input.fs.isFile(input.targetPath)) {
    emit(`Error: Target file not found: ${input.targetPath}`);
    return { resolved: null, exitCode: 1 };
  }

  let templateContent: string;
  try {
    templateContent = input.fs.readTextFile(input.templatePath);
  } catch (error) {
    emit(`Error reading template: ${describeError(error)}`);
    return { resolved: null, exitCode: 1 };
  }

  let resolved: string;
  try {
    resolved = resolvePrompt(
      templateContent,
      input.targetPath,
      input.workspaceRoot,
      input.fs,
    );
  } catch (error) {
    emit(`Error processing prompt: ${describeError(error)}`);
    return { resolved: null, exitCode: 1 };
  }

  // Clipboard branch mirrors the bundled main(): both paths print the resolved
  // content; only the leading status line differs.
  if (copyToClipboard(resolved)) {
    emit("Successfully resolved prompt and copied to clipboard.");
    emit(resolved);
  } else {
    emit("Could not copy to clipboard; printing resolved prompt to stdout.");
    emit(resolved);
  }

  return { resolved, exitCode: 0 };
}

/**
 * Render an unknown thrown value as the message string Python would print.
 *
 * Mirrors Python f-string interpolation of an exception (`{error}`), which
 * yields the exception's message text.
 *
 * @param error The caught value.
 * @returns The error message text.
 */
function describeError(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
