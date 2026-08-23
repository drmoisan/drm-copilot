"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleResolvePolicyAuditTemplateAsset = handleResolvePolicyAuditTemplateAsset;
exports.handleValidateOrchestrationArtifacts = handleValidateOrchestrationArtifacts;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
async function handleResolvePolicyAuditTemplateAsset(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolvePolicyAuditTemplateAssetToolInput)(rawInput);
    return service.resolvePolicyAuditTemplateAsset(input);
}
async function handleValidateOrchestrationArtifacts(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveValidateOrchestrationArtifactsToolInput)(rawInput);
    return service.validateOrchestrationArtifacts(input);
}
