/**
 * Discover and parse canonical feature verification evidence artifacts.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/verification_evidence.py`. Provide
 *     deterministic discovery and strict schema parsing for canonical evidence
 *     markdown files so PR context generation can make traceable verification
 *     claims.
 *
 * Flow:
 *     1. Discover canonical evidence files under an active feature folder.
 *     2. Parse required schema fields from each markdown file.
 *     3. Normalize pass/fail/unparseable status from `EXIT_CODE`.
 *
 * Responsibilities:
 *     - All filesystem access flows through the injected {@link FileSystem}
 *       (`exists`/`isDirectory`/`glob`/`readTextFile`) so the module is
 *       hermetic.
 */

import { type FileSystem, toPosixPath } from "../file-system";

/** Required schema fields parsed from an evidence markdown file. */
export const REQUIRED_FIELDS = ["Timestamp", "Command", "EXIT_CODE"] as const;

/** Optional schema field declaring the exit code a gate is expected to produce. */
export const EXPECTED_EXIT_CODE_FIELD = "ExpectedExitCode";

/** Canonical evidence glob roots, searched in fixed order. */
export const CANONICAL_GLOBS = [
  "evidence/qa-gates/**/*.md",
  "evidence/regression-testing/**/*.md",
  "evidence/other/**/*.md",
] as const;

/** Deterministic verification result derived from `EXIT_CODE`. */
export type NormalizedResult = "pass" | "fail" | "unparseable";

/** One parsed canonical evidence artifact. */
export interface VerificationEvidenceRecord {
  readonly feature: string;
  readonly sourceFile: string;
  readonly timestamp: string | null;
  readonly command: string | null;
  readonly exitCode: number | null;
  readonly normalizedResult: NormalizedResult;
  /**
   * Declared expected exit code. Defaults to `0` when the optional
   * `ExpectedExitCode` field is absent, and is `0` on every `unparseable` path.
   */
  readonly expectedExitCode: number;
}

/**
 * Normalize an observed exit code against its declared expectation.
 *
 * Mirrors Python `normalize_result`. Pure: performs no I/O.
 *
 * @param exitCode Observed process exit code parsed from `EXIT_CODE`.
 * @param expectedExitCode Declared expectation, `0` when undeclared.
 * @returns `pass` when the observed code equals the expectation, `fail` otherwise.
 */
export function normalizeResult(
  exitCode: number,
  expectedExitCode: number,
): NormalizedResult {
  return exitCode === expectedExitCode ? "pass" : "fail";
}

/**
 * Discover canonical evidence files for one active feature.
 *
 * Mirrors Python `discover_canonical_evidence_files`: when the feature root is
 * absent or not a directory, returns `[]`; otherwise globs the three canonical
 * roots (fixed order), keeps files, deduplicates, and returns repo-relative
 * POSIX paths sorted by code point.
 *
 * @param fs Injected filesystem.
 * @param root Repository root path.
 * @param feature Active feature directory name under `docs/features/active`.
 * @returns Sorted, deduplicated repo-relative POSIX evidence paths.
 */
export function discoverCanonicalEvidenceFiles(
  fs: FileSystem,
  root: string,
  feature: string,
): string[] {
  const normalizedRoot = toPosixPath(root).replace(/\/+$/u, "");
  const featureRoot = `${normalizedRoot}/docs/features/active/${feature}`;
  if (!fs.exists(featureRoot) || !fs.isDirectory(featureRoot)) {
    return [];
  }

  const discovered = new Set<string>();
  // Search canonical evidence roots in a fixed order, then sort for stability.
  for (const pattern of CANONICAL_GLOBS) {
    for (const candidate of fs.glob(featureRoot, pattern)) {
      if (fs.isFile(candidate)) {
        discovered.add(relativeToPosix(normalizedRoot, candidate));
      }
    }
  }
  return [...discovered].sort(compareCodePoint);
}

/**
 * Parse required schema fields and normalize verification status.
 *
 * Mirrors Python `parse_verification_evidence_markdown`: parse `Key: value`
 * rows (first occurrence wins for required fields), and when any required field
 * is missing or `EXIT_CODE` is not an integer, the result is `unparseable`;
 * otherwise `pass` when exit code is `0`, else `fail`.
 *
 * @param params Feature id, source path, and raw markdown content.
 * @returns A normalized evidence record.
 */
export function parseVerificationEvidenceMarkdown(params: {
  feature: string;
  sourceFile: string;
  markdown: string;
}): VerificationEvidenceRecord {
  const { feature, sourceFile, markdown } = params;
  const parsed = new Map<string, string>();

  // Parse `Key: value` rows once, keeping only the first occurrence of each
  // required schema field (mirrors the Python dict-first-write semantics).
  for (const rawLine of splitLines(markdown)) {
    const colonIndex = rawLine.indexOf(":");
    if (colonIndex === -1) {
      continue;
    }
    const key = rawLine.slice(0, colonIndex).trim();
    const value = rawLine.slice(colonIndex + 1).trim();
    if (
      (REQUIRED_FIELDS as readonly string[]).includes(key) &&
      !parsed.has(key)
    ) {
      parsed.set(key, value);
    }
    // Separate `if` rather than `else if` so the required-field block above is
    // left byte-identical; the two conditions are mutually exclusive because the
    // optional expectation field is not one of the required fields.
    if (key === EXPECTED_EXIT_CODE_FIELD && !parsed.has(key)) {
      parsed.set(key, value);
    }
  }

  const timestamp = parsed.get("Timestamp") ?? null;
  const command = parsed.get("Command") ?? null;
  const exitCodeRaw = parsed.get("EXIT_CODE");
  const expectedExitCodeRaw = parsed.get(EXPECTED_EXIT_CODE_FIELD);

  // A missing required field cannot produce a verifiable result.
  if (!timestamp || !command || exitCodeRaw === undefined) {
    return {
      feature,
      sourceFile,
      timestamp,
      command,
      exitCode: null,
      normalizedResult: "unparseable",
      expectedExitCode: 0,
    };
  }

  const exitCode = parseIntegerStrict(exitCodeRaw);
  if (exitCode === null) {
    return {
      feature,
      sourceFile,
      timestamp,
      command,
      exitCode: null,
      normalizedResult: "unparseable",
      expectedExitCode: 0,
    };
  }

  // An undeclared expectation defaults to zero, reproducing prior behavior; a
  // declared but non-integer expectation is as unparseable as a bad EXIT_CODE.
  const expectedExitCode =
    expectedExitCodeRaw === undefined
      ? 0
      : parseIntegerStrict(expectedExitCodeRaw);
  if (expectedExitCode === null) {
    return {
      feature,
      sourceFile,
      timestamp,
      command,
      exitCode: null,
      normalizedResult: "unparseable",
      expectedExitCode: 0,
    };
  }

  const normalizedResult: NormalizedResult = normalizeResult(
    exitCode,
    expectedExitCode,
  );
  return {
    feature,
    sourceFile,
    timestamp,
    command,
    exitCode,
    normalizedResult,
    expectedExitCode,
  };
}

/**
 * Read and parse one canonical evidence file.
 *
 * Mirrors Python `parse_verification_evidence_file`: reads `root/relativePath`
 * through the injected filesystem and parses it; a read failure propagates as a
 * thrown error (the collector catches it, matching the Python `OSError`
 * contract).
 *
 * @param params Filesystem, repo root, feature id, and repo-relative path.
 * @returns The parsed normalized evidence record.
 * @throws Error When the evidence file cannot be read.
 */
export function parseVerificationEvidenceFile(params: {
  fs: FileSystem;
  root: string;
  feature: string;
  relativePath: string;
}): VerificationEvidenceRecord {
  const { fs, root, feature, relativePath } = params;
  const normalizedRoot = toPosixPath(root).replace(/\/+$/u, "");
  const relPosix = toPosixPath(relativePath).replace(/^\/+/u, "");
  const markdown = fs.readTextFile(`${normalizedRoot}/${relPosix}`);
  return parseVerificationEvidenceMarkdown({
    feature,
    sourceFile: relPosix,
    markdown,
  });
}

/**
 * Parse an integer strictly, mirroring Python `int(str)` semantics for the
 * decimal strings evidence files contain.
 *
 * Python `int("0")` succeeds; `int("ok")` raises `ValueError`. This accepts an
 * optionally-signed run of decimal digits and rejects anything else.
 *
 * @param value Trimmed candidate string.
 * @returns The parsed integer, or `null` when not a valid integer.
 */
function parseIntegerStrict(value: string): number | null {
  if (!/^[+-]?\d+$/u.test(value)) {
    return null;
  }
  return Number.parseInt(value, 10);
}

/**
 * Convert an absolute POSIX path under `root` to a repo-relative POSIX path.
 *
 * @param root Normalized repository root (no trailing slash).
 * @param absolute Absolute POSIX path under `root`.
 * @returns The path relative to `root`, without a leading slash.
 */
function relativeToPosix(root: string, absolute: string): string {
  const normalized = toPosixPath(absolute);
  if (normalized.startsWith(`${root}/`)) {
    return normalized.slice(root.length + 1);
  }
  return normalized.replace(/^\/+/u, "");
}

/** Compare two strings by Unicode code point (Python `sorted` semantics). */
function compareCodePoint(left: string, right: string): number {
  if (left < right) {
    return -1;
  }
  if (left > right) {
    return 1;
  }
  return 0;
}

/**
 * Split text into lines the way Python `str.splitlines()` does.
 *
 * @param value Text to split.
 * @returns Lines without terminators.
 */
function splitLines(value: string): string[] {
  if (value === "") {
    return [];
  }
  const lines = value.split(/\r\n|\r|\n/u);
  if (
    lines.length > 0 &&
    lines[lines.length - 1] === "" &&
    /(\r\n|\r|\n)$/u.test(value)
  ) {
    lines.pop();
  }
  return lines;
}
