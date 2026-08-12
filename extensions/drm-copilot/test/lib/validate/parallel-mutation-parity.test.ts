import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";

/** A JSON object used by the shared mutation corpus. */
type JsonObject = Record<string, unknown>;

/** The binary result and stable reason code committed for one scenario. */
interface ExpectedDecision {
  readonly accepted: boolean;
  readonly reasonCode: string;
}

/** One structurally guarded shared mutation scenario. */
interface MutationCase {
  readonly name: string;
  readonly behavior: string;
  readonly authority: string;
  readonly documentOverrides: JsonObject;
  readonly operation: JsonObject | null;
  readonly expected: ExpectedDecision;
  readonly typescriptErrorContains: string | null;
  readonly currentlyDivergent: boolean;
}

/** The committed fixture is resolved from the repository root. */
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
  "mutation-parity.json",
);

const REQUIRED_BEHAVIORS = [
  "closed-mode",
  "complete-record",
  "detach-abandon-confirmation",
  "merged-removal",
  "open-mode",
  "pinned-in-flight",
  "sequence-duplicate",
  "sequence-gap",
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

/** Narrow a fixture value to a string or null. */
function requireNullableText(value: unknown, label: string): string | null {
  if (value === null) {
    return null;
  }
  return requireText(value, label);
}

/** Parse and structurally guard one corpus case. */
function loadCase(value: unknown, index: number): MutationCase {
  const fixtureCase = requireObject(value, `cases[${index}]`);
  const expected = requireObject(
    fixtureCase["expected"],
    `cases[${index}].expected`,
  );
  const operationValue = fixtureCase["operation"];
  return {
    name: requireText(fixtureCase["name"], `cases[${index}].name`),
    behavior: requireText(fixtureCase["behavior"], `cases[${index}].behavior`),
    authority: requireText(
      fixtureCase["authority"],
      `cases[${index}].authority`,
    ),
    documentOverrides: requireObject(
      fixtureCase["document_overrides"],
      `cases[${index}].document_overrides`,
    ),
    operation:
      operationValue === null
        ? null
        : requireObject(operationValue, `cases[${index}].operation`),
    expected: {
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
  readonly cases: readonly MutationCase[];
  readonly lifecycleModes: JsonObject;
} {
  const parsed: unknown = JSON.parse(fs.readFileSync(FIXTURE_PATH, "utf8"));
  const root = requireObject(parsed, path.basename(FIXTURE_PATH));
  if (root["schema_version"] !== 1) {
    throw new Error("mutation-parity.json schema_version must equal 1.");
  }
  const casesValue = root["cases"];
  if (!Array.isArray(casesValue)) {
    throw new Error("mutation-parity.json cases must be a JSON array.");
  }
  return {
    baseDocument: requireObject(root["base_document"], "base_document"),
    cases: casesValue.map(loadCase),
    lifecycleModes: requireObject(root["lifecycle_modes"], "lifecycle_modes"),
  };
}

const CORPUS = loadCorpus();

/** Apply one case's top-level state overrides to a fresh base document. */
function materializeDocument(corpusCase: MutationCase): JsonObject {
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
function checkpointErrors(corpusCase: MutationCase): readonly string[] {
  return validateParallelOrchestratorStateText(
    JSON.stringify(materializeDocument(corpusCase)),
  );
}

describe("shared parallel mutation-decision corpus", () => {
  it("loads every required behavior with one stable binary decision", () => {
    const names = CORPUS.cases.map((entry) => entry.name);
    const codes = CORPUS.cases.map((entry) => entry.expected.reasonCode);
    const behaviors = [
      ...new Set(CORPUS.cases.map((entry) => entry.behavior)),
    ].sort();

    expect(CORPUS.cases.length).toBeGreaterThan(0);
    expect(new Set(names).size).toBe(names.length);
    expect(new Set(codes).size).toBe(codes.length);
    expect(behaviors).toEqual([...REQUIRED_BEHAVIORS]);
  });

  it("binds every lifecycle mutation mode to an executed shared case", () => {
    expect(Object.keys(CORPUS.lifecycleModes).sort()).toEqual([
      "abandon",
      "add",
      "close",
      "detach",
      "remove",
    ]);
    const casesByName = new Map(
      CORPUS.cases.map((entry) => [entry.name, entry] as const),
    );
    for (const [mode, caseNameValue] of Object.entries(CORPUS.lifecycleModes)) {
      const caseName = requireText(caseNameValue, `lifecycle_modes.${mode}`);
      const corpusCase = casesByName.get(caseName);
      expect(corpusCase).toBeDefined();
      const errors = checkpointErrors(corpusCase as MutationCase);
      if (corpusCase?.expected.accepted) {
        expect(errors).toEqual([]);
      } else {
        expect(errors).not.toEqual([]);
      }
    }
  });

  it("carries exact item/worktree-bound confirmation for accepted detach and abandon", () => {
    const confirmed = CORPUS.cases.filter((entry) =>
      [
        "MUTATION_REMOVE_DETACH_CONFIRMED",
        "MUTATION_REMOVE_ABANDON_CONFIRMED",
      ].includes(entry.expected.reasonCode),
    );

    expect(confirmed).toHaveLength(2);
    for (const entry of confirmed) {
      const operation = requireObject(
        entry.operation,
        `${entry.name}.operation`,
      );
      const confirmation = requireObject(
        operation["confirmation"],
        `${entry.name}.operation.confirmation`,
      );
      const disposition = requireText(
        operation["disposition"],
        `${entry.name}.operation.disposition`,
      );
      const itemKey = operation["item_key"];
      const worktree = requireText(
        confirmation["worktree_identity"],
        `${entry.name}.operation.confirmation.worktree_identity`,
      );

      expect(confirmation).toEqual({
        operation: disposition,
        item_key: itemKey,
        worktree_identity: worktree,
        token: `confirm:${disposition}:${String(itemKey)}:${worktree}`,
      });
    }
  });

  const validatorCases = CORPUS.cases.filter(
    (entry) => entry.authority !== "recolor",
  );

  it.each(validatorCases)(
    "$name [$expected.reasonCode] matches the Python decision",
    (corpusCase: MutationCase) => {
      const errors = checkpointErrors(corpusCase);
      if (corpusCase.expected.accepted) {
        expect(errors).toEqual([]);
        return;
      }

      expect(corpusCase.typescriptErrorContains).not.toBeNull();
      expect(errors).toEqual(
        expect.arrayContaining([
          expect.stringContaining(corpusCase.typescriptErrorContains ?? ""),
        ]),
      );
    },
  );

  it.each(CORPUS.cases.filter((entry) => entry.currentlyDivergent))(
    "names the current TypeScript divergence: $name [$expected.reasonCode]",
    (corpusCase: MutationCase) => {
      expect(corpusCase.typescriptErrorContains).not.toBeNull();
    },
  );
});
