import { describe, expect, it } from "@jest/globals";

import {
  buildCodexTrustCommand,
  buildCodexWorktreeSessionCommands,
} from "../src/codex-worktree-session";

describe("buildCodexTrustCommand", () => {
  it("emits a command that writes a trusted Codex project entry", () => {
    const command = buildCodexTrustCommand("C:/repos/workspace-wt");

    expect(command).toContain(
      "$codexConfig = Join-Path $HOME '.codex/config.toml'",
    );
    expect(command).toContain("$header = \"[projects.'$escapedPath']\"");
    expect(command).toContain("$trustedLine = 'trust_level = \"trusted\"'");
    expect(command).toContain("(?<body>.*?)");
    expect(command).toContain(
      "Codex project trust entry exists but is not trusted",
    );
  });

  it("quotes paths with spaces and apostrophes", () => {
    const command = buildCodexTrustCommand("C:/repos/o'connor worktree");

    expect(command).toContain(
      "Test-Path -LiteralPath 'C:/repos/o''connor worktree'",
    );
    expect(command).toContain(
      "Resolve-Path -LiteralPath 'C:/repos/o''connor worktree'",
    );
  });

  it("emits the elseif branch as part of the same PowerShell statement", () => {
    const command = buildCodexTrustCommand("C:/repos/workspace-wt");

    expect(command).not.toContain("; elseif");
    expect(command).not.toMatch(/[;\r\n]\s*elseif\s*\(/);
    expect(command).toContain("} elseif (");
  });
});

describe("buildCodexWorktreeSessionCommands", () => {
  const baseInput = {
    repoRoot: "C:/workspace",
    worktreePath: "C:/workspace-wt-2026-04-20-09-59",
    branchName: "workspace-wt-2026-04-20-09-59",
    usePoetry: false,
    objective: undefined,
    codexExecutablePath: "C:/bin/codex.exe",
    postCodexScriptPath: undefined,
  };

  it("emits git, Set-Location, trust, and codex commands", () => {
    const commands = buildCodexWorktreeSessionCommands(baseInput);

    expect(commands.git).toBe(
      "git -C 'C:/workspace' worktree add 'C:/workspace-wt-2026-04-20-09-59' -b 'workspace-wt-2026-04-20-09-59'",
    );
    expect(commands.setLocation).toBe(
      "Set-Location 'C:/workspace-wt-2026-04-20-09-59'",
    );
    expect(commands.trustCodexProject).toContain(
      "$codexConfig = Join-Path $HOME '.codex/config.toml'",
    );
    expect(commands.codex).toBe("& 'C:/bin/codex.exe'");
  });

  it("emits codex with a quoted objective when supplied", () => {
    const commands = buildCodexWorktreeSessionCommands({
      ...baseInput,
      objective: "Implement the Codex command.",
    });

    expect(commands.codex).toBe(
      "& 'C:/bin/codex.exe' 'Implement the Codex command.'",
    );
  });

  it("emits codex through the resolved executable path", () => {
    const input = {
      ...baseInput,
      codexExecutablePath: "C:/Tools/Codex/codex.exe",
    };

    const commands = buildCodexWorktreeSessionCommands(input);

    expect(commands.codex).toBe("& 'C:/Tools/Codex/codex.exe'");
  });

  it("preserves the objective argument when using a resolved codex executable", () => {
    const input = {
      ...baseInput,
      codexExecutablePath: "C:/Tools/Codex/codex.exe",
      objective: "Implement issue 268",
    };

    const commands = buildCodexWorktreeSessionCommands(input);

    expect(commands.codex).toBe(
      "& 'C:/Tools/Codex/codex.exe' 'Implement issue 268'",
    );
  });

  it("returns poetry commands when the workspace uses poetry", () => {
    const commands = buildCodexWorktreeSessionCommands({
      ...baseInput,
      usePoetry: true,
    });

    expect(commands.poetryInstall).toBe("poetry install --with dev");
    expect(commands.activate).toBe("& './.venv/Scripts/Activate.ps1'");
  });

  it("emits a guarded post-codex script command when configured", () => {
    const commands = buildCodexWorktreeSessionCommands({
      ...baseInput,
      postCodexScriptPath: "scripts/post-codex.ps1",
    });

    expect(commands.postCodex).toBe(
      "if (Test-Path -LiteralPath 'scripts/post-codex.ps1') { & 'scripts/post-codex.ps1' -SourceRoot 'C:/workspace' -WorktreeRoot 'C:/workspace-wt-2026-04-20-09-59' }",
    );
  });

  it("omits the post-codex script command when the path is blank", () => {
    const commands = buildCodexWorktreeSessionCommands({
      ...baseInput,
      postCodexScriptPath: "   ",
    });

    expect(commands.postCodex).toBeUndefined();
  });
});
