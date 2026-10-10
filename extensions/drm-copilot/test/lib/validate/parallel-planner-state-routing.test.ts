/**
 * Tests for parallel-planner ready-gate invariant P10, the routing record.
 *
 * Under `requireReadyForExecution` every planner item must carry a valid
 * `complexity_band`, a `complexity_assessment`, and a `model_routing_receipt`
 * (issue #532). Every expected string is the byte-identical literal emitted by
 * `scripts/dev_tools/validate_parallel_planner_state.py`; the shared-literal
 * table matches the Python `test_ready_gate_emits_shared_literal_strings`.
 * The divergence pins record the checks only the Python validator performs.
 */

import { validateParallelPlannerStateText } from "../../../src/lib/validate/parallel-planner-state-core";
import { validateReadyItemRouting } from "../../../src/lib/validate/parallel-planner-state-routing";
import {
  buildPlannerRoutingFields,
  buildValidPlannerState,
  itemAt,
  type JsonRecord,
} from "./parallel-state-test-support";

const CTX = "Parallel planner checkpoint items[0]";
const BAND_ABSENT =
  "Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: None.";
const BAND_C9 =
  "Parallel planner checkpoint items[0] complexity_band must be one of C1, C2, C3, C4; found: 'C9'.";
const ASSESSMENT_NOT_OBJECT =
  "Parallel planner checkpoint items[0] complexity_assessment must be an object.";
const RECEIPT_NOT_OBJECT =
  "Parallel planner checkpoint items[0] model_routing_receipt must be an object.";
const ASSESSMENT_BAND_ENUM =
  "Parallel planner checkpoint items[0] complexity_assessment band must be one of C1, C2, C3, C4; got: C9.";
const SIGNALS_NOT_LIST =
  "Parallel planner checkpoint items[0] complexity_assessment signals_present must be a list of strings.";
const BAND_BELOW_FLOOR =
  "Parallel planner checkpoint items[0] complexity_assessment band C2 is below its floor C3.";
const RATIONALE_EMPTY =
  "Parallel planner checkpoint items[0] complexity_assessment rationale must be a non-empty string.";
const ASSESSED_AT_EMPTY =
  "Parallel planner checkpoint items[0] complexity_assessment.assessed_at must be a non-empty string.";
const ASSESSMENT_BAND_MISMATCH =
  "Parallel planner checkpoint items[0] complexity_assessment.band 'C2' does not equal complexity_band 'C3'.";
const RECEIPT_BAND_ENUM =
  "Parallel planner checkpoint items[0] model_routing_receipt complexity_band must be one of C1, C2, C3, C4; got: C9.";
const AGENT_NOT_ORCHESTRATOR =
  "Parallel planner checkpoint items[0] model_routing_receipt.agent must be 'orchestrator'; found: 'atomic-planner'.";
const RECEIPT_BAND_MISMATCH =
  "Parallel planner checkpoint items[0] model_routing_receipt.complexity_band 'C2' does not equal complexity_band 'C3'.";
const UNKNOWN_FABLE_POLICY =
  "Parallel planner checkpoint items[0] model_routing_receipt.fable_policy must be one of disabled, available, preferred; found: 'sometimes'.";
const ASSESSMENT_BAND_VS_ABSENT =
  "Parallel planner checkpoint items[0] complexity_assessment.band 'C3' does not equal complexity_band None.";
const RECEIPT_BAND_VS_ABSENT =
  "Parallel planner checkpoint items[0] model_routing_receipt.complexity_band 'C3' does not equal complexity_band None.";
const RECEIPT_BAND_ABSENT_ENUM =
  "Parallel planner checkpoint items[0] model_routing_receipt complexity_band must be one of C1, C2, C3, C4; got: None.";
const RECEIPT_BAND_ABSENT_VS_ITEM =
  "Parallel planner checkpoint items[0] model_routing_receipt.complexity_band None does not equal complexity_band 'C3'.";
const ASSESSMENT_BAND_LIST = ASSESSMENT_BAND_ENUM.replace("C9.", "['C3'].");
const RECEIPT_BAND_LIST = RECEIPT_BAND_ENUM.replace("C9.", "['C3'].");
const ROUTING_FIELDS = [
  "complexity_band",
  "complexity_assessment",
  "model_routing_receipt",
];

/** Serialize a checkpoint object and validate it with the gate on or off. */
function validate(state: JsonRecord, ready = true): string[] {
  return validateParallelPlannerStateText(JSON.stringify(state), {
    requireReadyForExecution: ready,
  });
}

/**
 * Return an item's nested assessment or receipt object for in-place mutation.
 *
 * @param record An item record or a routing-fields record.
 * @param key `complexity_assessment` or `model_routing_receipt`.
 * @returns The nested object.
 * @throws Error when the fixture does not hold an object under that key.
 */
function nested(record: JsonRecord, key: string): JsonRecord {
  const value: unknown = record[key];
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error(`fixture ${key} is not an object`);
  }
  return value as JsonRecord;
}

/** Return the item-0 errors that mention the assessment or the receipt. */
function routingErrors(errors: string[]): string[] {
  return errors.filter(
    (error) =>
      error.startsWith(CTX) &&
      (error.includes("complexity_assessment") ||
        error.includes("model_routing_receipt")),
  );
}

describe("parallel planner ready gate P10 routing record", () => {
  it("rejects an item without band, assessment, or receipt under the ready gate (fail-before)", () => {
    const state = buildValidPlannerState();
    const item = itemAt(state, 0);
    delete item["complexity_band"];
    delete item["complexity_assessment"];
    delete item["model_routing_receipt"];

    const errors = validate(state);

    expect(errors).toEqual(
      expect.arrayContaining([
        BAND_ABSENT,
        ASSESSMENT_NOT_OBJECT,
        RECEIPT_NOT_OBJECT,
      ]),
    );
  });

  it("accepts an item with a valid routing record under the ready gate", () => {
    const state = buildValidPlannerState();

    const errors = validate(state);

    expect(errors).toEqual([]);
  });

  it("accepts items without the routing fields with the gate off", () => {
    const state = buildValidPlannerState();
    for (const index of [0, 1]) {
      const item = itemAt(state, index);
      for (const key of ROUTING_FIELDS) {
        delete item[key];
      }
    }

    const errors = validate(state, false);

    expect(errors).toEqual([]);
  });

  it("reports both band mismatches and check 1 twice when the item band is C9", () => {
    const state = buildValidPlannerState();
    itemAt(state, 0)["complexity_band"] = "C9";

    const errors = validate(state);

    expect(errors).toEqual(
      expect.arrayContaining([
        `${CTX} complexity_assessment.band 'C3' does not equal complexity_band 'C9'.`,
        `${CTX} model_routing_receipt.complexity_band 'C3' does not equal complexity_band 'C9'.`,
      ]),
    );
    expect(errors.filter((error) => error === BAND_C9)).toHaveLength(2);
  });

  it("reports only checks 2 and 6 for string-valued assessment and receipt", () => {
    const state = buildValidPlannerState();
    const item = itemAt(state, 0);
    item["complexity_assessment"] = "C3";
    item["model_routing_receipt"] = "opus";

    const errors = validate(state);

    expect(routingErrors(errors)).toEqual([
      ASSESSMENT_NOT_OBJECT,
      RECEIPT_NOT_OBJECT,
    ]);
  });

  it("reports every P7 error for an item before its P10 errors", () => {
    const state = buildValidPlannerState();
    const item = itemAt(state, 0);
    item["preparation_status"] = "pending";
    item["preflight_status"] = "PREFLIGHT: REVISIONS REQUIRED";
    for (const key of ROUTING_FIELDS) {
      delete item[key];
    }

    const errors = validate(state);

    const p7Positions = errors
      .map((error, index) => ({ error, index }))
      .filter(
        ({ error }) =>
          error.startsWith(`${CTX} preparation_status`) ||
          error.startsWith(`${CTX} preflight_status`),
      )
      .map(({ index }) => index);
    const p10Positions = [
      BAND_ABSENT,
      ASSESSMENT_NOT_OBJECT,
      RECEIPT_NOT_OBJECT,
    ].map((literal) => errors.indexOf(literal));
    expect(p7Positions).toHaveLength(2);
    expect(Math.min(...p10Positions)).toBeGreaterThan(Math.max(...p7Positions));
  });

  it.each<[string, string, unknown, string]>([
    ["complexity_assessment", "band", "C9", ASSESSMENT_BAND_ENUM],
    ["complexity_assessment", "signals_present", "x", SIGNALS_NOT_LIST],
    ["complexity_assessment", "band", "C2", BAND_BELOW_FLOOR],
    ["complexity_assessment", "rationale", "   ", RATIONALE_EMPTY],
    ["complexity_assessment", "assessed_at", "", ASSESSED_AT_EMPTY],
    ["complexity_assessment", "band", "C2", ASSESSMENT_BAND_MISMATCH],
    [
      "model_routing_receipt",
      "agent",
      "atomic-planner",
      AGENT_NOT_ORCHESTRATOR,
    ],
    ["model_routing_receipt", "complexity_band", "C2", RECEIPT_BAND_MISMATCH],
    [
      "model_routing_receipt",
      "fable_policy",
      "sometimes",
      UNKNOWN_FABLE_POLICY,
    ],
    ["model_routing_receipt", "complexity_band", "C9", RECEIPT_BAND_ENUM],
    ["complexity_assessment", "band", ["C3"], ASSESSMENT_BAND_LIST],
    ["model_routing_receipt", "complexity_band", ["C3"], RECEIPT_BAND_LIST],
  ])(
    "emits the shared literal when %s.%s is %p",
    (target, key, value, expected) => {
      const record = buildPlannerRoutingFields();
      nested(record, target)[key] = value;

      const errors = validateReadyItemRouting(record, CTX);

      expect(errors).toContain(expected);
    },
  );

  it("returns no errors when called directly on a valid routing record", () => {
    const record = buildPlannerRoutingFields();

    const errors = validateReadyItemRouting(record, CTX);

    expect(errors).toEqual([]);
  });

  it("reports checks 1, 5, and 9 with None when only the item band is absent", () => {
    const record = buildPlannerRoutingFields();
    delete record["complexity_band"];

    const errors = validateReadyItemRouting(record, CTX);

    expect(errors).toEqual([
      BAND_ABSENT,
      ASSESSMENT_BAND_VS_ABSENT,
      RECEIPT_BAND_VS_ABSENT,
    ]);
  });

  it("reports checks 7 and 9 with None when only the receipt band is absent", () => {
    const record = buildPlannerRoutingFields();
    delete nested(record, "model_routing_receipt")["complexity_band"];

    const errors = validateReadyItemRouting(record, CTX);

    expect(errors).toEqual(
      expect.arrayContaining([
        RECEIPT_BAND_ABSENT_ENUM,
        RECEIPT_BAND_ABSENT_VS_ITEM,
      ]),
    );
  });

  it.each<[string, (item: JsonRecord) => void]>([
    [
      "floor C1 disagreeing with signals concurrency_or_ordering",
      (item) => {
        const assessment = nested(item, "complexity_assessment");
        assessment["signals_present"] = ["concurrency_or_ordering"];
        assessment["floor"] = "C1";
      },
    ],
    [
      "receipt model opus disagreeing with the resolver for C2",
      (item) => {
        item["complexity_band"] = "C2";
        Object.assign(nested(item, "complexity_assessment"), {
          band: "C2",
          floor: "C1",
          signals_present: [],
        });
        Object.assign(nested(item, "model_routing_receipt"), {
          agent: "orchestrator",
          complexity_band: "C2",
          fable_policy: "available",
          model: "opus",
        });
      },
    ],
    [
      "receipt model fable under the disabled policy for C4",
      (item) => {
        item["complexity_band"] = "C4";
        nested(item, "complexity_assessment")["band"] = "C4";
        Object.assign(nested(item, "model_routing_receipt"), {
          complexity_band: "C4",
          fable_policy: "disabled",
          model: "fable",
        });
      },
    ],
  ])("pins the documented divergence: %s yields no error", (_name, mutate) => {
    const state = buildValidPlannerState();
    mutate(itemAt(state, 0));

    const errors = validate(state);

    expect(errors).toEqual([]);
  });
});
