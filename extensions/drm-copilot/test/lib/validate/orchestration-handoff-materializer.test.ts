import { describe, expect, it, jest } from "@jest/globals";
import { createHash } from "node:crypto";

import type {
  HandoffEnvelope,
  HandoffFailureCode,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import type { TransitionPreparedOrchestrationRequest } from "../../../src/mcp-repo-automation-tool-definitions-handoff";
import {
  OrchestrationHandoffMaterializer,
  type HandoffMaterializerDependencies,
} from "../../../src/lib/validate/orchestration-handoff-materializer";

const encoder = new TextEncoder();

function sha256(content: Uint8Array): string {
  return createHash("sha256").update(content).digest("hex");
}

function createEnvelope(sourceSha256: string): HandoffEnvelope {
  return {
    schemaUri:
      "https://drm-copilot.dev/schemas/orchestration-handoff/2.0.0/schema.json",
    schemaVersion: "2.0.0",
    kind: "portable_orchestration_handoff",
    handoffId: "handoff-614",
    identity: {
      objectiveId: "github:drmoisan/drm-copilot#614",
      issueNumber: 614,
      featureFolder: "docs/features/active/portable-handoff-614",
      workMode: "full-feature",
    },
    binding: {
      repositoryId: "github.com/drmoisan/drm-copilot",
      workspaceRoot: "C:/workspace",
      branch: "feature/portable-handoff-614",
      sourceHeadSha: "0".repeat(40),
      allowedHeadRelationship: "equal_or_descendant",
    },
    source: {
      provider: "claude",
      checkpointPath: "artifacts/orchestration/orchestrator-state.json",
      checkpointSha256: sourceSha256,
      archivePath: `artifacts/orchestration/handoffs/sources/sha256/${sourceSha256}.json`,
      expressionSchemaId: "claude.orchestrator-state",
      expressionSchemaVersion: "legacy-v1",
      receiptReferences: [
        {
          path: "artifacts/orchestration/receipts/source.json",
          sha256: "1".repeat(64),
        },
      ],
    },
    destinationProvider: "codex",
    destinationCheckpointPath:
      "artifacts/orchestration/orchestrator-state.json",
    plan: {
      path: "docs/features/active/portable-handoff-614/plan.md",
      sha256: "2".repeat(64),
      contractVersion: "atomic-plan-v1",
    },
    lifecycle: {
      logicalComplexity: "C3",
      routeIntent: "prepared_to_ordinary_execution",
      completedPhases: ["promotion", "preflight"],
      nextTransition: "atomic_execution",
      replayPolicy: "forbid_completed_phases",
    },
    capabilities: {
      vocabularies: ["portable-orchestration-handoff-core-v1"],
      required: ["handoff-schema:2"],
    },
    schedulerContext: { kind: "ordinary" },
    handoffHistory: [
      {
        sequence: 1,
        fromProvider: "claude",
        toProvider: "codex",
        sourceCheckpointSha256: sourceSha256,
        envelopeSha256: "3".repeat(64),
        requestedAt: "2026-08-31T08:00:00Z",
        previousEntrySha256: null,
        entrySha256: "4".repeat(64),
        status: "requested",
        adapterId: "claude-to-codex-v1",
        adapterVersion: "1.0.0",
        targetCheckpointSha256: null,
        failureCode: null,
      },
    ],
  };
}

interface ScenarioOptions {
  readonly envelopeBytes?: Uint8Array;
  readonly gitFailure?: boolean;
  readonly porcelainStatus?: string;
  readonly projectionErrors?: readonly string[];
  readonly readFailure?: boolean;
  readonly replaceFailure?: boolean;
  readonly request?: Partial<TransitionPreparedOrchestrationRequest>;
  readonly routingFailure?: HandoffFailureCode;
  readonly sourceBytes?: Uint8Array;
  readonly topologyFailure?: HandoffFailureCode | null;
  readonly transformEnvelope?: (envelope: HandoffEnvelope) => HandoffEnvelope;
  readonly validationFailure?: HandoffFailureCode;
  readonly writeFailureAt?: "archive" | "candidate";
}

function createScenario(options: ScenarioOptions = {}) {
  const sourceBytes =
    options.sourceBytes ?? encoder.encode('{"provider":"claude"}\n');
  const envelopeBytes =
    options.envelopeBytes ?? encoder.encode('{"kind":"validated-envelope"}\n');
  const sourceSha256 = sha256(sourceBytes);
  const envelopeSha256 = sha256(envelopeBytes);
  const baseEnvelope = createEnvelope(sourceSha256);
  const envelope = options.transformEnvelope?.(baseEnvelope) ?? baseEnvelope;
  const sourcePath = `C:/workspace/${baseEnvelope.source.checkpointPath}`;
  const envelopePath =
    "C:/workspace/artifacts/orchestration/handoffs/handoff.json";
  const files = new Map<string, Uint8Array>([
    [sourcePath, sourceBytes],
    [envelopePath, envelopeBytes],
  ]);
  const authorityResult = (failure: HandoffFailureCode | null | undefined) => ({
    status:
      failure === undefined ? ("validated" as const) : ("blocked" as const),
    handoffId: envelope.handoffId,
    handoffEnvelopeSha256: envelopeSha256,
    primaryFailureCode: failure ?? null,
    affectedPaths: failure === undefined ? [] : ["affected/path"],
    unsupportedCapabilities:
      failure === "HANDOFF_CAPABILITY_UNAVAILABLE" ? ["missing"] : [],
    resolution: failure === undefined ? {} : null,
  });
  const readFile = jest.fn((filePath: string) => {
    if (options.readFailure === true) throw new Error("read failed");
    const content = files.get(filePath);
    if (content === undefined) throw new Error(`missing: ${filePath}`);
    return content;
  });
  const writeFile = jest.fn(
    (
      filePath: string,
      content: Uint8Array,
      writeOptions?: { readonly exclusive?: boolean },
    ) => {
      const isArchive = filePath.includes("/sources/sha256/");
      if (options.writeFailureAt === "archive" && isArchive)
        files.set(filePath, encoder.encode("mismatched archive"));
      if (
        (options.writeFailureAt === "archive" && isArchive) ||
        (options.writeFailureAt === "candidate" && !isArchive)
      ) {
        throw new Error(`write failed: ${filePath}`);
      }
      if (writeOptions?.exclusive === true && files.has(filePath)) {
        throw new Error(`exists: ${filePath}`);
      }
      files.set(filePath, Uint8Array.from(content));
    },
  );
  const replaceFile = jest.fn(
    (candidatePath: string, destinationPath: string) => {
      if (options.replaceFailure === true) throw new Error("replace failed");
      const content = files.get(candidatePath);
      if (content === undefined) throw new Error(`missing: ${candidatePath}`);
      files.set(destinationPath, content);
      files.delete(candidatePath);
    },
  );
  const dependencies: HandoffMaterializerDependencies = {
    fileSystem: {
      readFile,
      createDirectory: jest.fn(),
      writeFile,
      replaceFile,
      removeFile: jest.fn(),
    },
    git: {
      readPorcelainStatus: jest.fn(async () => {
        if (options.gitFailure === true) throw new Error("git failed");
        return options.porcelainStatus ?? "";
      }),
    },
    topology: {
      resolve: jest.fn(async () => authorityResult(options.topologyFailure)),
    },
    routing: {
      resolve: jest.fn(async () => authorityResult(options.routingFailure)),
    },
    validator: {
      validateEnvelope: jest.fn(() => ({
        envelope: options.validationFailure === undefined ? envelope : null,
        primaryFailureCode: options.validationFailure ?? null,
        affectedPaths:
          options.validationFailure === undefined ? [] : ["invalid/envelope"],
        unsupportedCapabilities:
          options.validationFailure === "HANDOFF_CAPABILITY_UNAVAILABLE"
            ? ["missing"]
            : [],
      })),
      validateDestinationProjection: jest.fn(
        () => options.projectionErrors ?? [],
      ),
    },
    clock: { nowIso8601: jest.fn(() => "2026-08-31T08:00:00Z") },
  };
  const request: TransitionPreparedOrchestrationRequest = {
    workspaceRoot: "C:/workspace",
    sourceCheckpointPath: baseEnvelope.source.checkpointPath,
    expectedSourceCheckpointSha256: sourceSha256,
    handoffEnvelopePath: "artifacts/orchestration/handoffs/handoff.json",
    expectedHandoffEnvelopeSha256: envelopeSha256,
    destinationProvider: "codex",
    mode: "dry_run",
    ...options.request,
  };
  return {
    dependencies,
    envelope,
    envelopeSha256,
    files,
    readFile,
    request,
    replaceFile,
    sourceBytes,
    sourcePath,
    sourceSha256,
    writeFile,
  };
}

describe("orchestration handoff materializer", () => {
  it("returns a deterministic dry-run projection without mutation", async () => {
    // Arrange
    const scenario = createScenario();
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const first = await materializer.transition(scenario.request);
    const second = await materializer.transition(scenario.request);

    // Assert
    expect(first).toEqual(second);
    expect(first).toMatchObject({
      status: "validated",
      handoffId: scenario.envelope.handoffId,
      sourceCheckpointSha256: scenario.sourceSha256,
      handoffEnvelopeSha256: scenario.envelopeSha256,
      handoffHistorySha256: "4".repeat(64),
      requestedTransition: "prepared_to_atomic_execution",
      destinationCheckpointPath: scenario.envelope.destinationCheckpointPath,
      primaryFailureCode: null,
    });
    expect(first.destinationCheckpointSha256).toMatch(/^[a-f0-9]{64}$/);
    expect(scenario.dependencies.topology.resolve).toHaveBeenCalledTimes(2);
    expect(scenario.dependencies.routing.resolve).toHaveBeenCalledTimes(2);
    expect(
      scenario.dependencies.fileSystem.createDirectory,
    ).not.toHaveBeenCalled();
    expect(scenario.dependencies.fileSystem.writeFile).not.toHaveBeenCalled();
    expect(scenario.dependencies.fileSystem.replaceFile).not.toHaveBeenCalled();
    expect(scenario.dependencies.fileSystem.removeFile).not.toHaveBeenCalled();
    expect(scenario.dependencies.git.readPorcelainStatus).toHaveBeenCalledTimes(
      2,
    );
  });

  it.each<{
    affectedPaths?: readonly string[];
    expected: HandoffFailureCode;
    name: string;
    options: ScenarioOptions;
    replacementExpected?: boolean;
    stagingExpected?: boolean;
  }>([
    {
      name: "repository path escape",
      options: { request: { sourceCheckpointPath: "../source.json" } },
      expected: "HANDOFF_PLAN_PATH_INVALID",
    },
    {
      name: "input read failure",
      options: { readFailure: true },
      expected: "HANDOFF_VALIDATOR_UNAVAILABLE",
    },
    {
      name: "raw source digest mismatch",
      options: {
        request: { expectedSourceCheckpointSha256: "9".repeat(64) },
      },
      expected: "HANDOFF_SOURCE_HASH_MISMATCH",
    },
    {
      name: "non-UTF-8 envelope",
      options: { envelopeBytes: Uint8Array.from([255]) },
      expected: "HANDOFF_UNSUPPORTED_VERSION",
    },
    {
      name: "contract validator rejection",
      options: { validationFailure: "HANDOFF_CAPABILITY_UNAVAILABLE" },
      expected: "HANDOFF_CAPABILITY_UNAVAILABLE",
    },
    {
      name: "missing history",
      options: {
        transformEnvelope: (envelope) => ({
          ...envelope,
          handoffHistory: [],
        }),
      },
      expected: "HANDOFF_HISTORY_INVALID",
    },
    {
      name: "archive path escape",
      options: {
        transformEnvelope: (envelope) => ({
          ...envelope,
          source: { ...envelope.source, archivePath: "../archive.json" },
        }),
      },
      expected: "HANDOFF_PLAN_PATH_INVALID",
    },
    {
      name: "workspace binding mismatch",
      options: {
        transformEnvelope: (envelope) => ({
          ...envelope,
          binding: { ...envelope.binding, workspaceRoot: "C:/other" },
        }),
      },
      expected: "HANDOFF_WORKSPACE_MISMATCH",
    },
    {
      name: "destination provider mismatch",
      options: {
        transformEnvelope: (envelope) => ({
          ...envelope,
          destinationProvider: "claude",
        }),
      },
      expected: "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    },
    {
      name: "topology authority rejection",
      options: { topologyFailure: null },
      expected: "HANDOFF_VALIDATOR_UNAVAILABLE",
    },
    {
      name: "routing authority rejection",
      options: { routingFailure: "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE" },
      expected: "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    },
    {
      name: "provider adapter rejection",
      options: {
        transformEnvelope: (envelope) => ({
          ...envelope,
          source: {
            ...envelope.source,
            expressionSchemaId: "codex.orchestrator-state",
          },
        }),
      },
      expected: "HANDOFF_UNSUPPORTED_VERSION",
    },
    {
      name: "destination projection rejection",
      options: { projectionErrors: ["invalid projection"] },
      expected: "HANDOFF_VALIDATOR_UNAVAILABLE",
    },
    {
      name: "porcelain read failure",
      options: { gitFailure: true },
      expected: "HANDOFF_VALIDATOR_UNAVAILABLE",
    },
    {
      name: "dirty worktree paths",
      options: {
        porcelainStatus:
          " M src/one.csproj\n?? src/two.csproj\nR  old.csproj -> new.csproj\n",
      },
      expected: "HANDOFF_DIRTY_WORKTREE",
      affectedPaths: [
        "new.csproj",
        "old.csproj",
        "src/one.csproj",
        "src/two.csproj",
      ],
    },
    {
      name: "archive write failure",
      options: { request: { mode: "materialize" }, writeFailureAt: "archive" },
      expected: "HANDOFF_SOURCE_HASH_MISMATCH",
      stagingExpected: true,
    },
    {
      name: "candidate write failure",
      options: {
        request: { mode: "materialize" },
        writeFailureAt: "candidate",
      },
      expected: "HANDOFF_VALIDATOR_UNAVAILABLE",
      stagingExpected: true,
    },
    {
      name: "atomic replacement failure",
      options: { replaceFailure: true, request: { mode: "materialize" } },
      expected: "HANDOFF_VALIDATOR_UNAVAILABLE",
      replacementExpected: true,
      stagingExpected: true,
    },
  ])(
    "blocks $name without mutation",
    async ({
      affectedPaths,
      expected,
      options,
      replacementExpected,
      stagingExpected,
    }) => {
      // Arrange
      const scenario = createScenario(options);
      const materializer = new OrchestrationHandoffMaterializer(
        scenario.dependencies,
      );

      // Act
      const result = await materializer.transition(scenario.request);

      // Assert
      expect(result.status).toBe("blocked");
      expect(result.primaryFailureCode).toBe(expected);
      if (affectedPaths !== undefined) {
        expect(result.affectedPaths).toEqual(affectedPaths);
      }
      expect(scenario.replaceFile).toHaveBeenCalledTimes(
        replacementExpected === true ? 1 : 0,
      );
      if (stagingExpected !== true) {
        expect(
          scenario.dependencies.fileSystem.createDirectory,
        ).not.toHaveBeenCalled();
        expect(
          scenario.dependencies.fileSystem.writeFile,
        ).not.toHaveBeenCalled();
        expect(
          scenario.dependencies.fileSystem.removeFile,
        ).not.toHaveBeenCalled();
      } else {
        expect(scenario.files.get(scenario.sourcePath)).toEqual(
          scenario.sourceBytes,
        );
      }
      expect(scenario.dependencies.clock.nowIso8601).not.toHaveBeenCalled();
    },
  );

  it("atomically replaces the canonical checkpoint after candidate validation", async () => {
    // Arrange
    const scenario = createScenario({ request: { mode: "materialize" } });
    const archivePath =
      `C:/workspace/artifacts/orchestration/handoffs/sources/sha256/` +
      `${scenario.sourceSha256}.json`;
    scenario.files.set(archivePath, scenario.sourceBytes);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    const replacement = scenario.replaceFile.mock.calls[0];
    const candidatePath = replacement?.[0];
    const destinationPath = replacement?.[1];
    expect(result.status).toBe("materialized");
    expect(scenario.files.get(archivePath)).toEqual(scenario.sourceBytes);
    expect(candidatePath).toBe(
      `C:/workspace/artifacts/orchestration/orchestrator-state` +
        `.handoff-candidate-${scenario.envelopeSha256}.json`,
    );
    expect(candidatePath?.slice(0, candidatePath.lastIndexOf("/"))).toBe(
      "C:/workspace/artifacts/orchestration",
    );
    expect(destinationPath).toBe(scenario.sourcePath);
    expect(scenario.files.has(candidatePath ?? "")).toBe(false);
    expect(
      sha256(scenario.files.get(scenario.sourcePath) ?? new Uint8Array()),
    ).toBe(result.destinationCheckpointSha256);
    expect(scenario.writeFile).toHaveBeenCalledTimes(2);
    expect(scenario.replaceFile).toHaveBeenCalledTimes(1);
  });
});
