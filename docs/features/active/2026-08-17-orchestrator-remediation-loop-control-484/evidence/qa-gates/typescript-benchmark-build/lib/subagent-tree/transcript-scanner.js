"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.scanTranscripts = scanTranscripts;
const transcript_parser_1 = require("./transcript-parser");
/** Suffix identifying a subagent meta file. */
const META_SUFFIX = ".meta.json";
/** Suffix identifying a transcript file (root session or subagent). */
const TRANSCRIPT_SUFFIX = ".jsonl";
/** Matches `agent-<agentId>.meta.json`, capturing `<agentId>`. */
const META_FILENAME_PATTERN = /agent-([^/\\]+)\.meta\.json$/;
/**
 * Scan a root session transcript and its sibling subagent transcripts.
 *
 * Purpose:
 *     The only file in the subagent-tree module that touches `FileSystem`.
 *     Derives the sibling `subagents` directory per Design Decision item 7,
 *     globs its `agent-*.meta.json` files, and reads each meta file plus its
 *     sibling `.jsonl` transcript, delegating line-level parsing to
 *     `parseTranscriptLines`.
 *
 * Tolerance:
 *     A missing `subagents` directory yields zero subagents rather than
 *     raising (the injected `FileSystem.glob` returns no matches for an
 *     absent root). A meta file that is not well-formed JSON or is missing a
 *     required field is skipped rather than raising, so one malformed
 *     subagent does not fail the whole scan.
 *
 * @param rootSessionPath Absolute path to the root session's `.jsonl` file.
 * @param fileSystem Injected filesystem seam (production: `RealFileSystem`).
 * @returns The root transcript's parsed facts plus every well-formed
 *   subagent's parsed meta and transcript facts.
 * @throws {Error} When `rootSessionPath` does not end in `.jsonl`.
 */
function scanTranscripts(rootSessionPath, fileSystem) {
    if (!rootSessionPath.endsWith(TRANSCRIPT_SUFFIX)) {
        throw new Error(`scanTranscripts: rootSessionPath must end in "${TRANSCRIPT_SUFFIX}", got: ${rootSessionPath}`);
    }
    const root = readTranscript(rootSessionPath, fileSystem);
    const subagentsDir = `${rootSessionPath.slice(0, -TRANSCRIPT_SUFFIX.length)}/subagents`;
    const metaPaths = fileSystem.glob(subagentsDir, "agent-*.meta.json");
    const subagents = metaPaths
        .map((metaPath) => readSubagent(metaPath, fileSystem))
        .filter((subagent) => subagent !== undefined);
    return { root, subagents };
}
/**
 * Read and parse a single transcript file's lines.
 *
 * @param path Absolute path to a `.jsonl` transcript file.
 * @param fileSystem Injected filesystem seam.
 * @returns The transcript's parsed models and `Agent` tool-use ids.
 */
function readTranscript(path, fileSystem) {
    const content = fileSystem.readTextFile(path);
    return (0, transcript_parser_1.parseTranscriptLines)(content.split(/\r?\n/));
}
/**
 * Read one subagent's meta file and its sibling transcript.
 *
 * @param metaPath Absolute path to `agent-<agentId>.meta.json`.
 * @param fileSystem Injected filesystem seam.
 * @returns The parsed subagent, or `undefined` when the meta filename or
 *   contents are not well-formed.
 */
function readSubagent(metaPath, fileSystem) {
    const filenameMatch = META_FILENAME_PATTERN.exec(metaPath);
    const agentId = filenameMatch?.[1];
    if (agentId === undefined) {
        return undefined;
    }
    const metaContent = fileSystem.readTextFile(metaPath);
    const meta = parseSubagentMeta(agentId, metaContent);
    if (!meta) {
        return undefined;
    }
    const transcriptPath = metaPath.slice(0, -META_SUFFIX.length) + TRANSCRIPT_SUFFIX;
    const transcript = readTranscript(transcriptPath, fileSystem);
    return { meta, transcript };
}
/**
 * Parse the JSON contents of a subagent's meta file into a `SubagentMeta`.
 *
 * @param agentId The `agentId` parsed from the meta filename.
 * @param content Raw JSON text of the meta file.
 * @returns The parsed meta, or `undefined` when required fields are absent
 *   or of the wrong type.
 */
function parseSubagentMeta(agentId, content) {
    let parsed;
    try {
        parsed = JSON.parse(content);
    }
    catch {
        return undefined;
    }
    if (typeof parsed !== "object" || parsed === null) {
        return undefined;
    }
    const record = parsed;
    const agentType = record["agentType"];
    const description = record["description"];
    const toolUseId = record["toolUseId"];
    const spawnDepth = record["spawnDepth"];
    if (typeof agentType !== "string" ||
        typeof description !== "string" ||
        typeof toolUseId !== "string" ||
        typeof spawnDepth !== "number") {
        return undefined;
    }
    const worktreePath = record["worktreePath"];
    const worktreeBranch = record["worktreeBranch"];
    return {
        agentId,
        agentType,
        description,
        toolUseId,
        spawnDepth,
        ...(typeof worktreePath === "string" ? { worktreePath } : {}),
        ...(typeof worktreeBranch === "string" ? { worktreeBranch } : {}),
    };
}
