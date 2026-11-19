/**
 * Host exposure contract of the push-down integration tools (issue #1051,
 * S55): the bundled Codex config enables both tools without an approval
 * table, and the bundled `repo-automation-adapter` skill lists both.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

const BUNDLE = join(
  __dirname,
  "..",
  "..",
  "resources",
  "codex-and-agents-customizations",
);
const CONFIG = readFileSync(join(BUNDLE, ".codex", "config.toml"), "utf8");
const ADAPTER = readFileSync(
  join(BUNDLE, ".agents", "skills", "repo-automation-adapter", "SKILL.md"),
  "utf8",
);
const NAMES = [
  "detect_push_down_integration",
  "validate_push_down_integration",
] as const;

/** Return the quoted names of the drm-copilot `enabled_tools` array. */
function enabledTools(text: string): string[] {
  const start = text.indexOf("[mcp_servers.drm-copilot]");
  const block = text.slice(start);
  const open = block.indexOf("enabled_tools = [");
  const close = block.indexOf("]", open);
  if (start < 0 || open < 0) {
    return [];
  }
  return [...block.slice(open, close).matchAll(/"([^"]+)"/g)].map(
    (match) => match[1] ?? "",
  );
}

/** Return whether either tool carries a per-tool approval table. */
function hasApprovalTable(text: string): boolean {
  return NAMES.some((name) =>
    text.includes(`[mcp_servers.drm-copilot.tools.${name}]`),
  );
}

/** Return the tool names listed under `## Published MCP Tool Surface`. */
function publishedTools(text: string): string[] {
  const start = text.indexOf("## Published MCP Tool Surface");
  if (start < 0) {
    return [];
  }
  const lines = text.slice(start).split("\n").slice(1);
  const end = lines.findIndex((line) => line.startsWith("## "));
  return (end < 0 ? lines : lines.slice(0, end))
    .filter((line) => /^- `[a-z_]+`$/.test(line))
    .map((line) => line.slice(3, -1));
}

describe("push-down integration host exposure", () => {
  it("S55 positive: the bundled Codex config enables both tools after validate_orchestration_artifacts with no approval table", () => {
    const tools = enabledTools(CONFIG);
    const index = tools.indexOf("validate_orchestration_artifacts");

    expect(tools.slice(index + 1, index + 3)).toEqual([...NAMES]);
    expect(hasApprovalTable(CONFIG)).toBe(false);
  });

  it("S55 positive: the bundled adapter skill lists both tools after transition_prepared_orchestration", () => {
    const tools = publishedTools(ADAPTER);
    const index = tools.indexOf("transition_prepared_orchestration");

    expect(tools.slice(index + 1, index + 3)).toEqual([...NAMES]);
  });

  it("S55 negative: a config without the names, an approval table, or an adapter without the names is detected", () => {
    const withoutNames = CONFIG.replace(`    "${NAMES[0]}",\n`, "");
    const approved = `${CONFIG}\n[mcp_servers.drm-copilot.tools.${NAMES[1]}]\napproval_mode = "approve"\n`;
    const adapter = ADAPTER.replace(`- \`${NAMES[1]}\`\n`, "");

    expect(enabledTools(withoutNames)).not.toContain(NAMES[0]);
    expect(hasApprovalTable(approved)).toBe(true);
    expect(publishedTools(adapter)).not.toContain(NAMES[1]);
    expect(enabledTools("")).toEqual([]);
    expect(publishedTools("")).toEqual([]);
  });
});
