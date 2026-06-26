/**
 * In-process wiring for the `potentialToIssue` service method.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.potentialToIssue` delegates to,
 *     so the service file stays within the 500-line limit while preserving the
 *     method's observable return contract exactly. Mirrors the F2
 *     `validate-orchestration-service-call.ts`, F5
 *     `resolve-prompts-service-call.ts`, and F6
 *     `new-potential-bug-entry-service-call.ts` precedents.
 *
 * Return contract (preserved):
 *     - `tool: "potential_to_issue"`, `workspaceRoot`, and the byte-identical
 *       `summary`: `Promoted '<path>' as a <type> workflow in <mode> mode.`
 *     - On success the result is enriched with `destinationPath` (the normalized
 *       promoted file path) and, when the created issue URL was parsed,
 *       `artifacts` (the created issue URL). No existing extension test asserts
 *       the absence of these fields for `potential_to_issue`, so the enrichment
 *       is additive and safe.
 *
 * Failure surface (preserved):
 *     The prior Python-spawn path threw on a non-zero exit
 *     (`Command exited with code <n>.`). To preserve the extension/MCP failure
 *     behavior, a non-zero promotion outcome is surfaced here by throwing an
 *     `Error` whose message includes the emitted gh output lines. A
 *     `PromotionError` thrown by the workflow (e.g. unauthenticated gh, invalid
 *     work mode) propagates unchanged.
 *
 * Side effects:
 *     Invokes `gh` through the injected command runner (via the narrow
 *     `GhCommandRunner` stdin seam) and reads/writes/moves files through the
 *     port-local filesystem seam.
 */

import { type CommandRunner } from "../subprocess-runner";
import { normalizeGeneratedPath } from "../../repo-automation-service-support";
import {
  type PotentialPromotionType,
  type WorkModeOption,
} from "../../workflow-command-arguments";
import {
  type GhClient,
  type GhCommandResult,
  type GhCommandRunner,
  RealGhClient,
  SpawnSyncGhCommandRunner,
} from "./gh-client";
import { parseIssueReference } from "./content";
import {
  type PotentialFileSystem,
  promotePotential,
  RealPotentialFileSystem,
} from "./promotion";

/** Input for {@link potentialToIssueServiceCall}. */
export interface PotentialToIssueServiceCallInput {
  /** Optional injected filesystem seam; defaults to {@link RealPotentialFileSystem}. */
  readonly fileSystem?: PotentialFileSystem;
  /** Command runner used for the non-stdin `gh` invocations (auth/label/view). */
  readonly runner: CommandRunner;
  /**
   * Optional injected `gh` client (test seam). When omitted, a
   * {@link RealGhClient} is constructed whose non-stdin calls route through
   * {@link runner} and whose stdin `issue create` call uses the stdin-capable
   * {@link SpawnSyncGhCommandRunner}, keeping the shared F1 `CommandRunner`
   * interface unchanged. Tests inject a deterministic fake instead.
   */
  readonly gh?: GhClient;
  /** Workspace root the promotion runs against. */
  readonly workspaceRoot: string;
  /** Path to the potential markdown file. */
  readonly potentialPath: string;
  /** Promotion type label. */
  readonly promotionType: PotentialPromotionType;
  /** Requested work mode. */
  readonly workMode: WorkModeOption;
  /** Optional log sink wired to the service output channel. */
  readonly log?: (message: string) => void;
}

/** Preserved result of the potential-to-issue service call. */
export interface PotentialToIssueServiceCallResult {
  readonly tool: "potential_to_issue";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: readonly string[];
  readonly destinationPath?: string;
}

/**
 * Adapt the F1 {@link CommandRunner} to the narrow {@link GhCommandRunner} seam.
 *
 * Purpose:
 *     The `gh` client needs an optional stdin body for `issue create
 *     --body-file -`, which the shared `CommandRunner.run` signature does not
 *     accept. This adapter routes the no-stdin `gh` calls (auth/label/view)
 *     through the injected F1 runner with `allowError: true` (the workflow
 *     inspects the exit code itself), and routes the single stdin `issue
 *     create` call through the stdin-capable {@link SpawnSyncGhCommandRunner}.
 *     This keeps the shared F1 `CommandRunner` interface unchanged while still
 *     delivering the issue body on stdin in production.
 *
 * Side effects:
 *     Spawns `gh` child processes (directly for the stdin call, via the
 *     injected runner otherwise).
 */
class CommandRunnerGhAdapter implements GhCommandRunner {
  private readonly stdinRunner = new SpawnSyncGhCommandRunner();

  constructor(private readonly runner: CommandRunner) {}

  /**
   * Run `gh` with the given arguments and optional stdin body.
   *
   * @param ghPath Resolved `gh` executable path.
   * @param args Argument vector passed to `gh`.
   * @param input Optional stdin body (present only for `issue create`).
   * @returns Captured stdout, stderr, and exit code.
   */
  run(
    ghPath: string,
    args: readonly string[],
    input?: string,
  ): GhCommandResult {
    // The stdin body cannot flow through the F1 CommandRunner, so the single
    // body-bearing call is delegated to the stdin-capable spawn runner.
    if (input !== undefined) {
      return this.stdinRunner.run(ghPath, args, input);
    }

    // No-stdin calls route through the injected F1 runner with allowError so a
    // non-zero exit returns a result instead of throwing.
    const result = this.runner.run([ghPath, ...args], { allowError: true });
    return { stdout: result.stdout, stderr: result.stderr, code: result.code };
  }
}

/**
 * Promote a potential file to a GitHub issue in-process and return the
 * preserved service result record.
 *
 * @param input Filesystem (optional), runner, workspace root, potential path,
 *   promotion type, work mode, and optional log sink.
 * @returns The preserved result record (`tool`, `workspaceRoot`, exact
 *   `summary`) enriched with `destinationPath` and `artifacts` on success.
 * @throws Error When the promotion outcome is non-zero (message includes the
 *   emitted gh output lines), or a `PromotionError` from the workflow.
 */
export function potentialToIssueServiceCall(
  input: PotentialToIssueServiceCallInput,
): PotentialToIssueServiceCallResult {
  // Use the injected gh client when provided (test seam); otherwise construct a
  // RealGhClient whose non-stdin calls route through the injected F1 runner and
  // whose stdin create call uses the stdin-capable spawn runner.
  const ghClient =
    input.gh ??
    new RealGhClient({ runner: new CommandRunnerGhAdapter(input.runner) });

  const outcome = promotePotential({
    potentialPath: input.potentialPath,
    promotionType: input.promotionType,
    workMode: input.workMode,
    workspace: input.workspaceRoot,
    fs: input.fileSystem ?? new RealPotentialFileSystem(),
    gh: ghClient,
    ...(input.log === undefined ? {} : { emit: input.log }),
  });

  // Surface a non-zero promotion outcome as a thrown Error, preserving the
  // prior non-zero-exit failure surface (which threw on a non-zero exit). The
  // emitted gh output lines are included so the failure signal is retained.
  if (outcome.exitCode !== 0) {
    const detail =
      outcome.messages.length > 0 ? `\n${outcome.messages.join("\n")}` : "";
    throw new Error(`Command exited with code ${outcome.exitCode}.${detail}`);
  }

  const summary = `Promoted '${input.potentialPath}' as a ${input.promotionType} workflow in ${input.workMode} mode.`;

  // Enrich with the created issue URL when it was parsed from the gh output.
  const [issueUrl] = parseIssueReference(outcome.messages);

  return {
    tool: "potential_to_issue",
    workspaceRoot: input.workspaceRoot,
    summary,
    ...(outcome.destination === undefined
      ? {}
      : { destinationPath: normalizeGeneratedPath(outcome.destination) }),
    ...(issueUrl === null ? {} : { artifacts: [issueUrl] }),
  };
}
