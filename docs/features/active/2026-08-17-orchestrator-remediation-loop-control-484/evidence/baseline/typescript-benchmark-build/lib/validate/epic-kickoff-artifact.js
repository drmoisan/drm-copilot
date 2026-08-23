"use strict";
/** Parse and validate the durable epic kickoff Markdown contract. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseEpicKickoff = parseEpicKickoff;
exports.validateEpicKickoffText = validateEpicKickoffText;
const KICKOFF_HEADING_RE = /^# Epic Kickoff: (?<slug>[a-z0-9][a-z0-9-]*)$/;
const EPIC_RUN_RE = /Run `\/epic-run (?<slug>[a-z0-9][a-z0-9-]*)`/;
const MANIFEST_RE = /docs\/features\/epics\/[a-z0-9][a-z0-9-]*\/epic\.md/;
const INTEGRATION_BRANCH_RE = /epic\/[a-z0-9][a-z0-9-]*-integration/;
const RESUME_RE = /(?:Every child|child features)\s+resumes?\s+at atomic execution\s+from\s+(?:its|their)\s+committed plan-path/i;
const INTEGRITY_COMMIT_RE = /^(?:-\s*)?planning_commit:\s*`?(?<commit>[0-9a-fA-F]{7,64})`?\s*$/;
const FEATURE_HEADERS = [
    "issue_num",
    "feature_folder",
    "wave",
    "complexity",
    "plan-path",
];
const HASH_HEADERS = new Set([
    "plan-hash",
    "plan_hash",
    "git-blob-sha",
    "git_blob_sha",
]);
function splitSections(text) {
    const sections = new Map();
    const errors = [];
    let current;
    for (const line of text.split("\n").slice(1)) {
        if (line.startsWith("## ")) {
            current = line.slice(3).trim();
            if (sections.has(current)) {
                errors.push(`Epic kickoff contains duplicate section: ## ${current}`);
            }
            else {
                sections.set(current, []);
            }
            continue;
        }
        if (current !== undefined) {
            sections.get(current)?.push(line.replace(/\r$/, ""));
        }
    }
    for (const required of ["Invocation Prompt", "Feature Summary"]) {
        if (!sections.has(required)) {
            errors.push(`Epic kickoff is missing required section: ## ${required}`);
        }
    }
    return { sections, errors };
}
function parseCells(line) {
    const stripped = line.trim();
    if (!stripped.startsWith("|") || !stripped.endsWith("|")) {
        return undefined;
    }
    return stripped
        .slice(1, -1)
        .split("|")
        .map((cell) => cell.trim().replace(/^`|`$/g, ""));
}
function isSeparator(cells) {
    return cells.length > 0 && cells.every((cell) => /^:?-{3,}:?$/.test(cell));
}
function tableRows(lines, expectedHeaders) {
    const nonempty = lines.filter((line) => line.trim().length > 0);
    if (nonempty.length < 2) {
        return {
            rows: [],
            errors: ["Epic kickoff table is missing its header or separator row."],
        };
    }
    const headers = parseCells(nonempty[0] ?? "");
    const separator = parseCells(nonempty[1] ?? "");
    const errors = [];
    if (headers === undefined ||
        headers.length !== expectedHeaders.length ||
        headers.some((value, index) => value !== expectedHeaders[index])) {
        errors.push(`Epic kickoff feature table headers must be: ${expectedHeaders.join(" | ")}`);
    }
    if (separator === undefined ||
        separator.length !== expectedHeaders.length ||
        !isSeparator(separator)) {
        errors.push("Epic kickoff table separator row is invalid.");
    }
    const rows = [];
    for (const line of nonempty.slice(2)) {
        const cells = parseCells(line);
        if (cells === undefined || cells.length !== expectedHeaders.length) {
            errors.push(`Epic kickoff table row is invalid: ${line}`);
        }
        else {
            rows.push(cells);
        }
    }
    if (rows.length === 0) {
        errors.push("Epic kickoff feature table must contain at least one feature row.");
    }
    return { rows, errors };
}
function parseFeatures(lines) {
    const table = tableRows(lines, FEATURE_HEADERS);
    const features = [];
    table.rows.forEach((row, index) => {
        const issueNum = Number(row[0]);
        if (!Number.isInteger(issueNum)) {
            table.errors.push(`Epic kickoff feature row ${index} issue_num must be an integer.`);
            return;
        }
        const wave = Number(row[2]);
        if (!Number.isInteger(wave)) {
            table.errors.push(`Epic kickoff feature row ${index} wave must be an integer.`);
            return;
        }
        const complexity = row[3] ?? "";
        if (!new Set(["C1", "C2", "C3", "C4"]).has(complexity)) {
            table.errors.push(`Epic kickoff feature row ${index} complexity must be C1-C4.`);
        }
        features.push({
            issueNum,
            featureFolder: row[1] ?? "",
            wave,
            complexity,
            planPath: row[4] ?? "",
        });
    });
    return { features, errors: table.errors };
}
function parseIntegrity(lines) {
    let planningCommit;
    const planHashes = {};
    const errors = [];
    const tableLines = [];
    for (const line of lines) {
        if (line.trim().length === 0) {
            continue;
        }
        const match = INTEGRITY_COMMIT_RE.exec(line.trim());
        if (match?.groups?.["commit"] !== undefined) {
            if (planningCommit !== undefined) {
                errors.push("Epic kickoff integrity has duplicate planning_commit fields.");
            }
            planningCommit = match.groups["commit"].toLowerCase();
        }
        else if (line.trim().startsWith("|")) {
            tableLines.push(line);
        }
        else {
            errors.push(`Epic kickoff integrity line is invalid: ${line}`);
        }
    }
    if (tableLines.length > 0) {
        const header = parseCells(tableLines[0] ?? "");
        if (header === undefined ||
            header.length !== 2 ||
            header[0] !== "plan-path" ||
            !HASH_HEADERS.has(header[1] ?? "")) {
            errors.push("Epic kickoff integrity table headers must be plan-path and plan-hash.");
        }
        else if (tableLines.length < 2) {
            errors.push("Epic kickoff integrity table is missing its separator row.");
        }
        else {
            const separator = parseCells(tableLines[1] ?? "");
            if (separator === undefined ||
                separator.length !== 2 ||
                !isSeparator(separator)) {
                errors.push("Epic kickoff integrity table separator row is invalid.");
            }
            for (const line of tableLines.slice(2)) {
                const cells = parseCells(line);
                if (cells === undefined ||
                    cells.length !== 2 ||
                    !/^[0-9a-fA-F]{40,64}$/.test(cells[1] ?? "")) {
                    errors.push(`Epic kickoff integrity table row is invalid: ${line}`);
                    continue;
                }
                const planPath = cells[0] ?? "";
                if (planHashes[planPath] !== undefined) {
                    errors.push(`Epic kickoff integrity repeats plan path: '${planPath}'.`);
                }
                planHashes[planPath] = (cells[1] ?? "").toLowerCase();
            }
        }
    }
    return {
        ...(planningCommit === undefined ? {} : { planningCommit }),
        planHashes,
        errors,
    };
}
/** Parse the kickoff into a state-comparable structure. */
function parseEpicKickoff(text) {
    const lines = text.split("\n");
    if (text.length === 0) {
        return { errors: ["Epic kickoff is empty."] };
    }
    const heading = KICKOFF_HEADING_RE.exec((lines[0] ?? "").replace(/\r$/, ""));
    if (heading?.groups?.["slug"] === undefined) {
        return {
            errors: ["Epic kickoff first line must match '# Epic Kickoff: <slug>'."],
        };
    }
    const sectionResult = splitSections(text);
    const invocation = (sectionResult.sections.get("Invocation Prompt") ?? []).join("\n");
    const invocationSlug = EPIC_RUN_RE.exec(invocation)?.groups?.["slug"];
    const manifestMatch = MANIFEST_RE.exec(invocation);
    const branchMatch = INTEGRATION_BRANCH_RE.exec(invocation);
    const resumeMatch = RESUME_RE.exec(invocation);
    if (invocationSlug === undefined) {
        sectionResult.errors.push("Epic kickoff invocation must contain `Run /epic-run <slug>`.");
    }
    if (manifestMatch?.[0] === undefined ||
        branchMatch?.[0] === undefined ||
        resumeMatch === null) {
        sectionResult.errors.push("Epic kickoff invocation must structurally name the manifest, " +
            "integration branch, and atomic-execution resume boundary.");
    }
    const featureResult = parseFeatures(sectionResult.sections.get("Feature Summary") ?? []);
    sectionResult.errors.push(...featureResult.errors);
    const integrity = parseIntegrity(sectionResult.sections.get("Integrity") ?? []);
    sectionResult.errors.push(...integrity.errors);
    if (sectionResult.errors.length > 0 ||
        invocationSlug === undefined ||
        manifestMatch?.[0] === undefined ||
        branchMatch?.[0] === undefined ||
        resumeMatch === null) {
        return { errors: sectionResult.errors };
    }
    return {
        parsed: {
            slug: heading.groups["slug"],
            invocationSlug,
            manifestPath: manifestMatch[0],
            integrationBranch: branchMatch[0],
            features: featureResult.features,
            ...(integrity.planningCommit === undefined
                ? {}
                : { planningCommit: integrity.planningCommit }),
            planHashes: integrity.planHashes,
        },
        errors: [],
    };
}
/** Validate the standalone kickoff Markdown contract. */
function validateEpicKickoffText(text) {
    return parseEpicKickoff(text).errors;
}
