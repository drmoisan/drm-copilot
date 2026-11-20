/**
 * Decision-file parsing and validation (issue #1016, spec "Decision File").
 *
 * The tool consumes `discovery_templates_target`, `in_tree_rewrite_scope`,
 * `commit_split`, `rewrite_exclusions` and `decisions`; the nine other
 * `global_decisions` keys are recorded for the stage B plan and are validated
 * only as present strings.
 */
import { createHash } from "node:crypto";

import { parseFeatureFolderName } from "../development-docs/feature-folder-name";

/** Global choices the tool consumes (OQ-1, OQ-2, OQ-12). */
export const CONSUMED_CHOICES = [
  "discovery_templates_target",
  "in_tree_rewrite_scope",
  "commit_split",
] as const;

/** A consumed global choice key. */
export type ConsumedChoice = (typeof CONSUMED_CHOICES)[number];

/** Global decisions recorded for the stage B plan only. */
export const RECORD_ONLY_KEYS = [
  "absent_key_resolves",
  "discovery_runtime_resource_key",
  "rules_mirrors_editable",
  "remove_fallback",
  "run_source",
  "allow_list_tool",
  "extension_command",
  "file_size_excluded_segment",
  "plan_template_link_depth",
] as const;

/** Allowed `in_tree_rewrite_scope` values (OQ-2). */
export const IN_TREE_REWRITE_SCOPES = [
  "references-and-links",
  "links-only",
  "none",
] as const;

/** An `in_tree_rewrite_scope` value. */
export type InTreeRewriteScope = (typeof IN_TREE_REWRITE_SCOPES)[number];

/** Allowed `commit_split` values (OQ-12). */
export const COMMIT_SPLITS = ["single", "moves-then-rewrites"] as const;

/** A `commit_split` value. */
export type CommitSplit = (typeof COMMIT_SPLITS)[number];

/** One folder decision. */
export type FolderDecision =
  | {
      readonly source: string;
      readonly action: "rename";
      readonly target: string;
    }
  | { readonly source: string; readonly action: "keep" };

/** A parsed decision file. */
export interface MigrationDecisions {
  readonly version: 1;
  readonly dryRunReport: string | null;
  readonly sourceDigest: string;
  readonly discoveryTemplatesTarget: string | null;
  readonly inTreeRewriteScope: InTreeRewriteScope | null;
  readonly commitSplit: CommitSplit | null;
  readonly recordOnly: Readonly<Record<string, string>>;
  readonly rewriteExclusions: ReadonlyArray<string>;
  readonly decisions: ReadonlyArray<FolderDecision>;
}

/** Inputs of {@link validateMigrationDecisions}. */
export interface DecisionValidationContext {
  readonly reportedFolders: ReadonlyArray<string>;
  readonly heldSources: ReadonlyArray<string>;
  readonly sourceDigest: string;
  readonly requiredChoices: ReadonlyArray<ConsumedChoice>;
}

type JsonObject = Record<string, unknown>;

function isObject(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Read an optional consumed choice: `null` or missing is unset; a non-string,
 * or a value outside `allowed` when given, is an error.
 */
function readChoice<T extends string>(
  globals: JsonObject,
  key: string,
  errors: string[],
  allowed?: ReadonlyArray<T>,
): T | null {
  const value = globals[key];
  if (value === undefined || value === null) {
    return null;
  }
  if (typeof value !== "string") {
    errors.push(`global_decisions.${key} must be a string or null`);
    return null;
  }
  if (allowed !== undefined && !allowed.includes(value as T)) {
    errors.push(
      `global_decisions.${key} must be one of ${allowed.join(", ")}: ${value}`,
    );
    return null;
  }
  return value as T;
}

/**
 * Parse one `decisions[]` entry.
 *
 * @returns The decision, or null after recording an error.
 */
function readDecision(
  entry: unknown,
  index: number,
  errors: string[],
): FolderDecision | null {
  if (!isObject(entry) || typeof entry["source"] !== "string") {
    errors.push(`decisions[${String(index)}].source must be a string`);
    return null;
  }
  const source = entry["source"];
  if (entry["action"] === "keep") {
    return { source, action: "keep" };
  }
  if (entry["action"] === "rename") {
    const target = entry["target"];
    if (typeof target !== "string") {
      errors.push(
        `decisions[${String(index)}].target must be a string for a rename`,
      );
      return null;
    }
    return { source, action: "rename", target };
  }
  errors.push(`decisions[${String(index)}].action must be rename or keep`);
  return null;
}

/**
 * Parse and schema-validate a decision file.
 *
 * @param text Decision-file JSON text.
 * @returns The parsed decisions.
 * @throws Error Naming every schema problem when the file is invalid.
 */
export function parseMigrationDecisions(text: string): MigrationDecisions {
  let raw: unknown;
  try {
    raw = JSON.parse(text);
  } catch (error: unknown) {
    throw new Error(
      `Decision file is not valid JSON: ${error instanceof Error ? error.message : String(error)}`,
      { cause: error },
    );
  }
  const errors: string[] = [];
  if (!isObject(raw)) {
    throw new Error("Decision file must be a JSON object");
  }
  if (raw["version"] !== 1) {
    errors.push("version must be 1");
  }
  const sourceDigest = raw["source_digest"];
  if (typeof sourceDigest !== "string") {
    errors.push("source_digest must be a string");
  }
  const dryRunReport = raw["dry_run_report"];
  if (dryRunReport !== undefined && typeof dryRunReport !== "string") {
    errors.push("dry_run_report must be a string");
  }
  const globals = isObject(raw["global_decisions"])
    ? raw["global_decisions"]
    : null;
  if (globals === null) {
    errors.push("global_decisions must be an object");
  }
  const g = globals ?? {};
  const discoveryTemplatesTarget = readChoice<string>(
    g,
    "discovery_templates_target",
    errors,
  );
  const inTreeRewriteScope = readChoice(
    g,
    "in_tree_rewrite_scope",
    errors,
    IN_TREE_REWRITE_SCOPES,
  );
  const commitSplit = readChoice(g, "commit_split", errors, COMMIT_SPLITS);
  const recordOnly: Record<string, string> = {};
  for (const key of RECORD_ONLY_KEYS) {
    const value = g[key];
    if (typeof value === "string") {
      recordOnly[key] = value;
    } else if (globals !== null) {
      errors.push(`global_decisions.${key} must be a present string`);
    }
  }
  const exclusions = raw["rewrite_exclusions"] ?? [];
  if (
    !Array.isArray(exclusions) ||
    exclusions.some((item) => typeof item !== "string")
  ) {
    errors.push("rewrite_exclusions must be an array of strings");
  }
  const rawDecisions = raw["decisions"] ?? [];
  const decisions: FolderDecision[] = [];
  if (Array.isArray(rawDecisions)) {
    rawDecisions.forEach((entry: unknown, index) => {
      const decision = readDecision(entry, index, errors);
      if (decision !== null) {
        decisions.push(decision);
      }
    });
  } else {
    errors.push("decisions must be an array");
  }
  if (errors.length > 0) {
    throw new Error(`Decision file is invalid: ${errors.join("; ")}`);
  }
  return {
    version: 1,
    dryRunReport: typeof dryRunReport === "string" ? dryRunReport : null,
    sourceDigest: sourceDigest as string,
    discoveryTemplatesTarget,
    inTreeRewriteScope,
    commitSplit,
    recordOnly,
    rewriteExclusions: exclusions as string[],
    decisions,
  };
}

/**
 * Compute the `source_digest`: SHA-256 of the sorted candidate folder paths.
 *
 * @param folders Candidate folder paths of the dry run.
 * @returns Lowercase hexadecimal digest.
 */
export function computeSourceDigest(folders: ReadonlyArray<string>): string {
  const sorted = [...new Set(folders)].sort();
  return createHash("sha256").update(sorted.join("\n"), "utf8").digest("hex");
}

/** Return the value of a consumed choice from parsed decisions. */
export function consumedChoiceValue(
  decisions: MigrationDecisions,
  choice: ConsumedChoice,
): string | null {
  switch (choice) {
    case "discovery_templates_target":
      return decisions.discoveryTemplatesTarget;
    case "in_tree_rewrite_scope":
      return decisions.inTreeRewriteScope;
    case "commit_split":
      return decisions.commitSplit;
  }
}

/**
 * Validate parsed decisions against a fresh dry run (apply mode).
 *
 * @param decisions Parsed decision file.
 * @param context Reported folders, held sources, fresh digest, required choices.
 * @returns Refusal reasons; empty when the decisions may be applied.
 */
export function validateMigrationDecisions(
  decisions: MigrationDecisions,
  context: DecisionValidationContext,
): ReadonlyArray<string> {
  const reasons: string[] = [];
  if (decisions.sourceDigest !== context.sourceDigest) {
    reasons.push(
      `source_digest mismatch: decision file ${decisions.sourceDigest}, fresh dry run ${context.sourceDigest}`,
    );
  }
  const reported = new Set(context.reportedFolders);
  const decided = new Set<string>();
  for (const decision of decisions.decisions) {
    decided.add(decision.source);
    if (!reported.has(decision.source)) {
      reasons.push(
        `decision names a source that is not a reported folder: ${decision.source}`,
      );
    }
    if (
      decision.action === "rename" &&
      parseFeatureFolderName(decision.target).format !== "issue-first"
    ) {
      reasons.push(`rename target is not issue-first: ${decision.target}`);
    }
  }
  for (const source of context.heldSources) {
    if (!decided.has(source)) {
      reasons.push(`held item has no decision entry: ${source}`);
    }
  }
  for (const choice of context.requiredChoices) {
    if (consumedChoiceValue(decisions, choice) === null) {
      reasons.push(`required global choice is unset: ${choice}`);
    }
  }
  return reasons;
}

/** Inputs of {@link buildDecisionSkeleton}. */
export interface SkeletonInputs {
  readonly dryRunReport: string | null;
  readonly sourceDigest: string;
  readonly heldSources: ReadonlyArray<string>;
}

/**
 * Build the `decision_skeleton`: every held item and every global key with `null`.
 *
 * @param inputs Report name, digest and held sources.
 * @returns A JSON-ready object a maintainer fills in.
 */
export function buildDecisionSkeleton(
  inputs: SkeletonInputs,
): Record<string, unknown> {
  const globals: Record<string, null> = {};
  for (const key of [...CONSUMED_CHOICES, ...RECORD_ONLY_KEYS]) {
    globals[key] = null;
  }
  return {
    version: 1,
    dry_run_report: inputs.dryRunReport,
    source_digest: inputs.sourceDigest,
    global_decisions: globals,
    rewrite_exclusions: [],
    decisions: inputs.heldSources.map((source) => ({
      source,
      action: null,
      target: null,
    })),
  };
}
