import { describe, expect, it } from "@jest/globals";

import {
  validateEpicChildLaunchBindings,
  validateEpicPlannerChildLaunchBindings,
} from "../../../src/lib/validate/epic-orchestrator-state-launch-binding";

const DEPLOYMENT_AGENT_ERROR =
  "Epic planner checkpoint features[0] launch binding.model_routing_receipt.deployment_agent must be a non-empty string.";
const WORKTREE_PATH_ERROR =
  "Epic planner checkpoint features[0] launch binding.worktree_path must be a non-empty canonical absolute path.";

const worktreeCases: ReadonlyArray<{
  readonly label: string;
  readonly path: string;
  readonly rejected: boolean;
}> = [
  { label: "root", path: "/", rejected: false },
  { label: "posix-backslash", path: "/repo\\worktree", rejected: true },
  { label: "unc", path: "\\\\server\\share\\worktree", rejected: false },
  { label: "bare-name", path: "worktree", rejected: true },
];

describe("epic launch-binding edge cases", () => {
  it("requires a deployment agent on the planner model receipt", () => {
    const features = [{ model_routing_receipt: {} }];

    const errors = validateEpicPlannerChildLaunchBindings(features);

    expect(errors).toContain(DEPLOYMENT_AGENT_ERROR);
  });

  it.each(worktreeCases)(
    "classifies a $label worktree_path",
    ({ path, rejected }) => {
      const features = [{ worktree_path: path }];

      const errors = validateEpicPlannerChildLaunchBindings(features);

      expect(errors.includes(WORKTREE_PATH_ERROR)).toBe(rejected);
    },
  );

  it("skips child launch bindings when features is not a list", () => {
    const state = { features: "not-a-list" };

    const errors = validateEpicChildLaunchBindings(state, {
      requireComplete: true,
    });

    expect(errors).toEqual([]);
  });
});
