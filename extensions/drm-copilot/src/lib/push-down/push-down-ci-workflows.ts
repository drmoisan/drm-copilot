/**
 * Destination CI workflows of the push-down (issue #1050).
 *
 * Purpose:
 *     Pure logic for the optional `ci_workflows` delivery: parse and infer the
 *     mode (`off`, `reference`, `copy`), map the recorded pack selections to
 *     the CI jobs the caller runs, and render the caller workflow
 *     `.github/workflows/drm-copilot-ci.yml` from the bundled template and job
 *     fragments.
 *
 * Invariants / Constraints:
 *     - This module performs no I/O; the layer contribution reads the bundle.
 *     - The rendered caller is named `CI` and always holds the
 *       `ci-required-gate` job (`CI Required Gate`), which needs every
 *       rendered pack job.
 *     - A selection union holding both C# variants is rejected through
 *       `assertSingleCsharpToolchain`.
 */

import { assertSingleCsharpToolchain } from "./claude-pack-selection";
import { type DestinationManifest } from "./push-down-destination-manifest";

/** Values of the `ci_workflows` input, default first. */
export const CI_WORKFLOWS_MODES = ["off", "reference", "copy"] as const;

/** One `ci_workflows` value. */
export type CiWorkflowsMode = (typeof CI_WORKFLOWS_MODES)[number];

/** Destination path of the rendered caller. */
export const CI_CALLER_RELATIVE_PATH = ".github/workflows/drm-copilot-ci.yml";

/** Destination path of the CI data file. */
export const CI_DATA_FILE_RELATIVE_PATH =
  ".github/drm-copilot/ci-required-checks.json";

/** Destination path of the opt-in branch-protection command. */
export const CI_COMMAND_RELATIVE_PATH =
  ".github/drm-copilot/Set-CiRequiredChecks.ps1";

/** Bundle directory under the extension `resources` root. */
export const CI_BUNDLE_DIRECTORY = "ci-workflows";

/** Resources-relative source of the caller template. */
export const CI_CALLER_TEMPLATE_SOURCE = `${CI_BUNDLE_DIRECTORY}/caller/drm-copilot-ci.template.yml`;

/** Resources-relative source of the data file. */
export const CI_DATA_FILE_SOURCE = `${CI_BUNDLE_DIRECTORY}/ci-required-checks.json`;

/** Resources-relative source of the opt-in command. */
export const CI_COMMAND_SOURCE = `${CI_BUNDLE_DIRECTORY}/Set-CiRequiredChecks.ps1`;

/** Workflow stems, in caller job order. */
export const CI_STEMS = [
  "python",
  "powershell",
  "typescript",
  "dotnet",
] as const;

/** One workflow stem. */
export type CiStem = (typeof CI_STEMS)[number];

/** Repository that holds the `harness-<stem>.yml` reusable workflows. */
export const CI_HARNESS_REPOSITORY = "drmoisan/drm-copilot";

/** Template line replaced by the rendered pack jobs. */
export const CI_JOBS_MARKER = "__DRM_COPILOT_CI_JOBS__";

/** Template line replaced by the gate job's `needs` list. */
export const CI_GATE_NEEDS_MARKER = "__DRM_COPILOT_CI_GATE_NEEDS__";

/** Fragment token replaced by the job's `uses` reference. */
export const CI_USES_MARKER = "__DRM_COPILOT_CI_USES__";

/** Fragment line replaced by the job's `with` block. */
export const CI_WITH_MARKER = "__DRM_COPILOT_CI_WITH__";

/** One job of the rendered caller. */
export interface CiPackJob {
  readonly stem: CiStem;
  /** C# variant; present only for the `dotnet` job. */
  readonly variant?: "modern" | "legacy";
}

/** One recorded or resolved pack selection. */
export interface CiSelectionRecord {
  readonly packs: ReadonlyArray<string>;
  readonly csharpVariant?: string;
}

/** Inputs of {@link renderCiCaller}. */
export interface CiCallerRenderInput {
  readonly mode: Exclude<CiWorkflowsMode, "off">;
  readonly jobs: ReadonlyArray<CiPackJob>;
  readonly payloadVersion: string;
  /** Caller template text. */
  readonly template: string;
  /** Job fragment text per stem. */
  readonly fragments: Readonly<Partial<Record<CiStem, string>>>;
}

/**
 * Return the destination path of a copy-mode workflow copy.
 *
 * @param stem Workflow stem.
 * @returns `.github/workflows/drm-copilot-<stem>.yml`.
 */
export function ciCopyRelativePath(stem: CiStem): string {
  return `.github/workflows/drm-copilot-${stem}.yml`;
}

/**
 * Return the resources-relative source of a bundled reusable workflow.
 *
 * @param stem Workflow stem.
 * @returns `ci-workflows/workflows/harness-<stem>.yml`.
 */
export function ciWorkflowSource(stem: CiStem): string {
  return `${CI_BUNDLE_DIRECTORY}/workflows/harness-${stem}.yml`;
}

/**
 * Return the resources-relative source of a caller job fragment.
 *
 * @param stem Workflow stem.
 * @returns `ci-workflows/caller/jobs/<stem>.yml`.
 */
export function ciFragmentSource(stem: CiStem): string {
  return `${CI_BUNDLE_DIRECTORY}/caller/jobs/${stem}.yml`;
}

/**
 * Parse a `ci_workflows` value.
 *
 * @param value Raw value.
 * @returns The mode.
 * @throws Error Naming the value when it is not `off`, `reference`, or `copy`.
 */
export function parseCiWorkflowsMode(value: unknown): CiWorkflowsMode {
  const match = CI_WORKFLOWS_MODES.find((mode) => mode === value);
  if (match === undefined) {
    const shown = typeof value === "string" ? value : JSON.stringify(value);
    throw new Error(
      `Field 'ci_workflows' must be one of off, reference, copy when provided; received '${shown}'.`,
    );
  }
  return match;
}

/**
 * Infer the recorded CI mode from a destination manifest.
 *
 * @param manifest Destination manifest, when present.
 * @returns `off` without a data-file entry; `copy` with the data-file entry
 *   and at least one `drm-copilot-<stem>.yml` entry; otherwise `reference`.
 */
export function inferCiWorkflowsMode(
  manifest: DestinationManifest | undefined,
): CiWorkflowsMode {
  const files = manifest?.files ?? {};
  if (files[CI_DATA_FILE_RELATIVE_PATH] === undefined) {
    return "off";
  }
  return CI_STEMS.some((stem) => files[ciCopyRelativePath(stem)] !== undefined)
    ? "copy"
    : "reference";
}

/**
 * Map one pack name to its canonical C#-qualified name and job.
 *
 * @param pack Pack name.
 * @param csharpVariant Recorded C# variant of the selection.
 * @returns The canonical pack name and job, or `undefined` for a pack with no
 *   CI job (`core` and unknown names).
 */
function packJob(
  pack: string,
  csharpVariant: string | undefined,
): { readonly name: string; readonly job: CiPackJob } | undefined {
  switch (pack) {
    case "python":
    case "powershell":
    case "typescript":
      return { name: pack, job: { stem: pack } };
    case "csharp-modern":
      return { name: pack, job: { stem: "dotnet", variant: "modern" } };
    case "csharp-legacy":
      return { name: pack, job: { stem: "dotnet", variant: "legacy" } };
    case "csharp": {
      const variant = csharpVariant === "legacy" ? "legacy" : "modern";
      return {
        name: `csharp-${variant}`,
        job: { stem: "dotnet", variant },
      };
    }
    default:
      return undefined;
  }
}

/**
 * Resolve the caller jobs of a selection union.
 *
 * @param selectionRecords Selections of every ecosystem in the union.
 * @returns One job per selected language pack, in {@link CI_STEMS} order.
 * @throws ManifestError When the union holds both C# variants.
 */
export function resolveCiPackJobs(
  selectionRecords: ReadonlyArray<CiSelectionRecord>,
): CiPackJob[] {
  const names = new Set<string>();
  const jobs = new Map<CiStem, CiPackJob>();
  for (const record of selectionRecords) {
    for (const pack of record.packs) {
      const mapped = packJob(pack, record.csharpVariant);
      if (mapped !== undefined) {
        names.add(mapped.name);
        jobs.set(mapped.job.stem, mapped.job);
      }
    }
  }
  assertSingleCsharpToolchain(new Set<string>(), names);
  return CI_STEMS.flatMap((stem) => {
    const job = jobs.get(stem);
    return job === undefined ? [] : [job];
  });
}

/**
 * Return the `with` inputs of one job.
 *
 * @param job Caller job.
 * @param mode Delivery mode.
 * @param payloadVersion Extension version the reference pin uses.
 * @returns Input name and literal value pairs, in render order.
 */
function jobInputs(
  job: CiPackJob,
  mode: Exclude<CiWorkflowsMode, "off">,
  payloadVersion: string,
): Array<readonly [string, string]> {
  if (job.stem === "dotnet") {
    return [["variant", job.variant ?? "modern"]];
  }
  if (job.stem !== "powershell") {
    return [];
  }
  return mode === "reference"
    ? [
        ["harness_repository", CI_HARNESS_REPOSITORY],
        ["harness_ref", `v${payloadVersion}`],
      ]
    : [["poshqc", "false"]];
}

/**
 * Replace the single line holding a marker with replacement lines.
 *
 * @param text Text to edit (LF line endings).
 * @param marker Marker token.
 * @param render Builds the replacement lines from the marker line's indent.
 * @returns The edited text.
 * @throws Error When the marker is absent.
 */
function replaceMarkerLine(
  text: string,
  marker: string,
  render: (indent: string) => ReadonlyArray<string>,
): string {
  const lines = text.split("\n");
  const index = lines.findIndex((line) => line.trim() === marker);
  if (index < 0) {
    throw new Error(`CI template is missing the marker line ${marker}.`);
  }
  const line = lines[index] ?? "";
  const indent = line.slice(0, line.length - line.trimStart().length);
  return [
    ...lines.slice(0, index),
    ...render(indent),
    ...lines.slice(index + 1),
  ].join("\n");
}

/**
 * Render one caller job from its fragment.
 *
 * @param job Caller job.
 * @param input Render input.
 * @returns The job text without a trailing newline.
 * @throws Error When the fragment is absent or lacks a marker.
 */
function renderJob(job: CiPackJob, input: CiCallerRenderInput): string {
  const fragment = input.fragments[job.stem];
  if (fragment === undefined) {
    throw new Error(`CI job fragment for ${job.stem} is missing.`);
  }
  const normalized = fragment.replace(/\r\n?/g, "\n").replace(/\n+$/, "");
  if (!normalized.includes(CI_USES_MARKER)) {
    throw new Error(`CI job fragment for ${job.stem} lacks ${CI_USES_MARKER}.`);
  }
  const uses =
    input.mode === "reference"
      ? `${CI_HARNESS_REPOSITORY}/.github/workflows/harness-${job.stem}.yml@v${input.payloadVersion}`
      : `./${ciCopyRelativePath(job.stem)}`;
  const inputs = jobInputs(job, input.mode, input.payloadVersion);
  return replaceMarkerLine(
    normalized.split(CI_USES_MARKER).join(uses),
    CI_WITH_MARKER,
    (indent) =>
      inputs.length === 0
        ? []
        : [
            `${indent}with:`,
            ...inputs.map(([name, value]) => `${indent}  ${name}: ${value}`),
          ],
  );
}

/**
 * Render the destination caller workflow.
 *
 * @param input Mode, jobs, payload version, template, and fragments.
 * @returns The caller text with LF line endings.
 * @throws Error When the template or a needed fragment lacks a marker.
 */
export function renderCiCaller(input: CiCallerRenderInput): string {
  const template = input.template.replace(/\r\n?/g, "\n");
  const jobIds = input.jobs.map((job) => job.stem);
  const withJobs = replaceMarkerLine(template, CI_JOBS_MARKER, () =>
    input.jobs.flatMap((job) => renderJob(job, input).split("\n")),
  );
  return replaceMarkerLine(withJobs, CI_GATE_NEEDS_MARKER, (indent) =>
    jobIds.length === 0
      ? []
      : [`${indent}needs:`, ...jobIds.map((id) => `${indent}  - ${id}`)],
  );
}
