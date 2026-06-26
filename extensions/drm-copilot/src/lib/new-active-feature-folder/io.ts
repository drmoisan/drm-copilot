/**
 * I/O and template materialization helpers for active feature folder creation.
 *
 * Purpose:
 *     Direct TypeScript port of the bundled
 *     `dev_tools/new_active_feature_folder_io.py`. Covers potential-file
 *     discovery, issue-number parsing, folder-slug construction, template
 *     copying, plan-file materialization, the guarded `gh` issue fetch, and the
 *     injectable VS Code launcher seam.
 *
 * Seams:
 *     - The `gh` issue fetch routes through the injected F1 `CommandRunner`
 *       (`allowError: true`) and an injectable `gh` PATH lookup.
 *     - The launcher uses injectable env + which lookups and an injectable
 *       runner so tests never touch the real environment, PATH, or `code`.
 */

import { type CommandRunner } from "../subprocess-runner";
import { toPosixPath } from "../file-system";
import {
  EXCLUDED_POTENTIAL_NAMES,
  type FolderFileSystem,
  type IssueMeta,
  joinPosix,
  NAME_PATTERN,
  PLAN_TIMESTAMP_TEMPLATE_NAME,
} from "./models";
import { setHeaderPlaceholder } from "./markdown";
import { defaultWhichLookup } from "./io-launcher";

export {
  type CodeLauncherDeps,
  defaultCodeLauncher,
  defaultEnvLookup,
  defaultWhichLookup,
  INSIDERS_SIGNAL_NAMES,
  isInsidersSession,
  resolveCodeCli,
} from "./io-launcher";

/**
 * Return the final path segment (basename) of a forward-slash path.
 *
 * @param path Path string.
 * @returns The text after the last `/`, or the whole string when none.
 */
function baseName(path: string): string {
  const normalized = toPosixPath(path).replace(/\/+$/, "");
  const slash = normalized.lastIndexOf("/");
  return slash === -1 ? normalized : normalized.slice(slash + 1);
}

/**
 * Return the file suffix (extension) including the leading dot.
 *
 * Mirrors Python `Path.suffix`: the suffix is the text from the last `.` in the
 * basename, but only when that dot is not the first character.
 *
 * @param path Path string.
 * @returns The suffix (e.g. `.md`), or `""` when there is none.
 */
function suffix(path: string): string {
  const name = baseName(path);
  const dot = name.lastIndexOf(".");
  if (dot <= 0) {
    return "";
  }
  return name.slice(dot);
}

/**
 * Return the file stem (basename without the final suffix).
 *
 * Mirrors Python `Path.stem`.
 *
 * @param path Path string.
 * @returns The basename with its final suffix removed.
 */
function stem(path: string): string {
  const name = baseName(path);
  const ext = suffix(path);
  return ext ? name.slice(0, name.length - ext.length) : name;
}

/**
 * Find the best matching potential file for a feature name.
 *
 * Mirrors Python `find_potential_file`: searches `docs/features/potential` then
 * `docs/features/potential/promoted`; in each, collects `.md` files whose name
 * contains the underscore-normalized feature name and is not excluded; returns
 * the name-descending winner from the first directory that has candidates.
 *
 * @param featureName Feature name to match.
 * @param workspace Workspace root.
 * @param fs Filesystem seam.
 * @returns The matching potential file path, or `null` when none match.
 */
export function findPotentialFile(
  featureName: string,
  workspace: string,
  fs: FolderFileSystem,
): string | null {
  const normalized = featureName.replace(/_/g, "-");
  const potentialDirs = [
    joinPosix(workspace, "docs/features/potential"),
    joinPosix(workspace, "docs/features/potential/promoted"),
  ];

  // Scan each candidate directory in order and stop at the first one that has
  // matching potential files, returning the name-descending winner.
  for (const directory of potentialDirs) {
    const candidates = fs
      .listFiles(directory)
      .filter(
        (file) =>
          suffix(file) === ".md" &&
          baseName(file).includes(normalized) &&
          !EXCLUDED_POTENTIAL_NAMES.has(baseName(file)),
      );
    if (candidates.length > 0) {
      // Sort by basename descending so the highest-sorting file wins, matching
      // Python `sorted(..., key=name, reverse=True)[0]`.
      candidates.sort((left, right) =>
        baseName(right).localeCompare(baseName(left)),
      );
      return candidates[0] ?? null;
    }
  }
  return null;
}

/**
 * Parse an issue number from markdown metadata lines.
 *
 * Mirrors Python `parse_issue_number`.
 *
 * @param content Markdown content to scan.
 * @returns The captured digits, or `null` when no Issue line is present.
 */
export function parseIssueNumber(content: string): string | null {
  const match = /^\s*-\s*Issue\s*:\s*#?(\d+)/m.exec(content);
  return match ? (match[1] ?? null) : null;
}

/**
 * Build the canonical active-folder slug.
 *
 * Mirrors Python `build_folder_slug`: normalizes underscores, prefers the
 * potential-file stem, appends the issue number when not already a suffix, and
 * validates the result against {@link NAME_PATTERN}.
 *
 * @param featureName Feature name.
 * @param potentialFile Matched potential file path, or `null`.
 * @param issueNumber Resolved issue number, or `null`.
 * @returns The validated folder slug.
 * @throws Error When the slug fails the anchored full-match validation.
 */
export function buildFolderSlug(
  featureName: string,
  potentialFile: string | null,
  issueNumber: string | null,
): string {
  let slug = featureName.replace(/_/g, "-");
  if (potentialFile) {
    slug = stem(potentialFile);
  }
  if (issueNumber && !slug.endsWith(String(issueNumber))) {
    slug = `${slug}-${issueNumber}`;
  }
  if (!NAME_PATTERN.test(slug)) {
    throw new Error(
      `Aborted: '${slug}' is invalid. Use kebab/underscore-case letters/numbers ` +
        "(e.g., notes-feature or notes_feature).",
    );
  }
  return slug;
}

/**
 * Copy template files for the selected feature type.
 *
 * Mirrors Python `copy_template`. For `bug`, iterates
 * `(spec.md, <timestamped-plan>, plan.md)` copying each that exists and BREAKS
 * immediately after copying the timestamped plan template (so `plan.md` is only
 * copied when the timestamped template is absent). For all other types,
 * recursively copies the template tree.
 *
 * @param featureType Feature type.
 * @param templateDir Template source directory.
 * @param targetDir Destination directory.
 * @param fs Filesystem seam.
 */
export function copyTemplate(
  featureType: string,
  templateDir: string,
  targetDir: string,
  fs: FolderFileSystem,
): void {
  // Bug templates are copied selectively: the timestamped plan template, when
  // present, supersedes the legacy plan.md, so the loop breaks after copying it.
  if (featureType === "bug") {
    for (const name of ["spec.md", PLAN_TIMESTAMP_TEMPLATE_NAME, "plan.md"]) {
      const src = joinPosix(templateDir, name);
      if (fs.exists(src)) {
        fs.copyFile(src, joinPosix(targetDir, name));
        if (name === PLAN_TIMESTAMP_TEMPLATE_NAME) {
          break;
        }
      }
    }
  } else {
    fs.copyTree(templateDir, targetDir);
  }
}

/**
 * Copy only the plan template for minor-audit feature flows.
 *
 * Mirrors Python `copy_feature_template_for_minor_audit`: prefers the
 * timestamped plan template, falling back to the legacy `plan.md`.
 *
 * @param templateDir Template source directory.
 * @param targetDir Destination directory.
 * @param fs Filesystem seam.
 */
export function copyFeatureTemplateForMinorAudit(
  templateDir: string,
  targetDir: string,
  fs: FolderFileSystem,
): void {
  const timestampedPlan = joinPosix(templateDir, PLAN_TIMESTAMP_TEMPLATE_NAME);
  if (fs.exists(timestampedPlan)) {
    fs.copyFile(
      timestampedPlan,
      joinPosix(targetDir, PLAN_TIMESTAMP_TEMPLATE_NAME),
    );
    return;
  }

  const legacyPlan = joinPosix(templateDir, "plan.md");
  if (fs.exists(legacyPlan)) {
    fs.copyFile(legacyPlan, joinPosix(targetDir, "plan.md"));
  }
}

/**
 * Rename and stamp plan templates when timestamped templates exist.
 *
 * Mirrors Python `materialize_plan_file`. When the timestamped plan template
 * exists in `targetDir`, moves it to `plan.<planTimestamp>.md`, applies
 * {@link setHeaderPlaceholder} (with `updatedField = planTimestamp`), and
 * returns the new plan path; else returns the legacy `plan.md` when present,
 * else `null`.
 *
 * The `featureType` argument is unused (Python `del feature_type`); it is kept
 * for signature parity.
 *
 * @param featureType Unused; kept for signature parity.
 * @param targetDir Destination directory.
 * @param featureName Feature name for header stamping.
 * @param issueField Issue field value.
 * @param ownerField Owner field value.
 * @param parentField Parent field value.
 * @param statusField Status field value.
 * @param versionField Version field value.
 * @param planTimestamp Timestamp used for the plan filename and updated field.
 * @param fs Filesystem seam.
 * @returns The materialized plan path, or `null` when no plan template exists.
 */
export function materializePlanFile(
  featureType: string,
  targetDir: string,
  featureName: string,
  issueField: string,
  ownerField: string,
  parentField: string,
  statusField: string,
  versionField: string,
  planTimestamp: string,
  fs: FolderFileSystem,
): string | null {
  // featureType is intentionally unused; void it to satisfy lint while keeping
  // the parameter for signature parity with the Python source.
  void featureType;
  const templatePlan = joinPosix(targetDir, PLAN_TIMESTAMP_TEMPLATE_NAME);
  if (fs.exists(templatePlan)) {
    const targetPlan = joinPosix(targetDir, `plan.${planTimestamp}.md`);
    fs.move(templatePlan, targetPlan);
    let content = fs.readText(targetPlan);
    const updatedField = planTimestamp;
    content = setHeaderPlaceholder(
      content,
      featureName,
      issueField,
      ownerField,
      updatedField,
      statusField,
      parentField,
      versionField,
    );
    fs.writeText(targetPlan, content);
    return targetPlan;
  }

  const legacy = joinPosix(targetDir, "plan.md");
  if (fs.exists(legacy)) {
    return legacy;
  }
  return null;
}

/**
 * Resolve `gh` on PATH.
 *
 * Mirrors Python `shutil.which("gh")`. Exposed as an injectable lookup so tests
 * can supply a deterministic resolution.
 *
 * @returns The resolved `gh` path, or `null` when not on PATH.
 */
function defaultGhLookup(): string | null {
  return defaultWhichLookup("gh") ?? null;
}

/**
 * Fetch issue metadata from the GitHub CLI.
 *
 * Mirrors Python `default_issue_fetcher`. Resolves `gh` via the injectable
 * lookup; runs `gh issue view <n> --json number,title,url,author,updatedAt`
 * through the injected runner with `allowError: true`; returns `null` on
 * missing `gh`, non-zero exit, blank stdout, or JSON parse error. This is the
 * only `gh` interaction in the cluster and is optional/guarded.
 *
 * @param issueNumber Issue number to look up.
 * @param runner Command runner used to invoke `gh`.
 * @param ghLookup Optional injectable `gh` PATH resolver.
 * @returns The parsed {@link IssueMeta}, or `null`.
 */
export function defaultIssueFetcher(
  issueNumber: string,
  runner: CommandRunner,
  ghLookup: () => string | null = defaultGhLookup,
): IssueMeta | null {
  const ghCmd = ghLookup();
  if (!ghCmd) {
    return null;
  }
  const result = runner.run(
    [
      ghCmd,
      "issue",
      "view",
      issueNumber,
      "--json",
      "number,title,url,author,updatedAt",
    ],
    { allowError: true },
  );
  if (result.code !== 0 || !result.stdout.trim()) {
    return null;
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(result.stdout.trim());
  } catch {
    // A malformed gh payload is treated as no metadata rather than an error.
    return null;
  }

  const record = parsed as {
    number?: unknown;
    author?: { login?: unknown };
    updatedAt?: unknown;
  };
  const numberValue =
    record.number === undefined || record.number === null
      ? issueNumber
      : String(record.number);
  const login = record.author?.login;
  const author = typeof login === "string" && login ? login : "name";
  let updatedDate = "YYYY-MM-DD";
  if (typeof record.updatedAt === "string" && record.updatedAt.trim()) {
    updatedDate = record.updatedAt.split("T")[0] ?? "YYYY-MM-DD";
  }
  return { number: numberValue, author, updatedDate };
}
