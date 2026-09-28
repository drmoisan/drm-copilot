import { jest } from "@jest/globals";
import { createHash } from "node:crypto";
import * as path from "node:path";

import type {
  HandoffEnvelope,
  HandoffFailureCode,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import type { TransitionPreparedOrchestrationRequest } from "../../../src/mcp-repo-automation-tool-definitions-handoff";
import {
  OrchestrationHandoffMaterializer,
  type HandoffMaterializerDependencies,
} from "../../../src/lib/validate/orchestration-handoff-materializer";

/**
 * Absolute workspace root shared by every materializer scenario, derived at
 * run time rather than written as a drive-letter literal. A drive-letter
 * literal is absolute on Windows and relative on POSIX, so the production
 * absolute-path predicates reject it on Linux. Resolving a relative
 * virtual name yields a root that is absolute on both platforms, and
 * normalizing the separator to a forward slash matches the POSIX-style paths
 * the production modules compute.
 */
export const VIRTUAL_WORKSPACE_ROOT = path
  .resolve("virtual-workspace")
  .replaceAll("\\", "/");

/**
 * Joins a repository-relative path onto {@link VIRTUAL_WORKSPACE_ROOT} with a
 * single forward slash, producing the same absolute path the production
 * modules derive for that repository-relative input.
 */
export function workspacePath(repositoryPath: string): string {
  return `${VIRTUAL_WORKSPACE_ROOT}/${repositoryPath}`;
}

/**
 * Caller-controlled independent expected context required by every portable
 * handoff request. The values are fixed constants so a test can assert that a
 * request forwards them unchanged rather than deriving them from the envelope.
 */
export const INDEPENDENT_CONTEXT = {
  expectedRepositoryId: "github.com/drmoisan/drm-copilot",
  expectedWorkspaceRoot: VIRTUAL_WORKSPACE_ROOT,
  expectedBranch: "feature/portable-handoff-614",
  expectedSourceHeadSha: "0".repeat(40),
  allowedHeadRelationship: "equal_or_descendant",
  expectedIssueNumber: 614,
  expectedFeatureFolder: "docs/features/active/portable-handoff-614",
  expectedWorkMode: "full-feature",
  expectedPlanPath: "docs/features/active/portable-handoff-614/plan.md",
  expectedPlanSha256: "2".repeat(64),
} as const;

export const encoder = new TextEncoder();

export function sha256(content: Uint8Array): string {
  return createHash("sha256").update(content).digest("hex");
}

export function createEnvelope(sourceSha256: string): HandoffEnvelope {
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
      workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
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

export interface ScenarioOptions {
  readonly candidateProjectionErrors?: readonly string[];
  readonly envelopeBytes?: Uint8Array;
  readonly failReadFor?: (filePath: string) => boolean;
  readonly gitFailure?: boolean;
  readonly porcelainStatus?: string;
  readonly projectionErrors?: readonly string[];
  readonly readFailure?: boolean;
  readonly removeFailure?: boolean;
  readonly replaceFailure?: boolean;
  readonly request?: Partial<TransitionPreparedOrchestrationRequest>;
  readonly routingFailure?: HandoffFailureCode;
  readonly sourceBytes?: Uint8Array;
  readonly topologyFailure?: HandoffFailureCode | null;
  readonly transformEnvelope?: (envelope: HandoffEnvelope) => HandoffEnvelope;
  readonly validationFailure?: HandoffFailureCode;
  readonly writeFailureAt?: "archive" | "candidate";
}

export function archivePathFor(sourceSha256: string): string {
  return workspacePath(
    `artifacts/orchestration/handoffs/sources/sha256/${sourceSha256}.json`,
  );
}

export function candidatePathFor(envelopeSha256: string): string {
  return workspacePath(
    `artifacts/orchestration/orchestrator-state` +
      `.handoff-candidate-${envelopeSha256}.json`,
  );
}

export function createScenario(options: ScenarioOptions = {}) {
  const sourceBytes =
    options.sourceBytes ?? encoder.encode('{"provider":"claude"}\n');
  const envelopeBytes =
    options.envelopeBytes ?? encoder.encode('{"kind":"validated-envelope"}\n');
  const sourceSha256 = sha256(sourceBytes);
  const envelopeSha256 = sha256(envelopeBytes);
  const baseEnvelope = createEnvelope(sourceSha256);
  const envelope = options.transformEnvelope?.(baseEnvelope) ?? baseEnvelope;
  const sourcePath = workspacePath(baseEnvelope.source.checkpointPath);
  const envelopePath = workspacePath(
    "artifacts/orchestration/handoffs/handoff.json",
  );
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
    if (options.failReadFor?.(filePath) === true) {
      throw new Error(`read failed: ${filePath}`);
    }
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
  const removeFile = jest.fn((filePath: string) => {
    if (options.removeFailure === true) throw new Error("remove failed");
    files.delete(filePath);
  });
  let projectionValidationCalls = 0;
  const dependencies: HandoffMaterializerDependencies = {
    fileSystem: {
      readFile,
      createDirectory: jest.fn(),
      writeFile,
      replaceFile,
      removeFile,
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
      validateDestinationProjection: jest.fn((): readonly string[] => {
        projectionValidationCalls += 1;
        if (
          options.candidateProjectionErrors !== undefined &&
          projectionValidationCalls >= 2
        ) {
          return options.candidateProjectionErrors;
        }
        return options.projectionErrors ?? [];
      }),
    },
    clock: { nowIso8601: jest.fn(() => "2026-08-31T08:00:00Z") },
  };
  const request: TransitionPreparedOrchestrationRequest = {
    workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
    sourceCheckpointPath: baseEnvelope.source.checkpointPath,
    expectedSourceCheckpointSha256: sourceSha256,
    handoffEnvelopePath: "artifacts/orchestration/handoffs/handoff.json",
    expectedHandoffEnvelopeSha256: envelopeSha256,
    destinationProvider: "codex",
    mode: "dry_run",
    ...INDEPENDENT_CONTEXT,
    ...options.request,
  };
  return {
    dependencies,
    envelope,
    envelopeSha256,
    files,
    readFile,
    removeFile,
    request,
    replaceFile,
    sourceBytes,
    sourcePath,
    sourceSha256,
    writeFile,
  };
}

export async function materializedProjectionBytes(): Promise<Uint8Array> {
  const scenario = createScenario({ request: { mode: "materialize" } });
  const materializer = new OrchestrationHandoffMaterializer(
    scenario.dependencies,
  );
  await materializer.transition(scenario.request);
  const candidateWrite = scenario.writeFile.mock.calls[1];
  if (candidateWrite === undefined) {
    throw new Error(
      "Expected a candidate write while building projection bytes.",
    );
  }
  return candidateWrite[1];
}
