import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  parseParallelKickoff,
  validateParallelKickoffText,
} from "../../../src/lib/validate/parallel-kickoff-artifact";

/**
 * Producer/consumer seam tests for the parallel kickoff template.
 *
 * Purpose:
 *     Bind the PRODUCER of parallel kickoff documents — the fenced `markdown`
 *     template under `## Kickoff Artifact` in
 *     `.claude/skills/parallel-plan/SKILL.md` — to the CONSUMER that validates
 *     them, `extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts`.
 *     The two surfaces are delivered by the same feature and were previously
 *     verified only against hand-authored fixtures, which allowed the template
 *     and the matcher to disagree without any test failing.
 *
 * Real-filesystem read:
 *     Unlike the sibling `parallel-kickoff-artifact*.test.ts` modules, this
 *     suite intentionally reads the REAL canonical skill file from disk via
 *     `node:fs`/`node:path` resolved from `__dirname`, rather than a fixture.
 *     A fixture copy could drift from the runtime surface, which is exactly the
 *     failure mode this seam exists to prevent. The precedent for reading a
 *     committed repository file from a Jest suite is
 *     `test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
 *
 * Scope boundaries:
 *     Structural validation only. The module spawns no child process, imports
 *     no child-process API, and never invokes the Python runtime; the Python
 *     seam lives in `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py`
 *     and the two are kept in agreement by identical substitution constants.
 */

/**
 * Canonical repository-root skill file, five levels up from this directory.
 *
 * `test/lib/validate` -> `test/lib` -> `test` -> `drm-copilot` -> `extensions`
 * -> repository root. This deliberately resolves the repository-root file, not
 * the bundled mirror under `resources/claude-customizations/`.
 */
const PARALLEL_PLAN_SKILL_PATH = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  ".claude",
  "skills",
  "parallel-plan",
  "SKILL.md",
);

// Substitution values for the template's authoring placeholders. These are
// byte-identical to the constants in the Python seam module so a rendering
// divergence between the runtimes cannot mask a contract divergence.
const SLUG = "bugfix-batch";
const ISO8601 = "2026-08-08T15:15:00Z";
const PLANNING_COMMIT_HEX = "4a7f1c9e2b8d3a6f0c5e91b47d28a3f6c0e5b91d";
const PLAN_PATH =
  "docs/features/active/2026-08-07-parallel-planner-surface-443/plan.md";
const PLAN_HASH_HEX = "9f2e4c7a1b5d8e0f3a6c9b2d5e8f1a4c7b0d3e6f";
const ITEM_ROW =
  "| 443 | docs/features/active/2026-08-07-parallel-planner-surface-443 " +
  `| 0 | C3 | feature/parallel-planner-surface-443 | ${PLAN_PATH} |`;
const HASH_ROW = `| ${PLAN_PATH} | ${PLAN_HASH_HEX} |`;

// The template's own resume-boundary subject and verb, used as the anchor for
// the alternant-substitution tests. The anchor spans the template's line break
// so the later lowercase "each item opens its own pull request" clause is not
// rewritten by accident.
const TEMPLATE_RESUME_ANCHOR = "Each item\nresumes";

const KICKOFF_FENCE_RE = /^```markdown\r?\n([\s\S]*?)^```/m;

const STRUCTURAL_INVOCATION_ERROR =
  "Parallel kickoff invocation must structurally name the manifest, " +
  "plan-home branch, and atomic-execution resume boundary.";

/**
 * Return the fenced kickoff template published under `## Kickoff Artifact`.
 *
 * Mirrors the Python `extract_kickoff_template` for the same input, so both
 * runtimes validate the same producer text.
 *
 * @param text - Full text of `.claude/skills/parallel-plan/SKILL.md`.
 * @returns Inner text of the first fenced `markdown` block after the heading.
 * @throws Error when the heading or the fenced block is absent.
 */
function extractKickoffTemplate(text: string): string {
  const headingIndex = text.indexOf("\n## Kickoff Artifact\n");
  if (headingIndex < 0) {
    throw new Error("parallel-plan skill has no '## Kickoff Artifact' heading");
  }
  const match = KICKOFF_FENCE_RE.exec(text.slice(headingIndex));
  if (match === null) {
    throw new Error("no fenced markdown block follows '## Kickoff Artifact'");
  }
  return match[1];
}

/**
 * Replace each `| ... |` placeholder row with a concrete row of matching width.
 *
 * Six cells is the `## Item Summary` row and two cells is the `## Integrity`
 * hash row. Any other width means the template grew a placeholder shape this
 * suite cannot fill, which is reported rather than silently passed through.
 *
 * @param rendered - Template text whose scalar placeholders are substituted.
 * @returns The same text with every all-ellipsis pipe row replaced.
 * @throws Error when a placeholder row has an unrecognized cell count.
 */
function substitutePlaceholderRows(rendered: string): string {
  const lines: string[] = [];
  for (const line of rendered.split("\n")) {
    const stripped = line.trim();
    const isPipeRow = stripped.startsWith("|") && stripped.endsWith("|");
    const cells = isPipeRow
      ? stripped
          .slice(1, -1)
          .split("|")
          .map((cell) => cell.trim())
      : [];
    if (cells.length > 0 && cells.every((cell) => cell === "...")) {
      if (cells.length === 6) {
        lines.push(ITEM_ROW);
      } else if (cells.length === 2) {
        lines.push(HASH_ROW);
      } else {
        throw new Error(
          `unexpected placeholder row width: ${String(cells.length)}`,
        );
      }
      continue;
    }
    lines.push(line);
  }
  return lines.join("\n");
}

/**
 * Substitute the template's placeholders into a concrete kickoff document.
 *
 * Uses the same substitution values as the Python seam module.
 *
 * @param template - Inner text of the fenced kickoff template.
 * @param options - `includeIntegrity` retains or removes the optional
 *   `## Integrity` section, so both contract paths are exercised.
 * @returns A rendered kickoff document carrying no residual authoring token.
 * @throws Error on an unrecognized placeholder row, a missing `## Integrity`
 *   section when removal is requested, or a residual authoring token.
 */
function renderKickoffTemplate(
  template: string,
  options: { includeIntegrity: boolean },
): string {
  let rendered = template.split("<slug>").join(SLUG);
  rendered = rendered.split("<iso8601>").join(ISO8601);
  rendered = rendered.split("<hex>").join(PLANNING_COMMIT_HEX);
  rendered = substitutePlaceholderRows(rendered);
  // The integrity section is the template's only optional block, so removing it
  // is how the absent-section contract path is reached without authoring a
  // second, independently-maintained template.
  if (!options.includeIntegrity) {
    const index = rendered.indexOf("\n## Integrity\n");
    if (index < 0) {
      throw new Error("template has no '## Integrity' section");
    }
    rendered = `${rendered.slice(0, index).replace(/\s+$/u, "")}\n`;
  }
  // A surviving authoring token would make the document structurally invalid
  // for a reason unrelated to the contract under test.
  for (const token of ["<slug>", "<iso8601>", "<hex>", "..."]) {
    if (rendered.includes(token)) {
      throw new Error(`residual authoring token in rendering: ${token}`);
    }
  }
  return rendered;
}

/**
 * Read the canonical parallel-plan skill from the repository root.
 *
 * @returns Full UTF-8 text of `.claude/skills/parallel-plan/SKILL.md`.
 */
function readSkillText(): string {
  return fs.readFileSync(PARALLEL_PLAN_SKILL_PATH, "utf8");
}

describe("parallel kickoff template seam (real canonical skill file)", () => {
  it("extracts the documented kickoff block rather than another fenced block", () => {
    // Arrange
    const skillText = readSkillText();

    // Act
    const template = extractKickoffTemplate(skillText);

    // Assert
    expect(template.startsWith("# Parallel Kickoff: <slug>")).toBe(true);
    expect(template).toContain("## Invocation Prompt");
    expect(template).toContain("## Item Summary");
    expect(template).toContain("## Integrity");
  });

  it("validates the rendered template with the ## Integrity section", () => {
    // Arrange
    const template = extractKickoffTemplate(readSkillText());
    const rendered = renderKickoffTemplate(template, {
      includeIntegrity: true,
    });

    // Act
    const errors = validateParallelKickoffText(rendered);

    // Assert
    expect(errors).toEqual([]);
  });

  it("validates the rendered template without the ## Integrity section", () => {
    // Arrange
    const template = extractKickoffTemplate(readSkillText());
    const rendered = renderKickoffTemplate(template, {
      includeIntegrity: false,
    });

    // Act
    const errors = validateParallelKickoffText(rendered);

    // Assert
    expect(rendered).not.toContain("## Integrity");
    expect(rendered).not.toContain("planning_commit");
    expect(errors).toEqual([]);
  });

  it("captures planningCommit from the rendered integrity section", () => {
    // Arrange
    const template = extractKickoffTemplate(readSkillText());
    const rendered = renderKickoffTemplate(template, {
      includeIntegrity: true,
    });

    // Act
    const result = parseParallelKickoff(rendered);

    // Assert
    expect(result.errors).toEqual([]);
    expect(result.parsed?.planningCommit).toBe(PLANNING_COMMIT_HEX);
  });

  it.each([
    ["Every item", "resumes"],
    ["Each item", "resumes"],
    ["items", "resume"],
  ])("accepts the documented resume-boundary alternant %s", (subject, verb) => {
    // Arrange
    const template = extractKickoffTemplate(readSkillText());
    const rendered = renderKickoffTemplate(template, {
      includeIntegrity: true,
    });
    const respelled = rendered
      .split(TEMPLATE_RESUME_ANCHOR)
      .join(`${subject}\n${verb}`);

    // Act
    const errors = validateParallelKickoffText(respelled);

    // Assert
    expect(rendered).toContain(TEMPLATE_RESUME_ANCHOR);
    expect(errors).toEqual([]);
  });

  it("rejects an undocumented resume-boundary subject", () => {
    // Arrange
    // `Each entry` is chosen because RESUME_RE is applied with a substring
    // search and carries no word boundary, so a negative subject must contain
    // none of `Every item`, `Each item`, or `items` as a substring. `Some items`
    // would match both before and after the B1 widening and is therefore not a
    // valid negative. This spelling is byte-identical to the Python seam
    // module's negative case, so both runtimes exercise the same input.
    const template = extractKickoffTemplate(readSkillText());
    const rendered = renderKickoffTemplate(template, {
      includeIntegrity: true,
    });
    const respelled = rendered
      .split(TEMPLATE_RESUME_ANCHOR)
      .join("Each entry\nresumes");

    // Act
    const errors = validateParallelKickoffText(respelled);

    // Assert
    expect(rendered).toContain(TEMPLATE_RESUME_ANCHOR);
    expect(errors).toEqual([STRUCTURAL_INVOCATION_ERROR]);
  });
});
