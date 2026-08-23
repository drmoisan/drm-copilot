"use strict";
/**
 * `gh` CLI client seam for the potential-to-issue promotion workflow.
 *
 * Purpose:
 *     In-process TypeScript port of the `gh` client in the bundled
 *     `resources/scripts/dev_tools/potential_to_issue.py`
 *     (`GhResult`, `GhClient`, `RealGhClient`). The workflow module uses this
 *     seam for all GitHub interactions (auth check, issue create, label create,
 *     issue view) so tests can inject a deterministic fake.
 *
 * Parity:
 *     Argument vectors for `auth status`, `issue create`, `label create`, and
 *     `issue view`, the `--json` field list, the label color/description, and
 *     the missing-`gh` error message are byte-identical to the Python source.
 *     Every invocation runs with `allowError: true` (Python uses `check=False`
 *     and inspects the return code), and `GhResult.output` is the combined
 *     stdout+stderr split into lines.
 *
 * Design choice (parity-note option b):
 *     The F1 `CommandRunner.run` signature does not accept stdin. Rather than
 *     widen the shared interface, this module defines a narrow
 *     {@link GhCommandRunner} seam that adds an optional `input?: string` for
 *     the `issue create --body-file -` stdin body. The production default
 *     ({@link SpawnSyncGhCommandRunner}) wraps `node:child_process.spawnSync`
 *     directly so stdin can be supplied; the shared F1 interface is unchanged.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.RealGhClient = exports.SpawnSyncGhCommandRunner = exports.GH_NOT_FOUND_MESSAGE = exports.FEATURE_LABEL_DESCRIPTION = exports.FEATURE_LABEL_COLOR = void 0;
exports.defaultGhPathLookup = defaultGhPathLookup;
const node_child_process_1 = require("node:child_process");
/** Label color applied when creating the promotion label (byte-identical). */
exports.FEATURE_LABEL_COLOR = "0e8a16";
/** Label description applied when creating the promotion label. */
exports.FEATURE_LABEL_DESCRIPTION = "Feature work";
/** Missing-`gh` error message (byte-identical to the Python source). */
exports.GH_NOT_FOUND_MESSAGE = "gh CLI not found on PATH. Install gh and authenticate first.";
/**
 * Production {@link GhCommandRunner} backed by `node:child_process.spawnSync`.
 *
 * Purpose:
 *     Invoke `gh` without a shell, capturing UTF-8 stdout/stderr and the exit
 *     code, and supplying an optional stdin body. Mirrors the Python
 *     `subprocess.run(..., input=body, text=True, encoding="utf-8",
 *     capture_output=True, check=False)` call.
 *
 * Side effects:
 *     Spawns a child process.
 */
class SpawnSyncGhCommandRunner {
    /**
     * Run `gh` with the given arguments and optional stdin body.
     *
     * @param ghPath Resolved `gh` executable path.
     * @param args Argument vector passed verbatim.
     * @param input Optional UTF-8 stdin body.
     * @returns Captured stdout, stderr, and exit code (status null treated as 1).
     */
    run(ghPath, args, input) {
        const completed = (0, node_child_process_1.spawnSync)(ghPath, [...args], {
            shell: false,
            encoding: "utf8",
            ...(input === undefined ? {} : { input }),
        });
        const stdout = typeof completed.stdout === "string" ? completed.stdout : "";
        const stderr = typeof completed.stderr === "string" ? completed.stderr : "";
        // A null status (signal/spawn failure) is treated as a non-zero failure.
        const code = completed.status === null ? 1 : completed.status;
        return { stdout, stderr, code };
    }
}
exports.SpawnSyncGhCommandRunner = SpawnSyncGhCommandRunner;
/**
 * Resolve the `gh` executable path, mirroring Python `shutil.which("gh")`.
 *
 * Uses the platform `where`/`which` lookup. Returns the first resolved path, or
 * null when `gh` is not found. This is the injectable production default so
 * tests never touch the real PATH.
 *
 * @returns The resolved `gh` path, or null when absent.
 */
function defaultGhPathLookup() {
    // Use the platform locator (`where` on Windows, `which` elsewhere) to mirror
    // shutil.which; a non-zero exit or empty output means gh is absent.
    const locator = process.platform === "win32" ? "where" : "which";
    try {
        const output = (0, node_child_process_1.execSync)(`${locator} gh`, { encoding: "utf8" });
        const first = output.split(/\r?\n/).find((line) => line.trim().length > 0);
        return first ? first.trim() : null;
    }
    catch {
        return null;
    }
}
/**
 * Split combined stdout+stderr into lines, mirroring Python `str.splitlines()`.
 *
 * Python's `splitlines()` splits on `\n`, `\r\n`, and `\r` and does not produce
 * a trailing empty element for a terminal newline.
 *
 * @param combined Concatenated stdout+stderr text.
 * @returns The text split into lines with no trailing empty element.
 */
function splitCombinedOutput(combined) {
    if (combined === "") {
        return [];
    }
    // Split on all line-ending forms; drop a single trailing empty element that a
    // terminal newline would otherwise produce (matches Python splitlines).
    const lines = combined.split(/\r\n|\r|\n/);
    if (lines.length > 0 && lines[lines.length - 1] === "") {
        lines.pop();
    }
    return lines;
}
/**
 * Production {@link GhClient} backed by the `gh` CLI.
 *
 * Purpose:
 *     Run the auth/create/label/view `gh` invocations the promotion workflow
 *     needs, capturing combined output and the exit code, and never throwing on
 *     a non-zero exit (the workflow inspects the code itself).
 *
 * Responsibilities:
 *     - Resolve the `gh` executable via an injectable lookup; fail fast with the
 *       byte-identical missing-`gh` message when absent.
 *     - Build the exact argument vectors the Python source uses.
 *     - Convert combined stdout+stderr into split lines for {@link GhResult}.
 *
 * Side effects:
 *     Spawns `gh` child processes through the injected {@link GhCommandRunner}.
 *
 * Invariants:
 *     The resolved `gh` path is non-null after construction.
 */
class RealGhClient {
    ghPath;
    runner;
    /**
     * Construct a client, resolving and validating the `gh` executable.
     *
     * @param options Optional injected `runner` (defaults to
     *   {@link SpawnSyncGhCommandRunner}) and `ghPathLookup` (defaults to
     *   {@link defaultGhPathLookup}) so tests never touch the real PATH.
     * @throws Error With {@link GH_NOT_FOUND_MESSAGE} when `gh` cannot be resolved.
     */
    constructor(options) {
        const lookup = options?.ghPathLookup ?? defaultGhPathLookup;
        const resolved = lookup();
        // Fail fast when gh is absent, mirroring the Python FileNotFoundError.
        if (!resolved) {
            throw new Error(exports.GH_NOT_FOUND_MESSAGE);
        }
        this.ghPath = resolved;
        this.runner = options?.runner ?? new SpawnSyncGhCommandRunner();
    }
    /**
     * Run a `gh` invocation and build a {@link GhResult} from combined output.
     *
     * @param args Argument vector (without the `gh` executable).
     * @param input Optional stdin body.
     * @returns The combined-output/exit-code result.
     */
    runGh(args, input) {
        const result = this.runner.run(this.ghPath, args, input);
        const combined = (result.stdout || "") + (result.stderr || "");
        return { output: splitCombinedOutput(combined), exitCode: result.code };
    }
    /**
     * @returns True when `gh auth status` exits zero.
     */
    isAuthenticated() {
        const result = this.runner.run(this.ghPath, ["auth", "status"]);
        return result.code === 0;
    }
    /**
     * Create a GitHub issue with the body supplied on stdin.
     *
     * @param title Issue title.
     * @param body Issue body (passed on stdin via `--body-file -`).
     * @param promotionType Promotion label to attach.
     * @returns The combined-output/exit-code result.
     */
    issueCreate(title, body, promotionType) {
        const args = [
            "issue",
            "create",
            "--title",
            title,
            "--body-file",
            "-",
            "--label",
            promotionType,
        ];
        return this.runGh(args, body);
    }
    /**
     * Create the promotion label with the canonical color and description.
     *
     * @param label Label name to create.
     * @returns The combined-output/exit-code result.
     */
    ensureLabel(label) {
        const args = [
            "label",
            "create",
            label,
            "--color",
            exports.FEATURE_LABEL_COLOR,
            "--description",
            exports.FEATURE_LABEL_DESCRIPTION,
        ];
        return this.runGh(args);
    }
    /**
     * View an issue's JSON metadata with the canonical field list.
     *
     * @param issueNumber Issue number to view.
     * @returns The combined-output/exit-code result.
     */
    issueView(issueNumber) {
        const args = [
            "issue",
            "view",
            issueNumber,
            "--json",
            "number,title,url,author,updatedAt",
        ];
        return this.runGh(args);
    }
}
exports.RealGhClient = RealGhClient;
