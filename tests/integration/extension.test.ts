import * as assert from "assert";
import * as vscode from "vscode";

/**
 * Integration tests for the drm-copilot extension.
 *
 * NOTE: These tests require a GUI environment and cannot run in headless containers.
 * Run `npm run test:unit` for tests that work in dev containers.
 * Run `npm test` or `npm run test:integration` only on desktop environments.
 */
suite("Extension Test Suite", () => {
  vscode.window.showInformationMessage("Start all tests.");

  test("Extension activates and registers all commands", async () => {
    // Ensure extension is activated
    const ext = vscode.extensions.getExtension("drm-copilot.drm-copilot");
    assert.ok(ext, "Extension should be installed");

    // Activate and wait for it to complete
    if (!ext.isActive) {
      await ext.activate();
    }

    // Get all registered commands
    const allCommands = await vscode.commands.getCommands(true);

    // Verify key drm-copilot commands are registered
    const expectedCommands = [
      "drm-copilot.loadOpenAIKey",
      "drm-copilot.qcBlackFormat",
      "drm-copilot.qcRuffLint",
      "drm-copilot.qcPyrightTypeCheck",
      "drm-copilot.poshQCFormat",
      "drm-copilot.devPromotePotentialToIssue",
      "drm-copilot.tsPrettierFormat",
      "drm-copilot.tsEslintLint",
    ];

    for (const commandId of expectedCommands) {
      assert.ok(
        allCommands.includes(commandId),
        `Command ${commandId} should be registered`,
      );
    }
  });
});
