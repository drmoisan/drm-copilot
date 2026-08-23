"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH = void 0;
exports.handleResolveExecuteHardLockPrompt = handleResolveExecuteHardLockPrompt;
const mcp_tool_inputs_1 = require("../mcp-tool-inputs");
exports.DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH = "artifacts/hard_lock_prompt.txt";
async function handleResolveExecuteHardLockPrompt(rawInput, service) {
    const input = (0, mcp_tool_inputs_1.resolveResolveExecuteHardLockPromptToolInput)(rawInput);
    return service.resolveExecuteHardLockPrompt({
        ...input,
        output: exports.DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH,
        quiet: true,
    });
}
