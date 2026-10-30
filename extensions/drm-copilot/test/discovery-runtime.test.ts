import { describe, expect, it } from "@jest/globals";

import { DiscoveryTransportError } from "../src/discovery-result";
import {
  buildDiscoveryServiceRequest,
  DISCOVERY_GATEWAY_MODULE,
  DISCOVERY_WHEEL_FILE_NAME,
  invokeDiscoveryRuntime,
  type DiscoveryRuntimeInvocation,
} from "../src/discovery-runtime";
import {
  buildBlockingResult,
  buildServiceResult,
  FAKE_INTERPRETER,
  FakeLauncher,
  successOutcome,
} from "./discovery-test-helpers";

const WORKSPACE_ROOT = "C:/workspace";
const output = { appendLine: (): void => undefined };

function invocation(
  overrides: Partial<DiscoveryRuntimeInvocation> = {},
): DiscoveryRuntimeInvocation {
  return {
    invocationId: "test-invocation",
    request: {
      operation: "validate-profile",
      workspaceRoot: WORKSPACE_ROOT,
      inputs: { input_path: "discovery/profile.yaml" },
    },
    ...overrides,
  };
}

async function expectTransportError(
  invoke: () => Promise<unknown>,
  code: DiscoveryTransportError["code"],
): Promise<DiscoveryTransportError> {
  let caught: unknown;
  try {
    await invoke();
  } catch (error: unknown) {
    caught = error;
  }
  expect(caught).toBeInstanceOf(DiscoveryTransportError);
  const transportError = caught as DiscoveryTransportError;
  expect(transportError.code).toBe(code);
  return transportError;
}

describe("buildDiscoveryServiceRequest", () => {
  it("composes the complete v2 service-request with defaults and a deterministic id", () => {
    // Act
    const first = buildDiscoveryServiceRequest({
      operation: "inventory",
      workspaceRoot: WORKSPACE_ROOT,
      inputs: { analyzer_ids: ["dotnet"] },
    });
    const second = buildDiscoveryServiceRequest({
      operation: "inventory",
      workspaceRoot: WORKSPACE_ROOT,
      inputs: { analyzer_ids: ["dotnet"] },
    });

    // Assert
    expect(first).toEqual({
      $schema: "urn:drm-copilot:discovery:2.0.0:service-request",
      schema_version: "2.0.0",
      artifact_kind: "service-request",
      id: first.id,
      request_id: first.id,
      operation: "inventory",
      mode: "structural",
      workspace_root: WORKSPACE_ROOT,
      profile_path: null,
      dry_run: false,
      write: false,
      format: "json",
      inputs: { analyzer_ids: ["dotnet"] },
      invocation_ref: null,
      authorization_ref: null,
    });
    expect(first.id).toMatch(/^host-[0-9a-f]{64}$/);
    expect(second.id).toBe(first.id);
  });

  it("changes the id when any pre-identity field changes", () => {
    const base = buildDiscoveryServiceRequest({
      operation: "coverage-report",
      workspaceRoot: WORKSPACE_ROOT,
    });
    const changed = buildDiscoveryServiceRequest({
      operation: "coverage-report",
      workspaceRoot: WORKSPACE_ROOT,
      write: true,
    });

    expect(changed.write).toBe(true);
    expect(changed.id).not.toBe(base.id);
  });

  it.each(["discovery", "./discovery", "", "workspace/sub"])(
    "rejects the non-absolute workspace root %p",
    (workspaceRoot) => {
      expect(() =>
        buildDiscoveryServiceRequest({
          operation: "doctor",
          workspaceRoot,
        }),
      ).toThrow("DISCOVERY_WORKSPACE_ROOT_INVALID");
    },
  );

  it.each(["C:\\work space", "/home/user/repo", "\\\\server\\share\\repo"])(
    "accepts the absolute workspace root %p",
    (workspaceRoot) => {
      expect(
        buildDiscoveryServiceRequest({ operation: "doctor", workspaceRoot })
          .workspace_root,
      ).toBe(workspaceRoot);
    },
  );
});

describe("invokeDiscoveryRuntime", () => {
  it("launches the fixed gateway module with isolated mode and the request on stdin", async () => {
    // Arrange
    const launcher = new FakeLauncher(successOutcome());

    // Act
    const result = await invokeDiscoveryRuntime(output, invocation(), {
      launcher,
      detectInterpreter: () => FAKE_INTERPRETER,
    });

    // Assert: no `-c`, no shell string, exact fixed argv, cwd is the workspace.
    const capture = launcher.single();
    expect(capture.executable).toBe(FAKE_INTERPRETER.executable);
    expect(capture.args).toEqual([
      "-I",
      "-m",
      DISCOVERY_GATEWAY_MODULE,
      "--workspace-root",
      WORKSPACE_ROOT,
      "--principal",
      "local-user",
    ]);
    expect(capture.cwd).toBe(WORKSPACE_ROOT);
    expect(launcher.request()).toMatchObject({
      $schema: "urn:drm-copilot:discovery:2.0.0:service-request",
      operation: "validate-profile",
      inputs: { input_path: "discovery/profile.yaml" },
    });
    expect(result.ok).toBe(true);
  });

  it("prefers the trusted configured interpreter over runtime detection", async () => {
    const launcher = new FakeLauncher(successOutcome());

    await invokeDiscoveryRuntime(
      output,
      invocation({ interpreter: "  D:/venv/Scripts/python.exe " }),
      {
        launcher,
        detectInterpreter: () => {
          throw new Error("detection must not run");
        },
      },
    );

    expect(launcher.single().executable).toBe("D:/venv/Scripts/python.exe");
  });

  it("forwards the trusted repository and author identity as fixed options", async () => {
    const launcher = new FakeLauncher(successOutcome());

    await invokeDiscoveryRuntime(
      output,
      invocation({
        principal: "local-user",
        repositoryId: "example/source",
        authorId: "dan",
      }),
      { launcher, detectInterpreter: () => FAKE_INTERPRETER },
    );

    expect(launcher.single().args.slice(-4)).toEqual([
      "--repository-id",
      "example/source",
      "--author-id",
      "dan",
    ]);
  });

  const HOST = {
    principal: "host" as const,
    authorId: "agent-alpha",
    sessionId: "session-alpha",
    hostName: "codex",
    agentRole: "legacy-parity-analyst",
  };

  it("forwards the complete trusted host identity in the fixed option order", async () => {
    const launcher = new FakeLauncher(successOutcome());

    await invokeDiscoveryRuntime(
      output,
      invocation({ ...HOST, repositoryId: "example/source" }),
      { launcher, detectInterpreter: () => FAKE_INTERPRETER },
    );

    expect(launcher.single().args).toEqual([
      "-I",
      "-m",
      DISCOVERY_GATEWAY_MODULE,
      "--workspace-root",
      WORKSPACE_ROOT,
      "--principal",
      "host",
      "--repository-id",
      "example/source",
      "--author-id",
      "agent-alpha",
      "--session-id",
      "session-alpha",
      "--host-name",
      "codex",
      "--agent-role",
      "legacy-parity-analyst",
    ]);
  });

  it.each([
    [
      "authorId",
      {
        principal: "host" as const,
        sessionId: "session-alpha",
        hostName: "codex",
        agentRole: "legacy-parity-analyst",
      },
    ],
    [
      "sessionId",
      {
        principal: "host" as const,
        authorId: "agent-alpha",
        hostName: "codex",
        agentRole: "legacy-parity-analyst",
      },
    ],
    [
      "hostName",
      {
        principal: "host" as const,
        authorId: "agent-alpha",
        sessionId: "session-alpha",
        agentRole: "legacy-parity-analyst",
      },
    ],
    [
      "agentRole",
      {
        principal: "host" as const,
        authorId: "agent-alpha",
        sessionId: "session-alpha",
        hostName: "codex",
      },
    ],
  ])(
    "refuses a host invocation without %s before launching",
    async (_missing, partial) => {
      const launcher = new FakeLauncher(successOutcome());

      const error = await expectTransportError(
        () =>
          invokeDiscoveryRuntime(output, invocation(partial), {
            launcher,
            detectInterpreter: () => FAKE_INTERPRETER,
          }),
        "DISCOVERY_HOST_IDENTITY_INCOMPLETE",
      );
      expect(error.message).toContain("--session-id");
      expect(launcher.captures).toHaveLength(0);
    },
  );

  it.each([
    ["sessionId", { sessionId: "session-alpha" }],
    ["hostName", { hostName: "codex" }],
    ["agentRole", { agentRole: "legacy-parity-analyst" }],
  ])(
    "refuses a local-user invocation that supplies %s before launching",
    async (_label, supplied) => {
      const launcher = new FakeLauncher(successOutcome());

      await expectTransportError(
        () =>
          invokeDiscoveryRuntime(
            output,
            invocation({
              principal: "local-user",
              authorId: "dan",
              ...supplied,
            }),
            { launcher, detectInterpreter: () => FAKE_INTERPRETER },
          ),
        "DISCOVERY_HOST_IDENTITY_INCOMPLETE",
      );
      expect(launcher.captures).toHaveLength(0);
    },
  );

  it("reports an unavailable interpreter with the install diagnostic", async () => {
    const error = await expectTransportError(
      () =>
        invokeDiscoveryRuntime(output, invocation(), {
          launcher: new FakeLauncher(successOutcome()),
          detectInterpreter: () => {
            throw new Error("Python runtime not found.");
          },
        }),
      "DISCOVERY_INTERPRETER_UNAVAILABLE",
    );
    expect(error.message).toContain("Python runtime not found.");
    expect(error.message).toContain(`pip install ${DISCOVERY_WHEEL_FILE_NAME}`);
  });

  it("reports a failed launch with the launcher detail and no result claim", async () => {
    const launcher = new FakeLauncher({
      exitCode: null,
      stdout: "",
      stderr: "",
      launchError: "spawn ENOENT",
    });

    const error = await expectTransportError(
      () =>
        invokeDiscoveryRuntime(output, invocation(), {
          launcher,
          detectInterpreter: () => FAKE_INTERPRETER,
        }),
      "DISCOVERY_INTERPRETER_UNAVAILABLE",
    );
    expect(error.message).toContain("spawn ENOENT");
    expect(error.message).toContain(FAKE_INTERPRETER.executable);
  });

  it("reports a missing installed runtime with the exact install command", async () => {
    const launcher = new FakeLauncher({
      exitCode: 1,
      stdout: "",
      stderr:
        "Traceback (most recent call last):\nModuleNotFoundError: No module named 'drm_copilot_discovery'\n",
    });

    const error = await expectTransportError(
      () =>
        invokeDiscoveryRuntime(output, invocation(), {
          launcher,
          detectInterpreter: () => FAKE_INTERPRETER,
        }),
      "DISCOVERY_RUNTIME_MISSING",
    );
    expect(error.message).toContain(
      `${FAKE_INTERPRETER.executable} -I -m pip install ${DISCOVERY_WHEEL_FILE_NAME}`,
    );
    expect(error.stderr).toContain("ModuleNotFoundError");
    expect(error.exitCode).toBe(1);
  });

  it("surfaces truncated stdout as a malformed result carrying stderr context", async () => {
    const launcher = new FakeLauncher({
      exitCode: 0,
      stdout: '{"result_version":"2.0.0","operation":"doctor"',
      stderr: "partial write",
    });

    const error = await expectTransportError(
      () =>
        invokeDiscoveryRuntime(output, invocation(), {
          launcher,
          detectInterpreter: () => FAKE_INTERPRETER,
        }),
      "DISCOVERY_RESULT_MALFORMED",
    );
    expect(error.stderr).toBe("partial write");
  });

  it("rejects a process exit that disagrees with the result exit code", async () => {
    const launcher = new FakeLauncher({
      exitCode: 0,
      stdout: JSON.stringify(buildBlockingResult()),
      stderr: "",
    });

    await expectTransportError(
      () =>
        invokeDiscoveryRuntime(output, invocation(), {
          launcher,
          detectInterpreter: () => FAKE_INTERPRETER,
        }),
      "DISCOVERY_RESULT_EXIT_MISMATCH",
    );
  });

  it("rejects an incompatible runtime build and version", async () => {
    const result = buildServiceResult();
    const launcher = new FakeLauncher({
      exitCode: 0,
      stdout: JSON.stringify({
        ...result,
        runtime: { ...result.runtime, schema_version: "1.0.0" },
      }),
      stderr: "",
    });

    await expectTransportError(
      () =>
        invokeDiscoveryRuntime(output, invocation(), {
          launcher,
          detectInterpreter: () => FAKE_INTERPRETER,
        }),
      "DISCOVERY_RUNTIME_INCOMPATIBLE",
    );
  });

  it("returns a valid blocking result for the adapter to surface", async () => {
    const launcher = new FakeLauncher({
      exitCode: 1,
      stdout: JSON.stringify(buildBlockingResult()),
      stderr: "Discovery request failed; inspect the JSON findings.\n",
    });

    const result = await invokeDiscoveryRuntime(output, invocation(), {
      launcher,
      detectInterpreter: () => FAKE_INTERPRETER,
    });

    expect(result.ok).toBe(false);
    expect(result.exit_code).toBe(1);
  });

  it("logs the probe, the gateway start and the exit without the request body", async () => {
    const lines: string[] = [];
    const launcher = new FakeLauncher(successOutcome());

    await invokeDiscoveryRuntime(
      { appendLine: (line) => lines.push(line) },
      invocation(),
      { launcher, detectInterpreter: () => FAKE_INTERPRETER },
    );

    expect(lines).toEqual([
      `[test-invocation] runtime probe success: ${FAKE_INTERPRETER.executable}`,
      `[test-invocation] gateway start: ${FAKE_INTERPRETER.executable} -I -m ${DISCOVERY_GATEWAY_MODULE} (validate-profile, structural)`,
      "[test-invocation] gateway exit 0",
    ]);
    expect(lines.join("\n")).not.toContain("discovery/profile.yaml");
  });
});
