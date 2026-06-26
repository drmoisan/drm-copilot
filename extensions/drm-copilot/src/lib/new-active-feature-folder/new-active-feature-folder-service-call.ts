/**
 * In-process wiring for the `newActiveFeatureFolder` service method.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.newActiveFeatureFolder`
 *     delegates to, so the service file stays within the 500-line limit while
 *     preserving the method's observable return contract exactly. Mirrors the
 *     F2 `validate-orchestration-service-call.ts`, F5
 *     `resolve-prompts-service-call.ts`, F6 `new-potential-bug-entry-service-
 *     call.ts`, and F7 `potential-to-issue/potential-to-issue-service-call.ts`
 *     precedents.
 *
 * Return contract (preserved):
 *     - `tool: "new_active_feature_folder"`, `workspaceRoot`, and the
 *       byte-identical `summary`:
 *       `Created a new active <type> feature folder for '<featureName>'.`
 *     - On success the result is enriched with `destinationPath` (the normalized
 *       created folder path) and, when a potential file was moved to issue.md,
 *       `artifacts` (the moved issue.md path). No existing extension test
 *       asserts the absence of these fields for `new_active_feature_folder`, so
 *       the enrichment is additive and safe (decision recorded in the P0-T2
 *       Phase 0 artifact).
 *
 * --template-root parity:
 *     The service forwards `this.templateRoot` (the bundled
 *     `resources/feature-templates` directory) as `templateRoot`, replicating
 *     the Python wrapper's `--template-root` injection. The helper passes it to
 *     `createActiveFolder({ templateRoot, ... })`.
 *
 * Failure surface (preserved):
 *     The prior Python-spawn path threw on a non-zero exit
 *     (`Command exited with code <n>.`). A workflow `Error` (invalid type,
 *     invalid name, missing template, target exists, invalid work mode)
 *     propagates here unchanged, preserving its message. This matches the
 *     surfaced-failure behavior the prior path provided.
 *
 * Side effects:
 *     Reads/writes/moves files through the port-local {@link FolderFileSystem}
 *     seam and resolves optional issue metadata via the injected
 *     {@link CommandRunner} (`gh`). Performs no editor launch (a no-op launcher
 *     is passed so the MCP/non-interactive path never spawns `code`).
 */

import { type CommandRunner } from "../subprocess-runner";
import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import {
  type PotentialPromotionType,
  type WorkModeOption,
} from "../../workflow-command-arguments";
import {
  createActiveFolder,
  defaultIssueFetcher,
  type FolderFileSystem,
  type IssueMeta,
  RealFolderFileSystem,
} from "./index";

/** Input for {@link newActiveFeatureFolderServiceCall}. */
export interface NewActiveFeatureFolderServiceCallInput {
  /** Optional injected filesystem seam; defaults to {@link RealFolderFileSystem}. */
  readonly fileSystem?: FolderFileSystem;
  /** Command runner used for the optional guarded `gh` issue-title fetch. */
  readonly runner: CommandRunner;
  /** Workspace root the creation runs against. */
  readonly workspaceRoot: string;
  /** Validated feature/folder name. */
  readonly featureName: string;
  /** Promotion/feature type. */
  readonly type: PotentialPromotionType;
  /** Optional issue number (omitted when undefined, matching the prior arg builder). */
  readonly issueNumber?: string;
  /** Requested work mode. */
  readonly workMode: WorkModeOption;
  /** Bundled feature-template root (`<extensionRoot>/resources/feature-templates`). */
  readonly templateRoot: string;
  /** Optional log sink wired to the service output channel. */
  readonly log?: (message: string) => void;
}

/** Preserved result of the new-active-feature-folder service call. */
export interface NewActiveFeatureFolderServiceCallResult {
  readonly tool: "new_active_feature_folder";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: readonly string[];
  readonly destinationPath?: string;
}

/**
 * Create a new active feature folder in-process and return the preserved
 * service result record.
 *
 * Binds a {@link defaultIssueFetcher}-style fetcher to the injected runner so
 * the optional `gh` issue-title fetch routes through the F1 runner, and passes
 * a no-op `codeLauncher` so the service/MCP path never spawns an editor (the
 * manual-open warning lines are emitted through the injected log instead).
 *
 * @param input Filesystem (optional), runner, workspace root, feature name,
 *   type, issue number (optional), work mode, template root, and optional log.
 * @returns The preserved result record (`tool`, `workspaceRoot`, exact
 *   `summary`) enriched with `destinationPath` and (when present) `artifacts`.
 * @throws Error When the workflow throws (invalid type/name, missing template,
 *   target exists, invalid work mode); the message is preserved.
 */
export function newActiveFeatureFolderServiceCall(
  input: NewActiveFeatureFolderServiceCallInput,
): NewActiveFeatureFolderServiceCallResult {
  const result = createActiveFolder({
    featureName: input.featureName,
    featureType: input.type,
    issueNumber: input.issueNumber ?? null,
    workMode: input.workMode,
    workspace: input.workspaceRoot,
    templateRoot: input.templateRoot,
    fs: input.fileSystem ?? new RealFolderFileSystem(),
    // Route the guarded gh issue fetch through the injected F1 runner.
    issueFetcher: (issueNumber: string): IssueMeta | null =>
      defaultIssueFetcher(issueNumber, input.runner),
    // No-op launcher: the MCP/non-interactive path must never open an editor.
    codeLauncher: () => false,
    ...(input.log === undefined ? {} : { emit: input.log }),
  });

  return {
    tool: "new_active_feature_folder",
    workspaceRoot: input.workspaceRoot,
    summary: `Created a new active ${input.type} feature folder for '${input.featureName}'.`,
    destinationPath: normalizeGeneratedPath(result.target),
    // Enrich with the moved issue.md path when a potential file was seeded.
    ...(result.potentialIssuePath === null
      ? {}
      : { artifacts: [normalizeGeneratedPath(result.potentialIssuePath)] }),
  };
}
