/**
 * In-process wiring for the `newPotentialBugEntry` service method.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.newPotentialBugEntry` delegates
 *     to, so the service file stays within the 500-line limit while preserving
 *     the method's observable return contract exactly. Mirrors the F2
 *     `validate-orchestration-service-call.ts` and F5 `resolve-prompts-service-
 *     call.ts` precedents.
 *
 * Responsibilities:
 *     - Invoke the in-process {@link createBugEntry} port with the service's
 *       injected filesystem and a git/env-backed author provider.
 *     - Pass a no-op editor launcher (returns `false`) so `code`/`code-insiders`
 *       never launches in the non-interactive/MCP path; the manual-open warning
 *       lines are emitted through the injected log sink instead.
 *     - Build the preserved service result record (tool/workspaceRoot/summary)
 *       and enrich it with the created file path as a single `artifacts` entry.
 *
 * Side effects:
 *     Reads the template and writes the generated markdown file through the
 *     injected {@link FileSystem}; resolves the author via the injected
 *     {@link CommandRunner} (git). Performs no editor launch.
 */

import { type FileSystem } from "./file-system";
import { type CommandRunner } from "./subprocess-runner";
import { normalizeGeneratedPath } from "../repo-automation-service-support";
import {
  createBugEntry,
  defaultEnvLookup,
  defaultGitConfigLookup,
  getAuthor,
} from "./new-potential-bug-entry";

/** Input for {@link newPotentialBugEntryServiceCall}. */
export interface NewPotentialBugEntryServiceCallInput {
  /** Injected filesystem used for the template read and the output write. */
  readonly fileSystem: FileSystem;
  /** Command runner used by the git-backed author lookup. */
  readonly runner: CommandRunner;
  /** Workspace root the target/output paths are resolved against. */
  readonly workspaceRoot: string;
  /** Validated kebab-case short name for the generated bug entry. */
  readonly shortName: string;
  /** Bundled feature-template root (`<extensionRoot>/resources/feature-templates`). */
  readonly templateRoot: string;
  /** Optional log sink wired to the service output channel. */
  readonly log?: (message: string) => void;
}

/** Preserved result of the new-potential-bug-entry service call. */
export interface NewPotentialBugEntryServiceCallResult {
  readonly tool: "new_potential_bug_entry";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: ReadonlyArray<string>;
}

/**
 * Create a potential bug entry in-process and return the preserved service
 * result record.
 *
 * Passes a no-op editor launcher so the MCP/non-interactive path never spawns
 * `code`/`code-insiders`; the library emits the manual-open warning lines
 * through the injected log sink. The author is resolved via the git-backed
 * lookup (using the injected runner) with the `USERNAME`/`"Unknown"` fallback.
 *
 * @param input Filesystem, runner, workspace root, short name, template root,
 *   and optional log sink.
 * @returns The preserved result record (`tool`, `workspaceRoot`, exact
 *   `summary`) enriched with the created file path as a single `artifacts`
 *   entry.
 * @throws Error When the short name is invalid or when the template is absent
 *   (surfaced as a file-not-found read error by the library).
 */
export function newPotentialBugEntryServiceCall(
  input: NewPotentialBugEntryServiceCallInput,
): NewPotentialBugEntryServiceCallResult {
  const createdPath = createBugEntry({
    shortName: input.shortName,
    workspace: input.workspaceRoot,
    fs: input.fileSystem,
    templateRoot: input.templateRoot,
    authorProvider: () =>
      getAuthor(
        (key) => defaultGitConfigLookup(input.runner, key),
        defaultEnvLookup,
      ),
    // No-op launcher: the MCP/non-interactive path must never open an editor.
    codeLauncher: () => false,
    ...(input.log === undefined ? {} : { log: input.log }),
  });

  return {
    tool: "new_potential_bug_entry",
    workspaceRoot: input.workspaceRoot,
    summary: `Created a new potential bug entry for '${input.shortName}'.`,
    artifacts: [normalizeGeneratedPath(createdPath)],
  };
}
