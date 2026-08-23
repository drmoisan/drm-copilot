"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleRunCodexNativeConverter = handleRunCodexNativeConverter;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
async function handleRunCodexNativeConverter(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveRunCodexNativeConverterToolInput)(rawInput);
    return service.runCodexNativeConverter(input);
}
