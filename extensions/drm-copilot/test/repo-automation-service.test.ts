import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import type { DiscoveryProcessLauncher } from "../src/discovery-runtime";
import { DOCS_ENTRY_SCRIPT_RELATIVE_PATH } from "../src/repo-automation-execute-docs";
import { createRepoAutomationService } from "../src/repo-automation-service";
import { InMemoryFileSystem } from "./lib/subagent-tree/in-memory-file-system";
import { VIRTUAL_WORKSPACE_ROOT } from "./mcp-server-test-service";

const appendLineMock = jest.fn<(line: string) => void>();

describe("repo automation service", () => {
  it("creates a service instance with the configured extension root", () => {
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    expect(service).toBeDefined();
  });

  it("runDocsCommand uses the injected docs dependencies and fileSystem", async () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    fileSystem.addFile(
      `${VIRTUAL_WORKSPACE_ROOT}/${DOCS_ENTRY_SCRIPT_RELATIVE_PATH}`,
      "# entry script",
    );
    const launches: Array<{
      readonly executable: string;
      readonly args: ReadonlyArray<string>;
      readonly cwd: string;
    }> = [];
    const launcher: DiscoveryProcessLauncher = {
      launch: (executable, args, options) => {
        launches.push({ executable, args, cwd: options.cwd });
        return Promise.resolve({
          exitCode: 0,
          stdout:
            '{"command":"check","exit_code":0,"findings":[],"ok":true,"result":null}\n',
          stderr: "",
        });
      },
    };
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
      docs: { launcher, resolvePwsh: () => "/opt/powershell/pwsh" },
    });

    // Act
    const outcome = await service.runDocsCommand?.({
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
      subcommand: "check",
      options: [],
    });

    // Assert
    expect(launches).toEqual([
      {
        executable: "/opt/powershell/pwsh",
        args: [
          "-NoProfile",
          "-File",
          DOCS_ENTRY_SCRIPT_RELATIVE_PATH,
          "-Command",
          "check",
          "-Json",
        ],
        cwd: VIRTUAL_WORKSPACE_ROOT,
      },
    ]);
    expect(outcome?.envelope.ok).toBe(true);
    expect(outcome?.stderr).toBe("");
  });
});
