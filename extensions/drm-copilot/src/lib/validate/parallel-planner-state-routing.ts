/**
 * Parallel-planner ready-gate invariant P10, structural subset (issue #532).
 *
 * Purpose:
 *     Port the resolver-free part of
 *     `scripts/dev_tools/_parallel_planner_state_routing.py`'s
 *     `validate_ready_item_routing`: validate one object-shaped `items[]`
 *     entry's `complexity_band`, `complexity_assessment`, and
 *     `model_routing_receipt` under the readiness gate.
 *
 * Divergence from the Python validator (deliberate):
 *     This port does not check `floor == compute_complexity_floor(signals_present)`,
 *     `model == resolve_delegation_model(...)`, or the disabled-mode clamp,
 *     because the floor and model formulas have no TypeScript implementation.
 *     The Python validator is authoritative for those three checks. Every check
 *     this port does perform emits a string byte-identical to the Python one.
 *
 * Invariants / Constraints:
 *     - Checks run in spec FR2 table order. Checks 3 through 5 are skipped when
 *       check 2 fails, and checks 7 through 10 when check 6 fails. Checks 5 and
 *       9 are reported whenever the two bands differ, including when check 1
 *       already rejected the item band.
 *     - Imports only `./parallel-state-shared` and defines its own band order,
 *       so no import cycle with the planner core validator that calls it exists.
 *
 * Side Effects:
 *     None; the function never mutates its input and never throws.
 */

import {
  enumError,
  isEnumMember,
  isNonEmptyString,
  isObject,
  pythonRepr,
  pythonStr,
} from "./parallel-state-shared";

/** Complexity bands in ascending order, mirroring Python `BAND_ORDER`. */
const BAND_ORDER: readonly string[] = ["C1", "C2", "C3", "C4"];

/** Session fable policies accepted on a receipt, in canonical order. */
const VALID_FABLE_POLICIES: readonly string[] = [
  "disabled",
  "available",
  "preferred",
];

/** The only agent a planner item's receipt may name (check 8). */
const ROUTING_AGENT = "orchestrator";

/**
 * Compare two deserialized values the way Python `==` compares JSON values.
 *
 * @param left First value; `undefined` (an absent key) equals `null`.
 * @param right Second value.
 * @returns True when both values serialize to the same JSON text.
 */
function sameValue(left: unknown, right: unknown): boolean {
  return JSON.stringify(left ?? null) === JSON.stringify(right ?? null);
}

/**
 * Report whether a value is a list whose every entry is a string (Python
 * `_string_list`; empty strings are accepted).
 *
 * @param value Any deserialized JSON value.
 * @returns True for an array of strings.
 */
function isListOfStrings(value: unknown): boolean {
  return (
    Array.isArray(value) &&
    value.every((entry: unknown) => typeof entry === "string")
  );
}

/**
 * Run the check-3 structural subset on an assessment object.
 *
 * @param assessment The item's assessment object.
 * @param context The `<entry> complexity_assessment` prefix.
 * @returns Band-enum, `signals_present`, ordering, and rationale errors, in the
 * Python helper's order.
 */
function validateAssessmentEntry(
  assessment: Record<string, unknown>,
  context: string,
): string[] {
  const errors: string[] = [];
  const band = assessment["band"];
  const floor = assessment["floor"];
  if (!isEnumMember(BAND_ORDER, band)) {
    errors.push(
      `${context} band must be one of C1, C2, C3, C4; got: ${pythonStr(band)}.`,
    );
  }
  if (!isListOfStrings(assessment["signals_present"])) {
    errors.push(`${context} signals_present must be a list of strings.`);
  }
  // Both values must be valid bands to compare, so a prior enum error
  // suppresses a spurious ordering error.
  if (
    isEnumMember(BAND_ORDER, band) &&
    isEnumMember(BAND_ORDER, floor) &&
    BAND_ORDER.indexOf(String(band)) < BAND_ORDER.indexOf(String(floor))
  ) {
    errors.push(
      `${context} band ${pythonStr(band)} is below its floor ${pythonStr(floor)}.`,
    );
  }
  if (!isNonEmptyString(assessment["rationale"])) {
    errors.push(`${context} rationale must be a non-empty string.`);
  }
  return errors;
}

/**
 * Run checks 3 through 5 on an object-shaped `complexity_assessment`.
 *
 * @param assessment The item's assessment object.
 * @param band The item's `complexity_band` value, possibly invalid.
 * @param entryContext Item-scoped context prefix.
 * @returns Check-3 subset errors, the check-4 error, then the check-5 error.
 */
function validateAssessment(
  assessment: Record<string, unknown>,
  band: unknown,
  entryContext: string,
): string[] {
  const context = `${entryContext} complexity_assessment`;
  const errors = validateAssessmentEntry(assessment, context);
  if (!isNonEmptyString(assessment["assessed_at"])) {
    errors.push(`${context}.assessed_at must be a non-empty string.`);
  }
  const assessedBand = assessment["band"];
  if (!sameValue(assessedBand, band)) {
    errors.push(
      `${context}.band ${pythonRepr(assessedBand)} does not equal complexity_band ${pythonRepr(band)}.`,
    );
  }
  return errors;
}

/**
 * Run checks 7 (band enum only) through 10 on an object-shaped receipt.
 *
 * @param receipt The item's receipt object.
 * @param band The item's `complexity_band` value, possibly invalid.
 * @param entryContext Item-scoped context prefix.
 * @returns The receipt band-enum error, then the agent, band-mismatch, and
 * `fable_policy` errors.
 */
function validateReceipt(
  receipt: Record<string, unknown>,
  band: unknown,
  entryContext: string,
): string[] {
  const context = `${entryContext} model_routing_receipt`;
  const errors: string[] = [];
  const receiptBand = receipt["complexity_band"];
  if (!isEnumMember(BAND_ORDER, receiptBand)) {
    errors.push(
      `${context} complexity_band must be one of C1, C2, C3, C4; got: ${pythonStr(receiptBand)}.`,
    );
  }
  const agent = receipt["agent"];
  if (agent !== ROUTING_AGENT) {
    errors.push(
      `${context}.agent must be ${pythonRepr(ROUTING_AGENT)}; found: ${pythonRepr(agent)}.`,
    );
  }
  if (!sameValue(receiptBand, band)) {
    errors.push(
      `${context}.complexity_band ${pythonRepr(receiptBand)} does not equal complexity_band ${pythonRepr(band)}.`,
    );
  }
  const fablePolicy = receipt["fable_policy"];
  if (!isEnumMember(VALID_FABLE_POLICIES, fablePolicy)) {
    errors.push(
      enumError(
        entryContext,
        "model_routing_receipt.fable_policy",
        VALID_FABLE_POLICIES,
        fablePolicy,
      ),
    );
  }
  return errors;
}

/**
 * Validate one planner item's routing record (ready-gate invariant P10,
 * structural subset).
 *
 * @param record One object-shaped `items[]` entry.
 * @param entryContext Item-scoped context prefix, for example
 * `Parallel planner checkpoint items[0]`.
 * @returns Errors in spec FR2 table order; an empty array when the routing
 * record satisfies every check this port performs.
 */
export function validateReadyItemRouting(
  record: Record<string, unknown>,
  entryContext: string,
): string[] {
  const errors: string[] = [];
  const band = record["complexity_band"];
  if (!isEnumMember(BAND_ORDER, band)) {
    errors.push(enumError(entryContext, "complexity_band", BAND_ORDER, band));
  }

  const assessment = record["complexity_assessment"];
  if (isObject(assessment)) {
    errors.push(...validateAssessment(assessment, band, entryContext));
  } else {
    errors.push(`${entryContext} complexity_assessment must be an object.`);
  }

  const receipt = record["model_routing_receipt"];
  if (isObject(receipt)) {
    errors.push(...validateReceipt(receipt, band, entryContext));
  } else {
    errors.push(`${entryContext} model_routing_receipt must be an object.`);
  }
  return errors;
}
