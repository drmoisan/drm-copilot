"use strict";
/**
 * Parse and validate the durable parallel kickoff Markdown contract.
 *
 * TypeScript parity port of `scripts/dev_tools/parallel_kickoff_contract.py`
 * and its helper `scripts/dev_tools/_parallel_kickoff_tables.py`. The MCP tool
 * `validate_orchestration_artifacts` dispatches through this runtime rather
 * than shelling out to the Python CLI, so the two implementations must emit
 * byte-identical error strings for every construct they represent identically.
 *
 * Ownership is recorded in `docs/features/epics/parallel-orchestration/epic.md`,
 * section "Planner Adjudication: the kickoff-contract boundary (F3 / F4)".
 *
 * Decision rationale for the shared algorithm is documented on the Python side
 * rather than duplicated here, so the two ports cannot drift into inconsistent
 * explanations of the same behavior. Read
 * `scripts/dev_tools/parallel_kickoff_contract.py` for the section-splitting,
 * invocation-grammar, and resume-boundary reasoning, and
 * `scripts/dev_tools/_parallel_kickoff_tables.py` for the table and integrity
 * parsing reasoning.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseParallelKickoff = parseParallelKickoff;
exports.validateParallelKickoffText = validateParallelKickoffText;
const KICKOFF_HEADING_RE = /^# Parallel Kickoff: (?<slug>[a-z0-9][a-z0-9-]*)$/;
const PARALLEL_RUN_RE = /Run `\/parallel-run (?<slug>[a-z0-9][a-z0-9-]*)`/;
const MANIFEST_RE = /docs\/features\/parallel\/[a-z0-9][a-z0-9-]*\/parallel\.md/;
const PLAN_BRANCH_RE = /parallel\/[a-z0-9][a-z0-9-]*-plan/;
const RESUME_RE = /(?:Every item|Each item|items)\s+resumes?\s+at atomic execution\s+from\s+(?:its|their)\s+committed plan-path\s+on\s+(?:its|their)\s+own\s+(?:pushed\s+)?feature branch/i;
const INTEGRITY_COMMIT_RE = /^(?:-\s*)?planning_commit:\s*`?(?<commit>[0-9a-fA-F]{7,64})`?\s*$/;
const LINE_SPLIT_RE = /\r\n|\r|\n/u;
const ITEM_HEADERS = [
    "issue_num",
    "feature_folder",
    "cohort",
    "complexity",
    "branch",
    "plan-path",
];
const HASH_HEADERS = new Set([
    "plan-hash",
    "plan_hash",
    "git-blob-sha",
    "git_blob_sha",
]);
const COMPLEXITY_BANDS = new Set(["C1", "C2", "C3", "C4"]);
function splitSections(text) {
    const sections = new Map();
    const errors = [];
    let current;
    for (const line of text.split(LINE_SPLIT_RE).slice(1)) {
        if (line.startsWith("## ")) {
            current = line.slice(3).trim();
            if (sections.has(current)) {
                errors.push(`Parallel kickoff contains duplicate section: ## ${current}`);
            }
            else {
                sections.set(current, []);
            }
            continue;
        }
        if (current !== undefined) {
            sections.get(current)?.push(line);
        }
    }
    for (const required of ["Invocation Prompt", "Item Summary"]) {
        if (!sections.has(required)) {
            errors.push(`Parallel kickoff is missing required section: ## ${required}`);
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
            errors: [
                "Parallel kickoff table is missing its header or separator row.",
            ],
        };
    }
    const headers = parseCells(nonempty[0] ?? "");
    const separator = parseCells(nonempty[1] ?? "");
    const errors = [];
    if (headers === undefined ||
        headers.length !== expectedHeaders.length ||
        headers.some((value, index) => value !== expectedHeaders[index])) {
        errors.push(`Parallel kickoff item table headers must be: ${expectedHeaders.join(" | ")}`);
    }
    if (separator === undefined ||
        separator.length !== expectedHeaders.length ||
        !isSeparator(separator)) {
        errors.push("Parallel kickoff table separator row is invalid.");
    }
    const rows = [];
    for (const line of nonempty.slice(2)) {
        const cells = parseCells(line);
        if (cells === undefined || cells.length !== expectedHeaders.length) {
            errors.push(`Parallel kickoff table row is invalid: ${line}`);
        }
        else {
            rows.push(cells);
        }
    }
    if (rows.length === 0) {
        errors.push("Parallel kickoff item table must contain at least one item row.");
    }
    return { rows, errors };
}
function parseItems(lines) {
    const table = tableRows(lines, ITEM_HEADERS);
    const items = [];
    table.rows.forEach((row, index) => {
        const issueNum = Number(row[0]);
        if (!Number.isInteger(issueNum)) {
            table.errors.push(`Parallel kickoff item row ${String(index)} issue_num must be an integer.`);
            return;
        }
        const cohort = Number(row[2]);
        if (!Number.isInteger(cohort)) {
            table.errors.push(`Parallel kickoff item row ${String(index)} cohort must be an integer.`);
            return;
        }
        const complexity = row[3] ?? "";
        if (!COMPLEXITY_BANDS.has(complexity)) {
            table.errors.push(`Parallel kickoff item row ${String(index)} complexity must be C1-C4.`);
        }
        items.push({
            issueNum,
            featureFolder: row[1] ?? "",
            cohort,
            complexity,
            branch: row[4] ?? "",
            planPath: row[5] ?? "",
        });
    });
    return { items, errors: table.errors };
}
function parseIntegrityTable(tableLines) {
    const planHashes = {};
    const errors = [];
    const header = parseCells(tableLines[0] ?? "");
    if (header === undefined ||
        header.length !== 2 ||
        header[0] !== "plan-path" ||
        !HASH_HEADERS.has(header[1] ?? "")) {
        errors.push("Parallel kickoff integrity table headers must be plan-path and plan-hash.");
    }
    else if (tableLines.length < 2) {
        errors.push("Parallel kickoff integrity table is missing its separator row.");
    }
    else {
        const separator = parseCells(tableLines[1] ?? "");
        if (separator === undefined ||
            separator.length !== 2 ||
            !isSeparator(separator)) {
            errors.push("Parallel kickoff integrity table separator row is invalid.");
        }
        for (const line of tableLines.slice(2)) {
            const cells = parseCells(line);
            if (cells === undefined ||
                cells.length !== 2 ||
                !/^[0-9a-fA-F]{40,64}$/.test(cells[1] ?? "")) {
                errors.push(`Parallel kickoff integrity table row is invalid: ${line}`);
                continue;
            }
            const planPath = cells[0] ?? "";
            if (planHashes[planPath] !== undefined) {
                errors.push(`Parallel kickoff integrity repeats plan path: '${planPath}'.`);
            }
            planHashes[planPath] = (cells[1] ?? "").toLowerCase();
        }
    }
    return { planHashes, errors };
}
function parseIntegrity(lines) {
    let planningCommit;
    const errors = [];
    const tableLines = [];
    for (const line of lines) {
        if (line.trim().length === 0) {
            continue;
        }
        const match = INTEGRITY_COMMIT_RE.exec(line.trim());
        if (match?.groups?.["commit"] !== undefined) {
            if (planningCommit !== undefined) {
                errors.push("Parallel kickoff integrity has duplicate planning_commit fields.");
            }
            planningCommit = match.groups["commit"].toLowerCase();
        }
        else if (line.trim().startsWith("|")) {
            tableLines.push(line);
        }
        else {
            errors.push(`Parallel kickoff integrity line is invalid: ${line}`);
        }
    }
    let planHashes = {};
    if (tableLines.length > 0) {
        const table = parseIntegrityTable(tableLines);
        planHashes = table.planHashes;
        errors.push(...table.errors);
    }
    return {
        ...(planningCommit === undefined ? {} : { planningCommit }),
        planHashes,
        errors,
    };
}
/** Parse the kickoff into a state-comparable structure. */
function parseParallelKickoff(text) {
    const lines = text.split(LINE_SPLIT_RE);
    if (text.length === 0) {
        return { errors: ["Parallel kickoff is empty."] };
    }
    const heading = KICKOFF_HEADING_RE.exec(lines[0] ?? "");
    if (heading?.groups?.["slug"] === undefined) {
        return {
            errors: [
                "Parallel kickoff first line must match '# Parallel Kickoff: <slug>'.",
            ],
        };
    }
    const sectionResult = splitSections(text);
    const invocation = (sectionResult.sections.get("Invocation Prompt") ?? []).join("\n");
    const invocationSlug = PARALLEL_RUN_RE.exec(invocation)?.groups?.["slug"];
    const manifestMatch = MANIFEST_RE.exec(invocation);
    const branchMatch = PLAN_BRANCH_RE.exec(invocation);
    const resumeMatch = RESUME_RE.exec(invocation);
    if (invocationSlug === undefined) {
        sectionResult.errors.push("Parallel kickoff invocation must contain `Run /parallel-run <slug>`.");
    }
    if (manifestMatch?.[0] === undefined ||
        branchMatch?.[0] === undefined ||
        resumeMatch === null) {
        sectionResult.errors.push("Parallel kickoff invocation must structurally name the manifest, " +
            "plan-home branch, and atomic-execution resume boundary.");
    }
    const itemResult = parseItems(sectionResult.sections.get("Item Summary") ?? []);
    sectionResult.errors.push(...itemResult.errors);
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
            planHomeBranch: branchMatch[0],
            items: itemResult.items,
            ...(integrity.planningCommit === undefined
                ? {}
                : { planningCommit: integrity.planningCommit }),
            planHashes: integrity.planHashes,
        },
        errors: [],
    };
}
function validateReadyIdentity(parsed) {
    const expectedManifest = `docs/features/parallel/${parsed.slug}/parallel.md`;
    const expectedBranch = `parallel/${parsed.slug}-plan`;
    const errors = [];
    if (parsed.invocationSlug !== parsed.slug) {
        errors.push("Parallel kickoff readiness requires heading and invocation slugs to match.");
    }
    if (parsed.manifestPath !== expectedManifest) {
        errors.push(`Parallel kickoff readiness manifest must be '${expectedManifest}'.`);
    }
    if (parsed.planHomeBranch !== expectedBranch) {
        errors.push(`Parallel kickoff readiness plan-home branch must be '${expectedBranch}'.`);
    }
    if (parsed.planningCommit === undefined) {
        errors.push("Parallel kickoff readiness requires version-1 committed planning_commit identity.");
    }
    return errors;
}
/** Validate the standalone parallel kickoff Markdown contract. */
function validateParallelKickoffText(text, options = {}) {
    const result = parseParallelKickoff(text);
    if (result.parsed === undefined ||
        options.requireReadyForExecution !== true) {
        return result.errors;
    }
    return [...result.errors, ...validateReadyIdentity(result.parsed)];
}
