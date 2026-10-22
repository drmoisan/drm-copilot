import { describe, expect, it } from "@jest/globals";

import {
  DISCOVERY_MODES,
  DISCOVERY_OPERATIONS,
  DiscoveryOperationError,
  DiscoveryTransportError,
  parseDiscoveryResult,
  toExecutionResult,
} from "../src/discovery-result";
import {
  buildBlockingResult,
  buildServiceResult,
  SHA_A,
} from "./discovery-test-helpers";

const OK_CONTEXT = { exitCode: 0, stderr: "" };

function parse(
  document: unknown,
  exitCode = 0,
): ReturnType<typeof parseDiscoveryResult> {
  return parseDiscoveryResult(JSON.stringify(document), {
    exitCode,
    stderr: "",
  });
}

function expectTransportError(
  invoke: () => unknown,
  code: DiscoveryTransportError["code"],
): DiscoveryTransportError {
  let caught: unknown;
  try {
    invoke();
  } catch (error: unknown) {
    caught = error;
  }
  expect(caught).toBeInstanceOf(DiscoveryTransportError);
  const transportError = caught as DiscoveryTransportError;
  expect(transportError.code).toBe(code);
  return transportError;
}

describe("parseDiscoveryResult", () => {
  it("accepts a complete valid success envelope and preserves its fields", () => {
    // Arrange
    const result = buildServiceResult({
      artifacts: [
        {
          path: "discovery/reports/coverage.json",
          kind: "coverage-report",
          status: "created",
          sha256: SHA_A,
        },
      ],
    });

    // Act
    const parsed = parse(result);

    // Assert
    expect(parsed).toEqual(result);
    expect(parsed.runtime?.package_version).toBe("2.0.0");
  });

  it("accepts a valid blocking envelope whose exit code matches the process", () => {
    const parsed = parse(buildBlockingResult(), 1);

    expect(parsed.ok).toBe(false);
    expect(parsed.exit_code).toBe(1);
    expect(parsed.findings[0]?.code).toBe("COVERAGE_INCOMPLETE");
  });

  it("accepts the fixed pre-execution failure envelope with null context", () => {
    const parsed = parse(
      buildBlockingResult({
        operation: null,
        mode: null,
        exit_code: 2,
        input_manifest: null,
        runtime: null,
      }),
      2,
    );

    expect(parsed.operation).toBeNull();
    expect(parsed.runtime).toBeNull();
  });

  it.each([
    ["empty stdout", "", "DISCOVERY_RESULT_EMPTY"],
    ["whitespace stdout", "  \n", "DISCOVERY_RESULT_EMPTY"],
    [
      "truncated JSON",
      '{"result_version":"2.0.0","ok":tr',
      "DISCOVERY_RESULT_MALFORMED",
    ],
    ["two documents", "{}\n{}", "DISCOVERY_RESULT_MALFORMED"],
    ["a sentence", "ok: wrote discovery/x.json", "DISCOVERY_RESULT_MALFORMED"],
    ["an array", "[]", "DISCOVERY_RESULT_MALFORMED"],
  ] as const)("rejects %s as a transport error", (_label, stdout, code) => {
    const error = expectTransportError(
      () => parseDiscoveryResult(stdout, { exitCode: 0, stderr: "ctx" }),
      code,
    );
    expect(error.stderr).toBe("ctx");
    expect(error.exitCode).toBe(0);
  });

  it("rejects an unsupported result version", () => {
    expectTransportError(
      () => parse({ ...buildServiceResult(), result_version: "3.0.0" }),
      "DISCOVERY_RESULT_VERSION_UNSUPPORTED",
    );
  });

  it.each([
    ["operation", { operation: "run-anything" }],
    ["mode", { mode: "complete" }],
    ["ok type", { ok: "true" }],
    ["exit code range", { exit_code: 4 }],
    ["findings type", { findings: {} }],
    ["artifacts type", { artifacts: "none" }],
    ["summary message", { summary: { counts: [] } }],
    [
      "summary count",
      {
        summary: {
          message: "x",
          counts: [{ name: "n", value: -1 }],
          validation_result: null,
          receipt_ref: null,
          invocation_ref: null,
        },
      },
    ],
    [
      "finding shape",
      { findings: [{ code: "X", severity: "error", message: "m" }] },
    ],
    [
      "artifact digest",
      {
        artifacts: [
          { path: "a", kind: "k", status: "created", sha256: "not-a-digest" },
        ],
      },
    ],
    ["runtime shape", { runtime: { package_version: "2.0.0" } }],
    ["input manifest type", { input_manifest: "manifest" }],
    ["ok/exit disagreement", { ok: true, exit_code: 1 }],
  ])("rejects an invalid %s as malformed", (_label, overrides) => {
    expectTransportError(
      () =>
        parseDiscoveryResult(
          JSON.stringify({ ...buildServiceResult(), ...overrides }),
          {
            exitCode: (overrides as { exit_code?: number }).exit_code ?? 0,
            stderr: "",
          },
        ),
      "DISCOVERY_RESULT_MALFORMED",
    );
  });

  it("rejects a missing envelope field", () => {
    const withoutRuntime: Record<string, unknown> = { ...buildServiceResult() };
    delete withoutRuntime["runtime"];
    expectTransportError(
      () => parse(withoutRuntime),
      "DISCOVERY_RESULT_MALFORMED",
    );
  });

  it("rejects a result whose exit code disagrees with the process exit", () => {
    const error = expectTransportError(
      () => parse(buildServiceResult(), 1),
      "DISCOVERY_RESULT_EXIT_MISMATCH",
    );
    expect(error.message).toContain("reports exit 0");
    expect(error.message).toContain("exited with 1");
  });

  it("rejects an incompatible installed runtime version", () => {
    const result = buildServiceResult();
    const error = expectTransportError(
      () =>
        parse({
          ...result,
          runtime: { ...result.runtime, package_version: "2.1.0" },
        }),
      "DISCOVERY_RUNTIME_INCOMPATIBLE",
    );
    expect(error.message).toContain("2.1.0");
    expect(error.message).toContain("install the matching wheel");
  });

  it("exports the closed operation and mode vocabularies", () => {
    expect(DISCOVERY_OPERATIONS).toHaveLength(30);
    expect(DISCOVERY_OPERATIONS).toContain("prepare-agent");
    expect(DISCOVERY_MODES).toEqual([
      "structural",
      "agent-output",
      "discovery-complete",
      "parity-complete",
      "planning",
    ]);
  });
});

describe("toExecutionResult", () => {
  it("maps a successful result to the host result with artifact paths", () => {
    const result = buildServiceResult({
      operation: "inventory",
      artifacts: [
        {
          path: "discovery/inventory.json",
          kind: "inventory-snapshot",
          status: "created",
          sha256: SHA_A,
        },
      ],
    });

    const execution = toExecutionResult(
      result,
      "run_discovery_repo_inventory",
      "C:/workspace",
    );

    expect(execution).toEqual({
      tool: "run_discovery_repo_inventory",
      workspaceRoot: "C:/workspace",
      summary: "Validation passed.",
      artifacts: ["discovery/inventory.json"],
      discovery: result,
    });
  });

  it("omits the artifacts list when the result has none", () => {
    const execution = toExecutionResult(
      buildServiceResult(),
      "validate_discovery_artifacts",
      "C:/workspace",
    );

    expect(execution.artifacts).toBeUndefined();
    expect(execution.discovery?.ok).toBe(true);
  });

  it("raises a typed operation error carrying a blocking result", () => {
    const result = buildBlockingResult({ operation: "validate-all" });

    let caught: unknown;
    try {
      toExecutionResult(result, "validate_discovery_artifacts", "C:/workspace");
    } catch (error: unknown) {
      caught = error;
    }

    expect(caught).toBeInstanceOf(DiscoveryOperationError);
    const operationError = caught as DiscoveryOperationError;
    expect(operationError.result).toBe(result);
    expect(operationError.message).toBe(
      "Discovery validate-all failed with exit 1: COVERAGE_INCOMPLETE: Component alpha has no disposition.",
    );
  });

  it("describes a failure without an error finding by its exit code only", () => {
    const result = buildBlockingResult({
      operation: null,
      mode: null,
      exit_code: 3,
      input_manifest: null,
      runtime: null,
      findings: [
        {
          code: "SERVICE_FAILURE",
          severity: "error",
          artifact_path: null,
          pointer: "/runtime",
          related_ids: [],
          related_paths: [],
          message: "The discovery request could not be completed.",
          next_action: "Repair the runtime.",
        },
      ],
    });
    const parsed = parseDiscoveryResult(JSON.stringify(result), {
      exitCode: 3,
      stderr: "",
    });

    expect(() =>
      toExecutionResult(parsed, "run_discovery_report", "C:/workspace"),
    ).toThrow("Discovery request failed with exit 3: SERVICE_FAILURE");
    expect(OK_CONTEXT.exitCode).toBe(0);
  });
});
