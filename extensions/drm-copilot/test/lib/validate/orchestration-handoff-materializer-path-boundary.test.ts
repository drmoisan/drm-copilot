import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import * as path from "node:path";
import { describe, expect, it, jest } from "@jest/globals";

import type { TransitionPreparedOrchestrationRequest } from "../../../src/mcp-repo-automation-tool-definitions-handoff";
import { parseHandoffEnvelopeText } from "../../../src/lib/validate/orchestration-handoff-contract";
import type { HandoffEnvelope } from "../../../src/lib/validate/orchestration-handoff-contract";
import {
  OrchestrationHandoffMaterializer,
  type HandoffMaterializerDependencies,
} from "../../../src/lib/validate/orchestration-handoff-materializer";
import { candidateFilePath } from "../../../src/lib/validate/orchestration-handoff-materializer-support";

type RejectedTarget =
  "source" | "envelope" | "archive" | "destination" | "candidate";

const encoder = new TextEncoder();
const canonicalWorkspaceRoot = "C:/canonical-workspace";
const envelopeRepositoryPath = "artifacts/orchestration/handoffs/handoff.json";
const fixturePath = path.resolve(
  __dirname,
  "../../../../../tests/fixtures/orchestration-handoff/contract/valid-ordinary-claude-to-codex.json",
);
const baseEnvelope = parseHandoffEnvelopeText(
  readFileSync(fixturePath, "utf8"),
);

function sha256(content: Uint8Array): string {
  return createHash("sha256").update(content).digest("hex");
}

function canonicalPath(repositoryPath: string): string {
  return `${canonicalWorkspaceRoot}/${repositoryPath}`;
}

function envelopeFor(sourceSha256: string): HandoffEnvelope {
  return {
    ...baseEnvelope,
    binding: { ...baseEnvelope.binding, workspaceRoot: "C:/workspace" },
    source: {
      ...baseEnvelope.source,
      checkpointSha256: sourceSha256,
      archivePath: `artifacts/orchestration/handoffs/sources/sha256/${sourceSha256}.json`,
    },
    handoffHistory: baseEnvelope.handoffHistory.map((entry) => ({
      ...entry,
      sourceCheckpointSha256: sourceSha256,
    })),
  };
}

function createScenario(rejectedTarget?: RejectedTarget) {
  const sourceBytes = encoder.encode('{"provider":"claude"}\n');
  const envelopeBytes = encoder.encode('{"kind":"validated-envelope"}\n');
  const sourceSha256 = sha256(sourceBytes);
  const envelopeSha256 = sha256(envelopeBytes);
  const envelope = envelopeFor(sourceSha256);
  const candidateRepositoryPath = candidateFilePath(
    envelope.destinationCheckpointPath,
    envelopeSha256,
  );
  const sourcePath = canonicalPath(envelope.source.checkpointPath);
  const envelopePath = canonicalPath(envelopeRepositoryPath);
  const archivePath = canonicalPath(envelope.source.archivePath);
  const destinationPath = canonicalPath(envelope.destinationCheckpointPath);
  const candidatePath = canonicalPath(candidateRepositoryPath);
  const files = new Map<string, Uint8Array>([
    [sourcePath, sourceBytes],
    [envelopePath, envelopeBytes],
  ]);
  const readFile = jest.fn((filePath: string): Uint8Array => {
    const content = files.get(filePath);
    if (content === undefined) throw new Error(`Missing file: ${filePath}`);
    return content;
  });
  const createDirectory = jest.fn();
  const writeFile = jest.fn(
    (
      filePath: string,
      content: Uint8Array,
      options?: { readonly exclusive?: boolean },
    ): void => {
      if (options?.exclusive === true && files.has(filePath)) {
        throw new Error(`Existing file: ${filePath}`);
      }
      files.set(filePath, Uint8Array.from(content));
    },
  );
  const removeFile = jest.fn((filePath: string): void => {
    files.delete(filePath);
  });
  const replaceFile = jest.fn(
    (candidate: string, destination: string): void => {
      const content = files.get(candidate);
      if (content === undefined) throw new Error("Candidate is missing.");
      files.set(destination, content);
      files.delete(candidate);
    },
  );
  const topology = jest.fn(async () => ({
    status: "validated" as const,
    handoffId: envelope.handoffId,
    handoffEnvelopeSha256: envelopeSha256,
    primaryFailureCode: null,
    affectedPaths: [],
    unsupportedCapabilities: [],
    resolution: {},
  }));
  const routing = jest.fn(async () => ({
    status: "validated" as const,
    handoffId: envelope.handoffId,
    handoffEnvelopeSha256: envelopeSha256,
    primaryFailureCode: null,
    affectedPaths: [],
    unsupportedCapabilities: [],
    resolution: {},
  }));
  const pathBoundary = {
    resolveWorkspaceRoot: jest.fn(() => canonicalWorkspaceRoot),
    resolveExistingTarget: jest.fn(
      (_root: string, repositoryPath: string): string | null => {
        if (
          (rejectedTarget === "source" &&
            repositoryPath === envelope.source.checkpointPath) ||
          (rejectedTarget === "envelope" &&
            repositoryPath === envelopeRepositoryPath)
        ) {
          return null;
        }
        if (repositoryPath === envelope.source.checkpointPath)
          return sourcePath;
        if (repositoryPath === envelopeRepositoryPath) return envelopePath;
        return null;
      },
    ),
    resolveCreatableTarget: jest.fn(
      (_root: string, repositoryPath: string): string | null => {
        if (
          (rejectedTarget === "archive" &&
            repositoryPath === envelope.source.archivePath) ||
          (rejectedTarget === "destination" &&
            repositoryPath === envelope.destinationCheckpointPath) ||
          (rejectedTarget === "candidate" &&
            repositoryPath === candidateRepositoryPath)
        ) {
          return null;
        }
        if (repositoryPath === envelope.source.archivePath) return archivePath;
        if (repositoryPath === envelope.destinationCheckpointPath) {
          return destinationPath;
        }
        if (repositoryPath === candidateRepositoryPath) return candidatePath;
        return null;
      },
    ),
  };
  const gitStatus = jest.fn(async () => "");
  const dependencies: HandoffMaterializerDependencies = {
    fileSystem: {
      readFile,
      createDirectory,
      writeFile,
      removeFile,
      replaceFile,
    },
    pathBoundary,
    git: { readPorcelainStatus: gitStatus },
    topology: { resolve: topology },
    routing: { resolve: routing },
    validator: {
      validateEnvelope: jest.fn(() => ({
        envelope,
        primaryFailureCode: null,
        affectedPaths: [],
        unsupportedCapabilities: [],
      })),
      validateDestinationProjection: jest.fn(() => []),
    },
    clock: { nowIso8601: jest.fn(() => "2026-08-31T08:00:00Z") },
  };
  const request: TransitionPreparedOrchestrationRequest = {
    workspaceRoot: "C:/workspace",
    sourceCheckpointPath: envelope.source.checkpointPath,
    expectedSourceCheckpointSha256: sourceSha256,
    handoffEnvelopePath: envelopeRepositoryPath,
    expectedHandoffEnvelopeSha256: envelopeSha256,
    destinationProvider: "codex",
    mode: "materialize",
  };
  return {
    archivePath,
    candidatePath,
    createDirectory,
    dependencies,
    destinationPath,
    files,
    gitStatus,
    readFile,
    removeFile,
    replaceFile,
    request,
    sourceBytes,
    sourcePath,
    topology,
    routing,
    writeFile,
  };
}

describe("orchestration handoff materializer canonical path boundary", () => {
  it.each([
    ["source", 0],
    ["envelope", 0],
    ["archive", 2],
    ["destination", 2],
    ["candidate", 2],
  ] as const)(
    "rejects a canonical %s escape before relevant reads or mutations",
    async (target, expectedReads) => {
      // Arrange
      const scenario = createScenario(target);
      const originalSource = scenario.files.get(scenario.sourcePath);

      // Act
      const result = await new OrchestrationHandoffMaterializer(
        scenario.dependencies,
      ).transition(scenario.request);

      // Assert
      expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
      expect(scenario.readFile).toHaveBeenCalledTimes(expectedReads);
      expect(scenario.createDirectory).not.toHaveBeenCalled();
      expect(scenario.writeFile).not.toHaveBeenCalled();
      expect(scenario.removeFile).not.toHaveBeenCalled();
      expect(scenario.replaceFile).not.toHaveBeenCalled();
      expect(scenario.topology).not.toHaveBeenCalled();
      expect(scenario.routing).not.toHaveBeenCalled();
      expect(scenario.files.get(scenario.sourcePath)).toEqual(originalSource);
    },
  );

  it("materializes an ordinary in-workspace handoff through canonical paths", async () => {
    // Arrange
    const scenario = createScenario();

    // Act
    const result = await new OrchestrationHandoffMaterializer(
      scenario.dependencies,
    ).transition(scenario.request);

    // Assert
    expect(result.status).toBe("materialized");
    expect(result.primaryFailureCode).toBeNull();
    expect(scenario.gitStatus).toHaveBeenCalledWith(canonicalWorkspaceRoot);
    expect(scenario.createDirectory).toHaveBeenCalledTimes(1);
    expect(scenario.writeFile).toHaveBeenCalledTimes(2);
    expect(scenario.replaceFile).toHaveBeenCalledWith(
      scenario.candidatePath,
      scenario.destinationPath,
    );
    expect(scenario.removeFile).not.toHaveBeenCalled();
    expect(scenario.files.get(scenario.archivePath)).toEqual(
      scenario.sourceBytes,
    );
    expect(scenario.files.has(scenario.candidatePath)).toBe(false);
  });
});
