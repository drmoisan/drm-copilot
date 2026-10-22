/**
 * Resolver contract for the artifact mutation tools: create, update and link.
 *
 * Each resolver accepts exactly the closed v2 shape of its operation, keeps
 * the two draft kinds' fields apart, and binds grant references and digests.
 */

import { describe, expect, it } from "@jest/globals";

import {
  CREATE_ARTIFACT_KINDS,
  DISCOVERY_ARTIFACT_KINDS,
  resolveCreateDiscoveryArtifactToolInput,
  resolveLinkDiscoveryEvidenceToolInput,
  resolveUpdateDiscoveryArtifactToolInput,
} from "../src/mcp-tool-inputs-discovery";

const WS = "C:/ws";
const SHA = "a".repeat(64);
describe("resolveCreateDiscoveryArtifactToolInput", () => {
  it("normalizes a feature-contract draft with grant references", () => {
    expect(
      resolveCreateDiscoveryArtifactToolInput({
        workspace_root: WS,
        artifact_kind: "feature-contract",
        feature_id: "orders.export",
        name: "Order export",
        capability_group: "billing",
        input_path: "proposals/orders.yaml",
        invocation_ref: "invocation-alpha-0000000001",
        authorization_ref: "authz-alpha-000000000000001",
        write: true,
        dry_run: false,
      }),
    ).toEqual({
      workspaceRoot: WS,
      artifactKind: "feature-contract",
      featureId: "orders.export",
      name: "Order export",
      capabilityGroup: "billing",
      inputPath: "proposals/orders.yaml",
      invocationRef: "invocation-alpha-0000000001",
      authorizationRef: "authz-alpha-000000000000001",
      write: true,
      dryRun: false,
    });
    expect([...CREATE_ARTIFACT_KINDS]).toEqual([
      "feature-contract",
      "runtime-scenario",
    ]);
  });

  it("normalizes a runtime-scenario draft", () => {
    expect(
      resolveCreateDiscoveryArtifactToolInput({
        workspace_root: WS,
        artifact_kind: "runtime-scenario",
        scenario_id: "orders.export.happy",
        feature_ids: ["orders.export"],
      }),
    ).toEqual({
      workspaceRoot: WS,
      artifactKind: "runtime-scenario",
      scenarioId: "orders.export.happy",
      featureIds: ["orders.export"],
    });
  });

  it.each([
    ["unknown kind", { artifact_kind: "scope" }, /artifact kind/],
    [
      "contract missing feature_id",
      { artifact_kind: "feature-contract", name: "x" },
      /feature_id/,
    ],
    [
      "contract with scenario fields",
      {
        artifact_kind: "feature-contract",
        feature_id: "f",
        name: "n",
        scenario_id: "s",
      },
      /runtime-scenario/,
    ],
    [
      "scenario missing feature_ids",
      { artifact_kind: "runtime-scenario", scenario_id: "s" },
      /feature_ids/,
    ],
    [
      "scenario with contract fields",
      {
        artifact_kind: "runtime-scenario",
        scenario_id: "s",
        feature_ids: ["f"],
        name: "n",
      },
      /feature-contract/,
    ],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveCreateDiscoveryArtifactToolInput({ workspace_root: WS, ...args }),
    ).toThrow(pattern);
  });
});

describe("resolveUpdateDiscoveryArtifactToolInput", () => {
  it("normalizes a compare-and-swap replacement with a null baseline", () => {
    expect(
      resolveUpdateDiscoveryArtifactToolInput({
        workspace_root: WS,
        artifact_kind: "feature-contract",
        artifact_path: "docs/fc.yaml",
        input_path: "proposals/fc.yaml",
        expected_sha256: null,
        update_action: "replace",
        dry_run: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      artifactKind: "feature-contract",
      artifactPath: "docs/fc.yaml",
      inputPath: "proposals/fc.yaml",
      expectedSha256: null,
      updateAction: "replace",
      dryRun: true,
    });
    expect(DISCOVERY_ARTIFACT_KINDS).toHaveLength(16);
  });

  it("normalizes a decision approval with its identity and evidence", () => {
    expect(
      resolveUpdateDiscoveryArtifactToolInput({
        workspace_root: WS,
        artifact_kind: "product-decision",
        artifact_path: "docs/pd.yaml",
        input_path: "proposals/pd.yaml",
        expected_sha256: SHA,
        update_action: "approve-decision",
        artifact_id: "decision.one",
        approval_owner: "owner.alpha",
        approval_evidence_refs: ["evidence.one"],
      }),
    ).toMatchObject({
      expectedSha256: SHA,
      updateAction: "approve-decision",
      artifactId: "decision.one",
      approvalOwner: "owner.alpha",
      approvalEvidenceRefs: ["evidence.one"],
    });
  });

  it.each([
    [
      "missing expected_sha256",
      { update_action: "replace" },
      /expected_sha256/,
    ],
    [
      "uppercase digest",
      { expected_sha256: SHA.toUpperCase(), update_action: "replace" },
      /expected_sha256/,
    ],
    [
      "unknown kind",
      {
        expected_sha256: null,
        update_action: "replace",
        artifact_kind: "shell",
      },
      /artifact kind/,
    ],
    [
      "unknown action",
      { expected_sha256: null, update_action: "patch" },
      /update action/,
    ],
  ])("rejects %s", (_label, args, pattern) => {
    expect(() =>
      resolveUpdateDiscoveryArtifactToolInput({
        workspace_root: WS,
        artifact_kind: "feature-contract",
        artifact_path: "docs/fc.yaml",
        input_path: "proposals/fc.yaml",
        ...args,
      }),
    ).toThrow(pattern);
  });
});

describe("resolveLinkDiscoveryEvidenceToolInput", () => {
  it("normalizes an evidence link bound to the target digest", () => {
    expect(
      resolveLinkDiscoveryEvidenceToolInput({
        workspace_root: WS,
        artifact_kind: "runtime-characterization-scenario",
        artifact_id: "scenario.one",
        evidence_path: "evidence/run.json",
        expected_sha256: SHA,
        write: true,
      }),
    ).toEqual({
      workspaceRoot: WS,
      artifactKind: "runtime-characterization-scenario",
      artifactId: "scenario.one",
      evidencePath: "evidence/run.json",
      expectedSha256: SHA,
      write: true,
    });
  });

  it("requires a real target digest", () => {
    expect(() =>
      resolveLinkDiscoveryEvidenceToolInput({
        workspace_root: WS,
        artifact_kind: "feature-contract",
        artifact_id: "f",
        evidence_path: "e.json",
        expected_sha256: null,
      }),
    ).toThrow(/expected_sha256/);
  });
});
