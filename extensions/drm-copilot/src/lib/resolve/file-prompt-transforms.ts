/**
 * Template-text transform helpers for the atomic-plan prompt resolver.
 *
 * Purpose:
 *     Hold the pure string-transform helpers ported from
 *     `resolve_file_prompt.py` (line removal, heading insertion, minor-audit
 *     overrides, placeholder extraction, and deterministic substitution) so the
 *     companion `file-prompt-variables.ts` stays within the 500-line limit. The
 *     substitution logic is identical between the repo-root and bundled Python
 *     variants.
 *
 * Responsibilities:
 *     - Line-keepends splitting with byte-identical re-join semantics.
 *     - User-story clause removal and optional-variable line removal.
 *     - Heading-anchored block insertion and the minor-audit override block.
 *     - `${...}` placeholder extraction and deterministic substitution with an
 *       unresolved-placeholder safety check.
 *
 * Parity:
 *     Error messages, the minor-audit override block, and the placeholder
 *     strings are byte-identical to the Python source.
 */

/**
 * Split text into lines while preserving trailing newlines on each line.
 *
 * Mirrors Python `str.splitlines(keepends=True)` for `\n`-delimited text so
 * that re-joining the kept lines yields byte-identical output. A final line
 * without a trailing newline is preserved as-is; an empty string yields an
 * empty list (matching Python).
 *
 * @param text Text to split.
 * @returns Lines including their trailing `\n` where present.
 */
function splitLinesKeepEnds(text: string): string[] {
  if (text === "") {
    return [];
  }
  // Match each run up to and including a newline, plus a trailing run with no
  // newline. This reproduces Python `splitlines(keepends=True)` for `\n`.
  return text.match(/[^\n]*\n|[^\n]+$/g) ?? [];
}

/**
 * Remove the user-story clause used by the planner template when no user story
 * exists.
 *
 * Mirrors Python `_remove_user_story_clause_when_missing`: replaces the literal
 * `" and the \`${user-story}\`"` with the empty string.
 *
 * @param template Template content.
 * @returns Template with the clause removed.
 */
export function removeUserStoryClauseWhenMissing(template: string): string {
  return template.split(" and the `${user-story}`").join("");
}

/**
 * Remove every line that references an optional `${variable}` token.
 *
 * Mirrors Python `_remove_lines_referencing_variable` using
 * `splitlines(keepends=True)` semantics: lines are split while preserving their
 * trailing `\n`, lines containing the token are dropped, and the remainder is
 * re-joined so the output is byte-identical to the Python implementation.
 *
 * @param template Template content (front matter already removed).
 * @param variableName Variable name without `${...}` braces.
 * @returns Template with any lines referencing the variable removed.
 */
export function removeLinesReferencingVariable(
  template: string,
  variableName: string,
): string {
  const token = `\${${variableName}}`;
  const lines = splitLinesKeepEnds(template);
  // Keep only lines that do not reference the optional variable.
  const kept = lines.filter((line) => !line.includes(token));
  return kept.join("");
}

/**
 * Insert a block immediately after the first exact (trimmed) heading match.
 *
 * Mirrors Python `_insert_after_heading`: scans `splitlines(keepends=True)` for
 * the first line whose trimmed text equals `heading`, inserts `block` (ensuring
 * it ends with a newline) after it, and re-joins. When no heading matches, the
 * original template is returned unchanged.
 *
 * @param template Template content.
 * @param heading Exact heading text to match (compared after trimming).
 * @param block Block to insert after the heading.
 * @returns Template with the block inserted, or the original template.
 */
export function insertAfterHeading(
  template: string,
  heading: string,
  block: string,
): string {
  const lines = splitLinesKeepEnds(template);

  // Insert after the first exact heading match to keep behavior deterministic.
  for (let index = 0; index < lines.length; index += 1) {
    if ((lines[index] ?? "").trim() !== heading) {
      continue;
    }
    const insertion = block.endsWith("\n") ? block : `${block}\n`;
    lines.splice(index + 1, 0, insertion);
    return lines.join("");
  }

  return template;
}

/**
 * Apply deterministic minor-audit prompt overrides.
 *
 * Mirrors Python `_apply_minor_audit_overrides`: removes spec/user-story/
 * research requirement lines, then inserts the byte-identical minor-audit mode
 * block after the `## Core Requirements` heading.
 *
 * @param template Template content without front matter.
 * @returns Template with minor-audit overrides applied.
 */
export function applyMinorAuditOverrides(template: string): string {
  let updated = template;
  // Remove optional document references that are invalid for minor-audit.
  for (const variableName of ["spec", "user-story", "research"]) {
    updated = removeLinesReferencingVariable(updated, variableName);
  }

  const modeBlock =
    "\n" +
    "### Minor-Audit Mode Overrides (Mandatory)\n" +
    "\n" +
    "- Use `${folderpath}/issue.md` as the sole requirements source.\n" +
    "- Do not require or reference `${spec}`, `${user-story}`, or `${research}`.\n" +
    "- Output exactly 3 phases in this order:\n" +
    "  - Phase 0 — Baseline Capture\n" +
    "  - Phase 1 — Handoff to small-path planning/development agent\n" +
    "  - Phase 2 — Final QC loop\n";

  return insertAfterHeading(updated, "## Core Requirements", modeBlock);
}

/**
 * Extract `${...}` placeholder names from a template.
 *
 * Mirrors Python `_extract_template_variables` (`re.finditer(r"\$\{([^}]+)\}")`).
 *
 * @param template Template content.
 * @returns The set of referenced variable names.
 */
export function extractTemplateVariables(template: string): Set<string> {
  const names = new Set<string>();
  const pattern = /\$\{([^}]+)\}/g;
  let match: RegExpExecArray | null = pattern.exec(template);
  // Collect every distinct placeholder name referenced by the template.
  while (match !== null) {
    names.add(match[1] ?? "");
    match = pattern.exec(template);
  }
  return names;
}

/**
 * Replace every referenced placeholder using the provided mapping.
 *
 * Mirrors Python `_replace_all_variables`: raises when any referenced variable
 * is missing from the mapping, substitutes in sorted key order for
 * determinism, then raises again if any `${...}` placeholder remains.
 *
 * @param template Template content.
 * @param variables Mapping of variable name to substitution value.
 * @returns The fully resolved template.
 * @throws Error When a referenced variable is missing
 *   (`Unresolved template variables: ...`) or when placeholders remain after
 *   substitution (`Template resolution failed: unresolved placeholders remain`).
 */
export function replaceAllVariables(
  template: string,
  variables: Readonly<Record<string, string>>,
): string {
  const referenced = extractTemplateVariables(template);
  const missing = [...referenced].filter((name) => !(name in variables)).sort();
  if (missing.length > 0) {
    throw new Error(`Unresolved template variables: ${missing.join(", ")}`);
  }

  let resolved = template;
  // Apply substitutions deterministically in sorted key order for stability.
  for (const key of [...referenced].sort()) {
    resolved = resolved.split(`\${${key}}`).join(variables[key] ?? "");
  }

  if (extractTemplateVariables(resolved).size > 0) {
    throw new Error(
      "Template resolution failed: unresolved placeholders remain",
    );
  }

  return resolved;
}
