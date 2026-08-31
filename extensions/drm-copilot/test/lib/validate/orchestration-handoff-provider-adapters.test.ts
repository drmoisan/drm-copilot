import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import * as path from "node:path";

import {
  HandoffContractError,
  parseHandoffEnvelopeText,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import type {
  HandoffEnvelope,
  HandoffProvider,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import {
  projectDestinationCheckpoint,
  validateProviderSource,
} from "../../../src/lib/validate/orchestration-handoff-provider-adapters";

interface FixtureDocument {
  source: {
    expression: {
      historical_receipts: {
        references: Array<{ path: string; sha256: string }>;
      };
    };
  };
}

function loadEnvelope(name: string): HandoffEnvelope {
  const fixturePath = path.resolve(
    __dirname,
    "../../../../../tests/fixtures/orchestration-handoff/contract",
    name,
  );
  const document = JSON.parse(
    readFileSync(fixturePath, "utf8"),
  ) as FixtureDocument;
  document.source.expression.historical_receipts.references = [
    {
      path: "artifacts/orchestration/receipts/source.json",
      sha256: "a".repeat(64),
    },
  ];
  return parseHandoffEnvelopeText(JSON.stringify(document));
}

function project(envelope: HandoffEnvelope) {
  const lastEntry = envelope.handoffHistory.at(-1);
  if (lastEntry === undefined) throw new Error("Fixture history is required.");
  return projectDestinationCheckpoint({
    envelope,
    envelopeSha256: "b".repeat(64),
    historyEntrySha256: lastEntry.entrySha256,
  });
}

describe("orchestration handoff provider adapters", () => {
  it.each<{
    destination: HandoffProvider;
    expression: string;
    fixture: string;
    projector: string;
    source: HandoffProvider;
  }>([
    {
      fixture: "valid-ordinary-claude-to-codex.json",
      source: "claude",
      destination: "codex",
      expression: "codex.orchestrator-state",
      projector: "portable-to-codex-v1",
    },
    {
      fixture: "valid-parallel-codex-to-claude.json",
      source: "codex",
      destination: "claude",
      expression: "claude.orchestrator-state",
      projector: "portable-to-claude-v1",
    },
  ])(
    "validates $source source and projects $destination destination without translated evidence",
    ({ destination, expression, fixture, projector, source }) => {
      // Arrange
      const envelope = loadEnvelope(fixture);

      // Act
      const sourceAdapter = validateProviderSource(envelope);
      const projection = project(envelope);
      const link = projection.portable_handoff as {
        lifecycle: {
          completed_phases: readonly string[];
          logical_complexity: string;
          next_transition: string;
          route_intent: string;
        };
        plan: { path: string; sha256: string };
        scheduler_context: Readonly<Record<string, unknown>>;
        source: {
          expression: {
            historical_receipts: {
              mode: string;
              references: readonly { path: string; sha256: string }[];
            };
          };
          provider: string;
        };
      };

      // Assert: portable lifecycle/plan/ownership are copied, historical
      // receipts remain opaque references, and destination evidence is empty.
      expect(sourceAdapter.provider).toBe(source);
      expect(projection.provider).toBe(destination);
      expect(projection.checkpoint_expression).toBe(expression);
      expect(projection.destination_projector).toBe(projector);
      expect(projection["plan-path"]).toBe(envelope.plan.path);
      expect(projection.next_step).toBe(envelope.lifecycle.nextTransition);
      expect(link.plan).toEqual({
        path: envelope.plan.path,
        sha256: envelope.plan.sha256,
        contract_version: envelope.plan.contractVersion,
      });
      expect(link.lifecycle).toMatchObject({
        logical_complexity: envelope.lifecycle.logicalComplexity,
        route_intent: envelope.lifecycle.routeIntent,
        completed_phases: envelope.lifecycle.completedPhases,
        next_transition: envelope.lifecycle.nextTransition,
      });
      expect(link.scheduler_context).toMatchObject({
        kind: envelope.schedulerContext.kind,
      });
      expect(link.source).toMatchObject({
        provider: source,
        expression: {
          historical_receipts: {
            mode: "opaque",
            references: [
              {
                path: "artifacts/orchestration/receipts/source.json",
                sha256: "a".repeat(64),
              },
            ],
          },
        },
      });
      expect(projection.destination_evidence).toEqual({
        status: "pending_first_delegation",
        receipts: [],
      });
      expect(JSON.stringify(projection)).not.toMatch(
        /"(?:model|reasoning_effort|agent_profile|topology|launch_attestation)"/,
      );
    },
  );

  it("rejects a source expression registered to the other provider", () => {
    // Arrange
    const envelope = loadEnvelope("valid-ordinary-claude-to-codex.json");
    const invalid: HandoffEnvelope = {
      ...envelope,
      source: {
        ...envelope.source,
        expressionSchemaId: "codex.orchestrator-state",
      },
    };

    // Act
    let failure: unknown;
    try {
      validateProviderSource(invalid);
    } catch (error: unknown) {
      failure = error;
    }

    // Assert
    expect(failure).toBeInstanceOf(HandoffContractError);
    expect((failure as HandoffContractError).code).toBe(
      "HANDOFF_UNSUPPORTED_VERSION",
    );
  });

  it("rejects an approximate bidirectional adapter identity", () => {
    // Arrange
    const envelope = loadEnvelope("valid-ordinary-claude-to-codex.json");
    const firstEntry = envelope.handoffHistory[0];
    if (firstEntry === undefined)
      throw new Error("Fixture history is required.");
    const invalid: HandoffEnvelope = {
      ...envelope,
      handoffHistory: [{ ...firstEntry, adapterId: "claude-codex-v1" }],
    };

    // Act
    let failure: unknown;
    try {
      validateProviderSource(invalid);
    } catch (error: unknown) {
      failure = error;
    }

    // Assert
    expect(failure).toBeInstanceOf(HandoffContractError);
    expect((failure as HandoffContractError).code).toBe(
      "HANDOFF_HISTORY_INVALID",
    );
  });
});
