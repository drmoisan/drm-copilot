"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleRunPoshQCFormat = handleRunPoshQCFormat;
exports.handleRunPoshQCAnalyze = handleRunPoshQCAnalyze;
exports.handleRunPoshQCTest = handleRunPoshQCTest;
exports.handleRunPoshQCAnalyzeAutofix = handleRunPoshQCAnalyzeAutofix;
exports.handleRunPoshQCSuite = handleRunPoshQCSuite;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
async function handleRunPoshQCFormat(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveRunPoshQCSuiteToolInput)(rawInput);
    return service.runPoshQCFormat(input);
}
async function handleRunPoshQCAnalyze(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveRunPoshQCSuiteToolInput)(rawInput);
    return service.runPoshQCAnalyze(input);
}
async function handleRunPoshQCTest(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveRunPoshQCSuiteToolInput)(rawInput);
    return service.runPoshQCTest(input);
}
async function handleRunPoshQCAnalyzeAutofix(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveRunPoshQCSuiteToolInput)(rawInput);
    return service.runPoshQCAnalyzeAutofix(input);
}
async function handleRunPoshQCSuite(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveRunPoshQCSuiteToolInput)(rawInput);
    return service.runPoshQCSuite(input);
}
