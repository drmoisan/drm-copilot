import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import path from "node:path";

import {
  isExactSemanticMcpOperation,
  parseSemanticMcpIdentity,
} from "../../../src/lib/validate/semantic-mcp-identity";

interface AliasParityCase {
  readonly operation: string | null;
  readonly rejectionCode: string | null;
  readonly semanticId: string | null;
  readonly transportId: string;
}

function aliasParityCases(): readonly AliasParityCase[] {
  const fixturePath = path.resolve(
    __dirname,
    "../../../../../tests/fixtures/orchestration-handoff/contract/semantic-mcp-alias-cases.json",
  );
  const value: unknown = JSON.parse(readFileSync(fixturePath, "utf8"));
  if (!Array.isArray(value))
    throw new Error("Alias parity fixture must be an array.");
  return value.map((item): AliasParityCase => {
    if (typeof item !== "object" || item === null || Array.isArray(item)) {
      throw new Error("Alias parity case must be an object.");
    }
    const record = item as Readonly<Record<string, unknown>>;
    const nullableString = (key: string): string | null => {
      const candidate = record[key];
      if (candidate === null || typeof candidate === "string") return candidate;
      throw new Error(`Alias parity ${key} must be a nullable string.`);
    };
    const transportId = record["transport_id"];
    if (typeof transportId !== "string") {
      throw new Error("Alias parity transport_id must be a string.");
    }
    return {
      operation: nullableString("operation"),
      rejectionCode: nullableString("rejection_code"),
      semanticId: nullableString("semantic_id"),
      transportId,
    };
  });
}

describe("semantic MCP identity", () => {
  it.each(aliasParityCases())(
    "matches shared Python parity fixture for $transportId",
    (testCase) => {
      const identity = parseSemanticMcpIdentity(testCase.transportId);
      expect({
        semanticId: identity?.semanticId ?? null,
        operation: identity?.operation ?? null,
        rejectionCode:
          identity === null ? "SEMANTIC_MCP_IDENTITY_REJECTED" : null,
      }).toEqual({
        semanticId: testCase.semanticId,
        operation: testCase.operation,
        rejectionCode: testCase.rejectionCode,
      });
    },
  );

  it.each([
    "mcp__drm-copilot__validate_orchestration_artifacts",
    "mcp__drm_copilot__validate_orchestration_artifacts",
  ])("normalizes validator alias %s", (transportId) => {
    expect(parseSemanticMcpIdentity(transportId)).toEqual({
      semanticId: "drm-copilot.validate_orchestration_artifacts",
      server: "drm-copilot",
      operation: "validate_orchestration_artifacts",
      transportId,
    });
  });

  it.each([
    "mcp__drm-copilot__transition_prepared_orchestration",
    "mcp__drm_copilot__transition_prepared_orchestration",
  ])("normalizes transition alias %s", (transportId) => {
    expect(parseSemanticMcpIdentity(transportId)?.semanticId).toBe(
      "drm-copilot.transition_prepared_orchestration",
    );
  });

  it.each([
    "drm-copilot__validate_orchestration_artifacts",
    "mcp_drm-copilot_validate_orchestration_artifacts",
    "mcp__drm-copilot",
    "mcp__drm-copilot__",
    "mcp__DRM-COPILOT__validate_orchestration_artifacts",
    "mcp__drm-copilot__validate-orchestration-artifacts",
  ])("rejects malformed transport identity %s", (transportId) => {
    expect(parseSemanticMcpIdentity(transportId)).toBeNull();
  });

  it.each([
    "mcp__other__validate_orchestration_artifacts",
    "mcp__drm-copilot-extra__validate_orchestration_artifacts",
  ])("rejects unrelated server %s", (transportId) => {
    expect(parseSemanticMcpIdentity(transportId)).toBeNull();
  });

  it.each([
    "mcp__drm-copilot__validate_orchestration_artifact",
    "mcp__drm-copilot__transition_prepared_orchestrator",
    "mcp__drm-copilot__resolve_orchestration_topologies",
  ])("rejects approximate operation name %s", (transportId) => {
    expect(parseSemanticMcpIdentity(transportId)).toBeNull();
  });

  it("rejects a well-formed but unregistered operation", () => {
    expect(
      parseSemanticMcpIdentity("mcp__drm-copilot__collect_commit_context"),
    ).toBeNull();
  });

  it("compares the registered operation exactly", () => {
    const validator = "mcp__drm_copilot__validate_orchestration_artifacts";
    expect(
      isExactSemanticMcpOperation(
        validator,
        "validate_orchestration_artifacts",
      ),
    ).toBe(true);
    expect(
      isExactSemanticMcpOperation(
        validator,
        "transition_prepared_orchestration",
      ),
    ).toBe(false);
  });
});
