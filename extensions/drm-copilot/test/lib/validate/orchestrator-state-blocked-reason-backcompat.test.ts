import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Back-compat capture for the orchestrator-state `blocked_reason` vocabulary
 * (issue #523).
 *
 * Purpose:
 *     Replay the nine committed checkpoint fixtures in
 *     `tests/fixtures/orchestrator_state_blocked_reason_backcompat/` (the key
 *     absent, JSON `null`, and each pre-existing `blocked_reason` member) through
 *     `validateOrchestratorStateText` in three modes and assert the full ordered
 *     error list equals the `typescript` section of
 *     `tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json`,
 *     which was captured against the unmodified validator.
 *
 * Filesystem access:
 *     Read-only loads of committed fixtures resolved from `__dirname`. No
 *     temporary file is created and no file is mutated.
 */

/**
 * Committed fixtures root, five levels up from this directory: `validate` ->
 * `lib` -> `test` -> `drm-copilot` -> `extensions` -> repository root.
 */
const FIXTURES_ROOT = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
);

/** Directory holding the nine back-compat checkpoint fixtures. */
const BACKCOMPAT_DIR = path.join(
  FIXTURES_ROOT,
  "orchestrator_state_blocked_reason_backcompat",
);

/** Committed capture of the unmodified validators' error lists. */
const BACKCOMPAT_EXPECTED_PATH = path.join(
  FIXTURES_ROOT,
  "orchestrator_state_blocked_reason_backcompat_expected.json",
);

/** Fixture stems, one per captured `blocked_reason` shape. */
const BACKCOMPAT_STEMS: readonly string[] = [
  "absent",
  "null",
  "none",
  "spawn_agent_unavailable",
  "delegation_launch_failed",
  "delegate_no_receipt",
  "delegate_contract_incomplete",
  "validator_failed",
  "user_requested_stop",
];

/** Validation modes captured for the TypeScript runtime. */
const BACKCOMPAT_MODES: readonly string[] = [
  "plain",
  "require_complete",
  "require_model_routing",
];

/**
 * Focused routing matrix injected under `requireComplete`, declared the same
 * way as `orchestrator-state-core.completion.test.ts`.
 */
const ROUTING_MATRIX = {
  routes: {
    large: {
      requires_pr_gate: true,
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
    small: {
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
  },
};

/**
 * Type guard narrowing an unknown JSON value to a plain object.
 *
 * @param value Parsed JSON value.
 * @returns True when the value is a non-null, non-array object.
 */
function isJsonObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Narrow an unknown JSON value to a plain object.
 *
 * @param value Parsed JSON value.
 * @param label Dotted path used in the failure message.
 * @returns The validated object.
 * @throws Error when the value is not a plain JSON object.
 */
function requireObject(value: unknown, label: string): Record<string, unknown> {
  if (!isJsonObject(value)) {
    throw new Error(`${label} must be a JSON object.`);
  }
  return value;
}

/**
 * Narrow an unknown JSON value to an ordered list of error strings.
 *
 * @param value Parsed JSON value.
 * @param label Dotted path used in the failure message.
 * @returns The validated string list.
 * @throws Error when the value is not an array of strings.
 */
function requireStringList(value: unknown, label: string): string[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be an array.`);
  }
  return value.map((entry: unknown, index: number): string => {
    if (typeof entry !== "string") {
      throw new Error(`${label}[${String(index)}] must be a string.`);
    }
    return entry;
  });
}

/**
 * Return the captured error list for one stem and mode.
 *
 * @param stem Fixture stem.
 * @param mode Validation mode key.
 * @returns The ordered error list recorded in the `typescript` section.
 */
function loadExpected(stem: string, mode: string): string[] {
  const payload = requireObject(
    JSON.parse(fs.readFileSync(BACKCOMPAT_EXPECTED_PATH, "utf-8")),
    "expected",
  );
  const section = requireObject(payload["typescript"], "expected.typescript");
  const entry = requireObject(section[stem], `expected.typescript.${stem}`);
  return requireStringList(entry[mode], `expected.typescript.${stem}.${mode}`);
}

/**
 * Validate checkpoint text with only the option named by `mode` set.
 *
 * @param text Checkpoint JSON text.
 * @param mode Validation mode key.
 * @returns The validator's ordered error list.
 * @throws Error when the mode is not a captured mode.
 */
function validateInMode(text: string, mode: string): string[] {
  if (mode === "plain") {
    return validateOrchestratorStateText(text);
  }
  if (mode === "require_complete") {
    return validateOrchestratorStateText(text, {
      requireComplete: true,
      routingMatrix: ROUTING_MATRIX,
    });
  }
  if (mode === "require_model_routing") {
    return validateOrchestratorStateText(text, { requireModelRouting: true });
  }
  throw new Error(`unknown back-compat mode: ${mode}`);
}

describe("orchestrator-state blocked_reason back-compat capture", () => {
  it("discovers exactly nine back-compat fixtures", () => {
    // Arrange
    const expectedNames = BACKCOMPAT_STEMS.map((stem) => `${stem}.json`).sort();

    // Act
    const actualNames = fs
      .readdirSync(BACKCOMPAT_DIR)
      .filter((name) => name.endsWith(".json"))
      .sort();

    // Assert
    expect(actualNames).toHaveLength(9);
    expect(actualNames).toEqual(expectedNames);
  });

  for (const stem of BACKCOMPAT_STEMS) {
    for (const mode of BACKCOMPAT_MODES) {
      it(`${stem} / ${mode} yields the captured ordered error list`, () => {
        // Arrange
        const text = fs.readFileSync(
          path.join(BACKCOMPAT_DIR, `${stem}.json`),
          "utf-8",
        );
        const expected = loadExpected(stem, mode);

        // Act
        const actual = validateInMode(text, mode);

        // Assert
        expect(actual).toEqual(expected);
      });
    }
  }
});
