/**
 * Apply the destination exclusion manifest to the Claude push-down.
 *
 * Purpose:
 *     Port `scripts/dev_tools/push_down_claude_exclusion_filter.py`. Reads
 *     `.push-down-exclusions` through the injected adapter, withholds every
 *     matched payload path at enumeration time, guards destination writes, and
 *     assembles, renders, and persists the exclusion report.
 *
 * Invariants / Constraints:
 *     - {@link ExclusionFilterFileSystem} is the outermost decorator, so a
 *       skipped path never reaches any merge or derive decorator beneath it.
 *     - The manifest path and every matched path are never written through the
 *       filter; the summary artifact directory is exempt from the manifest.
 *     - Nothing here deletes a destination file.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import { stringifySorted } from "./copilot-customizations-engine";
import {
  EXCLUSION_MANIFEST_RELATIVE_PATH,
  type ExclusionEntry,
  type ExclusionManifest,
  ExclusionManifestError,
  matchesExclusionEntry,
  parseExclusionManifest,
  planExclusions,
  type SkippedPath,
} from "./claude-exclusion-manifest";

/** Prefix of every rendered conflict line; the VS Code command counts these. */
export const EXCLUSION_CONFLICT_LINE_PREFIX = "push-down exclusion conflict:";

/**
 * Destination-relative directory of the Claude summary artifact. It equals
 * `ARTIFACT_DIRECTORY` in `claude-customizations.ts`, which passes its own
 * constant explicitly.
 */
const DEFAULT_ARTIFACT_DIRECTORY = "artifacts/claude-customizations";

/** Raised when a write targets the manifest path or an excluded path. */
export class ExclusionViolationError extends Error {
  /**
   * @param message Description of the refused write.
   */
  constructor(message: string) {
    super(message);
    this.name = "ExclusionViolationError";
  }
}

/** The exclusion outcome of one push-down run with a manifest. */
export interface ExclusionReport {
  /** Destination-relative manifest path. */
  readonly manifestPath: string;
  /** Manifest entries in file order. */
  readonly entries: ReadonlyArray<ExclusionEntry>;
  /** Skipped paths in enumeration order. */
  readonly skipped: ReadonlyArray<SkippedPath>;
  /** Entries that were the first match of no skipped path, in file order. */
  readonly unmatchedEntries: ReadonlyArray<ExclusionEntry>;
}

/**
 * Normalize a path to forward slashes with no trailing slash.
 *
 * @param value Path in any separator style.
 * @returns The normalized POSIX path.
 */
function normalizePosix(value: string): string {
  return value.replace(/\\/g, "/").replace(/\/+$/, "");
}

/**
 * Return `path` relative to `root` as POSIX text, or `undefined` outside it.
 *
 * @param path Candidate child path.
 * @param root Candidate parent path.
 * @returns The relative POSIX path, or `undefined`.
 */
function relativeToPosix(path: string, root: string): string | undefined {
  const normalizedPath = normalizePosix(path);
  const prefix = `${normalizePosix(root)}/`;
  return normalizedPath.startsWith(prefix)
    ? normalizedPath.slice(prefix.length)
    : undefined;
}

/**
 * Return the first manifest entry that matches a candidate.
 *
 * @param manifest Parsed manifest.
 * @param candidate Destination-relative POSIX path.
 * @returns The first matching entry, or `undefined`.
 */
function findFirstMatch(
  manifest: ExclusionManifest,
  candidate: string,
): ExclusionEntry | undefined {
  return manifest.entries.find((entry) =>
    matchesExclusionEntry(entry, candidate),
  );
}

/**
 * Outermost decorator that withholds manifest-matched payload paths.
 *
 * Drops matched source files from `listFiles` so the engine never reads,
 * merges, derives, or writes them, records each skip with its destination
 * status, and refuses any write to an excluded path.
 */
export class ExclusionFilterFileSystem implements PushDownFileSystem {
  /** Skip records in enumeration order. */
  readonly skipped: SkippedPath[] = [];
  private readonly inner: PushDownFileSystem;
  private readonly sourceRoot: string;
  private readonly destinationRoot: string;
  private readonly manifest: ExclusionManifest;
  private readonly artifactPrefix: string;

  /**
   * @param inner Adapter the engine would otherwise use.
   * @param sourceRoot Root the engine enumerates payload files under.
   * @param destinationRoot Destination workspace root.
   * @param manifest Parsed manifest.
   * @param artifactDirectory Destination-relative summary-artifact directory
   *   exempt from the write guard.
   */
  constructor(
    inner: PushDownFileSystem,
    sourceRoot: string,
    destinationRoot: string,
    manifest: ExclusionManifest,
    artifactDirectory: string = DEFAULT_ARTIFACT_DIRECTORY,
  ) {
    this.inner = inner;
    this.sourceRoot = normalizePosix(sourceRoot);
    this.destinationRoot = normalizePosix(destinationRoot);
    this.manifest = manifest;
    this.artifactPrefix = `${normalizePosix(artifactDirectory)}/`;
  }

  listFiles(root: string): string[] {
    const listed = this.inner.listFiles(root);
    const relativeByPath = listed.map(
      (path) => [path, relativeToPosix(path, this.sourceRoot)] as const,
    );
    const candidates = relativeByPath.flatMap(([, relative]) =>
      relative === undefined ? [] : [relative],
    );
    const plan = planExclusions(candidates, this.manifest, (relative) =>
      this.inner.isFile(`${this.destinationRoot}/${relative}`),
    );
    this.skipped.push(...plan.skipped);
    const kept = new Set(plan.kept);
    // Paths outside the source root cannot map to a destination path and are
    // passed through unchanged.
    return relativeByPath
      .filter(([, relative]) => relative === undefined || kept.has(relative))
      .map(([path]) => path);
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    return this.inner.isFile(path);
  }

  readTextFile(path: string): string {
    return this.inner.readTextFile(path);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }

  /**
   * Write through the inner adapter unless the target is excluded.
   *
   * @param path Target path.
   * @param content Text to write.
   * @throws ExclusionViolationError When the destination-relative target is
   *   the manifest path or matches a manifest entry.
   */
  writeTextFile(path: string, content: string): void {
    const relative = relativeToPosix(path, this.destinationRoot);
    // Targets outside the destination and the summary artifact are not subject
    // to the manifest and pass through unconditionally.
    if (relative !== undefined && !relative.startsWith(this.artifactPrefix)) {
      if (relative === EXCLUSION_MANIFEST_RELATIVE_PATH) {
        throw new ExclusionViolationError(
          `Refusing to write the push-down exclusion manifest: ${relative}`,
        );
      }
      const entry = findFirstMatch(this.manifest, relative);
      if (entry !== undefined) {
        throw new ExclusionViolationError(
          `Refusing to write excluded path ${relative} (entry ${entry.normalized}, line ${String(entry.line)})`,
        );
      }
    }
    this.inner.writeTextFile(path, content);
  }
}

/**
 * Read and parse the destination manifest, or return `undefined` when absent.
 *
 * `readFileSync(path, "utf8")` substitutes U+FFFD for undecodable bytes rather
 * than throwing, so undecodable text is rejected by the parser instead.
 *
 * @param fs Adapter used to probe and read the manifest.
 * @param destinationRoot Destination workspace root.
 * @returns The parsed manifest, or `undefined` when no manifest exists.
 * @throws ExclusionManifestError When a directory sits at the manifest path or
 *   an entry is malformed.
 */
export function readExclusionManifest(
  fs: PushDownFileSystem,
  destinationRoot: string,
): ExclusionManifest | undefined {
  const manifestPath = `${normalizePosix(destinationRoot)}/${EXCLUSION_MANIFEST_RELATIVE_PATH}`;
  if (!fs.isFile(manifestPath)) {
    if (fs.isDir(manifestPath)) {
      throw new ExclusionManifestError(
        EXCLUSION_MANIFEST_RELATIVE_PATH,
        undefined,
        "path is not a regular file",
      );
    }
    return undefined;
  }
  return parseExclusionManifest(
    fs.readTextFile(manifestPath),
    EXCLUSION_MANIFEST_RELATIVE_PATH,
  );
}

/**
 * Assemble the report from the manifest and the recorded skips.
 *
 * @param manifest Parsed manifest.
 * @param skipped Skip records in enumeration order.
 * @returns The exclusion report.
 */
export function buildExclusionReport(
  manifest: ExclusionManifest,
  skipped: ReadonlyArray<SkippedPath>,
): ExclusionReport {
  const claimed = new Set(
    skipped.map((skip) => `${String(skip.line)}\u0000${skip.entry}`),
  );
  return {
    manifestPath: manifest.path,
    entries: manifest.entries,
    skipped: [...skipped],
    unmatchedEntries: manifest.entries.filter(
      (entry) => !claimed.has(`${String(entry.line)}\u0000${entry.normalized}`),
    ),
  };
}

/**
 * Render one line per skipped path, then one per unmatched entry.
 *
 * @param report Exclusion report.
 * @returns The pinned-format lines in order.
 */
export function renderExclusionLines(report: ExclusionReport): string[] {
  const skippedLines = report.skipped.map((skip) => {
    const suffix = `${skip.relativePath} (entry ${skip.entry}, line ${String(skip.line)})`;
    return skip.destinationStatus === "present"
      ? `${EXCLUSION_CONFLICT_LINE_PREFIX} destination file present, not overwritten: ${suffix}`
      : `push-down exclusion: skipped ${suffix}`;
  });
  const unmatchedLines = report.unmatchedEntries.map(
    (entry) =>
      `push-down exclusion: entry matched no payload path: ${entry.normalized} (line ${String(entry.line)})`,
  );
  return [...skippedLines, ...unmatchedLines];
}

/**
 * Return the JSON-ready `exclusions` object for the summary artifact.
 *
 * @param report Exclusion report.
 * @returns The snake_case payload object.
 */
export function exclusionReportPayload(
  report: ExclusionReport,
): Record<string, unknown> {
  return {
    conflict_count: report.skipped.filter(
      (skip) => skip.destinationStatus === "present",
    ).length,
    entries: report.entries.map((entry) => entry.normalized),
    manifest_path: report.manifestPath,
    skipped: report.skipped.map((skip) => ({
      destination_status: skip.destinationStatus,
      entry: skip.entry,
      line: skip.line,
      relative_path: skip.relativePath,
    })),
    skipped_count: report.skipped.length,
    unmatched_entries: report.unmatchedEntries.map((entry) => entry.normalized),
  };
}

/**
 * Add the `exclusions` object to the written artifact with sorted keys.
 *
 * @param fs Adapter used to read and rewrite the artifact.
 * @param artifactPath Path of the artifact the engine wrote.
 * @param report Exclusion report.
 * @throws Error When the artifact does not hold a JSON object.
 */
export function appendExclusionsToArtifact(
  fs: PushDownFileSystem,
  artifactPath: string,
  report: ExclusionReport,
): void {
  const payload: unknown = JSON.parse(fs.readTextFile(artifactPath));
  if (
    payload === null ||
    typeof payload !== "object" ||
    Array.isArray(payload)
  ) {
    throw new Error(`Summary artifact is not a JSON object: ${artifactPath}`);
  }
  const document: Record<string, unknown> = {
    ...(payload as Record<string, unknown>),
    exclusions: exclusionReportPayload(report),
  };
  fs.writeTextFile(artifactPath, stringifySorted(document, 2));
}
