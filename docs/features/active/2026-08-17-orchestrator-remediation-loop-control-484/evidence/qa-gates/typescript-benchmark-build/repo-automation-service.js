"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createRepoAutomationService = createRepoAutomationService;
const repo_automation_service_support_1 = require("./repo-automation-service-support");
const repo_automation_execute_script_1 = require("./repo-automation-execute-script");
const repo_automation_args_1 = require("./repo-automation-args");
const repo_automation_service_push_down_1 = require("./repo-automation-service-push-down");
const repo_automation_service_workflows_1 = require("./repo-automation-service-workflows");
const codex_native_converter_service_call_1 = require("./lib/codex-native-converter/codex-native-converter-service-call");
const file_system_1 = require("./lib/file-system");
const subprocess_runner_1 = require("./lib/subprocess-runner");
const validate_orchestration_service_call_1 = require("./lib/validate/validate-orchestration-service-call");
const build_validate_orchestration_service_call_input_1 = require("./lib/validate/build-validate-orchestration-service-call-input");
const new_potential_bug_entry_service_call_1 = require("./lib/new-potential-bug-entry-service-call");
const pr_context_service_call_1 = require("./lib/pr-context/pr-context-service-call");
const potential_to_issue_service_call_1 = require("./lib/potential-to-issue/potential-to-issue-service-call");
const new_active_feature_folder_service_call_1 = require("./lib/new-active-feature-folder/new-active-feature-folder-service-call");
const filesystem_adapter_1 = require("./lib/push-down/filesystem-adapter");
const repo_automation_service_subagent_tree_1 = require("./repo-automation-service-subagent-tree");
const repo_automation_execute_discovery_1 = require("./repo-automation-execute-discovery");
class DefaultRepoAutomationService {
    extensionRoot;
    output;
    templateRoot;
    fileSystem;
    runner;
    resolvePromptDeps;
    pushDownDeps;
    constructor(options) {
        this.extensionRoot = options.extensionRoot;
        this.output = options.output;
        this.templateRoot = (0, repo_automation_service_workflows_1.buildTemplateRoot)(this.extensionRoot);
        this.fileSystem = options.fileSystem ?? new file_system_1.RealFileSystem();
        this.runner = options.runner ?? new subprocess_runner_1.SubprocessRunner();
        this.resolvePromptDeps = {
            fileSystem: this.fileSystem,
            extensionRoot: this.extensionRoot,
            log: (message) => this.output.appendLine(message),
        };
        this.pushDownDeps = {
            fs: options.pushDownFileSystem ?? new filesystem_adapter_1.RealPushDownFileSystem(),
            extensionRoot: this.extensionRoot,
            log: (message) => this.output.appendLine(message),
        };
    }
    async collectCommitContext(input) {
        // In-process TS port of collect_commit_context.py (F4): delegate to the
        // support helper instead of spawning the bundled Python script.
        return (0, repo_automation_service_support_1.runCollectCommitContext)({
            runner: this.runner,
            fileSystem: this.fileSystem,
            workspaceRoot: input.workspaceRoot,
            log: (message) => this.output.appendLine(message),
        });
    }
    async collectPrContext(input) {
        // In-process TS port of the pr_context collector (F9): delegate to the
        // extracted helper instead of spawning the bundled Python script.
        return (0, pr_context_service_call_1.collectPrContextServiceCall)({
            runner: this.runner,
            fileSystem: this.fileSystem,
            workspaceRoot: input.workspaceRoot,
            base: input.base,
            log: (message) => this.output.appendLine(message),
        });
    }
    async runCodexNativeConverter(input) {
        // In-process TS port of codex_native_converter (F10): delegate to the
        // extracted helper instead of spawning the bundled Python script.
        return (0, codex_native_converter_service_call_1.runCodexNativeConverterServiceCall)({
            fileSystem: this.fileSystem,
            workspaceRoot: input.workspaceRoot,
            mode: input.mode,
            sourceEcosystem: input.sourceEcosystem,
            sourceRoot: input.sourceRoot,
            selectedPaths: input.selectedPaths,
            destinationRoot: input.destinationRoot,
            artifactRoot: input.artifactRoot,
            enableRepoPrompts: input.enableRepoPrompts,
            log: (message) => this.output.appendLine(message),
        });
    }
    async pushDownCopilotCustomizations(input) {
        // In-process TS port (F3): delegate to the push-down helper.
        return (0, repo_automation_service_push_down_1.runPushDownCopilotCustomizations)(input.workspaceRoot, this.pushDownDeps);
    }
    async pushDownCodexAndAgentsCustomizations(input) {
        return (0, repo_automation_service_push_down_1.runPushDownCodexAndAgentsCustomizations)(input, this.pushDownDeps);
    }
    async pushDownClaudeCustomizations(input) {
        // In-process TS port (F3): the helper forwards optional pack/variant/memory.
        return (0, repo_automation_service_push_down_1.runPushDownClaudeCustomizations)(input, this.pushDownDeps);
    }
    async newPotentialBugEntry(input) {
        // In-process TS port of new_potential_bug_entry.py (F6): delegate to the
        // extracted helper instead of spawning the bundled Python script. The helper
        // passes a no-op editor launcher so no `code`/`code-insiders` subprocess runs.
        return (0, new_potential_bug_entry_service_call_1.newPotentialBugEntryServiceCall)({
            fileSystem: this.fileSystem,
            runner: this.runner,
            workspaceRoot: input.workspaceRoot,
            shortName: input.shortName,
            templateRoot: this.templateRoot,
            log: (message) => this.output.appendLine(message),
        });
    }
    async newPotentialEntry(input) {
        return this.executeScript({
            tool: "new_potential_entry",
            runtimeKind: "powershell",
            bundledRelativePath: "resources/templates/new-potential-entry.ps1",
            workspaceRoot: input.workspaceRoot,
            invocationId: input.invocationId ?? "new_potential_entry",
            args: ["-ShortName", input.shortName, "-TemplateRoot", this.templateRoot],
            summary: `Created a new potential entry for '${input.shortName}'.`,
            stdoutArtifactPattern: /^Created:\s*(.+)$/im,
        });
    }
    async linkParentChild(input) {
        return this.executeScript({
            tool: "link_parent_child",
            runtimeKind: "powershell",
            bundledRelativePath: "resources/templates/link-parent-child.ps1",
            workspaceRoot: input.workspaceRoot,
            invocationId: input.invocationId ?? "link_parent_child",
            args: [
                "-ParentIssueNumber",
                input.parentIssueNumber,
                "-ChildIssueNumber",
                input.childIssueNumber,
            ],
            summary: `Linked child issue #${input.childIssueNumber} to parent issue #${input.parentIssueNumber} using the bundled workflow.`,
        });
    }
    async potentialToIssue(input) {
        // In-process TS port of potential_to_issue.py (F7): delegate to the extracted
        // helper instead of spawning the bundled Python script. The helper runs the
        // gh calls through the injected runner and preserves the return contract.
        return (0, potential_to_issue_service_call_1.potentialToIssueServiceCall)({
            runner: this.runner,
            workspaceRoot: input.workspaceRoot,
            potentialPath: input.potentialPath,
            promotionType: input.promotionType,
            workMode: input.workMode,
            log: (message) => this.output.appendLine(message),
        });
    }
    async newActiveFeatureFolder(input) {
        return (0, new_active_feature_folder_service_call_1.newActiveFeatureFolderServiceCall)({
            ...input,
            runner: this.runner,
            templateRoot: this.templateRoot,
            log: (message) => this.output.appendLine(message),
        });
    }
    async runPoshQCFormat(input) {
        return this.runPoshQcWorkflow("run_poshqc_format", input);
    }
    async runPoshQCAnalyze(input) {
        return this.runPoshQcWorkflow("run_poshqc_analyze", input);
    }
    async runPoshQCTest(input) {
        return this.runPoshQcWorkflow("run_poshqc_test", input);
    }
    async runPoshQCAnalyzeAutofix(input) {
        return this.runPoshQcWorkflow("run_poshqc_analyze_autofix", input);
    }
    async runPoshQCSuite(input) {
        return this.runPoshQcWorkflow("run_poshqc_suite", input);
    }
    async resolvePolicyAuditTemplateAsset(input) {
        return (0, repo_automation_service_workflows_1.resolvePolicyAuditTemplateAssetResult)(this.extensionRoot, input);
    }
    async resolveExecuteHardLockPrompt(input) {
        // In-process TS port of resolve_hard_lock_prompt.py (F5).
        return (0, repo_automation_service_workflows_1.runResolveExecuteHardLockPrompt)(this.resolvePromptDeps, input);
    }
    async resolveAtomicPlanPrompt(input) {
        // In-process TS port of the bundled resolve_file_prompt.py (F5).
        return (0, repo_automation_service_workflows_1.runResolveAtomicPlanPrompt)(this.resolvePromptDeps, input);
    }
    async runPoshQcWorkflow(tool, input) {
        const { args, bundledRelativePath, summary } = (0, repo_automation_args_1.buildPoshQcWorkflowArguments)(tool, input);
        return this.executeScript({
            tool: tool,
            runtimeKind: "powershell",
            bundledRelativePath,
            workspaceRoot: input.workspaceRoot,
            invocationId: input.invocationId ?? tool,
            args,
            summary,
        });
    }
    async validateOrchestrationArtifacts(input) {
        // Delegate to the extracted helper, which preserves the observable behavior.
        // Request shaping (optional-field omission) lives in the extracted builder.
        return (0, validate_orchestration_service_call_1.validateOrchestrationServiceCall)((0, build_validate_orchestration_service_call_input_1.buildValidateOrchestrationServiceCallInput)(this.fileSystem, input, this.runner));
    }
    async renderSubagentTree(input) {
        return (0, repo_automation_service_subagent_tree_1.renderSubagentTreeServiceCall)({
            ...input,
            fileSystem: this.fileSystem,
        });
    }
    async validateDiscoveryArtifacts(input) {
        // Thin delegation to the central discovery mapping + Python subprocess
        // helper; no dev.discovery.* logic is re-authored here.
        return (0, repo_automation_execute_discovery_1.runValidateDiscoveryArtifacts)(this.output, input);
    }
    async runDiscoveryInit(input) {
        return (0, repo_automation_execute_discovery_1.runDiscoveryInit)(this.output, input);
    }
    async runDiscoveryRepoInventory(input) {
        return (0, repo_automation_execute_discovery_1.runDiscoveryRepoInventory)(this.output, input);
    }
    async runDiscoveryDotnetAnalyzer(input) {
        return (0, repo_automation_execute_discovery_1.runDiscoveryDotnetAnalyzer)(this.output, input);
    }
    async runDiscoveryVstoAnalyzer(input) {
        return (0, repo_automation_execute_discovery_1.runDiscoveryVstoAnalyzer)(this.output, input);
    }
    async runDiscoveryScenarioGeneration(input) {
        return (0, repo_automation_execute_discovery_1.runDiscoveryScenarioGeneration)(this.output, input);
    }
    async runDiscoveryReport(input) {
        return (0, repo_automation_execute_discovery_1.runDiscoveryReport)(this.output, input);
    }
    async executeScript(options) {
        return (0, repo_automation_execute_script_1.executeScriptServiceCall)(this.output, this.extensionRoot, options);
    }
}
function createRepoAutomationService(options) {
    return new DefaultRepoAutomationService(options);
}
