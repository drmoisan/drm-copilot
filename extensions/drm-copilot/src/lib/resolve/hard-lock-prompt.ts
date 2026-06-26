/**
 * Execute-hard-lock prompt resolver: template selection, `${plan-path}` /
 * `${work-mode}` / `${fallback-reason}` substitution, and the bundled `main()`
 * command shell.
 *
 * Purpose:
 *     Port the bundled `resolve_hard_lock_prompt.py` into host-neutral
 *     TypeScript. All file I/O flows through the injected {@link FileSystem};
 *     clipboard and stdout/stderr are injectable seams so the resolver runs
 *     hermetically with no real OS clipboard, subprocess, or process-stdout
 *     usage and so the MCP quiet path performs no clipboard interaction.
 *
 * Responsibilities:
 *     - `resolveTemplateName` / `resolveTemplatePath`: template selection and
 *       deterministic probe order (explicit template root first, then the
 *       workspace `.github/codex` fallback).
 *     - `resolveIssueFileForTarget` / `resolveWorkModeFromIssue`: nearest
 *       `issue.md` resolution (including `v*` parent fallback) and fail-closed
 *       work-mode selection.
 *     - `resolveHardLockPrompt`: `${plan-path}` / `${work-mode}` /
 *       `${fallback-reason}` substitution.
 *     - `resolveExecuteHardLockCommand`: the bundled `main()` shell (quiet/
 *       output semantics, output write, clipboard branch, error messages, exit
 *       codes).
 *
 * Parity:
 *     Messages and exit codes match the bundled `resolve_hard_lock_prompt.py`.
 */

import { type FileSystem, toPosixPath } from "../file-system";
import {
  buildFallbackReason,
  resolveSelectedWorkMode,
} from "../prompt-mode-contract";

/** Hard-lock template kinds accepted by the resolver. */
export type HardLockTemplateKind = "execute" | "resume";

/**
 * Map a template-kind selector to its concrete template filename.
 *
 * Mirrors Python `_resolve_template_name`.
 *
 * @param templateKind The CLI selector (`execute` or `resume`).
 * @returns The prompt filename for the requested kind.
 */
export function resolveTemplateName(
  templateKind: HardLockTemplateKind,
): string {
  return templateKind === "execute"
    ? "execute-hard-lock.prompt.md"
    : "resume-hard-lock.prompt.md";
}

/** Outcome of {@link resolveTemplatePath}. */
export interface TemplatePathResolution {
  /** The selected template path when found, otherwise null. */
  readonly path: string | null;
  /** The ordered list of candidate paths that were checked. */
  readonly checked: string[];
}

/**
 * Resolve the first available template path in deterministic order.
 *
 * Mirrors Python `_resolve_template_path`: probe `templateRoot/<name>` first
 * (when a template root is provided), then `<workspaceRoot>/.github/codex/
 * <name>`. Returns the first existing path (via {@link FileSystem.isFile}) plus
 * the ordered checked list.
 *
 * @param templateName Prompt filename to resolve.
 * @param workspaceRoot Workspace root used for the repo-local fallback.
 * @param templateRoot Optional explicit template directory probed first.
 * @param fs Injected filesystem for existence checks.
 * @returns The selected path (or null) and the ordered checked candidates.
 */
export function resolveTemplatePath(
  templateName: string,
  workspaceRoot: string,
  templateRoot: string | null,
  fs: FileSystem,
): TemplatePathResolution {
  const candidates: string[] = [];
  if (templateRoot !== null) {
    candidates.push(joinPosix(templateRoot, templateName));
  }
  candidates.push(
    joinPosix(
      joinPosix(toPosixPath(workspaceRoot), ".github/codex"),
      templateName,
    ),
  );

  // Probe the explicit template root before the workspace fallback so bundled
  // extension resources stay authoritative when intentionally passed.
  for (const candidate of candidates) {
    if (fs.isFile(candidate)) {
      return { path: candidate, checked: candidates };
    }
  }

  return { path: null, checked: candidates };
}

/**
 * Resolve the nearest `issue.md` path for a target plan file.
 *
 * Mirrors Python `_resolve_issue_file_for_target`: prefer the direct
 * `<plan-dir>/issue.md`; when the plan directory is a versioned `v*` folder
 * (with at least two components) fall back to the parent directory's
 * `issue.md`; otherwise return the direct candidate.
 *
 * @param targetPath Target plan file path.
 * @param workspaceRoot Workspace root for normalization.
 * @param fs Injected filesystem for existence checks.
 * @returns The candidate `issue.md` path to parse for the work-mode marker.
 */
export function resolveIssueFileForTarget(
  targetPath: string,
  workspaceRoot: string,
  fs: FileSystem,
): string {
  const normalizedRoot = toPosixPath(workspaceRoot).replace(/\/+$/, "");
  const relativeTarget = tryRelativeToWorkspace(targetPath, workspaceRoot);
  const planDir = parentOf(relativeTarget);
  const directIssue = joinPosix(joinPosix(normalizedRoot, planDir), "issue.md");
  if (fs.isFile(directIssue)) {
    return directIssue;
  }

  const planDirParts = splitParts(planDir);
  const planDirName = planDirParts[planDirParts.length - 1] ?? "";
  // Versioned plan folders defer to the parent feature folder's issue.md.
  if (planDirName.startsWith("v") && planDirParts.length >= 2) {
    const parentIssue = joinPosix(
      joinPosix(normalizedRoot, parentOf(planDir)),
      "issue.md",
    );
    if (fs.isFile(parentIssue)) {
      return parentIssue;
    }
  }

  return directIssue;
}

/** Resolved work-mode outcome for the hard-lock resolver. */
export interface HardLockWorkModeResolution {
  /** Selected work mode (`minor-audit`, `full-feature`, or `full-bug`). */
  readonly mode: string;
  /** Human-readable fallback or normalization reason. */
  readonly fallbackReason: string;
}

/**
 * Resolve `${work-mode}` and `${fallback-reason}` from the nearest `issue.md`.
 *
 * Mirrors Python `_resolve_work_mode_from_issue` (hard-lock variant): locate the
 * issue file via {@link resolveIssueFileForTarget}; when absent use
 * `resolveSelectedWorkMode(null)` / `buildFallbackReason(null)`; when present but
 * unreadable use `full-feature` with the fixed reason
 * `issue.md unreadable; fail closed to full-feature`; otherwise the file content
 * drives both values.
 *
 * @param targetPath Target plan file path.
 * @param workspaceRoot Workspace root for path resolution.
 * @param fs Injected filesystem for existence and read.
 * @returns The resolved work-mode and fallback reason.
 */
export function resolveWorkModeFromIssue(
  targetPath: string,
  workspaceRoot: string,
  fs: FileSystem,
): HardLockWorkModeResolution {
  const issuePath = resolveIssueFileForTarget(targetPath, workspaceRoot, fs);
  if (!fs.isFile(issuePath)) {
    return {
      mode: resolveSelectedWorkMode(null),
      fallbackReason: buildFallbackReason(null),
    };
  }

  let issueContent: string;
  try {
    issueContent = fs.readTextFile(issuePath);
  } catch {
    // A present-but-unreadable issue file fails closed with a fixed reason,
    // matching the Python OSError branch.
    return {
      mode: resolveSelectedWorkMode(null),
      fallbackReason: "issue.md unreadable; fail closed to full-feature",
    };
  }

  return {
    mode: resolveSelectedWorkMode(issueContent),
    fallbackReason: buildFallbackReason(issueContent),
  };
}

/**
 * Substitute `${plan-path}`, `${work-mode}`, and `${fallback-reason}`.
 *
 * Mirrors Python `resolve_prompt` (hard-lock): the workspace-relative target is
 * forward-slashed (Python `relative_target.as_posix()`), substituted for
 * `${plan-path}`, then `${work-mode}` and `${fallback-reason}` are resolved from
 * the nearest `issue.md`.
 *
 * @param templateContent Raw template content containing the placeholders.
 * @param targetPath Target plan file path.
 * @param workspaceRoot Workspace root for relative resolution.
 * @param fs Injected filesystem for existence and read.
 * @returns The resolved template.
 */
export function resolveHardLockPrompt(
  templateContent: string,
  targetPath: string,
  workspaceRoot: string,
  fs: FileSystem,
): string {
  const relativeTarget = tryRelativeToWorkspace(targetPath, workspaceRoot);
  const planPathValue = toPosixPath(relativeTarget);

  const { mode, fallbackReason } = resolveWorkModeFromIssue(
    targetPath,
    workspaceRoot,
    fs,
  );

  let resolved = templateContent.split("${plan-path}").join(planPathValue);
  resolved = resolved.split("${work-mode}").join(mode);
  resolved = resolved.split("${fallback-reason}").join(fallbackReason);
  return resolved;
}

/** Input for {@link resolveExecuteHardLockCommand}. */
export interface ResolveExecuteHardLockCommandInput {
  /** Absolute or workspace-resolved path to the target plan file. */
  readonly targetPath: string;
  /** Workspace root used for relative resolution and file lookups. */
  readonly workspaceRoot: string;
  /** Template kind to resolve; defaults to `execute`. */
  readonly templateKind?: HardLockTemplateKind;
  /** Explicit template directory probed before the workspace fallback. */
  readonly templateRoot: string;
  /** Optional output path; relative paths resolve against the workspace root. */
  readonly output?: string;
  /** When true, suppress stdout/clipboard (requires `output`). */
  readonly quiet?: boolean;
  /** Injected filesystem for existence checks, reads, and the output write. */
  readonly fs: FileSystem;
  /**
   * Optional clipboard seam returning true on success. Defaults to a no-op
   * returning false so no real OS clipboard is touched.
   */
  readonly copyToClipboard?: (text: string) => boolean;
  /** Optional sink for stdout/stderr lines emitted by the command shell. */
  readonly log?: (message: string) => void;
}

/** Result of {@link resolveExecuteHardLockCommand}. */
export interface ResolveExecuteHardLockCommandResult {
  /** The resolved prompt content, or null when an error short-circuited. */
  readonly resolved: string | null;
  /** The absolute output path that was written, when `output` was provided. */
  readonly outputWritten?: string;
  /** Exit code: 0 on success, 1 on any error path. */
  readonly exitCode: number;
}

/**
 * Reproduce the bundled `resolve_hard_lock_prompt.py` `main()` shell.
 *
 * Mirrors the bundled `main()` using injected seams: `quiet` without `output`
 * returns the error/exit-1 path with the bundled message; template not found →
 * `Error: Template '<name>' not found. Checked locations:\n- <p1>\n- <p2>` +
 * exit 1; target missing → `Error: Target file not found at <target>` + exit 1;
 * template read failure → `Error reading template: <error>` + exit 1; resolve
 * the prompt; when `output` is provided write via {@link FileSystem.ensureDir}
 * plus {@link FileSystem.writeTextFile} (relative output resolves against the
 * workspace root; absolute output is used verbatim), with
 * `Error writing output file: <error>` + exit 1 on failure; when `quiet` return
 * exit 0 without stdout/clipboard; otherwise emit the resolved content then
 * attempt the clipboard, emitting `\n✓ Copied to clipboard` on success or
 * `\n✗ Could not copy to clipboard (no supported mechanism found)` on failure;
 * return exit 0.
 *
 * @param input Target/workspace, template selection, output/quiet flags,
 *   filesystem, and the optional clipboard/log seams.
 * @returns The resolved content (or null), the written output path, and exit
 *   code.
 */
export function resolveExecuteHardLockCommand(
  input: ResolveExecuteHardLockCommandInput,
): ResolveExecuteHardLockCommandResult {
  const emit = input.log ?? ((): void => undefined);
  const copyToClipboard = input.copyToClipboard ?? ((): boolean => false);

  // Defensive command-level guard: the service-layer guard runs first with a
  // different message; this only triggers if the service guard is bypassed.
  if (input.quiet === true && input.output === undefined) {
    emit(
      "Error: --quiet requires --output; --quiet alone would suppress all output.",
    );
    return { resolved: null, exitCode: 1 };
  }

  const templateKind = input.templateKind ?? "execute";
  const templateName = resolveTemplateName(templateKind);
  const { path: templatePath, checked } = resolveTemplatePath(
    templateName,
    input.workspaceRoot,
    input.templateRoot,
    input.fs,
  );

  if (templatePath === null) {
    const checkedText = checked.map((candidate) => `- ${candidate}`).join("\n");
    emit(
      `Error: Template '${templateName}' not found. Checked locations:\n${checkedText}`,
    );
    return { resolved: null, exitCode: 1 };
  }

  if (!input.fs.isFile(input.targetPath)) {
    emit(`Error: Target file not found at ${input.targetPath}`);
    return { resolved: null, exitCode: 1 };
  }

  let templateContent: string;
  try {
    templateContent = input.fs.readTextFile(templatePath);
  } catch (error) {
    emit(`Error reading template: ${describeError(error)}`);
    return { resolved: null, exitCode: 1 };
  }

  const resolved = resolveHardLockPrompt(
    templateContent,
    input.targetPath,
    input.workspaceRoot,
    input.fs,
  );

  // When --output is provided, persist the resolved prompt so non-interactive
  // callers receive the full content without capturing stdout.
  let outputWritten: string | undefined;
  if (input.output !== undefined) {
    const resolvedOutput = resolveOutputPath(input.output, input.workspaceRoot);
    try {
      input.fs.ensureDir(parentOf(resolvedOutput));
      input.fs.writeTextFile(resolvedOutput, resolved);
      outputWritten = resolvedOutput;
    } catch (error) {
      emit(`Error writing output file: ${describeError(error)}`);
      return { resolved: null, exitCode: 1 };
    }
  }

  // --quiet combined with --output suppresses stdout and clipboard so callers
  // produce only the file side channel.
  if (input.quiet === true) {
    return {
      resolved,
      ...(outputWritten === undefined ? {} : { outputWritten }),
      exitCode: 0,
    };
  }

  emit(resolved);

  if (copyToClipboard(resolved)) {
    emit("\n✓ Copied to clipboard");
  } else {
    emit("\n✗ Could not copy to clipboard (no supported mechanism found)");
  }

  return {
    resolved,
    ...(outputWritten === undefined ? {} : { outputWritten }),
    exitCode: 0,
  };
}

/**
 * Resolve an output path: absolute used verbatim, relative joined to workspace.
 *
 * Mirrors Python `_write_resolved_prompt` path resolution.
 *
 * @param output Output path supplied by the caller.
 * @param workspaceRoot Workspace root for relative resolution.
 * @returns The forward-slash output path.
 */
function resolveOutputPath(output: string, workspaceRoot: string): string {
  if (isAbsolute(output)) {
    return toPosixPath(output);
  }
  return joinPosix(toPosixPath(workspaceRoot), output);
}

/**
 * Return the workspace-relative path when the target sits under the workspace,
 * else the original POSIX path.
 *
 * Mirrors Python `_try_relative_to_workspace`.
 *
 * @param path Target path.
 * @param workspaceRoot Workspace root.
 * @returns The workspace-relative POSIX path, or the original POSIX path.
 */
function tryRelativeToWorkspace(path: string, workspaceRoot: string): string {
  const normalizedPath = toPosixPath(path).replace(/\/+$/, "");
  const normalizedRoot = toPosixPath(workspaceRoot).replace(/\/+$/, "");
  if (normalizedPath === normalizedRoot) {
    return "";
  }
  const rootPrefix = `${normalizedRoot}/`;
  if (normalizedPath.startsWith(rootPrefix)) {
    return normalizedPath.slice(rootPrefix.length);
  }
  return normalizedPath;
}

/**
 * Return the parent directory of a POSIX path.
 *
 * Mirrors Python `Path(...).parent`: a path with no separator yields `.`.
 *
 * @param pathValue POSIX path.
 * @returns The parent path, or `.` when there is no separator.
 */
function parentOf(pathValue: string): string {
  const normalized = toPosixPath(pathValue).replace(/\/+$/, "");
  const lastSlash = normalized.lastIndexOf("/");
  if (lastSlash === -1) {
    return ".";
  }
  if (lastSlash === 0) {
    return "/";
  }
  return normalized.slice(0, lastSlash);
}

/**
 * Split a POSIX path into non-empty components.
 *
 * @param pathValue POSIX path.
 * @returns Non-empty path components in order.
 */
function splitParts(pathValue: string): string[] {
  return toPosixPath(pathValue)
    .split("/")
    .filter((part) => part.length > 0 && part !== ".");
}

/**
 * Join two path segments using forward slashes.
 *
 * @param root Base path.
 * @param relative Relative path.
 * @returns The joined POSIX path.
 */
function joinPosix(root: string, relative: string): string {
  const normalizedRoot = toPosixPath(root).replace(/\/+$/, "");
  const normalizedRelative = toPosixPath(relative).replace(/^\/+/, "");
  // A `.` segment carries no path information, matching Python `Path(".") / x`.
  if (normalizedRelative === "" || normalizedRelative === ".") {
    return normalizedRoot;
  }
  if (normalizedRoot === "" || normalizedRoot === ".") {
    return normalizedRelative;
  }
  return `${normalizedRoot}/${normalizedRelative}`;
}

/**
 * Test whether a path is absolute (drive-letter, UNC, or POSIX root).
 *
 * @param filePath Candidate path.
 * @returns True when the path is absolute.
 */
function isAbsolute(filePath: string): boolean {
  return /^(?:[a-zA-Z]:[\\/]|\\\\|\/)/.test(filePath);
}

/**
 * Render an unknown thrown value as the message string Python would print.
 *
 * @param error The caught value.
 * @returns The error message text.
 */
function describeError(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
