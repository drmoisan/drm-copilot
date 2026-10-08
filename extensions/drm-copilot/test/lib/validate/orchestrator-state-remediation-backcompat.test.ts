import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  validateOrchestratorStateText,
  type ValidateOrchestratorStateOptions,
} from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Back-compat replay of the remediation-loop checkpoint corpus (issue #484).
 *
 * Purpose:
 *     Each committed checkpoint under
 *     `tests/fixtures/orchestrator_state_remediation_loop_backcompat/` carries
 *     none of the #484 keys. The companion file
 *     `tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json`
 *     records, under its `typescript` section, the full ordered error list the
 *     unmodified validator returned for each fixture in each supported mode.
 *     This suite replays every fixture and requires the same list, so the
 *     remediation-loop change cannot alter the output for a checkpoint that
 *     does not use the new keys.
 *
 * Filesystem access:
 *     Read-only load of the committed fixtures, resolved from `__dirname`. No
 *     temporary file is created, no file is mutated, and no process is started.
 */

/**
 * Repository fixtures directory, five levels up from this directory:
 * `validate` -> `lib` -> `test` -> `drm-copilot` -> `extensions` -> root.
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

/** Directory holding the eleven back-compat checkpoints. */
const FIXTURE_DIR = path.join(
  FIXTURES_ROOT,
  "orchestrator_state_remediation_loop_backcompat",
);

/** Captured expected-output file shared by the three runtimes. */
const EXPECTED_PATH = path.join(
  FIXTURES_ROOT,
  "orchestrator_state_remediation_loop_backcompat_expected.json",
);

/** Fixed corpus size. */
const EXPECTED_FIXTURE_COUNT = 11;

/** Runtime section of the expected file read by this suite. */
const RUNTIME_KEY = "typescript";

/**
 * Test-local routing matrix injected under `require_complete`, declared as in
 * `orchestrator-state-core.completion.test.ts`.
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

/** Mode name in the expected file mapped to the options that select it. */
const MODE_OPTIONS: Readonly<Record<string, ValidateOrchestratorStateOptions>> =
  {
    plain: {},
    require_complete: { requireComplete: true, routingMatrix: ROUTING_MATRIX },
    require_model_routing: { requireModelRouting: true },
  };

/** One replay case: a fixture stem and a mode. */
interface ReplayCase {
  readonly stem: string;
  readonly mode: string;
}

/**
 * Narrow an unknown parsed value to a plain JSON object.
 *
 * @param value Parsed JSON value.
 * @param label Label used in the failure message.
 * @returns The validated object.
 * @throws Error when the value is not a plain JSON object.
 */
function requireObject(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error(`${label} must be a JSON object.`);
  }
  return value as Record<string, unknown>;
}

/** Fixture file names, sorted for stable case order. */
const FIXTURE_FILE_NAMES: readonly string[] = fs
  .readdirSync(FIXTURE_DIR)
  .filter((entry) => entry.endsWith(".json"))
  .sort((left, right) => left.localeCompare(right));

/** Parsed expected-output file. */
const EXPECTED: Record<string, unknown> = requireObject(
  JSON.parse(fs.readFileSync(EXPECTED_PATH, "utf8")),
  path.basename(EXPECTED_PATH),
);

/** Every stem and mode pair, in fixture then mode order. */
const REPLAY_CASES: readonly ReplayCase[] = FIXTURE_FILE_NAMES.flatMap(
  (fileName) =>
    Object.keys(MODE_OPTIONS).map((mode) => ({
      stem: path.basename(fileName, ".json"),
      mode,
    })),
);

/**
 * Read the captured error list for one stem and mode.
 *
 * @param stem Fixture stem.
 * @param mode Mode key.
 * @returns The ordered expected error list.
 * @throws Error when the section is absent or not an array.
 */
function expectedErrors(stem: string, mode: string): unknown[] {
  const runtimes = requireObject(EXPECTED[stem], stem);
  const modes = requireObject(runtimes[RUNTIME_KEY], `${stem}.${RUNTIME_KEY}`);
  const errors = modes[mode];
  if (!Array.isArray(errors)) {
    throw new Error(`${stem}.${RUNTIME_KEY}.${mode} must be a JSON array.`);
  }
  return errors;
}

describe("remediation-loop back-compat replay", () => {
  it("discovers exactly eleven back-compat fixtures", () => {
    // Arrange: fixtures are discovered at module evaluation.
    // Act
    const discovered = FIXTURE_FILE_NAMES.length;

    // Assert
    expect(discovered).toBe(EXPECTED_FIXTURE_COUNT);
  });

  it.each(REPLAY_CASES)(
    "keeps the captured error list for $stem in mode $mode",
    ({ stem, mode }: ReplayCase) => {
      // Arrange
      const text = fs.readFileSync(
        path.join(FIXTURE_DIR, `${stem}.json`),
        "utf8",
      );
      const expected = expectedErrors(stem, mode);

      // Act
      const observed = validateOrchestratorStateText(text, MODE_OPTIONS[mode]);

      // Assert: element for element and in order.
      expect(observed).toEqual(expected);
    },
  );
});
