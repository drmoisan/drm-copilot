import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateRoutingContract } from "../../../src/lib/validate/orchestrator-state-routing";

/**
 * Promotion-type routing-contract regression tests for `validateRoutingContract`.
 *
 * Purpose:
 *     Mirror the four PR #402 Python tests in
 *     `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`
 *     so the TypeScript validator resolves the promotion-entry tool from
 *     `promotion-type` exactly as the Python authority does. The matrix is the
 *     real `config/orchestration-routing.json`, not a hand-built copy.
 *
 * Filesystem access:
 *     Read-only load of the committed routing matrix, resolved from `__dirname`
 *     five levels up to the repository root. No temporary file, timer, or clock.
 */

/** Feature-type promotion-entry tool. */
const FEATURE_TOOL = "new_potential_entry";

/** Bug-type promotion-entry tool. */
const BUG_TOOL = "new_potential_bug_entry";

/** Real routing matrix path, five levels above this directory. */
const ROUTING_MATRIX_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "config",
  "orchestration-routing.json",
);

/** Parsed real routing matrix. */
const ROUTING_MATRIX: unknown = JSON.parse(fs.readFileSync(ROUTING_MATRIX_PATH, "utf8"));

/** The three declared lists of the real `large` route. */
interface LargeRoute {
  readonly agents: string[];
  readonly skills: string[];
  readonly tools: string[];
}

/**
 * Read the `large` route lists from the real routing matrix.
 *
 * @returns The required agents, skills, and MCP tools of route `large`.
 * @throws Error when the matrix does not have the expected shape.
 */
function readLargeRoute(): LargeRoute {
  const root = ROUTING_MATRIX as { routes?: Record<string, Record<string, unknown>> };
  const route = root.routes?.["large"];
  if (route === undefined) {
    throw new Error("routing matrix has no large route.");
  }
  return {
    agents: route["required_agents"] as string[],
    skills: route["required_skills"] as string[],
    tools: route["required_mcp_tools"] as string[],
  };
}

/**
 * Build a completion-safe `large` checkpoint from the real route lists.
 *
 * @param promotionType Value written to `promotion-type`.
 * @param tools Tool list used for both `required_mcp_tools` and the receipts.
 * @returns A checkpoint that satisfies every routing-contract row.
 */
function buildLargeState(promotionType: string, tools: string[]): Record<string, unknown> {
  const route = readLargeRoute();
  return {
    route_id: "large",
    "promotion-type": promotionType,
    required_agents: route.agents,
    required_skills: route.skills,
    required_mcp_tools: tools,
    delegation_receipts: route.agents.map((agent) => ({ agent_name: agent })),
    skill_receipts: route.skills.map((skill) => ({
      skill,
      required: true,
      evidence: `artifact:${skill}`,
    })),
    mcp_call_receipts: tools.map((tool) => ({
      tool,
      ok: true,
      evidence: `mcp_call:${tool}`,
    })),
    local_execution_overrides: [],
    delegation_bypasses: [],
  };
}

/**
 * Return the real large-route tool list with the feature tool replaced by the
 * bug tool in place.
 *
 * @returns The bug-type tool list.
 */
function bugTools(): string[] {
  return readLargeRoute().tools.map((tool) => (tool === FEATURE_TOOL ? BUG_TOOL : tool));
}

describe("validateRoutingContract promotion-type resolution", () => {
  it("accepts a bug-type large-route checkpoint that declares and records new_potential_bug_entry", () => {
    // Arrange: a bug-type checkpoint whose declared and recorded tools are the bug tools.
    const state = buildLargeState("bug", bugTools());

    // Act: run the routing-contract validator against the real matrix.
    const errors = validateRoutingContract(state, { routingMatrix: ROUTING_MATRIX });

    // Assert: the bug-type promotion validates cleanly.
    expect(errors).toEqual([]);
  });

  it("accepts a feature-type large-route checkpoint that declares and records new_potential_entry", () => {
    // Arrange: the feature-type baseline checkpoint.
    const state = buildLargeState("feature", readLargeRoute().tools);

    // Act: run the routing-contract validator against the real matrix.
    const errors = validateRoutingContract(state, { routingMatrix: ROUTING_MATRIX });

    // Assert: feature-type behavior is unchanged.
    expect(errors).toEqual([]);
  });

  it("excludes the removed dead skill names from the real large-route required_skills", () => {
    // Arrange: read the large-route skills from the real matrix.
    const { skills } = readLargeRoute();

    // Act / Assert: the removed dead names are absent.
    expect(skills).not.toContain("orchestrator-workflow");
    expect(skills).not.toContain("repo-automation-adapter");
  });

  it("rejects a bug-type large-route checkpoint that declares and records only new_potential_entry", () => {
    // Arrange: mark the feature-type baseline as a bug promotion without
    // substituting the promotion-entry tool in the declared or recorded evidence.
    const state = buildLargeState("bug", readLargeRoute().tools);

    // Act: run the routing-contract validator against the real matrix.
    const errors = validateRoutingContract(state, { routingMatrix: ROUTING_MATRIX });

    // Assert: the bug-tool mismatch and missing bug-tool receipt are reported,
    // and the feature-tool receipt is not demanded.
    expect(errors).toContain(
      "Checkpoint required_mcp_tools must match routing matrix for route large.",
    );
    expect(errors).toContain(
      "Checkpoint missing successful MCP receipt: new_potential_bug_entry.",
    );
    expect(errors).not.toContain(
      "Checkpoint missing successful MCP receipt: new_potential_entry.",
    );
  });
});
