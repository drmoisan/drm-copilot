/**
 * Fixed discovery routing: contract parity with the shared routing corpus.
 *
 * Every row of `tests/fixtures/codex_routing/{topology,deployment}.json` is
 * replayed through the TypeScript resolvers (the Python CLI corpus is the
 * oracle), and the helper table is compared with the committed
 * `config/orchestration-routing.json`. Parser-level rows (exit 2) are argparse
 * rejections and are covered by the selector validator instead.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { describe, expect, it } from "@jest/globals";

import {
  DISCOVERY_GENERATED_AGENT_FAMILIES,
  DISCOVERY_OPERATIONS,
  resolveCodexDiscoveryTopology,
  validateInvocationKind,
  type DiscoveryRoutingInputs,
} from "../../../src/lib/validate/codex-discovery-routing";
import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");
const CORPUS_ROOT = path.join(REPO_ROOT, "tests", "fixtures", "codex_routing");
const CONFIG_PATH = path.join(
  REPO_ROOT,
  "config",
  "orchestration-routing.json",
);

interface CorpusRecord {
  readonly id: string;
  readonly argv: ReadonlyArray<string>;
  readonly expected_exit: number;
  readonly expected_stdout: string;
  readonly expected_stderr_contains: string | null;
}

interface ParsedTopologyArgv {
  languages: string[];
  productionFileCount: number;
  testFileCount: number;
  executionContext: string | undefined;
  crossCutting: boolean;
  rootPersona: string | undefined;
  invocationKind: string | undefined;
  skillId: string | undefined;
}

function loadCorpus(name: string): CorpusRecord[] {
  const text = fs.readFileSync(path.join(CORPUS_ROOT, `${name}.json`), "utf8");
  return JSON.parse(text) as CorpusRecord[];
}

/**
 * Render like Python `json.dumps(receipt, indent=2, sort_keys=True)`.
 *
 * Python's default `ensure_ascii=True` escapes every character outside the
 * printable ASCII range as a lowercase `\uXXXX` code unit, which the corpus
 * records verbatim, so the same escape is applied after serialization.
 */
function renderSorted(receipt: object): string {
  const sorted = Object.fromEntries(
    Object.entries(receipt).sort(([left], [right]) =>
      left < right ? -1 : left > right ? 1 : 0,
    ),
  );
  return JSON.stringify(sorted, null, 2).replace(
    /[^ -~\n]/g,
    (character) =>
      `\\u${character.charCodeAt(0).toString(16).padStart(4, "0")}`,
  );
}

/** Map topology CLI tokens onto resolver arguments (GNU `--flag value`). */
function parseTopologyArgv(argv: ReadonlyArray<string>): ParsedTopologyArgv {
  const parsed: ParsedTopologyArgv = {
    languages: [],
    productionFileCount: 0,
    testFileCount: 0,
    executionContext: undefined,
    crossCutting: false,
    rootPersona: undefined,
    invocationKind: undefined,
    skillId: undefined,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index] ?? "";
    const value = argv[index + 1] ?? "";
    // Routing table over the eight accepted options of the topology CLI.
    switch (token) {
      case "--language":
        parsed.languages.push(value);
        index += 1;
        break;
      case "--production-file-count":
        parsed.productionFileCount = Number(value);
        index += 1;
        break;
      case "--test-file-count":
        parsed.testFileCount = Number(value);
        index += 1;
        break;
      case "--execution-context":
        parsed.executionContext = value;
        index += 1;
        break;
      case "--cross-cutting":
        parsed.crossCutting = true;
        break;
      case "--root-persona":
        parsed.rootPersona = value;
        index += 1;
        break;
      case "--invocation-kind":
        parsed.invocationKind = value;
        index += 1;
        break;
      case "--skill-id":
        parsed.skillId = value;
        index += 1;
        break;
      default:
        throw new Error(`unexpected topology token ${token}`);
    }
  }
  return parsed;
}

function optionValue(argv: ReadonlyArray<string>, name: string): string {
  const index = argv.indexOf(name);
  return index === -1 ? "" : (argv[index + 1] ?? "");
}

const TOPOLOGY_RECORDS = loadCorpus("topology");
const DEPLOYMENT_RECORDS = loadCorpus("deployment");
const RESOLVABLE_TOPOLOGY = TOPOLOGY_RECORDS.filter(
  (record) => record.expected_exit !== 2,
);
const RESOLVABLE_DEPLOYMENT = DEPLOYMENT_RECORDS.filter(
  (record) => record.expected_exit !== 2,
);

const BASE_INPUTS: DiscoveryRoutingInputs = {
  invocationKind: "discovery",
  skillId: "inventory-legacy-system",
  executionContext: "standalone",
  languages: [],
  productionFileCount: 0,
  testFileCount: 0,
  crossCutting: false,
  rootPersona: null,
};

describe("shared routing corpus parity", () => {
  it("binds the frozen corpus population", () => {
    expect(TOPOLOGY_RECORDS).toHaveLength(43);
    expect(DEPLOYMENT_RECORDS).toHaveLength(33);
    expect(
      TOPOLOGY_RECORDS.filter((record) =>
        record.id.startsWith("topo-discovery-"),
      ),
    ).toHaveLength(23);
    expect(
      DEPLOYMENT_RECORDS.filter((record) =>
        record.id.startsWith("dep-discovery-"),
      ),
    ).toHaveLength(24);
  });

  it.each(RESOLVABLE_TOPOLOGY.map((record) => [record.id, record] as const))(
    "topology %s matches the Python CLI corpus",
    (_id, record) => {
      // Arrange
      const parsed = parseTopologyArgv(record.argv);
      const invoke = () =>
        resolveCodexTopology(
          parsed.languages,
          parsed.productionFileCount,
          parsed.testFileCount,
          parsed.executionContext,
          {
            crossCutting: parsed.crossCutting,
            rootPersona: parsed.rootPersona,
            invocationKind: parsed.invocationKind,
            skillId: parsed.skillId,
          },
        );

      // Act / Assert: exit 0 compares the rendered receipt, exit 1 the message.
      if (record.expected_exit === 0) {
        expect(renderSorted(invoke())).toBe(record.expected_stdout);
      } else {
        expect(invoke).toThrow(record.expected_stderr_contains ?? "");
      }
    },
  );

  it.each(RESOLVABLE_DEPLOYMENT.map((record) => [record.id, record] as const))(
    "deployment %s matches the Python CLI corpus",
    (_id, record) => {
      // Arrange
      const invoke = () =>
        resolveCodexDeployment(
          optionValue(record.argv, "--logical-agent"),
          optionValue(record.argv, "--complexity-band"),
          optionValue(record.argv, "--execution-context"),
          optionValue(record.argv, "--orchestration-complexity-ceiling"),
        );

      // Act / Assert
      if (record.expected_exit === 0) {
        expect(renderSorted(invoke())).toBe(record.expected_stdout);
      } else {
        expect(invoke).toThrow(record.expected_stderr_contains ?? "");
      }
    },
  );

  it("treats the parser-level corpus rows as selector rejections", () => {
    // Arrange
    const parserRows = TOPOLOGY_RECORDS.filter(
      (record) => record.expected_exit === 2,
    );
    const invalidKind = parserRows.find(
      (record) => record.id === "topo-invalid-invocation-kind",
    );

    // Act / Assert
    expect(invalidKind).toBeDefined();
    expect(() =>
      validateInvocationKind(
        optionValue(invalidKind?.argv ?? [], "--invocation-kind"),
      ),
    ).toThrow("invocation_kind must be ordinary or discovery.");
  });
});

describe("discovery operation table", () => {
  it("matches the canonical discovery_operations configuration", () => {
    // Arrange
    const configured = (
      JSON.parse(fs.readFileSync(CONFIG_PATH, "utf8")) as {
        discovery_operations: Record<string, unknown>;
      }
    ).discovery_operations;

    // Assert: same keys in the same order and equal rows.
    expect(Object.keys(configured)).toEqual(Object.keys(DISCOVERY_OPERATIONS));
    for (const [skillId, operation] of Object.entries(DISCOVERY_OPERATIONS)) {
      expect(configured[skillId]).toEqual({
        logical_agent: operation.logical_agent,
        output_contract_version: operation.output_contract_version,
        permissible_artifact_kinds: [...operation.permissible_artifact_kinds],
        gate_mode: operation.gate_mode,
      });
    }
  });

  it("routes every skill to one of the four discovery families", () => {
    const roles = new Set(
      Object.values(DISCOVERY_OPERATIONS).map((row) => row.logical_agent),
    );
    expect([...roles].sort()).toEqual(
      [...DISCOVERY_GENERATED_AGENT_FAMILIES].sort(),
    );
  });
});

describe("resolveCodexDiscoveryTopology guards", () => {
  it("returns null for an ordinary request without a skill", () => {
    expect(
      resolveCodexDiscoveryTopology({
        ...BASE_INPUTS,
        invocationKind: "ordinary",
        skillId: undefined,
      }),
    ).toBeNull();
    expect(
      resolveCodexDiscoveryTopology({
        ...BASE_INPUTS,
        invocationKind: "ordinary",
        skillId: null,
      }),
    ).toBeNull();
  });

  it.each([null, undefined, 7, true, ["discovery"], "Discovery", "", "agent"])(
    "rejects invocation kind %p without coercion",
    (value) => {
      expect(() =>
        resolveCodexDiscoveryTopology({
          ...BASE_INPUTS,
          invocationKind: value,
        }),
      ).toThrow("invocation_kind must be ordinary or discovery.");
    },
  );

  it.each([
    null,
    undefined,
    7,
    false,
    ["inventory-legacy-system"],
    "Inventory-legacy-system",
    "",
    "discovery-repo-inventory",
    "inventory-legacy-system ",
    "toString",
  ])("rejects noncanonical skill %p", (value) => {
    expect(() =>
      resolveCodexDiscoveryTopology({ ...BASE_INPUTS, skillId: value }),
    ).toThrow("Discovery invocations require a supported skill_id.");
  });

  it("fires the guards in the shared precedence order", () => {
    // Arrange: every forbidden field at once, repaired one guard at a time.
    const request: {
      -readonly [
        Key in keyof DiscoveryRoutingInputs
      ]: DiscoveryRoutingInputs[Key];
    } = {
      ...BASE_INPUTS,
      skillId: "unknown",
      languages: ["python"],
      productionFileCount: 1,
      testFileCount: 1,
      crossCutting: true,
      rootPersona: "epic-planner",
    };
    const ordered: ReadonlyArray<
      readonly [keyof DiscoveryRoutingInputs, unknown, string]
    > = [
      ["rootPersona", null, "do not accept root_persona"],
      ["productionFileCount", 0, "require production_file_count=0"],
      ["testFileCount", 0, "require test_file_count=0"],
      ["languages", [], "do not accept languages"],
      ["crossCutting", false, "do not accept cross_cutting"],
      ["skillId", "inventory-legacy-system", "require a supported skill_id"],
    ];

    // Act / Assert
    for (const [field, valid, message] of ordered) {
      expect(() => resolveCodexDiscoveryTopology({ ...request })).toThrow(
        message,
      );
      (request as Record<string, unknown>)[field] = valid;
    }
    expect(resolveCodexDiscoveryTopology(request)?.route).toBe("discovery");
  });

  it("returns fresh kind arrays so caller mutation cannot leak", () => {
    // Arrange
    const first = resolveCodexDiscoveryTopology(BASE_INPUTS);
    (first?.permissible_artifact_kinds as string[]).push("forbidden-write");

    // Act
    const second = resolveCodexDiscoveryTopology(BASE_INPUTS);

    // Assert
    expect(second?.permissible_artifact_kinds).not.toContain("forbidden-write");
    expect(
      DISCOVERY_OPERATIONS["inventory-legacy-system"]
        ?.permissible_artifact_kinds,
    ).not.toContain("forbidden-write");
  });
});
