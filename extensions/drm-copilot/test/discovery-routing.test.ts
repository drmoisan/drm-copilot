/**
 * Prove discovery routing binds the existing topology and deployment resolvers.
 *
 * Every one of the nine skills must route to its fixed role with the exact
 * model/effort the Codex deployment table assigns, carry zero write scope, and
 * accept only outputs inside the skill's permissible artifact kinds. Shapes
 * are checked against the committed v2 schemas read from the repository.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { DISCOVERY_OPERATIONS } from "../src/lib/validate/codex-discovery-routing";
import { resolveCodexTopology } from "../src/lib/validate/codex-topology-resolver";
import { sha256Hex } from "../src/discovery-authority-paths";
import { canonicalJson } from "../src/discovery-authorization-record";
import {
  buildInvocationDeployment,
  buildRequiredOutputManifest,
  DISCOVERY_ROLES,
  DISCOVERY_SKILL_IDS,
  DiscoveryRoutingError,
  type ExpectedOutput,
  OUTPUT_KINDS,
  resolveDiscoveryRouting,
  scopeDigest,
  SKILL_PRIMARY_OPERATIONS,
  validateExpectedOutputs,
  validateScope,
} from "../src/discovery-routing";

const SCHEMAS = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "schemas",
  "discovery",
  "v2",
);

interface SchemaNode {
  readonly required?: string[];
  readonly enum?: string[];
  readonly properties?: Record<string, SchemaNode>;
}

interface SchemaDocument {
  readonly required: string[];
  readonly $defs: Record<string, SchemaNode>;
}

function schema(name: string): SchemaDocument {
  return JSON.parse(
    fs.readFileSync(path.join(SCHEMAS, `${name}.schema.json`), "utf8"),
  ) as SchemaDocument;
}

const WORKSPACE = {
  workspace_root: "C:/Users/Example/Repos/Workspace",
  workspace_sha256: "a".repeat(64),
  profile_path: "docs/migration/discovery/domain-profile.yaml",
  profile_sha256: "b".repeat(64),
};

function firstOutput(skillId: string): ExpectedOutput {
  const kind = DISCOVERY_OPERATIONS[skillId]!.permissible_artifact_kinds[0]!;
  return {
    artifact_kind: kind,
    id: `${kind.replace(/[^a-z0-9]/gu, "-")}-one`,
    path: `docs/migration/discovery/${kind}.yaml`,
    format: "yaml",
    expected_sha256: null,
  };
}

function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (error instanceof DiscoveryRoutingError) {
      return error.code;
    }
    throw error;
  }
  return "NO_ERROR";
}

describe("resolveDiscoveryRouting", () => {
  it("exposes the nine skills, four roles and a primary operation per skill", () => {
    const requestSchema = schema("service-request");
    const inputs = requestSchema.$defs["inputs"]!.properties!;
    expect([...DISCOVERY_SKILL_IDS].sort()).toEqual(
      [...inputs["skill_id"]!.enum!].sort(),
    );
    expect(DISCOVERY_ROLES).toHaveLength(4);
    const operations = requestSchema.$defs["operation"]!.enum!;
    for (const skillId of DISCOVERY_SKILL_IDS) {
      expect(operations).toContain(SKILL_PRIMARY_OPERATIONS[skillId]);
    }
  });

  it.each(DISCOVERY_SKILL_IDS.map((skillId) => [skillId]))(
    "routes %s through the fixed specialist topology and C2 deployment",
    (skillId) => {
      const decision = resolveDiscoveryRouting({
        skillId,
        executionContext: "standalone",
        complexity: "C2",
      });
      const expectedTopology = resolveCodexTopology([], 0, 0, "standalone", {
        invocationKind: "discovery",
        skillId,
      });
      expect(decision.topology).toEqual(expectedTopology);
      expect(decision.role).toBe(DISCOVERY_OPERATIONS[skillId]!.logical_agent);
      expect(decision.deployment.deployment_agent).toBe(`${decision.role}-c2`);
      expect(decision.deployment.model).toBe("gpt-6.1-sol");
      expect(decision.deployment.model_reasoning_effort).toBe("medium");
      expect(decision.gateMode).toBe("agent-output");
      expect(decision.topology.production_file_count).toBe(0);
      expect(decision.topology.max_production_files).toBe(0);
      expect(decision.topologyReceiptRef).toBe(
        `topology-${sha256Hex(canonicalJson(decision.topology))}`,
      );
      expect(decision.modelReceiptRef).toBe(
        `model-${sha256Hex(canonicalJson(decision.deployment))}`,
      );
    },
  );

  it.each([
    ["C1", "standalone", "C1", "gpt-6-luna", "low", "c1"],
    ["C2", "standalone", "C2", "gpt-6.1-sol", "medium", "c2"],
    ["C3", "standalone", "C3", "gpt-6.1-sol", "high", "c3"],
    ["C3", "epic_execution_child", "C3", "gpt-6-astra", "high", "c3-elevated"],
    ["C3", "standalone", "C4", "gpt-6-astra", "high", "c3-elevated"],
    ["C4", "standalone", "C4", "gpt-6-astra", "max", "c4"],
  ])(
    "assigns the exact model and effort for %s in %s under ceiling %s",
    (complexity, context, ceiling, model, effort, suffix) => {
      const decision = resolveDiscoveryRouting({
        skillId: "inventory-legacy-system",
        executionContext: context,
        complexity,
        orchestrationComplexityCeiling: ceiling,
      });
      expect(decision.deployment.model).toBe(model);
      expect(decision.deployment.model_reasoning_effort).toBe(effort);
      expect(decision.deployment.deployment_agent).toBe(
        `legacy-parity-analyst-${suffix}`,
      );
      expect(decision.deployment.execution_context).toBe(context);
    },
  );

  it("refuses an unavailable routed model instead of falling back", () => {
    expect(
      codeOf(() =>
        resolveDiscoveryRouting(
          {
            skillId: "inventory-legacy-system",
            executionContext: "standalone",
            complexity: "C2",
          },
          new Set(["gpt-6-luna"]),
        ),
      ),
    ).toBe("ROUTING_MODEL_UNAVAILABLE");
  });

  it.each([
    ["unknown skill", { skillId: "run-shell" }, "ROUTING_SKILL_UNKNOWN"],
    ["non-string skill", { skillId: 7 }, "ROUTING_SKILL_UNKNOWN"],
    ["production write", { productionWriteCount: 1 }, "ROUTING_WRITE_COUNT"],
    ["test write", { testWriteCount: 2 }, "ROUTING_WRITE_COUNT"],
    [
      "string write count",
      { productionWriteCount: "0" },
      "ROUTING_WRITE_COUNT",
    ],
    [
      "bad context",
      { executionContext: "epic_root" },
      "ROUTING_CONTEXT_INVALID",
    ],
    ["bad complexity", { complexity: "C5" }, "ROUTING_COMPLEXITY_INVALID"],
    [
      "ceiling below complexity",
      { complexity: "C3", orchestrationComplexityCeiling: "C2" },
      "ROUTING_COMPLEXITY_INVALID",
    ],
    [
      "bad ceiling",
      { orchestrationComplexityCeiling: "max" },
      "ROUTING_COMPLEXITY_INVALID",
    ],
  ])("refuses %s", (_label, overrides, code) => {
    expect(
      codeOf(() =>
        resolveDiscoveryRouting({
          skillId: "inventory-legacy-system",
          executionContext: "standalone",
          complexity: "C2",
          ...overrides,
        }),
      ),
    ).toBe(code);
  });
});

describe("validateScope and scopeDigest", () => {
  it("accepts unique identifiers and relative paths and digests them canonically", () => {
    const scope = validateScope(
      ["orders.export", "billing"],
      ["src/Orders", "docs/plan.md"],
    );
    expect(scope).toEqual({
      selectedIds: ["orders.export", "billing"],
      paths: ["src/Orders", "docs/plan.md"],
    });
    expect(scopeDigest(scope)).toBe(
      sha256Hex(
        canonicalJson({ paths: scope.paths, selected_ids: scope.selectedIds }),
      ),
    );
    expect(scopeDigest(validateScope([], []))).toBe(
      sha256Hex(canonicalJson({ paths: [], selected_ids: [] })),
    );
  });

  it.each([
    ["non-array ids", "orders", []],
    ["non-array paths", [], "src"],
    ["uppercase id", ["Orders"], []],
    ["numeric id", [1], []],
    ["duplicate ids", ["a", "a"], []],
    ["absolute path", [], ["/etc/passwd"]],
    ["parent path", [], ["../x"]],
    ["non-string path", [], [3]],
    ["duplicate paths", [], ["src", "src"]],
  ])("refuses %s", (_label, ids, paths) => {
    expect(codeOf(() => validateScope(ids, paths))).toBe(
      "ROUTING_SCOPE_INVALID",
    );
  });
});

describe("validateExpectedOutputs", () => {
  it.each(DISCOVERY_SKILL_IDS.map((skillId) => [skillId]))(
    "accepts every permissible kind of %s and nothing else",
    (skillId) => {
      const kinds = DISCOVERY_OPERATIONS[skillId]!.permissible_artifact_kinds;
      const outputs = kinds.map((kind, index) => ({
        artifact_kind: kind,
        id: `output-${String(index)}`,
        path: `out/${String(index)}.json`,
        format: "json",
        expected_sha256: index === 0 ? null : "c".repeat(64),
      }));
      expect(validateExpectedOutputs(skillId, outputs)).toEqual(outputs);
      const forbidden = OUTPUT_KINDS.find((kind) => !kinds.includes(kind))!;
      expect(
        codeOf(() =>
          validateExpectedOutputs(skillId, [
            { ...firstOutput(skillId), artifact_kind: forbidden },
          ]),
        ),
      ).toBe("ROUTING_OUTPUT_KIND_FORBIDDEN");
    },
  );

  it("pins the output kind enum to the schema", () => {
    const defs = schema("required-output-manifest").$defs;
    expect([...OUTPUT_KINDS]).toEqual(defs["output-kind"]!.enum);
  });

  it.each([
    ["empty", []],
    ["not an array", { artifact_kind: "coverage-ledger" }],
    [
      "extra key",
      [{ ...firstOutput("inventory-legacy-system"), destination: "x" }],
    ],
    [
      "unknown kind",
      [{ ...firstOutput("inventory-legacy-system"), artifact_kind: "shell" }],
    ],
    ["bad id", [{ ...firstOutput("inventory-legacy-system"), id: "Bad Id" }]],
    [
      "bad path",
      [{ ...firstOutput("inventory-legacy-system"), path: "../x.yaml" }],
    ],
    [
      "bad format",
      [{ ...firstOutput("inventory-legacy-system"), format: "xml" }],
    ],
    [
      "bad digest",
      [{ ...firstOutput("inventory-legacy-system"), expected_sha256: "abc" }],
    ],
    [
      "duplicate id",
      [
        firstOutput("inventory-legacy-system"),
        { ...firstOutput("inventory-legacy-system"), path: "other.yaml" },
      ],
    ],
    [
      "duplicate path",
      [
        firstOutput("inventory-legacy-system"),
        { ...firstOutput("inventory-legacy-system"), id: "other" },
      ],
    ],
  ])("refuses %s", (_label, value) => {
    expect(
      codeOf(() => validateExpectedOutputs("inventory-legacy-system", value)),
    ).toBe("ROUTING_OUTPUT_INVALID");
  });

  it("refuses an unknown skill", () => {
    expect(codeOf(() => validateExpectedOutputs("other", []))).toBe(
      "ROUTING_SKILL_UNKNOWN",
    );
  });
});

describe("manifest and deployment shapes", () => {
  it("builds a required-output-manifest whose digest covers every other field", () => {
    const outputs = [firstOutput("extract-feature-contract")];
    const manifest = buildRequiredOutputManifest({
      invocationId: "invocation-abc123",
      workspace: WORKSPACE,
      role: "legacy-parity-analyst",
      outputs,
    });
    const { required } = schema("required-output-manifest");
    expect(Object.keys(manifest).sort()).toEqual([...required].sort());
    const { manifest_sha256: digest, ...body } = manifest;
    expect(digest).toBe(sha256Hex(canonicalJson(body)));
    expect(manifest.id).toMatch(/^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$/u);
    expect(manifest.outputs).toEqual(outputs);
    expect(manifest.outputs).not.toBe(outputs);
  });

  it.each(
    DISCOVERY_SKILL_IDS.flatMap((skillId) =>
      ["C1", "C2", "C3", "C4"].map((band) => [skillId, band]),
    ),
  )("renders a schema-shaped deployment for %s at %s", (skillId, band) => {
    const decision = resolveDiscoveryRouting({
      skillId,
      executionContext: "epic_preparation_child",
      complexity: band,
      orchestrationComplexityCeiling: "C4",
    });
    const deployment = buildInvocationDeployment(decision, "codex", WORKSPACE);
    const definition = schema("discovery-invocation").$defs["deployment"]!;
    expect(Object.keys(deployment).sort()).toEqual(
      [...definition.required!].sort(),
    );
    expect(deployment.agent_name).toMatch(
      /^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$/u,
    );
    expect(definition.properties!["reasoning_effort"]!.enum).toContain(
      deployment.reasoning_effort,
    );
    expect(deployment.profile_sha256).toBe(WORKSPACE.profile_sha256);
    expect(deployment.complexity).toBe(band);
  });
});
