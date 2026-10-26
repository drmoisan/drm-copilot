import {
  normalizeOptionalText,
  normalizeRequiredText,
  validateChoice,
} from "./workflow-command-arguments";
import { asToolArgumentObject } from "./mcp-tool-inputs";
import {
  compact,
  normalizeOptionalBoolean,
  normalizeOptionalChoice,
  normalizeOptionalInteger,
  normalizeOptionalStringList,
  normalizeRequiredStringList,
  resolveDiscoveryWorkspaceInput,
  SYSTEM_ROLES,
} from "./mcp-tool-inputs-discovery";
import {
  COMPLEXITY_BANDS as ROUTING_COMPLEXITY_BANDS,
  DISCOVERY_ROLES,
  DISCOVERY_SKILL_IDS,
  EXECUTION_CONTEXTS as ROUTING_EXECUTION_CONTEXTS,
} from "./discovery-routing";
import type { RepoAutomationToolName } from "./repo-automation-tool-names";
import type {
  ConfigureDiscoveryWorkspaceInput,
  FinalizeDiscoveryAgentInput,
  ImportDiscoveryInventoryInput,
  MigrateDiscoveryArtifactsInput,
  PrepareDiscoveryAgentInput,
  ReadDiscoverySourceInput,
  RunDiscoveryDoctorInput,
  TransferDiscoverySnapshotInput,
} from "./repo-automation-service-discovery-types";

/**
 * Enum constants, role-denial policy and input resolvers for the root-authority
 * and agent-lifecycle discovery tools (configure, transfer, import, migrate,
 * doctor, read, prepare, finalize).
 *
 * Root-only tools are refused at dispatch when the service reports a discovery
 * role context; the diagnostic `run_discovery_doctor` and the bounded
 * `read_discovery_source` remain available to roles.
 */
export const CONFIGURATION_ACTIONS = ["activate", "deactivate"] as const;
export const TRANSFER_DIRECTIONS = ["export", "import"] as const;
export const READ_OPERATIONS = ["list", "read", "search"] as const;
export const SKILL_IDS: ReadonlyArray<string> = DISCOVERY_SKILL_IDS;
export const EXECUTION_CONTEXTS: ReadonlyArray<string> =
  ROUTING_EXECUTION_CONTEXTS;
export const COMPLEXITY_BANDS: ReadonlyArray<string> = ROUTING_COMPLEXITY_BANDS;

/** Tools that only the local-user root principal may invoke. */
export const ROOT_ONLY_DISCOVERY_TOOLS: ReadonlyArray<RepoAutomationToolName> =
  [
    "run_discovery_init",
    "configure_discovery_workspace",
    "transfer_discovery_snapshot",
    "import_discovery_inventory",
    "migrate_discovery_artifacts",
    "prepare_discovery_agent",
  ];

export function isRootOnlyDiscoveryTool(tool: RepoAutomationToolName): boolean {
  return ROOT_ONLY_DISCOVERY_TOOLS.includes(tool);
}

export function isDiscoveryRole(
  role: string | null | undefined,
): role is string {
  return typeof role === "string" && DISCOVERY_ROLES.includes(role);
}

/** Message for a root-only tool invoked by a discovery role. */
export function discoveryRoleDeniedMessage(
  tool: RepoAutomationToolName,
  role: string,
): string {
  return `DISCOVERY_ROLE_DENIED: ${tool} is a root-only operation and is not available to the ${role} role.`;
}

export function resolveConfigureDiscoveryWorkspaceToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ConfigureDiscoveryWorkspaceInput {
  const args = asToolArgumentObject(rawInput);
  const configurationAction = validateChoice(
    normalizeRequiredText(args["configuration_action"], "configuration_action"),
    "configuration_action",
    CONFIGURATION_ACTIONS,
  );
  const inputPath = normalizeOptionalText(args["input_path"], "input_path");
  // Deactivation never selects a profile; activation needs one or the default.
  if (configurationAction === "deactivate" && inputPath !== undefined) {
    throw new Error("Field 'input_path' is not accepted for deactivate.");
  }
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    configurationAction,
    inputPath,
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
  });
}

export function resolveTransferDiscoverySnapshotToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): TransferDiscoverySnapshotInput {
  const args = asToolArgumentObject(rawInput);
  const direction = validateChoice(
    normalizeRequiredText(args["direction"], "direction"),
    "direction",
    TRANSFER_DIRECTIONS,
  );
  const base = {
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    direction,
    write: normalizeOptionalBoolean(args["write"], "write"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
  };
  // Export selects identities; import names a manifest. Mixing is refused.
  if (direction === "export") {
    if (args["manifest_path"] !== undefined) {
      throw new Error("Field 'manifest_path' applies only to import.");
    }
    const selectedIds = normalizeRequiredStringList(
      args["selected_ids"],
      "selected_ids",
    );
    if (selectedIds.length === 0) {
      throw new Error("Snapshot export requires at least one selected id.");
    }
    return compact({
      ...base,
      selectedIds,
      paths: normalizeOptionalStringList(args["paths"], "paths"),
    });
  }
  if (args["selected_ids"] !== undefined || args["paths"] !== undefined) {
    throw new Error("Fields 'selected_ids' and 'paths' apply only to export.");
  }
  return compact({
    ...base,
    manifestPath: normalizeRequiredText(args["manifest_path"], "manifest_path"),
  });
}

export function resolveImportDiscoveryInventoryToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ImportDiscoveryInventoryInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    manifestPath: normalizeRequiredText(args["manifest_path"], "manifest_path"),
    write: normalizeOptionalBoolean(args["write"], "write"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
  });
}

export function resolveMigrateDiscoveryArtifactsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): MigrateDiscoveryArtifactsInput {
  const args = asToolArgumentObject(rawInput);
  const inputPath = normalizeOptionalText(args["input_path"], "input_path");
  const paths = normalizeOptionalStringList(args["paths"], "paths");
  // Exactly one source selection is accepted, matching the runtime rule.
  if ((inputPath === undefined) === (paths === undefined)) {
    throw new Error(
      "Migration requires exactly one of 'input_path' or 'paths' as the source selection.",
    );
  }
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    destination: normalizeRequiredText(args["destination"], "destination"),
    systemId: normalizeRequiredText(args["system_id"], "system_id"),
    systemName: normalizeRequiredText(args["system_name"], "system_name"),
    systemRole: validateChoice(
      normalizeRequiredText(args["system_role"], "system_role"),
      "system_role",
      SYSTEM_ROLES,
    ),
    repositoryId: normalizeRequiredText(args["repository_id"], "repository_id"),
    inputPath,
    paths,
    productionRoots: normalizeOptionalStringList(
      args["production_roots"],
      "production_roots",
    ),
    testRoots: normalizeOptionalStringList(args["test_roots"], "test_roots"),
    draft: normalizeOptionalBoolean(args["draft"], "draft"),
    write: normalizeOptionalBoolean(args["write"], "write"),
    dryRun: normalizeOptionalBoolean(args["dry_run"], "dry_run"),
  });
}

export function resolveRunDiscoveryDoctorToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryDoctorInput {
  return resolveDiscoveryWorkspaceInput(
    asToolArgumentObject(rawInput),
    fallbackWorkspaceRoot,
  );
}

export function resolveReadDiscoverySourceToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ReadDiscoverySourceInput {
  const args = asToolArgumentObject(rawInput);
  const readOperation = validateChoice(
    normalizeRequiredText(args["read_operation"], "read_operation"),
    "read_operation",
    READ_OPERATIONS,
  );
  const query = normalizeOptionalText(args["query"], "query");
  const regex = normalizeOptionalBoolean(args["regex"], "regex");
  const lineStart = normalizeOptionalInteger(args["line_start"], "line_start");
  const lineEnd = normalizeOptionalInteger(args["line_end"], "line_end");
  // Search fields belong to search; line selection belongs to read.
  if (readOperation === "search" && query === undefined) {
    throw new Error("Source search requires 'query'.");
  }
  if (
    readOperation !== "search" &&
    (query !== undefined || regex !== undefined)
  ) {
    throw new Error("Fields 'query' and 'regex' apply only to search.");
  }
  if (
    readOperation !== "read" &&
    (lineStart !== undefined || lineEnd !== undefined)
  ) {
    throw new Error("Fields 'line_start' and 'line_end' apply only to read.");
  }
  if (lineStart !== undefined && lineEnd !== undefined && lineStart > lineEnd) {
    throw new Error("Field 'line_start' must not exceed 'line_end'.");
  }
  const invocationRef = normalizeOptionalText(
    args["invocation_ref"],
    "invocation_ref",
  );
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    readOperation,
    paths: normalizeRequiredStringList(args["paths"], "paths"),
    query,
    regex,
    maxBytes: normalizeOptionalInteger(args["max_bytes"], "max_bytes"),
    lineStart,
    lineEnd,
    invocationRef,
    authorizationRef: normalizeOptionalText(
      args["authorization_ref"],
      "authorization_ref",
    ),
    mode: invocationRef === undefined ? undefined : ("agent-output" as const),
  });
}

export function resolvePrepareDiscoveryAgentToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PrepareDiscoveryAgentInput {
  const args = asToolArgumentObject(rawInput);
  const expectedOutputs = args["expected_outputs"];
  if (
    !Array.isArray(expectedOutputs) ||
    expectedOutputs.length === 0 ||
    expectedOutputs.some(
      (row) => row === null || typeof row !== "object" || Array.isArray(row),
    )
  ) {
    throw new Error(
      "Field 'expected_outputs' must be a non-empty array of output rows.",
    );
  }
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    skillId: validateChoice(
      normalizeRequiredText(args["skill_id"], "skill_id"),
      "skill_id",
      SKILL_IDS,
    ),
    selectedIds: normalizeRequiredStringList(
      args["selected_ids"],
      "selected_ids",
    ),
    paths: normalizeRequiredStringList(args["paths"], "paths"),
    expectedOutputs: expectedOutputs as ReadonlyArray<Record<string, unknown>>,
    executionContext: validateChoice(
      normalizeRequiredText(args["execution_context"], "execution_context"),
      "execution_context",
      EXECUTION_CONTEXTS,
    ),
    complexity: validateChoice(
      normalizeRequiredText(args["complexity"], "complexity"),
      "complexity",
      COMPLEXITY_BANDS,
    ),
    orchestrationComplexityCeiling: normalizeOptionalChoice(
      args["orchestration_complexity_ceiling"],
      "orchestration_complexity_ceiling",
      COMPLEXITY_BANDS,
    ),
  });
}

export function resolveFinalizeDiscoveryAgentToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): FinalizeDiscoveryAgentInput {
  const args = asToolArgumentObject(rawInput);
  return compact({
    ...resolveDiscoveryWorkspaceInput(args, fallbackWorkspaceRoot),
    invocationRef: normalizeRequiredText(
      args["invocation_ref"],
      "invocation_ref",
    ),
    requestId: normalizeRequiredText(args["request_id"], "request_id"),
    authorizationRef: normalizeOptionalText(
      args["authorization_ref"],
      "authorization_ref",
    ),
  });
}
