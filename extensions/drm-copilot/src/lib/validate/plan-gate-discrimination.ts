import type { CommandRunner } from "../subprocess-runner";
import { extractPlanCommands, type PlanCommand } from "./plan-gate-commands";
import {
  BLOCKING_CHANNEL,
  covValues,
  emptyPlanGateReport,
  evaluateCovValue,
  hasCrossLinePresence,
  isCheckableLiteral,
  patternOperand,
  planQuotesLiteral,
  type PlanGateContext,
  type PlanGateGitRepository,
  type PlanGateReport,
} from "./plan-gate-rules";

/**
 * Discriminate falsifiable from non-discriminating atomic-plan acceptance gates.
 *
 * Purpose:
 *     Port `scripts/dev_tools/plan_gate_discrimination.py`. Hold the Git-backed
 *     repository adapter, the search-literal rules G5 and G6 that depend on it,
 *     and the public `evaluatePlanGates` entry point, and re-export every symbol
 *     declared in `plan-gate-rules.ts` so the specification's public surface is
 *     a single module.
 *
 * Invariants / Constraints:
 *     - Every finding string is byte-identical to the Python rule's message.
 *     - Offending values are rendered between backticks. No `pythonRepr`-style
 *       formatting is used, because the Python side does not use `repr()`.
 *     - The module never imports `orchestration-artifacts.ts`, which imports it.
 *
 * Side Effects:
 *     Queries the injected `git` seam when a context is supplied.
 */

export { extractPlanCommands };
export type { PlanCommand };
export {
  BLOCKING_CHANNEL,
  covValues,
  dottedRemedy,
  emptyPlanGateReport,
  evaluateCovValue,
  hasCrossLinePresence,
  isCheckableLiteral,
  isPlaceholder,
  patternOperand,
  planQuotesLiteral,
  WARNING_CHANNEL,
  windowJoin,
} from "./plan-gate-rules";
export type {
  CovValue,
  PlanGateContext,
  PlanGateGitRepository,
  PlanGateReport,
} from "./plan-gate-rules";

/**
 * G5's severity channel, mirroring the Python constant exactly.
 *
 * The value is fixed by the pre-declared corpus measurement recorded in
 * `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md`
 * and by nothing else. That run scanned 166 plan files, evaluated 100 candidate
 * literals, and produced a total G5 finding count of 0, so the zero
 * false-positive count measures nothing and does not license Blocking.
 */
export const G5_SEVERITY: string = "warning";

/**
 * Git-backed plan-gate repository adapter over an injectable runner.
 *
 * Purpose and responsibilities:
 *     Answer the tracked-tree questions the rules ask by shelling out to the
 *     same `git` binary the command under validation would use, so the gate
 *     never reimplements matching or tracked-path resolution. It issues
 *     `git grep -F -l`, `git ls-files`, and `git show HEAD:` and translates
 *     their output; findings and severities are not its concern.
 *
 * Usage, invariants, and side effects:
 *     Construct with the workspace root and a command runner, then pass the
 *     instance as the `git` member of a {@link PlanGateContext}. Every
 *     invocation passes `allowError: true`, so a non-zero `git` exit becomes a
 *     negative answer rather than a thrown error, and each query spawns one
 *     `git` subprocess through the injected runner.
 */
export class CommandRunnerPlanGateRepository implements PlanGateGitRepository {
  public constructor(
    private readonly workspaceRoot: string,
    private readonly runner: CommandRunner,
  ) {}

  /** Run one `git` invocation and return its exit code and trimmed stdout. */
  private run(arguments_: readonly string[]): {
    readonly code: number;
    readonly stdout: string;
  } {
    const result = this.runner.run(["git", ...arguments_], {
      cwd: this.workspaceRoot,
      allowError: true,
    });
    return { code: result.code, stdout: result.stdout.trim() };
  }

  /** Return tracked paths carrying the literal on a single line. */
  public filesContaining(literal: string): string[] {
    const result = this.run(["grep", "-F", "-l", "--", literal]);
    if (result.code !== 0 || result.stdout === "") {
      return [];
    }
    return result.stdout
      .split(/\r\n|\n|\r/)
      .map((line) => line.trim())
      .filter((line) => line !== "");
  }

  /** Return whether `git ls-files` lists the path itself. */
  public isTrackedFile(path: string): boolean {
    const normalized = path.split("\\").join("/");
    const result = this.run(["ls-files", "--", normalized]);
    if (result.code !== 0 || result.stdout === "") {
      return false;
    }
    return result.stdout
      .split(/\r\n|\n|\r/)
      .some((line) => line.trim() === normalized);
  }

  /** Return whether entries exist beneath the path but none equals it. */
  public isTrackedDirectory(path: string): boolean {
    const normalized = path.split("\\").join("/").replace(/\/+$/, "");
    const result = this.run(["ls-files", "--", normalized]);
    if (result.code !== 0 || result.stdout === "") {
      return false;
    }
    const listed = result.stdout
      .split(/\r\n|\n|\r/)
      .map((line) => line.trim())
      .filter((line) => line !== "");
    return listed.length > 0 && listed.every((entry) => entry !== normalized);
  }

  /** Return the committed text of the path at `HEAD`, or an empty string. */
  public readTrackedText(path: string): string {
    const normalized = path.split("\\").join("/");
    const result = this.run(["show", `HEAD:${normalized}`]);
    return result.code === 0 ? result.stdout : "";
  }
}

/**
 * Apply the G5 and G6 cascade to one grep-family command, in place.
 *
 * @param report Accumulating report the finding is appended to.
 * @param text Full plan document text.
 * @param command The grep-family command under judgement.
 * @param context Repository seam supplying tracked-tree answers.
 * @returns Nothing. Mutates the supplied report.
 */
function evaluateLiteral(
  report: PlanGateReport,
  text: string,
  command: PlanCommand,
  context: PlanGateContext,
): void {
  const pattern = patternOperand(command.argv);
  if (pattern === null || !isCheckableLiteral(command.argv, pattern)) {
    return;
  }

  // Presence anywhere in the tree exonerates it; the pathspec is ignored.
  if (context.git.filesContaining(pattern).length > 0) {
    return;
  }

  // A literal the plan quotes elsewhere is one the executor must create.
  if (planQuotesLiteral(text, pattern, command.rawSpan)) {
    return;
  }

  // G6 precedes G5: cross-line presence falsifies G5's tree-absence claim.
  if (hasCrossLinePresence(context, pattern)) {
    report.warnings.push(
      `[${command.taskId}] search literal \`${pattern}\` is present only ` +
        "across adjacent lines of a tracked file and matches no single " +
        "line; a line-oriented search returns zero matches. Search a " +
        "shorter single-line token.",
    );
    return;
  }

  const finding =
    `[${command.taskId}] search literal \`${pattern}\` is absent from the ` +
    "tracked tree and is not quoted in the plan; the search returns zero " +
    "matches whatever the executor does. Quote the exact literal the task " +
    "will create, or assert a literal that exists.";
  const channel =
    G5_SEVERITY === BLOCKING_CHANNEL ? report.blocking : report.warnings;
  channel.push(finding);
}

/**
 * Apply G5 and G6 to every grep-family command.
 *
 * @param report Accumulating report the findings are appended to.
 * @param text Full plan document text.
 * @param commands Every extracted command, in source order.
 * @param context Repository seam supplying tracked-tree answers.
 * @returns Nothing. Mutates the supplied report.
 */
function evaluateLiteralRules(
  report: PlanGateReport,
  text: string,
  commands: readonly PlanCommand[],
  context: PlanGateContext,
): void {
  // A failing or unavailable repository seam discards the whole literal group
  // rather than reporting it partially, and never propagates an exception.
  const literalFindings = emptyPlanGateReport();
  try {
    // Only grep-family commands carry a search literal to judge.
    for (const command of commands) {
      if (command.kind !== "grep") {
        continue;
      }
      evaluateLiteral(literalFindings, text, command, context);
    }
  } catch {
    // Broad by contract: a validation run must never fail because the
    // repository could not be queried (spec AC10, graceful degradation).
    return;
  }

  report.blocking.push(...literalFindings.blocking);
  report.warnings.push(...literalFindings.warnings);
}

/**
 * Evaluate the plan acceptance-gate rule set against plan text.
 *
 * @param text Full plan document text.
 * @param context Repository seam. When omitted only the context-free rules G1
 *     and G4 run, so the returned Blocking list is byte-identical to the
 *     pre-change output for the same text.
 * @returns Blocking and Warning findings in source order. A failing repository
 *     seam degrades to zero literal findings rather than propagating.
 */
export function evaluatePlanGates(
  text: string,
  context?: PlanGateContext,
): PlanGateReport {
  const report = emptyPlanGateReport();
  const commands = extractPlanCommands(text);

  // Coverage-argument rules run for every command, because a wrapper such as
  // `poetry run` can place a `--cov` argument in any command shape.
  for (const command of commands) {
    for (const cov of covValues(command)) {
      evaluateCovValue(report, command, cov, context);
    }
  }

  if (context !== undefined) {
    evaluateLiteralRules(report, text, commands, context);
  }

  return report;
}
