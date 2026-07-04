/**
 * Rewrite supported automation references for the Codex-native converter.
 *
 * Purpose:
 *     Centralize the approved runtime-reference rewrites that convert supported
 *     host-specific automation references into the repository's semantic MCP
 *     usage model. Ported from `rewrites.py`; the large rule-table builder lives
 *     in `rewrites-rules.ts` so neither file exceeds the 500-line policy. Pure
 *     logic, no I/O.
 *
 * Invariants:
 *     Only verified catalog entries are rewritten automatically. Unknown runtime
 *     references remain explicit instead of being guessed. Rule order is fixed.
 */

import { buildRewriteRules } from "./rewrites-rules";

/**
 * One supported runtime-reference rewrite rule.
 *
 * `replacement` is either a literal string or a function receiving the matched
 * text and capture groups, mirroring the Python `str | Callable[[Match], str]`.
 * `pattern` carries the global flag so all occurrences are replaced.
 */
export interface RewriteRule {
  readonly pattern: RegExp;
  readonly replacement:
    string | ((match: string, ...groups: string[]) => string);
  readonly description: string;
}

/**
 * Normalize one extracted path segment for use in native target paths.
 *
 * Mirrors `_normalize_target_name`.
 *
 * @param name Extracted path segment.
 * @returns The segment with underscores replaced by hyphens.
 */
export function normalizeTargetName(name: string): string {
  return name.replace(/_/g, "-");
}

/**
 * Normalize one extracted hook path segment without script extensions.
 *
 * Mirrors `_normalize_hook_target_name`.
 *
 * @param name Extracted hook path segment.
 * @returns The normalized hook segment without a `.ps1`/`.py` suffix.
 */
export function normalizeHookTargetName(name: string): string {
  const normalized = normalizeTargetName(name);
  for (const suffix of [".ps1", ".py"]) {
    if (normalized.endsWith(suffix)) {
      return normalized.slice(0, normalized.length - suffix.length);
    }
  }
  return normalized;
}

/**
 * Convert a mixed-case command identifier into snake_case.
 *
 * Mirrors `_camel_or_pascal_to_snake`.
 *
 * @param value Mixed-case identifier.
 * @returns The snake_case identifier.
 */
export function camelOrPascalToSnake(value: string): string {
  let snake = value.replace(/([a-z0-9])([A-Z])/g, "$1_$2");
  snake = snake.replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2");
  return snake.replace(/-/g, "_").toLowerCase();
}

// Unresolved-runtime-reference patterns and their human-readable descriptions,
// mirroring `_UNRESOLVED_RUNTIME_PATTERNS`.
const UNRESOLVED_RUNTIME_PATTERNS: ReadonlyArray<readonly [RegExp, string]> = [
  [/\bdrmCopilotExtension\.[A-Za-z0-9_]+\b/, "raw VS Code command identifier"],
  [
    /(^|[^A-Za-z0-9_])\.github\/(copilot-instructions\.md|instructions\/|skills\/|agents\/|prompts\/)/,
    "GitHub Copilot runtime path",
  ],
  [
    /(^|[^A-Za-z0-9_])\.claude\/(skills\/|agents\/|hooks\/|settings\.json)/,
    "Claude runtime path",
  ],
  [/\bCLAUDE\.md\b/, "Claude standing-instructions file"],
  [
    /\bscripts\/dev_tools\/[A-Za-z0-9_./-]+\b/,
    "repository-local script reference",
  ],
];

/**
 * Count how many times a pattern matches a text without consuming lastIndex
 * state across calls.
 *
 * @param pattern Global RegExp to count matches for.
 * @param text Text to scan.
 * @returns The number of matches.
 */
function countMatches(pattern: RegExp, text: string): number {
  const counter = new RegExp(pattern.source, pattern.flags);
  const matches = text.match(counter);
  return matches ? matches.length : 0;
}

/**
 * Rewrite supported runtime references toward semantic MCP usage.
 *
 * Mirrors `rewrite_supported_automation_reference`: applies the ordered catalog,
 * recording the description of every rule that performed at least one
 * replacement.
 *
 * @param text Generated text that may contain host-specific runtime references.
 * @param options `enableRepoPrompts` and optional `standingGuidanceSourcePaths`.
 * @returns The rewritten text plus the descriptions of applied rules.
 */
export function rewriteSupportedAutomationReference(
  text: string,
  options: {
    readonly enableRepoPrompts: boolean;
    readonly standingGuidanceSourcePaths?: ReadonlyArray<string>;
  },
): [string, ReadonlyArray<string>] {
  let rewrittenText = text;
  const appliedDescriptions: string[] = [];

  const rules = buildRewriteRules({
    enableRepoPrompts: options.enableRepoPrompts,
    standingGuidanceSourcePaths: options.standingGuidanceSourcePaths ?? [],
  });

  // Apply the catalog in fixed order so the same input always yields the same
  // rewritten output and applied-rule metadata.
  for (const rule of rules) {
    const replacementCount = countMatches(rule.pattern, rewrittenText);
    if (replacementCount > 0) {
      appliedDescriptions.push(rule.description);
      rewrittenText =
        typeof rule.replacement === "string"
          ? rewrittenText.replace(
              rule.pattern,
              () => rule.replacement as string,
            )
          : rewrittenText.replace(
              rule.pattern,
              rule.replacement as (
                match: string,
                ...groups: string[]
              ) => string,
            );
    }
  }

  return [rewrittenText, appliedDescriptions];
}

/**
 * Detect runtime-specific references that still require manual handling.
 *
 * Mirrors `detect_unresolved_runtime_reference`.
 *
 * @param text Generated text to inspect after supported rewrites have run.
 * @returns Human-readable descriptions of unresolved runtime references found.
 */
export function detectUnresolvedRuntimeReference(
  text: string,
): ReadonlyArray<string> {
  const findings: string[] = [];
  // Scan for unresolved source-runtime references that must block apply mode.
  for (const [pattern, description] of UNRESOLVED_RUNTIME_PATTERNS) {
    if (pattern.test(text)) {
      findings.push(description);
    }
  }
  return findings;
}
