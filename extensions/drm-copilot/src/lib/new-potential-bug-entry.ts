import * as fs from "node:fs";
import * as nodePath from "node:path";
import { type FileSystem, toPosixPath } from "./file-system";
import { type CommandRunner, SubprocessRunner } from "./subprocess-runner";

/**
 * In-process TypeScript port of the bundled Python
 * `resources/scripts/dev_tools/new_potential_bug_entry.py`.
 *
 * Purpose:
 *     Reproduce, verbatim, the observable behavior of the Python bug-entry
 *     creator: short-name validation, template selection/read, author
 *     resolution from git config / environment, placeholder rendering, target
 *     file write, and the optional VS Code launch. All external interactions
 *     (filesystem, git, PATH probing, environment, editor launch) flow through
 *     injectable seams so the module is hermetically testable and so the
 *     service/MCP path can pass a no-op editor launcher.
 *
 * Responsibilities:
 *     - {@link validateShortName}: enforce the kebab-case short-name contract
 *       with a byte-identical error message to the Python `ValueError`.
 *     - {@link renderContent}: replace-all placeholder substitution matching
 *       Python `str.replace` semantics.
 *     - Author resolution seams ({@link defaultGitConfigLookup},
 *       {@link defaultEnvLookup}, {@link getAuthor}).
 *     - Editor-launch seams ({@link isInsidersSession}, {@link resolveCodeCli},
 *       {@link defaultCodeLauncher}).
 *     - {@link createBugEntry}: orchestrate the full creation workflow.
 *
 * Invariants / Constraints:
 *     - The library entry point performs no direct `node:fs` /
 *       `node:child_process` access; those are confined to the injectable
 *       production defaults (env lookup, which lookup, git lookup, launcher),
 *       which callers can replace in tests.
 *     - No `copyFile` is added to the shared {@link FileSystem} interface; the
 *       Python copy-then-read collapses into a single template read followed by
 *       render-and-write, which is behaviorally identical for the observable
 *       outcome (target file content).
 */

/**
 * Anchored kebab-case pattern for bug-entry short names.
 *
 * Mirrors the Python `SHORT_NAME_PATTERN = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")`.
 * Python `fullmatch` against this anchored pattern is equivalent to
 * `RegExp.prototype.test` here because the pattern is anchored with `^...$`.
 */
export const SHORT_NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;

/**
 * VS Code session signal environment variable names, checked in a fixed order.
 *
 * Mirrors the Python `_INSIDERS_SIGNAL_NAMES` tuple. The order is preserved so
 * Insiders detection behaves identically to the Python source.
 */
const INSIDERS_SIGNAL_NAMES = [
  "TERM_PROGRAM_VERSION",
  "VSCODE_GIT_ASKPASS_MAIN",
  "TERM_PROGRAM",
  "VSCODE_IPC_HOOK_CLI",
] as const;

/**
 * Validate that a short name matches the repository kebab-case contract.
 *
 * Rejects invalid bug-entry short names before any filesystem or template work
 * begins, matching the Python `validate_short_name` contract.
 *
 * @param shortName Candidate short name that must use lowercase kebab-case
 *   tokens (letters/numbers, hyphen-separated).
 * @throws Error When `shortName` is blank or does not fully match
 *   {@link SHORT_NAME_PATTERN}. The message is byte-identical to the Python
 *   `ValueError` text.
 */
export function validateShortName(shortName: string): void {
  // A blank string or a value that does not fully match the anchored pattern is
  // rejected. The message text must remain byte-identical to the Python source.
  if (!shortName || !SHORT_NAME_PATTERN.test(shortName)) {
    throw new Error(
      `Aborted: '${shortName}' is invalid. Use kebab-case letters/numbers only ` +
        "(e.g., api-timeout).",
    );
  }
}

/**
 * Apply bug-entry placeholder substitutions to the markdown template content.
 *
 * Replaces every occurrence of each placeholder, matching Python `str.replace`
 * replace-all semantics. `String.prototype.replace` with a string argument
 * replaces only the first match in JavaScript, so this implementation uses
 * `split`/`join` to replace all occurrences.
 *
 * @param template Raw markdown template content.
 * @param shortName Validated short name replacing the `<bug-name>` placeholder.
 * @param entryDate ISO date string replacing the `YYYY-MM-DD` placeholder.
 * @param author Author name replacing the `- Author: name` metadata line.
 * @returns Markdown content with all supported placeholders replaced.
 */
export function renderContent(
  template: string,
  shortName: string,
  entryDate: string,
  author: string,
): string {
  // Replace-all every placeholder via split/join so all occurrences are
  // substituted, matching Python `str.replace` (which replaces all matches).
  let updated = template.split("<bug-name>").join(shortName);
  updated = updated.split("YYYY-MM-DD").join(entryDate);
  updated = updated.split("- Author: name").join(`- Author: ${author}`);
  return updated;
}

/**
 * Resolve a git configuration value through the injected command runner.
 *
 * Production default for the author git lookup. Runs `git config <key>` with
 * `allowError: true` so a missing git executable or a non-zero exit yields
 * `undefined` rather than throwing, mirroring the Python `default_git_config_
 * lookup` behavior (which probes `shutil.which("git")` and returns `None` on
 * absence). The injected {@link CommandRunner} surfaces a spawn failure as a
 * non-zero `code`, which this function treats as "no value".
 *
 * @param runner Command runner used to invoke git.
 * @param key Git configuration key to read, such as `user.name`.
 * @returns The trimmed configuration value when non-empty; otherwise
 *   `undefined`.
 */
export function defaultGitConfigLookup(
  runner: CommandRunner,
  key: string,
): string | undefined {
  const result = runner.run(["git", "config", key], { allowError: true });
  // A non-zero exit (including a failed spawn when git is absent) means no
  // value is available, mirroring the Python `which("git")` guard returning None.
  if (result.code !== 0) {
    return undefined;
  }
  const value = result.stdout.trim();
  return value.length > 0 ? value : undefined;
}

/**
 * Return a non-blank environment variable value when one is defined.
 *
 * Production default for the author/insiders environment lookup. Mirrors the
 * Python `default_env_lookup`: reads `process.env[name]` and returns it only
 * when present and non-blank after trimming, else `undefined`.
 *
 * @param name Environment variable name to read.
 * @returns The value when present and non-blank; otherwise `undefined`.
 */
export function defaultEnvLookup(name: string): string | undefined {
  const value = process.env[name];
  return value !== undefined && value.trim().length > 0 ? value : undefined;
}

/**
 * Resolve the author name, preferring git config before the USERNAME fallback.
 *
 * Mirrors the Python `get_author`: query `user.name` via the git lookup first;
 * if blank/undefined, read the `USERNAME` environment variable; if still
 * blank/undefined, return the literal `"Unknown"`.
 *
 * @param gitLookup Git-backed lookup for configuration values.
 * @param envLookup Environment-backed lookup for fallback variables.
 * @returns The resolved author name, or `"Unknown"` when neither yields a value.
 */
export function getAuthor(
  gitLookup: (key: string) => string | undefined,
  envLookup: (name: string) => string | undefined,
): string {
  // Prefer the repository's configured author; fall back to USERNAME; then to
  // the literal "Unknown". Ordering matches the Python source exactly.
  let author = gitLookup("user.name");
  if (!author) {
    author = envLookup("USERNAME");
  }
  if (!author) {
    return "Unknown";
  }
  return author;
}

/**
 * Determine whether the current process appears to run inside VS Code Insiders.
 *
 * Mirrors the Python `_is_insiders_session`: probe the documented VS Code
 * session signal variables in a fixed order; a value containing the substring
 * `insider` (case-insensitive) indicates an Insiders session.
 *
 * @param envLookup Environment lookup used to read the signal variables.
 * @returns `true` when any supported signal indicates Insiders; else `false`.
 */
export function isInsidersSession(
  envLookup: (name: string) => string | undefined,
): boolean {
  // Check the documented VS Code environment signals in a stable order so the
  // launcher behavior stays deterministic, matching the Python ordering.
  for (const variableName of INSIDERS_SIGNAL_NAMES) {
    const value = envLookup(variableName);
    if (value !== undefined && value.toLowerCase().includes("insider")) {
      return true;
    }
  }
  return false;
}

/**
 * Resolve the best VS Code CLI executable for the current session.
 *
 * Mirrors the Python `_resolve_code_cli`: when the session signals Insiders,
 * prefer `code-insiders` then fall back to `code`; otherwise prefer `code`
 * then fall back to `code-insiders`. Returns the first resolved executable.
 *
 * @param whichLookup PATH lookup resolving a CLI name to an executable path.
 * @param envLookup Environment lookup used for Insiders-session detection.
 * @returns The resolved CLI executable path, or `undefined` when none resolves.
 */
export function resolveCodeCli(
  whichLookup: (name: string) => string | undefined,
  envLookup: (name: string) => string | undefined,
): string | undefined {
  // Prefer the CLI matching the current session first, then fall back to the
  // other supported executable name to preserve graceful behavior.
  const candidateNames = isInsidersSession(envLookup)
    ? (["code-insiders", "code"] as const)
    : (["code", "code-insiders"] as const);
  for (const candidateName of candidateNames) {
    const resolvedCommand = whichLookup(candidateName);
    if (resolvedCommand) {
      return resolvedCommand;
    }
  }
  return undefined;
}

/**
 * Probe the current process PATH for an executable and return its path.
 *
 * Production default for the {@link resolveCodeCli} `whichLookup` seam. Mirrors
 * `shutil.which` using the same PATH/PATHEXT probing approach as
 * `command-runtime.ts`. Injectable so tests never touch the real PATH.
 *
 * @param executable The executable name to probe, without a file extension.
 * @returns The resolved absolute path when found; otherwise `undefined`.
 */
export function defaultWhichLookup(executable: string): string | undefined {
  const pathValue = process.env["PATH"] ?? "";
  const pathParts = pathValue
    .split(nodePath.delimiter)
    .filter((part) => part.length > 0);
  const pathExtensions =
    process.platform === "win32"
      ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
          .split(";")
          .filter((part) => part.length > 0)
      : [""];

  // Probe each PATH directory against each allowed extension so resolution
  // behaves consistently across Windows and non-Windows environments.
  for (const directory of pathParts) {
    for (const extension of pathExtensions) {
      const candidate = nodePath.join(
        directory,
        process.platform === "win32" ? `${executable}${extension}` : executable,
      );
      if (fs.existsSync(candidate)) {
        return candidate;
      }
    }
  }
  return undefined;
}

/** Injectable dependencies for {@link defaultCodeLauncher}. */
export interface CodeLauncherDeps {
  /** Command runner used to invoke the resolved CLI executable. */
  readonly runner: CommandRunner;
  /** PATH lookup resolving a CLI name to an executable path. */
  readonly whichLookup: (name: string) => string | undefined;
  /** Environment lookup used for Insiders-session detection. */
  readonly envLookup: (name: string) => string | undefined;
}

/**
 * Open the created files in the matching VS Code session when possible.
 *
 * Production default editor launcher. Mirrors the Python `default_code_
 * launcher`: resolve the CLI via {@link resolveCodeCli}; if none resolves,
 * return `false`; otherwise invoke `<cli> --reuse-window <files...>` (with
 * forward-slash file paths) through the injected runner and return `true`.
 *
 * @param files Files to open in the editor session.
 * @param deps Injected runner / which / env seams.
 * @returns `true` when a CLI was resolved and invoked; otherwise `false`.
 */
export function defaultCodeLauncher(
  files: readonly string[],
  deps: CodeLauncherDeps,
): boolean {
  const codeCmd = resolveCodeCli(deps.whichLookup, deps.envLookup);
  if (!codeCmd) {
    return false;
  }

  // Invoke the resolved CLI with the same argument shape as the Python source:
  // `--reuse-window` followed by forward-slash-normalized file paths. The run
  // tolerates a non-zero exit (allowError) to preserve the boolean success
  // contract once a CLI is resolved.
  deps.runner.run(
    [
      codeCmd,
      "--reuse-window",
      ...files.map((filePath) => filePath.replace(/\\/g, "/")),
    ],
    { allowError: true },
  );
  return true;
}

/** Options for {@link createBugEntry}. */
export interface CreateBugEntryOptions {
  /** Validated kebab-case short name for the generated filename and content. */
  readonly shortName: string;
  /** Workspace root that receives the generated file. */
  readonly workspace: string;
  /** Injected filesystem for directory creation and text I/O. */
  readonly fs: FileSystem;
  /** Author resolver; defaults to {@link getAuthor} with production lookups. */
  readonly authorProvider?: () => string;
  /** Editor launcher; defaults to {@link defaultCodeLauncher}. */
  readonly codeLauncher?: (files: readonly string[]) => boolean;
  /** Optional ISO date override (`YYYY-MM-DD`) for deterministic generation. */
  readonly entryDate?: string;
  /** Optional bundled feature-template root overriding workspace templates. */
  readonly templateRoot?: string;
  /** Optional log sink for the editor-not-found warning lines. */
  readonly log?: (message: string) => void;
}

/**
 * Build the production author provider backed by git config and environment.
 *
 * @param runner Command runner used by the default git lookup.
 * @returns A zero-argument author resolver matching the Python default chain.
 */
function buildDefaultAuthorProvider(runner: CommandRunner): () => string {
  return () =>
    getAuthor((key) => defaultGitConfigLookup(runner, key), defaultEnvLookup);
}

/**
 * Resolve today's date as an ISO `YYYY-MM-DD` string.
 *
 * Mirrors the Python `date.today().strftime("%Y-%m-%d")`. Used only when no
 * explicit `entryDate` override is supplied.
 *
 * @returns The current local date formatted as `YYYY-MM-DD`.
 */
function todayIsoDate(): string {
  const now = new Date();
  const year = now.getFullYear().toString().padStart(4, "0");
  const month = (now.getMonth() + 1).toString().padStart(2, "0");
  const day = now.getDate().toString().padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * Create a potential bug markdown file from the selected template root.
 *
 * Materializes a new potential bug entry by reading a template, filling in
 * metadata, writing the rendered result, and optionally opening it in VS Code.
 * The Python copy-then-read-then-write is collapsed into a single template read
 * followed by render-and-write, which is behaviorally identical for the target
 * file content (the only observable filesystem outcome).
 *
 * Flow:
 *     1. Validate the short name (before any filesystem work).
 *     2. Resolve the date string, target directory, target path, and template
 *        path (templateRoot override vs workspace fallback).
 *     3. Ensure the target directory exists.
 *     4. Read the template; resolve the author; render placeholders; write the
 *        target file.
 *     5. Attempt the editor launch; on failure, emit the two warning lines.
 *
 * @param options See {@link CreateBugEntryOptions}.
 * @returns The created absolute target path (forward-slash joined per the
 *   injected filesystem and `node:path` conventions).
 * @throws Error When the short name is invalid (before any write) or when the
 *   template path is absent (surfaced as a file-not-found read error).
 */
export function createBugEntry(options: CreateBugEntryOptions): string {
  validateShortName(options.shortName);

  const dateStr = options.entryDate ?? todayIsoDate();
  // The service/MCP path always injects both seams. The defaults below back
  // standalone/CLI-equivalent callers and construct a real SubprocessRunner.
  const authorProvider =
    options.authorProvider ??
    buildDefaultAuthorProvider(new SubprocessRunner());
  const codeLauncher =
    options.codeLauncher ??
    ((files: readonly string[]) =>
      defaultCodeLauncher(files, {
        runner: new SubprocessRunner(),
        whichLookup: defaultWhichLookup,
        envLookup: defaultEnvLookup,
      }));

  // Paths are joined with forward-slash separators (`node:path` POSIX join over
  // toPosixPath-normalized inputs) to match the F1 FileSystem convention and the
  // Python `Path` POSIX-style outputs, so the returned/written path is stable
  // and OS-neutral.
  const targetDir = nodePath.posix.join(
    toPosixPath(options.workspace),
    "docs",
    "features",
    "potential",
  );
  const targetPath = nodePath.posix.join(
    targetDir,
    `${dateStr}-${options.shortName}.md`,
  );

  // Branch decision: a provided templateRoot overrides the workspace-local
  // template directory, matching the Python `template_root is not None` branch
  // (the service path always passes templateRoot; the fallback mirrors the CLI).
  const templatePath =
    options.templateRoot !== undefined
      ? nodePath.posix.join(
          toPosixPath(options.templateRoot),
          "bug",
          "potential_bug.md",
        )
      : nodePath.posix.join(
          toPosixPath(options.workspace),
          "docs",
          "features",
          "templates",
          "bug",
          "potential_bug.md",
        );

  options.fs.ensureDir(targetDir);
  const template = options.fs.readTextFile(templatePath);
  const author = authorProvider();
  const updated = renderContent(template, options.shortName, dateStr, author);
  options.fs.writeTextFile(targetPath, updated);

  // When the editor launch is unavailable (or a no-op in the MCP/service path),
  // emit the manual-open guidance lines, preserving the Python warning text.
  if (!codeLauncher([targetPath])) {
    options.log?.(
      "WARNING: VS Code 'code' command not found. Open file manually:",
    );
    options.log?.(`  ${targetPath}`);
  }

  return targetPath;
}
