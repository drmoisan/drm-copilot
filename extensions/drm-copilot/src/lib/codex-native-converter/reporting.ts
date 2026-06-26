/**
 * Write review and apply artifacts for the Codex-native converter.
 *
 * Purpose:
 *     Emit the required report artifact set for review and apply runs in a
 *     stable, deterministic layout. Ported from `reporting.py`; the Markdown
 *     report renderer lives in `reporting-render.ts` so neither file exceeds the
 *     500-line policy. Writes flow through the injected {@link FileSystem}.
 *
 * Invariants:
 *     Artifact filenames and serialization ordering remain stable across runs
 *     for the same inputs. JSON catalogs use sorted keys, 2-space indentation,
 *     and a trailing newline, matching the Python `json.dumps` usage.
 */

import { type FileSystem } from "../file-system";
import {
  type MappingRecord,
  mappingRecordToJson,
  type RunOptions,
  type TopologyEdge,
  type TranslationTrace,
  type ValidationFinding,
  validationFindingToJson,
} from "./models";
import { renderConversionReport } from "./reporting-render";

/**
 * The artifact paths written for one converter run.
 *
 * Mirrors `ReportSetPaths`. All stored paths are rooted beneath the artifact
 * root.
 */
export interface ReportSetPaths {
  readonly conversionReport: string;
  readonly mappingCatalog: string;
  readonly validationResults: string;
  readonly proposedTreeRoot: string;
}

/**
 * Recursively sort object keys so serialization matches Python `sort_keys=True`.
 *
 * @param value Value to normalize for deterministic serialization.
 * @returns A structurally equivalent value with all object keys sorted.
 */
function sortKeysDeep(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => sortKeysDeep(item));
  }
  if (value !== null && typeof value === "object") {
    const sorted: Record<string, unknown> = {};
    for (const key of Object.keys(value as Record<string, unknown>).sort(
      (left, right) => (left < right ? -1 : left > right ? 1 : 0),
    )) {
      sorted[key] = sortKeysDeep((value as Record<string, unknown>)[key]);
    }
    return sorted;
  }
  return value;
}

/**
 * Serialize a JSON-safe payload with sorted keys, 2-space indentation, and a
 * trailing newline, matching `json.dumps(..., indent=2, sort_keys=True) + "\n"`.
 *
 * @param payload JSON-safe value to serialize.
 * @returns The deterministic JSON string with a trailing newline.
 */
function dumpsSortedWithNewline(payload: unknown): string {
  return JSON.stringify(sortKeysDeep(payload), null, 2) + "\n";
}

/**
 * Collapse `.`/`..` segments in a POSIX path, mirroring `Path.resolve` segment
 * handling for already-absolute inputs.
 *
 * @param value POSIX path.
 * @returns The path with relative segments collapsed.
 */
function collapseSegments(value: string): string {
  const isAbsolute = value.startsWith("/");
  const driveMatch = /^([A-Za-z]:)(.*)$/.exec(value);
  const drive = driveMatch ? (driveMatch[1] ?? "") : "";
  const body = driveMatch ? (driveMatch[2] ?? "") : value;
  const resolved: string[] = [];
  for (const segment of body.split("/")) {
    if (segment === "" || segment === ".") {
      continue;
    }
    if (segment === "..") {
      if (resolved.length > 0) {
        resolved.pop();
      }
      continue;
    }
    resolved.push(segment);
  }
  const joined = resolved.join("/");
  if (drive) {
    return `${drive}/${joined}`;
  }
  return isAbsolute ? `/${joined}` : joined;
}

/**
 * Join a POSIX root with a child path segment.
 *
 * @param root POSIX root path.
 * @param child Child path segment.
 * @returns The combined POSIX path.
 */
function joinPosix(root: string, child: string): string {
  const normalizedRoot = root.replace(/\/+$/, "");
  const normalizedChild = child.replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedChild
    : `${normalizedRoot}/${normalizedChild}`;
}

/**
 * Sort mapping records by source path, returning a new array.
 *
 * @param mappingRecords Mapping records to sort.
 * @returns The records sorted by source path.
 */
function sortBySourcePath(
  mappingRecords: ReadonlyArray<MappingRecord>,
): MappingRecord[] {
  return [...mappingRecords].sort((left, right) =>
    left.sourcePath < right.sourcePath
      ? -1
      : left.sourcePath > right.sourcePath
        ? 1
        : 0,
  );
}

/**
 * Sort validation findings by (code, sourcePath, targetPath).
 *
 * @param validationFindings Findings to sort.
 * @returns The findings sorted by stable key.
 */
function sortFindings(
  validationFindings: ReadonlyArray<ValidationFinding>,
): ValidationFinding[] {
  const compare = (left: string, right: string): number =>
    left < right ? -1 : left > right ? 1 : 0;
  return [...validationFindings].sort((left, right) => {
    const byCode = compare(left.code, right.code);
    if (byCode !== 0) {
      return byCode;
    }
    const bySource = compare(left.sourcePath ?? "", right.sourcePath ?? "");
    if (bySource !== 0) {
      return bySource;
    }
    return compare(left.targetPath ?? "", right.targetPath ?? "");
  });
}

/**
 * Write the required review/apply report artifact set.
 *
 * Mirrors `write_conversion_report_set`: resolves the artifact root, creates
 * the artifact and proposed-tree directories, writes the Markdown report and
 * sorted JSON catalogs, and writes the proposed tree in sorted path order.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecords Planned mappings.
 * @param topologyEdges Derived topology edges for Mermaid rendering.
 * @param translationTraces Section-level translation traces.
 * @param validationFindings Validation results.
 * @param generatedOutput Generated output keyed by target path.
 * @returns Paths to the written report artifacts.
 * @throws Error When an artifact cannot be written.
 */
export function writeConversionReportSet(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
  topologyEdges: ReadonlyArray<TopologyEdge>,
  translationTraces: ReadonlyArray<TranslationTrace>,
  validationFindings: ReadonlyArray<ValidationFinding>,
  generatedOutput: Readonly<Record<string, string>>,
): ReportSetPaths {
  const artifactRoot = collapseSegments(runOptions.artifactRoot);
  const proposedTreeRoot = joinPosix(artifactRoot, "proposed-tree");
  const reportPaths: ReportSetPaths = {
    conversionReport: joinPosix(artifactRoot, "conversion-report.md"),
    mappingCatalog: joinPosix(artifactRoot, "mapping-catalog.json"),
    validationResults: joinPosix(artifactRoot, "validation-results.json"),
    proposedTreeRoot,
  };

  fileSystem.ensureDir(artifactRoot);
  fileSystem.ensureDir(proposedTreeRoot);

  const mappingCatalogPayload = sortBySourcePath(mappingRecords).map((record) =>
    mappingRecordToJson(record),
  );
  const validationResultsPayload = sortFindings(validationFindings).map(
    (finding) => validationFindingToJson(finding),
  );

  fileSystem.writeTextFile(
    reportPaths.conversionReport,
    renderConversionReport(
      runOptions,
      mappingRecords,
      topologyEdges,
      translationTraces,
      validationFindings,
    ),
  );
  fileSystem.writeTextFile(
    reportPaths.mappingCatalog,
    dumpsSortedWithNewline(mappingCatalogPayload),
  );
  fileSystem.writeTextFile(
    reportPaths.validationResults,
    dumpsSortedWithNewline(validationResultsPayload),
  );

  // Write the proposed tree in stable path order so review runs always emit a
  // deterministic snapshot of the generated content.
  for (const targetPath of Object.keys(generatedOutput).sort((left, right) =>
    left < right ? -1 : left > right ? 1 : 0,
  )) {
    fileSystem.writeTextFile(
      joinPosix(proposedTreeRoot, targetPath),
      generatedOutput[targetPath] ?? "",
    );
  }

  return reportPaths;
}
