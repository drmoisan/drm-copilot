/**
 * Reference rewrite helpers for the push-down customization publisher.
 *
 * Purpose:
 *     Port `push_down_copilot_customizations_rewrites.py`. Keeps command-
 *     reference normalization and the rewrite catalog separate from the
 *     publisher's orchestration flow so each module stays cohesive and testable.
 *
 * Responsibilities:
 *     - Recognize documented script references in copied text via a single
 *       regex (`SCRIPT_REFERENCE_PATTERN`).
 *     - Normalize a matched reference onto a canonical catalog key.
 *     - Replace a known reference with a stable VS Code command reference while
 *       preserving trailing prose punctuation.
 *     - Report unknown references in deterministic first-seen order without
 *       changing them.
 *
 * Side effects:
 *     None. All functions are pure transformations from inputs to outputs.
 */

/** Trailing punctuation characters preserved during a rewrite. */
export const TRAILING_PUNCTUATION = ".,;:!?)";

/**
 * Regex matching a documented script reference.
 *
 * Ported one-to-one from the Python `SCRIPT_REFERENCE_PATTERN`. It matches an
 * optional `poetry run python -m` prefix, an optional `${workspaceFolder}`
 * prefix (forward- or back-slash separated), then either a dotted
 * `scripts.dev_tools.<...>` module path or a slash-separated
 * `scripts/dev_tools/<...>` (or `dev-tools`) path. The global flag mirrors
 * Python `re.sub` replacing every non-overlapping match.
 */
export const SCRIPT_REFERENCE_PATTERN =
  /(?:(?:poetry\s+run\s+python\s+-m)\s+)?(?:\$\{workspaceFolder\}[\\/])?scripts(?:\.dev_tools\.[A-Za-z0-9_.]+|[\\/](?:dev_tools|dev-tools)[A-Za-z0-9_.\\/-]+)/g;

/**
 * Catalog entry mapping a normalized script reference to a VS Code command.
 *
 * Mirrors the Python frozen `RewriteTarget` dataclass.
 */
export interface RewriteTarget {
  /** Canonical lookup key for a script reference. */
  readonly normalizedKey: string;
  /** VS Code command identifier. */
  readonly commandId: string;
  /** User-facing command title. */
  readonly title: string;
  /** Original script reference documented by the placeholder contract. */
  readonly scriptReference: string;
  /** Whether the command intentionally remains a placeholder. */
  readonly isPlaceholder: boolean;
}

/**
 * Build the command rewrite catalog for supported script references.
 *
 * Replicates the seven Python catalog entries exactly (key, command id, title,
 * script reference, placeholder flag), keyed by normalized reference.
 *
 * @returns Catalog keyed by normalized reference.
 */
export function buildRewriteCatalog(): Map<string, RewriteTarget> {
  const targets: ReadonlyArray<RewriteTarget> = [
    {
      normalizedKey: "scripts.dev_tools.pr_context.collector",
      commandId: "drmCopilotExtension.collectPrContext",
      title: "drm-copilot: Collect PR Context",
      scriptReference: "scripts.dev_tools.pr_context.collector",
      isPlaceholder: false,
    },
    {
      normalizedKey: "scripts.dev_tools.new_active_feature_folder",
      commandId: "drmCopilotExtension.newActiveFeatureFolder",
      title: "drm-copilot: New Active Feature Folder",
      scriptReference: "scripts.dev_tools.new_active_feature_folder",
      isPlaceholder: false,
    },
    {
      normalizedKey: "scripts.dev_tools.potential_to_issue",
      commandId: "drmCopilotExtension.potentialToIssue",
      title: "drm-copilot: Potential To Issue",
      scriptReference: "scripts.dev_tools.potential_to_issue",
      isPlaceholder: false,
    },
    {
      normalizedKey: "scripts/dev_tools/new_potential_bug_entry.py",
      commandId: "drmCopilotExtension.newPotentialBugEntry",
      title: "drm-copilot: New Potential Bug Entry",
      scriptReference: "scripts/dev_tools/new_potential_bug_entry.py",
      isPlaceholder: false,
    },
    {
      normalizedKey: "scripts/dev_tools/new-potential-entry.ps1",
      commandId: "drmCopilotExtension.newPotentialEntry",
      title: "drm-copilot: New Potential Entry",
      scriptReference: "scripts/dev-tools/new-potential-entry.ps1",
      isPlaceholder: false,
    },
    {
      normalizedKey: "scripts.dev_tools.push_down_copilot_customizations",
      commandId: "drmCopilotExtension.pushDownCopilotCustomizations",
      title: "drm-copilot: Push Down Copilot Customizations",
      scriptReference: "scripts.dev_tools.push_down_copilot_customizations",
      isPlaceholder: false,
    },
    {
      normalizedKey: "scripts/dev_tools/sync-agents-from-instructions.ps1",
      commandId: "drmCopilotExtension.syncAgentsFromInstructions",
      title: "drm-copilot: Sync AGENTS.md from Instructions",
      scriptReference: "scripts/dev-tools/sync-agents-from-instructions.ps1",
      isPlaceholder: false,
    },
  ];
  const catalog = new Map<string, RewriteTarget>();
  // Key each target by its normalized reference for O(1) lookup during rewrite.
  for (const target of targets) {
    catalog.set(target.normalizedKey, target);
  }
  return catalog;
}

/**
 * Render a canonical textual command reference for copied files.
 *
 * @param target Catalog entry for the matched reference.
 * @returns Stable textual command reference identical to the Python output.
 */
export function renderCommandReference(target: RewriteTarget): string {
  return `VS Code command: \`${target.title}\` (command ID: \`${target.commandId}\`)`;
}

/**
 * Normalize a matched textual reference before catalog lookup.
 *
 * Collapses the `poetry run python -m` prefix, `${workspaceFolder}` prefixes,
 * backslash separators, and the `dev-tools` slash variant onto a single
 * canonical key, mirroring the Python normalization order.
 *
 * @param referenceText Raw matched script reference.
 * @returns Canonical lookup key.
 */
export function normalizeReferenceForLookup(referenceText: string): string {
  let normalized = referenceText.trim();
  normalized = normalized.replace(/^poetry\s+run\s+python\s+-m\s+/, "");
  normalized = normalized.split("${workspaceFolder}\\").join("");
  normalized = normalized.split("${workspaceFolder}/").join("");
  normalized = normalized.split("\\").join("/");
  normalized = normalized
    .split("scripts/dev-tools/")
    .join("scripts/dev_tools/");
  return normalized;
}

/**
 * Split a matched reference into its core text and trailing punctuation.
 *
 * @param referenceText Matched reference including any trailing punctuation.
 * @returns A tuple of `[core, suffix]`.
 */
export function splitTrailingPunctuation(
  referenceText: string,
): [string, string] {
  let core = referenceText;
  let suffix = "";
  // Peel trailing sentence punctuation so prose around a reference is preserved.
  while (
    core.length > 0 &&
    TRAILING_PUNCTUATION.includes(core[core.length - 1]!)
  ) {
    suffix = core[core.length - 1]! + suffix;
    core = core.slice(0, -1);
  }
  return [core, suffix];
}

/**
 * Rewrite one matched script reference when it belongs to the catalog.
 *
 * @param referenceText Matched script reference text.
 * @param catalog Lookup table keyed by normalized reference.
 * @returns A tuple `[replacement, rewrittenDelta, placeholderDelta, unmatched]`.
 */
export function rewriteMatchedReference(
  referenceText: string,
  catalog: Map<string, RewriteTarget>,
): [string, number, number, string[]] {
  const [coreReference, suffix] = splitTrailingPunctuation(referenceText);
  const normalizedReference = normalizeReferenceForLookup(coreReference);
  const target = catalog.get(normalizedReference);
  if (target === undefined) {
    return [referenceText, 0, 0, [normalizedReference]];
  }
  const replacement = renderCommandReference(target) + suffix;
  if (target.isPlaceholder) {
    return [replacement, 0, 1, []];
  }
  return [replacement, 1, 0, []];
}

/**
 * Rewrite supported script references within text content.
 *
 * Applies replacements only to matched references and reports unknown
 * references without changing them, in deterministic first-seen order. Mirrors
 * the Python `rewrite_text_references` return shape exactly.
 *
 * @param text Source text to rewrite.
 * @returns A tuple `[rewrittenText, rewrittenCount, placeholderCount,
 *   unmatchedRefs]`.
 */
export function rewriteTextReferences(
  text: string,
): [string, number, number, string[]] {
  const catalog = buildRewriteCatalog();
  let rewrittenCount = 0;
  let placeholderCount = 0;
  const unmatchedReferences: string[] = [];

  // Replace every regex match while accumulating deterministic counters and
  // preserving first-seen unmatched-reference order.
  const rewrittenText = text.replace(SCRIPT_REFERENCE_PATTERN, (match) => {
    const [replacement, rewrittenDelta, placeholderDelta, unmatched] =
      rewriteMatchedReference(match, catalog);
    rewrittenCount += rewrittenDelta;
    placeholderCount += placeholderDelta;
    // Record each new unmatched reference once, preserving first-seen order.
    for (const reference of unmatched) {
      if (!unmatchedReferences.includes(reference)) {
        unmatchedReferences.push(reference);
      }
    }
    return replacement;
  });

  return [rewrittenText, rewrittenCount, placeholderCount, unmatchedReferences];
}

/** Rewrite-function signature shared by the publisher engine. */
export type RewriteFunction = (
  text: string,
) => [string, number, number, string[]];
