import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import path from "node:path";

import {
  HandoffContractError,
  parseHandoffEnvelopeText,
} from "../../../src/lib/validate/orchestration-handoff-contract";
import {
  matchingText,
  oneOf,
  parseCapabilities,
  positiveInteger,
  record,
  stringArray,
  text,
} from "../../../src/lib/validate/orchestration-handoff-contract-support";

type Document = Record<string, unknown>;

interface InvalidEnvelopeCase {
  readonly expectedField: string;
  readonly fixture?: string;
  readonly id: string;
  readonly mutate: (document: Document) => void;
}

interface SupportFailureCase {
  readonly act: () => unknown;
  readonly expectedField: string;
  readonly id: string;
}

const fixtureRoot = path.resolve(
  __dirname,
  "../../../../../tests/fixtures/orchestration-handoff/contract",
);

function isDocument(value: unknown): value is Document {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function loadDocument(name = "valid-ordinary-claude-to-codex.json"): Document {
  const value: unknown = JSON.parse(
    readFileSync(path.join(fixtureRoot, name), "utf8"),
  );
  if (!isDocument(value)) throw new Error("Handoff fixture must be an object.");
  return value;
}

function objectAt(
  document: Document,
  ...segments: readonly string[]
): Document {
  let current: unknown = document;
  for (const segment of segments) {
    if (!isDocument(current)) {
      throw new Error(`Fixture path does not resolve before ${segment}.`);
    }
    current = current[segment];
  }
  if (!isDocument(current))
    throw new Error("Fixture path must resolve to an object.");
  return current;
}

function captureContractError(act: () => unknown): HandoffContractError {
  try {
    act();
  } catch (error: unknown) {
    if (error instanceof HandoffContractError) return error;
    throw error;
  }
  throw new Error("Expected a handoff contract error.");
}

const invalidEnvelopeCases: readonly InvalidEnvelopeCase[] = [
  {
    id: "translated historical receipts",
    expectedField: "source.expression.historical_receipts",
    mutate: (document) => {
      objectAt(document, "source", "expression", "historical_receipts")[
        "mode"
      ] = "translated";
    },
  },
  {
    id: "non-canonical archive path",
    expectedField: "source.checkpoint.archive_path",
    mutate: (document) => {
      objectAt(document, "source", "checkpoint")["archive_path"] =
        "artifacts/orchestration/handoffs/sources/sha256/wrong.json";
    },
  },
  {
    id: "unknown completed phase",
    expectedField: "lifecycle.completed_phases",
    mutate: (document) => {
      objectAt(document, "lifecycle")["completed_phases"] = [
        "promotion",
        "not-a-phase",
      ];
    },
  },
  {
    id: "non-monotonic completed phases",
    expectedField: "lifecycle.completed_phases",
    mutate: (document) => {
      objectAt(document, "lifecycle")["completed_phases"] = [
        "preflight",
        "promotion",
      ];
    },
  },
  {
    id: "completed next transition",
    expectedField: "lifecycle.next_transition",
    mutate: (document) => {
      objectAt(document, "lifecycle")["next_transition"] = "promotion";
    },
  },
  {
    id: "non-integral parallel cohort",
    fixture: "valid-parallel-codex-to-claude.json",
    expectedField: "scheduler_context.cohort_or_wave",
    mutate: (document) => {
      objectAt(document, "scheduler_context")["cohort_or_wave"] = 1.5;
    },
  },
  {
    id: "invalid history failure code",
    expectedField: "handoff_history.0.failure_code",
    mutate: (document) => {
      const history = document["handoff_history"];
      if (!Array.isArray(history) || !isDocument(history[0])) {
        throw new Error("Fixture history must contain an object.");
      }
      history[0]["failure_code"] = "invalid";
    },
  },
  {
    id: "same source and destination provider",
    expectedField: "destination.provider",
    mutate: (document) => {
      objectAt(document, "destination")["provider"] = "claude";
    },
  },
  {
    id: "non-canonical destination checkpoint",
    expectedField: "destination.checkpoint_path",
    mutate: (document) => {
      objectAt(document, "destination")["checkpoint_path"] =
        "artifacts/orchestration/other.json";
    },
  },
  {
    id: "empty handoff history",
    expectedField: "handoff_history",
    mutate: (document) => {
      document["handoff_history"] = [];
    },
  },
];

const supportFailureCases: readonly SupportFailureCase[] = [
  {
    id: "record rejects null",
    expectedField: "record",
    act: () => record(null, "record", []),
  },
  {
    id: "record requires declared properties",
    expectedField: "record",
    act: () => record({}, "record", ["required"]),
  },
  {
    id: "text rejects non-strings",
    expectedField: "text",
    act: () => text(1, "text"),
  },
  {
    id: "text rejects whitespace",
    expectedField: "text",
    act: () => text(" ", "text"),
  },
  {
    id: "matching text enforces its pattern",
    expectedField: "matching",
    act: () => matchingText("no", "matching", /^yes$/),
  },
  {
    id: "positive integers reject zero",
    expectedField: "integer",
    act: () => positiveInteger(0, "integer"),
  },
  {
    id: "enumerations reject unknown values",
    expectedField: "enum",
    act: () => oneOf("other", "enum", ["expected"]),
  },
  {
    id: "string arrays reject non-arrays",
    expectedField: "strings",
    act: () => stringArray(null, "strings"),
  },
  {
    id: "string arrays reject non-string members",
    expectedField: "strings",
    act: () => stringArray([1], "strings"),
  },
  {
    id: "string arrays reject empty members",
    expectedField: "strings",
    act: () => stringArray([""], "strings"),
  },
  {
    id: "string arrays reject duplicates",
    expectedField: "strings",
    act: () => stringArray(["same", "same"], "strings"),
  },
  {
    id: "capabilities require non-empty lists",
    expectedField: "capabilities",
    act: () => parseCapabilities({ vocabularies: [], required: [] }),
  },
];

describe("portable handoff negative contract coverage", () => {
  it.each(invalidEnvelopeCases)("rejects $id", (scenario) => {
    // Arrange
    const document = loadDocument(scenario.fixture);
    scenario.mutate(document);

    // Act
    const error = captureContractError(() =>
      parseHandoffEnvelopeText(JSON.stringify(document)),
    );

    // Assert
    expect(error.field).toBe(scenario.expectedField);
  });

  it.each(supportFailureCases)("$id", (scenario) => {
    // Act
    const error = captureContractError(scenario.act);

    // Assert
    expect(error.field).toBe(scenario.expectedField);
  });

  it("normalizes malformed JSON to a contract error", () => {
    // Act
    const error = captureContractError(() => parseHandoffEnvelopeText("{"));

    // Assert
    expect(error.field).toBe("handoff");
  });
});
