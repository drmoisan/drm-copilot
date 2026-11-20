/**
 * Reference rewrite rules (issue #1016, spec "Reference rewrite rules (research section 4)").
 *
 * Pure text transforms: the prefix rewrite with token-boundary matching and the
 * `Write(`/`Edit(` protected-literal rule, the renamed-basename rewrite, the
 * backslash report, and relative-link recomputation for Markdown files.
 */
import * as nodePath from "node:path";

import {
  GENERIC_FEATURES_PREFIX,
  LEGACY_LAYOUT_MAP,
  rowTarget,
} from "./layout-map";

const posix = nodePath.posix;

/** One prefix replacement. */
export interface RewritePrefix {
  readonly from: string;
  readonly to: string;
}

/** One approved folder rename, keyed by area (`active`, `completed`, `archive`). */
export interface FolderNameRename {
  readonly area: string;
  readonly from: string;
  readonly to: string;
}

/** Result of {@link rewritePrefixes}. */
export interface PrefixRewriteResult {
  readonly text: string;
  readonly occurrences: number;
  readonly protectedOccurrences: number;
  readonly backslashOccurrences: number;
  readonly renamedBasenames: number;
}

/** Inputs of {@link recomputeRelativeLinks}. */
export interface LinkContext {
  /** Repository-relative path of the source file before the move. */
  readonly sourceOld: string;
  /** Repository-relative path of the source file after the move. */
  readonly sourceNew: string;
  /** Maps a pre-move repository path to its post-move path. */
  readonly mapPath: (path: string) => string;
  /** True when a pre-move repository path (file or directory) exists. */
  readonly exists: (path: string) => boolean;
}

/** Result of {@link recomputeRelativeLinks}. */
export interface LinkRewriteResult {
  readonly text: string;
  readonly recomputed: number;
  readonly broken: ReadonlyArray<string>;
}

/** Characters that end a path token when they precede a prefix. */
const TOKEN_CHARACTER = /[A-Za-z0-9._\-/]/;

/**
 * Build the ordered prefix list: the table rows with the OQ-1 target, then the
 * generic `docs/features/` row, longest prefix first.
 *
 * @param discoveryTarget Repository-relative OQ-1 target directory.
 * @returns The prefixes in matching order.
 */
export function buildRewritePrefixes(
  discoveryTarget: string,
): ReadonlyArray<RewritePrefix> {
  const rows: RewritePrefix[] = LEGACY_LAYOUT_MAP.map((row) => ({
    from: row.from,
    to: rowTarget(row, discoveryTarget),
  }));
  rows.push({ ...GENERIC_FEATURES_PREFIX });
  return rows.sort((left, right) => right.from.length - left.from.length);
}

/**
 * Whether a prefix starting at `index` sits on a path-token boundary.
 *
 * An optional leading `/` or `./` is accepted; the character before it must be
 * absent or not a letter, digit, `.`, `_`, `-` or `/`.
 *
 * @param text Text being scanned.
 * @param index Start index of the prefix.
 * @returns True on a boundary.
 */
export function isTokenBoundary(text: string, index: number): boolean {
  let start = index;
  if (text[start - 1] === "/") {
    start -= 1;
    if (text[start - 1] === ".") {
      start -= 1;
    }
  }
  const before = text[start - 1];
  return before === undefined || !TOKEN_CHARACTER.test(before);
}

/**
 * Whether `index` lies inside a `Write(` or `Edit(` permission literal on its line.
 *
 * @param text Text being scanned.
 * @param index Index of the occurrence.
 * @returns True when an opening `Write(` or `Edit(` precedes the index on the
 *     same line with no closing `)` between them.
 */
export function isInsideProtectedLiteral(text: string, index: number): boolean {
  const lineStart = text.lastIndexOf("\n", index - 1) + 1;
  const line = text.slice(lineStart, index);
  const opening = Math.max(
    line.lastIndexOf("Write("),
    line.lastIndexOf("Edit("),
  );
  return opening >= 0 && !line.slice(opening).includes(")");
}

/**
 * Count backslash-separated occurrences of the prefixes (reported, never rewritten).
 *
 * @param text Text being scanned.
 * @param prefixes Prefixes in matching order.
 * @returns The number of occurrences on a token boundary.
 */
function countBackslashOccurrences(
  text: string,
  prefixes: ReadonlyArray<RewritePrefix>,
): number {
  const seen = new Set<number>();
  for (const prefix of prefixes) {
    const needle = prefix.from.replace(/\//g, "\\");
    let index = text.indexOf(needle);
    while (index >= 0) {
      const before = text[index - 1];
      if (before === undefined || !/[A-Za-z0-9._\-\\]/.test(before)) {
        seen.add(index);
      }
      index = text.indexOf(needle, index + 1);
    }
  }
  return seen.size;
}

/**
 * Rewrite renamed folder basenames that follow a `.dev/<area>/` prefix.
 *
 * @param text Text after the prefix rewrite.
 * @param renames Approved folder renames.
 * @returns The rewritten text and the number of replacements.
 */
function rewriteBasenames(
  text: string,
  renames: ReadonlyArray<FolderNameRename>,
): { text: string; count: number } {
  let count = 0;
  let output = text;
  for (const rename of renames) {
    const needle = `.dev/${rename.area}/${rename.from}`;
    let index = output.indexOf(needle);
    while (index >= 0) {
      const after = output[index + needle.length];
      if (after === undefined || !/[A-Za-z0-9._-]/.test(after)) {
        const replacement = `.dev/${rename.area}/${rename.to}`;
        output =
          output.slice(0, index) +
          replacement +
          output.slice(index + needle.length);
        count += 1;
        index = output.indexOf(needle, index + replacement.length);
      } else {
        index = output.indexOf(needle, index + 1);
      }
    }
  }
  return { text: output, count };
}

/**
 * Apply the prefix rewrite, then the renamed-basename rewrite.
 *
 * @param text Input text.
 * @param prefixes Prefixes from {@link buildRewritePrefixes}.
 * @param renames Approved folder renames.
 * @returns The rewritten text and the occurrence counts.
 */
export function rewritePrefixes(
  text: string,
  prefixes: ReadonlyArray<RewritePrefix>,
  renames: ReadonlyArray<FolderNameRename> = [],
): PrefixRewriteResult {
  const parts: string[] = [];
  let occurrences = 0;
  let protectedOccurrences = 0;
  let index = 0;
  // Every prefix begins with "docs/", so the text between candidates copies through.
  let next = text.indexOf("docs/", index);
  while (next >= 0) {
    parts.push(text.slice(index, next));
    const match = isTokenBoundary(text, next)
      ? prefixes.find((prefix) => text.startsWith(prefix.from, next))
      : undefined;
    if (match === undefined) {
      parts.push("d");
      index = next + 1;
    } else if (isInsideProtectedLiteral(text, next)) {
      parts.push(match.from);
      protectedOccurrences += 1;
      index = next + match.from.length;
    } else {
      parts.push(match.to);
      occurrences += 1;
      index = next + match.from.length;
    }
    next = text.indexOf("docs/", index);
  }
  parts.push(text.slice(index));
  const output = parts.join("");
  const basenames = rewriteBasenames(output, renames);
  return {
    text: basenames.text,
    occurrences,
    protectedOccurrences,
    backslashOccurrences: countBackslashOccurrences(text, prefixes),
    renamedBasenames: basenames.count,
  };
}

/** Inline Markdown link: `](target)` with an optional quoted title. */
const INLINE_LINK = /\]\(([^()\s]+)((?:\s+"[^"]*")?)\)/g;

/**
 * Recompute relative Markdown links whose source or target moved.
 *
 * Scheme links, fragment-only links and root-relative links are unchanged. A
 * link whose target does not exist before the move is unchanged and reported.
 *
 * @param text Markdown text.
 * @param context Source paths, path map and existence predicate.
 * @returns The rewritten text, the recomputed count and the broken links.
 */
export function recomputeRelativeLinks(
  text: string,
  context: LinkContext,
): LinkRewriteResult {
  let recomputed = 0;
  const broken: string[] = [];
  const result = text.replace(
    INLINE_LINK,
    (whole: string, target: string, title: string) => {
      const next = recomputeLink(target, context);
      if (next === null) {
        broken.push(`${context.sourceOld}: ${target}`);
        return whole;
      }
      if (next === target) {
        return whole;
      }
      recomputed += 1;
      return `](${next}${title})`;
    },
  );
  return { text: result, recomputed, broken };
}

/**
 * Recompute one link target.
 *
 * @param target Link target as written.
 * @param context Source paths, path map and existence predicate.
 * @returns The new target, the unchanged target, or null for a broken link.
 */
function recomputeLink(target: string, context: LinkContext): string | null {
  if (
    /^[A-Za-z][A-Za-z0-9+.-]*:/.test(target) ||
    target.startsWith("#") ||
    target.startsWith("/")
  ) {
    return target;
  }
  const hash = target.indexOf("#");
  const pathPart = hash >= 0 ? target.slice(0, hash) : target;
  const fragment = hash >= 0 ? target.slice(hash) : "";
  const decoded = safeDecode(pathPart);
  const joined = posix.normalize(
    posix.join(posix.dirname(context.sourceOld), decoded),
  );
  const resolved = joined.replace(/\/+$/, "");
  if (
    resolved === ".." ||
    resolved.startsWith("../") ||
    !context.exists(resolved)
  ) {
    return null;
  }
  const targetNew = context.mapPath(resolved);
  if (targetNew === resolved && context.sourceNew === context.sourceOld) {
    return target;
  }
  let relative = posix.relative(posix.dirname(context.sourceNew), targetNew);
  if (relative === "") {
    relative = ".";
  }
  if (
    pathPart.startsWith("./") &&
    relative !== "." &&
    !relative.startsWith("..")
  ) {
    relative = `./${relative}`;
  }
  if (pathPart.endsWith("/")) {
    relative = `${relative}/`;
  }
  const encoded = pathPart.includes("%20")
    ? relative.replace(/ /g, "%20")
    : relative;
  return encoded + fragment;
}

/**
 * Decode percent-escapes in a link path, keeping the text when it is malformed.
 *
 * @param value Link path.
 * @returns The decoded path.
 */
function safeDecode(value: string): string {
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}
