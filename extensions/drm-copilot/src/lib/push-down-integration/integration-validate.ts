/**
 * Deterministic verdict of the push-down integration validate tool (issue
 * #1051, S35 to S38 and S41).
 *
 * Purpose:
 *     Evaluate rules V1 to V5 over a destination, in a fixed order, and return
 *     the verdict with the fixed `not_checked` list. V1 to V3 live here; V4
 *     and V5 live in `integration-validate-artifacts.ts`.
 *
 * Side effects:
 *     Reads the destination through the injected read-only seam only.
 */

import { compareCodePoint } from "../string-ordering";
import { CI_DATA_FILE_RELATIVE_PATH } from "../push-down/push-down-ci-workflows";
import { readManifestOrUndefined } from "./integration-ecosystems";
import {
  type CiDataFile,
  type DestinationWorkflow,
  jobCheckName,
  readCiDataFile,
  readDestinationWorkflows,
} from "./integration-detect";
import {
  evaluateCoverageArtifactRule,
  evaluateManifestHashRule,
  type ValidateFailure,
  type ValidateReadInput,
} from "./integration-validate-artifacts";

/** What validate does not check, in order (S41). */
export const VALIDATE_NOT_CHECKED = [
  "whether CI runs or passes",
  "GitHub expression syntax and context names",
  "action versions and their availability",
  "secrets and permissions",
  "runner labels",
  "rulesets and branch protection",
  "YAML outside the reader subset",
  "coverage values and thresholds",
  "hook behavior",
  "symlinks and reparse points",
  "files the manifest does not list",
  "integration choices that are correct but unusual",
] as const;

/** Rule ids, in evaluation order (S35). */
export const VALIDATE_RULE_IDS = [
  "V1-workflow-read",
  "V2-data-file",
  "V3-required-check",
  "V4-coverage-artifact-path",
  "V5-manifest-hash",
] as const;

/** One rule id. */
export type ValidateRuleId = (typeof VALIDATE_RULE_IDS)[number];

/** Status of one rule. */
export type ValidateRuleStatus = "pass" | "fail" | "not-applicable";

/** One rule entry of the verdict (S35). */
export interface ValidateRuleEntry {
  readonly rule: ValidateRuleId;
  readonly status: ValidateRuleStatus;
  readonly failures: ReadonlyArray<ValidateFailure>;
  /** V5 only: modified or missing paths listed in `.push-down-exclusions`. */
  readonly destination_owned?: ReadonlyArray<string>;
}

/** The `integration` object of a validate result (S35). */
export interface ValidateIntegrationResult {
  readonly verdict: "pass" | "fail";
  readonly rules: ReadonlyArray<ValidateRuleEntry>;
  readonly not_checked: ReadonlyArray<string>;
}

/** Gate job `if` values accepted by V3 (trimmed). */
const ALWAYS_CONDITIONS: ReadonlySet<string> = new Set([
  "always()",
  "${{ always() }}",
]);

/**
 * Build a rule entry with sorted failures.
 *
 * @param rule Rule id.
 * @param failures Failures, or undefined when the rule does not apply.
 * @returns The entry; `fail` exactly when a failure exists.
 */
function ruleEntry(
  rule: ValidateRuleId,
  failures: ReadonlyArray<ValidateFailure> | undefined,
): ValidateRuleEntry {
  if (failures === undefined) {
    return { rule, status: "not-applicable", failures: [] };
  }
  const sorted = [...failures].sort(
    (left, right) =>
      compareCodePoint(left.path, right.path) ||
      compareCodePoint(left.message, right.message),
  );
  return {
    rule,
    status: sorted.length > 0 ? "fail" : "pass",
    failures: sorted,
  };
}

/** Evaluate V1 (S36). */
function evaluateWorkflowRead(
  workflows: ReadonlyArray<DestinationWorkflow>,
): ReadonlyArray<ValidateFailure> | undefined {
  if (workflows.length === 0) {
    return undefined;
  }
  return workflows.flatMap((workflow) => {
    const result = workflow.result;
    if (result.status === "unsupported") {
      return [
        {
          path: workflow.path,
          message: `line ${String(result.finding.line)}: unsupported construct ${result.finding.construct}`,
        },
      ];
    }
    if (result.status === "error") {
      return [
        {
          path: workflow.path,
          message: `line ${String(result.line)}: ${result.message}`,
        },
      ];
    }
    return [];
  });
}

/**
 * Evaluate V3 (S38).
 *
 * @param workflows Destination workflows.
 * @param data Valid data file.
 * @returns The failures and the single workflow named as the data file's
 *   `workflow`, when exactly one exists.
 */
function evaluateRequiredCheck(
  workflows: ReadonlyArray<DestinationWorkflow>,
  data: CiDataFile,
): { failures: ValidateFailure[]; workflow: DestinationWorkflow | undefined } {
  const named = workflows.filter(
    (workflow) =>
      workflow.result.status === "ok" && workflow.result.name === data.workflow,
  );
  const [workflow] = named;
  if (named.length !== 1 || workflow?.result.status !== "ok") {
    return {
      failures: [
        {
          path: CI_DATA_FILE_RELATIVE_PATH,
          message: `expected exactly one workflow named '${data.workflow}'; found ${String(named.length)}${named.length > 0 ? ` (${named.map((entry) => entry.path).join(", ")})` : ""}`,
        },
      ],
      workflow: undefined,
    };
  }
  const result = workflow.result;
  const failures: ValidateFailure[] = [];
  const fail = (message: string): void => {
    failures.push({ path: workflow.path, message });
  };
  if (!result.triggers.includes("pull_request")) {
    fail("the workflow triggers do not include pull_request");
  }
  for (const context of data.required_contexts) {
    if (!result.jobs.some((job) => jobCheckName(job) === context)) {
      fail(`no job produces the required check '${context}'`);
    }
  }
  const first = data.required_contexts[0] ?? "";
  const gate = result.jobs.find((job) => jobCheckName(job) === first);
  if (gate !== undefined) {
    if (!ALWAYS_CONDITIONS.has((gate.if ?? "").trim())) {
      fail(`job '${gate.id}' does not run with if: always()`);
    }
    const missing = result.jobs
      .map((job) => job.id)
      .filter((id) => id !== gate.id && !gate.needs.includes(id));
    if (missing.length > 0) {
      fail(`job '${gate.id}' does not need: ${missing.join(", ")}`);
    }
  }
  return { failures, workflow: failures.length === 0 ? workflow : undefined };
}

/**
 * Validate an integrated destination (S35).
 *
 * @param input Seam and destination root.
 * @returns The verdict, the five rule entries in order, and `not_checked`.
 */
export function validatePushDownIntegration(
  input: ValidateReadInput,
): ValidateIntegrationResult {
  const workflows = readDestinationWorkflows(input.fs, input.destinationRoot);
  const data = readCiDataFile(input.fs, input.destinationRoot);
  const dataFailures =
    data.status === "absent"
      ? undefined
      : data.status === "invalid"
        ? [{ path: CI_DATA_FILE_RELATIVE_PATH, message: data.message }]
        : [];
  const required =
    data.status === "valid"
      ? evaluateRequiredCheck(workflows, data.data)
      : undefined;
  const manifestHash = evaluateManifestHashRule(input);
  const rules: ValidateRuleEntry[] = [
    ruleEntry("V1-workflow-read", evaluateWorkflowRead(workflows)),
    ruleEntry("V2-data-file", dataFailures),
    ruleEntry("V3-required-check", required?.failures),
    ruleEntry(
      "V4-coverage-artifact-path",
      evaluateCoverageArtifactRule(
        input,
        required?.workflow,
        readManifestOrUndefined(input.fs, input.destinationRoot),
      ),
    ),
    {
      ...ruleEntry("V5-manifest-hash", manifestHash.failures),
      destination_owned: manifestHash.destinationOwned,
    },
  ];
  return {
    verdict: rules.some((rule) => rule.status === "fail") ? "fail" : "pass",
    rules,
    not_checked: VALIDATE_NOT_CHECKED,
  };
}
