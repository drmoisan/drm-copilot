import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import * as path from "node:path";

import type { FileSystem } from "../src/lib/file-system";
import type {
  TransitionPreparedOrchestrationRequest,
  TransitionPreparedOrchestrationResult,
} from "../src/mcp-repo-automation-tool-definitions-handoff";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  ...jest.requireActual<typeof import("node:fs")>("node:fs"),
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import { createRepoAutomationService } from "../src/repo-automation-service";

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

const VALID_PLAN = [
  "# Plan",
  "### Phase 0 — Setup",
  "- [ ] [P0-T1] First task",
].join("\n");

const PORTABLE_HANDOFF_FIXTURE = readFileSync(
  path.resolve(
    __dirname,
    "../../../tests/fixtures/orchestration-handoff/contract/valid-ordinary-claude-to-codex.json",
  ),
  "utf8",
);

function sha256(value: string): string {
  return createHash("sha256").update(value, "utf8").digest("hex");
}

function createPortableHandoffFiles(): {
  readonly envelopePath: string;
  readonly envelopeSha256: string;
  readonly envelopeText: string;
  readonly files: Readonly<Record<string, string>>;
  readonly planPath: string;
} {
  const payload = JSON.parse(PORTABLE_HANDOFF_FIXTURE) as {
    binding: { workspace_root: string };
    plan: { path: string; sha256: string };
  };
  const workspaceRoot = "C:/workspace";
  const envelopePath = "artifacts/orchestration/handoff.json";
  payload.binding.workspace_root = workspaceRoot;
  payload.plan.sha256 = sha256(VALID_PLAN);
  const envelopeText = JSON.stringify(payload);
  return {
    envelopePath,
    envelopeSha256: sha256(envelopeText),
    envelopeText,
    files: {
      [`${workspaceRoot}/${envelopePath}`]: envelopeText,
      [`${workspaceRoot}/${payload.plan.path}`]: VALID_PLAN,
    },
    planPath: payload.plan.path,
  };
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

  it("validates portable handoff artifacts without starting a Python process", async () => {
    // Arrange: the shared contract fixture is rebound to this explicit
    // workspace and its pinned plan digest is calculated from the plan bytes.
    const fixture = createPortableHandoffFiles();
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem: new VirtualFileSystem({ ...fixture.files }),
    });

    // Act
    const result = await service.validateOrchestrationArtifacts({
      workspaceRoot: "C:/workspace",
      invocationId: "validate_orchestration_artifacts",
      artifactType: "portable-orchestration-handoff",
      artifactPath: fixture.envelopePath,
      requireComplete: true,
    });

    // Assert
    expect(result.summary).toBe(
      `Validated portable-orchestration-handoff artifact at '${fixture.envelopePath}'.`,
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("resolves portable topology and routing through typed read-only dispatch", async () => {
    // Arrange
    const fixture = createPortableHandoffFiles();
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem: new VirtualFileSystem({ ...fixture.files }),
    });
    const request = {
      workspaceRoot: "C:/workspace",
      handoffEnvelopePath: fixture.envelopePath,
      expectedHandoffEnvelopeSha256: fixture.envelopeSha256,
      destinationProvider: "codex",
    } as const;

    // Act: exercise both the service contract and public MCP dispatch.
    const topology = await service.resolveOrchestrationTopology?.(request);
    const routing = await service.resolveProviderRouting?.(request);
    const dispatch = await dispatchRepoAutomationTool(
      "resolve_orchestration_topology",
      {
        workspace_root: request.workspaceRoot,
        handoff_envelope_path: request.handoffEnvelopePath,
        expected_handoff_envelope_sha256: request.expectedHandoffEnvelopeSha256,
        destination_provider: request.destinationProvider,
      },
      service,
    );

    // Assert: resolutions identify destination policy and expose no historical
    // provider receipt content.
    expect(topology).toMatchObject({
      status: "validated",
      primaryFailureCode: null,
      resolution: {
        kind: "destination_topology",
        provider: "codex",
        topology_policy: "codex_topology_policy",
      },
    });
    expect(routing).toMatchObject({
      status: "validated",
      primaryFailureCode: null,
      resolution: {
        kind: "provider_routing",
        provider: "codex",
        routing_policy: "codex_model_policy",
        source_evidence_mode: "opaque",
      },
    });
    expect(dispatch).toMatchObject({
      ok: true,
      tool: "resolve_orchestration_topology",
      status: "validated",
      handoff_id: "handoff-614-claude-to-codex-ordinary",
      primary_failure_code: null,
      resolution: {
        kind: "destination_topology",
        provider: "codex",
      },
    });
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it.each(["validated", "materialized", "blocked"] as const)(
    "dispatches a deterministic %s prepared-orchestration result",
    async (status) => {
      // Arrange
      const fixture = createPortableHandoffFiles();
      const sourceSha256 = "a".repeat(64);
      const destinationSha256 = "b".repeat(64);
      const transition =
        jest.fn<
          (
            input: TransitionPreparedOrchestrationRequest,
          ) => Promise<TransitionPreparedOrchestrationResult>
        >();
      const service = createRepoAutomationService({
        extensionRoot: "C:/extension",
        output: { appendLine: appendLineMock },
        fileSystem: new VirtualFileSystem({ ...fixture.files }),
        handoffMaterializer: { transition },
      });
      const request = {
        workspaceRoot: "C:/workspace",
        sourceCheckpointPath: "artifacts/orchestration/orchestrator-state.json",
        expectedSourceCheckpointSha256: sourceSha256,
        handoffEnvelopePath: fixture.envelopePath,
        expectedHandoffEnvelopeSha256: fixture.envelopeSha256,
        destinationProvider: "codex",
        mode: status === "materialized" ? "materialize" : "dry_run",
      } as const;
      const blocked = status === "blocked";
      transition.mockResolvedValue({
        status,
        handoffId: "handoff-614-claude-to-codex-ordinary",
        sourceCheckpointSha256: sourceSha256,
        handoffEnvelopeSha256: fixture.envelopeSha256,
        handoffHistorySha256: "c".repeat(64),
        requestedTransition: "prepared_to_atomic_execution",
        destinationCheckpointPath: blocked
          ? null
          : request.sourceCheckpointPath,
        destinationCheckpointSha256: blocked ? null : destinationSha256,
        primaryFailureCode: blocked ? "HANDOFF_DIRTY_WORKTREE" : null,
        affectedPaths: blocked ? ["src/dirty.ts"] : [],
        unsupportedCapabilities: [],
      });

      // Act
      const result = await dispatchRepoAutomationTool(
        "transition_prepared_orchestration",
        {
          workspace_root: request.workspaceRoot,
          source_checkpoint_path: request.sourceCheckpointPath,
          expected_source_checkpoint_sha256: sourceSha256,
          handoff_envelope_path: fixture.envelopePath,
          expected_handoff_envelope_sha256: fixture.envelopeSha256,
          destination_provider: "codex",
          mode: request.mode,
        },
        service,
      );

      // Assert
      expect(transition).toHaveBeenCalledWith(request);
      expect(result).toMatchObject({
        ok: true,
        status,
        destination_checkpoint_sha256: blocked ? null : destinationSha256,
        primary_failure_code: blocked ? "HANDOFF_DIRTY_WORKTREE" : null,
      });
      expect(childProcessMock.spawn).not.toHaveBeenCalled();
    },
  );
});
