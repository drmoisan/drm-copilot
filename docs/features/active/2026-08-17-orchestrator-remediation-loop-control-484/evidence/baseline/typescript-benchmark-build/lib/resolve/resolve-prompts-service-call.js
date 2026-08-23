"use strict";
/**
 * In-process wiring for the two resolve-prompt service methods.
 *
 * Purpose:
 *     Hold the bodies that `RepoAutomationService.resolveExecuteHardLockPrompt`
 *     and `resolveAtomicPlanPrompt` delegate to, so the service file stays
 *     within the 500-line limit while preserving each method's observable
 *     return contract exactly. Mirrors the F2 `validate-orchestration-service-
 *     call.ts` precedent.
 *
 * Responsibilities:
 *     - Resolve the injected template root / template path from `extensionRoot`
 *       (the values the bundled wrappers inject).
 *     - Invoke the in-process resolvers with a no-op clipboard seam so the
 *       quiet/MCP path performs no real OS clipboard interaction.
 *     - Build the preserved service result records and surface non-zero command
 *       outcomes as thrown errors.
 *
 * Side effects:
 *     Reads templates/targets and writes the hard-lock output file through the
 *     injected {@link FileSystem}; performs no other I/O.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveExecuteHardLockPromptServiceCall = resolveExecuteHardLockPromptServiceCall;
exports.resolveAtomicPlanPromptServiceCall = resolveAtomicPlanPromptServiceCall;
const path = __importStar(require("node:path"));
const file_system_1 = require("../file-system");
const repo_automation_service_support_1 = require("../../repo-automation-service-support");
const workflow_command_arguments_1 = require("../../workflow-command-arguments");
const hard_lock_prompt_1 = require("./hard-lock-prompt");
const file_prompt_core_1 = require("./file-prompt-core");
/**
 * Resolve the execute hard-lock prompt in-process.
 *
 * Enforces the preserved TS-layer guard (`quiet` requires `output`) before any
 * file work, resolves the bundled hard-lock template root from `extensionRoot`,
 * invokes {@link resolveExecuteHardLockCommand} with a no-op clipboard seam,
 * surfaces a non-zero command outcome as a thrown error, and returns the
 * preserved result record (with `artifacts` computed from the resolved output
 * path, matching the previously-spawned command's artifact contract).
 *
 * @param input Filesystem, extension/workspace roots, target, and optional
 *   output/quiet/log.
 * @returns The preserved hard-lock service result record.
 * @throws Error When `quiet` is set without `output`, or when the command
 *   reports a non-zero exit (the message carries the command's error text).
 */
function resolveExecuteHardLockPromptServiceCall(input) {
    // Preserve the existing TS-layer guard message verbatim; it must run before
    // any file work, matching the prior builder-level guard and its test.
    if (input.quiet === true && input.output === undefined) {
        throw new Error("resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.");
    }
    const templateRoot = (0, file_system_1.toPosixPath)(path.join(input.extensionRoot, "resources", "customizations", ".github", "codex"));
    // Capture the command's emitted lines so a non-zero exit can be surfaced as a
    // thrown error while still forwarding output to the service log sink.
    const emittedLines = [];
    const log = (message) => {
        emittedLines.push(message);
        input.log?.(message);
    };
    const result = (0, hard_lock_prompt_1.resolveExecuteHardLockCommand)({
        targetPath: input.target,
        workspaceRoot: input.workspaceRoot,
        templateKind: "execute",
        templateRoot,
        ...(input.output === undefined ? {} : { output: input.output }),
        ...(input.quiet === undefined ? {} : { quiet: input.quiet }),
        fs: input.fileSystem,
        copyToClipboard: () => false,
        log,
    });
    if (result.exitCode !== 0) {
        throw new Error(`resolve_execute_hard_lock_prompt failed:\n${emittedLines.join("\n")}`);
    }
    const artifacts = input.output === undefined
        ? undefined
        : [
            (0, repo_automation_service_support_1.normalizeGeneratedPath)((0, workflow_command_arguments_1.isAbsolutePathLike)(input.output)
                ? input.output
                : path.join(input.workspaceRoot, input.output)),
        ];
    return {
        tool: "resolve_execute_hard_lock_prompt",
        workspaceRoot: input.workspaceRoot,
        summary: `Resolved the execute hard-lock prompt for '${input.target}'.`,
        ...(artifacts === undefined ? {} : { artifacts }),
    };
}
/**
 * Resolve the atomic-plan prompt in-process.
 *
 * Resolves the bundled atomic-plan template path from `extensionRoot`, resolves
 * the target against the workspace root when relative (absolute used verbatim),
 * invokes {@link resolveAtomicPlanCommand} with a no-op clipboard seam (so the
 * "could not copy" branch is the deterministic outcome), surfaces a non-zero
 * command outcome as a thrown error, and returns the preserved result record
 * with no `artifacts` field.
 *
 * @param input Filesystem, extension/workspace roots, target, and optional log.
 * @returns The preserved atomic-plan service result record.
 * @throws Error When the command reports a non-zero exit (the message carries
 *   the command's error text).
 */
function resolveAtomicPlanPromptServiceCall(input) {
    const templatePath = (0, file_system_1.toPosixPath)(path.join(input.extensionRoot, "resources", "customizations", ".github", "prompts", "generate-atomic-plan.prompt.md"));
    const targetPath = (0, workflow_command_arguments_1.isAbsolutePathLike)(input.target)
        ? (0, file_system_1.toPosixPath)(input.target)
        : (0, file_system_1.toPosixPath)(path.join(input.workspaceRoot, input.target));
    const emittedLines = [];
    const log = (message) => {
        emittedLines.push(message);
        input.log?.(message);
    };
    const result = (0, file_prompt_core_1.resolveAtomicPlanCommand)({
        templatePath,
        targetPath,
        workspaceRoot: input.workspaceRoot,
        fs: input.fileSystem,
        copyToClipboard: () => false,
        log,
    });
    if (result.exitCode !== 0) {
        throw new Error(`resolve_atomic_plan_prompt failed:\n${emittedLines.join("\n")}`);
    }
    return {
        tool: "resolve_atomic_plan_prompt",
        workspaceRoot: input.workspaceRoot,
        summary: `Resolved the atomic-plan prompt for '${input.target}'.`,
    };
}
