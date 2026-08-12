import { createHash } from "node:crypto";
import { type FileSystem, toPosixPath } from "../file-system";
import type { CommandRunner } from "../subprocess-runner";
import {
  type ParallelCodexReadinessEvidence,
  validateZeroLostLedger,
} from "./parallel-codex-readiness";
import { parseParallelKickoff } from "./parallel-kickoff-artifact";
import { isObject } from "./parallel-state-shared";

const RECEIPT_PATH_KEYS = [
  "authority_receipt_path",
  "delegation_receipt_path",
  "topology_receipt_path",
  "model_routing_receipt_path",
] as const;

export interface ParallelReadinessFileContext {
  readonly fileSystem: FileSystem;
  readonly workspaceRoot: string;
  readonly artifactPath: string;
  readonly runner: CommandRunner;
}

export interface ParallelReadinessBuildResult {
  readonly evidence?: ParallelCodexReadinessEvidence;
  readonly errors: string[];
}

function guardedPath(value: unknown): string | undefined {
  if (
    typeof value !== "string" ||
    value.trim().length === 0 ||
    value.includes("\\") ||
    value.startsWith("/") ||
    /^[A-Za-z]:/.test(value) ||
    value.split("/").some((part) => part === "." || part === "..")
  ) {
    return undefined;
  }
  return value;
}

function fullPath(root: string, relative: string): string {
  return `${toPosixPath(root).replace(/\/+$/, "")}/${relative}`;
}

function readJson(
  context: ParallelReadinessFileContext,
  relative: string,
  label: string,
  errors: string[],
): unknown {
  const path = fullPath(context.workspaceRoot, relative);
  if (!context.fileSystem.isFile(path)) {
    errors.push(`${label} is missing at '${relative}'.`);
    return undefined;
  }
  try {
    return JSON.parse(context.fileSystem.readTextFile(path)) as unknown;
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    errors.push(`${label} at '${relative}' is not valid JSON: ${detail}.`);
    return undefined;
  }
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableJson).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${Object.keys(value)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${stableJson(value[key])}`)
      .join(",")}}`;
  }
  return JSON.stringify(value) ?? "undefined";
}

function buildKickoffIdentity(
  state: Readonly<Record<string, unknown>>,
  context: ParallelReadinessFileContext,
  errors: string[],
): Readonly<Record<string, unknown>> | undefined {
  const relative = guardedPath(state["kickoff_prompt_path"]);
  if (relative === undefined) {
    errors.push(
      "Parallel checkpoint kickoff_prompt_path must be a guarded repository-relative path.",
    );
    return undefined;
  }
  const expected = `docs/features/parallel/${String(state["parallel_slug"])}/parallel-kickoff.md`;
  if (relative !== expected) {
    errors.push(
      `Parallel checkpoint kickoff_prompt_path must be '${expected}'; found: '${relative}'.`,
    );
    return undefined;
  }
  const path = fullPath(context.workspaceRoot, relative);
  if (!context.fileSystem.isFile(path)) {
    errors.push(`Parallel committed kickoff is missing at '${relative}'.`);
    return undefined;
  }
  const text = context.fileSystem.readTextFile(path);
  const parsedResult = parseParallelKickoff(text);
  errors.push(...parsedResult.errors);
  const parsed = parsedResult.parsed;
  if (parsed === undefined) return undefined;

  const slug = String(state["parallel_slug"]);
  const expectedManifest = `docs/features/parallel/${slug}/parallel.md`;
  const expectedBranch = `parallel/${slug}-plan`;
  if (parsed.slug !== slug || parsed.invocationSlug !== slug) {
    errors.push(
      "Parallel committed kickoff slug identities must match checkpoint parallel_slug.",
    );
  }
  if (parsed.manifestPath !== expectedManifest) {
    errors.push(
      `Parallel committed kickoff manifest must be '${expectedManifest}'.`,
    );
  }
  if (parsed.planHomeBranch !== expectedBranch) {
    errors.push(
      `Parallel committed kickoff plan-home branch must be '${expectedBranch}'.`,
    );
  }
  if (parsed.planningCommit === undefined) {
    errors.push("Parallel committed kickoff planning_commit is required.");
    return undefined;
  }

  const ref = `origin/${expectedBranch}`;
  const resolved = context.runner.run(
    ["git", "rev-parse", "--verify", `${ref}^{commit}`],
    { cwd: context.workspaceRoot, allowError: true },
  );
  if (resolved.code !== 0 || resolved.stdout.trim() !== parsed.planningCommit) {
    errors.push(
      `Parallel committed kickoff planning_commit must match ${ref}.`,
    );
  }
  const committed = context.runner.run(
    ["git", "rev-parse", "--verify", `${ref}:${relative}`],
    { cwd: context.workspaceRoot, allowError: true },
  );
  const worktree = context.runner.run(["git", "hash-object", "--", relative], {
    cwd: context.workspaceRoot,
    allowError: true,
  });
  if (
    committed.code !== 0 ||
    worktree.code !== 0 ||
    committed.stdout.trim() !== worktree.stdout.trim()
  ) {
    errors.push(
      "Parallel committed kickoff worktree content must match the plan-home ref blob.",
    );
  }
  const digest = createHash("sha256").update(text, "utf8").digest("hex");
  return {
    schema_version: 1,
    path: relative,
    plan_home_ref: ref,
    planning_commit: parsed.planningCommit,
    blob_sha256: digest,
    worktree_sha256: digest,
  };
}

export function validateCommittedParallelKickoff(
  text: string,
  context: ParallelReadinessFileContext,
): string[] {
  const parsedResult = parseParallelKickoff(text);
  if (parsedResult.parsed === undefined) return parsedResult.errors;
  const parsed = parsedResult.parsed;
  const normalizedRoot = toPosixPath(context.workspaceRoot).replace(/\/+$/, "");
  const normalizedArtifact = toPosixPath(context.artifactPath);
  const relative = normalizedArtifact.startsWith(`${normalizedRoot}/`)
    ? normalizedArtifact.slice(normalizedRoot.length + 1)
    : normalizedArtifact;
  const expected = `docs/features/parallel/${parsed.slug}/parallel-kickoff.md`;
  const errors: string[] = [];
  if (relative !== expected) {
    errors.push(
      `Parallel committed kickoff artifact path must be '${expected}'; found: '${relative}'.`,
    );
    return errors;
  }
  buildKickoffIdentity(
    { parallel_slug: parsed.slug, kickoff_prompt_path: relative },
    context,
    errors,
  );
  return errors;
}

export function buildParallelCodexReadinessEvidence(
  text: string,
  context: ParallelReadinessFileContext,
): ParallelReadinessBuildResult {
  let state: unknown;
  try {
    state = JSON.parse(text) as unknown;
  } catch {
    return { errors: [] };
  }
  if (!isObject(state)) return { errors: [] };

  const errors: string[] = [];
  const launchRecords: Record<string, unknown> = {};
  const statusRecords: Record<string, unknown> = {};
  const receiptRecords: Record<string, unknown> = {};
  let enforceabilityLedger: unknown;
  let normalizedLedger: string | undefined;
  const items = Array.isArray(state["items"]) ? state["items"] : [];

  items.forEach((value, index) => {
    if (!isObject(value)) return;
    const itemContext = `Parallel checkpoint items[${String(index)}]`;
    const launchPath = guardedPath(value["launch_receipt_path"]);
    const statusPath = guardedPath(value["launch_status_path"]);
    if (launchPath === undefined || statusPath === undefined) {
      errors.push(
        `${itemContext} launch/status paths must be guarded repository-relative paths.`,
      );
      return;
    }
    const launch = readJson(
      context,
      launchPath,
      `${itemContext} launch record`,
      errors,
    );
    const status = readJson(
      context,
      statusPath,
      `${itemContext} launch status`,
      errors,
    );
    launchRecords[launchPath] = launch;
    statusRecords[statusPath] = status;
    if (!isObject(launch)) return;
    if (
      launch["launch_receipt_path"] !== undefined &&
      launch["launch_receipt_path"] !== launchPath
    ) {
      errors.push(`${itemContext} launch record path binding is mismatched.`);
    }
    if (launch["launch_status_path"] !== statusPath) {
      errors.push(`${itemContext} launch status path binding is mismatched.`);
    }
    if (isObject(status) && status["launch_receipt_path"] !== launchPath) {
      errors.push(
        `${itemContext} launch status receipt binding is mismatched.`,
      );
    }

    const ledger = launch["enforceability_ledger"];
    const normalized = stableJson(ledger);
    if (normalizedLedger === undefined) {
      normalizedLedger = normalized;
      enforceabilityLedger = ledger;
    } else if (normalized !== normalizedLedger) {
      errors.push(
        "Parallel launch records must carry one identical normalized enforceability ledger.",
      );
    }
    for (const key of RECEIPT_PATH_KEYS) {
      const receiptPath = guardedPath(launch[key]);
      if (receiptPath === undefined) {
        errors.push(
          `${itemContext} ${key} must be a guarded repository-relative path.`,
        );
        continue;
      }
      receiptRecords[receiptPath] = readJson(
        context,
        receiptPath,
        `${itemContext} ${key}`,
        errors,
      );
    }
  });

  errors.push(
    ...validateZeroLostLedger(enforceabilityLedger, "Parallel checkpoint"),
  );
  const kickoffIdentity = buildKickoffIdentity(state, context, errors);
  return {
    evidence: {
      launchRecords,
      statusRecords,
      receiptRecords,
      enforceabilityLedger,
      ...(kickoffIdentity === undefined ? {} : { kickoffIdentity }),
    },
    errors,
  };
}
