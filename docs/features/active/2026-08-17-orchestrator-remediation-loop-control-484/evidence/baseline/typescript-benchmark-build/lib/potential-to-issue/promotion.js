"use strict";
/**
 * Potential-to-issue promotion workflow.
 *
 * Purpose:
 *     In-process TypeScript port of the `promote_potential` workflow in the
 *     bundled `scripts/dev_tools/potential_to_issue.py`. Drives the
 *     end-to-end promotion: validate inputs, check gh auth, parse the potential
 *     file, build the issue body, create the issue (with a single missing-label
 *     recovery), update the potential-file metadata, and move the file into the
 *     promoted folder.
 *
 * Parity:
 *     Every `PromotionError` message, emitted line, constant, and decision
 *     branch is byte-identical to the Python source. The missing-label recovery
 *     only recovers from the specific `could not add label: '<label>' not found`
 *     failure for the selected promotion label.
 *
 * Seams:
 *     The workflow uses a port-local {@link PotentialFileSystem} (NOT the shared
 *     F1 `FileSystem`, which lacks `exists`/`move`/`writeLines`/`resolvePath`)
 *     and the {@link GhClient} seam. Tests inject in-memory fakes; production
 *     defaults to {@link RealPotentialFileSystem} and `RealGhClient`.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.PromotionError = exports.TITLE_PREFIXES = exports.PROMOTION_TYPES = exports.RealPotentialFileSystem = void 0;
exports.isMissingLabelFailure = isMissingLabelFailure;
exports.promotePotential = promotePotential;
const nodePath = __importStar(require("node:path"));
const prompt_mode_contract_1 = require("../prompt-mode-contract");
const promotion_filesystem_1 = require("./promotion-filesystem");
// Re-export the port-local filesystem seam so consumers can import it from the
// workflow module (the seam was extracted to keep this file under 500 lines).
var promotion_filesystem_2 = require("./promotion-filesystem");
Object.defineProperty(exports, "RealPotentialFileSystem", { enumerable: true, get: function () { return promotion_filesystem_2.RealPotentialFileSystem; } });
const content_1 = require("./content");
const gh_client_1 = require("./gh-client");
/** Accepted promotion types (byte-identical to the Python tuple). */
exports.PROMOTION_TYPES = [
    "epic",
    "feature",
    "refactor",
    "bug",
];
/** Issue title prefixes keyed by promotion type. */
exports.TITLE_PREFIXES = {
    epic: "Epic",
    feature: "Feature",
    refactor: "Refactor",
    bug: "Bug",
};
/** Raised when a promotion precondition fails. */
class PromotionError extends Error {
    /**
     * @param message Byte-identical failure message from the Python source.
     */
    constructor(message) {
        super(message);
        this.name = "PromotionError";
    }
}
exports.PromotionError = PromotionError;
/**
 * Return whether gh output reports a missing-label create failure.
 *
 * Mirrors Python `_is_missing_label_failure`: any output line (lowercased)
 * containing `could not add label: '<label>' not found`.
 *
 * @param output gh output lines.
 * @param label Promotion label being created.
 * @returns True when the specific missing-label failure is present.
 */
function isMissingLabelFailure(output, label) {
    const expectedFragment = `could not add label: '${label}' not found`;
    return output.some((line) => line.toLowerCase().includes(expectedFragment));
}
/**
 * Compute the POSIX path of `resolved` relative to `workspacePath`.
 *
 * Mirrors Python `Path(os.path.relpath(resolved, workspace)).as_posix()` with a
 * fallback to the resolved path string on a relpath error (e.g. a different
 * drive on Windows raises in Python; `node:path.relative` does not, so the
 * try/catch is preserved for parity even though it rarely triggers).
 *
 * @param resolved Resolved potential-file path.
 * @param workspacePath Workspace root.
 * @returns The POSIX relative path, or the resolved path on failure.
 */
function computeRelativePath(resolved, workspacePath) {
    try {
        const relative = nodePath.relative(workspacePath, resolved);
        return relative.split(nodePath.sep).join("/");
    }
    catch {
        // Mirror the Python ValueError fallback to the resolved path string.
        return resolved;
    }
}
/**
 * Join path segments using forward slashes, collapsing duplicate separators.
 *
 * Keeps the result OS-neutral (forward slashes) so emitted and returned paths
 * match the Python `Path` join behavior on POSIX-style workspace inputs.
 *
 * @param base Base path (may contain either separator form).
 * @param relative Relative path appended to the base.
 * @returns The combined forward-slash path.
 */
function posixJoin(base, relative) {
    const normalizedBase = base.replace(/\\/g, "/").replace(/\/+$/, "");
    const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
    return `${normalizedBase}/${normalizedRelative}`;
}
/**
 * Return the final path segment, splitting on either separator form.
 *
 * Mirrors Python `Path(...).name` for the resolved potential-file path.
 *
 * @param pathStr Path to take the basename of.
 * @returns The final path segment.
 */
function posixBasename(pathStr) {
    const normalized = pathStr.replace(/\\/g, "/").replace(/\/+$/, "");
    const lastSlash = normalized.lastIndexOf("/");
    return lastSlash === -1 ? normalized : normalized.slice(lastSlash + 1);
}
/**
 * Build the issue body for the selected mode and promotion type.
 *
 * Routing table (decision order MUST match the Python source):
 * - bug promotion -> {@link buildBugBody} over the canonical bug headings,
 *   regardless of work mode (so a minor-audit bug renders the bug headings).
 * - non-bug minor-audit -> {@link buildMinorAuditBody} (with the default
 *   Evidence Checklist when the section is absent).
 * - otherwise -> {@link buildBody} (standard full-feature body).
 *
 * @param content Potential-file content.
 * @param selectedMode Normalized work mode.
 * @param promotionType Promotion type.
 * @param relativePath POSIX source path for the footer.
 * @returns The composed (un-normalized) issue body.
 */
function buildIssueBody(content, selectedMode, promotionType, relativePath) {
    // Bug promotions route through the canonical bug-section body FIRST, before
    // the work-mode branch. This ordering is required so a bug potential promoted
    // in minor-audit mode still renders the real bug headings (Summary,
    // Environment, ...) from the bug template rather than the minor-audit/feature
    // sections, which read headings the bug template does not contain. The
    // `- Work Mode:` first line emitted by buildBugBody still records the selected
    // mode, so a minor-audit bug issue records `- Work Mode: minor-audit`.
    if (promotionType === "bug") {
        const bugSections = {};
        for (const heading of content_1.BUG_SECTION_HEADINGS) {
            bugSections[heading] = (0, content_1.getSection)(content, heading) || content_1.PLACEHOLDER;
        }
        return (0, content_1.buildBugBody)(selectedMode, bugSections, relativePath);
    }
    // Non-bug minor-audit promotions route to the audit body with audit-specific
    // sections (defaulting the Evidence Checklist when the section is absent).
    if (selectedMode === "minor-audit") {
        const problem = (0, content_1.getSection)(content, "Problem / Why") || content_1.PLACEHOLDER;
        const implementationIntent = (0, content_1.getSection)(content, "Proposed Behavior") || content_1.PLACEHOLDER;
        const acceptanceCriteria = (0, content_1.getSection)(content, "Acceptance Criteria (early draft)") || content_1.PLACEHOLDER;
        const dependenciesRisks = (0, content_1.getSection)(content, "Constraints & Risks") || content_1.PLACEHOLDER;
        const verificationSteps = (0, content_1.getSection)(content, "Test Conditions to Consider") || content_1.PLACEHOLDER;
        let evidenceChecklist = (0, content_1.getSection)(content, "Evidence Checklist");
        // Default the checklist to the canonical three-line block when absent.
        if (!evidenceChecklist) {
            evidenceChecklist =
                "- [ ] Baseline\n- [ ] End-state\n- [ ] Targeted verification";
        }
        return (0, content_1.buildMinorAuditBody)(selectedMode, problem, implementationIntent, acceptanceCriteria, dependenciesRisks, verificationSteps, evidenceChecklist, relativePath);
    }
    // Default: the standard full-feature body.
    const problem = (0, content_1.getSection)(content, "Problem / Why") || content_1.PLACEHOLDER;
    const behavior = (0, content_1.getSection)(content, "Proposed Behavior") || content_1.PLACEHOLDER;
    const criteria = (0, content_1.getSection)(content, "Acceptance Criteria (early draft)") || content_1.PLACEHOLDER;
    const constraints = (0, content_1.getSection)(content, "Constraints & Risks") || content_1.PLACEHOLDER;
    const tests = (0, content_1.getSection)(content, "Test Conditions to Consider") || content_1.PLACEHOLDER;
    return (0, content_1.buildBody)(selectedMode, problem, behavior, criteria, constraints, tests, relativePath);
}
/**
 * Promote a potential feature file to a GitHub issue.
 *
 * Reproduces the Python `promote_potential` control flow, emitted lines, error
 * messages, and decision ordering verbatim. Recovers once from a missing-label
 * create failure for the selected promotion label; all other gh errors fall
 * through to the failure path with their original output.
 *
 * @param options Promotion options (path, promotion type, seams, workspace,
 *   work mode, and an optional emit sink).
 * @returns A {@link PromotionOutcome}: exit code, ordered messages, and the
 *   promoted destination path on success.
 * @throws PromotionError When a precondition fails (invalid type/mode,
 *   unauthenticated gh, missing/empty file, or a re-wrapped work-mode error).
 *
 * Side effects:
 *     Invokes the gh client; reads, writes, and moves files through the injected
 *     filesystem seam.
 */
function promotePotential(options) {
    const promotionType = options.promotionType ?? "feature";
    const workMode = options.workMode ?? "full";
    // Validate the promotion type and work mode before any I/O.
    if (!exports.PROMOTION_TYPES.includes(promotionType)) {
        throw new PromotionError(`Invalid promotion type: ${promotionType}`);
    }
    if (!prompt_mode_contract_1.ACCEPTED_WORK_MODES.includes(workMode)) {
        throw new PromotionError(`Invalid work mode: ${workMode}`);
    }
    const filesystem = options.fs ?? new promotion_filesystem_1.RealPotentialFileSystem();
    const ghClient = options.gh ?? new gh_client_1.RealGhClient();
    const workspacePath = options.workspace ?? process.cwd();
    const emit = options.emit ?? (() => undefined);
    // Fail fast when gh is not authenticated, before touching the file.
    if (!ghClient.isAuthenticated()) {
        throw new PromotionError("GitHub CLI is not authenticated. Run 'gh auth login' first.");
    }
    const resolved = filesystem.resolvePath(options.potentialPath);
    // The not-found message uses the ORIGINAL path arg (byte-identical to Python).
    if (!filesystem.exists(resolved)) {
        throw new PromotionError(`Potential file not found: ${options.potentialPath}`);
    }
    const content = filesystem.readText(resolved);
    // The empty message uses the RESOLVED path (byte-identical to Python).
    if (content.trim() === "") {
        throw new PromotionError(`Potential file is empty: ${resolved}`);
    }
    const featureName = (0, content_1.getFeatureName)(content, resolved);
    const featurePath = (0, content_1.getFeaturePath)(featureName);
    const prefix = exports.TITLE_PREFIXES[promotionType] ?? "Feature";
    const issueTitle = (0, content_1.normalizeSmartPunctuation)(`${prefix}: ${featureName}`);
    const relativePath = computeRelativePath(resolved, workspacePath);
    let selectedMode;
    try {
        selectedMode = (0, prompt_mode_contract_1.normalizeRequestedWorkMode)(workMode, promotionType);
    }
    catch (exc) {
        // Re-wrap the work-mode error as a PromotionError with the same message.
        const message = exc instanceof Error ? exc.message : String(exc);
        throw new PromotionError(message);
    }
    // Python initializes fallback_reason = "" and never sets it on this path, so
    // the "Fallback reason:" line is never emitted. The variable is retained for
    // parity but intentionally not emitted while empty.
    const fallbackReason = "";
    let body = buildIssueBody(content, selectedMode, promotionType, relativePath);
    body = (0, content_1.normalizeSmartPunctuation)(body);
    const messages = [];
    // Collect every emitted line and forward it to the injected sink, mirroring
    // the Python _emit helper.
    const emitLine = (message) => {
        messages.push(message);
        emit(message);
    };
    emitLine(`Selected mode: ${selectedMode}`);
    if (fallbackReason) {
        emitLine(`Fallback reason: ${fallbackReason}`);
    }
    emitLine(`Creating issue: ${issueTitle} (label: ${promotionType})`);
    let createResult = ghClient.issueCreate(issueTitle, body, promotionType);
    // Recover only from the known missing-label failure for the selected label so
    // other gh errors still fail fast with their original output.
    if (isMissingLabelFailure(createResult.output, promotionType)) {
        emitLine("Missing promotion label detected; ensuring label exists and retrying.");
        const ensureLabelResult = ghClient.ensureLabel(promotionType);
        for (const line of ensureLabelResult.output) {
            emitLine(line);
        }
        // Retry the create only when the label-ensure succeeded.
        if (ensureLabelResult.exitCode === 0) {
            createResult = ghClient.issueCreate(issueTitle, body, promotionType);
        }
    }
    // On a non-zero create exit, emit the output (or a synthetic line) and return
    // without a destination.
    if (createResult.exitCode !== 0) {
        const outputLines = createResult.output.length > 0
            ? createResult.output
            : [`gh CLI exited with code ${createResult.exitCode}`];
        for (const line of outputLines) {
            emitLine(line);
        }
        return { exitCode: createResult.exitCode, messages };
    }
    // Success: echo the create output lines.
    for (const line of createResult.output) {
        emitLine(line);
    }
    const [issueUrl, issueNumber] = (0, content_1.parseIssueReference)(createResult.output);
    let lastUpdated = null;
    // Refresh the updated date from the created issue when a number was parsed.
    if (issueNumber) {
        const viewResult = ghClient.issueView(issueNumber);
        if (viewResult.exitCode === 0 && viewResult.output.length > 0) {
            lastUpdated = (0, content_1.extractLastUpdated)(viewResult.output.join("\n"));
        }
    }
    // Update the potential-file metadata only when both number and url resolved.
    if (issueNumber && issueUrl) {
        // Split on all line-ending forms to mirror Python content.splitlines().
        const lines = content.split(/\r\n|\r|\n/);
        const updatedLines = (0, content_1.updateMetadataLines)(lines, featureName, issueNumber, issueUrl, lastUpdated, featurePath);
        filesystem.writeLines(resolved, updatedLines);
        emitLine(`Updated potential file with issue metadata: ${resolved}`);
    }
    // Build the promoted directory and destination using POSIX joins so the
    // emitted/returned paths keep forward slashes regardless of host OS,
    // matching the Python `Path` join behavior on the test/workspace inputs.
    const promotedDir = posixJoin(workspacePath, "docs/features/potential/promoted");
    filesystem.ensureDir(promotedDir);
    const destPath = posixJoin(promotedDir, posixBasename(resolved));
    filesystem.move(resolved, destPath);
    emitLine(`Moved potential file to promoted folder: ${destPath}`);
    return { exitCode: 0, messages, destination: destPath };
}
