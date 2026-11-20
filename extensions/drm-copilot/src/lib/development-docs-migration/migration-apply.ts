/**
 * Plan applier (issue #1016, spec "Idempotence").
 *
 * Applies a {@link MigrationPlan} through the {@link MigrationGit} and
 * {@link FileSystem} seams. The tool never commits: with `commit_split`
 * `"moves-then-rewrites"`, a call performs only the moves while any move is
 * pending, and the caller commits before the next call.
 */
import * as nodePath from "node:path";

import type { FileSystem } from "../file-system";
import type { MigrationGit } from "./migration-git";
import { DOCS_README_PATH, type MigrationPlan } from "./migration-plan";

/** Text of the `docs/README.md` boundary note created in apply mode. */
export const DOCS_README_TEXT = [
  "# Documentation",
  "",
  "This folder holds production documentation only.",
  "",
  "Development records (potential entries, active, completed and archived features,",
  "epics, parallel runs, templates, research and engineering notes) live under `.dev/`.",
  "",
].join("\n");

/** Seams the applier writes through. */
export interface ApplyDependencies {
  readonly git: MigrationGit;
  readonly fileSystem: FileSystem;
  /** Workspace root that repository-relative plan paths are joined to. */
  readonly workspaceRoot: string;
}

/** What one apply call did. */
export interface MigrationApplyResult {
  /** `moves` when only the moves ran (moves-then-rewrites); otherwise `all`. */
  readonly phase: "all" | "moves";
  readonly moved: number;
  readonly renamed: number;
  readonly rewritten: number;
  readonly readmeCreated: boolean;
  readonly readmeExisting: boolean;
}

/**
 * Join a repository-relative path to the workspace root with forward slashes.
 *
 * @param root Workspace root.
 * @param relative Repository-relative path.
 * @returns The joined path.
 */
function joinRoot(root: string, relative: string): string {
  return nodePath.posix.join(root.replace(/\\/g, "/"), relative);
}

/**
 * Apply a plan: directory moves, folder renames, rewrites and the README.
 *
 * @param plan A plan from `buildMigrationPlan` with no refusals.
 * @param deps Git and file-system seams and the workspace root.
 * @returns Counts of what was done.
 */
export function applyMigrationPlan(
  plan: MigrationPlan,
  deps: ApplyDependencies,
): MigrationApplyResult {
  const steps = [...plan.moves, ...plan.renames];
  for (const step of steps) {
    deps.fileSystem.ensureDir(
      joinRoot(deps.workspaceRoot, nodePath.posix.dirname(step.to)),
    );
    deps.git.move(step.from, step.to);
  }
  const counts = { moved: plan.moves.length, renamed: plan.renames.length };
  if (plan.commitSplit === "moves-then-rewrites" && steps.length > 0) {
    return {
      phase: "moves",
      ...counts,
      rewritten: 0,
      readmeCreated: false,
      readmeExisting: false,
    };
  }
  for (const rewrite of plan.rewrites) {
    deps.fileSystem.writeTextFile(
      joinRoot(deps.workspaceRoot, rewrite.path),
      rewrite.text,
    );
  }
  const readmePath = joinRoot(deps.workspaceRoot, DOCS_README_PATH);
  const readmeExisting = deps.fileSystem.exists(readmePath);
  // An empty plan writes nothing, including the README of an already migrated tree.
  const readmeCreated =
    !readmeExisting && (steps.length > 0 || plan.rewrites.length > 0);
  if (readmeCreated) {
    deps.fileSystem.ensureDir(joinRoot(deps.workspaceRoot, "docs"));
    deps.fileSystem.writeTextFile(readmePath, DOCS_README_TEXT);
  }
  return {
    phase: "all",
    ...counts,
    rewritten: plan.rewrites.length,
    readmeCreated,
    readmeExisting,
  };
}
