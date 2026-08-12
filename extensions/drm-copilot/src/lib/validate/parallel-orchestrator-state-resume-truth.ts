/** Validate persisted live truth before a parallel child may resume. */

type JsonRecord = Record<string, unknown>;

const REASON_TRUTH_REQUIRED = "PARALLEL_RESUME_TRUTH_REQUIRED";
const REASON_TRUTH_INVALID = "PARALLEL_RESUME_TRUTH_INVALID";
const REASON_FAN_IN_FORBIDDEN = "PARALLEL_RESUME_FAN_IN_FORBIDDEN";
const REASON_ORDER_MISMATCH = "PARALLEL_RESUME_ORDER_MISMATCH";
const REASON_IDENTITY_DUPLICATE = "PARALLEL_RESUME_IDENTITY_DUPLICATE";
const REASON_GIT_MISMATCH = "PARALLEL_RESUME_GIT_MISMATCH";
const REASON_WORKTREE_MISMATCH = "PARALLEL_RESUME_WORKTREE_MISMATCH";
const REASON_GITHUB_MISMATCH = "PARALLEL_RESUME_GITHUB_MISMATCH";
const REASON_LAUNCH_MISMATCH = "PARALLEL_RESUME_LAUNCH_MISMATCH";
const REASON_MUTATION_MISMATCH = "PARALLEL_RESUME_MUTATION_MISMATCH";
const REASON_DRIFT_UNRESOLVED = "PARALLEL_RESUME_DRIFT_UNRESOLVED";
const REASON_ROUTING_MISMATCH = "PARALLEL_RESUME_ROUTING_MISMATCH";
const REASON_CHILD_STATUS_MISMATCH = "PARALLEL_RESUME_CHILD_STATUS_MISMATCH";
const REASON_PROCESS_RUNNING = "PARALLEL_RESUME_PROCESS_RUNNING";
const REASON_RELAUNCH_NOT_AUTHORIZED =
  "PARALLEL_RESUME_RELAUNCH_NOT_AUTHORIZED";

const TERMINAL_ITEM_STATES = new Set([
  "merged",
  "worktree_removed",
  "abandoned",
]);
const IDENTITY_FIELDS = [
  "launch_id",
  "worktree_path",
  "branch_name",
  "pr_number",
] as const;
const ROUTING_FIELDS = [
  "authority_receipt_path",
  "delegation_receipt_path",
  "topology_receipt_path",
  "model_routing_receipt_path",
  "deployment_agent",
  "model",
  "model_reasoning_effort",
  "permissions",
] as const;
const FORBIDDEN_KEYS = new Set([
  "integration_branch",
  "integration_pr",
  "integration_pr_url",
  "final_pr",
  "final_pr_url",
  "fan_in",
  "fan_in_pr",
  "fan_in_pr_url",
  "waves",
  "wave",
]);
const REQUIRED_TRUTH_FIELDS = new Set([
  "schema_version",
  "selected_issue_num",
  "repository",
  "origin_main_head",
  "worktree_path",
  "branch_name",
  "worktree_head",
  "pr_number",
  "pr_base_branch",
  "pr_head_branch",
  "pr_head_sha",
  "pr_state",
  "checks_head_sha",
  "checks_conclusion",
  "launch_id",
  "spec_sha256",
  "checkpoint_sha256",
  "latest_mutation_sequence",
  "recolor_generation",
  "drift_resolution_generation",
  "unresolved_drift",
  ...ROUTING_FIELDS,
  "child_status_path",
  "child_status_launch_id",
  "child_status_pid",
  "live_process_pid",
  "live_process_running",
  "should_relaunch",
]);

function asRecord(value: unknown): JsonRecord | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return undefined;
  }
  return value as JsonRecord;
}

function mappingItems(state: JsonRecord): JsonRecord[] {
  const value = state["items"];
  if (!Array.isArray(value)) {
    return [];
  }
  return value.flatMap((item) => {
    const record = asRecord(item);
    return record === undefined ? [] : [record];
  });
}

function positiveInteger(value: unknown): value is number {
  return typeof value === "number" && Number.isInteger(value) && value > 0;
}

function numberOrZero(value: unknown): number {
  return typeof value === "number" && Number.isInteger(value) ? value : 0;
}

function firstIncomplete(items: JsonRecord[]): JsonRecord | undefined {
  const candidates = items.filter(
    (item) => !TERMINAL_ITEM_STATES.has(String(item["state"])),
  );
  return candidates.reduce<JsonRecord | undefined>((first, item) => {
    if (first === undefined) {
      return item;
    }
    const left = ["cohort", "batch", "issue_num"].map((field) =>
      numberOrZero(item[field]),
    );
    const right = ["cohort", "batch", "issue_num"].map((field) =>
      numberOrZero(first[field]),
    );
    for (let index = 0; index < left.length; index += 1) {
      const leftValue = left[index] ?? 0;
      const rightValue = right[index] ?? 0;
      if (leftValue !== rightValue) {
        return leftValue < rightValue ? item : first;
      }
    }
    return first;
  }, undefined);
}

function containsForbiddenKey(value: unknown): boolean {
  if (Array.isArray(value)) {
    return value.some((entry) => containsForbiddenKey(entry));
  }
  const record = asRecord(value);
  if (record === undefined) {
    return false;
  }
  return (
    Object.keys(record).some((key) => FORBIDDEN_KEYS.has(key)) ||
    Object.values(record).some((entry) => containsForbiddenKey(entry))
  );
}

function hasDuplicateIdentity(items: JsonRecord[]): boolean {
  return IDENTITY_FIELDS.some((field) => {
    const values = items
      .filter(
        (item) =>
          item["state"] !== "withdrawn" &&
          item[field] !== null &&
          item[field] !== undefined &&
          item[field] !== "",
      )
      .map((item) => String(item[field]));
    return values.length !== new Set(values).size;
  });
}

function latestMutationSequence(state: JsonRecord): number {
  const mutations = state["mutations"];
  if (!Array.isArray(mutations)) {
    return 0;
  }
  return mutations.reduce((latest, entry) => {
    const sequence = asRecord(entry)?.["sequence"];
    return typeof sequence === "number" && Number.isInteger(sequence)
      ? Math.max(latest, sequence)
      : latest;
  }, 0);
}

function selectedItem(
  items: JsonRecord[],
  selectedIssue: unknown,
): JsonRecord | undefined {
  const matches = items.filter((item) => item["issue_num"] === selectedIssue);
  return matches.length === 1 ? matches[0] : undefined;
}

function hasRequiredTruthFields(truth: JsonRecord): boolean {
  return [...REQUIRED_TRUTH_FIELDS].every((field) =>
    Object.prototype.hasOwnProperty.call(truth, field),
  );
}

function anyFieldMismatch(
  truth: JsonRecord,
  item: JsonRecord,
  fields: readonly string[],
): boolean {
  return fields.some((field) => truth[field] !== item[field]);
}

/** Return ordered live-truth errors for an explicitly resumable checkpoint. */
export function validateParallelResumeTruth(
  state: JsonRecord,
  context: string,
): string[] {
  void context;
  const required = state["resume_required"] === true;
  const truthValue = state["resume_truth"];
  if (!required && (truthValue === null || truthValue === undefined)) {
    return [];
  }
  const truth = asRecord(truthValue);
  if (truth === undefined) {
    return [REASON_TRUTH_REQUIRED];
  }

  const items = mappingItems(state);
  const errors: string[] = [];
  if (containsForbiddenKey(truth)) {
    errors.push(REASON_FAN_IN_FORBIDDEN);
  }
  if (truth["schema_version"] !== 1 || !hasRequiredTruthFields(truth)) {
    errors.push(REASON_TRUTH_INVALID);
  }

  const first = firstIncomplete(items);
  const selected = selectedItem(items, truth["selected_issue_num"]);
  if (
    first === undefined ||
    selected === undefined ||
    first["issue_num"] !== truth["selected_issue_num"]
  ) {
    errors.push(REASON_ORDER_MISMATCH);
  }
  if (hasDuplicateIdentity(items)) {
    errors.push(REASON_IDENTITY_DUPLICATE);
  }
  if (selected === undefined) {
    return [...new Set(errors)];
  }

  if (
    truth["repository"] !== selected["repository"] ||
    truth["origin_main_head"] !== selected["origin_main_head"]
  ) {
    errors.push(REASON_GIT_MISMATCH);
  }
  if (
    truth["worktree_path"] !== selected["worktree_path"] ||
    truth["branch_name"] !== selected["branch_name"]
  ) {
    errors.push(REASON_WORKTREE_MISMATCH);
  }
  if (
    !positiveInteger(truth["pr_number"]) ||
    truth["pr_number"] !== selected["pr_number"] ||
    truth["pr_base_branch"] !== "main" ||
    truth["pr_base_branch"] !== selected["pr_base_branch"] ||
    truth["pr_head_branch"] !== selected["branch_name"] ||
    truth["pr_head_sha"] !== truth["worktree_head"] ||
    truth["pr_head_sha"] !== selected["pr_head_sha"] ||
    truth["checks_head_sha"] !== truth["pr_head_sha"] ||
    truth["checks_conclusion"] !== "success" ||
    truth["pr_state"] !== "OPEN"
  ) {
    errors.push(REASON_GITHUB_MISMATCH);
  }
  if (
    anyFieldMismatch(truth, selected, [
      "launch_id",
      "spec_sha256",
      "checkpoint_sha256",
    ])
  ) {
    errors.push(REASON_LAUNCH_MISMATCH);
  }
  if (truth["latest_mutation_sequence"] !== latestMutationSequence(state)) {
    errors.push(REASON_MUTATION_MISMATCH);
  }

  const generation = state["recolor_generation"];
  if (
    truth["unresolved_drift"] !== false ||
    truth["recolor_generation"] !== generation ||
    truth["drift_resolution_generation"] !== generation
  ) {
    errors.push(REASON_DRIFT_UNRESOLVED);
  }
  if (anyFieldMismatch(truth, selected, ROUTING_FIELDS)) {
    errors.push(REASON_ROUTING_MISMATCH);
  }
  if (
    truth["child_status_path"] !== selected["child_status_path"] ||
    truth["child_status_launch_id"] !== selected["launch_id"] ||
    truth["child_status_pid"] !== selected["child_status_pid"] ||
    truth["child_status_pid"] !== truth["live_process_pid"]
  ) {
    errors.push(REASON_CHILD_STATUS_MISMATCH);
  }
  if (
    truth["live_process_running"] === true &&
    truth["should_relaunch"] === true
  ) {
    errors.push(REASON_PROCESS_RUNNING);
  } else if (
    truth["live_process_running"] === false &&
    truth["should_relaunch"] !== true
  ) {
    errors.push(REASON_RELAUNCH_NOT_AUTHORIZED);
  }

  return [...new Set(errors)];
}
