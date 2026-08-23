"use strict";
/** Repository-aware integrity checks for execution-ready epic plans. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateEpicReadinessIntegrity = validateEpicReadinessIntegrity;
const file_system_1 = require("../file-system");
const epic_kickoff_artifact_1 = require("./epic-kickoff-artifact");
const epic_planner_git_integrity_1 = require("./epic-planner-git-integrity");
const epic_planner_launch_evidence_1 = require("./epic-planner-launch-evidence");
const ALL_CLEAR = "PREFLIGHT: ALL CLEAR";
const SLUG_RE = /^[a-z0-9][a-z0-9-]*$/;
function join(root, relative) {
    return `${(0, file_system_1.toPosixPath)(root).replace(/\/+$/, "")}/${relative.replace(/^\/+/, "")}`;
}
function relativePath(value, field) {
    if (typeof value !== "string" || value.trim().length === 0) {
        return {
            errors: [`${field} must be a non-empty repository-relative path.`],
        };
    }
    if (value.includes("\\")) {
        return { errors: [`${field} must use forward slashes.`] };
    }
    const parts = value.split("/");
    if (value.startsWith("/") ||
        /^[A-Za-z]:/.test(value) ||
        parts.includes("..") ||
        parts.includes(".")) {
        return { errors: [`${field} must stay within the workspace root.`] };
    }
    return { path: parts.join("/"), errors: [] };
}
function readRequired(context, relative, label) {
    const path = join(context.workspaceRoot, relative);
    if (!context.fileSystem.isFile(path)) {
        return { errors: [`Execution readiness requires ${label}: ${relative}`] };
    }
    try {
        return { text: context.fileSystem.readTextFile(path), errors: [] };
    }
    catch (error) {
        return {
            errors: [
                `Execution readiness could not read ${label} ${relative}: ${String(error)}`,
            ],
        };
    }
}
function validateArtifactSource(stateText, context) {
    const expected = "artifacts/orchestration/epic-planner-state.json";
    const root = (0, file_system_1.toPosixPath)(context.workspaceRoot).replace(/\/+$/, "");
    const artifact = (0, file_system_1.toPosixPath)(context.artifactPath);
    if (!artifact.startsWith(`${root}/`)) {
        return ["Epic planner artifact path must stay within the workspace root."];
    }
    const supplied = artifact.slice(root.length + 1);
    const errors = [];
    if (supplied !== expected) {
        errors.push(`Execution-ready epic planner artifact path must be '${expected}'.`);
    }
    const source = readRequired(context, supplied, "the epic planner checkpoint");
    errors.push(...source.errors);
    if (source.text !== undefined && source.text !== stateText) {
        errors.push("Supplied epic planner text does not match artifact_path bytes.");
    }
    return errors;
}
function validateFeatureFiles(feature, index, context) {
    const prefix = `Epic planner checkpoint features[${index}]`;
    const folderResult = relativePath(feature["feature_folder"], `${prefix}.feature_folder`);
    const planResult = relativePath(feature["plan_path"], `${prefix}.plan_path`);
    const researchResult = relativePath(feature["research_path"], `${prefix}.research_path`);
    const errors = [
        ...folderResult.errors,
        ...planResult.errors,
        ...researchResult.errors,
    ];
    const folder = folderResult.path;
    const plan = planResult.path;
    const researchPath = researchResult.path;
    if (folder === undefined ||
        plan === undefined ||
        researchPath === undefined) {
        return { ...(plan === undefined ? {} : { plan }), errors };
    }
    if (!folder.startsWith("docs/features/active/") &&
        !folder.startsWith("docs/features/completed/")) {
        errors.push(`${prefix}.feature_folder must be under docs/features/active or completed.`);
    }
    const folderPath = join(context.workspaceRoot, folder);
    if (!context.fileSystem.isDirectory(folderPath)) {
        errors.push(`Execution readiness requires feature folder: ${folder}`);
        return { plan, errors };
    }
    if (!plan.startsWith(`${folder}/`)) {
        errors.push(`${prefix}.plan_path must be inside its feature_folder.`);
    }
    for (const name of ["issue.md", "spec.md", "user-story.md"]) {
        errors.push(...readRequired(context, `${folder}/${name}`, `${prefix} ${name}`).errors);
    }
    errors.push(...readRequired(context, plan, `${prefix} atomic plan`).errors);
    if (!researchPath.startsWith("artifacts/research/") &&
        !researchPath.startsWith(`${folder}/`)) {
        errors.push(`${prefix}.research_path must be under artifacts/research or its ` +
            "feature_folder.");
    }
    errors.push(...readRequired(context, researchPath, `${prefix} research evidence`)
        .errors);
    const evidenceValue = feature["preflight_evidence_path"];
    const evidencePaths = [];
    if (evidenceValue !== undefined) {
        const evidence = relativePath(evidenceValue, `${prefix}.preflight_evidence_path`);
        errors.push(...evidence.errors);
        if (evidence.path !== undefined) {
            if (!evidence.path.startsWith(`${folder}/`)) {
                errors.push(`${prefix}.preflight_evidence_path must be inside its feature_folder.`);
            }
            evidencePaths.push(join(context.workspaceRoot, evidence.path));
        }
    }
    else {
        evidencePaths.push(...context.fileSystem.glob(folderPath, "**/*preflight*.md"));
    }
    let allClear = false;
    for (const path of evidencePaths) {
        if (!context.fileSystem.isFile(path)) {
            continue;
        }
        try {
            allClear = context.fileSystem.readTextFile(path).includes(ALL_CLEAR);
        }
        catch {
            continue;
        }
        if (allClear) {
            break;
        }
    }
    if (!allClear) {
        errors.push(`Execution readiness requires preflight evidence containing ` +
            `'${ALL_CLEAR}' under ${folder}.`);
    }
    return { plan, errors };
}
function isRecord(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function validateKickoffAgainstState(parsed, state, label) {
    const errors = [];
    const slug = state["epic_feature_folder"];
    if (parsed.slug !== slug || parsed.invocationSlug !== slug) {
        errors.push(`${label} kickoff slug and /epic-run slug must match state '${String(slug)}'.`);
    }
    if (parsed.manifestPath !== state["epic_manifest_path"]) {
        errors.push(`${label} kickoff manifest reference must match epic_manifest_path.`);
    }
    if (parsed.integrationBranch !== state["integration_branch"]) {
        errors.push(`${label} kickoff integration branch must match planner state.`);
    }
    const expected = Array.isArray(state["features"])
        ? state["features"]
            .filter(isRecord)
            .map((feature) => [
            feature["issue_num"],
            feature["feature_folder"],
            feature["wave"],
            feature["complexity_band"],
            feature["plan_path"],
        ])
        : [];
    const actual = parsed.features.map((feature) => [
        feature.issueNum,
        feature.featureFolder,
        feature.wave,
        feature.complexity,
        feature.planPath,
    ]);
    if (JSON.stringify(actual) !== JSON.stringify(expected)) {
        errors.push(`${label} kickoff feature table must exactly match planner state ` +
            "order and values.");
    }
    return errors;
}
/** Run repository, kickoff, artifact, and Git readiness checks. */
function validateEpicReadinessIntegrity(state, stateText, context) {
    const errors = validateArtifactSource(stateText, context);
    const slug = state["epic_feature_folder"];
    if (typeof slug !== "string" || !SLUG_RE.test(slug)) {
        return [
            ...errors,
            "Epic planner checkpoint epic_feature_folder must be a slug.",
        ];
    }
    const manifestPath = `docs/features/epics/${slug}/epic.md`;
    if (state["epic_manifest_path"] !== manifestPath) {
        errors.push(`Execution-ready epic_manifest_path must be '${manifestPath}'.`);
    }
    const branch = `epic/${slug}-integration`;
    if (state["integration_branch"] !== branch) {
        errors.push(`Execution-ready integration_branch must be '${branch}'.`);
    }
    const manifest = readRequired(context, manifestPath, "the epic manifest");
    errors.push(...manifest.errors);
    const ignoredResult = relativePath(state["kickoff_prompt_path"], "Epic planner checkpoint kickoff_prompt_path");
    errors.push(...ignoredResult.errors);
    const durablePath = `docs/features/epics/${slug}/epic-kickoff.md`;
    const durable = readRequired(context, durablePath, "the committed epic kickoff");
    errors.push(...durable.errors);
    const ignored = ignoredResult.path === undefined
        ? { errors: [] }
        : readRequired(context, ignoredResult.path, "the ignored epic kickoff");
    errors.push(...ignored.errors);
    let parsed;
    if (durable.text !== undefined) {
        const result = (0, epic_kickoff_artifact_1.parseEpicKickoff)(durable.text);
        errors.push(...result.errors);
        parsed = result.parsed;
        if (parsed !== undefined) {
            errors.push(...validateKickoffAgainstState(parsed, state, "Committed"));
        }
    }
    if (ignored.text !== undefined) {
        const result = (0, epic_kickoff_artifact_1.parseEpicKickoff)(ignored.text);
        errors.push(...result.errors);
        if (result.parsed !== undefined) {
            errors.push(...validateKickoffAgainstState(result.parsed, state, "Ignored"));
        }
        if (durable.text !== undefined && ignored.text !== durable.text) {
            errors.push("Committed and ignored epic kickoff bytes must match.");
        }
    }
    const plans = [];
    if (Array.isArray(state["features"])) {
        state["features"].forEach((feature, index) => {
            if (!isRecord(feature)) {
                return;
            }
            const result = validateFeatureFiles(feature, index, context);
            errors.push(...result.errors);
            if (result.plan !== undefined) {
                plans.push(result.plan);
            }
        });
    }
    errors.push(...(0, epic_planner_launch_evidence_1.validateEpicPlannerLaunchEvidence)(state, context));
    if (parsed !== undefined) {
        errors.push(...(0, epic_planner_git_integrity_1.validatePlanningGitIntegrity)(state, parsed, plans, context.git), ...(0, epic_planner_git_integrity_1.validateCommittedFile)(context.git, String(state["integration_branch"]), durablePath, "durable kickoff"));
        if (manifest.text !== undefined) {
            errors.push(...(0, epic_planner_git_integrity_1.validateCommittedFile)(context.git, String(state["integration_branch"]), manifestPath, "epic manifest"));
        }
    }
    return errors;
}
