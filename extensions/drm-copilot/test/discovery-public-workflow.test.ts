/**
 * Host transport proof for the public discovery workflows (issue #980, P11-T1).
 *
 * The Python suites drive the workflows through the installed service; this suite
 * proves the TypeScript gateway client carries the same authority: every request
 * fixture under `tests/fixtures/discovery_workflow/requests` is exactly what
 * `buildDiscoveryServiceRequest` emits for the same specification, every result
 * fixture under `results` maps to the same exit code and ok/error disposition
 * through `parseDiscoveryResult` and `toExecutionResult`, the forged pass is
 * refused as malformed, and an exit disagreement between the envelope and the
 * process is a transport error. Fixtures are committed files; no process runs.
 */

import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  DiscoveryOperationError,
  DiscoveryTransportError,
  parseDiscoveryResult,
  toExecutionResult,
} from "../src/discovery-result";
import {
  buildDiscoveryServiceRequest,
  invokeDiscoveryRuntime,
  type DiscoveryRequestSpec,
} from "../src/discovery-runtime";
import type {
  DiscoveryMode,
  DiscoveryOperation,
  DiscoveryOutputFormat,
  DiscoveryRequestInputs,
  DiscoveryServiceResult,
} from "../src/discovery-service-types";
import { FAKE_INTERPRETER, FakeLauncher } from "./discovery-test-helpers";

const FIXTURES = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "discovery_workflow",
);
const WORKSPACE_ROOT = "C:/workspace";
const output = { appendLine: (): void => undefined };

interface RequestFixture {
  readonly operation: DiscoveryOperation;
  readonly mode: DiscoveryMode;
  readonly workspace_root: string;
  readonly profile_path: string | null;
  readonly dry_run: boolean;
  readonly write: boolean;
  readonly format: DiscoveryOutputFormat;
  readonly inputs: DiscoveryRequestInputs;
  readonly invocation_ref: string | null;
  readonly authorization_ref: string | null;
}

/** Read and parse one committed JSON fixture. */
function fixture<T>(folder: string, name: string): T {
  return JSON.parse(
    fs.readFileSync(path.join(FIXTURES, folder, name), "utf8"),
  ) as T;
}

/** The sorted JSON fixture names under a folder. */
function names(folder: string): string[] {
  return fs
    .readdirSync(path.join(FIXTURES, folder))
    .filter((name) => name.endsWith(".json"))
    .sort();
}

/** The request specification a host would pass for a fixture. */
function specFor(request: RequestFixture): DiscoveryRequestSpec {
  return {
    operation: request.operation,
    mode: request.mode,
    workspaceRoot: request.workspace_root,
    inputs: request.inputs,
    dryRun: request.dry_run,
    write: request.write,
    format: request.format,
  };
}

describe("discovery public workflow host transport", () => {
  it("emits exactly the committed request documents the Python authority accepts", () => {
    const requestNames = names("requests");
    expect(requestNames.length).toBeGreaterThan(0);
    // Every fixture is the host-built request minus its content-derived identity.
    for (const name of requestNames) {
      const request = fixture<RequestFixture>("requests", name);
      const built = buildDiscoveryServiceRequest(specFor(request));
      const { id: builtId, request_id: builtRequestId, ...builtRest } = built;
      const {
        id: fixtureId,
        request_id: fixtureRequestId,
        ...fixtureRest
      } = request as RequestFixture & { id: string; request_id: string };
      expect(builtRest).toEqual(fixtureRest);
      expect(builtId).toBe(builtRequestId);
      expect(fixtureId).toBe(fixtureRequestId);
    }
  });

  it.each([
    ["structural-pass.json", 0, true],
    ["completion-fail.json", 1, false],
    ["usage-rejection.json", 2, false],
    ["runtime-unavailable.json", 3, false],
  ] as const)(
    "maps %s to exit %i with ok=%s and never to a false execution success",
    (name, exitCode, ok) => {
      const document = fixture<DiscoveryServiceResult>("results", name);
      const parsed = parseDiscoveryResult(JSON.stringify(document), {
        exitCode,
        stderr: "",
      });
      expect(parsed.exit_code).toBe(exitCode);
      expect(parsed.ok).toBe(ok);
      // The execution mapping succeeds only for a genuinely passing result.
      if (ok) {
        const execution = toExecutionResult(
          parsed,
          "validate_discovery_artifacts",
          WORKSPACE_ROOT,
        );
        expect(execution.discovery).toBeDefined();
        expect(execution.discovery?.exit_code).toBe(0);
      } else {
        expect(() =>
          toExecutionResult(
            parsed,
            "validate_discovery_artifacts",
            WORKSPACE_ROOT,
          ),
        ).toThrow(DiscoveryOperationError);
        expect(parsed.findings.some((item) => item.severity === "error")).toBe(
          true,
        );
      }
    },
  );

  it("refuses the forged pass whose ok and exit_code disagree", () => {
    const document = fixture<DiscoveryServiceResult>(
      "results",
      "false-pass.json",
    );
    let caught: unknown;
    try {
      parseDiscoveryResult(JSON.stringify(document), {
        exitCode: 1,
        stderr: "",
      });
    } catch (error: unknown) {
      caught = error;
    }
    expect(caught).toBeInstanceOf(DiscoveryTransportError);
    expect((caught as DiscoveryTransportError).code).toBe(
      "DISCOVERY_RESULT_MALFORMED",
    );
  });

  it("treats an envelope that disagrees with the process exit as a transport error", () => {
    const document = fixture<DiscoveryServiceResult>(
      "results",
      "completion-fail.json",
    );
    let caught: unknown;
    try {
      parseDiscoveryResult(JSON.stringify(document), {
        exitCode: 0,
        stderr: "",
      });
    } catch (error: unknown) {
      caught = error;
    }
    expect(caught).toBeInstanceOf(DiscoveryTransportError);
    expect((caught as DiscoveryTransportError).code).toBe(
      "DISCOVERY_RESULT_EXIT_MISMATCH",
    );
  });

  it("launches the installed gateway with the fixture request and returns the fixture result", async () => {
    const request = fixture<RequestFixture>(
      "requests",
      "validate-discovery-complete.json",
    );
    const document = fixture<DiscoveryServiceResult>(
      "results",
      "completion-fail.json",
    );
    const launcher = new FakeLauncher({
      exitCode: document.exit_code,
      stdout: JSON.stringify(document),
      stderr: "",
    });
    const result = await invokeDiscoveryRuntime(
      output,
      { invocationId: "workflow-proof", request: specFor(request) },
      { launcher, detectInterpreter: () => FAKE_INTERPRETER },
    );
    // The host wrote exactly one canonical request and received the honest failure.
    const launched = launcher.single();
    expect(launched.executable).toBe(FAKE_INTERPRETER.executable);
    expect(launched.args).toEqual([
      "-I",
      "-m",
      "drm_copilot_discovery.gateway",
      "--workspace-root",
      request.workspace_root,
      "--principal",
      "local-user",
    ]);
    const written = launcher.request();
    expect(written["operation"]).toBe("validate-all");
    expect(written["mode"]).toBe("discovery-complete");
    expect(result.ok).toBe(false);
    expect(result.exit_code).toBe(1);
    expect(result.summary.validation_result).toBe("fail");
  });
});
