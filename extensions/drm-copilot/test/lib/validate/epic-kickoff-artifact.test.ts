import { describe, expect, it } from "@jest/globals";

import {
  parseEpicKickoff,
  validateEpicKickoffText,
} from "../../../src/lib/validate/epic-kickoff-artifact";

const VALID_KICKOFF = `# Epic Kickoff: sample-epic
## Invocation Prompt
Run \`/epic-run sample-epic\` to execute this epic.
Use the epic-orchestrator subagent to execute the prepared epic at
docs/features/epics/sample-epic/epic.md. Reuse epic/sample-epic-integration.
Every child resumes at atomic execution from its committed plan-path;
do not repeat planning or preflight.
## Feature Summary
| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 101 | docs/features/active/feature-101 | 0 | C3 | docs/features/active/feature-101/plan.md |
`;

describe("validateEpicKickoffText", () => {
  it("accepts a kickoff containing every handoff fragment", () => {
    expect(validateEpicKickoffText(VALID_KICKOFF)).toEqual([]);
  });

  it("reports missing structural sections", () => {
    expect(validateEpicKickoffText("# Epic Kickoff: incomplete")).toEqual([
      "Epic kickoff is missing required section: ## Invocation Prompt",
      "Epic kickoff is missing required section: ## Feature Summary",
      "Epic kickoff invocation must contain `Run /epic-run <slug>`.",
      "Epic kickoff invocation must structurally name the manifest, " +
        "integration branch, and atomic-execution resume boundary.",
      "Epic kickoff table is missing its header or separator row.",
    ]);
  });

  it("accepts the merged Claude invocation wording", () => {
    const claudeBaseline = VALID_KICKOFF.replace(
      "docs/features/epics/sample-epic/epic.md. " +
        "Reuse epic/sample-epic-integration.\n" +
        "Every child resumes at atomic execution from its committed plan-path;",
      "docs/features/epics/sample-epic/epic.md. The integration branch\n" +
        "epic/sample-epic-integration already contains every prepared feature " +
        "folder and approved atomic plan; child features resume at atomic " +
        "execution from their committed plan-path rather than re-planning.",
    );

    expect(validateEpicKickoffText(claudeBaseline)).toEqual([]);
  });

  it.each([
    ["", "Epic kickoff is empty."],
    ["not a heading", "first line must match"],
    [
      VALID_KICKOFF.replace("## Feature Summary", "## Invocation Prompt"),
      "duplicate section",
    ],
    [VALID_KICKOFF.replace("issue_num", "issue"), "feature table headers"],
    [VALID_KICKOFF.replace("| --- |", "| bad |"), "separator row"],
    [
      VALID_KICKOFF.replace(
        "| 101 | docs/features/active/feature-101 | 0 | C3 |",
        "not a table row",
      ),
      "table row is invalid",
    ],
    [VALID_KICKOFF.replace("| 101 |", "| issue |"), "issue_num"],
    [
      VALID_KICKOFF.replace(
        "docs/features/active/feature-101 | 0 |",
        "docs/features/active/feature-101 | wave |",
      ),
      "wave must be an integer",
    ],
    [VALID_KICKOFF.replace("| C3 |", "| C5 |"), "complexity must be C1-C4"],
  ])("rejects malformed kickoff structure", (text, expected) => {
    expect(validateEpicKickoffText(text).join("\n")).toContain(expected);
  });

  it("parses optional integrity fields and rejects invalid declarations", () => {
    const validIntegrity =
      VALID_KICKOFF +
      [
        "## Integrity",
        `planning_commit: ${"a".repeat(40)}`,
        "| plan-path | plan-hash |",
        "| --- | --- |",
        `| docs/features/active/feature-101/plan.md | ${"b".repeat(40)} |`,
      ].join("\n");

    const parsed = parseEpicKickoff(validIntegrity);

    expect(parsed.errors).toEqual([]);
    expect(parsed.parsed?.planningCommit).toBe("a".repeat(40));
    expect(parsed.parsed?.planHashes).toEqual({
      "docs/features/active/feature-101/plan.md": "b".repeat(40),
    });

    const invalidIntegrity = validIntegrity
      .replace(
        "## Integrity",
        "## Integrity\ninvalid field\nplanning_commit: deadbeef",
      )
      .replace("| plan-path | plan-hash |", "| wrong | hash |")
      .replace("| --- | --- |", "| bad | bad |")
      .replace("b".repeat(40), "not-a-hash");
    expect(validateEpicKickoffText(invalidIntegrity).join("\n")).toContain(
      "integrity",
    );
  });
});
