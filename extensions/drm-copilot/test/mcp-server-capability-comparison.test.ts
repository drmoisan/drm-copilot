import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({ window: {} }), { virtual: true });

import {
  compareValidatorCapabilities,
  VALIDATOR_CAPABILITY_COMPARISON_CODES,
  type ValidatorCapabilityComparisonInput,
} from "../src/mcp-server";

const REQUIREMENTS = {
  validatorContractVersion: 1,
  remediationLoopSchemaVersion: 2,
  requiredValidationFlags: ["require_pr_creation_ready"],
  requiredArtifactTypes: ["orchestrator-state"],
  packageVersion: "1.0.24",
  bundleSha256: `sha256:${"1".repeat(64)}`,
  routingPolicySha256: `sha256:${"2".repeat(64)}`,
} as const;

const VALID_CAPABILITY = {
  validator_contract_version: 1,
  remediation_loop_schema_versions: [2],
  supported_validation_flags: ["require_pr_creation_ready"],
  supported_artifact_types: ["orchestrator-state"],
  package_version: "1.0.24",
  bundle_sha256: `sha256:${"1".repeat(64)}`,
  routing_policy_sha256: `sha256:${"2".repeat(64)}`,
} as const;

function compare(overrides: Partial<ValidatorCapabilityComparisonInput> = {}) {
  return compareValidatorCapabilities({
    serverInfoVersion: "1.0.24",
    capability: VALID_CAPABILITY,
    requirements: REQUIREMENTS,
    ...overrides,
  });
}

describe("validator capability comparison", () => {
  it("accepts compatible metadata", () => {
    expect(compare()).toEqual([]);
  });

  it("returns the missing-capability code when metadata is absent", () => {
    expect(compare({ capability: undefined })).toEqual([
      VALIDATOR_CAPABILITY_COMPARISON_CODES.missing,
    ]);
  });

  it("returns every mismatch code once in deterministic contract order", () => {
    expect(
      compare({
        serverInfoVersion: "9.9.9",
        capability: {
          validator_contract_version: 9,
          remediation_loop_schema_versions: [1],
          supported_validation_flags: [],
          supported_artifact_types: [],
          package_version: "9.9.9",
          bundle_sha256: `sha256:${"3".repeat(64)}`,
          routing_policy_sha256: `sha256:${"4".repeat(64)}`,
        },
      }),
    ).toEqual([
      VALIDATOR_CAPABILITY_COMPARISON_CODES.contract,
      VALIDATOR_CAPABILITY_COMPARISON_CODES.schema,
      VALIDATOR_CAPABILITY_COMPARISON_CODES.flag,
      VALIDATOR_CAPABILITY_COMPARISON_CODES.artifact,
      VALIDATOR_CAPABILITY_COMPARISON_CODES.package,
      VALIDATOR_CAPABILITY_COMPARISON_CODES.bundle,
      VALIDATOR_CAPABILITY_COMPARISON_CODES.routing,
    ]);
  });
});
