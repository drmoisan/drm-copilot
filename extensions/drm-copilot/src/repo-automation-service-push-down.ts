import { type PushDownClaudeCustomizationsInput } from "./repo-automation-service";
import { type ScriptExecutionOptions } from "./repo-automation-service-support";
import { type RepoAutomationToolName } from "./repo-automation-tool-names";

export function buildPushDownClaudeCustomizationsOptions(
  input: PushDownClaudeCustomizationsInput,
): ScriptExecutionOptions & { tool: RepoAutomationToolName } {
  // Start from the backward-compatible destination-only arg vector and append
  // optional pack, variant, and memory-mode flags only when supplied so a
  // no-field input spawns exactly ["--destination", workspaceRoot].
  const args: string[] = ["--destination", input.workspaceRoot];
  if (input.packs !== undefined && input.packs.length > 0) {
    args.push("--packs", input.packs.join(","));
  }
  if (input.csharpVariant !== undefined) {
    args.push("--csharp-variant", input.csharpVariant);
  }
  if (input.memoryMode !== undefined) {
    args.push("--memory-mode", input.memoryMode);
  }
  return {
    tool: "push_down_claude_customizations",
    runtimeKind: "python",
    bundledRelativePath:
      "resources/templates/push_down_claude_customizations.py",
    workspaceRoot: input.workspaceRoot,
    invocationId: input.invocationId ?? "push_down_claude_customizations",
    args,
    summary:
      "Pushed bundled Claude Code customizations into the destination workspace.",
    stdoutArtifactPattern: /Wrote push-down summary artifact to:\s*(.+)/i,
  };
}
