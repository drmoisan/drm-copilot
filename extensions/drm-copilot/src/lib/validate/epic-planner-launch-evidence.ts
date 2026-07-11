/** Verify completed epic-planner child launch evidence against its source spec. */

import { createHash } from "node:crypto";

import { toPosixPath } from "../file-system";
import type { EpicReadinessContext } from "./epic-planner-readiness-integrity";

const LAUNCH_ROOT = "artifacts/orchestration/epic-child-launches";
const SHA256_RE = /^[0-9a-f]{64}$/;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isNonEmpty(value: unknown): value is string {
  return (
    typeof value === "string" &&
    value.trim().length > 0 &&
    value === value.trim()
  );
}

interface LaunchPathResult {
  readonly relative?: string;
  readonly errors: string[];
}

function launchPath(
  value: unknown,
  context: EpicReadinessContext,
  field: string,
): LaunchPathResult {
  if (!isNonEmpty(value) || value.includes("\0")) {
    return {
      errors: [`${field} must identify a launch artifact in this repository.`],
    };
  }
  let normalized = toPosixPath(value);
  const root = toPosixPath(context.workspaceRoot).replace(/\/+$/, "");
  const rootPrefix = `${root}/`;
  if (normalized.toLowerCase().startsWith(rootPrefix.toLowerCase())) {
    normalized = normalized.slice(rootPrefix.length);
  }
  const parts = normalized.split("/");
  if (
    normalized.startsWith("/") ||
    /^[A-Za-z]:/.test(normalized) ||
    parts.includes("..") ||
    parts.includes(".") ||
    !normalized.startsWith(`${LAUNCH_ROOT}/`)
  ) {
    return {
      errors: [`${field} must identify a launch artifact in this repository.`],
    };
  }
  return { relative: parts.join("/"), errors: [] };
}

interface JsonReadResult {
  readonly value?: Record<string, unknown>;
  readonly text?: string;
  readonly errors: string[];
}

function readJson(
  relative: string,
  context: EpicReadinessContext,
  label: string,
): JsonReadResult {
  const path = `${toPosixPath(context.workspaceRoot).replace(/\/+$/, "")}/${relative}`;
  if (!context.fileSystem.isFile(path)) {
    return { errors: [`Execution readiness requires ${label}: ${relative}`] };
  }
  let text: string;
  try {
    text = context.fileSystem.readTextFile(path);
  } catch (error) {
    return {
      errors: [
        `Execution readiness could not read ${label} ${relative}: ${String(error)}`,
      ],
    };
  }
  let value: unknown;
  try {
    value = JSON.parse(text);
  } catch (error) {
    return {
      text,
      errors: [
        `Execution readiness ${label} is not valid JSON: ${
          error instanceof Error ? error.message : String(error)
        }`,
      ],
    };
  }
  if (!isRecord(value)) {
    return {
      text,
      errors: [`Execution readiness ${label} must be a JSON object.`],
    };
  }
  return { value, text, errors: [] };
}

function expectedFeatureBindings(
  feature: Readonly<Record<string, unknown>>,
): Record<string, unknown> {
  const delegation = feature["delegation_receipt"];
  const model = feature["model_routing_receipt"];
  return {
    issue_num: feature["issue_num"],
    feature_folder: feature["feature_folder"],
    delegation_id: isRecord(delegation)
      ? delegation["delegation_id"]
      : undefined,
    deployment_agent: isRecord(model) ? model["deployment_agent"] : undefined,
    model: isRecord(model) ? model["model"] : undefined,
    model_reasoning_effort: isRecord(model)
      ? model["model_reasoning_effort"]
      : undefined,
    execution_context: "epic_preparation_child",
    branch_name: feature["branch_name"],
    worktree_path: feature["worktree_path"],
  };
}

function parseTimestamp(
  value: unknown,
  prefix: string,
  key: string,
  errors: string[],
): Date | undefined {
  if (
    !isNonEmpty(value) ||
    !/(?:Z|[+-]\d\d:\d\d)$/.test(value) ||
    Number.isNaN(Date.parse(value))
  ) {
    errors.push(`${prefix}.${key} must be an ISO-8601 timestamp with offset.`);
    return undefined;
  }
  return new Date(value);
}

function validateCompletedReceipt(
  receipt: Readonly<Record<string, unknown>>,
  prefix: string,
): string[] {
  const errors: string[] = [];
  if (receipt["schema_version"] !== 2 || receipt["state"] !== "completed") {
    errors.push(`${prefix} must be a schema 2 completed launch receipt.`);
  }
  if (receipt["exit_code"] !== 0) {
    errors.push(`${prefix}.exit_code must be 0.`);
  }
  if (!isNonEmpty(receipt["codex_session_id"])) {
    errors.push(`${prefix}.codex_session_id must be a non-empty string.`);
  }
  const bound = parseTimestamp(
    receipt["session_bound_at"],
    prefix,
    "session_bound_at",
    errors,
  );
  const completed = parseTimestamp(
    receipt["completed_at"],
    prefix,
    "completed_at",
    errors,
  );
  if (bound !== undefined && completed !== undefined && completed < bound) {
    errors.push(`${prefix}.completed_at must not precede session_bound_at.`);
  }
  return errors;
}

function validateSpec(
  receipt: Readonly<Record<string, unknown>>,
  expected: Readonly<Record<string, unknown>>,
  context: EpicReadinessContext,
  prefix: string,
): string[] {
  const specPath = launchPath(
    receipt["spec_path"],
    context,
    `${prefix}.spec_path`,
  );
  const errors = [...specPath.errors];
  if (specPath.relative === undefined) {
    return errors;
  }
  const receiptPath = launchPath(
    receipt["receipt_path"],
    context,
    `${prefix}.receipt_path`,
  );
  if (
    receiptPath.relative !== undefined &&
    specPath.relative.slice(0, specPath.relative.lastIndexOf("/")) !==
      receiptPath.relative.slice(0, receiptPath.relative.lastIndexOf("/"))
  ) {
    errors.push(`${prefix}.spec_path must share the receipt wave directory.`);
  }
  const spec = readJson(
    specPath.relative,
    context,
    `${prefix} launch specification`,
  );
  errors.push(...spec.errors);
  const digest = receipt["spec_sha256"];
  if (!isNonEmpty(digest) || !SHA256_RE.test(digest)) {
    errors.push(`${prefix}.spec_sha256 must be a lowercase SHA-256 hash.`);
  } else if (
    spec.text !== undefined &&
    createHash("sha256").update(spec.text, "utf8").digest("hex") !== digest
  ) {
    errors.push(`${prefix}.spec_sha256 does not match spec_path bytes.`);
  }
  if (spec.value === undefined) {
    return errors;
  }
  if (spec.value["wave_id"] !== receipt["wave_id"]) {
    errors.push(`${prefix}.wave_id must match its launch specification.`);
  }
  const launches = spec.value["launches"];
  const matching = Array.isArray(launches)
    ? launches.filter(
        (item) => isRecord(item) && item["launch_id"] === receipt["launch_id"],
      )
    : [];
  if (matching.length !== 1) {
    errors.push(
      `${prefix}.launch_id must identify exactly one specification launch.`,
    );
  } else {
    const launch = matching[0];
    if (launch !== undefined) {
      for (const [key, value] of Object.entries(expected)) {
        if (launch[key] !== value) {
          errors.push(
            `${prefix} specification launch.${key} must match the feature.`,
          );
        }
      }
    }
  }
  return errors;
}

interface ReceiptResult {
  readonly receipt?: Record<string, unknown>;
  readonly path?: string;
  readonly errors: string[];
}

function validateReceipt(
  feature: Readonly<Record<string, unknown>>,
  index: number,
  context: EpicReadinessContext,
): ReceiptResult {
  const prefix = `Epic planner checkpoint features[${index}] launch receipt`;
  const path = launchPath(
    feature["launch_receipt_path"],
    context,
    `${prefix} path`,
  );
  const errors = [...path.errors];
  if (path.relative === undefined) {
    return { errors };
  }
  const result = readJson(path.relative, context, prefix);
  errors.push(...result.errors);
  if (result.value === undefined) {
    return { path: path.relative, errors };
  }
  const receipt = result.value;
  const expected = expectedFeatureBindings(feature);
  for (const [key, value] of Object.entries(expected)) {
    if (receipt[key] !== value) {
      errors.push(`${prefix}.${key} must match the feature.`);
    }
  }
  const receiptPath = launchPath(
    receipt["receipt_path"],
    context,
    `${prefix}.receipt_path`,
  );
  errors.push(...receiptPath.errors);
  if (
    receiptPath.relative !== undefined &&
    receiptPath.relative !== path.relative
  ) {
    errors.push(`${prefix}.receipt_path must identify the receipt file.`);
  }
  const launchId = receipt["launch_id"];
  const name = path.relative.split("/").at(-1);
  if (!isNonEmpty(launchId) || name !== `${launchId}.receipt.json`) {
    errors.push(`${prefix}.launch_id must match the receipt filename.`);
  }
  const statusPath = launchPath(
    receipt["status_path"],
    context,
    `${prefix}.status_path`,
  );
  errors.push(...statusPath.errors);
  const featureStatus = launchPath(
    feature["launch_status_path"],
    context,
    `${prefix}.status_path`,
  );
  if (
    statusPath.relative !== undefined &&
    statusPath.relative !== featureStatus.relative
  ) {
    errors.push(`${prefix}.status_path must match the feature status file.`);
  }
  errors.push(
    ...validateCompletedReceipt(receipt, prefix),
    ...validateSpec(receipt, expected, context, prefix),
  );
  return { receipt, path: path.relative, errors };
}

function validateStatus(
  feature: Readonly<Record<string, unknown>>,
  index: number,
  receipt: Readonly<Record<string, unknown>>,
  receiptPath: string,
  status: Readonly<Record<string, unknown>>,
  statusPath: string,
  context: EpicReadinessContext,
): string[] {
  const prefix = `Epic planner checkpoint features[${index}] launch status`;
  const errors: string[] = [];
  if (status["schema_version"] !== 2 || status["state"] !== "completed") {
    errors.push(`${prefix} shared wave must be a schema 2 completed status.`);
  }
  const failure = status["failure"];
  if (failure !== undefined && failure !== null && failure !== "") {
    errors.push(`${prefix} shared wave must not contain a failure.`);
  }
  if (status["wave_id"] !== receipt["wave_id"]) {
    errors.push(`${prefix}.wave_id must match the launch receipt.`);
  }
  const launches = status["launches"];
  const launchId = receipt["launch_id"];
  const entry =
    isRecord(launches) && typeof launchId === "string"
      ? launches[launchId]
      : undefined;
  if (!isRecord(entry)) {
    const launchLabel =
      typeof launchId === "string" ? `'${launchId}'` : "<invalid>";
    return [...errors, `${prefix} must contain launch_id ${launchLabel}.`];
  }
  if (entry["state"] !== "completed" || entry["exit_code"] !== 0) {
    errors.push(`${prefix} launch must be completed with exit_code 0.`);
  }
  const entryReceipt = launchPath(
    entry["receipt_path"],
    context,
    `${prefix} launch.receipt_path`,
  );
  errors.push(...entryReceipt.errors);
  if (
    entryReceipt.relative !== undefined &&
    entryReceipt.relative !== receiptPath
  ) {
    errors.push(
      `${prefix} launch.receipt_path must match the feature receipt.`,
    );
  }
  if (entry["codex_session_id"] !== receipt["codex_session_id"]) {
    errors.push(`${prefix} launch.codex_session_id must match the receipt.`);
  }
  if (entry["completed_at"] !== receipt["completed_at"]) {
    errors.push(`${prefix} launch.completed_at must match the receipt.`);
  }
  if (
    statusPath.slice(0, statusPath.lastIndexOf("/")) !==
    receiptPath.slice(0, receiptPath.lastIndexOf("/"))
  ) {
    errors.push(`${prefix} path must share the receipt wave directory.`);
  }
  const resolved = launchPath(feature["launch_status_path"], context, "status");
  if (resolved.relative !== statusPath) {
    errors.push(`${prefix} path must match the shared status file.`);
  }
  return errors;
}

/** Verify every prepared feature's receipt, specification, and final status. */
export function validateEpicPlannerLaunchEvidence(
  state: Readonly<Record<string, unknown>>,
  context: EpicReadinessContext,
): string[] {
  const features = state["features"];
  if (!Array.isArray(features)) {
    return [];
  }
  const errors: string[] = [];
  let statusPath: string | undefined;
  let status: Record<string, unknown> | undefined;
  features.forEach((item, index) => {
    if (!isRecord(item)) {
      return;
    }
    const receipt = validateReceipt(item, index, context);
    errors.push(...receipt.errors);
    const featureStatus = launchPath(
      item["launch_status_path"],
      context,
      `Epic planner checkpoint features[${index}] launch status path`,
    );
    errors.push(...featureStatus.errors);
    if (
      featureStatus.relative !== undefined &&
      statusPath !== undefined &&
      featureStatus.relative !== statusPath
    ) {
      errors.push(
        "Epic planner preparation features must share one launch_status_path.",
      );
    }
    if (featureStatus.relative !== undefined && statusPath === undefined) {
      statusPath = featureStatus.relative;
      const result = readJson(
        statusPath,
        context,
        "the shared preparation launch status",
      );
      errors.push(...result.errors);
      status = result.value;
    }
    if (
      receipt.receipt !== undefined &&
      receipt.path !== undefined &&
      status !== undefined &&
      statusPath !== undefined
    ) {
      errors.push(
        ...validateStatus(
          item,
          index,
          receipt.receipt,
          receipt.path,
          status,
          statusPath,
          context,
        ),
      );
    }
  });
  return errors;
}
