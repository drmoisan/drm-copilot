/**
 * Memory-scope frontmatter parser for the `.claude` customization push-down.
 *
 * Purpose:
 *     Port the frontmatter scope-reading helpers of
 *     `push_down_claude_filesystem.py`. Reads the agent-memory scope leaf
 *     (`metadata.scope`) from leading YAML frontmatter using a narrow regex
 *     parser (no runtime YAML dependency), and decides per-file inclusion for
 *     the general-vs-repo memory scope filter.
 *
 * Side effects:
 *     None. All functions are pure.
 */

/** Relative root beneath which agent-memory files live. */
export const AGENT_MEMORY_RELATIVE_ROOT = ".claude/agent-memory";

/** Scope value that permits distribution of an agent-memory file. */
export const GENERAL_MEMORY_SCOPE = "general";

/** Fail-safe default scope that excludes an agent-memory file from push-down. */
export const REPO_MEMORY_SCOPE = "repo";

/**
 * Match a leading YAML frontmatter block: the first `---` line, the block body,
 * and the closing `---` line. The `s` flag lets the body span multiple lines,
 * mirroring Python `re.DOTALL`.
 */
const FRONTMATTER_PATTERN = /^---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|$)/s;

/**
 * Match a `metadata:` mapping key at column zero, then capture the indented
 * block lines that belong to it (more-indented or blank) until the next
 * column-zero key or the end of the frontmatter body.
 */
const METADATA_BLOCK_PATTERN =
  /^metadata:[ \t]*\r?\n((?:[ \t]+.*(?:\r?\n|$)|\r?\n)*)/m;

/**
 * Match a `scope:` leaf inside the metadata block, capturing its scalar value
 * up to an optional inline comment. Surrounding quotes are stripped later.
 */
const SCOPE_LEAF_PATTERN = /^[ \t]+scope:[ \t]*([^\r\n#]*)/m;

/**
 * Return the declared memory scope from a file's YAML frontmatter.
 *
 * Returns `general` only when the frontmatter contains a `metadata:` mapping
 * whose `scope:` leaf is exactly `general` (quotes and inline comments
 * stripped). Every other case — missing/unterminated frontmatter, no metadata
 * block, no scope leaf, or any non-general value — returns `repo` as the
 * fail-safe default so nothing leaks by accident.
 *
 * @param content The full text of a candidate memory file.
 * @returns `general` or `repo`.
 */
export function readMemoryScope(content: string): string {
  // Isolate the leading frontmatter block; absent/unterminated fails safe.
  const frontmatterMatch = FRONTMATTER_PATTERN.exec(content);
  if (frontmatterMatch === null) {
    return REPO_MEMORY_SCOPE;
  }
  const frontmatterBody = frontmatterMatch[1] ?? "";

  // Locate the metadata mapping; without it there is no scope leaf to read.
  const metadataMatch = METADATA_BLOCK_PATTERN.exec(frontmatterBody);
  if (metadataMatch === null) {
    return REPO_MEMORY_SCOPE;
  }
  const metadataBlock = metadataMatch[1] ?? "";

  // Read the scope leaf from within the metadata block only; a top-level
  // `scope:` outside `metadata:` is intentionally ignored.
  const scopeMatch = SCOPE_LEAF_PATTERN.exec(metadataBlock);
  if (scopeMatch === null) {
    return REPO_MEMORY_SCOPE;
  }

  // Strip surrounding whitespace and matching quotes before exact comparison.
  let scopeValue = (scopeMatch[1] ?? "").trim();
  if (
    scopeValue.length >= 2 &&
    scopeValue[0] === scopeValue[scopeValue.length - 1] &&
    (scopeValue[0] === '"' || scopeValue[0] === "'")
  ) {
    scopeValue = scopeValue.slice(1, -1).trim();
  }
  return scopeValue === GENERAL_MEMORY_SCOPE
    ? GENERAL_MEMORY_SCOPE
    : REPO_MEMORY_SCOPE;
}

/**
 * Normalize a path to forward-slash separators with no trailing slash.
 *
 * @param value Path that may use OS-specific separators.
 * @returns Forward-slash POSIX path without a trailing separator.
 */
function normalizePosix(value: string): string {
  return value.replace(/\\/g, "/").replace(/\/+$/, "");
}

/**
 * Return whether a relative POSIX path is within the agent-memory subtree.
 *
 * @param relativePosixPath A repo-relative POSIX path.
 * @returns True when the path is `.claude/agent-memory` or beneath it.
 */
export function isUnderAgentMemory(relativePosixPath: string): boolean {
  const normalized = normalizePosix(relativePosixPath);
  return (
    normalized === AGENT_MEMORY_RELATIVE_ROOT ||
    normalized.startsWith(`${AGENT_MEMORY_RELATIVE_ROOT}/`)
  );
}

/**
 * Return whether a candidate file may be distributed by push-down.
 *
 * Files under `.claude/agent-memory/` are distributed only when general-scoped;
 * every other file is always distributed and unaffected by the scope filter.
 *
 * @param relativePosixPath The file path relative to the repository root.
 * @param content The full text of the file (used only for agent-memory paths).
 * @returns True when the file may be distributed.
 */
export function isGeneralMemoryFile(
  relativePosixPath: string,
  content: string,
): boolean {
  // Files outside the agent-memory subtree are always copied.
  if (!isUnderAgentMemory(relativePosixPath)) {
    return true;
  }
  return readMemoryScope(content) === GENERAL_MEMORY_SCOPE;
}
