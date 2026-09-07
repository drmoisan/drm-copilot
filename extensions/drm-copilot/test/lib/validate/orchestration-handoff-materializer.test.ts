import { describe, expect, it } from "@jest/globals";

import type { HandoffFailureCode } from "../../../src/lib/validate/orchestration-handoff-contract";
import { OrchestrationHandoffMaterializer } from "../../../src/lib/validate/orchestration-handoff-materializer";
import {
  INDEPENDENT_CONTEXT,
  archivePathFor,
  candidatePathFor,
  createScenario,
  encoder,
  materializedProjectionBytes,
  sha256,
  workspacePath,
  type ScenarioOptions,
} from "./orchestration-handoff-materializer-test-support";

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
    const io = scenario.dependencies.fileSystem;
    expect(scenario.dependencies.topology.resolve).toHaveBeenCalledTimes(2);
    expect(scenario.dependencies.routing.resolve).toHaveBeenCalledTimes(2);
    expect(io.createDirectory).not.toHaveBeenCalled();
    expect(io.writeFile).not.toHaveBeenCalled();
    expect(io.replaceFile).not.toHaveBeenCalled();
    expect(io.removeFile).not.toHaveBeenCalled();
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
      options: { transformEnvelope: (e) => ({ ...e, handoffHistory: [] }) },
      expected: "HANDOFF_HISTORY_INVALID",
    },
    {
      name: "archive path escape",
      options: {
        transformEnvelope: (e) => ({
          ...e,
          source: { ...e.source, archivePath: "../archive.json" },
        }),
      },
      expected: "HANDOFF_PLAN_PATH_INVALID",
    },
    {
      name: "workspace binding mismatch",
      options: {
        transformEnvelope: (e) => ({
          ...e,
          binding: { ...e.binding, workspaceRoot: "C:/other" },
        }),
      },
      expected: "HANDOFF_WORKSPACE_MISMATCH",
    },
    {
      name: "destination provider mismatch",
      options: {
        transformEnvelope: (e) => ({ ...e, destinationProvider: "claude" }),
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
        transformEnvelope: (e) => ({
          ...e,
          source: {
            ...e.source,
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
      const io = scenario.dependencies.fileSystem;
      if (stagingExpected !== true) {
        expect(io.createDirectory).not.toHaveBeenCalled();
        expect(io.writeFile).not.toHaveBeenCalled();
        expect(io.removeFile).not.toHaveBeenCalled();
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
    const archivePath = archivePathFor(scenario.sourceSha256);
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
    expect(candidatePath).toBe(candidatePathFor(scenario.envelopeSha256));
    expect(candidatePath?.slice(0, candidatePath.lastIndexOf("/"))).toBe(
      workspacePath("artifacts/orchestration"),
    );
    expect(destinationPath).toBe(scenario.sourcePath);
    expect(scenario.files.has(candidatePath ?? "")).toBe(false);
    expect(
      sha256(scenario.files.get(scenario.sourcePath) ?? new Uint8Array()),
    ).toBe(result.destinationCheckpointSha256);
    expect(scenario.writeFile).toHaveBeenCalledTimes(2);
    expect(scenario.replaceFile).toHaveBeenCalledTimes(1);
  });

  it("blocks when a pre-existing archive cannot be re-read", async () => {
    // Arrange
    const scenario = createScenario({
      failReadFor: (filePath) => filePath.includes("/sources/sha256/"),
      request: { mode: "materialize" },
    });
    const archivePath = archivePathFor(scenario.sourceSha256);
    scenario.files.set(archivePath, scenario.sourceBytes);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.affectedPaths).toEqual([archivePath]);
    expect(scenario.files.get(scenario.sourcePath)).toEqual(
      scenario.sourceBytes,
    );
  });

  it("blocks a pre-existing candidate whose digest differs from the projection", async () => {
    // Arrange
    const scenario = createScenario({ request: { mode: "materialize" } });
    const candidatePath = candidatePathFor(scenario.envelopeSha256);
    scenario.files.set(candidatePath, encoder.encode("unrelated candidate"));
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.affectedPaths).toEqual([candidatePath]);
    expect(scenario.files.get(scenario.sourcePath)).toEqual(
      scenario.sourceBytes,
    );
  });

  it("materializes when a pre-existing candidate already holds the projection bytes", async () => {
    // Arrange
    const projectionBytes = await materializedProjectionBytes();
    const scenario = createScenario({ request: { mode: "materialize" } });
    const candidatePath = candidatePathFor(scenario.envelopeSha256);
    scenario.files.set(candidatePath, projectionBytes);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("materialized");
    expect(result.primaryFailureCode).toBeNull();
    expect(scenario.replaceFile).toHaveBeenCalledTimes(1);
    expect(
      sha256(scenario.files.get(scenario.sourcePath) ?? new Uint8Array()),
    ).toBe(result.destinationCheckpointSha256);
  });

  it("discards the candidate and blocks when re-validation rejects it", async () => {
    // Arrange
    const scenario = createScenario({
      candidateProjectionErrors: ["candidate rejected"],
      request: { mode: "materialize" },
    });
    const candidatePath = candidatePathFor(scenario.envelopeSha256);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.affectedPaths).toEqual([candidatePath]);
    expect(scenario.removeFile).toHaveBeenCalledWith(candidatePath);
    expect(scenario.files.has(candidatePath)).toBe(false);
  });

  it("discards the candidate and blocks when the candidate cannot be re-read", async () => {
    // Arrange
    const scenario = createScenario({
      failReadFor: (filePath) => filePath.includes("handoff-candidate-"),
      request: { mode: "materialize" },
    });
    const candidatePath = candidatePathFor(scenario.envelopeSha256);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.affectedPaths).toEqual([candidatePath]);
    expect(scenario.removeFile).toHaveBeenCalledWith(candidatePath);
    expect(scenario.files.has(candidatePath)).toBe(false);
  });

  it("blocks with the retained candidate when candidate removal also fails", async () => {
    // Arrange
    const scenario = createScenario({
      candidateProjectionErrors: ["candidate rejected"],
      removeFailure: true,
      request: { mode: "materialize" },
    });
    const candidatePath = candidatePathFor(scenario.envelopeSha256);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.affectedPaths).toEqual([candidatePath]);
    expect(scenario.removeFile).toHaveBeenCalledWith(candidatePath);
    expect(scenario.files.has(candidatePath)).toBe(true);
  });

  it("discards the candidate and names it when the atomic replace fails", async () => {
    // Arrange
    const scenario = createScenario({
      replaceFailure: true,
      request: { mode: "materialize" },
    });
    const candidatePath = candidatePathFor(scenario.envelopeSha256);
    const materializer = new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    );

    // Act
    const result = await materializer.transition(scenario.request);

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(result.affectedPaths).toEqual([candidatePath]);
    expect(scenario.removeFile).toHaveBeenCalledTimes(1);
    expect(scenario.removeFile).toHaveBeenCalledWith(candidatePath);
    expect(scenario.files.get(scenario.sourcePath)).toEqual(
      scenario.sourceBytes,
    );
  });
});

const FR_614_005_CODES = [
  "HANDOFF_REPOSITORY_MISMATCH",
  "HANDOFF_WORKSPACE_MISMATCH",
  "HANDOFF_ISSUE_FEATURE_MISMATCH",
  "HANDOFF_BRANCH_LINEAGE_MISMATCH",
  "HANDOFF_PLAN_PATH_INVALID",
  "HANDOFF_PLAN_HASH_MISMATCH",
] as const;

const MODES = ["dry_run", "materialize"] as const;

const FR_614_005_MATRIX = MODES.flatMap((mode) =>
  FR_614_005_CODES.map((code) => ({ code, mode })),
);

describe("FR-614-005 independent-context mismatches block every transition", () => {
  it.each(FR_614_005_MATRIX)(
    "blocks $code in $mode mode with no dirty evaluation and no write",
    async ({ code, mode }) => {
      // Arrange
      const scenario = createScenario({
        request: { mode },
        topologyFailure: code,
      });
      const materializer = new OrchestrationHandoffMaterializer(
        scenario.dependencies,
      );

      // Act
      const result = await materializer.transition(scenario.request);

      // Assert
      const io = scenario.dependencies.fileSystem;
      expect(result.status).toBe("blocked");
      expect(result.primaryFailureCode).toBe(code);
      expect(result.destinationCheckpointPath).toBeNull();
      expect(result.destinationCheckpointSha256).toBeNull();
      expect(
        scenario.dependencies.git.readPorcelainStatus,
      ).not.toHaveBeenCalled();
      expect(scenario.dependencies.routing.resolve).not.toHaveBeenCalled();
      expect(io.createDirectory).not.toHaveBeenCalled();
      expect(io.writeFile).not.toHaveBeenCalled();
      expect(io.replaceFile).not.toHaveBeenCalled();
      expect(io.removeFile).not.toHaveBeenCalled();
      expect(scenario.dependencies.clock.nowIso8601).not.toHaveBeenCalled();
    },
  );

  it.each(MODES)(
    "forwards the entire independent context to both authorities in %s mode",
    async (mode) => {
      // Arrange
      const scenario = createScenario({ request: { mode } });
      const materializer = new OrchestrationHandoffMaterializer(
        scenario.dependencies,
      );

      // Act
      await materializer.transition(scenario.request);

      // Assert
      const expected = expect.objectContaining({ ...INDEPENDENT_CONTEXT });
      expect(scenario.dependencies.topology.resolve).toHaveBeenCalledWith(
        expected,
      );
      expect(scenario.dependencies.routing.resolve).toHaveBeenCalledWith(
        expected,
      );
    },
  );
});
