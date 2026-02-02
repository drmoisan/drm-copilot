import * as assert from "assert";
import * as vscode from "vscode";

suite("Extension Test Suite", () => {
  vscode.window.showInformationMessage("Start all tests.");

  test("Extension activates and registers all commands", async () => {
    // Ensure extension is activated
    const ext = vscode.extensions.getExtension("drm-copilot.drm-copilot");
    assert.ok(ext, "Extension should be installed");
    await ext.activate();

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
