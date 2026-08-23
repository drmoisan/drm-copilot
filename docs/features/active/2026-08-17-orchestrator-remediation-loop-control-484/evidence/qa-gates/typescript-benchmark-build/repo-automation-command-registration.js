"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerRepoAutomationCommands = registerRepoAutomationCommands;
const repo_automation_command_registration_admin_1 = require("./repo-automation-command-registration-admin");
const repo_automation_command_registration_feature_workflows_1 = require("./repo-automation-command-registration-feature-workflows");
/**
 * Registers the interactive repo-automation workflow commands so `extension.ts`
 * can remain a thin activation coordinator.
 *
 * @param options Shared command-registration dependencies.
 * @returns The disposables that must be added to the extension subscriptions.
 */
function registerRepoAutomationCommands(options) {
    return [
        ...(0, repo_automation_command_registration_admin_1.registerRepoAutomationAdminCommands)(options),
        ...(0, repo_automation_command_registration_feature_workflows_1.registerRepoAutomationFeatureWorkflowCommands)(options),
    ];
}
