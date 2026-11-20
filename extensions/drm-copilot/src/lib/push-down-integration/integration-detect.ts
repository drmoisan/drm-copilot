/**
 * Shared conflict core and detect result of the push-down integration tools
 * (issue #1051, S24 to S33).
 *
 * Purpose:
 *     Read the destination workflows and the #1050 CI data file through the
 *     read-only seam, raise the structured conflict items of S25 to S30 (the
 *     push-down writer and the detect tool share {@link
 *     evaluateDestinationConflicts}), and assemble the detect result.
 *
 * Invariants / Constraints:
 *     Reads only; never writes. Every list is sorted, so the result does not
 *     depend on the order in which the seam lists files.
 */

import { compareCodePoint } from "../string-ordering";
import { toPosixPath } from "../push-down/filesystem-adapter";
import {
  CI_CALLER_RELATIVE_PATH,
  CI_DATA_FILE_RELATIVE_PATH,
  CI_STEMS,
  ciCopyRelativePath,
  ciWorkflowSource,
  resolveCiPackJobs,
} from "../push-down/push-down-ci-workflows";
import { describeInvalidRelativePath } from "../push-down/push-down-destination-manifest";
import { joinPosix } from "../push-down/push-down-pipeline";
import {
  detectIntegrationEcosystems,
  type IntegrationEcosystems,
  type IntegrationReadFileSystem,
  readManifestOrUndefined,
} from "./integration-ecosystems";
import {
  createIntegrationItem,
  INTEGRATION_NEEDED_RELATIVE_PATH,
  type IntegrationItem,
  type IntegrationItemKind,
  type IntegrationItemSource,
  mergeIntegrationItems,
} from "./integration-items";
import {
  readWorkflowText,
  type WorkflowJob,
  type WorkflowReadResult,
  WORKFLOW_VERSION_KEYS,
  type WorkflowVersionKey,
} from "./workflow-yaml-reader";

/** Destination folder of the workflows the tools read. */
export const WORKFLOWS_DIRECTORY = ".github/workflows";

/** One destination workflow, read once. */
export interface DestinationWorkflow {
  /** Destination-relative path. */
  readonly path: string;
  readonly text: string;
  readonly result: WorkflowReadResult;
}

/** Validated fields of the CI data file. */
export interface CiDataFile {
  readonly workflow: string;
  readonly workflow_file: string;
  readonly required_contexts: ReadonlyArray<string>;
}

/** Outcome of reading the CI data file. */
export type CiDataFileRead =
  | { readonly status: "absent" }
  | { readonly status: "invalid"; readonly message: string }
  | { readonly status: "valid"; readonly data: CiDataFile };

/** One job of a detect workflow entry (S24). */
export interface DetectWorkflowJob {
  readonly id: string;
  readonly name: string | null;
  readonly uses: string | null;
  readonly needs: ReadonlyArray<string>;
}

/** One reader finding of a detect workflow entry. */
export type DetectWorkflowFinding =
  | { readonly line: number; readonly construct: string }
  | { readonly line: number; readonly message: string };

/** One workflow of the detect result (S24). */
export interface DetectWorkflow {
  readonly path: string;
  readonly name: string | null;
  readonly triggers: ReadonlyArray<string>;
  readonly parse: WorkflowReadResult["status"];
  readonly findings: ReadonlyArray<DetectWorkflowFinding>;
  readonly jobs: ReadonlyArray<DetectWorkflowJob>;
}

/** Integration-needed summary of the detect result (S31). */
export interface IntegrationNeededSummary {
  readonly present: boolean;
  readonly item_count: number | null;
  readonly parse: "absent" | "ok" | "error";
}

/** The `integration` object of a detect result (S24). */
export interface DetectIntegrationResult {
  readonly ecosystems: IntegrationEcosystems;
  readonly workflows: ReadonlyArray<DetectWorkflow>;
  readonly conflicts: ReadonlyArray<IntegrationItem>;
  readonly integration_needed: IntegrationNeededSummary;
}

/** Inputs of the conflict core and the detect tool. */
export interface IntegrationReadInput {
  readonly fs: IntegrationReadFileSystem;
  /** Destination root (POSIX). */
  readonly destinationRoot: string;
  /** Extension root holding `resources/ci-workflows/`. */
  readonly extensionRoot: string;
}

/** Inputs of {@link evaluateDestinationConflicts}. */
export interface ConflictCoreInput extends IntegrationReadInput {
  readonly source: IntegrationItemSource;
  /** Kinds to raise; every detect kind when omitted. */
  readonly kinds?: ReadonlyArray<IntegrationItemKind>;
}

/** Paths of pushed workflows that S27 and S29 never compare against. */
const PUSHED_WORKFLOW_PATHS: ReadonlySet<string> = new Set([
  CI_CALLER_RELATIVE_PATH,
  ...CI_STEMS.map(ciCopyRelativePath),
]);

/**
 * Read every `.yml` and `.yaml` file directly under `.github/workflows/`.
 *
 * @param fs Read-only seam.
 * @param destinationRoot Destination root (POSIX).
 * @returns The workflows sorted by path.
 */
export function readDestinationWorkflows(
  fs: IntegrationReadFileSystem,
  destinationRoot: string,
): DestinationWorkflow[] {
  const directory = joinPosix(destinationRoot, WORKFLOWS_DIRECTORY);
  const prefix = `${directory}/`;
  return fs
    .listFiles(directory)
    .map(toPosixPath)
    .filter((path) => path.startsWith(prefix))
    .map((path) => ({ absolute: path, name: path.slice(prefix.length) }))
    .filter(({ name }) => !name.includes("/") && /\.ya?ml$/.test(name))
    .map(({ absolute, name }) => {
      const text = fs.readTextFile(absolute);
      return {
        path: `${WORKFLOWS_DIRECTORY}/${name}`,
        text,
        result: readWorkflowText(text),
      };
    })
    .sort((left, right) => compareCodePoint(left.path, right.path));
}

/** Return whether a value is a non-empty string. */
function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value !== "";
}

/**
 * Read and check the CI data file (the checks of V2, S37).
 *
 * @param fs Read-only seam.
 * @param destinationRoot Destination root (POSIX).
 * @returns `absent`, `invalid` with the first failed check, or `valid`.
 */
export function readCiDataFile(
  fs: IntegrationReadFileSystem,
  destinationRoot: string,
): CiDataFileRead {
  const path = joinPosix(destinationRoot, CI_DATA_FILE_RELATIVE_PATH);
  if (!fs.isFile(path)) {
    return { status: "absent" };
  }
  let loaded: unknown;
  try {
    loaded = JSON.parse(fs.readTextFile(path));
  } catch {
    return { status: "invalid", message: "the data file is not valid JSON" };
  }
  const record =
    loaded !== null && typeof loaded === "object" && !Array.isArray(loaded)
      ? (loaded as Record<string, unknown>)
      : {};
  const version = record["schema_version"];
  if (typeof version !== "string" || version.split(".")[0] !== "1") {
    return { status: "invalid", message: "schema_version major is not 1" };
  }
  const workflow = record["workflow"];
  const workflowFile = record["workflow_file"];
  const contexts = record["required_contexts"];
  if (!isNonEmptyString(workflow)) {
    return { status: "invalid", message: "workflow is not a non-empty string" };
  }
  if (!isNonEmptyString(workflowFile)) {
    return {
      status: "invalid",
      message: "workflow_file is not a non-empty string",
    };
  }
  if (
    !Array.isArray(contexts) ||
    contexts.length === 0 ||
    !contexts.every(isNonEmptyString)
  ) {
    return {
      status: "invalid",
      message: "required_contexts is not a non-empty list of non-empty strings",
    };
  }
  return {
    status: "valid",
    data: {
      workflow,
      workflow_file: workflowFile,
      required_contexts: contexts,
    },
  };
}

/** Return the name a required check matches for a job (S28). */
export function jobCheckName(job: DetectWorkflowJob): string {
  return job.name ?? job.id;
}

/** Return the jobs of a workflow read with status ok, else undefined. */
function okJobs(
  workflow: DestinationWorkflow | undefined,
): ReadonlyArray<WorkflowJob> | undefined {
  return workflow?.result.status === "ok" ? workflow.result.jobs : undefined;
}

/** Return whether a version value is a literal (not an expression). */
function isLiteral(value: string): boolean {
  return !value.includes("${{");
}

/**
 * Read the reference version per key from the bundled harness workflows of
 * the selected packs (S29).
 *
 * @param input Seam, destination root and extension root.
 * @returns The first literal value per version key.
 */
export function readHarnessReferenceVersions(
  input: IntegrationReadInput,
): ReadonlyMap<WorkflowVersionKey, string> {
  const references = new Map<WorkflowVersionKey, string>();
  const manifest = readManifestOrUndefined(input.fs, input.destinationRoot);
  let stems: string[];
  try {
    stems = resolveCiPackJobs(Object.values(manifest?.selection ?? {})).map(
      (job) => job.stem,
    );
  } catch {
    return references;
  }
  for (const stem of CI_STEMS.filter((candidate) =>
    stems.includes(candidate),
  )) {
    const path = joinPosix(
      joinPosix(input.extensionRoot, "resources"),
      ciWorkflowSource(stem),
    );
    const jobs = input.fs.isFile(path)
      ? okJobs({
          path,
          text: "",
          result: readWorkflowText(input.fs.readTextFile(path)),
        })
      : undefined;
    for (const job of jobs ?? []) {
      for (const key of WORKFLOW_VERSION_KEYS) {
        const literal = job.with_versions[key].find(isLiteral);
        if (literal !== undefined && !references.has(key)) {
          references.set(key, literal);
        }
      }
    }
  }
  return references;
}

/** Raise S25 to S28 items that depend on a valid data file. */
function dataFileItems(
  workflows: ReadonlyArray<DestinationWorkflow>,
  data: CiDataFile,
  source: IntegrationItemSource,
): IntegrationItem[] {
  const items: IntegrationItem[] = [];
  const pushed = workflows.find((entry) => entry.path === data.workflow_file);
  const pushedJobs = okJobs(pushed);
  for (const workflow of workflows) {
    if (workflow.path === data.workflow_file) {
      continue;
    }
    if (
      workflow.result.status === "ok" &&
      workflow.result.name === data.workflow
    ) {
      items.push(
        createIntegrationItem(
          "workflow-name-collision",
          workflow.path,
          source,
          {
            existing_name: data.workflow,
          },
        ),
      );
    }
  }
  const pushedSet = new Set(
    pushedJobs === undefined
      ? data.required_contexts
      : pushedJobs.flatMap((job) => [
          job.id,
          ...(job.name === null ? [] : [job.name]),
        ]),
  );
  for (const workflow of workflows) {
    if (
      workflow.path === data.workflow_file ||
      PUSHED_WORKFLOW_PATHS.has(workflow.path)
    ) {
      continue;
    }
    for (const job of okJobs(workflow) ?? []) {
      const matched = pushedSet.has(job.id)
        ? job.id
        : job.name !== null && pushedSet.has(job.name)
          ? job.name
          : undefined;
      if (matched !== undefined) {
        items.push(
          createIntegrationItem("job-name-overlap", workflow.path, source, {
            job_id: job.id,
            matched,
          }),
        );
      }
    }
  }
  if (describeInvalidRelativePath(data.workflow_file) === undefined) {
    const produced = new Set((pushedJobs ?? []).map(jobCheckName));
    for (const context of data.required_contexts) {
      if (!produced.has(context)) {
        items.push(
          createIntegrationItem(
            "missing-required-check",
            data.workflow_file,
            source,
            {
              context,
              workflow_file: data.workflow_file,
            },
          ),
        );
      }
    }
  }
  return items;
}

/** Raise S29 version-matrix-difference items. */
function versionItems(
  workflows: ReadonlyArray<DestinationWorkflow>,
  references: ReadonlyMap<WorkflowVersionKey, string>,
  source: IntegrationItemSource,
): IntegrationItem[] {
  const items: IntegrationItem[] = [];
  for (const workflow of workflows) {
    if (PUSHED_WORKFLOW_PATHS.has(workflow.path)) {
      continue;
    }
    for (const job of okJobs(workflow) ?? []) {
      for (const key of WORKFLOW_VERSION_KEYS) {
        const found = [...new Set(job.with_versions[key].filter(isLiteral))];
        const expected = references.get(key);
        if (
          found.length > 0 &&
          expected !== undefined &&
          !found.includes(expected)
        ) {
          items.push(
            createIntegrationItem(
              "version-matrix-difference",
              workflow.path,
              source,
              {
                job_id: job.id,
                key,
                found,
                expected,
              },
            ),
          );
        }
      }
    }
  }
  return items;
}

/**
 * Evaluate the destination conflicts shared by the push-down writer and the
 * detect tool (S25 to S30).
 *
 * @param input Seam, roots, item source and the kinds to raise.
 * @returns Merged items sorted by id.
 */
export function evaluateDestinationConflicts(
  input: ConflictCoreInput,
): IntegrationItem[] {
  const workflows = readDestinationWorkflows(input.fs, input.destinationRoot);
  const data = readCiDataFile(input.fs, input.destinationRoot);
  const items: IntegrationItem[] = [];
  if (data.status !== "absent") {
    const workflowFile =
      data.status === "valid" ? data.data.workflow_file : undefined;
    for (const workflow of workflows) {
      const isCi = /^\.github\/workflows\/ci\.ya?ml$/.test(workflow.path);
      if (isCi && workflow.path !== workflowFile) {
        items.push(
          createIntegrationItem(
            "existing-ci-workflow",
            workflow.path,
            input.source,
          ),
        );
      }
    }
  }
  if (data.status === "valid") {
    items.push(...dataFileItems(workflows, data.data, input.source));
  }
  items.push(
    ...versionItems(
      workflows,
      readHarnessReferenceVersions(input),
      input.source,
    ),
  );
  for (const workflow of workflows) {
    if (workflow.result.status === "unsupported") {
      items.push(
        createIntegrationItem("yaml-unsupported", workflow.path, input.source, {
          line: workflow.result.finding.line,
          construct: workflow.result.finding.construct,
        }),
      );
    }
  }
  const kinds = input.kinds;
  return mergeIntegrationItems(
    kinds === undefined
      ? items
      : items.filter((item) => kinds.includes(item.kind)),
  );
}

/** Summarize the integration-needed file without interpreting items (S31). */
function summarizeIntegrationNeeded(
  input: IntegrationReadInput,
): IntegrationNeededSummary {
  const path = joinPosix(
    input.destinationRoot,
    INTEGRATION_NEEDED_RELATIVE_PATH,
  );
  if (!input.fs.isFile(path)) {
    return { present: false, item_count: null, parse: "absent" };
  }
  try {
    const loaded: unknown = JSON.parse(input.fs.readTextFile(path));
    const items =
      loaded !== null && typeof loaded === "object"
        ? (loaded as Record<string, unknown>)["items"]
        : undefined;
    if (Array.isArray(items)) {
      return { present: true, item_count: items.length, parse: "ok" };
    }
  } catch {
    // An unparseable file is reported with parse `error` below.
  }
  return { present: true, item_count: null, parse: "error" };
}

/** Shape one workflow for the detect result. */
function toDetectWorkflow(workflow: DestinationWorkflow): DetectWorkflow {
  const result = workflow.result;
  const findings: DetectWorkflowFinding[] =
    result.status === "unsupported"
      ? [{ line: result.finding.line, construct: result.finding.construct }]
      : result.status === "error"
        ? [{ line: result.line, message: result.message }]
        : [];
  return {
    path: workflow.path,
    name: result.status === "ok" ? result.name : null,
    triggers: result.status === "ok" ? result.triggers : [],
    parse: result.status,
    findings,
    jobs:
      result.status === "ok"
        ? result.jobs.map((job) => ({
            id: job.id,
            name: job.name,
            uses: job.uses,
            needs: job.needs,
          }))
        : [],
  };
}

/**
 * Detect the ecosystems, workflows and conflicts of a destination (S24).
 *
 * @param input Seam, destination root and extension root.
 * @returns The `integration` object of a detect result.
 */
export function detectPushDownIntegration(
  input: IntegrationReadInput,
): DetectIntegrationResult {
  return {
    ecosystems: detectIntegrationEcosystems(input.fs, input.destinationRoot),
    workflows: readDestinationWorkflows(input.fs, input.destinationRoot).map(
      toDetectWorkflow,
    ),
    conflicts: evaluateDestinationConflicts({ ...input, source: "detect" }),
    integration_needed: summarizeIntegrationNeeded(input),
  };
}
