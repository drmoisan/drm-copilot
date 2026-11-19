/**
 * Brief bullet contract of the push-down integration tools (issue #1051,
 * S56): in the bundled Claude copy of the execution-environment brief, the
 * bullet that names both tools follows the docs-tools bullet.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

const BRIEF = readFileSync(
  join(
    __dirname,
    "..",
    "..",
    "resources",
    "claude-customizations",
    ".claude",
    "skills",
    "execution-environment",
    "SKILL.md",
  ),
  "utf8",
);
const SECTION = "## MCP Surfaces Run the Installed Extension";

/** Return the bullets of the MCP surfaces section. */
function sectionBullets(text: string): string[] {
  const start = text.indexOf(SECTION);
  if (start < 0) {
    return [];
  }
  const lines = text.slice(start).split("\n").slice(1);
  const end = lines.findIndex((line) => line.startsWith("## "));
  return (end < 0 ? lines : lines.slice(0, end)).filter((line) =>
    line.startsWith("- "),
  );
}

/** Return whether the integration bullet directly follows the docs-tools bullet. */
function bulletFollowsDocsTools(text: string): boolean {
  const bullets = sectionBullets(text);
  const docs = bullets.findIndex((line) =>
    line.startsWith("- The docs tools ("),
  );
  const next = docs < 0 ? undefined : bullets[docs + 1];
  return (
    next !== undefined &&
    next.includes("`detect_push_down_integration`") &&
    next.includes("`validate_push_down_integration`")
  );
}

describe("execution-environment brief bullet", () => {
  it("S56 positive: the bullet naming both tools follows the docs-tools bullet", () => {
    expect(bulletFollowsDocsTools(BRIEF)).toBe(true);
  });

  it("S56 negative: a brief whose bullet precedes the docs-tools bullet or lacks a name is detected", () => {
    const bullets = sectionBullets(BRIEF);
    const integration = bullets.find((line) =>
      line.includes("`detect_push_down_integration`"),
    );
    const docs = bullets.find((line) => line.startsWith("- The docs tools ("));
    const swapped = BRIEF.replace(
      `${docs ?? ""}\n${integration ?? ""}`,
      `${integration ?? ""}\n${docs ?? ""}`,
    );
    const unnamed = BRIEF.replace(
      "`validate_push_down_integration`",
      "`validate`",
    );

    expect(bulletFollowsDocsTools(swapped)).toBe(false);
    expect(bulletFollowsDocsTools(unnamed)).toBe(false);
    expect(bulletFollowsDocsTools("")).toBe(false);
  });
});
