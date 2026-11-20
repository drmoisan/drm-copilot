/**
 * Write-scope literal contract (issue #1035, spec "Write-scope literal contract (D-16)").
 *
 * Purpose:
 *     The single source of the development-docs literals that agent `tools:`
 *     lists, the settings `permissions.allow` list and the `-RequiredArtifact`
 *     hook arguments must carry. Each rule names an area; the expansion
 *     functions turn a rule into one literal per known root, so during the
 *     fallback release both the `docs/features` form and the `.dev` form are
 *     required.
 *
 * Usage:
 *     The contract checker suite and the agent generator of epic child 3
 *     import the rule tables and call `expandWriteScopeLiterals` and
 *     `expandRequiredArtifactPattern` with `KNOWN_DEVELOPMENT_DOCS_ROOTS`.
 *
 * Side effects:
 *     None. Area paths come from `developmentDocsPath`; this module imports no
 *     `vscode` API and performs no I/O.
 */

import { DevelopmentDocsRoot, developmentDocsPath } from "./root";

/** The development-docs areas a write-scope rule can name. */
export type WriteScopeArea =
  | "root"
  | "active"
  | "potential"
  | "epics"
  | "parallel"
  | "feature-research"
  | "one-off-research"
  | "docs-broad";

/** One agent `tools:` rule; `leadingSlash` preserves the agent's spelling. */
export interface WriteScopeRule {
  readonly agent: string;
  readonly tool: "Write" | "Edit";
  readonly area: WriteScopeArea;
  readonly leadingSlash: boolean;
}

/** One `.claude/settings.json` `permissions.allow` rule (never a leading slash). */
export interface SettingsAllowRule {
  readonly tool: "Edit";
  readonly area: WriteScopeArea;
}

/** One `-RequiredArtifact` hook argument rule. */
export interface RequiredArtifactRule {
  readonly agent: string;
  readonly token: string;
  readonly area: WriteScopeArea;
  readonly suffixPattern: string;
}

/** The agent rules of the Phase 1 rule table, in table order. */
export const WRITE_SCOPE_RULES: ReadonlyArray<WriteScopeRule> = [
  {
    agent: "atomic-planner",
    tool: "Edit",
    area: "docs-broad",
    leadingSlash: false,
  },
  {
    agent: "atomic-planner",
    tool: "Write",
    area: "docs-broad",
    leadingSlash: false,
  },
  {
    agent: "task-researcher",
    tool: "Write",
    area: "feature-research",
    leadingSlash: true,
  },
  {
    agent: "task-researcher",
    tool: "Write",
    area: "one-off-research",
    leadingSlash: true,
  },
  { agent: "prd-feature", tool: "Write", area: "active", leadingSlash: true },
  {
    agent: "feature-review",
    tool: "Write",
    area: "active",
    leadingSlash: true,
  },
  { agent: "status-updater", tool: "Write", area: "root", leadingSlash: true },
  { agent: "epic-review", tool: "Write", area: "root", leadingSlash: true },
  { agent: "epic-planner", tool: "Write", area: "epics", leadingSlash: false },
  { agent: "epic-planner", tool: "Edit", area: "epics", leadingSlash: false },
  {
    agent: "epic-planner",
    tool: "Write",
    area: "potential",
    leadingSlash: false,
  },
  {
    agent: "epic-orchestrator",
    tool: "Write",
    area: "epics",
    leadingSlash: false,
  },
  {
    agent: "epic-orchestrator",
    tool: "Edit",
    area: "epics",
    leadingSlash: false,
  },
  {
    agent: "parallel-orchestrator",
    tool: "Write",
    area: "parallel",
    leadingSlash: false,
  },
  {
    agent: "parallel-orchestrator",
    tool: "Edit",
    area: "parallel",
    leadingSlash: false,
  },
  {
    agent: "parallel-planner",
    tool: "Write",
    area: "parallel",
    leadingSlash: false,
  },
  {
    agent: "parallel-planner",
    tool: "Edit",
    area: "parallel",
    leadingSlash: false,
  },
];

/** The settings `permissions.allow` rules. */
export const SETTINGS_ALLOW_RULES: ReadonlyArray<SettingsAllowRule> = [
  { tool: "Edit", area: "docs-broad" },
];

/** The `-RequiredArtifact` hook argument rules. */
export const REQUIRED_ARTIFACT_RULES: ReadonlyArray<RequiredArtifactRule> = [
  {
    agent: "prd-feature",
    token: "spec-path",
    area: "active",
    suffixPattern: ".+/spec\\.md$",
  },
  {
    agent: "epic-review",
    token: "epic-audit-path",
    area: "epics",
    suffixPattern: ".+/epic-audit\\.\\d{4}-\\d{2}-\\d{2}T\\d{2}-\\d{2}\\.md$",
  },
];

/**
 * Return the directory that holds a root's sibling areas: `docs` for
 * `docs/features` and `.dev` for `.dev` (the parent of the engineering area).
 */
function siblingBase(root: DevelopmentDocsRoot): string {
  const engineering = developmentDocsPath(root, "engineering");
  return engineering.slice(0, engineering.lastIndexOf("/"));
}

/**
 * Return the glob of one area under one root.
 *
 * @param area The write-scope area.
 * @param root A known root.
 * @returns The forward-slash glob without a leading slash.
 */
export function writeScopeAreaGlob(
  area: WriteScopeArea,
  root: DevelopmentDocsRoot,
): string {
  // Root-child areas map through the area map; the research and broad areas
  // are composed from the root or from the directory of its sibling areas.
  switch (area) {
    case "root":
      return `${root}/**`;
    case "active":
    case "potential":
    case "epics":
    case "parallel":
      return `${developmentDocsPath(root, area)}/**`;
    case "feature-research":
      return `${root}/**/research/**`;
    case "one-off-research":
      return `${developmentDocsPath(root, "research")}/**`;
    case "docs-broad":
      return `${siblingBase(root)}/**`;
    default:
      throw new Error(`Unknown write-scope area: ${String(area)}`);
  }
}

/**
 * Expand one rule into its literals, one per root, in root order.
 *
 * @param rule An agent rule or a settings rule.
 * @param roots The roots to expand for.
 * @returns For example `["Write(/docs/features/active/**)", "Write(/.dev/active/**)"]`.
 */
export function expandWriteScopeLiterals(
  rule: WriteScopeRule | SettingsAllowRule,
  roots: ReadonlyArray<DevelopmentDocsRoot>,
): string[] {
  const slash = "leadingSlash" in rule && rule.leadingSlash ? "/" : "";
  return roots.map(
    (root) => `${rule.tool}(${slash}${writeScopeAreaGlob(rule.area, root)})`,
  );
}

/** Escape regular-expression metacharacters in a literal path segment. */
function escapeRegex(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Return the area path of a required-artifact rule relative to its root:
 * empty for the root area and the area name for a root-child area.
 */
function requiredArtifactAreaSegment(area: WriteScopeArea): string {
  // Only areas that sit directly below a root have the same relative path
  // under every root, which a single alternation of roots requires.
  switch (area) {
    case "root":
      return "";
    case "active":
    case "potential":
    case "epics":
    case "parallel":
      return `${area}/`;
    default:
      throw new Error(
        `Required-artifact rules support root-child areas only: ${area}`,
      );
  }
}

/**
 * Expand one required-artifact rule into a regex accepting every root.
 *
 * @param rule The required-artifact rule.
 * @param roots The roots to accept.
 * @returns For example `^(?:docs/features|\.dev)/active/.+/spec\.md$`.
 */
export function expandRequiredArtifactPattern(
  rule: RequiredArtifactRule,
  roots: ReadonlyArray<DevelopmentDocsRoot>,
): string {
  const alternation = roots.map(escapeRegex).join("|");
  return `^(?:${alternation})/${requiredArtifactAreaSegment(rule.area)}${rule.suffixPattern}`;
}
