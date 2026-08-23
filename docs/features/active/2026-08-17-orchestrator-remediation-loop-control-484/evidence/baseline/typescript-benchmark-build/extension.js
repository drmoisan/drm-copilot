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
exports.resolveCodexExecutable = exports.detectRuntime = void 0;
exports.activate = activate;
exports.deactivate = deactivate;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const vscode = __importStar(require("vscode"));
const claude_worktree_session_1 = require("./claude-worktree-session");
const codex_worktree_session_1 = require("./codex-worktree-session");
const command_runtime_1 = require("./command-runtime");
Object.defineProperty(exports, "detectRuntime", { enumerable: true, get: function () { return command_runtime_1.detectRuntime; } });
Object.defineProperty(exports, "resolveCodexExecutable", { enumerable: true, get: function () { return command_runtime_1.resolveCodexExecutable; } });
const discovery_command_registration_1 = require("./discovery-command-registration");
const document_workflow_commands_1 = require("./document-workflow-commands");
const file_system_1 = require("./lib/file-system");
const hello_message_1 = require("./lib/hello-message");
const extension_command_helpers_1 = require("./extension-command-helpers");
const mcp_provider_1 = require("./mcp-provider");
const poshqc_command_registration_1 = require("./poshqc-command-registration");
const remove_worktrees_1 = require("./remove-worktrees");
const remove_worktrees_runner_1 = require("./remove-worktrees-runner");
const repo_automation_service_1 = require("./repo-automation-service");
const repo_automation_command_registration_1 = require("./repo-automation-command-registration");
const subagent_tree_command_1 = require("./subagent-tree-command");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
/**
 * Grace period (milliseconds) between sending the pre-claude commands
 * (`git worktree add`, `Set-Location`, optional venv activate) and the final
 * `claude` invocation. VS Code's Python extension auto-injects venv
 * activation via terminal.sendText after a short asynchronous delay; this
 * constant must be long enough that any such injection lands while the host
 * shell is still at its prompt and is consumed normally, otherwise the
 * injected text gets buffered into claude's TUI input.
 */
const TERMINAL_AUTO_ACTIVATION_GRACE_MS = 5000;
const INSTALLED_CODEX_EXTENSION_IDS = ["openai.chatgpt", "openai.codex"];
function getInstalledCodexExtensionCandidateRoots() {
    return INSTALLED_CODEX_EXTENSION_IDS.map((extensionId) => vscode.extensions.getExtension(extensionId)?.extensionUri.fsPath).filter((extensionRoot) => extensionRoot !== undefined && extensionRoot.trim().length > 0);
}
/**
 * Detects whether the workspace's `pyproject.toml` declares poetry as the
 * dependency-management tool, signalling that the worktree should run
 * `poetry install --with dev` and activate the resulting in-project venv
 * before starting Claude.
 *
 * @param workspaceRoot The absolute path of the source repository.
 * @returns `true` when a `pyproject.toml` exists at the workspace root and
 *          the literal substring "poetry" appears anywhere in the file.
 */
function pyprojectHasPoetry(workspaceRoot) {
    const normalizedRoot = workspaceRoot.replace(/\\/g, "/").replace(/\/+$/, "");
    const pyprojectPath = `${normalizedRoot}/pyproject.toml`;
    if (!fs.existsSync(pyprojectPath)) {
        return false;
    }
    const contents = fs.readFileSync(pyprojectPath, "utf-8");
    return contents.includes("poetry");
}
function resolveSourceRootPath(sourceRoot, configuredPath) {
    const trimmedPath = configuredPath.trim();
    if (trimmedPath.length === 0) {
        return "";
    }
    const normalizedPath = trimmedPath.replace(/\\/g, "/");
    if (/^[A-Za-z]:\//.test(normalizedPath) || normalizedPath.startsWith("/")) {
        return normalizedPath;
    }
    const normalizedRoot = sourceRoot.replace(/\\/g, "/").replace(/\/+$/, "");
    return `${normalizedRoot}/${normalizedPath.replace(/^\/+/, "")}`;
}
/**
 * Activates the extension by registering all command handlers and shared resources.
 *
 * @param context The extension lifecycle context supplied by VS Code.
 * @returns Nothing.
 */
function activate(context) {
    const output = (0, command_runtime_1.createOutputChannel)();
    const service = (0, repo_automation_service_1.createRepoAutomationService)({
        extensionRoot: context.extensionUri.fsPath,
        output,
    });
    const helloPythonDisposable = vscode.commands.registerCommand("drmCopilotExtension.helloPython", () => {
        // Run the smoke test in-process: resolve the workspace root and write
        // artifacts/hello_python.txt through the real filesystem. This preserves
        // the command's observable output contract without spawning a runtime.
        const result = (0, hello_message_1.writeHelloMessage)({
            fileSystem: new file_system_1.RealFileSystem(),
            workspaceRoot: (0, command_runtime_1.getWorkspaceRoot)(),
        });
        output.appendLine(`[drmCopilotExtension.helloPython] ${result.summary}`);
    });
    const helloPowerShellDisposable = vscode.commands.registerCommand("drmCopilotExtension.helloPowerShell", async () => {
        await (0, command_runtime_1.executeBundledScript)(context, output, {
            runtimeKind: "powershell",
            bundledRelativePath: "resources/templates/hello_pwsh.ps1",
            commandId: "drmCopilotExtension.helloPowerShell",
        });
    });
    const repoAutomationDisposables = (0, repo_automation_command_registration_1.registerRepoAutomationCommands)({
        context,
        output,
        service,
    });
    const newClaudeWorktreeSessionDisposable = vscode.commands.registerCommand("drmCopilotExtension.newClaudeWorktreeSession", async () => {
        const commandId = "drmCopilotExtension.newClaudeWorktreeSession";
        const objective = await vscode.window.showInputBox({
            title: "drm-copilot: New Claude Worktree Session",
            prompt: "Enter the objective to pass to claude as a prompt. Leave blank to skip.",
            ignoreFocusOut: true,
        });
        if (objective === undefined) {
            return;
        }
        // Resolve the PowerShell runtime first so a missing host fails fast with
        // the established error message rather than after creating a terminal.
        const runtime = (0, command_runtime_1.detectRuntime)("powershell");
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const repoName = path.basename(workspaceRoot);
        const workspaceParent = path.dirname(workspaceRoot);
        const timestamp = (0, claude_worktree_session_1.formatWorktreeTimestamp)(new Date());
        const worktreePath = (0, claude_worktree_session_1.buildWorktreePath)(workspaceParent, timestamp, repoName);
        const branchName = (0, claude_worktree_session_1.buildBranchName)(timestamp, repoName);
        const usePoetry = pyprojectHasPoetry(workspaceRoot);
        const configuredPreClaudeScriptPath = vscode.workspace
            .getConfiguration("drmCopilotExtension.newClaudeWorktreeSession")
            .get("preClaudeScriptPath") ??
            ".claude/hooks/pre-claude-session.ps1";
        const commands = (0, claude_worktree_session_1.buildWorktreeSessionCommands)({
            repoRoot: workspaceRoot,
            worktreePath,
            branchName,
            usePoetry,
            objective,
            preClaudeScriptPath: configuredPreClaudeScriptPath,
        });
        // The terminal must start inside the source repository so that
        // `git worktree add` can locate `.git`. The new worktree itself is
        // created at worktreePath (which lives under workspaceParent) by the
        // command sent to the terminal.
        const terminal = vscode.window.createTerminal({
            name: `Claude: ${branchName}`,
            cwd: workspaceRoot,
            shellPath: runtime.executable,
            shellArgs: ["-NoLogo"],
        });
        terminal.show();
        // Send the pre-claude commands as separate sendText calls so each is
        // processed at its own PowerShell prompt: ensure the <repoName>-wt
        // grouping directory exists, then git worktree add, then Set-Location
        // into the new worktree, then (when the workspace uses poetry) install
        // dependencies and activate the resulting venv. PowerShell's stdin is
        // line-buffered, so queued lines are read one at a time once each prior
        // command finishes.
        terminal.sendText(commands.ensureParentDirectory, true);
        terminal.sendText(commands.git, true);
        terminal.sendText(commands.setLocation, true);
        if (commands.poetryInstall !== undefined) {
            terminal.sendText(commands.poetryInstall, true);
        }
        if (commands.activate !== undefined) {
            terminal.sendText(commands.activate, true);
        }
        // Run the configured pre-`claude` script (guarded by a runtime
        // Test-Path) after the poetry activation step and before the deferred
        // claude send, so repo-local setup runs immediately before claude.
        if (commands.preClaude !== undefined) {
            terminal.sendText(commands.preClaude, true);
        }
        // Defer the final claude command. VS Code's Python extension auto-
        // injects its own venv activation via a deferred terminal.sendText.
        // If we start claude before that injection arrives, claude takes over
        // stdin and the injected text is buffered into claude's TUI prompt.
        // The grace window lets any such injection land at the host shell's
        // prompt and be consumed normally before claude takes over.
        setTimeout(() => {
            terminal.sendText(commands.claude, true);
        }, TERMINAL_AUTO_ACTIVATION_GRACE_MS);
        // Log only the objective length so the channel record is useful for
        // diagnostics without recording potentially sensitive prompt text.
        const objectiveLength = objective.trim().length;
        const poetryNote = usePoetry
            ? "with poetry install and activation"
            : "no poetry";
        const preClaudeNote = commands.preClaude !== undefined
            ? "pre-claude script: emitted"
            : "pre-claude script: none";
        output.appendLine(`[${commandId}] opened terminal for branch ${branchName} at ${worktreePath} (objective length: ${objectiveLength}, ${poetryNote}, ${preClaudeNote}); claude send deferred by ${TERMINAL_AUTO_ACTIVATION_GRACE_MS}ms`);
    });
    const newCodexWorktreeSessionDisposable = vscode.commands.registerCommand("drmCopilotExtension.newCodexWorktreeSession", async () => {
        const commandId = "drmCopilotExtension.newCodexWorktreeSession";
        const objective = await vscode.window.showInputBox({
            title: "drm-copilot: New Codex Worktree Session",
            prompt: "Enter the objective to pass to codex as a prompt. Leave blank to skip.",
            ignoreFocusOut: true,
        });
        if (objective === undefined) {
            return;
        }
        const runtime = (0, command_runtime_1.detectRuntime)("powershell");
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const repoName = path.basename(workspaceRoot);
        const workspaceParent = path.dirname(workspaceRoot);
        const timestamp = (0, claude_worktree_session_1.formatWorktreeTimestamp)(new Date());
        const worktreePath = (0, claude_worktree_session_1.buildWorktreePath)(workspaceParent, timestamp, repoName);
        const branchName = (0, claude_worktree_session_1.buildBranchName)(timestamp, repoName);
        const usePoetry = pyprojectHasPoetry(workspaceRoot);
        const codexConfiguration = vscode.workspace.getConfiguration("drmCopilotExtension.newCodexWorktreeSession");
        const configuredPostCodexScriptPath = codexConfiguration.get("postCodexScriptPath") ??
            ".codex/scripts/post-codex-worktree-session.ps1";
        const configuredCodexExecutablePath = codexConfiguration.get("codexExecutablePath") ?? "";
        const codexExecutablePath = (0, command_runtime_1.resolveCodexExecutable)(configuredCodexExecutablePath, getInstalledCodexExtensionCandidateRoots());
        const commands = (0, codex_worktree_session_1.buildCodexWorktreeSessionCommands)({
            repoRoot: workspaceRoot,
            worktreePath,
            branchName,
            usePoetry,
            objective,
            codexExecutablePath,
            postCodexScriptPath: resolveSourceRootPath(workspaceRoot, configuredPostCodexScriptPath),
        });
        const terminal = vscode.window.createTerminal({
            name: `Codex: ${branchName}`,
            cwd: workspaceRoot,
            shellPath: runtime.executable,
            shellArgs: ["-NoLogo"],
        });
        terminal.show();
        terminal.sendText(commands.ensureParentDirectory, true);
        terminal.sendText(commands.git, true);
        terminal.sendText(commands.setLocation, true);
        terminal.sendText(commands.trustCodexProject, true);
        if (commands.poetryInstall !== undefined) {
            terminal.sendText(commands.poetryInstall, true);
        }
        if (commands.activate !== undefined) {
            terminal.sendText(commands.activate, true);
        }
        if (commands.postCodex !== undefined) {
            terminal.sendText(commands.postCodex, true);
        }
        setTimeout(() => {
            terminal.sendText(commands.codex, true);
        }, TERMINAL_AUTO_ACTIVATION_GRACE_MS);
        const objectiveLength = objective.trim().length;
        const poetryNote = usePoetry
            ? "with poetry install and activation"
            : "no poetry";
        const postCodexNote = commands.postCodex !== undefined
            ? "post-codex script: emitted"
            : "post-codex script: none";
        output.appendLine(`[${commandId}] opened terminal for branch ${branchName} at ${worktreePath} (objective length: ${objectiveLength}, ${poetryNote}, trust command: emitted, ${postCodexNote}); codex send deferred by ${TERMINAL_AUTO_ACTIVATION_GRACE_MS}ms`);
    });
    const removeSecondaryWorktreesDisposable = vscode.commands.registerCommand("drmCopilotExtension.removeSecondaryWorktrees", async () => {
        const commandId = "drmCopilotExtension.removeSecondaryWorktrees";
        try {
            const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
            const confirmation = await vscode.window.showWarningMessage("Remove all secondary git worktrees? This action removes each secondary worktree directory.", { modal: true }, "Remove All");
            if (confirmation !== "Remove All") {
                return;
            }
            const summary = await (0, remove_worktrees_runner_1.removeAllSecondaryWorktrees)(workspaceRoot, (0, remove_worktrees_runner_1.createGitRunner)(), output, (0, remove_worktrees_runner_1.createParentDirectoryFileSystem)());
            const message = (0, remove_worktrees_1.buildRemovalSummaryMessage)(summary);
            output.appendLine(`[${commandId}] ${message}`);
            if (summary.skipped.length > 0) {
                await vscode.window.showWarningMessage(message);
            }
            else {
                await vscode.window.showInformationMessage(message);
            }
        }
        catch (error) {
            const detail = error instanceof Error ? error.message : "Unknown error.";
            output.appendLine(`[${commandId}] failed: ${detail}`);
            await vscode.window.showErrorMessage(`Remove Secondary Worktrees failed: ${detail}`);
        }
    });
    const runPoshQCSuiteDisposable = vscode.commands.registerCommand("drmCopilotExtension.runPoshQCSuite", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.runPoshQCSuite";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(output, commandId, () => (0, workflow_command_arguments_1.resolveRunPoshQCSuiteInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await service.runPoshQCSuite({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        const scopeChoice = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Run PoshQC Suite", "Choose the scan scope.", ["Scan entire workspace", "Select folders to scan"]);
        if (!scopeChoice) {
            return;
        }
        if (scopeChoice === "Select folders to scan") {
            const selectedFolders = await (0, extension_command_helpers_1.promptForWorkspaceScanFolders)(workspaceRoot);
            if (!selectedFolders) {
                return;
            }
            await service.runPoshQCSuite({
                workspaceRoot,
                invocationId: commandId,
                scanFolders: selectedFolders,
            });
            return;
        }
        await service.runPoshQCSuite({
            workspaceRoot,
            invocationId: commandId,
        });
    });
    const [runPoshQCFormatDisposable, runPoshQCAnalyzeDisposable, runPoshQCTestDisposable, runPoshQCAnalyzeAutofixDisposable,] = (0, poshqc_command_registration_1.registerPoshQcCommands)({
        output,
        service,
        createService: (commandOutput) => (0, repo_automation_service_1.createRepoAutomationService)({
            extensionRoot: context.extensionUri.fsPath,
            output: commandOutput,
        }),
    });
    const [resolvePolicyAuditTemplateAssetDisposable, resolveExecuteHardLockPromptDisposable, resolveAtomicPlanPromptDisposable,] = (0, document_workflow_commands_1.registerDocumentWorkflowCommands)({
        output,
        service,
    });
    const mcpDisposables = (0, mcp_provider_1.registerMcpProvider)(context);
    const discoveryDisposables = (0, discovery_command_registration_1.registerDiscoveryCommands)({
        context,
        output,
        service,
    });
    const showSubagentTreeDisposable = (0, subagent_tree_command_1.registerSubagentTreeCommand)({ output });
    context.subscriptions.push(helloPythonDisposable, helloPowerShellDisposable, newClaudeWorktreeSessionDisposable, newCodexWorktreeSessionDisposable, removeSecondaryWorktreesDisposable, runPoshQCSuiteDisposable, runPoshQCFormatDisposable, runPoshQCAnalyzeDisposable, runPoshQCTestDisposable, runPoshQCAnalyzeAutofixDisposable, resolvePolicyAuditTemplateAssetDisposable, resolveExecuteHardLockPromptDisposable, resolveAtomicPlanPromptDisposable, showSubagentTreeDisposable, ...repoAutomationDisposables, ...mcpDisposables, ...discoveryDisposables, output);
}
/**
 * Deactivates the extension.
 *
 * @returns Nothing.
 */
function deactivate() {
    // No-op.
}
