/** Pure Python-equivalent semantic-drift validation for parallel checkpoints. */

import {
  isNonNegativeInteger,
  isObject,
  pythonRepr,
} from "./parallel-state-shared";

const UNSTARTED_STATES = new Set([
  "proposed",
  "admitted",
  "prepared",
  "scheduled",
]);

const CANONICAL_TIMESTAMP = /^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$/u;

interface DriftEvent {
  readonly position: number;
  readonly itemKey: number;
  readonly observed: readonly string[];
  readonly escapedPaths: readonly string[];
  readonly at: string;
  readonly action: string;
}

interface ItemView {
  readonly key: number;
  readonly state: string;
  readonly mergeStatus: string;
  readonly radius: Record<string, unknown> | null;
}

interface MutationView {
  readonly position: number;
  readonly op: string;
  readonly itemKey: number | null;
  readonly at: string;
  readonly generation: number;
  readonly priorState: unknown;
  readonly newState: unknown;
}

function stringList(value: unknown): string[] | null {
  if (
    !Array.isArray(value) ||
    value.some((entry) => typeof entry !== "string")
  ) {
    return null;
  }
  return [...new Set(value as string[])].sort();
}

function normalizePath(value: string): string {
  return value.replaceAll("\\", "/").replace(/^\.\//u, "");
}

function globExpression(pattern: string): RegExp {
  const normalized = normalizePath(pattern);
  let source = "";
  for (let index = 0; index < normalized.length; index += 1) {
    const character = normalized[index] ?? "";
    const next = normalized[index + 1];
    if (character === "*" && next === "*") {
      source += ".*";
      index += 1;
    } else if (character === "*") {
      source += "[^/]*";
    } else if (character === "?") {
      source += "[^/]";
    } else {
      source += character.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
    }
  }
  return new RegExp(`^${source}$`, "u");
}

function pathIsCovered(path: string, declared: readonly string[]): boolean {
  const normalizedPath = normalizePath(path);
  return declared.some((rawPattern) => {
    const pattern = normalizePath(rawPattern).replace(/\/$/u, "");
    if (pattern === normalizedPath) {
      return true;
    }
    if (!pattern.includes("*") && !pattern.includes("?")) {
      return normalizedPath.startsWith(`${pattern}/`);
    }
    return globExpression(pattern).test(normalizedPath);
  });
}

function driftEvents(state: Record<string, unknown>): DriftEvent[] {
  const rawEvents = state["drift_events"];
  if (!Array.isArray(rawEvents)) {
    return [];
  }
  const events: DriftEvent[] = [];
  rawEvents.forEach((entry, position) => {
    if (!isObject(entry)) {
      return;
    }
    const itemKey = entry["item_key"];
    const observed = stringList(entry["observed"]);
    const escapedPaths = stringList(entry["escaped_paths"]);
    const at = entry["at"];
    const action = entry["action"];
    if (
      typeof itemKey === "number" &&
      Number.isInteger(itemKey) &&
      observed !== null &&
      escapedPaths !== null &&
      typeof at === "string" &&
      typeof action === "string"
    ) {
      events.push({ position, itemKey, observed, escapedPaths, at, action });
    }
  });
  return events;
}

function itemViews(state: Record<string, unknown>): ItemView[] {
  const rawItems = state["items"];
  if (!Array.isArray(rawItems)) {
    return [];
  }
  const items: ItemView[] = [];
  for (const entry of rawItems) {
    if (
      !isObject(entry) ||
      typeof entry["issue_num"] !== "number" ||
      !Number.isInteger(entry["issue_num"]) ||
      typeof entry["state"] !== "string" ||
      typeof entry["merge_status"] !== "string"
    ) {
      continue;
    }
    items.push({
      key: entry["issue_num"],
      state: entry["state"],
      mergeStatus: entry["merge_status"],
      radius: isObject(entry["blast_radius"]) ? entry["blast_radius"] : null,
    });
  }
  return items.sort((left, right) => left.key - right.key);
}

function mutationViews(state: Record<string, unknown>): MutationView[] {
  const rawMutations = state["mutations"];
  if (!Array.isArray(rawMutations)) {
    return [];
  }
  const mutations: MutationView[] = [];
  rawMutations.forEach((entry, position) => {
    if (
      !isObject(entry) ||
      typeof entry["op"] !== "string" ||
      typeof entry["at"] !== "string" ||
      !isNonNegativeInteger(entry["recolor_generation"]) ||
      typeof entry["recolor_generation"] !== "number"
    ) {
      return;
    }
    const itemKey = entry["item_key"];
    if (
      itemKey !== null &&
      (typeof itemKey !== "number" || !Number.isInteger(itemKey))
    ) {
      return;
    }
    mutations.push({
      position,
      op: entry["op"],
      itemKey,
      at: entry["at"],
      generation: entry["recolor_generation"],
      priorState: entry["prior_state"],
      newState: entry["new_state"],
    });
  });
  return mutations;
}

function latestEvents(events: readonly DriftEvent[]): DriftEvent[] {
  const latest = new Map<number, DriftEvent>();
  for (const event of events) {
    const current = latest.get(event.itemKey);
    if (
      current === undefined ||
      event.at > current.at ||
      (event.at === current.at && event.position > current.position)
    ) {
      latest.set(event.itemKey, event);
    }
  }
  return [...latest.values()].sort(
    (left, right) => left.itemKey - right.itemKey,
  );
}

function eventIsResolved(
  event: DriftEvent,
  item: ItemView | undefined,
): boolean {
  const radius = item?.radius;
  if (radius === null || radius === undefined) {
    return false;
  }
  const paths = stringList(radius["paths"]);
  if (
    paths !== null &&
    event.escapedPaths.every((path) => pathIsCovered(path, paths))
  ) {
    return true;
  }
  const computedAt = radius["computed_at"];
  return (
    radius["source"] === "observed" &&
    typeof computedAt === "string" &&
    CANONICAL_TIMESTAMP.test(computedAt) &&
    CANONICAL_TIMESTAMP.test(event.at) &&
    computedAt > event.at
  );
}

function observedConflictPeers(
  event: DriftEvent,
  items: readonly ItemView[],
): number[] {
  return items
    .filter((item) => item.key !== event.itemKey && item.state === "in_flight")
    .filter((item) => {
      const paths =
        item.radius === null ? null : stringList(item.radius["paths"]);
      return (
        paths === null ||
        event.observed.some((observedPath) =>
          pathIsCovered(observedPath, paths),
        )
      );
    })
    .map((item) => item.key)
    .sort((left, right) => left - right);
}

/** Validate persisted halt intent, affected-item order, and generation binding. */
function validateHaltProtocol(
  state: Record<string, unknown>,
  events: readonly DriftEvent[],
  items: readonly ItemView[],
  mutations: readonly MutationView[],
  context: string,
): string[] {
  const errors: string[] = [];
  const haltedEvents = events.filter(
    (event) => event.action === "halted_later_started_item",
  );
  for (const event of haltedEvents) {
    const requeues = mutations.filter(
      (mutation) => mutation.op === "requeue" && mutation.at >= event.at,
    );
    const keys = requeues
      .map((mutation) => mutation.itemKey)
      .filter((key): key is number => key !== null);
    const ordered = [...keys].sort((left, right) => left - right);
    if (keys.length === 0) {
      errors.push(
        `${context} drift_events[${event.position}] halted_later_started_item action requires a persisted requeue mutation.`,
      );
    } else if (keys.some((key, index) => key !== ordered[index])) {
      errors.push(
        `${context} requeue mutation item order must be ascending; found: ${pythonRepr(keys)}.`,
      );
    }
    if (keys.includes(event.itemKey)) {
      errors.push(
        `${context} drifted item ${event.itemKey} must not be the halted requeue target.`,
      );
    }

    const expectedPeers = observedConflictPeers(event, items);
    if (
      expectedPeers.length > 0 &&
      (expectedPeers.length !== ordered.length ||
        expectedPeers.some((key, index) => key !== ordered[index]))
    ) {
      errors.push(
        `${context} drift_events[${event.position}] requires halted peer order ${pythonRepr(expectedPeers)}; found requeues: ${pythonRepr(ordered)}.`,
      );
    }
    for (const requeue of requeues) {
      if (
        requeue.priorState !== "in_flight" ||
        requeue.newState !== "blocked"
      ) {
        errors.push(
          `${context} mutations[${requeue.position}] must requeue in_flight to blocked for semantic drift.`,
        );
      }
      const item = items.find((candidate) => candidate.key === requeue.itemKey);
      if (item?.state !== "blocked" || item.mergeStatus !== "blocked_drift") {
        errors.push(
          `${context} requeued item ${String(requeue.itemKey)} must persist state 'blocked' with merge_status 'blocked_drift'.`,
        );
      }
    }
    const finalGeneration = requeues.at(-1)?.generation;
    if (
      finalGeneration !== undefined &&
      state["recolor_generation"] !== finalGeneration
    ) {
      errors.push(
        `${context} drift resolution generation must match final requeue generation ${finalGeneration}; found: ${pythonRepr(state["recolor_generation"])}.`,
      );
    }
  }
  return errors;
}

function conflictEdges(state: Record<string, unknown>): [number, number][] {
  const rawEdges = state["conflict_edges"];
  if (!Array.isArray(rawEdges)) {
    return [];
  }
  const edges: [number, number][] = [];
  for (const entry of rawEdges) {
    if (
      !isObject(entry) ||
      typeof entry["a"] !== "number" ||
      !Number.isInteger(entry["a"]) ||
      typeof entry["b"] !== "number" ||
      !Number.isInteger(entry["b"]) ||
      entry["a"] === entry["b"]
    ) {
      continue;
    }
    edges.push([
      Math.min(entry["a"], entry["b"]),
      Math.max(entry["a"], entry["b"]),
    ]);
  }
  return edges;
}

/** Port the Python Welsh-Powell ordering for the unstarted induced subgraph. */
function localColors(
  vertices: readonly number[],
  edges: readonly [number, number][],
): Map<number, number> {
  const vertexSet = new Set(vertices);
  const neighbors = new Map(vertices.map((key) => [key, new Set<number>()]));
  for (const [left, right] of edges) {
    if (vertexSet.has(left) && vertexSet.has(right)) {
      neighbors.get(left)?.add(right);
      neighbors.get(right)?.add(left);
    }
  }
  const ordered = [...vertices].sort((left, right) => {
    const degreeDifference =
      (neighbors.get(right)?.size ?? 0) - (neighbors.get(left)?.size ?? 0);
    return degreeDifference === 0 ? left - right : degreeDifference;
  });
  const colors = new Map<number, number>();
  for (const key of ordered) {
    const occupied = new Set(
      [...(neighbors.get(key) ?? [])]
        .map((neighbor) => colors.get(neighbor))
        .filter((color): color is number => color !== undefined),
    );
    let color = 0;
    while (occupied.has(color)) {
      color += 1;
    }
    colors.set(key, color);
  }
  return colors;
}

/** Validate the persisted current-generation view of the unstarted recolor. */
function validateRecolor(
  state: Record<string, unknown>,
  events: readonly DriftEvent[],
  items: readonly ItemView[],
  mutations: readonly MutationView[],
  context: string,
): string[] {
  if (
    !events.some((event) => event.action === "halted_later_started_item") ||
    !mutations.some((mutation) => mutation.op === "requeue")
  ) {
    return [];
  }
  const currentCohort = state["current_cohort"];
  const generation = state["recolor_generation"];
  if (
    !isNonNegativeInteger(currentCohort) ||
    typeof currentCohort !== "number" ||
    !isNonNegativeInteger(generation) ||
    typeof generation !== "number"
  ) {
    return [];
  }
  const vertices = items
    .filter((item) => UNSTARTED_STATES.has(item.state))
    .map((item) => item.key);
  const pinned = new Set(
    items.filter((item) => item.state === "in_flight").map((item) => item.key),
  );
  const edges = conflictEdges(state);
  const crossesPinned = edges.some(
    ([left, right]) =>
      (vertices.includes(left) && pinned.has(right)) ||
      (vertices.includes(right) && pinned.has(left)),
  );
  const offset = crossesPinned ? currentCohort + 1 : currentCohort;
  const expected = new Map(
    [...localColors(vertices, edges)].map(([key, color]) => [
      key,
      offset + color,
    ]),
  );

  const actual = new Map<number, number>();
  const cohorts = state["cohorts"];
  if (Array.isArray(cohorts)) {
    for (const cohort of cohorts) {
      if (
        !isObject(cohort) ||
        cohort["generation"] !== generation ||
        typeof cohort["index"] !== "number" ||
        !Array.isArray(cohort["item_keys"])
      ) {
        continue;
      }
      const orderedKeys = cohort["item_keys"].filter(
        (key): key is number =>
          typeof key === "number" && vertices.includes(key),
      );
      if (
        orderedKeys.some(
          (key, index) => key !== [...orderedKeys].sort((a, b) => a - b)[index],
        )
      ) {
        return [`${context} recomputed cohort item order must be ascending.`];
      }
      for (const key of orderedKeys) {
        actual.set(key, cohort["index"]);
      }
    }
  }
  const mismatch =
    actual.size !== expected.size ||
    [...expected].some(([key, index]) => actual.get(key) !== index);
  return mismatch
    ? [
        `${context} recomputed cohort assignments do not match deterministic unstarted recoloring.`,
      ]
    : [];
}

/** Validate cross-record semantic drift invariants over a parsed checkpoint. */
export function validateDriftProtocol(
  state: Record<string, unknown>,
  context: string,
): string[] {
  const events = driftEvents(state);
  const items = itemViews(state);
  const mutations = mutationViews(state);
  const itemByKey = new Map(items.map((item) => [item.key, item]));
  const unresolved = latestEvents(events)
    .filter((event) => !eventIsResolved(event, itemByKey.get(event.itemKey)))
    .map((event) => event.itemKey)
    .sort((left, right) => left - right);
  const errors: string[] = [];
  if (unresolved.length > 0) {
    errors.push(
      `${context} unresolved drift for items ${pythonRepr(unresolved)} blocks admission and completion.`,
    );
  }

  const haltedEvents = events.filter(
    (event) => event.action === "halted_later_started_item",
  );
  if (
    haltedEvents.length === 0 &&
    mutations.some((mutation) => mutation.op === "requeue")
  ) {
    errors.push(
      `${context} semantic-drift requeue requires a persisted halted_later_started_item event.`,
    );
  }
  errors.push(
    ...validateHaltProtocol(state, events, items, mutations, context),
  );
  errors.push(...validateRecolor(state, events, items, mutations, context));
  return errors;
}
