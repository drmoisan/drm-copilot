import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import path from "node:path";

import {
  HANDOFF_FAILURE_PRECEDENCE,
  collectHandoffValidationFailures,
  parseHandoffEnvelopeText,
  selectPrimaryHandoffFailure,
  validateHandoffEnvelopeText,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import type {
  HandoffEnvelope,
  HandoffValidationContext,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import {
  projectDestinationCheckpoint,
  recordFirstDestinationDelegation,
} from "../../../src/lib/validate/orchestration-handoff-provider-adapters";
import type { DestinationExecutionEvidence } from "../../../src/lib/validate/orchestration-handoff-provider-adapters";

interface InvalidFixtureCase {
  readonly base: string;
  readonly expected: string;
  readonly id: string;
  readonly path: readonly (string | number)[];
  readonly value: unknown;
}

const fixtureRoot = path.resolve(
  __dirname,
  "../../../../../tests/fixtures/orchestration-handoff/contract",
);

function fixture(name: string): string {
  return readFileSync(path.join(fixtureRoot, name), "utf8");
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function invalidCases(): readonly InvalidFixtureCase[] {
  const value: unknown = JSON.parse(fixture("invalid-contract-cases.json"));
  if (!Array.isArray(value))
    throw new Error("Invalid cases fixture must be an array.");
  return value.map((item): InvalidFixtureCase => {
    if (!isRecord(item) || !Array.isArray(item["path"])) {
      throw new Error("Invalid fixture case structure.");
    }
    const casePath = item["path"];
    if (
      !casePath.every(
        (segment) => typeof segment === "string" || typeof segment === "number",
      )
    ) {
      throw new Error("Invalid fixture path structure.");
    }
    const base = item["base"];
    const expected = item["expected"];
    const id = item["id"];
    if (
      typeof base !== "string" ||
      typeof expected !== "string" ||
      typeof id !== "string"
    ) {
      throw new Error("Invalid fixture case identity.");
    }
    return { base, expected, id, path: casePath, value: item["value"] };
  });
}

function replaceAtPath(
  root: unknown,
  segments: readonly (string | number)[],
  value: unknown,
): void {
  let current = root;
  for (const [index, segment] of segments.entries()) {
    if (!isRecord(current) && !Array.isArray(current)) {
      throw new Error("Fixture mutation path does not resolve to a container.");
    }
    if (index === segments.length - 1) {
      if (typeof segment === "number" && Array.isArray(current))
        current[segment] = value;
      else if (typeof segment === "string" && isRecord(current))
        current[segment] = value;
      else
        throw new Error(
          "Fixture mutation path has an invalid terminal segment.",
        );
      return;
    }
    current = current[segment];
  }
}

function validationContext(
  envelope: HandoffEnvelope,
  overrides: Partial<HandoffValidationContext> = {},
): HandoffValidationContext {
  return {
    repositoryId: envelope.binding.repositoryId,
    workspaceRoot: envelope.binding.workspaceRoot,
    branch: envelope.binding.branch,
    sourceHeadRelationshipValid: true,
    issueNumber: envelope.identity.issueNumber,
    featureFolder: envelope.identity.featureFolder,
    workMode: envelope.identity.workMode,
    planPath: envelope.plan.path,
    planSha256: envelope.plan.sha256,
    expectedSchedulerContext: envelope.schedulerContext,
    requestedTransition: "prepared_to_atomic_execution",
    transitionState: "preparation_complete",
    requestedPhase: "atomic_execution",
    supportedCapabilities: envelope.capabilities.required,
    supportedVocabularies: ["portable-orchestration-handoff-core-v1"],
    validatorAvailable: true,
    topologyResolverAvailable: true,
    providerRoutingAvailable: true,
    evaluateDirtyWorktree: () => [],
    ...overrides,
  };
}

function ordinaryEnvelope(): HandoffEnvelope {
  return parseHandoffEnvelopeText(
    fixture("valid-ordinary-claude-to-codex.json"),
  );
}

function projectionFor(envelope: HandoffEnvelope) {
  const history = envelope.handoffHistory.at(-1);
  if (history === undefined) throw new Error("Expected handoff history.");
  return projectDestinationCheckpoint({
    envelope,
    envelopeSha256: history.envelopeSha256,
    historyEntrySha256: history.entrySha256,
  });
}

function destinationEvidence(
  envelope: HandoffEnvelope,
): DestinationExecutionEvidence {
  const provider = envelope.destinationProvider;
  return {
    routing: { provider },
    topology: { provider },
    model: { provider },
    receipts: [{ provider, delegation_sequence: 1 }],
  };
}

describe("portable orchestration handoff contract parity", () => {
  it.each([
    ["valid-ordinary-claude-to-codex.json", "claude", "codex", "ordinary"],
    ["valid-parallel-codex-to-claude.json", "codex", "claude", "parallel"],
  ] as const)(
    "parses shared positive fixture %s",
    (name, source, destination, scheduler) => {
      const envelope = parseHandoffEnvelopeText(fixture(name));
      expect(envelope.source.provider).toBe(source);
      expect(envelope.destinationProvider).toBe(destination);
      expect(envelope.schedulerContext.kind).toBe(scheduler);
      expect(validateHandoffEnvelopeText(fixture(name))).toBeNull();
    },
  );

  it.each([
    ["ordinary", "valid-ordinary-claude-to-codex.json"],
    ["parallel", "valid-parallel-codex-to-claude.json"],
  ] as const)(
    "defers %s destination receipts until the first post-materialization delegation",
    (_scheduler, fixtureName) => {
      const envelope = parseHandoffEnvelopeText(fixture(fixtureName));
      const projection = projectionFor(envelope);
      const evidence = destinationEvidence(envelope);

      expect(projection.destination_evidence).toEqual({
        status: "pending_first_delegation",
        receipts: [],
      });
      expect(() =>
        recordFirstDestinationDelegation({
          projection,
          evidence,
          checkpointMaterialized: false,
          delegationSequence: 1,
        }),
      ).toThrow("requires the first new delegation after materialization");
      expect(() =>
        recordFirstDestinationDelegation({
          projection,
          evidence,
          checkpointMaterialized: true,
          delegationSequence: 2,
        }),
      ).toThrow("requires the first new delegation after materialization");
      expect(projection.destination_evidence).toEqual({
        status: "pending_first_delegation",
        receipts: [],
      });
    },
  );

  it.each([
    ["ordinary", "valid-ordinary-claude-to-codex.json"],
    ["parallel", "valid-parallel-codex-to-claude.json"],
  ] as const)(
    "records %s destination receipts once for delegation one",
    (_scheduler, fixtureName) => {
      const envelope = parseHandoffEnvelopeText(fixture(fixtureName));
      const projection = projectionFor(envelope);
      const evidence = destinationEvidence(envelope);
      const recorded = recordFirstDestinationDelegation({
        projection,
        evidence,
        checkpointMaterialized: true,
        delegationSequence: 1,
      });

      expect(recorded.destination_evidence).toEqual({
        status: "first_delegation_recorded",
        delegation_sequence: 1,
        ...evidence,
      });
      expect(() =>
        recordFirstDestinationDelegation({
          projection: recorded,
          evidence,
          checkpointMaterialized: true,
          delegationSequence: 1,
        }),
      ).toThrow("requires the first new delegation after materialization");
    },
  );

  it.each(invalidCases())("matches Python failure code for $id", (testCase) => {
    const envelope: unknown = JSON.parse(fixture(testCase.base));
    replaceAtPath(envelope, testCase.path, testCase.value);
    expect(validateHandoffEnvelopeText(JSON.stringify(envelope))).toBe(
      testCase.expected,
    );
  });

  it("rejects structural properties outside the strict domain", () => {
    const envelope: unknown = JSON.parse(
      fixture("valid-ordinary-claude-to-codex.json"),
    );
    if (!isRecord(envelope))
      throw new Error("Positive fixture must be an object.");
    envelope["unexpected"] = true;
    expect(() => parseHandoffEnvelopeText(JSON.stringify(envelope))).toThrow(
      "handoff: contains an unknown property",
    );
  });

  it("matches the shared Python failure precedence registry", () => {
    const registryPath = path.resolve(
      __dirname,
      "../../../../../config/orchestration-handoff-registry.json",
    );
    const registry: unknown = JSON.parse(readFileSync(registryPath, "utf8"));
    if (!isRecord(registry) || !Array.isArray(registry["failure_precedence"])) {
      throw new Error("Registry failure_precedence must be an array.");
    }
    expect(HANDOFF_FAILURE_PRECEDENCE).toEqual(registry["failure_precedence"]);
    expect(HANDOFF_FAILURE_PRECEDENCE).toHaveLength(16);
  });

  it("selects one primary code from multiply-invalid failures", () => {
    const failures = [...HANDOFF_FAILURE_PRECEDENCE].reverse();
    expect(selectPrimaryHandoffFailure(failures)).toBe(
      "HANDOFF_UNSUPPORTED_VERSION",
    );
    expect(selectPrimaryHandoffFailure([])).toBeNull();
  });

  it("rejects completed-phase replay before dirty-worktree precedence", () => {
    const envelope = ordinaryEnvelope();
    const result = collectHandoffValidationFailures(
      envelope,
      validationContext(envelope, {
        requestedPhase: "preflight",
        evaluateDirtyWorktree: () => ["unrelated.csproj"],
      }),
    );
    expect(result.failures).toContain("HANDOFF_TRANSITION_NOT_ALLOWED");
    expect(result.failures.at(-1)).toBe("HANDOFF_DIRTY_WORKTREE");
    expect(selectPrimaryHandoffFailure(result.failures)).toBe(
      "HANDOFF_TRANSITION_NOT_ALLOWED",
    );
  });

  it.each([
    ["validatorAvailable", "HANDOFF_VALIDATOR_UNAVAILABLE"],
    ["topologyResolverAvailable", "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE"],
    ["providerRoutingAvailable", "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE"],
  ] as const)("selects missing authority for %s", (field, expected) => {
    const envelope = ordinaryEnvelope();
    const result = collectHandoffValidationFailures(
      envelope,
      validationContext(envelope, { [field]: false }),
    );
    expect(selectPrimaryHandoffFailure(result.failures)).toBe(expected);
  });

  it("evaluates dirtiness after every contract and authority check", () => {
    const envelope = ordinaryEnvelope();
    let dirtyEvaluationCount = 0;
    const result = collectHandoffValidationFailures(
      envelope,
      validationContext(envelope, {
        repositoryId: "github.com/other/repository",
        validatorAvailable: false,
        topologyResolverAvailable: false,
        providerRoutingAvailable: false,
        evaluateDirtyWorktree: () => {
          dirtyEvaluationCount += 1;
          return ["unrelated.csproj"];
        },
      }),
    );
    expect(dirtyEvaluationCount).toBe(1);
    expect(result.failures).toEqual([
      "HANDOFF_REPOSITORY_MISMATCH",
      "HANDOFF_VALIDATOR_UNAVAILABLE",
      "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
      "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
      "HANDOFF_DIRTY_WORKTREE",
    ]);
    expect(selectPrimaryHandoffFailure(result.failures)).toBe(
      "HANDOFF_REPOSITORY_MISMATCH",
    );
  });
});
