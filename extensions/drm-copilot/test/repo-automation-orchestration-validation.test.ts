import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import type { FileSystem } from "../src/lib/file-system";
import type { CommandRunner } from "../src/lib/subprocess-runner";
import { validateParallelOrchestratorStateText } from "../src/lib/validate/parallel-orchestrator-state-core";
import { kickoffWithIntegrity } from "./lib/validate/parallel-kickoff-fixtures";
import { buildValidParallelState } from "./lib/validate/parallel-state-test-support";

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

/** Return a public-path fixture carrying mutation and unresolved-drift defects. */
function semanticFalseAcceptText(): string {
  const state = buildValidParallelState();
  state["recolor_generation"] = 2;
  state["cohorts"] = [{ index: 0, generation: 2, item_keys: [444, 445] }];
  state["mutations"] = [
    {
      op: "requeue",
      item_key: 444,
      at: "2026-08-10T21-00",
      prior_state: "in_flight",
      new_state: "blocked",
      disposition: null,
      recolor_generation: 2,
    },
  ];
  state["drift_events"] = [
    {
      item_key: 444,
      declared: ["scripts/dev_tools/**"],
      observed: ["scripts/dev_tools/a.py", "outside/unowned.txt"],
      escaped_paths: ["outside/unowned.txt"],
      at: "2026-08-10T21-00",
      action: "raised_blocking_finding",
    },
  ];
  return JSON.stringify(state);
}

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

  it("surfaces ordered parallel mutation and drift findings in-process", async () => {
    const text = semanticFalseAcceptText();
    const directErrors = validateParallelOrchestratorStateText(text);
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/artifacts/orchestration/parallel-state.json": text,
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    await expect(
      service.validateOrchestrationArtifacts({
        workspaceRoot: "C:/workspace",
        invocationId: "validate_orchestration_artifacts",
        artifactType: "parallel-orchestrator-state",
        artifactPath: "artifacts/orchestration/parallel-state.json",
      }),
    ).rejects.toThrow(
      `Validation failed for parallel-orchestrator-state artifact at ` +
        `'artifacts/orchestration/parallel-state.json':\n${directErrors.join("\n")}`,
    );
    expect(directErrors).toEqual(
      expect.arrayContaining([
        expect.stringContaining("expected recompute generation 1"),
        expect.stringContaining("unresolved drift"),
      ]),
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("validates committed parallel kickoff readiness through the service", async () => {
    const kickoffPath = "docs/features/parallel/sample-run/parallel-kickoff.md";
    const fileSystem = new VirtualFileSystem({
      [`C:/workspace/${kickoffPath}`]: kickoffWithIntegrity(),
    });
    const runner: CommandRunner = {
      run: jest.fn((args) => ({
        stdout: args.join(" ").includes("^{commit}")
          ? "e".repeat(40)
          : "same-blob",
        stderr: "",
        code: 0,
      })),
    };
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
      runner,
    });

    const result = await service.validateOrchestrationArtifacts({
      workspaceRoot: "C:/workspace",
      invocationId: "validate_orchestration_artifacts",
      artifactType: "parallel-kickoff",
      artifactPath: kickoffPath,
      requireReadyForExecution: true,
    });

    expect(result.summary).toContain("parallel-kickoff");
    expect(runner.run).toHaveBeenCalledWith(
      expect.arrayContaining(["git", "rev-parse", "--verify"]),
      expect.objectContaining({ cwd: "C:/workspace", allowError: true }),
    );
  });

  it("rejects mismatched committed parallel kickoff evidence", async () => {
    const kickoffPath = "docs/features/parallel/sample-run/parallel-kickoff.md";
    const fileSystem = new VirtualFileSystem({
      [`C:/workspace/${kickoffPath}`]: kickoffWithIntegrity(),
    });
    const runner: CommandRunner = {
      run: jest.fn((args) => ({
        stdout: args.join(" ").includes("hash-object")
          ? "worktree-blob"
          : args.join(" ").includes("^{commit}")
            ? "f".repeat(40)
            : "committed-blob",
        stderr: "",
        code: 0,
      })),
    };
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
      runner,
    });

    await expect(
      service.validateOrchestrationArtifacts({
        workspaceRoot: "C:/workspace",
        invocationId: "validate_orchestration_artifacts",
        artifactType: "parallel-kickoff",
        artifactPath: kickoffPath,
        requireReadyForExecution: true,
      }),
    ).rejects.toThrow(
      "Parallel committed kickoff planning_commit must match origin/parallel/sample-run-plan.",
    );
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
