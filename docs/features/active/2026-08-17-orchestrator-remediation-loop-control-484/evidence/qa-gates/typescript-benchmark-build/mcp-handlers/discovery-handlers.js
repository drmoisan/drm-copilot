"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleValidateDiscoveryArtifacts = handleValidateDiscoveryArtifacts;
exports.handleRunDiscoveryInit = handleRunDiscoveryInit;
exports.handleRunDiscoveryRepoInventory = handleRunDiscoveryRepoInventory;
exports.handleRunDiscoveryDotnetAnalyzer = handleRunDiscoveryDotnetAnalyzer;
exports.handleRunDiscoveryVstoAnalyzer = handleRunDiscoveryVstoAnalyzer;
exports.handleRunDiscoveryScenarioGeneration = handleRunDiscoveryScenarioGeneration;
exports.handleRunDiscoveryReport = handleRunDiscoveryReport;
const mcp_tool_inputs_discovery_1 = require("../mcp-tool-inputs-discovery");
async function handleValidateDiscoveryArtifacts(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveValidateDiscoveryArtifactsToolInput)(rawInput);
    return service.validateDiscoveryArtifacts(input);
}
async function handleRunDiscoveryInit(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryInitToolInput)(rawInput);
    return service.runDiscoveryInit(input);
}
async function handleRunDiscoveryRepoInventory(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryRepoInventoryToolInput)(rawInput);
    return service.runDiscoveryRepoInventory(input);
}
async function handleRunDiscoveryDotnetAnalyzer(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryDotnetAnalyzerToolInput)(rawInput);
    return service.runDiscoveryDotnetAnalyzer(input);
}
async function handleRunDiscoveryVstoAnalyzer(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryVstoAnalyzerToolInput)(rawInput);
    return service.runDiscoveryVstoAnalyzer(input);
}
async function handleRunDiscoveryScenarioGeneration(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryScenarioGenerationToolInput)(rawInput);
    return service.runDiscoveryScenarioGeneration(input);
}
async function handleRunDiscoveryReport(rawInput, service) {
    const input = (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryReportToolInput)(rawInput);
    return service.runDiscoveryReport(input);
}
