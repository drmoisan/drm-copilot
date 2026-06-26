import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import type { FileSystem } from "../src/lib/file-system";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { createRepoAutomationService } from "../src/repo-automation-service";

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

const VALID_PLAN = [
  "# Plan",
  "### Phase 0 — Setup",
  "- [ ] [P0-T1] First task",
].join("\n");

/**
 * In-memory FileSystem fake mapping artifact paths to text. The
 * `validateOrchestrationArtifacts` method is the only consumer, so glob/isFile
 * default to empty/false; orchestrator-state routing uses an explicit matrix in
 * its own unit tests rather than this fake.
 */
class VirtualFileSystem implements FileSystem {
  private readonly contents: Map<string, string>;

  constructor(files: Record<string, string>) {
    this.contents = new Map(Object.entries(files));
  }

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.contents.has(path);
  }

  readTextFile(path: string): string {
    const content = this.contents.get(path);
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(): void {
    throw new Error("not used");
  }

  ensureDir(): void {
    throw new Error("not used");
  }
}

describe("repo automation orchestration validation", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("validateOrchestrationArtifacts validates in-process and preserves the summary", async () => {
    // Arrange: inject a filesystem returning a valid plan at the resolved path.
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/plan.md": VALID_PLAN,
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    // Act
    const result = await service.validateOrchestrationArtifacts({
      workspaceRoot: "C:/workspace",
      invocationId: "validate_orchestration_artifacts",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
      requireComplete: false,
    });

    // Assert: no Python subprocess; result preserves tool + summary contract.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(result.tool).toBe("validate_orchestration_artifacts");
    expect(result.summary).toBe("Validated plan artifact at 'docs/plan.md'.");
  });

  it("validateOrchestrationArtifacts routes require-complete to the orchestrator-state path", async () => {
    // Arrange: a non-object orchestrator-state document under requireComplete.
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/state.json": "[]",
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    // Act / Assert: the orchestrator-state validator reports the root error and
    // the method throws, surfacing the failure to the MCP handler.
    await expect(
      service.validateOrchestrationArtifacts({
        workspaceRoot: "C:/workspace",
        invocationId: "validate_orchestration_artifacts",
        artifactType: "orchestrator-state",
        artifactPath: "docs/state.json",
        requireComplete: true,
      }),
    ).rejects.toThrow("Checkpoint root must be a JSON object.");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("validateOrchestrationArtifacts throws when validation errors are present", async () => {
    // Arrange: a policy-audit document missing required headings.
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/policy-audit.md": "incomplete document",
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    // Act / Assert
    await expect(
      service.validateOrchestrationArtifacts({
        workspaceRoot: "C:/workspace",
        invocationId: "validate_orchestration_artifacts",
        artifactType: "policy-audit",
        artifactPath: "docs/policy-audit.md",
        requireComplete: true,
      }),
    ).rejects.toThrow(
      "Validation failed for policy-audit artifact at 'docs/policy-audit.md':",
    );
  });
});
