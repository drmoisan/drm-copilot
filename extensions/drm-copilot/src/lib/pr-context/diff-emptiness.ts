/**
 * Pure classifier for the collected PR-context diff state.
 *
 * Purpose:
 *     Distinguish, from values already present on a collected PR-context
 *     record, between refs that failed to resolve, refs that resolved but
 *     produced no file-level change, and a genuinely populated diff. No git
 *     or filesystem call is made here: every input is a value the collector
 *     already computed, so classification costs no additional invocation.
 *
 * Root-cause states (see spec.md #675, Root Cause Analysis):
 *     - State A: head is an ancestor of base (`mergeBase === headSha`).
 *     - State B: wrong worktree whose HEAD is at or behind base — identical
 *       to A in the git data, and this guard does not attempt to
 *       distinguish them; that would be a heuristic.
 *     - State C: base ref does not resolve (`mergeBase`/`headSha` are
 *       `null`).
 *     - State D: range is real but its net diff is empty.
 *
 * Documented limitation:
 *     This guard cannot detect a wrong target whose branch has commits
 *     ahead of the base: a populated but wrong diff is indistinguishable
 *     from a populated and correct one at this layer. Only supplying an
 *     explicit `target_ref` (not this guard) addresses that case.
 *
 *     The working-tree sections (`git status -sb`, staged/unstaged diffs,
 *     untracked files) and the current-PR lookup (`gh pr view`) remain
 *     scoped to `workspace_root` even when `target_ref` is supplied — this
 *     classifier's `target_ref` handling does not relocate them.
 */

/** Input to {@link classifyPrContextDiffState}. */
export interface ClassifyPrContextDiffStateInput {
  /** Collected merge-base SHA, or `null` when refs did not resolve. */
  readonly mergeBase: string | null;
  /** Collected head SHA, or `null` when refs did not resolve. */
  readonly headSha: string | null;
  /** Head ref the collector actually used, or `null` when unresolved. */
  readonly resolvedHeadRef: string | null;
  /** Base ref the collector actually resolved to, or `null` when unresolved. */
  readonly resolvedBase: string | null;
  /** Count of changed files across the collected buckets. */
  readonly changedFileCount: number;
  /** The `base` argument the caller supplied. */
  readonly requestedBase: string;
  /** The `target_ref` the caller supplied, or `null` on the session fallback. */
  readonly attemptedHeadRef: string | null;
}

/** Discriminated classification of a collected PR-context diff. */
export type PrContextDiffState =
  | { readonly kind: "refs-unresolved"; readonly message: string }
  | { readonly kind: "refs-resolved-no-change"; readonly message: string }
  | { readonly kind: "populated" };

/**
 * Classify a collected PR-context diff as refs-unresolved,
 * refs-resolved-no-change, or populated.
 *
 * @param input Values already present on the collected record.
 * @returns The discriminated state, with a distinct failure message for
 *   each of the two failing states.
 */
export function classifyPrContextDiffState(
  input: ClassifyPrContextDiffStateInput,
): PrContextDiffState {
  if (input.mergeBase === null || input.headSha === null) {
    const attemptedHead = input.attemptedHeadRef ?? "(session HEAD)";
    const underlyingFailure =
      input.resolvedBase === null
        ? `base '${input.requestedBase}' did not resolve to a commit`
        : `head '${attemptedHead}' did not resolve to a commit`;
    return {
      kind: "refs-unresolved",
      message:
        `Could not resolve PR context refs for requested base '${input.requestedBase}' ` +
        `and attempted head '${attemptedHead}': ${underlyingFailure}. ` +
        "Correct the 'base' argument (or 'target_ref', if supplied) and retry.",
    };
  }

  if (input.changedFileCount === 0) {
    return {
      kind: "refs-resolved-no-change",
      message:
        `PR context diff is empty: resolved head ref '${input.resolvedHeadRef ?? "(unknown)"}' ` +
        `at head SHA '${input.headSha}' has no changes relative to merge base '${input.mergeBase}' ` +
        `and resolved base '${input.resolvedBase ?? "(unknown)"}'. This guard cannot detect a wrong ` +
        "target whose branch has commits ahead of the base; supply or correct 'target_ref' if this " +
        "diff was not expected to be empty. The working-tree sections and the current-PR lookup " +
        "remain scoped to 'workspace_root' even when 'target_ref' is supplied.",
    };
  }

  return { kind: "populated" };
}
