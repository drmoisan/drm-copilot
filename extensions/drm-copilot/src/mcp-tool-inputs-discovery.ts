import {
  normalizeOptionalText,
  normalizeRequiredText,
  validateChoice,
} from "./workflow-command-arguments";
import { asToolArgumentObject } from "./mcp-tool-inputs";
import type {
  RunDiscoveryAnalyzerInput,
  RunDiscoveryInitInput,
  RunDiscoveryReportInput,
  RunDiscoveryScenarioGenerationInput,
  ValidateDiscoveryArtifactsInput,
} from "./repo-automation-execute-discovery";
import type {
  CreateDiscoveryArtifactInput,
  LinkDiscoveryEvidenceInput,
  UpdateDiscoveryArtifactInput,
} from "./repo-automation-service-discovery-types";

/**
 * Enum constants and input resolvers for the workspace-level discovery tools.
 *
 * Every literal that a tool schema advertises lives here (or in the authority
 * resolver module) so the schema enums and the resolver enums cannot drift.
 * Resolvers normalize raw MCP arguments into the v2 service inputs; they add
 * no defaults the service does not own, and the retired positional-CLI fields
 * are passed through unchanged so the operation adapter rejects them with its
 * explicit message until the command layer is reworked.
 */
export const DISCOVERY_ARTIFACT_TYPES = [
  "profile",
  "feature-contract",
  "coverage-ledger",
  "runtime-scenario",
  "parity-matrix",
  "unspecified-behavior",
  "product-decision",
  "evidence-reference",
  "all",
] as const;

export const DISCOVERY_REPORT_TYPES = [
  "coverage",
  "parity",
  "completion",
] as const;

export const DISCOVERY_MODES = [
  "structural",
  "agent-output",
  "discovery-complete",
  "parity-complete",
  "planning",
] as const;

export const DISCOVERY_OUTPUT_FORMATS = [
  "markdown",
  "gherkin",
  "both",
] as const;
export const REPORT_FORMATS = ["json", "markdown", "both"] as const;
export const SYSTEM_ROLES = [
  "legacy-source",
  "modernization-target",
  "combined",
] as const;
export const ACCEPTANCE_KINDS = [
  "legacy-characterization",
  "target-acceptance",
] as const;
export const CREATE_ARTIFACT_KINDS = [
  "feature-contract",
  "runtime-scenario",
] as const;
export const UPDATE_ACTIONS = ["replace", "approve-decision"] as const;
/** `common#/$defs/artifact-kind`. */
export const DISCOVERY_ARTIFACT_KINDS = [
  "domain-profile",
  "scope",
  "feature-contract",
  "coverage-ledger",
  "runtime-characterization-scenario",
  "parity-matrix",
  "unspecified-behavior",
  "product-decision",
  "evidence-reference",
  "inventory-snapshot",
  "acceptance-specification",
  "source-snapshot-manifest",
  "implementation-record",
  "unspecified-behavior-collection",
  "product-decision-collection",
  "extension-result-manifest",
] as const;

export type DiscoveryArtifactType = (typeof DISCOVERY_ARTIFACT_TYPES)[number];
export type DiscoveryReportType = (typeof DISCOVERY_REPORT_TYPES)[number];

import {
  compact,
  normalizeOptionalBoolean,
  normalizeOptionalChoice,
  normalizeOptionalStringList,
  normalizeRequiredStringList,
  resolveDiscoveryWorkspaceInput,
} from "./mcp-tool-inputs-discovery-shared";

export {
  compact,
  type Compacted,
  normalizeOptionalBoolean,
  normalizeOptionalChoice,
  normalizeOptionalInteger,
  normalizeOptionalStringList,
  normalizeRequiredStringList,
  resolveDiscoveryWorkspaceInput,
} from "./mcp-tool-inputs-discovery-shared";

export function resolveValidateDiscoveryArtifactsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ValidateDiscoveryArtifactsInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    artifactType: validateChoice(
      normalizeRequiredText(args["artifact_type"], "artifact_type"),
      "artifact_type",
      DISCOVERY_ARTIFACT_TYPES,
    ),
    artifactPath: normalizeRequiredText(args["artifact_path"], "artifact_path"),
    mode: normalizeOptionalChoice(args["mode"], "mode", DISCOVERY_MODES),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
  });
}

export function resolveRunDiscoveryInitToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryInitInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    systemId: normalizeOptionalText(args["system_id"], "system_id"),
    systemName: normalizeOptionalText(args["system_name"], "system_name"),
    systemRole: normalizeOptionalChoice(
      args["system_role"],
      "system_role",
      SYSTEM_ROLES,
    ),
    repositoryId: normalizeOptionalText(args["repository_id"], "repository_id"),
    productionRoots: normalizeOptionalStringList(
      args["production_roots"],
      "production_roots",
    ),
    testRoots: normalizeOptionalStringList(args["test_roots"], "test_roots"),
    draft: normalizeOptionalBoolean(args["draft"], "draft"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
    // Retired positional fields pass through so the adapter rejects them explicitly.
    targetDir: normalizeOptionalText(args["target_dir"], "target_dir"),
    templateRoot: normalizeOptionalText(args["template_root"], "template_root"),
    force: normalizeOptionalBoolean(args["force"], "force"),
  });
}

function resolveDiscoveryAnalyzerToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot: string | undefined,
  allowAnalyzerIds: boolean,
): RunDiscoveryAnalyzerInput {
  const args = asToolArgumentObject(rawInput);
  if (!allowAnalyzerIds && args["analyzer_ids"] !== undefined) {
    throw new Error(
      "Field 'analyzer_ids' is fixed for the stack analyzer tools; use run_discovery_repo_inventory for an explicit selection.",
    );
  }
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    analyzerIds: allowAnalyzerIds
      ? normalizeOptionalStringList(args["analyzer_ids"], "analyzer_ids")
      : undefined,
    write: normalizeOptionalBoolean(args["write"], "write"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
    outputDir: normalizeOptionalText(args["output_dir"], "output_dir"),
  });
}

export function resolveRunDiscoveryRepoInventoryToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  return resolveDiscoveryAnalyzerToolInput(
    rawInput,
    fallbackWorkspaceRoot,
    true,
  );
}

export function resolveRunDiscoveryDotnetAnalyzerToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  return resolveDiscoveryAnalyzerToolInput(
    rawInput,
    fallbackWorkspaceRoot,
    false,
  );
}

export function resolveRunDiscoveryVstoAnalyzerToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  return resolveDiscoveryAnalyzerToolInput(
    rawInput,
    fallbackWorkspaceRoot,
    false,
  );
}

export function resolveRunDiscoveryScenarioGenerationToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryScenarioGenerationInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    acceptanceKind: normalizeOptionalChoice(
      args["acceptance_kind"],
      "acceptance_kind",
      ACCEPTANCE_KINDS,
    ),
    featureIds: normalizeOptionalStringList(args["feature_ids"], "feature_ids"),
    clientIds: normalizeOptionalStringList(args["client_ids"], "client_ids"),
    modeIds: normalizeOptionalStringList(args["mode_ids"], "mode_ids"),
    platformIds: normalizeOptionalStringList(
      args["platform_ids"],
      "platform_ids",
    ),
    outputFormat: normalizeOptionalChoice(
      args["output_format"],
      "output_format",
      DISCOVERY_OUTPUT_FORMATS,
    ),
    write: normalizeOptionalBoolean(args["write"], "write"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
    // Retired positional fields pass through so the adapter rejects them explicitly.
    featureContract: normalizeOptionalText(
      args["feature_contract"],
      "feature_contract",
    ),
    parityMatrix: normalizeOptionalText(args["parity_matrix"], "parity_matrix"),
    runtimeCharacterization: normalizeOptionalText(
      args["runtime_characterization"],
      "runtime_characterization",
    ),
    outputPath: normalizeOptionalText(args["output_path"], "output_path"),
    check: normalizeOptionalBoolean(args["check"], "check"),
  });
}

export function resolveRunDiscoveryReportToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryReportInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    reportType: validateChoice(
      normalizeRequiredText(args["report_type"], "report_type"),
      "report_type",
      DISCOVERY_REPORT_TYPES,
    ),
    mode: normalizeOptionalChoice(args["mode"], "mode", DISCOVERY_MODES),
    format: normalizeOptionalChoice(args["format"], "format", REPORT_FORMATS),
    write: normalizeOptionalBoolean(args["write"], "write"),
    // Retired positional fields pass through so the adapter rejects them explicitly.
    inputPath: normalizeOptionalText(args["input_path"], "input_path"),
    coverageInput: normalizeOptionalText(
      args["coverage_input"],
      "coverage_input",
    ),
    parityInput: normalizeOptionalText(args["parity_input"], "parity_input"),
    outputPath: normalizeOptionalText(args["output_path"], "output_path"),
  });
}

/** Resolve the grant references and publication flags shared by mutations. */
function resolveGrantedFields(args: Readonly<Record<string, unknown>>) {
  return {
    invocationRef: normalizeOptionalText(
      args["invocation_ref"],
      "invocation_ref",
    ),
    authorizationRef: normalizeOptionalText(
      args["authorization_ref"],
      "authorization_ref",
    ),
    write: normalizeOptionalBoolean(args["write"], "write"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
  };
}

export function resolveCreateDiscoveryArtifactToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): CreateDiscoveryArtifactInput {
  const args = asToolArgumentObject(rawInput);
  const artifactKind = validateChoice(
    normalizeRequiredText(args["artifact_kind"], "artifact_kind"),
    "artifact_kind",
    CREATE_ARTIFACT_KINDS,
  );
  // Each draft kind has its own required identity; the other kind's fields are refused.
  if (artifactKind === "feature-contract") {
    if (
      args["scenario_id"] !== undefined ||
      args["feature_ids"] !== undefined
    ) {
      throw new Error(
        "Fields 'scenario_id' and 'feature_ids' apply only to runtime-scenario drafts.",
      );
    }
    return compact({
      ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
      artifactKind,
      featureId: normalizeRequiredText(args["feature_id"], "feature_id"),
      name: normalizeRequiredText(args["name"], "name"),
      capabilityGroup: normalizeOptionalText(
        args["capability_group"],
        "capability_group",
      ),
      inputPath: normalizeOptionalText(args["input_path"], "input_path"),
      ...resolveGrantedFields(args),
    });
  }
  if (
    args["feature_id"] !== undefined ||
    args["name"] !== undefined ||
    args["capability_group"] !== undefined
  ) {
    throw new Error(
      "Fields 'feature_id', 'name' and 'capability_group' apply only to feature-contract drafts.",
    );
  }
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    artifactKind,
    scenarioId: normalizeRequiredText(args["scenario_id"], "scenario_id"),
    featureIds: normalizeRequiredStringList(args["feature_ids"], "feature_ids"),
    inputPath: normalizeOptionalText(args["input_path"], "input_path"),
    ...resolveGrantedFields(args),
  });
}

function normalizeExpectedSha256(
  value: unknown,
  nullable: boolean,
): string | null {
  if (value === null && nullable) {
    return null;
  }
  const text = normalizeRequiredText(value, "expected_sha256");
  if (!/^[0-9a-f]{64}$/u.test(text)) {
    throw new Error(
      "Field 'expected_sha256' must be a lowercase SHA-256 digest.",
    );
  }
  return text;
}

export function resolveUpdateDiscoveryArtifactToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): UpdateDiscoveryArtifactInput {
  const args = asToolArgumentObject(rawInput);
  if (!("expected_sha256" in args)) {
    throw new Error("Field 'expected_sha256' is required (a digest or null).");
  }
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    artifactKind: validateChoice(
      normalizeRequiredText(args["artifact_kind"], "artifact_kind"),
      "artifact_kind",
      DISCOVERY_ARTIFACT_KINDS,
    ),
    artifactPath: normalizeRequiredText(args["artifact_path"], "artifact_path"),
    inputPath: normalizeRequiredText(args["input_path"], "input_path"),
    expectedSha256: normalizeExpectedSha256(args["expected_sha256"], true),
    updateAction: validateChoice(
      normalizeRequiredText(args["update_action"], "update_action"),
      "update_action",
      UPDATE_ACTIONS,
    ),
    artifactId: normalizeOptionalText(args["artifact_id"], "artifact_id"),
    approvalOwner: normalizeOptionalText(
      args["approval_owner"],
      "approval_owner",
    ),
    approvalEvidenceRefs: normalizeOptionalStringList(
      args["approval_evidence_refs"],
      "approval_evidence_refs",
    ),
    ...resolveGrantedFields(args),
  });
}

export function resolveLinkDiscoveryEvidenceToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): LinkDiscoveryEvidenceInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    artifactKind: validateChoice(
      normalizeRequiredText(args["artifact_kind"], "artifact_kind"),
      "artifact_kind",
      DISCOVERY_ARTIFACT_KINDS,
    ),
    artifactId: normalizeRequiredText(args["artifact_id"], "artifact_id"),
    evidencePath: normalizeRequiredText(args["evidence_path"], "evidence_path"),
    expectedSha256: normalizeExpectedSha256(
      args["expected_sha256"],
      false,
    ) as string,
    ...resolveGrantedFields(args),
  });
}
