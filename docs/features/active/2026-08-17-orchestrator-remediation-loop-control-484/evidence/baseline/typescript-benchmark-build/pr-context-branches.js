"use strict";
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
exports.runGitForTextOutput = runGitForTextOutput;
exports.scoreBranchForPriority = scoreBranchForPriority;
exports.sortRemoteBranchCandidates = sortRemoteBranchCandidates;
exports.discoverPrBaseBranches = discoverPrBaseBranches;
exports.pickPrBaseBranch = pickPrBaseBranch;
const cp = __importStar(require("node:child_process"));
const vscode = __importStar(require("vscode"));
/**
 * Runs a git command synchronously and returns trimmed stdout for follow-up parsing.
 *
 * @param output The output channel used for failure diagnostics.
 * @param commandId The logical command name associated with the git invocation.
 * @param cwd The repository root where git should run.
 * @param args The git argv array.
 * @param allowNonZeroExit Whether a non-zero exit should be tolerated.
 * @returns The trimmed stdout emitted by git.
 * @throws Error when git exits non-zero and the call does not allow that failure.
 */
function runGitForTextOutput(output, commandId, cwd, args, allowNonZeroExit) {
    const result = cp.spawnSync("git", args, {
        cwd,
        encoding: "utf-8",
        shell: false,
    });
    const status = result.status;
    if (!allowNonZeroExit && status !== 0) {
        const stderr = (result.stderr ?? "").trim();
        output.appendLine(`[${commandId}] git command failure: git ${args.join(" ")}`);
        throw new Error(`Git command failed (${status ?? "unknown"}): ${stderr || "no stderr output"}`);
    }
    return (result.stdout ?? "").trim();
}
/**
 * Scores a branch name so well-known long-lived branches sort ahead of others.
 *
 * @param branchName The branch name without the `origin/` prefix.
 * @returns A lower number for higher-priority default branch candidates.
 */
function scoreBranchForPriority(branchName) {
    // Keep the priority list explicit so default-branch heuristics stay predictable
    // even when repositories expose many remote refs.
    if (branchName === "main") {
        return 0;
    }
    if (branchName === "master") {
        return 1;
    }
    if (branchName === "develop") {
        return 2;
    }
    if (branchName === "trunk") {
        return 3;
    }
    if (/^release([/.-]|$)/.test(branchName)) {
        return 4;
    }
    return 5;
}
/**
 * Orders remote branch candidates by branch priority and then alphabetically.
 *
 * @param candidates The remote refs returned from git.
 * @returns A new array sorted for quick-pick display and default selection.
 */
function sortRemoteBranchCandidates(candidates) {
    return [...candidates].sort((left, right) => {
        const leftName = left.replace(/^origin\//, "");
        const rightName = right.replace(/^origin\//, "");
        const scoreDelta = scoreBranchForPriority(leftName) - scoreBranchForPriority(rightName);
        if (scoreDelta !== 0) {
            return scoreDelta;
        }
        return left.localeCompare(right);
    });
}
/**
 * Discovers the most suitable branch candidates for PR-context collection.
 *
 * @param output The output channel used for git failure diagnostics.
 * @param commandId The logical command requesting the selection.
 * @param workspaceRoot The repository root where git commands should run.
 * @returns Candidate base branches and the branch that should be selected by default.
 * @throws Error when the repository exposes no usable local or remote branches.
 */
function discoverPrBaseBranches(output, commandId, workspaceRoot) {
    const originHead = runGitForTextOutput(output, commandId, workspaceRoot, ["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"], true);
    // Prefer remote branches when available because PR context is typically based on
    // the branch layout tracked in `origin`, not on a contributor's local branches.
    const remoteRefLines = runGitForTextOutput(output, commandId, workspaceRoot, ["for-each-ref", "--format=%(refname:short)", "refs/remotes/origin"], false)
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
        .filter((line) => line !== "origin/HEAD");
    const uniqueRemoteRefs = Array.from(new Set(remoteRefLines));
    const sortedRemoteRefs = sortRemoteBranchCandidates(uniqueRemoteRefs);
    if (sortedRemoteRefs.length > 0) {
        // Keep `origin/HEAD` first when it resolves to a listed ref so the quick pick
        // mirrors the repository's advertised default branch.
        if (originHead.length > 0 && sortedRemoteRefs.includes(originHead)) {
            const candidates = [
                originHead,
                ...sortedRemoteRefs.filter((item) => item !== originHead),
            ];
            return {
                candidates,
                defaultBranch: originHead,
            };
        }
        return {
            candidates: sortedRemoteRefs,
            defaultBranch: sortedRemoteRefs[0],
        };
    }
    // Fall back to local branches only when no remote refs exist, which keeps the
    // command usable in offline or minimally configured repositories.
    const localRefLines = runGitForTextOutput(output, commandId, workspaceRoot, ["for-each-ref", "--format=%(refname:short)", "refs/heads"], false)
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line.length > 0);
    const uniqueLocalRefs = Array.from(new Set(localRefLines)).sort((left, right) => left.localeCompare(right));
    if (uniqueLocalRefs.length === 0) {
        throw new Error("No branch candidates found in destination repository.");
    }
    return {
        candidates: uniqueLocalRefs,
        defaultBranch: uniqueLocalRefs[0],
    };
}
/**
 * Prompts the user to choose which branch should be treated as the PR base.
 *
 * @param output The output channel used for cancellation and selection logging.
 * @param commandId The logical command requesting the selection.
 * @param candidates The ordered candidate branches displayed to the user.
 * @param defaultBranch The branch labeled as the default suggestion.
 * @returns The chosen branch label, or `undefined` when the user cancels.
 */
async function pickPrBaseBranch(output, commandId, candidates, defaultBranch) {
    // Mirror the sorted candidate list in the picker so the user sees the same
    // priority order the extension would otherwise use automatically.
    const quickPickItems = candidates.map((branch) => ({
        label: branch,
        description: branch === defaultBranch ? "default" : "",
    }));
    const selectedItem = await vscode.window.showQuickPick(quickPickItems, {
        title: "Select PR base branch",
        placeHolder: "Choose the base branch used for PR context collection",
        ignoreFocusOut: true,
    });
    if (!selectedItem) {
        output.appendLine(`[${commandId}] branch selection canceled by user`);
        return undefined;
    }
    output.appendLine(`[${commandId}] selected base branch: ${selectedItem.label}`);
    return selectedItem.label;
}
