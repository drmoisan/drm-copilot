/**
 * Pure destination-`.gitignore` merge for the Claude push-down.
 *
 * Purpose:
 *     Compute the text a destination workspace's `.gitignore` should carry once
 *     the drm-copilot managed ignore entries are delivered into it. Issue #596:
 *     the batch-budget and session-identity runtime state the pushed-down hooks
 *     write lives under `.claude/state/` and `.codex/state/`, and a destination
 *     workspace that does not ignore those paths reports them as untracked
 *     churn on every push-down.
 *
 * Why a separate module rather than logic inside the call site:
 *     `.claude/rules/general-code-change.md` requires pure logic to be separated
 *     from I/O. This module performs no filesystem access at all: it takes the
 *     destination's current text and returns the merged text. The call site in
 *     `claude-customizations.ts` owns the read and the conditional write, so the
 *     merge itself is exhaustively testable without a filesystem.
 *
 * Merge rule (pinned for idempotency):
 *     - CRLF and lone CR are normalized to LF before any comparison.
 *     - The managed block is located by its opening and closing sentinel lines
 *       and replaced in place, preserving its position in the file.
 *     - A block is appended only when no opening sentinel is present. A second
 *       block is never appended, and bare entries are never written outside a
 *       block.
 *     - Content outside the block is preserved exactly, including its ordering.
 *     - The full managed entry set is emitted inside the block even when one of
 *       those entries also appears outside it. Suppressing a duplicate would
 *       make the output depend on unmanaged content and would produce two
 *       different fixed points; a duplicate ignore pattern is inert to git.
 *     - An empty input string is a valid input representing an absent
 *       destination file.
 *
 * Side effects:
 *     None. Every export is a constant or a pure function.
 */

/** Destination-relative path of the file this module merges. */
export const CLAUDE_GITIGNORE_RELATIVE_PATH = ".gitignore";

/** Line that opens the drm-copilot managed ignore block. */
export const CLAUDE_GITIGNORE_BEGIN_SENTINEL =
  "# BEGIN drm-copilot managed ignores";

/** Line that closes the drm-copilot managed ignore block. */
export const CLAUDE_GITIGNORE_END_SENTINEL =
  "# END drm-copilot managed ignores";

/**
 * Ignore entries the push-down manages, in the order they are emitted.
 *
 * Both directories hold runtime state written by the pushed-down hooks:
 * `.claude/state/` carries the Claude batch-budget counters and the session-id
 * file, and `.codex/state/` carries the Codex-side equivalents.
 */
export const CLAUDE_MANAGED_IGNORE_ENTRIES: ReadonlyArray<string> = [
  ".claude/state/",
  ".codex/state/",
];

/** Line separator every merged result is emitted with. */
const LINE_SEPARATOR = "\n";

/**
 * Normalizes CRLF and lone CR line endings to LF.
 *
 * The destination file may have been authored on Windows. Comparing and
 * splitting a mixed-ending document without normalizing first would leave a
 * stray CR attached to a sentinel line and the sentinel would never match.
 */
function normalizeLineEndings(text: string): string {
  return text.replace(/\r\n?/g, LINE_SEPARATOR);
}

/**
 * Splits a normalized document into content lines.
 *
 * The single empty element a terminating newline leaves behind is dropped, so a
 * document and the same document without its terminator produce the same line
 * array. `toDocument` re-adds exactly one terminator, which is what makes the
 * merge a fixed point on its own output.
 */
function toLines(normalized: string): string[] {
  if (normalized === "") {
    return [];
  }

  const lines = normalized.split(LINE_SEPARATOR);
  if (lines[lines.length - 1] === "") {
    lines.pop();
  }
  return lines;
}

/** Renders the managed block, sentinels included, as an array of lines. */
function renderManagedBlock(): string[] {
  return [
    CLAUDE_GITIGNORE_BEGIN_SENTINEL,
    ...CLAUDE_MANAGED_IGNORE_ENTRIES,
    CLAUDE_GITIGNORE_END_SENTINEL,
  ];
}

/**
 * Merges the drm-copilot managed ignore block into a destination `.gitignore`.
 *
 * @param currentText - The destination file's current text. The empty string
 *     represents an absent destination file and is a valid input.
 * @returns The merged text, LF-separated and newline-terminated. Applying the
 *     function to its own output returns that output unchanged.
 */
export function mergeClaudeGitignore(currentText: string): string {
  const lines = toLines(normalizeLineEndings(currentText));
  const managedBlock = renderManagedBlock();

  const beginIndex = lines.indexOf(CLAUDE_GITIGNORE_BEGIN_SENTINEL);
  if (beginIndex === -1) {
    return appendManagedBlock(lines, managedBlock);
  }

  // An end sentinel that precedes the begin sentinel belongs to an earlier,
  // malformed block; only a closer at or after the opener delimits this one.
  const endOffset = lines
    .slice(beginIndex)
    .indexOf(CLAUDE_GITIGNORE_END_SENTINEL);
  const endIndex = endOffset === -1 ? lines.length - 1 : beginIndex + endOffset;

  const merged = [
    ...lines.slice(0, beginIndex),
    ...managedBlock,
    ...lines.slice(endIndex + 1),
  ];
  return toDocument(merged);
}

/**
 * Appends the managed block to a document that carries no opening sentinel.
 *
 * A single blank line separates the block from preceding content so the block
 * reads as its own section; no separator is emitted for an empty document.
 */
function appendManagedBlock(
  lines: ReadonlyArray<string>,
  managedBlock: ReadonlyArray<string>,
): string {
  const trailingBlankRemoved = [...lines];
  while (
    trailingBlankRemoved.length > 0 &&
    trailingBlankRemoved[trailingBlankRemoved.length - 1] === ""
  ) {
    trailingBlankRemoved.pop();
  }

  if (trailingBlankRemoved.length === 0) {
    return toDocument(managedBlock);
  }

  return toDocument([...trailingBlankRemoved, "", ...managedBlock]);
}

/** Joins lines into a newline-terminated document. */
function toDocument(lines: ReadonlyArray<string>): string {
  return `${lines.join(LINE_SEPARATOR)}${LINE_SEPARATOR}`;
}
