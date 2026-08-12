/**
 * Retrospective mutation-protocol validation for parallel checkpoints.
 *
 * This module composes the seven-field record shape already owned by
 * `parallel-state-records.ts` with the Python mutation authority's field-set,
 * generation-accounting, operation-order, pinning, and mode rules. It is pure:
 * validation reads the parsed checkpoint and returns ordered error strings.
 */

import {
  MERGED_MERGE_STATUSES,
  VALID_MODES,
  isEnumMember,
  isNonNegativeInteger,
  isObject,
  itemContext,
  pythonRepr,
} from "./parallel-state-shared";
import {
  OPS_REQUIRING_ITEM_KEY,
  OPS_REQUIRING_NULL_NEW_STATE,
  OPS_REQUIRING_NULL_PRIOR_STATE,
} from "./parallel-state-structures";
import { validateMutationReceiptBindings } from "./parallel-orchestrator-state-mutation-receipts";

/** The complete mutation entry field set, in canonical serialization order. */
const MUTATION_ENTRY_FIELDS: readonly string[] = [
  "op",
  "item_key",
  "at",
  "prior_state",
  "new_state",
  "disposition",
  "recolor_generation",
];

/** States whose removal changes the unstarted graph and increments generation. */
const UNSTARTED_ITEM_STATES: readonly string[] = [
  "proposed",
  "admitted",
  "prepared",
  "scheduled",
];

/** Return the stable entry-scoped validation prefix. */
function entryContext(context: string, position: number): string {
  return `${context} mutations[${position}]`;
}

/** Return the mutation list when its shape is readable by this additive gate. */
function mutationEntries(state: Record<string, unknown>): unknown[] | null {
  const value = state["mutations"];
  return Array.isArray(value) ? value : null;
}

/** Require every canonical field and reject an unapproved eighth field. */
function validateEntryFieldSet(
  entry: Record<string, unknown>,
  context: string,
): string[] {
  const errors: string[] = [];
  for (const field of MUTATION_ENTRY_FIELDS) {
    if (!(field in entry)) {
      errors.push(`${context} is missing required field: ${field}.`);
    }
  }
  for (const field of Object.keys(entry)) {
    if (!MUTATION_ENTRY_FIELDS.includes(field)) {
      errors.push(
        `${context} carries unexpected field: ${field}; the mutations[] entry shape is exactly ${MUTATION_ENTRY_FIELDS.join(", ")}.`,
      );
    }
  }
  return errors;
}

/** Require a non-null state wherever the operation's null rule does not apply. */
function validateEntryCompleteness(
  entry: Record<string, unknown>,
  context: string,
): string[] {
  const op = entry["op"];
  if (!isEnumMember(OPS_REQUIRING_ITEM_KEY, op)) {
    return [];
  }
  const operation = op as string;
  const requirements: readonly (readonly [string, readonly string[]])[] = [
    ["prior_state", OPS_REQUIRING_NULL_PRIOR_STATE],
    ["new_state", OPS_REQUIRING_NULL_NEW_STATE],
  ];
  const errors: string[] = [];
  for (const [field, nullOps] of requirements) {
    if (
      !nullOps.includes(operation) &&
      field in entry &&
      entry[field] === null
    ) {
      errors.push(
        `${context} ${field} must not be null for op ${pythonRepr(op)}.`,
      );
    }
  }
  return errors;
}

/** Apply the complete seven-field contract to every object-shaped entry. */
function validateEntryShapes(
  entries: readonly unknown[],
  context: string,
): string[] {
  const errors: string[] = [];
  entries.forEach((entry, position) => {
    if (!isObject(entry)) {
      return;
    }
    const scoped = entryContext(context, position);
    errors.push(...validateEntryFieldSet(entry, scoped));
    errors.push(...validateEntryCompleteness(entry, scoped));
  });
  return errors;
}

/** Preserve Python's non-decreasing append-order generation invariant. */
function validateGenerationMonotonicity(
  entries: readonly unknown[],
  context: string,
): string[] {
  const errors: string[] = [];
  let highest: number | null = null;
  entries.forEach((entry, position) => {
    if (!isObject(entry)) {
      return;
    }
    const generation = entry["recolor_generation"];
    if (!isNonNegativeInteger(generation) || typeof generation !== "number") {
      return;
    }
    if (highest !== null && generation < highest) {
      errors.push(
        `${entryContext(context, position)} recolor_generation ${generation} is below the preceding maximum ${highest}; the mutation log must be monotonically non-decreasing.`,
      );
      return;
    }
    highest = generation;
  });
  return errors;
}

/** Determine whether one operation necessarily recomputes the unstarted graph. */
function requiresRecompute(entry: Record<string, unknown>): boolean {
  if (entry["op"] === "requeue") {
    return (
      entry["prior_state"] === "in_flight" && entry["new_state"] === "blocked"
    );
  }
  return (
    entry["op"] === "remove" &&
    isEnumMember(UNSTARTED_ITEM_STATES, entry["prior_state"])
  );
}

/**
 * Validate exact generation accounting from the run's initial generation zero.
 * Recompute operations consume the next generation; non-recompute operations
 * retain the current generation. An add may either retain or increment because
 * its record does not carry the conflict decision that distinguishes the rows.
 */
function validateGenerationAccounting(
  entries: readonly unknown[],
  context: string,
): string[] {
  const errors: string[] = [];
  let currentGeneration = 0;
  entries.forEach((entry, position) => {
    if (!isObject(entry)) {
      return;
    }
    const generation = entry["recolor_generation"];
    if (!isNonNegativeInteger(generation) || typeof generation !== "number") {
      return;
    }
    const scoped = entryContext(context, position);
    const op = entry["op"];

    if (generation < currentGeneration) {
      return;
    }
    if (op === "add") {
      if (generation > currentGeneration + 1) {
        errors.push(
          `${scoped} recolor_generation ${generation} must be ${currentGeneration} or ${currentGeneration + 1} for op 'add'.`,
        );
      }
      currentGeneration = generation;
      return;
    }

    const expected = requiresRecompute(entry)
      ? currentGeneration + 1
      : currentGeneration;
    if (generation !== expected) {
      if (op === "remove" && entry["prior_state"] === "in_flight") {
        errors.push(
          `${scoped} in-flight remove must preserve recolor_generation ${currentGeneration}; found: ${generation}.`,
        );
      } else if (requiresRecompute(entry)) {
        errors.push(
          `${scoped} recolor_generation ${generation} must equal the expected recompute generation ${expected}.`,
        );
      } else {
        errors.push(
          `${scoped} recolor_generation ${generation} must preserve generation ${expected} for op ${pythonRepr(op)}.`,
        );
      }
    }
    currentGeneration = Math.max(currentGeneration, generation);
  });
  return errors;
}

/** Validate state transitions that the base seven-field shape cannot express. */
function validateOperationOrdering(
  entries: readonly unknown[],
  state: Record<string, unknown>,
  context: string,
): string[] {
  const errors: string[] = [];
  const addedKeys = new Set<number>();
  const inFlightKeys = Array.isArray(state["items"])
    ? state["items"]
        .filter(isObject)
        .filter((item) => item["state"] === "in_flight")
        .map((item) => item["issue_num"])
        .filter(
          (key): key is number =>
            typeof key === "number" && Number.isInteger(key),
        )
        .sort((left, right) => left - right)
    : [];

  entries.forEach((entry, position) => {
    if (!isObject(entry)) {
      return;
    }
    const scoped = entryContext(context, position);
    const op = entry["op"];
    const itemKey = entry["item_key"];

    if (op === "add" && typeof itemKey === "number") {
      if (addedKeys.has(itemKey)) {
        errors.push(`${scoped} records a duplicate add for item ${itemKey}.`);
      }
      addedKeys.add(itemKey);
    }
    if (op === "remove") {
      if (entry["prior_state"] === "merged") {
        errors.push(
          `${scoped} cannot remove item ${String(itemKey)} from prior_state 'merged'.`,
        );
      }
      if (
        entry["new_state"] !== null &&
        entry["new_state"] !== undefined &&
        entry["new_state"] !== "withdrawn"
      ) {
        errors.push(
          `${scoped} new_state must be 'withdrawn' for op 'remove'; found: ${pythonRepr(entry["new_state"])}.`,
        );
      }
    }
    if (op === "close" && inFlightKeys.length > 0) {
      errors.push(
        `${scoped} close requires no item in flight; still in flight: ${pythonRepr(inFlightKeys)}.`,
      );
    }
  });
  return errors;
}

/** Return every run-close entry position in append order. */
function closePositions(entries: readonly unknown[]): number[] {
  const positions: number[] = [];
  entries.forEach((entry, position) => {
    if (isObject(entry) && entry["op"] === "close") {
      positions.push(position);
    }
  });
  return positions;
}

/** Report whether a current-generation cohort still contains schedulable work. */
function hasSchedulableWork(state: Record<string, unknown>): boolean {
  const cohorts = state["cohorts"];
  if (!Array.isArray(cohorts)) {
    return true;
  }
  const generation = state["recolor_generation"];
  return cohorts.some(
    (cohort) =>
      isObject(cohort) &&
      cohort["generation"] === generation &&
      Array.isArray(cohort["item_keys"]) &&
      cohort["item_keys"].length > 0,
  );
}

/** Apply open termination and closed two-signal completion semantics. */
function validateModeCompletion(
  state: Record<string, unknown>,
  entries: readonly unknown[],
  context: string,
): string[] {
  const mode = state["mode"];
  const items = state["items"];
  if (!isEnumMember(VALID_MODES, mode) || !Array.isArray(items)) {
    return [];
  }
  const closes = closePositions(entries);
  if (closes.length === 0) {
    return [];
  }

  if (mode === "open") {
    const firstClose = closes[0]!;
    const errors: string[] = [];
    entries.forEach((entry, position) => {
      if (position <= firstClose || !isObject(entry)) {
        return;
      }
      errors.push(
        `${entryContext(context, position)} records op ${pythonRepr(entry["op"])} after the run-close entry at mutations[${firstClose}]; an open-mode run terminates at the close record and must not auto-complete.`,
      );
    });
    return errors;
  }

  if (hasSchedulableWork(state)) {
    return [];
  }
  const errors: string[] = [];
  items.forEach((item, index) => {
    if (!isObject(item) || item["state"] === "withdrawn") {
      return;
    }
    const mergeStatus = item["merge_status"] ?? "not_started";
    if (!isEnumMember(MERGED_MERGE_STATUSES, mergeStatus)) {
      errors.push(
        `${itemContext(context, index)} completion invariant failed: closed mode records a mutations[] op 'close' entry but merge_status is not merged or worktree_removed; found: ${pythonRepr(mergeStatus)}.`,
      );
    }
  });
  return errors;
}

/** Validate all mutation-protocol invariants reachable from checkpoint state. */
export function validateMutationProtocol(
  state: Record<string, unknown>,
  context: string,
): string[] {
  const entries = mutationEntries(state);
  if (entries === null) {
    return [];
  }
  return [
    ...validateEntryShapes(entries, context),
    ...validateGenerationMonotonicity(entries, context),
    ...validateGenerationAccounting(entries, context),
    ...validateOperationOrdering(entries, state, context),
    ...validateModeCompletion(state, entries, context),
    ...validateMutationReceiptBindings(state, context),
  ];
}
