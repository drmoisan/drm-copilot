import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";
import { validateDriftProtocol } from "../../../src/lib/validate/parallel-orchestrator-state-drift";

/** A non-null JSON object used by the shared drift corpus. */
type JsonObject = Record<string, unknown>;

/** Python-authoritative outputs committed for one semantic-drift scenario. */
interface ExpectedDriftDecision {
  readonly normalizedEvent: JsonObject | null;
  readonly affectedItemOrder: readonly number[];
  readonly recomputed: JsonObject;
  readonly orderedRequeues: readonly JsonObject[];
  readonly admissionDecision: string;
  readonly completionDecision: string;
  readonly accepted: boolean;
  readonly reasonCode: string;
}

/** One structurally guarded shared drift scenario. */
interface DriftCase {
  readonly name: string;
  readonly behavior: string;
  readonly documentOverrides: JsonObject;
  readonly expected: ExpectedDriftDecision;
  readonly typescriptErrorContains: string | null;
  readonly currentlyDivergent: boolean;
}

const FIXTURE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "parallel-orchestration",
  "drift-parity.json",
);

const REQUIRED_BEHAVIORS = [
  "deterministic-requeue",
  "later-started-conflict-halt",
  "observed-versus-declared-files",
  "persisted-resolution",
  "quiescence",
  "unstarted-recoloring",
] as const;

/** Return true only for a non-null, non-array JSON object. */
function isObject(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Narrow a fixture value to an object with a path-specific error. */
function requireObject(value: unknown, label: string): JsonObject {
  if (!isObject(value)) {
    throw new Error(`${label} must be a JSON object.`);
  }
  return value;
}

/** Narrow a fixture value to a non-blank string. */
function requireText(value: unknown, label: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`${label} must be a non-empty string.`);
  }
  return value;
}

/** Narrow a fixture value to a boolean. */
function requireBoolean(value: unknown, label: string): boolean {
  if (typeof value !== "boolean") {
    throw new Error(`${label} must be a boolean.`);
  }
  return value;
}

/** Narrow a fixture value to a JSON array. */
function requireArray(value: unknown, label: string): readonly unknown[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be a JSON array.`);
  }
  return value;
}

/** Narrow a fixture value to an integer array. */
function requireIntegerArray(value: unknown, label: string): readonly number[] {
  const values = requireArray(value, label);
  if (values.some((entry) => !Number.isInteger(entry))) {
    throw new Error(`${label} must contain only integers.`);
  }
  return values as readonly number[];
}

/** Narrow a fixture value to an object or null. */
function requireNullableObject(
  value: unknown,
  label: string,
): JsonObject | null {
  return value === null ? null : requireObject(value, label);
}

/** Narrow a fixture value to a string or null. */
function requireNullableText(value: unknown, label: string): string | null {
  return value === null ? null : requireText(value, label);
}

/** Parse and structurally guard one corpus case. */
function loadCase(value: unknown, index: number): DriftCase {
  const fixtureCase = requireObject(value, `cases[${index}]`);
  const expected = requireObject(
    fixtureCase["expected"],
    `cases[${index}].expected`,
  );
  return {
    name: requireText(fixtureCase["name"], `cases[${index}].name`),
    behavior: requireText(fixtureCase["behavior"], `cases[${index}].behavior`),
    documentOverrides: requireObject(
      fixtureCase["document_overrides"],
      `cases[${index}].document_overrides`,
    ),
    expected: {
      normalizedEvent: requireNullableObject(
        expected["normalized_event"],
        `cases[${index}].expected.normalized_event`,
      ),
      affectedItemOrder: requireIntegerArray(
        expected["affected_item_order"],
        `cases[${index}].expected.affected_item_order`,
      ),
      recomputed: requireObject(
        expected["recomputed"],
        `cases[${index}].expected.recomputed`,
      ),
      orderedRequeues: requireArray(
        expected["ordered_requeues"],
        `cases[${index}].expected.ordered_requeues`,
      ).map((entry, entryIndex) =>
        requireObject(
          entry,
          `cases[${index}].expected.ordered_requeues[${entryIndex}]`,
        ),
      ),
      admissionDecision: requireText(
        expected["admission_decision"],
        `cases[${index}].expected.admission_decision`,
      ),
      completionDecision: requireText(
        expected["completion_decision"],
        `cases[${index}].expected.completion_decision`,
      ),
      accepted: requireBoolean(
        expected["accepted"],
        `cases[${index}].expected.accepted`,
      ),
      reasonCode: requireText(
        expected["reason_code"],
        `cases[${index}].expected.reason_code`,
      ),
    },
    typescriptErrorContains: requireNullableText(
      fixtureCase["typescript_error_contains"],
      `cases[${index}].typescript_error_contains`,
    ),
    currentlyDivergent: requireBoolean(
      fixtureCase["currently_divergent"],
      `cases[${index}].currently_divergent`,
    ),
  };
}

/** Load the committed shared corpus once for deterministic case discovery. */
function loadCorpus(): {
  readonly baseDocument: JsonObject;
  readonly cases: readonly DriftCase[];
  readonly lifecycleRequirements: JsonObject;
} {
  const parsed: unknown = JSON.parse(fs.readFileSync(FIXTURE_PATH, "utf8"));
  const root = requireObject(parsed, path.basename(FIXTURE_PATH));
  if (root["schema_version"] !== 1) {
    throw new Error("drift-parity.json schema_version must equal 1.");
  }
  return {
    baseDocument: requireObject(root["base_document"], "base_document"),
    cases: requireArray(root["cases"], "cases").map(loadCase),
    lifecycleRequirements: requireObject(
      root["lifecycle_requirements"],
      "lifecycle_requirements",
    ),
  };
}

const CORPUS = loadCorpus();

/** Apply one case's top-level overrides to a fresh base checkpoint. */
function materializeDocument(corpusCase: DriftCase): JsonObject {
  const base = requireObject(
    JSON.parse(JSON.stringify(CORPUS.baseDocument)) as unknown,
    "base_document clone",
  );
  const overrides = requireObject(
    JSON.parse(JSON.stringify(corpusCase.documentOverrides)) as unknown,
    `${corpusCase.name}.document_overrides clone`,
  );
  return { ...base, ...overrides };
}

/** Return the direct TypeScript checkpoint errors for one scenario. */
function checkpointErrors(corpusCase: DriftCase): readonly string[] {
  return validateParallelOrchestratorStateText(
    JSON.stringify(materializeDocument(corpusCase)),
  );
}

/** Build a resolved checkpoint carrying one complete halt/requeue/recolor cycle. */
function persistedHaltDocument(): JsonObject {
  const corpusCase = CORPUS.cases.find(
    (entry) => entry.behavior === "later-started-conflict-halt",
  );
  if (
    corpusCase === undefined ||
    corpusCase.expected.normalizedEvent === null
  ) {
    throw new Error("The halt fixture must carry a normalized event.");
  }
  const state = materializeDocument(corpusCase);
  const items = requireArray(state["items"], "state.items").map(
    (entry, index) => ({ ...requireObject(entry, `state.items[${index}]`) }),
  );
  const drifting = items.find((item) => item["issue_num"] === 444);
  const halted = items.find((item) => item["issue_num"] === 445);
  if (drifting === undefined || halted === undefined) {
    throw new Error("The halt fixture must retain items 444 and 445.");
  }
  drifting["blast_radius"] = {
    paths: corpusCase.expected.normalizedEvent["observed"],
    modules: ["python-dev-tools", "mcp-server"],
    shared_surfaces: [],
    contracts: [],
    source: "observed",
    computed_at: "2026-08-10T21-05",
  };
  halted["state"] = "blocked";
  halted["merge_status"] = "blocked_drift";
  state["items"] = items;
  state["mutations"] = corpusCase.expected.orderedRequeues.map((request) =>
    requireObject(request["mutation"], "ordered_requeues[].mutation"),
  );
  state["recolor_generation"] = 1;
  state["conflict_edges"] = [
    { a: 444, b: 446, reason: "path_overlap" },
    { a: 446, b: 447, reason: "path_overlap" },
  ];
  state["cohorts"] = [
    { index: 0, generation: 1, item_keys: [444, 445] },
    { index: 1, generation: 1, item_keys: [446] },
    { index: 2, generation: 1, item_keys: [447] },
  ];
  return state;
}

describe("shared parallel semantic-drift corpus", () => {
  it("loads every required behavior with complete stable expected output", () => {
    const names = CORPUS.cases.map((entry) => entry.name);
    const codes = CORPUS.cases.map((entry) => entry.expected.reasonCode);
    const behaviors = [
      ...new Set(CORPUS.cases.map((entry) => entry.behavior)),
    ].sort();

    expect(CORPUS.cases).toHaveLength(REQUIRED_BEHAVIORS.length);
    expect(new Set(names).size).toBe(names.length);
    expect(new Set(codes).size).toBe(codes.length);
    expect(behaviors).toEqual([...REQUIRED_BEHAVIORS]);
    for (const entry of CORPUS.cases) {
      expect(entry.currentlyDivergent).toBe(false);
      expect(entry.expected.recomputed).toEqual(
        expect.objectContaining({
          generation: expect.any(Number),
          cohort_assignments: expect.any(Array),
          batches: expect.any(Array),
        }),
      );
      expect(entry.expected.admissionDecision).not.toHaveLength(0);
      expect(entry.expected.completionDecision).not.toHaveLength(0);
    }
  });

  it("binds every lifecycle drift requirement to an executed shared case", () => {
    expect(Object.keys(CORPUS.lifecycleRequirements).sort()).toEqual([
      "ascending_requeue",
      "later_started_halt",
      "persisted_resolution",
      "quiescence",
      "unstarted_recolor",
    ]);
    const casesByName = new Map(
      CORPUS.cases.map((corpusCase) => [corpusCase.name, corpusCase]),
    );

    for (const [requirement, rawCaseName] of Object.entries(
      CORPUS.lifecycleRequirements,
    )) {
      const caseName = requireText(
        rawCaseName,
        `lifecycle_requirements.${requirement}`,
      );
      const corpusCase = casesByName.get(caseName);
      if (corpusCase === undefined) {
        throw new Error(
          `Lifecycle requirement ${requirement} references unknown case ${caseName}.`,
        );
      }

      const errors = checkpointErrors(corpusCase);
      if (corpusCase.expected.accepted) {
        expect(errors).toEqual([]);
      } else {
        expect(errors).not.toHaveLength(0);
      }
    }
  });

  it("keeps affected items and requeues in deterministic ascending order", () => {
    for (const entry of CORPUS.cases) {
      expect(entry.expected.affectedItemOrder).toEqual(
        [...entry.expected.affectedItemOrder].sort(
          (left, right) => left - right,
        ),
      );
      const requeueKeys = entry.expected.orderedRequeues.map(
        (request) => request["item_key"],
      );
      expect(requeueKeys).toEqual(
        [...requeueKeys].sort((left, right) => Number(left) - Number(right)),
      );
    }
  });

  it("accepts persisted halt, requeue, recolor, and resolution generation", () => {
    expect(
      validateDriftProtocol(persistedHaltDocument(), "Parallel checkpoint"),
    ).toEqual([]);
  });

  it("rejects non-deterministic requeue order", () => {
    const state = persistedHaltDocument();
    const mutations = requireArray(state["mutations"], "state.mutations");
    state["mutations"] = [
      { ...requireObject(mutations[0], "state.mutations[0]"), item_key: 446 },
      { ...requireObject(mutations[0], "state.mutations[0]"), item_key: 445 },
    ];

    expect(validateDriftProtocol(state, "Parallel checkpoint")).toContain(
      "Parallel checkpoint requeue mutation item order must be ascending; found: [446, 445].",
    );
  });

  it("rejects a stale deterministic recolor assignment", () => {
    const state = persistedHaltDocument();
    state["cohorts"] = [
      { index: 0, generation: 1, item_keys: [444, 445] },
      { index: 1, generation: 1, item_keys: [446, 447] },
    ];

    expect(validateDriftProtocol(state, "Parallel checkpoint")).toContain(
      "Parallel checkpoint recomputed cohort assignments do not match deterministic unstarted recoloring.",
    );
  });

  it("rejects a requeue generation that is not bound to checkpoint state", () => {
    const state = persistedHaltDocument();
    state["recolor_generation"] = 2;

    expect(validateDriftProtocol(state, "Parallel checkpoint")).toContain(
      "Parallel checkpoint drift resolution generation must match final requeue generation 1; found: 2.",
    );
  });

  it.each(CORPUS.cases)(
    "$name [$expected.reasonCode] matches the Python semantic decision",
    (corpusCase: DriftCase) => {
      const errors = checkpointErrors(corpusCase);
      if (corpusCase.expected.accepted) {
        expect(errors).toEqual([]);
        return;
      }

      expect(corpusCase.currentlyDivergent).toBe(false);
      expect(corpusCase.typescriptErrorContains).not.toBeNull();
      expect(errors[0]).toBe(
        "Parallel checkpoint unresolved drift for items [444] blocks admission and completion.",
      );
      expect(errors).toEqual(
        expect.arrayContaining([
          expect.stringContaining(corpusCase.typescriptErrorContains ?? ""),
        ]),
      );
    },
  );
});
