/**
 * Contract tests of the `push-down-integration` skill (issue #1051, S51 to
 * S54). The four tracked copies are read from the repository tree; the S53 and
 * S54 negative cases edit an in-memory copy of the bundled Claude text.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import {
  INTEGRATION_ITEM_KINDS,
  RESOLUTION_OPTIONS_BY_KIND,
} from "../../src/lib/push-down-integration/integration-items";
import { VALIDATE_NOT_CHECKED } from "../../src/lib/push-down-integration/integration-validate";

const REPOSITORY_ROOT = join(__dirname, "..", "..", "..", "..");
const RESOURCES = "extensions/drm-copilot/resources";
const SKILL = "skills/push-down-integration/SKILL.md";
const COPIES = [
  `.agents/${SKILL}`,
  `.claude/${SKILL}`,
  `${RESOURCES}/codex-and-agents-customizations/.agents/${SKILL}`,
  `${RESOURCES}/claude-customizations/.claude/${SKILL}`,
] as const;

/** Read a tracked repository file. */
function read(path: string): string {
  return readFileSync(join(REPOSITORY_ROOT, ...path.split("/")), "utf8");
}

const BUNDLED_CLAUDE = read(
  `${RESOURCES}/claude-customizations/.claude/${SKILL}`,
);

/** The ordered loop anchors of S52, each a single-line literal of the skill. */
const LOOP_STEPS = [
  "Read `.push-down-integration-needed.json`",
  "Call `detect_push_down_integration`",
  "Resolve each item by kind with ordinary edits under the destination's hooks and review",
  "Call `validate_push_down_integration`",
  "On `verdict: fail`",
  "Stop only when `integration.verdict` is `pass`",
  "Quote the `not_checked` list in the hand-off",
  "Re-run the push-down and report each item that remains",
] as const;

/** Return whether every loop step occurs, in order. */
function statesLoopInOrder(text: string): boolean {
  let from = 0;
  for (const step of LOOP_STEPS) {
    const at = text.indexOf(step, from);
    if (at < 0) {
      return false;
    }
    from = at + step.length;
  }
  return true;
}

/** Return the kinds whose table row lacks the kind or one of its options. */
function kindsMissingGuidance(text: string): string[] {
  const rows = text.split("\n").filter((line) => line.startsWith("| `"));
  return INTEGRATION_ITEM_KINDS.filter((kind) => {
    const row = rows.find((line) => line.startsWith(`| \`${kind}\` |`));
    return (
      row === undefined ||
      !RESOLUTION_OPTIONS_BY_KIND[kind].every((option) =>
        row.includes(`\`${option}\``),
      )
    );
  });
}

/** Return the bullets of the `## What Validate Does Not Check` section. */
function notCheckedBullets(text: string): string[] {
  const start = text.indexOf("## What Validate Does Not Check");
  if (start < 0) {
    return [];
  }
  const rest = text.slice(start).split("\n").slice(1);
  const end = rest.findIndex((line) => line.startsWith("#"));
  return (end < 0 ? rest : rest.slice(0, end))
    .filter((line) => line.startsWith("- "))
    .map((line) => line.slice(2).trim());
}

describe("push-down-integration skill", () => {
  it("S51 positive: the four copies are byte-identical", () => {
    const texts = COPIES.map(read);

    expect(new Set(texts).size).toBe(1);
    expect(texts[0]?.startsWith("---\nname: push-down-integration\n")).toBe(
      true,
    );
  });

  it("S51 negative: a copy that differs by one byte is detected", () => {
    const texts = [...COPIES.map(read)];
    texts[3] = `${texts[3] ?? ""} `;

    expect(new Set(texts).size).toBe(2);
  });

  it("S52 positive: names both tools and the file and states the loop in order", () => {
    expect(BUNDLED_CLAUDE).toContain("detect_push_down_integration");
    expect(BUNDLED_CLAUDE).toContain("validate_push_down_integration");
    expect(BUNDLED_CLAUDE).toContain(".push-down-integration-needed.json");
    expect(statesLoopInOrder(BUNDLED_CLAUDE)).toBe(true);
    expect(BUNDLED_CLAUDE).toContain("listing it in `.push-down-exclusions`");
  });

  it("S52 negative: a copy with two steps swapped is not in order", () => {
    const swapped = BUNDLED_CLAUDE.replace(
      "Call `validate_push_down_integration`.",
      "PLACEHOLDER",
    )
      .replace(
        "Stop only when `integration.verdict` is `pass`.",
        "Call `validate_push_down_integration`.",
      )
      .replace(
        "PLACEHOLDER",
        "Stop only when `integration.verdict` is `pass`.",
      );

    expect(statesLoopInOrder(swapped)).toBe(false);
  });

  it("S53 positive: the per-kind table names every kind and every option", () => {
    expect(kindsMissingGuidance(BUNDLED_CLAUDE)).toEqual([]);
  });

  it("S53 negative: removing a kind from the skill text is detected", () => {
    const removed = BUNDLED_CLAUDE.split("\n")
      .filter((line) => !line.startsWith("| `deleted-locally` |"))
      .join("\n");

    expect(kindsMissingGuidance(removed)).toEqual(["deleted-locally"]);
  });

  it("S54 positive: the not-checked section equals VALIDATE_NOT_CHECKED in order", () => {
    expect(notCheckedBullets(BUNDLED_CLAUDE)).toEqual([
      ...VALIDATE_NOT_CHECKED,
    ]);
  });

  it("S54 negative: a dropped or reordered bullet is detected", () => {
    const dropped = BUNDLED_CLAUDE.replace("- runner labels\n", "");
    const reordered = BUNDLED_CLAUDE.replace(
      "- hook behavior\n- symlinks and reparse points\n",
      "- symlinks and reparse points\n- hook behavior\n",
    );

    expect(notCheckedBullets(dropped)).not.toEqual([...VALIDATE_NOT_CHECKED]);
    expect(notCheckedBullets(reordered)).not.toEqual([...VALIDATE_NOT_CHECKED]);
    expect(notCheckedBullets("no section")).toEqual([]);
  });
});
