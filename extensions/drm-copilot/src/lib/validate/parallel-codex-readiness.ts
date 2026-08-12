/** Pure Codex provenance and readiness checks for standalone parallel state. */

import { validateCodexModelRoutingReceipt } from "./orchestrator-state-codex-model-routing";
import { validateCodexTopologyReceipt } from "./orchestrator-state-codex-topology";
import { isObject, pythonRepr } from "./parallel-state-shared";

export const PARALLEL_LAUNCH_SCHEMA_VERSION = 2;
export const PARALLEL_SURFACE = "parallel";
const VALID_LEDGER_STATUSES = new Set(["PRESERVED", "DEGRADED", "LOST"]);
const SHA256_RE = /^[0-9a-f]{64}$/;
const COMMIT_RE = /^[0-9a-f]{40,64}$/;
const MIXED_STATE_KEYS = new Set([
  "epic_slug",
  "epic_manifest_path",
  "epic_status_doc_path",
  "integration_branch",
  "integration_branch_head",
  "integration_pr",
  "fan_in",
  "fan_in_pr",
  "final_integration_pr",
  "waves",
]);
const LAUNCH_RECORD_KEYS = [
  "schema_version",
  "surface",
  "parallel_slug",
  "item_key",
  "cohort",
  "batch",
  "base_branch",
  "pr_target",
  "head_branch",
  "worktree_path",
  "deployment_agent",
  "model",
  "model_reasoning_effort",
  "permissions",
  "authority_receipt_path",
  "delegation_receipt_path",
  "topology_receipt_path",
  "model_routing_receipt_path",
  "launch_status_path",
  "launch_spec_sha256",
] as const;

export interface ParallelCodexReadinessEvidence {
  readonly launchRecords: Readonly<Record<string, unknown>>;
  readonly statusRecords: Readonly<Record<string, unknown>>;
  readonly receiptRecords: Readonly<Record<string, unknown>>;
  readonly enforceabilityLedger: unknown;
  readonly kickoffIdentity?: Readonly<Record<string, unknown>>;
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function mixedStatePaths(value: unknown, path = ""): string[] {
  const paths: string[] = [];
  if (isObject(value)) {
    for (const [key, child] of Object.entries(value)) {
      const childPath = path.length > 0 ? `${path}.${key}` : key;
      if (MIXED_STATE_KEYS.has(key)) paths.push(childPath);
      paths.push(...mixedStatePaths(child, childPath));
    }
  } else if (Array.isArray(value)) {
    value.forEach((child, index) => {
      paths.push(...mixedStatePaths(child, `${path}[${String(index)}]`));
    });
  }
  return paths;
}

export function validateParallelStateIsStandalone(
  state: Readonly<Record<string, unknown>>,
  context: string,
): string[] {
  return mixedStatePaths(state).map(
    (path) => `${context} contains prohibited epic or fan-in key at ${path}.`,
  );
}

function guardedPath(
  value: unknown,
  field: string,
): { readonly path?: string; readonly errors: string[] } {
  if (!isNonEmptyString(value) || value.includes("\\")) {
    return {
      errors: [`${field} must be a repository-relative POSIX path.`],
    };
  }
  const parts = value.split("/");
  if (
    value.startsWith("/") ||
    /^[A-Za-z]:/.test(value) ||
    parts.includes(".") ||
    parts.includes("..")
  ) {
    return { errors: [`${field} must stay within the workspace root.`] };
  }
  return { path: parts.join("/"), errors: [] };
}

export function validateParallelLaunchProvenance(
  value: unknown,
  expected: Readonly<{
    context: string;
    parallelSlug: unknown;
    itemKey: unknown;
    cohort: unknown;
    batch: unknown;
    headBranch: unknown;
    worktreePath: unknown;
    launchReceiptPath: string;
    launchStatusPath: string;
  }>,
): string[] {
  const prefix = `${expected.context} Codex launch provenance`;
  if (!isObject(value)) {
    return [`${prefix} must be an object loaded from the guarded launch path.`];
  }
  const missing = LAUNCH_RECORD_KEYS.filter((key) => !(key in value));
  if (missing.length > 0) {
    return [`${prefix} missing required keys: ${missing.join(", ")}.`];
  }
  const pairs: ReadonlyArray<readonly [string, unknown]> = [
    ["schema_version", PARALLEL_LAUNCH_SCHEMA_VERSION],
    ["surface", PARALLEL_SURFACE],
    ["parallel_slug", expected.parallelSlug],
    ["item_key", expected.itemKey],
    ["cohort", expected.cohort],
    ["batch", expected.batch],
    ["base_branch", "main"],
    ["pr_target", "main"],
    ["head_branch", expected.headBranch],
    ["worktree_path", expected.worktreePath],
    ["launch_status_path", expected.launchStatusPath],
  ];
  const errors = pairs.flatMap(([key, wanted]) =>
    value[key] === wanted
      ? []
      : [
          `${prefix}.${key} must be ${pythonRepr(wanted)}; ` +
            `found: ${pythonRepr(value[key])}.`,
        ],
  );
  const receiptPath = value["launch_receipt_path"];
  if (
    receiptPath !== undefined &&
    receiptPath !== null &&
    receiptPath !== expected.launchReceiptPath
  ) {
    errors.push(
      `${prefix}.launch_receipt_path must match the guarded path ` +
        `${pythonRepr(expected.launchReceiptPath)}; found: ${pythonRepr(receiptPath)}.`,
    );
  }
  for (const key of [
    "deployment_agent",
    "model",
    "model_reasoning_effort",
    "permissions",
    "authority_receipt_path",
    "delegation_receipt_path",
    "topology_receipt_path",
    "model_routing_receipt_path",
  ]) {
    if (!isNonEmptyString(value[key])) {
      errors.push(`${prefix}.${key} must be a non-empty string.`);
    }
  }
  if (
    typeof value["launch_spec_sha256"] !== "string" ||
    !SHA256_RE.test(value["launch_spec_sha256"])
  ) {
    errors.push(
      `${prefix}.launch_spec_sha256 must be 64 lowercase hex characters.`,
    );
  }
  return errors;
}

export function validateZeroLostLedger(
  value: unknown,
  context: string,
): string[] {
  const prefix = `${context} enforceability_ledger`;
  if (!Array.isArray(value) || value.length === 0) {
    return [`${prefix} must be a non-empty list for execution readiness.`];
  }
  const errors: string[] = [];
  const seen = new Set<string>();
  value.forEach((item, index) => {
    const itemPrefix = `${prefix}[${String(index)}]`;
    if (!isObject(item)) {
      errors.push(`${itemPrefix} must be an object.`);
      return;
    }
    const gateId = item["gate_id"];
    const status = item["status"];
    if (!isNonEmptyString(gateId)) {
      errors.push(`${itemPrefix}.gate_id must be a non-empty string.`);
    } else if (seen.has(gateId)) {
      errors.push(
        `${itemPrefix}.gate_id must be unique; found: ${pythonRepr(gateId)}.`,
      );
    } else {
      seen.add(gateId);
    }
    if (typeof status !== "string" || !VALID_LEDGER_STATUSES.has(status)) {
      errors.push(
        `${itemPrefix}.status must be one of PRESERVED, DEGRADED, LOST; ` +
          `found: ${pythonRepr(status)}.`,
      );
    } else if (status === "LOST") {
      errors.push(`${itemPrefix}.status LOST blocks parallel readiness.`);
    }
  });
  return errors;
}

function validateKickoffIdentity(
  state: Readonly<Record<string, unknown>>,
  evidence: ParallelCodexReadinessEvidence,
  context: string,
): string[] {
  if (!("kickoff_prompt_path" in state)) return [];
  const prefix = `${context} committed kickoff identity`;
  const identity = evidence.kickoffIdentity;
  if (!isObject(identity)) {
    return [`${prefix} is required for execution readiness.`];
  }
  const slug = state["parallel_slug"];
  const expectedPath = `docs/features/parallel/${String(slug)}/parallel-kickoff.md`;
  const expected: ReadonlyArray<readonly [string, unknown]> = [
    ["schema_version", 1],
    ["path", expectedPath],
    ["plan_home_ref", `origin/parallel/${String(slug)}-plan`],
  ];
  const errors = expected.flatMap(([key, wanted]) =>
    identity[key] === wanted
      ? []
      : [
          `${prefix}.${key} must be ${pythonRepr(wanted)}; ` +
            `found: ${pythonRepr(identity[key])}.`,
        ],
  );
  if (state["kickoff_prompt_path"] !== expectedPath) {
    errors.push(
      `${prefix}.path must match checkpoint kickoff_prompt_path ` +
        `${pythonRepr(expectedPath)}; found: ${pythonRepr(state["kickoff_prompt_path"])}.`,
    );
  }
  if (
    typeof identity["planning_commit"] !== "string" ||
    !COMMIT_RE.test(identity["planning_commit"])
  ) {
    errors.push(
      `${prefix}.planning_commit must be 40-64 lowercase hex characters.`,
    );
  }
  if (
    typeof identity["blob_sha256"] !== "string" ||
    !SHA256_RE.test(identity["blob_sha256"])
  ) {
    errors.push(`${prefix}.blob_sha256 must be 64 lowercase hex characters.`);
  }
  if (identity["worktree_sha256"] !== identity["blob_sha256"]) {
    errors.push(`${prefix}.worktree_sha256 must match blob_sha256.`);
  }
  return errors;
}

function validateStatus(
  value: unknown,
  context: string,
  launchReceiptPath: string,
): string[] {
  const prefix = `${context} external launch status`;
  if (!isObject(value)) {
    return [`${prefix} must be an object loaded from the guarded status path.`];
  }
  const errors: string[] = [];
  if (value["schema_version"] !== PARALLEL_LAUNCH_SCHEMA_VERSION) {
    errors.push(
      `${prefix}.schema_version must be ${String(PARALLEL_LAUNCH_SCHEMA_VERSION)}; ` +
        `found: ${pythonRepr(value["schema_version"])}.`,
    );
  }
  if (value["state"] !== "completed") {
    errors.push(
      `${prefix}.state must be 'completed'; found: ${pythonRepr(value["state"])}.`,
    );
  }
  if (value["launch_receipt_path"] !== launchReceiptPath) {
    errors.push(
      `${prefix}.launch_receipt_path must match the guarded launch path.`,
    );
  }
  return errors;
}

function receiptDocument(
  evidence: ParallelCodexReadinessEvidence,
  record: Readonly<Record<string, unknown>>,
  key: string,
  context: string,
): {
  readonly document?: Readonly<Record<string, unknown>>;
  readonly errors: string[];
} {
  const label = key.replace(/_receipt_path$/u, "").replaceAll("_", "-");
  const path = record[key];
  if (!isNonEmptyString(path)) {
    return {
      errors: [`${context} ${label} receipt path must be a non-empty string.`],
    };
  }
  const value = evidence.receiptRecords[path];
  if (!isObject(value)) {
    return {
      errors: [
        `${context} ${label} receipt is missing at ${pythonRepr(path)}.`,
      ],
    };
  }
  return { document: value, errors: [] };
}

function validateReferencedReceipts(
  evidence: ParallelCodexReadinessEvidence,
  record: Readonly<Record<string, unknown>>,
  context: string,
  parallelSlug: unknown,
  itemKey: unknown,
): string[] {
  const documents: Record<string, Readonly<Record<string, unknown>>> = {};
  const errors: string[] = [];
  for (const key of [
    "authority_receipt_path",
    "delegation_receipt_path",
    "topology_receipt_path",
    "model_routing_receipt_path",
  ]) {
    const result = receiptDocument(evidence, record, key, context);
    errors.push(...result.errors);
    if (result.document !== undefined) documents[key] = result.document;
  }
  const authority = documents["authority_receipt_path"];
  if (authority !== undefined) {
    for (const [key, wanted] of [
      ["surface", PARALLEL_SURFACE],
      ["parallel_slug", parallelSlug],
      ["item_key", itemKey],
      ["authorized", true],
    ] as const) {
      if (authority[key] !== wanted) {
        errors.push(
          `${context} authority receipt.${key} must be ${pythonRepr(wanted)}; ` +
            `found: ${pythonRepr(authority[key])}.`,
        );
      }
    }
  }
  const delegation = documents["delegation_receipt_path"];
  if (delegation !== undefined) {
    if (!isNonEmptyString(delegation["delegation_id"])) {
      errors.push(
        `${context} delegation receipt.delegation_id must be non-empty.`,
      );
    }
    if (delegation["agent_name"] !== record["deployment_agent"]) {
      errors.push(
        `${context} delegation receipt.agent_name must match launch agent.`,
      );
    }
  }
  const topology = documents["topology_receipt_path"];
  if (topology !== undefined) {
    errors.push(
      ...validateCodexTopologyReceipt(topology, `${context} topology receipt`),
    );
  }
  const model = documents["model_routing_receipt_path"];
  if (model !== undefined) {
    errors.push(
      ...validateCodexModelRoutingReceipt(
        model,
        `${context} model-routing receipt`,
      ),
    );
    for (const key of ["deployment_agent", "model", "model_reasoning_effort"]) {
      if (record[key] !== model[key]) {
        errors.push(`${context} ${key} must match model-routing receipt.`);
      }
    }
  }
  return errors;
}

export function validateParallelCodexCheckpointReadiness(
  state: Readonly<Record<string, unknown>>,
  context: string,
  evidence?: ParallelCodexReadinessEvidence,
): string[] {
  if (evidence === undefined) {
    return [`${context} Codex readiness evidence is required.`];
  }
  const errors = validateZeroLostLedger(evidence.enforceabilityLedger, context);
  errors.push(...validateKickoffIdentity(state, evidence, context));
  const items = state["items"];
  if (!Array.isArray(items)) return errors;
  const seenPaths = new Set<string>();
  items.forEach((value, index) => {
    if (!isObject(value)) return;
    const itemContext = `${context} items[${String(index)}]`;
    const receipt = guardedPath(
      value["launch_receipt_path"],
      `${itemContext}.launch_receipt_path`,
    );
    const status = guardedPath(
      value["launch_status_path"],
      `${itemContext}.launch_status_path`,
    );
    errors.push(...receipt.errors, ...status.errors);
    for (const key of ["branch", "worktree_path", "cohort", "batch"]) {
      if (!(key in value)) {
        errors.push(`${itemContext}.${key} is required for Codex readiness.`);
      }
    }
    if (receipt.path === undefined || status.path === undefined) return;
    if (seenPaths.has(receipt.path) || seenPaths.has(status.path)) {
      errors.push(`${itemContext} launch and status paths must be unique.`);
    }
    seenPaths.add(receipt.path);
    seenPaths.add(status.path);
    const record = evidence.launchRecords[receipt.path];
    if (!isObject(record)) {
      errors.push(
        `${itemContext} external launch record is missing at ` +
          `${pythonRepr(receipt.path)}.`,
      );
      return;
    }
    errors.push(
      ...validateParallelLaunchProvenance(record, {
        context: itemContext,
        parallelSlug: state["parallel_slug"],
        itemKey: value["issue_num"],
        cohort: value["cohort"],
        batch: value["batch"],
        headBranch: value["branch"],
        worktreePath: value["worktree_path"],
        launchReceiptPath: receipt.path,
        launchStatusPath: status.path,
      }),
    );
    errors.push(
      ...validateStatus(
        evidence.statusRecords[status.path],
        itemContext,
        receipt.path,
      ),
    );
    errors.push(
      ...validateReferencedReceipts(
        evidence,
        record,
        itemContext,
        state["parallel_slug"],
        value["issue_num"],
      ),
    );
  });
  return errors;
}
