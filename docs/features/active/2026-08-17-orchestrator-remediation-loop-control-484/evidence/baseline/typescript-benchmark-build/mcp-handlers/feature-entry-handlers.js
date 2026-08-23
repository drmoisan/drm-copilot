"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleNewPotentialBugEntry = handleNewPotentialBugEntry;
exports.handleNewPotentialEntry = handleNewPotentialEntry;
exports.handlePotentialToIssue = handlePotentialToIssue;
exports.handleNewActiveFeatureFolder = handleNewActiveFeatureFolder;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
async function handleNewPotentialBugEntry(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveNewPotentialBugEntryToolInput)(rawInput);
    return service.newPotentialBugEntry(input);
}
async function handleNewPotentialEntry(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveNewPotentialEntryToolInput)(rawInput);
    return service.newPotentialEntry(input);
}
async function handlePotentialToIssue(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolvePotentialToIssueToolInput)(rawInput);
    return service.potentialToIssue(input);
}
async function handleNewActiveFeatureFolder(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveNewActiveFeatureFolderToolInput)(rawInput);
    return service.newActiveFeatureFolder(input);
}
