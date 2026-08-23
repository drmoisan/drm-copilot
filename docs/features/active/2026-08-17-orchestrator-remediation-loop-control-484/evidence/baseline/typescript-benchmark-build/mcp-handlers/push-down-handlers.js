"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handlePushDownCopilotCustomizations = handlePushDownCopilotCustomizations;
exports.handlePushDownCodexAndAgentsCustomizations = handlePushDownCodexAndAgentsCustomizations;
exports.handlePushDownClaudeCustomizations = handlePushDownClaudeCustomizations;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
async function handlePushDownCopilotCustomizations(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolvePushDownCopilotCustomizationsToolInput)(rawInput);
    return service.pushDownCopilotCustomizations(input);
}
async function handlePushDownCodexAndAgentsCustomizations(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolvePushDownCodexAndAgentsCustomizationsToolInput)(rawInput);
    return service.pushDownCodexAndAgentsCustomizations(input);
}
async function handlePushDownClaudeCustomizations(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolvePushDownClaudeCustomizationsToolInput)(rawInput);
    return service.pushDownClaudeCustomizations(input);
}
