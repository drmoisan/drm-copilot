/**
 * Tests for parallel-planner ready-gate invariant P10, the routing record.
 *
 * Under `requireReadyForExecution` every planner item must carry a valid
 * `complexity_band`, a `complexity_assessment`, and a `model_routing_receipt`
 * (issue #532). Every expected string is the byte-identical literal emitted by
 * `scripts/dev_tools/validate_parallel_planner_state.py`.
 */

import { validateParallelPlannerStateText } from "../../../src/lib/validate/parallel-planner-state-core";
import {
  buildValidPlannerState,
  itemAt,
  type JsonRecord,
} from "./parallel-state-test-support";

const BAND_ABSENT =
  "Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: None.";
const ASSESSMENT_NOT_OBJECT =
  "Parallel planner checkpoint items[0] complexity_assessment must be an object.";
const RECEIPT_NOT_OBJECT =
  "Parallel planner checkpoint items[0] model_routing_receipt must be an object.";

/** Serialize a checkpoint object and validate it with the ready gate on. */
function validateReady(state: JsonRecord): string[] {
  return validateParallelPlannerStateText(JSON.stringify(state), {
    requireReadyForExecution: true,
  });
}

describe("parallel planner ready gate P10 routing record", () => {
  it("rejects an item without band, assessment, or receipt under the ready gate (fail-before)", () => {
    const state = buildValidPlannerState();
    const item = itemAt(state, 0);
    delete item["complexity_band"];
    delete item["complexity_assessment"];
    delete item["model_routing_receipt"];

    const errors = validateReady(state);

    expect(errors).toEqual(
      expect.arrayContaining([
        BAND_ABSENT,
        ASSESSMENT_NOT_OBJECT,
        RECEIPT_NOT_OBJECT,
      ]),
    );
  });
});
