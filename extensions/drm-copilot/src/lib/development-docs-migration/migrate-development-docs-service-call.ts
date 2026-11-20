/**
 * Service call for `migrate_development_docs` (issue #1016, spec "MCP tool
 * `migrate_development_docs`").
 *
 * Composes the git seam, the planner, the applier and the report. Any refusal
 * throws before a move or a write. Report files are written only when
 * `reportDirectory` is supplied and no refusal occurred.
 */
import * as nodePath from "node:path";

import {
  resolveDevelopmentDocsRoot,
  developmentDocsPath,
} from "../development-docs/root";
import { toPosixPath, type FileSystem } from "../file-system";
import type { CommandRunner } from "../subprocess-runner";
import {
  applyMigrationPlan,
  type MigrationApplyResult,
} from "./migration-apply";
import {
  parseMigrationDecisions,
  type MigrationDecisions,
} from "./migration-decisions";
import { createMigrationGit } from "./migration-git";
import { buildMigrationPlan, type MigrationMode } from "./migration-plan";
import {
  buildMigrationReport,
  migrationReportFileName,
  renderMigrationReportJson,
  renderMigrationReportMarkdown,
  type MigrationReport,
} from "./migration-report";

/** Source trees whose untracked files are listed. */
export const MIGRATION_SOURCE_PATHSPECS: ReadonlyArray<string> = [
  "docs/features",
  "docs/research",
  "docs/engineering",
  "docs/discovery",
];

/** Tool input after validation. */
export interface MigrateDevelopmentDocsInput {
  readonly workspaceRoot: string;
  readonly mode: MigrationMode;
  readonly renameDecisionsPath?: string;
  readonly reportDirectory?: string;
}

/** Tool result; structurally a `RepoAutomationExecutionResult`. */
export interface MigrateDevelopmentDocsResult {
  readonly tool: "migrate_development_docs";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
}

/** Dependencies of {@link migrateDevelopmentDocsServiceCall}. */
export interface MigrateDevelopmentDocsServiceCallOptions {
  readonly fileSystem: FileSystem;
  readonly runner: CommandRunner;
  /** Clock; defaults to the system clock, rendered in UTC. */
  readonly now?: () => Date;
  readonly input: MigrateDevelopmentDocsInput;
}

/**
 * Resolve a path against the workspace root with forward slashes.
 *
 * @param root Workspace root.
 * @param value Absolute path, or a path relative to the root.
 * @returns The resolved path.
 */
export function resolveAgainstRoot(root: string, value: string): string {
  const posixValue = toPosixPath(value);
  if (
    nodePath.posix.isAbsolute(posixValue) ||
    /^[A-Za-z]:\//.test(posixValue)
  ) {
    return posixValue;
  }
  return nodePath.posix.join(toPosixPath(root), posixValue);
}

/** Read and parse the decision file, failing with the path named. */
function readDecisions(
  fileSystem: FileSystem,
  root: string,
  path: string | undefined,
): MigrationDecisions | null {
  if (path === undefined) {
    return null;
  }
  const resolved = resolveAgainstRoot(root, path);
  if (!fileSystem.isFile(resolved)) {
    throw new Error(
      `migrate_development_docs refused: decision file not found: ${path}`,
    );
  }
  return parseMigrationDecisions(fileSystem.readTextFile(resolved));
}

/** Render the result summary: every count, then applied counts and untracked files. */
function renderSummary(
  mode: MigrationMode,
  report: MigrationReport,
  applied: MigrationApplyResult | null,
  untracked: ReadonlyArray<string>,
): string {
  const lines = [`migrate_development_docs ${mode}`];
  for (const [key, value] of Object.entries(report.summary)) {
    lines.push(`${key}: ${String(value)}`);
  }
  if (applied !== null) {
    lines.push(
      `applied phase: ${applied.phase}`,
      `applied moves: ${String(applied.moved)}`,
      `applied renames: ${String(applied.renamed)}`,
      `applied rewrites: ${String(applied.rewritten)}`,
      `docs/README.md: ${applied.readmeCreated ? "created" : applied.readmeExisting ? "existing, unchanged" : "not written"}`,
    );
  }
  for (const file of untracked) {
    lines.push(`untracked: ${file}`);
  }
  return lines.join("\n");
}

/**
 * Run the migration in dry-run or apply mode.
 *
 * @param options File system, runner, optional clock and tool input.
 * @returns The result with the summary and the written report files.
 * @throws Error On any refusal, before any move or write.
 */
export function migrateDevelopmentDocsServiceCall(
  options: MigrateDevelopmentDocsServiceCallOptions,
): MigrateDevelopmentDocsResult {
  const { fileSystem, input } = options;
  const root = input.workspaceRoot;
  const git = createMigrationGit(options.runner, root);
  if (!git.isInsideWorkTree()) {
    throw new Error(
      "migrate_development_docs refused: workspace_root is not inside a git work tree",
    );
  }
  const resolvedRoot = resolveDevelopmentDocsRoot(fileSystem, root);
  const decisions = readDecisions(fileSystem, root, input.renameDecisionsPath);
  const untracked = git.listUntrackedFiles(MIGRATION_SOURCE_PATHSPECS);
  const { plan, refusals } = buildMigrationPlan({
    mode: input.mode,
    insideWorkTree: true,
    hasUncommittedTrackedChanges:
      input.mode === "apply" && git.hasUncommittedTrackedChanges(),
    trackedFiles: git.listTrackedFiles([]),
    untrackedFiles: untracked,
    readText: (path) => {
      try {
        return fileSystem.readTextFile(resolveAgainstRoot(root, path));
      } catch {
        return undefined;
      }
    },
    decisions,
    defaultDiscoveryTarget: developmentDocsPath(".dev", "discovery-templates"),
  });
  if (refusals.length > 0) {
    throw new Error(`migrate_development_docs refused: ${refusals.join("; ")}`);
  }
  const applied =
    input.mode === "apply"
      ? applyMigrationPlan(plan, { git, fileSystem, workspaceRoot: root })
      : null;
  const clock = options.now ?? (() => new Date());
  const target =
    input.reportDirectory === undefined
      ? null
      : {
          directory: resolveAgainstRoot(root, input.reportDirectory),
          stem: migrationReportFileName(clock()),
        };
  const report = buildMigrationReport(plan, {
    reportName: target === null ? null : `${target.stem}.json`,
    resolvedRoot,
    refusals,
  });
  const artifacts: string[] = [];
  if (target !== null) {
    fileSystem.ensureDir(target.directory);
    const markdownPath = nodePath.posix.join(
      target.directory,
      `${target.stem}.md`,
    );
    const jsonPath = nodePath.posix.join(
      target.directory,
      `${target.stem}.json`,
    );
    fileSystem.writeTextFile(
      markdownPath,
      renderMigrationReportMarkdown(report),
    );
    fileSystem.writeTextFile(jsonPath, renderMigrationReportJson(report));
    artifacts.push(markdownPath, jsonPath);
  }
  return {
    tool: "migrate_development_docs",
    workspaceRoot: root,
    summary: renderSummary(input.mode, report, applied, plan.untracked),
    artifacts,
  };
}
