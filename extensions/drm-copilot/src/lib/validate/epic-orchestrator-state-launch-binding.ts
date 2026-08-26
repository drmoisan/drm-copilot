/** Validate durable launch binding evidence for epic execution children. */

const LAUNCH_ARTIFACT_PARTS = [
  "artifacts",
  "orchestration",
  "epic-child-launches",
] as const;
const GENERATED_ORCHESTRATOR_AGENTS = new Set([
  "orchestrator-c1",
  "orchestrator-c2",
  "orchestrator-c3",
  "orchestrator-c3-elevated",
  "orchestrator-c4",
]);

/** Options that activate launch-binding validation. */
export interface EpicChildLaunchBindingOptions {
  readonly requireComplete?: boolean;
  readonly requireCodexModelRouting?: boolean;
  readonly requireCodexTopology?: boolean;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isNonEmptyString(value: unknown): value is string {
  return (
    typeof value === "string" && value.trim() !== "" && value === value.trim()
  );
}

function validPathSegments(value: string, separator: string): boolean {
  return value
    .split(separator)
    .every((part) => part !== "" && part !== "." && part !== "..");
}

function isCanonicalWorktreePath(value: unknown): boolean {
  if (!isNonEmptyString(value) || value.includes("\0")) {
    return false;
  }
  if (value.startsWith("/")) {
    if (value.includes("\\") || value === "/") {
      return !value.includes("\\");
    }
    const leadingLength = value.startsWith("//") ? 2 : 1;
    return validPathSegments(value.slice(leadingLength), "/");
  }
  if (value.includes("/")) {
    return false;
  }
  if (/^[A-Za-z]:\\/.test(value)) {
    return value.length === 3 || validPathSegments(value.slice(3), "\\");
  }
  if (value.startsWith("\\\\")) {
    const parts = value.slice(2).split("\\");
    return parts.length >= 2 && validPathSegments(value.slice(2), "\\");
  }
  return false;
}

function isLaunchArtifactPath(value: unknown): boolean {
  if (!isNonEmptyString(value) || value.includes("\0")) {
    return false;
  }
  const normalized = value.replaceAll("\\", "/");
  const rawParts = normalized.split("/");
  if (rawParts.some((part) => part === "." || part === "..")) {
    return false;
  }
  const parts = rawParts.filter((part) => part !== "");
  let markerIndex = -1;
  for (
    let index = 0;
    index <= parts.length - LAUNCH_ARTIFACT_PARTS.length;
    index += 1
  ) {
    if (
      LAUNCH_ARTIFACT_PARTS.every(
        (part, offset) => parts[index + offset] === part,
      )
    ) {
      markerIndex = index;
      break;
    }
  }
  if (
    markerIndex < 0 ||
    markerIndex + LAUNCH_ARTIFACT_PARTS.length >= parts.length
  ) {
    return false;
  }
  const absolute =
    normalized.startsWith("/") || /^[A-Za-z]:\//.test(normalized);
  return markerIndex === 0 || absolute;
}

function featurePrefix(feature: Record<string, unknown>): string {
  const folder = feature["feature_folder"];
  const label =
    typeof folder === "string" && folder !== "" ? folder : "<unknown>";
  return `Epic checkpoint feature '${label}' launch binding`;
}

function validateBranchAndPaths(
  feature: Record<string, unknown>,
  prefix: string,
  seenBranches: Set<string>,
): string[] {
  const errors: string[] = [];
  const branch = feature["branch_name"];
  if (!isNonEmptyString(branch) || seenBranches.has(branch)) {
    errors.push(`${prefix}.branch_name must be a non-empty unique string.`);
  } else {
    seenBranches.add(branch);
  }
  if (!isCanonicalWorktreePath(feature["worktree_path"])) {
    errors.push(
      `${prefix}.worktree_path must be a non-empty canonical absolute path.`,
    );
  }
  for (const key of ["launch_receipt_path", "launch_status_path"] as const) {
    if (!isLaunchArtifactPath(feature[key])) {
      errors.push(
        `${prefix}.${key} must be under artifacts/orchestration/epic-child-launches/.`,
      );
    }
  }
  return errors;
}

interface DelegationValidation {
  readonly errors: string[];
  readonly delegationId?: string;
  readonly deploymentAgent?: string;
}

function validateDelegationReceipt(
  feature: Record<string, unknown>,
  prefix: string,
  seenDelegationIds: Set<string>,
  requireGeneratedOrchestrator = false,
): DelegationValidation {
  const value = feature["delegation_receipt"];
  if (!isObject(value)) {
    return { errors: [`${prefix}.delegation_receipt must be an object.`] };
  }
  const errors: string[] = [];
  const delegationId = value["delegation_id"];
  const validId = isNonEmptyString(delegationId) ? delegationId : undefined;
  if (validId === undefined || seenDelegationIds.has(validId)) {
    errors.push(
      `${prefix}.delegation_receipt.delegation_id must be a non-empty unique string.`,
    );
  } else {
    seenDelegationIds.add(validId);
  }
  if (value["feature_folder"] !== feature["feature_folder"]) {
    errors.push(
      `${prefix}.delegation_receipt.feature_folder must match the feature.`,
    );
  }
  if (
    !("issue_num" in feature) ||
    !("issue_num" in value) ||
    value["issue_num"] !== feature["issue_num"]
  ) {
    errors.push(
      `${prefix}.delegation_receipt.issue_num must match the feature.`,
    );
  }
  const agentName = value["agent_name"];
  const validAgent = isNonEmptyString(agentName) ? agentName : undefined;
  if (validAgent === undefined) {
    errors.push(
      `${prefix}.delegation_receipt.agent_name must be a non-empty string.`,
    );
  } else if (
    requireGeneratedOrchestrator &&
    !GENERATED_ORCHESTRATOR_AGENTS.has(validAgent)
  ) {
    errors.push(
      `${prefix}.delegation_receipt.agent_name must name a generated orchestrator agent.`,
    );
  }
  return {
    errors,
    ...(validId === undefined ? {} : { delegationId: validId }),
    ...(validAgent === undefined ? {} : { deploymentAgent: validAgent }),
  };
}

function validateModelReceipt(
  feature: Record<string, unknown>,
  prefix: string,
  delegation: DelegationValidation,
  expectedExecutionContext = "epic_execution_child",
): string[] {
  const value = feature["model_routing_receipt"];
  if (!isObject(value)) {
    return [`${prefix}.model_routing_receipt must be an object.`];
  }
  const errors: string[] = [];
  if (
    delegation.delegationId !== undefined &&
    value["delegation_id"] !== delegation.delegationId
  ) {
    errors.push(
      `${prefix}.model_routing_receipt.delegation_id must match delegation_receipt.delegation_id.`,
    );
  }
  const modelAgent = value["deployment_agent"];
  if (!isNonEmptyString(modelAgent)) {
    errors.push(
      `${prefix}.model_routing_receipt.deployment_agent must be a non-empty string.`,
    );
  } else if (
    delegation.deploymentAgent !== undefined &&
    modelAgent !== delegation.deploymentAgent
  ) {
    errors.push(
      `${prefix}.model_routing_receipt.deployment_agent must match delegation_receipt.agent_name.`,
    );
  }
  if (value["execution_context"] !== expectedExecutionContext) {
    errors.push(
      `${prefix}.model_routing_receipt.execution_context must be '${expectedExecutionContext}'.`,
    );
  }
  return errors;
}

/** Return whether the feature records either launch path key. */
function featureCarriesLaunchPath(feature: Record<string, unknown>): boolean {
  return "launch_receipt_path" in feature || "launch_status_path" in feature;
}

interface LaunchBindingContext {
  readonly expectedExecutionContext: string;
  readonly planner: boolean;
  readonly requireGeneratedOrchestrator: boolean;
  readonly skipNotStarted: boolean;
  readonly requireLaunchPaths: boolean;
}

function validateLaunchBindings(
  features: readonly unknown[],
  context: LaunchBindingContext,
): string[] {
  const errors: string[] = [];
  const seenBranches = new Set<string>();
  const seenDelegationIds = new Set<string>();
  features.forEach((item, index) => {
    if (!isObject(item)) {
      return;
    }
    if (context.skipNotStarted && item["merge_status"] === "not_started") {
      return;
    }
    if (context.requireLaunchPaths && !featureCarriesLaunchPath(item)) {
      return;
    }
    const prefix = context.planner
      ? `Epic planner checkpoint features[${index}] launch binding`
      : featurePrefix(item);
    errors.push(...validateBranchAndPaths(item, prefix, seenBranches));
    const delegation = validateDelegationReceipt(
      item,
      prefix,
      seenDelegationIds,
      context.requireGeneratedOrchestrator,
    );
    errors.push(...delegation.errors);
    errors.push(
      ...validateModelReceipt(
        item,
        prefix,
        delegation,
        context.expectedExecutionContext,
      ),
    );
  });
  return errors;
}

/** Require durable preparation-child launch evidence for every feature. */
export function validateEpicPlannerChildLaunchBindings(
  features: ReadonlyArray<Record<string, unknown>>,
): string[] {
  return validateLaunchBindings(features, {
    expectedExecutionContext: "epic_preparation_child",
    planner: true,
    requireGeneratedOrchestrator: true,
    skipNotStarted: false,
    requireLaunchPaths: false,
  });
}

/** Validate launch evidence when routing gates or completion are required. */
export function validateEpicChildLaunchBindings(
  state: Record<string, unknown>,
  options: EpicChildLaunchBindingOptions = {},
): string[] {
  if (
    options.requireCodexModelRouting !== true &&
    options.requireCodexTopology !== true &&
    options.requireComplete !== true
  ) {
    return [];
  }
  const value = state["features"];
  if (!Array.isArray(value)) {
    return [];
  }
  return validateLaunchBindings(value, {
    expectedExecutionContext: "epic_execution_child",
    planner: false,
    requireGeneratedOrchestrator: false,
    skipNotStarted: options.requireComplete !== true,
    requireLaunchPaths:
      options.requireCodexModelRouting !== true &&
      options.requireCodexTopology !== true,
  });
}
