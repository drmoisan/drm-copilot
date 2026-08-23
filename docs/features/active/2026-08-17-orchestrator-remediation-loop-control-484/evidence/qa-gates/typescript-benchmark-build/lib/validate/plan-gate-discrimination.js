"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommandRunnerPlanGateRepository = exports.G5_SEVERITY = exports.windowJoin = exports.WARNING_CHANNEL = exports.planQuotesLiteral = exports.patternOperand = exports.isPlaceholder = exports.isCheckableLiteral = exports.hasCrossLinePresence = exports.evaluateCovValue = exports.emptyPlanGateReport = exports.dottedRemedy = exports.covValues = exports.BLOCKING_CHANNEL = exports.extractPlanCommands = void 0;
exports.evaluatePlanGates = evaluatePlanGates;
const plan_gate_commands_1 = require("./plan-gate-commands");
Object.defineProperty(exports, "extractPlanCommands", { enumerable: true, get: function () { return plan_gate_commands_1.extractPlanCommands; } });
const plan_gate_rules_1 = require("./plan-gate-rules");
var plan_gate_rules_2 = require("./plan-gate-rules");
Object.defineProperty(exports, "BLOCKING_CHANNEL", { enumerable: true, get: function () { return plan_gate_rules_2.BLOCKING_CHANNEL; } });
Object.defineProperty(exports, "covValues", { enumerable: true, get: function () { return plan_gate_rules_2.covValues; } });
Object.defineProperty(exports, "dottedRemedy", { enumerable: true, get: function () { return plan_gate_rules_2.dottedRemedy; } });
Object.defineProperty(exports, "emptyPlanGateReport", { enumerable: true, get: function () { return plan_gate_rules_2.emptyPlanGateReport; } });
Object.defineProperty(exports, "evaluateCovValue", { enumerable: true, get: function () { return plan_gate_rules_2.evaluateCovValue; } });
Object.defineProperty(exports, "hasCrossLinePresence", { enumerable: true, get: function () { return plan_gate_rules_2.hasCrossLinePresence; } });
Object.defineProperty(exports, "isCheckableLiteral", { enumerable: true, get: function () { return plan_gate_rules_2.isCheckableLiteral; } });
Object.defineProperty(exports, "isPlaceholder", { enumerable: true, get: function () { return plan_gate_rules_2.isPlaceholder; } });
Object.defineProperty(exports, "patternOperand", { enumerable: true, get: function () { return plan_gate_rules_2.patternOperand; } });
Object.defineProperty(exports, "planQuotesLiteral", { enumerable: true, get: function () { return plan_gate_rules_2.planQuotesLiteral; } });
Object.defineProperty(exports, "WARNING_CHANNEL", { enumerable: true, get: function () { return plan_gate_rules_2.WARNING_CHANNEL; } });
Object.defineProperty(exports, "windowJoin", { enumerable: true, get: function () { return plan_gate_rules_2.windowJoin; } });
/**
 * G5's severity channel, mirroring the Python constant exactly.
 *
 * The value is fixed by the pre-declared corpus measurement recorded in
 * `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08-20T12-02.md`
 * and by nothing else. That run scanned 166 plan files, evaluated 100 candidate
 * literals, and produced a total G5 finding count of 0, so the zero
 * false-positive count measures nothing and does not license Blocking.
 */
exports.G5_SEVERITY = "warning";
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
class CommandRunnerPlanGateRepository {
    workspaceRoot;
    runner;
    constructor(workspaceRoot, runner) {
        this.workspaceRoot = workspaceRoot;
        this.runner = runner;
    }
    /** Run one `git` invocation and return its exit code and trimmed stdout. */
    run(arguments_) {
        const result = this.runner.run(["git", ...arguments_], {
            cwd: this.workspaceRoot,
            allowError: true,
        });
        return { code: result.code, stdout: result.stdout.trim() };
    }
    /** Return tracked paths carrying the literal on a single line. */
    filesContaining(literal) {
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
    isTrackedFile(path) {
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
    isTrackedDirectory(path) {
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
    readTrackedText(path) {
        const normalized = path.split("\\").join("/");
        const result = this.run(["show", `HEAD:${normalized}`]);
        return result.code === 0 ? result.stdout : "";
    }
}
exports.CommandRunnerPlanGateRepository = CommandRunnerPlanGateRepository;
/**
 * Apply the G5 and G6 cascade to one grep-family command, in place.
 *
 * @param report Accumulating report the finding is appended to.
 * @param text Full plan document text.
 * @param command The grep-family command under judgement.
 * @param context Repository seam supplying tracked-tree answers.
 * @returns Nothing. Mutates the supplied report.
 */
function evaluateLiteral(report, text, command, context) {
    const pattern = (0, plan_gate_rules_1.patternOperand)(command.argv);
    if (pattern === null || !(0, plan_gate_rules_1.isCheckableLiteral)(command.argv, pattern)) {
        return;
    }
    // Presence anywhere in the tree exonerates it; the pathspec is ignored.
    if (context.git.filesContaining(pattern).length > 0) {
        return;
    }
    // A literal the plan quotes elsewhere is one the executor must create.
    if ((0, plan_gate_rules_1.planQuotesLiteral)(text, pattern, command.rawSpan)) {
        return;
    }
    // G6 precedes G5: cross-line presence falsifies G5's tree-absence claim.
    if ((0, plan_gate_rules_1.hasCrossLinePresence)(context, pattern)) {
        report.warnings.push(`[${command.taskId}] search literal \`${pattern}\` is present only ` +
            "across adjacent lines of a tracked file and matches no single " +
            "line; a line-oriented search returns zero matches. Search a " +
            "shorter single-line token.");
        return;
    }
    const finding = `[${command.taskId}] search literal \`${pattern}\` is absent from the ` +
        "tracked tree and is not quoted in the plan; the search returns zero " +
        "matches whatever the executor does. Quote the exact literal the task " +
        "will create, or assert a literal that exists.";
    const channel = exports.G5_SEVERITY === plan_gate_rules_1.BLOCKING_CHANNEL ? report.blocking : report.warnings;
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
function evaluateLiteralRules(report, text, commands, context) {
    // A failing or unavailable repository seam discards the whole literal group
    // rather than reporting it partially, and never propagates an exception.
    const literalFindings = (0, plan_gate_rules_1.emptyPlanGateReport)();
    try {
        // Only grep-family commands carry a search literal to judge.
        for (const command of commands) {
            if (command.kind !== "grep") {
                continue;
            }
            evaluateLiteral(literalFindings, text, command, context);
        }
    }
    catch {
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
function evaluatePlanGates(text, context) {
    const report = (0, plan_gate_rules_1.emptyPlanGateReport)();
    const commands = (0, plan_gate_commands_1.extractPlanCommands)(text);
    // Coverage-argument rules run for every command, because a wrapper such as
    // `poetry run` can place a `--cov` argument in any command shape.
    for (const command of commands) {
        for (const cov of (0, plan_gate_rules_1.covValues)(command)) {
            (0, plan_gate_rules_1.evaluateCovValue)(report, command, cov, context);
        }
    }
    if (context !== undefined) {
        evaluateLiteralRules(report, text, commands, context);
    }
    return report;
}
