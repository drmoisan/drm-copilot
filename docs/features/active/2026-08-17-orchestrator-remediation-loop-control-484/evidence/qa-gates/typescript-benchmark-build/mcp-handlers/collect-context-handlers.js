"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleCollectCommitContext = handleCollectCommitContext;
exports.handleCollectPrContext = handleCollectPrContext;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
async function handleCollectCommitContext(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveCollectCommitContextToolInput)(rawInput);
    return service.collectCommitContext(input);
}
async function handleCollectPrContext(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveCollectPrContextToolInput)(rawInput);
    return service.collectPrContext(input);
}
