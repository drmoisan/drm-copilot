/**
 * Unit tests for the validate verdict and rules V1 to V3 (issue #1051, S35 to
 * S38, S41 and S43). Fixtures are in-memory destinations under `/dest`.
 */

import { hashPayloadText } from "../../../src/lib/push-down/push-down-destination-manifest";
import {
  VALIDATE_NOT_CHECKED,
  VALIDATE_RULE_IDS,
  validatePushDownIntegration,
} from "../../../src/lib/push-down-integration/integration-validate";
import {
  CALLER_TEXT,
  DATA_FILE_TEXT,
  DEST,
  destination,
  manifestText,
  type RecordingIntegrationFileSystem,
} from "./integration-test-helpers";

const DATA = ".github/drm-copilot/ci-required-checks.json";
const CALLER = ".github/workflows/drm-copilot-ci.yml";

/** Files of a destination that passes every rule. */
function validFiles(caller: string = CALLER_TEXT): Record<string, string> {
  return {
    [CALLER]: caller,
    [DATA]: DATA_FILE_TEXT,
    ".push-down-manifest.json": manifestText(
      { claude: { packs: ["core", "python"] } },
      {
        [CALLER]: {
          layer: "shared",
          pack: "core",
          sha256: hashPayloadText(caller),
        },
        [DATA]: {
          layer: "shared",
          pack: "core",
          sha256: hashPayloadText(DATA_FILE_TEXT),
        },
      },
    ),
  };
}

/** Validate a destination. */
function validate(fs: RecordingIntegrationFileSystem) {
  return validatePushDownIntegration({ fs, destinationRoot: DEST });
}

/** Return one rule entry by id prefix. */
function rule(fs: RecordingIntegrationFileSystem, id: string) {
  const entry = validate(fs).rules.find((candidate) =>
    candidate.rule.startsWith(id),
  );
  if (entry === undefined) {
    throw new Error(`rule ${id} missing`);
  }
  return entry;
}

describe("validatePushDownIntegration", () => {
  it("S35 positive: returns pass with the five rules in order and no failures", () => {
    const result = validate(destination(validFiles()));

    expect(result.verdict).toBe("pass");
    expect(result.rules.map((entry) => entry.rule)).toEqual([
      ...VALIDATE_RULE_IDS,
    ]);
    expect(result.rules.map((entry) => entry.status)).toEqual([
      "pass",
      "pass",
      "pass",
      "pass",
      "pass",
    ]);
    expect(result.rules.every((entry) => entry.failures.length === 0)).toBe(
      true,
    );
  });

  it("S35 negative: one failing rule makes the verdict fail, with sorted failures", () => {
    const files = validFiles();
    files[".github/workflows/z.yml"] = "on: *a\n";
    files[".github/workflows/a.yml"] = 'name: "x\n';

    const result = validate(destination(files));

    expect(result.verdict).toBe("fail");
    const v1 = result.rules[0];
    expect(v1?.status).toBe("fail");
    expect(v1?.failures.map((failure) => failure.path)).toEqual([
      ".github/workflows/a.yml",
      ".github/workflows/z.yml",
    ]);
  });

  it("S36 positive: V1 passes when every workflow reads ok", () => {
    expect(rule(destination(validFiles()), "V1").status).toBe("pass");
  });

  it("S36 negative: V1 fails per unreadable file naming the line, and is not-applicable without workflows", () => {
    const failing = destination({
      ".github/workflows/a.yml": "name: a\njobs: &x {}\n",
      ".github/workflows/b.yaml": "on: [push\n",
    });

    expect(rule(failing, "V1")).toEqual({
      rule: "V1-workflow-read",
      status: "fail",
      failures: [
        {
          path: ".github/workflows/a.yml",
          message: "line 2: unsupported construct anchor",
        },
        {
          path: ".github/workflows/b.yaml",
          message: "line 1: unterminated flow collection",
        },
      ],
    });
    expect(rule(destination({}), "V1").status).toBe("not-applicable");
  });

  it("S37 positive: V2 passes for the delivered data file", () => {
    expect(rule(destination(validFiles()), "V2").status).toBe("pass");
  });

  it.each([
    ["absent", undefined, "not-applicable"],
    ["not JSON", "{", "fail"],
    ["schema major 2", '{"schema_version":"2.0.0"}', "fail"],
    [
      "an empty workflow",
      '{"schema_version":"1.0.0","workflow":"","workflow_file":"x","required_contexts":["a"]}',
      "fail",
    ],
    [
      "a missing workflow_file",
      '{"schema_version":"1.0.0","workflow":"CI","required_contexts":["a"]}',
      "fail",
    ],
    [
      "empty required_contexts",
      '{"schema_version":"1.0.0","workflow":"CI","workflow_file":"x","required_contexts":[]}',
      "fail",
    ],
    [
      "an empty context",
      '{"schema_version":"1.0.0","workflow":"CI","workflow_file":"x","required_contexts":[""]}',
      "fail",
    ],
    ["a JSON array", "[]", "fail"],
  ])("S37 negative: V2 for a data file that is %s", (_label, text, status) => {
    const fs = destination(text === undefined ? {} : { [DATA]: text });

    const entry = rule(fs, "V2");

    expect(entry.status).toBe(status);
    expect(entry.failures.length > 0).toBe(status === "fail");
  });

  it("S38 positive: V3 accepts a gate whose if is ${{ always() }}", () => {
    const caller = CALLER_TEXT.replace("if: always()", "if: ${{ always() }}");

    expect(rule(destination(validFiles(caller)), "V3").status).toBe("pass");
  });

  it("S38 negative: V3 is not-applicable when V2 does not pass", () => {
    const fs = destination({ [CALLER]: CALLER_TEXT, [DATA]: "{" });

    expect(rule(fs, "V3").status).toBe("not-applicable");
  });

  it.each([
    [
      "no workflow named CI",
      (files: Record<string, string>) => {
        files[CALLER] = CALLER_TEXT.replace("name: CI\n", "name: Other\n");
      },
      "expected exactly one workflow named 'CI'; found 0",
    ],
    [
      "two workflows named CI",
      (files: Record<string, string>) => {
        files[".github/workflows/ci.yml"] = "name: CI\non: push\n";
      },
      "expected exactly one workflow named 'CI'; found 2",
    ],
    [
      "no pull_request trigger",
      (files: Record<string, string>) => {
        files[CALLER] = CALLER_TEXT.replace("  pull_request:", "  push:");
      },
      "the workflow triggers do not include pull_request",
    ],
    [
      "no job producing the check",
      (files: Record<string, string>) => {
        files[CALLER] = CALLER_TEXT.replace(
          "name: CI Required Gate",
          "name: Gate",
        );
      },
      "no job produces the required check 'CI Required Gate'",
    ],
    [
      "a gate without always()",
      (files: Record<string, string>) => {
        files[CALLER] = CALLER_TEXT.replace("if: always()", "if: success()");
      },
      "job 'ci-required-gate' does not run with if: always()",
    ],
    [
      "a gate that misses a needed job",
      (files: Record<string, string>) => {
        files[CALLER] = CALLER_TEXT.replace(
          "      - python\n",
          "      - other\n",
        );
      },
      "job 'ci-required-gate' does not need: python",
    ],
  ])("S38 negative: V3 fails for %s", (_label, mutate, message) => {
    const files = validFiles();
    mutate(files);

    const entry = rule(destination(files), "V3");

    expect(entry.status).toBe("fail");
    expect(
      entry.failures.some((failure) => failure.message.startsWith(message)),
    ).toBe(true);
  });

  it("S41 positive: not_checked equals the exported list in order on every completed run", () => {
    const passing = validate(destination(validFiles()));
    const failing = validate(destination({}));

    expect(passing.not_checked).toEqual([...VALIDATE_NOT_CHECKED]);
    expect(failing.not_checked).toEqual([...VALIDATE_NOT_CHECKED]);
    expect(VALIDATE_NOT_CHECKED).toHaveLength(12);
    expect(VALIDATE_NOT_CHECKED[0]).toBe("whether CI runs or passes");
    expect(VALIDATE_NOT_CHECKED[11]).toBe(
      "integration choices that are correct but unusual",
    );
  });

  it("S41 negative: a reordered list is not the not_checked list", () => {
    const reordered = [...VALIDATE_NOT_CHECKED].reverse();

    expect(validate(destination({})).not_checked).not.toEqual(reordered);
  });

  it("S43 positive: validate records no write and two calls return deep-equal results", () => {
    const fixtures = [
      destination(validFiles()),
      destination({}),
      destination(validFiles(), true),
    ];

    for (const fs of fixtures) {
      const first = validate(fs);
      expect(validate(fs)).toEqual(first);
      expect(fs.writeCalls).toEqual([]);
    }
    expect(validate(fixtures[2] as RecordingIntegrationFileSystem)).toEqual(
      validate(fixtures[0] as RecordingIntegrationFileSystem),
    );
  });

  it("S43 negative: a changed destination changes the verdict, so results reflect content", () => {
    const fs = destination(validFiles());
    const before = validate(fs);

    fs.seed(`${DEST}/${CALLER}`, "name: CI\non: push\n");

    expect(validate(fs)).not.toEqual(before);
    expect(validate(fs).verdict).toBe("fail");
  });
});
