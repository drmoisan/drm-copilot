/**
 * Destination-owned push-down exclusion manifest: grammar, matcher, and plan.
 *
 * Purpose:
 *     Port `scripts/dev_tools/push_down_exclusion_manifest.py`. Holds the pure
 *     logic behind `.push-down-exclusions`: entry normalization, the manifest
 *     parser with its malformed-entry set, the exact/directory/glob matcher,
 *     and the first-match plan that partitions a payload into kept and skipped
 *     paths. The module performs no I/O; `claude-exclusion-filter.ts` reads the
 *     manifest and applies this plan at enumeration time.
 *
 * Invariants / Constraints:
 *     - Entries are destination-relative POSIX paths compared ordinally and
 *       case-sensitively against payload path strings.
 *     - A wildcard-free entry matches the path itself and every path beneath
 *       it; a trailing `/` documents intent only.
 *     - A wildcard entry uses the `_blast_radius_glob.py` vocabulary (`**`,
 *       `*`, `?`) and must match the whole candidate.
 *     - Entries are evaluated in manifest order; the first match wins.
 */

/** Destination-root location of the manifest, outside every published root. */
export const EXCLUSION_MANIFEST_RELATIVE_PATH = ".push-down-exclusions";

/** Matcher an entry uses. */
export type ExclusionEntryKind = "exact" | "directory" | "glob";

/** Whether the destination already holds a regular file at a skipped path. */
export type DestinationStatus = "present" | "absent";

/** One parsed manifest entry. */
export interface ExclusionEntry {
  /** The line text as written, without the line terminator. */
  readonly raw: string;
  /** The normalized destination-relative entry. */
  readonly normalized: string;
  /** `exact`, `directory`, or `glob`. */
  readonly kind: ExclusionEntryKind;
  /** 1-based line number in the manifest. */
  readonly line: number;
}

/** A parsed manifest: its relative path and entries in file order. */
export interface ExclusionManifest {
  readonly path: string;
  readonly entries: ReadonlyArray<ExclusionEntry>;
}

/** A payload path withheld from the destination by a manifest entry. */
export interface SkippedPath {
  /** Destination-relative POSIX path that was skipped. */
  readonly relativePath: string;
  /** Normalized text of the first matching entry. */
  readonly entry: string;
  /** Manifest line of that entry. */
  readonly line: number;
  /** `present` when the destination already holds the file (a conflict). */
  readonly destinationStatus: DestinationStatus;
}

/** The partition of a payload produced by {@link planExclusions}. */
export interface ExclusionPlan {
  readonly kept: ReadonlyArray<string>;
  readonly skipped: ReadonlyArray<SkippedPath>;
  readonly unmatchedEntries: ReadonlyArray<ExclusionEntry>;
}

/**
 * Raised when the exclusion manifest cannot be trusted.
 *
 * The push-down fails before any destination write when the manifest is not a
 * regular file, is not decodable, or holds a malformed entry.
 */
export class ExclusionManifestError extends Error {
  /** Destination-relative manifest path. */
  readonly path: string;
  /** 1-based offending line, or `undefined` when the whole file is at fault. */
  readonly line: number | undefined;

  /**
   * @param path Destination-relative manifest path.
   * @param line Offending line, or `undefined` for a whole-file condition.
   * @param reason Human-readable reason.
   */
  constructor(path: string, line: number | undefined, reason: string) {
    const location = line === undefined ? path : `${path} line ${String(line)}`;
    super(`Malformed push-down exclusion manifest ${location}: ${reason}`);
    this.name = "ExclusionManifestError";
    this.path = path;
    this.line = line;
  }
}

const BYTE_ORDER_MARK = "﻿";
const REPLACEMENT_CHARACTER = "�";
const LINE_SPLIT = /\r?\n/;
const REPEATED_SLASH = /\/{2,}/g;
const DRIVE_PREFIX = /^[A-Za-z]:/;

/**
 * Report whether normalized entry text contains a glob wildcard.
 *
 * @param normalized Normalized entry text.
 * @returns True when `*` or `?` is present.
 */
function hasWildcard(normalized: string): boolean {
  return normalized.includes("*") || normalized.includes("?");
}

/**
 * Escape one character for literal use inside a regular expression.
 *
 * @param character A single character.
 * @returns The escaped regex source text.
 */
function escapeRegexCharacter(character: string): string {
  return /[\\^$.*+?()[\]{}|/-]/.test(character) ? `\\${character}` : character;
}

/**
 * Translate the supported glob subset into regex source text.
 *
 * Port of `_glob_to_regex_text` in `scripts/dev_tools/_blast_radius_glob.py`:
 * `**` matches any run including separators, `*` any run excluding them, `?`
 * one non-separator character, and every other character is literal.
 *
 * @param pattern Glob pattern.
 * @returns Regex source text for a whole-string match.
 */
function globToRegexText(pattern: string): string {
  const parts: string[] = [];
  let index = 0;
  // Recognize `**` before the single-star rule, because only `**` may cross a
  // directory separator.
  while (index < pattern.length) {
    if (pattern.startsWith("**", index)) {
      parts.push(".*");
      index += 2;
      continue;
    }
    const character = pattern.charAt(index);
    if (character === "*") {
      parts.push("[^/]*");
    } else if (character === "?") {
      parts.push("[^/]");
    } else {
      parts.push(escapeRegexCharacter(character));
    }
    index += 1;
  }
  return parts.join("");
}

/**
 * Report whether a whole candidate matches a whole glob pattern.
 *
 * @param pattern Glob pattern.
 * @param candidate Destination-relative POSIX candidate.
 * @returns True on a full match.
 */
function matchesGlob(pattern: string, candidate: string): boolean {
  // The source is composed only of escaped literals and fixed wildcard
  // fragments, so the constructed expression is always well formed.
  return new RegExp(`^(?:${globToRegexText(pattern)})$`).test(candidate);
}

/**
 * Normalize one entry: trim, `\` to `/`, drop one `./`, collapse `/`.
 *
 * @param raw Entry text as written in the manifest.
 * @returns The normalized entry; empty when nothing remains.
 */
export function normalizeExclusionEntry(raw: string): string {
  let text = raw.trim().replace(/\\/g, "/");
  if (text.startsWith("./")) {
    text = text.slice(2);
  }
  return text.replace(REPEATED_SLASH, "/");
}

/**
 * Return why a normalized entry is malformed, or `undefined` when valid.
 *
 * Checks run in a fixed order so the reported reason is deterministic.
 *
 * @param normalized Normalized entry text.
 * @returns The reason text, or `undefined`.
 */
function malformedReason(normalized: string): string | undefined {
  const checks: ReadonlyArray<readonly [boolean, string]> = [
    [normalized === "", "entry is empty after normalization"],
    [
      normalized.startsWith("/") || DRIVE_PREFIX.test(normalized),
      "entry is an absolute path",
    ],
    [normalized.split("/").includes(".."), "entry contains a '..' segment"],
    [normalized.startsWith("!"), "negation entries are not supported"],
    [
      normalized.includes("[") || normalized.includes("]"),
      "character classes are not supported",
    ],
    [
      hasWildcard(normalized) && normalized.endsWith("/"),
      "a wildcard entry must not end with '/'",
    ],
    [normalized.includes(REPLACEMENT_CHARACTER), "text is not valid UTF-8"],
  ];
  const failed = checks.find(([isFailed]) => isFailed);
  return failed === undefined ? undefined : failed[1];
}

/**
 * Classify a valid normalized entry by the matcher it uses.
 *
 * @param normalized Normalized entry text.
 * @returns The entry kind.
 */
function classify(normalized: string): ExclusionEntryKind {
  if (hasWildcard(normalized)) {
    return "glob";
  }
  return normalized.endsWith("/") ? "directory" : "exact";
}

/**
 * Parse manifest text into entries, failing fast on a malformed entry.
 *
 * @param text Manifest content; a leading byte-order mark is ignored.
 * @param path Destination-relative manifest path used in errors.
 * @returns The entries in file order with 1-based lines.
 * @throws ExclusionManifestError On the first malformed entry.
 */
export function parseExclusionManifest(
  text: string,
  path: string,
): ExclusionManifest {
  const body = text.startsWith(BYTE_ORDER_MARK)
    ? text.slice(BYTE_ORDER_MARK.length)
    : text;
  const entries: ExclusionEntry[] = [];
  body.split(LINE_SPLIT).forEach((raw, offset) => {
    const line = offset + 1;
    const stripped = raw.trim();
    // Blank lines and comment lines carry no entry but still count lines.
    if (stripped === "" || stripped.startsWith("#")) {
      return;
    }
    const normalized = normalizeExclusionEntry(raw);
    const reason = malformedReason(normalized);
    if (reason !== undefined) {
      throw new ExclusionManifestError(path, line, reason);
    }
    entries.push({ raw, normalized, kind: classify(normalized), line });
  });
  return { path, entries };
}

/**
 * Report whether a destination-relative candidate matches an entry.
 *
 * @param entry Parsed manifest entry.
 * @param candidate Destination-relative POSIX payload path.
 * @returns True on an exact, directory-prefix, or whole-glob match.
 */
export function matchesExclusionEntry(
  entry: ExclusionEntry,
  candidate: string,
): boolean {
  if (entry.kind === "glob") {
    return matchesGlob(entry.normalized, candidate);
  }
  const base = entry.normalized.replace(/\/+$/, "");
  return candidate === base || candidate.startsWith(`${base}/`);
}

/**
 * Partition payload paths into kept and skipped using first-match order.
 *
 * An entry that is the first match of no skipped path is unmatched; a shadowed
 * entry is therefore reported as unmatched, keeping the report self-consistent.
 *
 * @param payloadRelativePaths Destination-relative payload paths in
 *   enumeration order.
 * @param manifest Parsed manifest.
 * @param destinationExists Probe reporting whether the destination holds a
 *   regular file at a relative path; called only for skipped paths.
 * @returns Kept paths, skipped records, and unmatched entries in input or
 *   manifest order.
 */
export function planExclusions(
  payloadRelativePaths: ReadonlyArray<string>,
  manifest: ExclusionManifest,
  destinationExists: (relativePath: string) => boolean,
): ExclusionPlan {
  const kept: string[] = [];
  const skipped: SkippedPath[] = [];
  for (const relativePath of payloadRelativePaths) {
    const entry = manifest.entries.find((candidate) =>
      matchesExclusionEntry(candidate, relativePath),
    );
    if (entry === undefined) {
      kept.push(relativePath);
      continue;
    }
    skipped.push({
      relativePath,
      entry: entry.normalized,
      line: entry.line,
      destinationStatus: destinationExists(relativePath) ? "present" : "absent",
    });
  }
  const claimed = new Set(
    skipped.map((skip) => `${String(skip.line)}\u0000${skip.entry}`),
  );
  const unmatchedEntries = manifest.entries.filter(
    (entry) => !claimed.has(`${String(entry.line)}\u0000${entry.normalized}`),
  );
  return { kept, skipped, unmatchedEntries };
}

/**
 * Assert the manifest path lies at the destination root, outside payload roots.
 *
 * @param relativePath Manifest path relative to the destination root.
 * @param rootFolders Published root folder names.
 * @throws Error When the path contains `/` or begins with a root name.
 */
export function assertManifestPathIsRootLevel(
  relativePath: string,
  rootFolders: ReadonlyArray<string>,
): void {
  if (relativePath.includes("/")) {
    throw new Error(
      `Exclusion manifest path must be root-level: ${relativePath}`,
    );
  }
  const root = rootFolders.find((name) => relativePath.startsWith(name));
  if (root !== undefined) {
    throw new Error(
      `Exclusion manifest path must not begin with published root ${root}: ${relativePath}`,
    );
  }
}
