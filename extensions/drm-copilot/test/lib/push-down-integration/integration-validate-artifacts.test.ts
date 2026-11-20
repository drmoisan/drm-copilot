/**
 * Unit and contract tests for validate rules V4 and V5 (issue #1051, S39 and
 * S40). The S39 contract case reads the tracked coverage-metrics hook and the
 * tracked bundled harness workflows; every other fixture is in memory.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { hashPayloadText } from "../../../src/lib/push-down/push-down-destination-manifest";
import { validatePushDownIntegration } from "../../../src/lib/push-down-integration/integration-validate";
import {
  COVERAGE_ARTIFACT_PATHS,
  selectedLanguagePacks,
} from "../../../src/lib/push-down-integration/integration-validate-artifacts";
import {
  bundledResource,
  CALLER_TEXT,
  DATA_FILE_TEXT,
  DEST,
  destination,
  manifestText,
} from "./integration-test-helpers";

const DATA = ".github/drm-copilot/ci-required-checks.json";
const CALLER = ".github/workflows/drm-copilot-ci.yml";
const REPOSITORY_ROOT = join(__dirname, "..", "..", "..", "..", "..");

/** Files with the given caller and selected packs, manifest hashes current. */
function files(
  caller: string,
  packs: ReadonlyArray<string>,
  extra: Readonly<Record<string, string>> = {},
): Record<string, string> {
  return {
    ...extra,
    [CALLER]: caller,
    [DATA]: DATA_FILE_TEXT,
    ".push-down-manifest.json": manifestText(
      { claude: { packs: ["core", ...packs] } },
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

/** Return a validate rule entry. */
function rule(fileSet: Readonly<Record<string, string>>, index: number) {
  const entry = validatePushDownIntegration({
    fs: destination(fileSet),
    destinationRoot: DEST,
  }).rules[index];
  if (entry === undefined) {
    throw new Error(`rule ${String(index)} missing`);
  }
  return entry;
}

const V4 = 3;
const V5 = 4;

describe("validate rule V4 (coverage artifact path)", () => {
  it("S39 positive: passes for a reference-mode harness job", () => {
    expect(rule(files(CALLER_TEXT, ["python"]), V4).status).toBe("pass");
  });

  it("S39 positive: passes for a copy-mode workflow job", () => {
    const caller = CALLER_TEXT.replace(
      "drmoisan/drm-copilot/.github/workflows/harness-python.yml@v9.8.7",
      "./.github/workflows/drm-copilot-python.yml",
    );

    expect(rule(files(caller, ["python"]), V4).status).toBe("pass");
  });

  it("S39 positive: passes when a transitively reached local workflow names the artifact path", () => {
    const caller = CALLER_TEXT.replace(
      "drmoisan/drm-copilot/.github/workflows/harness-python.yml@v9.8.7",
      "./.github/workflows/a.yml",
    );
    const extra = {
      ".github/workflows/a.yml":
        "name: A\non: workflow_call\njobs:\n  b:\n    uses: ./.github/workflows/b.yml\n  loop:\n    uses: ./.github/workflows/a.yml\n",
      ".github/workflows/b.yml":
        "name: B\non: workflow_call\njobs:\n  t:\n    steps:\n      - run: echo artifacts/python/lcov.info\n",
    };

    expect(rule(files(caller, ["python"], extra), V4).status).toBe("pass");
  });

  it("S39 positive: every artifact path appears in the coverage-metrics hook or the pack's bundled harness workflow", () => {
    const hook = readFileSync(
      join(
        REPOSITORY_ROOT,
        ".claude",
        "hooks",
        "validate-feature-review-coverage-metrics.ps1",
      ),
      "utf8",
    );
    const stems: Readonly<Record<string, string>> = {
      "csharp-legacy": "dotnet",
      "csharp-modern": "dotnet",
      powershell: "powershell",
      python: "python",
      typescript: "typescript",
    };

    for (const [pack, artifact] of Object.entries(COVERAGE_ARTIFACT_PATHS)) {
      const harness = bundledResource(
        `ci-workflows/workflows/harness-${stems[pack] ?? ""}.yml`,
      );
      expect(hook.includes(artifact) || harness.includes(artifact)).toBe(true);
    }
    expect(Object.keys(COVERAGE_ARTIFACT_PATHS)).toHaveLength(5);
  });

  it("S39 negative: fails once per selected pack that passes neither test", () => {
    const caller = CALLER_TEXT.replace(
      "drmoisan/drm-copilot/.github/workflows/harness-python.yml@v9.8.7",
      "./.github/workflows/missing.yml",
    );

    const entry = rule(files(caller, ["python", "typescript"]), V4);

    expect(entry.status).toBe("fail");
    expect(entry.failures.map((failure) => failure.message)).toEqual([
      "pack python: no job uses harness-python.yml or drm-copilot-python.yml and no reached workflow names artifacts/python/lcov.info",
      "pack typescript: no job uses harness-typescript.yml or drm-copilot-typescript.yml and no reached workflow names coverage/lcov.info",
    ]);
  });

  it("S39 negative: is not-applicable when V3 fails or no language pack is selected", () => {
    const noGate = CALLER_TEXT.replace("name: CI Required Gate", "name: Gate");

    expect(rule(files(noGate, ["python"]), V4).status).toBe("not-applicable");
    expect(rule(files(CALLER_TEXT, []), V4).status).toBe("not-applicable");
  });

  it("maps a bare csharp selection to its variant pack", () => {
    const manifest = {
      schemaVersion: "1.0.0",
      payloadVersion: "1.0.0",
      selection: {
        codex: { packs: ["core", "csharp"], csharpVariant: "legacy" },
        claude: { packs: ["core", "csharp"] },
      },
      files: {},
    };

    expect(selectedLanguagePacks(manifest)).toEqual([
      "csharp-legacy",
      "csharp-modern",
    ]);
    expect(selectedLanguagePacks(undefined)).toEqual([]);
  });
});

describe("validate rule V5 (manifest hash)", () => {
  it("S40 positive: passes when every entry's hash equals the destination text", () => {
    expect(rule(files(CALLER_TEXT, ["python"]), V5)).toEqual({
      rule: "V5-manifest-hash",
      status: "pass",
      failures: [],
      destination_owned: [],
    });
  });

  it("S40 positive: lists modified and missing paths named in .push-down-exclusions as destination-owned", () => {
    const fileSet = files(CALLER_TEXT, ["python"], {
      ".push-down-exclusions": `# owned\n${CALLER}\n.github/drm-copilot/\n`,
    });
    fileSet[CALLER] = `${CALLER_TEXT}# edited\n`;
    delete fileSet[DATA];

    expect(rule(fileSet, V5)).toEqual({
      rule: "V5-manifest-hash",
      status: "pass",
      failures: [],
      destination_owned: [DATA, CALLER],
    });
  });

  it("S40 negative: fails for a modified and a missing entry", () => {
    const fileSet = files(CALLER_TEXT, ["python"]);
    fileSet[CALLER] = `${CALLER_TEXT}# edited\n`;
    delete fileSet[DATA];

    expect(rule(fileSet, V5).failures).toEqual([
      {
        path: DATA,
        message:
          "missing: the manifest lists the file but the destination has none",
      },
      {
        path: CALLER,
        message:
          "modified: the destination text does not match the recorded hash",
      },
    ]);
  });

  it("S40 negative: fails when the manifest is absent or rejected by the parser", () => {
    const absent = files(CALLER_TEXT, ["python"]);
    delete absent[".push-down-manifest.json"];
    const rejected = files(CALLER_TEXT, ["python"]);
    rejected[".push-down-manifest.json"] = '{"schema_version":"9.0.0"}';

    expect(rule(absent, V5).failures).toEqual([
      {
        path: ".push-down-manifest.json",
        message: "the push-down manifest is absent",
      },
    ]);
    const message = rule(rejected, V5).failures[0]?.message ?? "";
    expect(message).toContain("Invalid push-down destination manifest");
  });

  it("S40 negative: a malformed exclusion manifest is a failure", () => {
    const fileSet = files(CALLER_TEXT, ["python"], {
      ".push-down-exclusions": "/absolute/path\n",
    });

    const entry = rule(fileSet, V5);

    expect(entry.status).toBe("fail");
    expect(entry.failures[0]?.path).toBe(".push-down-exclusions");
  });
});
