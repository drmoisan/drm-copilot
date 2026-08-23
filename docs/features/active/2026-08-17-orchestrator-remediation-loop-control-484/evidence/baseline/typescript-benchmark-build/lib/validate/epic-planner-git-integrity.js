"use strict";
/** Git provenance checks for execution-ready epic planning. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommandRunnerGitRepository = void 0;
exports.validateCommittedFile = validateCommittedFile;
exports.validatePlanningGitIntegrity = validatePlanningGitIntegrity;
const HASH_RE = /^[0-9a-fA-F]{40,64}$/;
const COMMIT_RE = /^[0-9a-fA-F]{7,64}$/;
/** Git-backed repository adapter using an injectable command runner. */
class CommandRunnerGitRepository {
    workspaceRoot;
    runner;
    constructor(workspaceRoot, runner) {
        this.workspaceRoot = workspaceRoot;
        this.runner = runner;
    }
    run(arguments_) {
        const result = this.runner.run(["git", ...arguments_], {
            cwd: this.workspaceRoot,
            allowError: true,
        });
        return { code: result.code, stdout: result.stdout.trim() };
    }
    refExists(ref) {
        return this.run(["rev-parse", "--verify", `${ref}^{commit}`]).code === 0;
    }
    commitExists(commit) {
        return this.run(["cat-file", "-e", `${commit}^{commit}`]).code === 0;
    }
    isAncestor(commit, ref) {
        return this.run(["merge-base", "--is-ancestor", commit, ref]).code === 0;
    }
    lastCommit(path) {
        const result = this.run(["log", "-n", "1", "--format=%H", "--", path]);
        return result.code === 0 && result.stdout.length > 0
            ? result.stdout
            : undefined;
    }
    committedBlobHash(ref, path) {
        const result = this.run(["rev-parse", "--verify", `${ref}:${path}`]);
        return result.code === 0 && HASH_RE.test(result.stdout)
            ? result.stdout.toLowerCase()
            : undefined;
    }
    worktreeBlobHash(path) {
        const result = this.run(["hash-object", "--", path]);
        return result.code === 0 && HASH_RE.test(result.stdout)
            ? result.stdout.toLowerCase()
            : undefined;
    }
}
exports.CommandRunnerGitRepository = CommandRunnerGitRepository;
function isRecord(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function optionalIntegrity(state, parsed) {
    const errors = [];
    const integrityValue = state["integrity"];
    let integrity = {};
    if (integrityValue !== undefined) {
        if (!isRecord(integrityValue)) {
            errors.push("Epic planner checkpoint integrity must be an object when present.");
        }
        else {
            integrity = integrityValue;
        }
    }
    const commits = [
        state["planning_commit"],
        integrity["planning_commit"],
        parsed.planningCommit,
    ].filter((value) => value !== undefined);
    for (const commit of commits) {
        if (typeof commit !== "string" || !COMMIT_RE.test(commit)) {
            errors.push("Optional planning_commit values must be 7-64 hexadecimal characters.");
        }
    }
    const normalized = commits
        .filter((commit) => typeof commit === "string" && COMMIT_RE.test(commit))
        .map((commit) => commit.toLowerCase());
    if (new Set(normalized).size > 1) {
        errors.push("Optional planning_commit values in state and kickoff must match.");
    }
    const planHashes = { ...parsed.planHashes };
    const stateHashes = integrity["plan_hashes"] ?? state["plan_hashes"];
    if (stateHashes !== undefined) {
        if (!isRecord(stateHashes)) {
            errors.push("Optional plan_hashes must be an object keyed by plan path.");
        }
        else {
            for (const [path, value] of Object.entries(stateHashes)) {
                if (typeof value !== "string" || !HASH_RE.test(value)) {
                    errors.push("Optional plan_hashes entries must map paths to 40-64 " +
                        "character hexadecimal hashes.");
                    continue;
                }
                if (planHashes[path] !== undefined &&
                    planHashes[path] !== value.toLowerCase()) {
                    errors.push(`Optional plan hash declarations disagree for '${path}'.`);
                }
                planHashes[path] = value.toLowerCase();
            }
        }
    }
    return {
        ...(normalized[0] === undefined ? {} : { planningCommit: normalized[0] }),
        planHashes,
        errors,
    };
}
/** Require a worktree file to match the exact blob committed at ref. */
function validateCommittedFile(git, ref, path, label) {
    const committed = git.committedBlobHash(ref, path);
    const worktree = git.worktreeBlobHash(path);
    if (committed === undefined) {
        return [
            `Execution readiness requires ${label} committed at ${ref}: ${path}`,
        ];
    }
    if (worktree === undefined) {
        return [`Execution readiness could not hash worktree ${label}: ${path}`];
    }
    if (committed !== worktree) {
        return [
            `Execution readiness detected worktree drift for ${label}: ${path}`,
        ];
    }
    return [];
}
/** Verify integration ancestry and byte-exact committed plan provenance. */
function validatePlanningGitIntegrity(state, parsed, plans, git) {
    const branch = state["integration_branch"];
    if (typeof branch !== "string" || !git.refExists(branch)) {
        return [
            `Execution readiness integration branch does not exist: '${String(branch)}'`,
        ];
    }
    const errors = [];
    const integrity = optionalIntegrity(state, parsed);
    errors.push(...integrity.errors);
    if (integrity.planningCommit !== undefined) {
        if (!git.commitExists(integrity.planningCommit)) {
            errors.push(`Execution readiness planning commit does not exist: ${integrity.planningCommit}`);
        }
        else if (!git.isAncestor(integrity.planningCommit, branch)) {
            errors.push(`Execution readiness planning commit ${integrity.planningCommit} ` +
                `is not an ancestor of ${branch}.`);
        }
    }
    const features = Array.isArray(state["features"])
        ? state["features"].filter(isRecord)
        : [];
    plans.forEach((plan, index) => {
        const derived = git.lastCommit(plan);
        if (derived === undefined) {
            errors.push(`Execution readiness could not derive a planning commit for ${plan}.`);
            return;
        }
        if (!git.commitExists(derived) || !git.isAncestor(derived, branch)) {
            errors.push(`Execution readiness derived plan commit ${derived} is not on ${branch}.`);
            return;
        }
        const candidates = [derived];
        const feature = features[index] ?? {};
        const featureCommit = feature["planning_commit"];
        if (featureCommit !== undefined) {
            if (typeof featureCommit !== "string" || !COMMIT_RE.test(featureCommit)) {
                errors.push(`Epic planner checkpoint features[${index}].planning_commit ` +
                    "must be hexadecimal.");
            }
            else {
                candidates.push(featureCommit.toLowerCase());
            }
        }
        if (integrity.planningCommit !== undefined) {
            candidates.push(integrity.planningCommit);
        }
        const worktreeHash = git.worktreeBlobHash(plan);
        if (worktreeHash === undefined) {
            errors.push(`Execution readiness could not hash worktree atomic plan: ${plan}`);
            return;
        }
        for (const candidate of [...new Set(candidates)]) {
            if (!git.commitExists(candidate)) {
                errors.push(`Execution readiness planning commit does not exist: ${candidate}`);
                continue;
            }
            if (!git.isAncestor(candidate, branch)) {
                errors.push(`Execution readiness planning commit ${candidate} is not an ` +
                    `ancestor of ${branch}.`);
                continue;
            }
            const committedHash = git.committedBlobHash(candidate, plan);
            if (committedHash === undefined) {
                errors.push(`Execution readiness planning commit ${candidate} does not contain ${plan}.`);
            }
            else if (committedHash !== worktreeHash) {
                errors.push(`Execution readiness detected committed plan drift: ${plan}`);
            }
        }
        const declared = feature["plan_hash"] ?? integrity.planHashes[plan];
        if (declared !== undefined) {
            if (typeof declared !== "string" || !HASH_RE.test(declared)) {
                errors.push(`Optional plan hash for ${plan} must be 40-64 hexadecimal characters.`);
            }
            else if (declared.toLowerCase() !== worktreeHash) {
                errors.push(`Optional plan hash does not match committed bytes for ${plan}.`);
            }
        }
    });
    for (const extra of Object.keys(integrity.planHashes)
        .filter((path) => !plans.includes(path))
        .sort()) {
        errors.push(`Optional plan_hashes contains unknown planner path: '${extra}'.`);
    }
    return errors;
}
