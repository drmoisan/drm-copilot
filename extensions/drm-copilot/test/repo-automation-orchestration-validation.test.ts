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
const RUNTIME_BLOCKER_FINGERPRINT = `sha256:${"a".repeat(64)}`;

/** Return a public checkpoint with a runtime-incompatibility loop outcome. */
function externalRuntimeState(
  status: string,
  includeAttempt = false,
): Record<string, unknown> {
  const attempts = includeAttempt
    ? [
        {
          attempt_id: 1,
          source_review_fingerprint: RUNTIME_BLOCKER_FINGERPRINT,
          plan_path: "NONE",
          preflight: { final_status: "pending" },
          execution_status: "blocked",
          candidate_applied: false,
          terminal_disposition: "external_runtime",
          started_at: "2026-08-17T12:00:00Z",
          finished_at: "2026-08-17T12:00:01Z",
          exception_binding: null,
        },
      ]
    : [];
  return {
    objective: "obj",
    change_budget_estimate: "large",
    path_selected: "large",
    "promotion-type": "feature",
    "short-name": "short",
    relativeFile: "docs/features/potential/x.md",
    "long-name": "feature-1",
    "issue-num": "1",
    "feature-folder": "docs/features/active/feature-1",
    "work-mode": "full-feature",
    "plan-path": "docs/features/active/feature-1/plan.md",
    completed_steps: [],
    next_step: "blocked_external_runtime",
    last_updated: "2026-08-17T12:00:01Z",
    step5_status: "not-applicable",
    step6_status: "not-applicable",
    step7_status: "verified",
    step8_status: "not-applicable",
    step9_status: "verified",
    step10_status: "not-applicable",
    delegation_receipts: [],
    blocked_reason: "validator_failed",
    remediation_loop: {
      schema_version: 2,
      status,
      max_completed_cycles: 3,
      attempt_count: attempts.length,
      completed_cycle_count: 0,
      last_blocker_fingerprint: RUNTIME_BLOCKER_FINGERPRINT,
      attempts,
      cycles: [],
    },
  };
}

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

  it("accepts the pre-remediation external-runtime transition without count mutation", async () => {
    const state = externalRuntimeState("blocked_external_runtime");
    const loop = state["remediation_loop"] as Record<string, unknown>;
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/state.json": JSON.stringify(state),
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    const result = await service.validateOrchestrationArtifacts({
      workspaceRoot: "C:/workspace",
      invocationId: "validate_orchestration_artifacts",
      artifactType: "orchestrator-state",
      artifactPath: "docs/state.json",
    });

    expect(result.summary).toBe(
      "Validated orchestrator-state artifact at 'docs/state.json'.",
    );
    expect(loop).toMatchObject({
      attempt_count: 0,
      completed_cycle_count: 0,
      attempts: [],
      cycles: [],
    });
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("rejects an active status after an external-runtime attempt disposition", async () => {
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/state.json": JSON.stringify(
        externalRuntimeState("active", true),
      ),
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
        artifactType: "orchestrator-state",
        artifactPath: "docs/state.json",
      }),
    ).rejects.toThrow(
      "ORCH_REMEDIATION_TRANSITION: remediation_loop.status active does not match the latest remediation outcome.",
    );
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
