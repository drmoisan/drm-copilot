"use strict";
/**
 * Pure line-level transcript parser.
 *
 * Purpose:
 *     Extract the two facts the subagent-tree algorithm needs from a single
 *     transcript file's lines: the distinct `message.model` values observed,
 *     and the ordered list of `Agent` tool-use ids emitted by assistant
 *     turns, in file line order. Performs no I/O; the caller supplies the
 *     already-read lines.
 *
 * Tolerance:
 *     Blank lines, non-JSON lines, and lines whose `message` field is not an
 *     object are skipped rather than raising, since a transcript may contain
 *     turn shapes irrelevant to this algorithm (e.g. plain user text turns).
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseTranscriptLines = parseTranscriptLines;
/**
 * Parse transcript lines into the model set and ordered `Agent` tool-use ids.
 *
 * @param lines Raw lines of a `.jsonl` transcript file, one JSON object per line.
 * @returns The distinct models observed and the ordered `Agent` tool-use ids.
 */
function parseTranscriptLines(lines) {
    const models = [];
    const seenModels = new Set();
    const agentToolUseIds = [];
    for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.length === 0) {
            continue;
        }
        const parsed = tryParseJson(trimmed);
        if (!isRecord(parsed)) {
            continue;
        }
        const message = parsed["message"];
        if (!isRecord(message)) {
            continue;
        }
        recordModel(message["model"], models, seenModels);
        collectAgentToolUseIds(message["content"], agentToolUseIds);
    }
    return { models, agentToolUseIds };
}
/**
 * Parse `text` as JSON, returning `undefined` on failure instead of raising.
 *
 * @param text The line text to parse.
 * @returns The parsed value, or `undefined` when `text` is not valid JSON.
 */
function tryParseJson(text) {
    try {
        return JSON.parse(text);
    }
    catch {
        return undefined;
    }
}
/**
 * @param value A candidate value.
 * @returns True when `value` is a non-null JSON object (not an array).
 */
function isRecord(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
/**
 * Append `model` to `models` when it is a truthy string not already seen.
 *
 * @param model The candidate `message.model` value.
 * @param models The accumulator of distinct models, in first-seen order.
 * @param seenModels The set of models already recorded.
 */
function recordModel(model, models, seenModels) {
    if (typeof model === "string" && model.length > 0 && !seenModels.has(model)) {
        seenModels.add(model);
        models.push(model);
    }
}
/**
 * Append every `Agent` tool-use id found in `content` to `agentToolUseIds`,
 * in array order.
 *
 * @param content The candidate `message.content` value.
 * @param agentToolUseIds The accumulator of `Agent` tool-use ids.
 */
function collectAgentToolUseIds(content, agentToolUseIds) {
    if (!Array.isArray(content)) {
        return;
    }
    for (const block of content) {
        if (!isRecord(block)) {
            continue;
        }
        if (block["type"] === "tool_use" &&
            block["name"] === "Agent" &&
            typeof block["id"] === "string") {
            agentToolUseIds.push(block["id"]);
        }
    }
}
