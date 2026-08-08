/**
 * Shared document builders for the parallel kickoff Jest suites.
 *
 * Extracted under the [P3-T9] conditional-split instruction so that neither
 * `parallel-kickoff-artifact.test.ts` nor
 * `parallel-kickoff-artifact-tables.test.ts` exceeds the repository's 500-line
 * file-size limit. This file deliberately carries no `.test` infix: the
 * repository-root `jest.config.cjs` `testMatch` pattern is
 * `**\/extensions/drm-copilot/test/**\/*.test.ts`, so importing this module
 * registers no duplicate suites.
 *
 * Every builder returns an in-memory string. Nothing here touches the
 * filesystem or starts an external process.
 */

export const ITEM_HEADER_ROW =
  "| issue_num | feature_folder | cohort | complexity | branch | plan-path |";
export const ITEM_SEPARATOR_ROW = "| --- | --- | --- | --- | --- | --- |";
export const PLAN_PATH_101 = "docs/features/active/item-101/plan.md";
export const ITEM_ROW_101 =
  "| 101 | docs/features/active/item-101 | 0 | C3 | feature/item-101 | " +
  `${PLAN_PATH_101} |`;
export const HASH_40 = "a".repeat(40);
export const HASH_64 = "b".repeat(64);

const INVOCATION_BLOCK = [
  "## Invocation Prompt",
  "Run `/parallel-run sample-run` to execute this parallel run.",
  "Use the parallel-orchestrator subagent to execute the prepared run at",
  "docs/features/parallel/sample-run/parallel.md. The plan-home branch",
  "parallel/sample-run-plan already contains every approved atomic plan;",
  "items resume at atomic execution from their committed plan-path on",
  "their own pushed feature branch rather than re-planning.",
].join("\n");

/** Render a canonical kickoff without the optional integrity section. */
export function kickoff(rows: ReadonlyArray<string> = [ITEM_ROW_101]): string {
  return [
    "# Parallel Kickoff: sample-run",
    INVOCATION_BLOCK,
    "## Item Summary",
    ITEM_HEADER_ROW,
    ITEM_SEPARATOR_ROW,
    ...rows,
  ].join("\n");
}

/** Render a canonical kickoff including the optional integrity section. */
export function kickoffWithIntegrity(
  integrityLines: ReadonlyArray<string> = [
    `planning_commit: ${"e".repeat(40)}`,
    "| plan-path | plan-hash |",
    "| --- | --- |",
    `| ${PLAN_PATH_101} | ${HASH_40} |`,
  ],
  rows: ReadonlyArray<string> = [ITEM_ROW_101],
): string {
  return [kickoff(rows), "## Integrity", ...integrityLines].join("\n");
}
