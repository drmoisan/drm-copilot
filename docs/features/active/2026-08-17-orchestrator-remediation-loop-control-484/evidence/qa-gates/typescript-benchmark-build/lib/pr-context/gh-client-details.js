"use strict";
/**
 * GitHub CLI issue/PR detail fetches for PR context collection.
 *
 * Purpose:
 *     Port of the issue/PR detail portion of `dev_tools/pr_context/github.py`
 *     `GhClient`. These functions operate on a {@link GhClient} instance (from
 *     `gh-client-core.ts`) so the two files stay under 500 lines while sharing
 *     one logical client. `GhClient` exposes the public methods that delegate
 *     here, so the combined public surface matches the Python class.
 *
 * Responsibilities:
 *     - `issueDetailsImpl`, `prDetailsImpl`, `closingIssuesImpl`, `currentPrImpl`.
 *     - Replicate label/assignee/author extraction guards, comment formatting,
 *       user-story resolution, the `pr view --json` field list, and every
 *       fallback string verbatim.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.compareCodePoint = compareCodePoint;
exports.issueDetailsImpl = issueDetailsImpl;
exports.prDetailsImpl = prDetailsImpl;
exports.closingIssuesImpl = closingIssuesImpl;
exports.currentPrImpl = currentPrImpl;
const models_1 = require("./models");
const gh_client_core_1 = require("./gh-client-core");
/** The `pr view --json` field list shared by `prDetails` (verbatim). */
const PR_DETAILS_FIELDS = "number,title,body,state,author,baseRefName,headRefName," +
    "createdAt,updatedAt,mergedAt,labels,assignees," +
    "closingIssuesReferences,files";
/** The `pr view --json` field list used by `currentPr` (verbatim). */
const CURRENT_PR_FIELDS = "number,title,body,state,author,baseRefName,headRefName," +
    "createdAt,updatedAt,mergedAt,labels,assignees,closingIssuesReferences";
/**
 * Read a string property, returning `""` when missing or not a string.
 *
 * @param record Source record.
 * @param key Property name.
 * @returns The string value or `""`.
 */
function stringField(record, key) {
    const value = record[key];
    return typeof value === "string" ? value : "";
}
/**
 * Read an optional string property, returning `null` when missing/non-string.
 *
 * @param record Source record.
 * @param key Property name.
 * @returns The string value or `null`.
 */
function optionalStringField(record, key) {
    const value = record[key];
    return typeof value === "string" ? value : null;
}
/**
 * Extract string members of objects in a list by property name.
 *
 * Mirrors the Python `isinstance` guards used for labels/assignees: only object
 * entries with a string value at `key` contribute.
 *
 * @param raw Candidate list value.
 * @param key Property name on each object entry.
 * @returns The collected string values in order.
 */
function extractStrings(raw, key) {
    const values = [];
    if (!Array.isArray(raw)) {
        return values;
    }
    // Collect the string property from each object entry, skipping non-objects.
    for (const entry of raw) {
        if ((0, gh_client_core_1.isRecord)(entry)) {
            const value = entry[key];
            if (typeof value === "string") {
                values.push(value);
            }
        }
    }
    return values;
}
/**
 * Extract `#N` references from a `closingIssuesReferences` list.
 *
 * @param raw Candidate list value.
 * @returns The `#N` strings for integer `number` entries, in order.
 */
function extractClosingNumbers(raw) {
    const numbers = [];
    if (!Array.isArray(raw)) {
        return numbers;
    }
    // Collect `#N` for each object entry whose `number` is an integer.
    for (const entry of raw) {
        if ((0, gh_client_core_1.isRecord)(entry)) {
            const num = entry["number"];
            if (typeof num === "number" && Number.isInteger(num)) {
                numbers.push(`#${num}`);
            }
        }
    }
    return numbers;
}
/**
 * Sort a set of strings by Unicode code point, mirroring Python
 * `sorted(set(...))`.
 *
 * Python's default `sorted` compares strings by code point, not by locale, so
 * multi-digit references such as `#10` sort before `#2`. A code-point comparator
 * is used rather than `localeCompare` to preserve that exact ordering.
 */
function sortedSet(values) {
    return [...new Set(values)].sort(compareCodePoint);
}
/** Compare two strings by Unicode code point (Python `sorted` semantics). */
function compareCodePoint(left, right) {
    if (left < right) {
        return -1;
    }
    if (left > right) {
        return 1;
    }
    return 0;
}
/**
 * Read the author login from an `author`/`user` record property.
 *
 * @param record Source record.
 * @param key The property holding the author/user object.
 * @returns The login string, or `""`.
 */
function authorLogin(record, key) {
    const raw = record[key];
    if ((0, gh_client_core_1.isRecord)(raw)) {
        const login = raw["login"];
        if (typeof login === "string") {
            return login;
        }
    }
    return "";
}
/**
 * Fetch issue details. Mirrors Python `issue_details`.
 *
 * @param client The owning client.
 * @param numberRef Issue number (without `#`).
 * @returns Parsed issue details with all fallback strings applied.
 * @throws Error When unavailable, repo unresolved, or the payload is malformed.
 */
function issueDetailsImpl(client, numberRef) {
    client.ensureAvailable();
    const repo = client.repoName();
    if (!repo) {
        throw new Error("Unable to resolve repository for issue lookup.");
    }
    const payload = client.requestJson([client.ghExecutable, "api", `repos/${repo}/issues/${numberRef}`], { context: "Fetch issue" });
    if (!(0, gh_client_core_1.isRecord)(payload)) {
        throw new Error("Unexpected issue payload format.");
    }
    const title = stringField(payload, "title");
    const state = stringField(payload, "state");
    const body = stringField(payload, "body");
    const labels = extractStrings(payload["labels"], "name");
    const assignees = extractStrings(payload["assignees"], "login");
    const author = authorLogin(payload, "user");
    const createdAt = stringField(payload, "created_at");
    const updatedAt = stringField(payload, "updated_at");
    const commentsUrl = optionalStringField(payload, "comments_url");
    const comments = commentsUrl ? fetchIssueComments(client, commentsUrl) : [];
    const storyPath = (0, models_1.findUserStoryLink)(body);
    let storyContent = null;
    if (storyPath) {
        // Prefer a local checkout of the story file before falling back to the
        // repo file API, matching the Python local-then-remote resolution.
        const localPath = `${client.cwd}/${storyPath}`;
        if (client.fileSystem.exists(localPath)) {
            storyContent = client.fileSystem.readTextFile(localPath);
        }
        else {
            storyContent = client.fetchRepoFile(storyPath);
        }
    }
    return {
        number: `#${numberRef}`,
        title: title || "(no title)",
        state: state || "(unknown)",
        labels,
        assignees,
        author: author || "(unknown)",
        createdAt,
        updatedAt,
        body: body || "(no body)",
        comments,
        userStoryPath: storyPath,
        userStoryContent: storyContent,
    };
}
/**
 * Fetch and format issue comments. Mirrors the Python comment loop.
 *
 * @param client The owning client.
 * @param commentsUrl The `comments_url` value.
 * @returns Formatted `"{login} at {created}: {body}"` strings (trimmed), with
 *   `(unknown)` when the login is absent.
 */
function fetchIssueComments(client, commentsUrl) {
    const commentPayload = client.requestJson([client.ghExecutable, "api", `${commentsUrl}?per_page=50`], { context: "Fetch issue comments" });
    const comments = [];
    if (!Array.isArray(commentPayload)) {
        return comments;
    }
    // Format each comment with login/created prefix; tolerate missing fields.
    for (const entry of commentPayload) {
        if (!(0, gh_client_core_1.isRecord)(entry)) {
            continue;
        }
        const login = authorLogin(entry, "user");
        const created = stringField(entry, "created_at");
        const entryBody = stringField(entry, "body");
        let prefix = login ? login : "(unknown)";
        if (created) {
            prefix = `${prefix} at ${created}`;
        }
        comments.push(`${prefix}: ${entryBody}`.trim());
    }
    return comments;
}
/**
 * Fetch pull request details. Mirrors Python `pr_details`.
 *
 * @param client The owning client.
 * @param numberRef PR number (without `#`).
 * @returns Parsed PR details with all fallback strings applied.
 * @throws Error When unavailable, repo unresolved, or the payload is malformed.
 */
function prDetailsImpl(client, numberRef) {
    client.ensureAvailable();
    const repo = client.repoName();
    if (!repo) {
        throw new Error("Unable to resolve repository for PR lookup.");
    }
    const payload = client.requestJson([client.ghExecutable, "pr", "view", numberRef, "--json", PR_DETAILS_FIELDS], { context: "Fetch pull request" });
    if (!(0, gh_client_core_1.isRecord)(payload)) {
        throw new Error("Unexpected pull request payload format.");
    }
    const title = stringField(payload, "title");
    const state = stringField(payload, "state");
    const body = stringField(payload, "body");
    const closing = extractClosingNumbers(payload["closingIssuesReferences"]);
    const labels = extractStrings(payload["labels"], "name");
    const assignees = extractStrings(payload["assignees"], "login");
    const authorLoginValue = authorLogin(payload, "author");
    const filesChanged = extractStrings(payload["files"], "path");
    return {
        number: `#${numberRef}`,
        title: title || "(no title)",
        state: state || "(unknown)",
        author: authorLoginValue || "(unknown)",
        baseRef: optionalStringField(payload, "baseRefName") ?? "(unknown)",
        headRef: optionalStringField(payload, "headRefName") ?? "(unknown)",
        createdAt: stringField(payload, "createdAt"),
        updatedAt: stringField(payload, "updatedAt"),
        mergedAt: optionalStringField(payload, "mergedAt"),
        labels,
        assignees,
        body: body || "(no body)",
        closingIssues: closing,
        filesChanged,
    };
}
/**
 * Fetch closing-issue references. Mirrors Python `closing_issues`.
 *
 * @param client The owning client.
 * @param prNumber Optional PR number inserted at argv index 3.
 * @returns Sorted, deduplicated `#N` references; `[]` on absent repo/payload.
 */
function closingIssuesImpl(client, prNumber) {
    client.ensureAvailable();
    const repo = client.repoName();
    if (!repo) {
        return [];
    }
    const args = [
        client.ghExecutable,
        "pr",
        "view",
        "--json",
        "closingIssuesReferences,number",
    ];
    if (prNumber) {
        // Mirror Python `args.insert(3, pr_number)`: place the number before --json.
        args.splice(3, 0, prNumber);
    }
    const payload = client.requestJson(args, { context: "Fetch closing issues" });
    if (!(0, gh_client_core_1.isRecord)(payload)) {
        return [];
    }
    return sortedSet(extractClosingNumbers(payload["closingIssuesReferences"]));
}
/**
 * Fetch the current branch's PR details. Mirrors Python `current_pr`.
 *
 * @param client The owning client.
 * @returns The PR details, or `null` when unavailable, on non-zero exit, empty
 *   stdout, invalid JSON, non-object payload, or a missing integer `number`.
 */
function currentPrImpl(client) {
    if (!client.available) {
        return null;
    }
    const args = [client.ghExecutable, "pr", "view", "--json", CURRENT_PR_FIELDS];
    const result = (0, gh_client_core_1.runGh)(client, args);
    if (result.code !== 0 || !result.stdout) {
        return null;
    }
    const payload = (0, gh_client_core_1.parseJsonOrNull)(result.stdout);
    if (!(0, gh_client_core_1.isRecord)(payload)) {
        return null;
    }
    const numberRaw = payload["number"];
    if (typeof numberRaw !== "number" || !Number.isInteger(numberRaw)) {
        return null;
    }
    const title = stringField(payload, "title");
    const state = stringField(payload, "state");
    const body = stringField(payload, "body");
    const authorLoginValue = authorLogin(payload, "author");
    const labels = extractStrings(payload["labels"], "name");
    const assignees = extractStrings(payload["assignees"], "login");
    const closing = extractClosingNumbers(payload["closingIssuesReferences"]);
    return {
        number: `#${numberRaw}`,
        title: title || "(no title)",
        state: state || "(unknown)",
        author: authorLoginValue || "(unknown)",
        baseRef: optionalStringField(payload, "baseRefName") ?? "(unknown)",
        headRef: optionalStringField(payload, "headRefName") ?? "(unknown)",
        createdAt: stringField(payload, "createdAt"),
        updatedAt: stringField(payload, "updatedAt"),
        mergedAt: optionalStringField(payload, "mergedAt"),
        labels,
        assignees,
        body: body || "(no body)",
        closingIssues: sortedSet(closing),
        filesChanged: [],
    };
}
