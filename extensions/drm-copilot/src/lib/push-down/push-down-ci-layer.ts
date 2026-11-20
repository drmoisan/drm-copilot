/**
 * Shared-layer contribution of the destination CI workflows (issue #1050).
 *
 * Purpose:
 *     Turn an enabled `ci_workflows` mode into root-file pairs of the shared
 *     layer: the rendered caller, the data file, the opt-in command, and in
 *     copy mode the selected reusable-workflow copies. Every CI path is
 *     protected from `overwrite_unmanaged`, and the caller is withheld when
 *     another destination workflow is already named `CI`.
 *
 * Invariants / Constraints:
 *     - Reads only; every write goes through the pipeline and the writer.
 *     - No path under `.github/workflows/` other than the caller and the
 *       selected copies is ever contributed.
 *
 * Side effects:
 *     Reads the bundle and the destination workflow folder through the adapter.
 */

import { type PushDownFileSystem, toPosixPath } from "./filesystem-adapter";
import { MANIFEST_CORE_PACK } from "./push-down-destination-manifest";
import { type PushDownLayer, type RootFilePair } from "./push-down-layer";
import { joinPosix } from "./push-down-pipeline";
import { PUSH_DOWN_CONFLICT_LINE_PREFIX } from "./push-down-report";
import {
  CI_CALLER_RELATIVE_PATH,
  CI_CALLER_TEMPLATE_SOURCE,
  CI_COMMAND_RELATIVE_PATH,
  CI_COMMAND_SOURCE,
  CI_DATA_FILE_RELATIVE_PATH,
  CI_DATA_FILE_SOURCE,
  CI_JOBS_MARKER,
  CI_STEMS,
  ciCopyRelativePath,
  ciFragmentSource,
  type CiPackJob,
  type CiSelectionRecord,
  type CiStem,
  ciWorkflowSource,
  type CiWorkflowsMode,
  renderCiCaller,
  resolveCiPackJobs,
} from "./push-down-ci-workflows";

/** Destination folder whose workflow names are checked for a collision. */
const WORKFLOWS_DIRECTORY = ".github/workflows";

/** A top-level `name: CI` line, quoted or unquoted, with an optional comment. */
const CI_NAME_LINE = /^name:[ \t]*(?:"CI"|'CI'|CI)[ \t]*(?:#.*)?$/;

/** Inputs of {@link buildCiWorkflowsContribution}. */
export interface CiWorkflowsContributionInput {
  readonly fs: PushDownFileSystem;
  /** Extension `resources` root. */
  readonly resourcesRoot: string;
  readonly destinationRoot: string;
  readonly mode: Exclude<CiWorkflowsMode, "off">;
  /** Selections of the run and the recorded selections of other ecosystems. */
  readonly selectionRecords: ReadonlyArray<CiSelectionRecord>;
  readonly payloadVersion: string;
}

/** CI files contributed to the shared layer. */
export interface CiWorkflowsContribution {
  /** Root-file pairs, caller first when it is not withheld. */
  readonly rootFiles: ReadonlyArray<RootFilePair>;
  /** Owning pack per contributed destination path. */
  readonly packByPath: Readonly<Record<string, string>>;
  /** CI paths classified with `overwrite_unmanaged` false. */
  readonly protectedPaths: ReadonlyArray<string>;
  /** Rendered caller text. */
  readonly callerText: string;
  /** `push-down conflict:` lines of a workflow-name collision. */
  readonly warnings: ReadonlyArray<string>;
}

/**
 * Return the language pack name that owns a job's copy.
 *
 * @param job Caller job.
 * @returns The pack name (`csharp-<variant>` for the .NET job).
 */
export function ciJobPackName(job: CiPackJob): string {
  return job.stem === "dotnet" ? `csharp-${job.variant ?? "modern"}` : job.stem;
}

/**
 * Find destination workflows other than the caller whose top-level name is CI.
 *
 * @param fs Destination adapter.
 * @param destinationRoot Destination root.
 * @returns One `push-down conflict:` line per colliding workflow file.
 */
export function findCiWorkflowNameCollisions(
  fs: PushDownFileSystem,
  destinationRoot: string,
): string[] {
  const directory = joinPosix(destinationRoot, WORKFLOWS_DIRECTORY);
  const prefix = `${directory}/`;
  const lines: string[] = [];
  for (const path of fs.listFiles(directory).map(toPosixPath)) {
    const name = path.startsWith(prefix) ? path.slice(prefix.length) : "";
    const relativePath = `${WORKFLOWS_DIRECTORY}/${name}`;
    if (
      name === "" ||
      name.includes("/") ||
      !/\.ya?ml$/.test(name) ||
      relativePath === CI_CALLER_RELATIVE_PATH
    ) {
      continue;
    }
    const declaresCi = fs
      .readTextFile(path)
      .split(/\r\n?|\n/)
      .some((line) => CI_NAME_LINE.test(line));
    if (declaresCi) {
      lines.push(
        `${PUSH_DOWN_CONFLICT_LINE_PREFIX} workflow-name ${relativePath} (layer shared, pack ${MANIFEST_CORE_PACK}): declares name CI; the caller ${CI_CALLER_RELATIVE_PATH} was not written.`,
      );
    }
  }
  return lines;
}

/**
 * Build the CI contribution of an enabled mode.
 *
 * @param input Adapter, roots, mode, selection union, and payload version.
 * @returns The root-file pairs, packs, protected paths, caller, and warnings.
 * @throws ManifestError When the selection union holds both C# variants.
 * @throws Error When the bundled template or a needed fragment is invalid.
 */
export function buildCiWorkflowsContribution(
  input: CiWorkflowsContributionInput,
): CiWorkflowsContribution {
  const jobs = resolveCiPackJobs(input.selectionRecords);
  const read = (source: string): string =>
    input.fs.readTextFile(joinPosix(input.resourcesRoot, source));
  const fragments: Partial<Record<CiStem, string>> = {};
  for (const job of jobs) {
    fragments[job.stem] = read(ciFragmentSource(job.stem));
  }
  const callerText = renderCiCaller({
    mode: input.mode,
    jobs,
    payloadVersion: input.payloadVersion,
    template: read(CI_CALLER_TEMPLATE_SOURCE),
    fragments,
  });
  const warnings = findCiWorkflowNameCollisions(
    input.fs,
    input.destinationRoot,
  );
  const packByPath: Record<string, string> = {
    [CI_CALLER_RELATIVE_PATH]: MANIFEST_CORE_PACK,
    [CI_DATA_FILE_RELATIVE_PATH]: MANIFEST_CORE_PACK,
    [CI_COMMAND_RELATIVE_PATH]: MANIFEST_CORE_PACK,
  };
  const rootFiles: RootFilePair[] = [
    ...(warnings.length === 0
      ? [[CI_CALLER_RELATIVE_PATH, CI_CALLER_TEMPLATE_SOURCE] as const]
      : []),
    [CI_DATA_FILE_RELATIVE_PATH, CI_DATA_FILE_SOURCE],
    [CI_COMMAND_RELATIVE_PATH, CI_COMMAND_SOURCE],
  ];
  if (input.mode === "copy") {
    for (const job of jobs) {
      rootFiles.push([
        ciCopyRelativePath(job.stem),
        ciWorkflowSource(job.stem),
      ]);
      packByPath[ciCopyRelativePath(job.stem)] = ciJobPackName(job);
    }
  }
  return {
    rootFiles,
    packByPath,
    protectedPaths: [
      CI_CALLER_RELATIVE_PATH,
      CI_DATA_FILE_RELATIVE_PATH,
      CI_COMMAND_RELATIVE_PATH,
      ...CI_STEMS.map(ciCopyRelativePath),
    ],
    callerText,
    warnings,
  };
}

/**
 * Merge a CI contribution into the shared layer.
 *
 * @param sharedLayer Shared layer built by `buildSharedLayer`.
 * @param contribution CI contribution.
 * @returns The shared layer with the CI root files, the caller rendering, the
 *   CI owning packs, and the protected paths.
 */
export function withCiWorkflows(
  sharedLayer: PushDownLayer,
  contribution: CiWorkflowsContribution,
): PushDownLayer {
  const baseRewrite = sharedLayer.rewrite;
  const baseOwnerPack = sharedLayer.ownerPack.bind(sharedLayer);
  return {
    ...sharedLayer,
    rootFiles: [...sharedLayer.rootFiles, ...contribution.rootFiles],
    // The caller template is the only payload text that holds the jobs marker.
    rewrite: (text) =>
      text.includes(CI_JOBS_MARKER)
        ? [contribution.callerText, 0, 0, []]
        : baseRewrite(text),
    ownerPack: (relativePath) =>
      contribution.packByPath[relativePath] ?? baseOwnerPack(relativePath),
    unmanagedProtectedPaths: [
      ...(sharedLayer.unmanagedProtectedPaths ?? []),
      ...contribution.protectedPaths,
    ],
  };
}
