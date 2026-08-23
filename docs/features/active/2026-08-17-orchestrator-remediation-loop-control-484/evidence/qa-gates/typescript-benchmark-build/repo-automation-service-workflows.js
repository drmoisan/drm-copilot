"use strict";
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
exports.resolvePolicyAuditTemplateAssetResult = resolvePolicyAuditTemplateAssetResult;
exports.buildTemplateRoot = buildTemplateRoot;
exports.runResolveExecuteHardLockPrompt = runResolveExecuteHardLockPrompt;
exports.runResolveAtomicPlanPrompt = runResolveAtomicPlanPrompt;
const path = __importStar(require("node:path"));
const policy_audit_template_assets_1 = require("./policy-audit-template-assets");
const resolve_prompts_service_call_1 = require("./lib/resolve/resolve-prompts-service-call");
const repo_automation_service_support_1 = require("./repo-automation-service-support");
function resolvePolicyAuditTemplateAssetResult(extensionRoot, input) {
    const resolvedAsset = (0, policy_audit_template_assets_1.resolveBundledPolicyAuditTemplateAsset)(extensionRoot, input.asset);
    const destinationPath = input.targetPath === undefined
        ? undefined
        : (0, policy_audit_template_assets_1.copyBundledPolicyAuditTemplateAsset)(resolvedAsset.bundledSourcePath, input.targetPath);
    return {
        tool: "resolve_policy_audit_template_asset",
        workspaceRoot: input.workspaceRoot,
        summary: destinationPath === undefined
            ? `Resolved bundled policy-audit asset '${input.asset}'.`
            : `Copied bundled policy-audit asset '${input.asset}' to '${destinationPath}'.`,
        artifacts: destinationPath === undefined
            ? [resolvedAsset.bundledSourcePath]
            : [resolvedAsset.bundledSourcePath, destinationPath],
        assetId: resolvedAsset.assetId,
        bundledSourcePath: resolvedAsset.bundledSourcePath,
        ...(destinationPath === undefined ? {} : { destinationPath }),
    };
}
function buildTemplateRoot(extensionRoot) {
    return (0, repo_automation_service_support_1.normalizeGeneratedPath)(path.join(extensionRoot, "resources", "feature-templates"));
}
/**
 * Run the in-process hard-lock resolver and return the preserved result.
 *
 * Thin wrapper that keeps `RepoAutomationService.resolveExecuteHardLockPrompt`
 * a single delegation while the F5 wiring lives in
 * `lib/resolve/resolve-prompts-service-call.ts`.
 *
 * @param deps Filesystem, extension root, and log sink from the service.
 * @param input Workspace root, target, and optional output/quiet.
 * @returns The preserved hard-lock service result record.
 */
function runResolveExecuteHardLockPrompt(deps, input) {
    return (0, resolve_prompts_service_call_1.resolveExecuteHardLockPromptServiceCall)({
        fileSystem: deps.fileSystem,
        extensionRoot: deps.extensionRoot,
        workspaceRoot: input.workspaceRoot,
        target: input.target,
        output: input.output,
        quiet: input.quiet,
        log: deps.log,
    });
}
/**
 * Run the in-process atomic-plan resolver and return the preserved result.
 *
 * @param deps Filesystem, extension root, and log sink from the service.
 * @param input Workspace root and target.
 * @returns The preserved atomic-plan service result record.
 */
function runResolveAtomicPlanPrompt(deps, input) {
    return (0, resolve_prompts_service_call_1.resolveAtomicPlanPromptServiceCall)({
        fileSystem: deps.fileSystem,
        extensionRoot: deps.extensionRoot,
        workspaceRoot: input.workspaceRoot,
        target: input.target,
        log: deps.log,
    });
}
