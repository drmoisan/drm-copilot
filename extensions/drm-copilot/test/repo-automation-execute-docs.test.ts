/**
 * Tests for the docs command executor (issue #1036). The launcher, the file
 * system and the `pwsh` resolver are injected fakes; no process is started
 * and no file is written.
 */

import { describe, expect, it } from "@jest/globals";

import type {
  DiscoveryProcessLauncher,
  DiscoveryProcessOutcome,
} from "../src/discovery-runtime";
import { DocsHostError } from "../src/docs-command-envelope";
import {
  resolveDocsToolInput,
  type DocsToolName,
} from "../src/mcp-tool-inputs-docs";
import {
  DOCS_ENTRY_SCRIPT_RELATIVE_PATH,
  createDefaultDocsDependencies,
  createDefaultPwshResolver,
  invokeDocsCommand,
  type DocsCommandDependencies,
  type DocsCommandRequest,
} from "../src/repo-automation-execute-docs";
import { InMemoryFileSystem } from "./lib/subagent-tree/in-memory-file-system";
import { VIRTUAL_WORKSPACE_ROOT } from "./mcp-server-test-service";

const PWSH_PATH = "/opt/powershell/pwsh";
const SCRIPT = `${VIRTUAL_WORKSPACE_ROOT}/${DOCS_ENTRY_SCRIPT_RELATIVE_PATH}`;

interface LaunchCall {
  readonly executable: string;
  readonly args: ReadonlyArray<string>;
  readonly cwd: string;
  readonly stdin: string;
}

interface Harness {
  readonly deps: DocsCommandDependencies;
  readonly calls: LaunchCall[];
  readonly order: string[];
}

function envelope(command: string, exitCode: number): string {
  const findings =
    exitCode === 0
      ? []
      : [
          {
            code: "DOCS_SAMPLE",
            severity: "error",
            artifact_path: null,
            pointer: "",
            related_ids: [],
            related_paths: [],
            message: "Sample.",
            next_action: "Fix.",
          },
        ];
  return JSON.stringify({
    command,
    exit_code: exitCode,
    findings,
    ok: exitCode === 0,
    result: exitCode >= 2 ? null : {},
  });
}

function harness(
  options: {
    readonly outcome?: (args: ReadonlyArray<string>) => DiscoveryProcessOutcome;
    readonly scriptPresent?: boolean;
    readonly pwsh?: string | undefined;
  } = {},
): Harness {
  const calls: LaunchCall[] = [];
  const order: string[] = [];
  const fileSystem = new InMemoryFileSystem();
  if (options.scriptPresent ?? true) {
    fileSystem.addFile(SCRIPT, "# entry");
  }
  const launcher: DiscoveryProcessLauncher = {
    launch(executable, args, launchOptions) {
      calls.push({ executable, args, ...launchOptions });
      const subcommand = args[4] ?? "";
      return Promise.resolve(
        options.outcome?.(args) ?? {
          exitCode: 0,
          stdout: envelope(subcommand, 0),
          stderr: "",
        },
      );
    },
  };
  return {
    calls,
    order,
    deps: {
      fileSystem: {
        isFile(filePath: string) {
          order.push("entry-script");
          return fileSystem.isFile(filePath);
        },
      },
      launcher,
      resolvePwsh() {
        order.push("pwsh");
        return "pwsh" in options ? options.pwsh : PWSH_PATH;
      },
    },
  };
}

function request(
  overrides: Partial<DocsCommandRequest> = {},
): DocsCommandRequest {
  return {
    workspaceRoot: VIRTUAL_WORKSPACE_ROOT,
    subcommand: "coverage",
    options: [],
    ...overrides,
  };
}

async function captureHostError(
  action: () => Promise<unknown>,
): Promise<DocsHostError> {
  try {
    await action();
  } catch (error) {
    if (error instanceof DocsHostError) {
      return error;
    }
    throw error;
  }
  throw new Error("Expected a DocsHostError.");
}

describe("invokeDocsCommand", () => {
  it("launches pwsh with the exact argv, cwd and empty stdin once per call", async () => {
    // Arrange: one input per tool, resolved through the declarative tables.
    const inputs: ReadonlyArray<
      readonly [
        DocsToolName,
        Record<string, unknown>,
        string,
        ReadonlyArray<string>,
      ]
    > = [
      [
        "run_docs_check",
        { paths: ["docs/index.md"] },
        "check",
        ["-Path", "docs/index.md"],
      ],
      [
        "run_docs_inventory",
        { analyzers: ["python-cli"] },
        "inventory",
        ["-Analyzer", "python-cli"],
      ],
      ["run_docs_coverage", {}, "coverage", []],
      [
        "update_docs_ledger",
        {
          operation: "sync-refs",
          actor_kind: "agent",
          actor_id: "docs-reconciler",
        },
        "update-ledger",
        [
          "-Operation",
          "sync-refs",
          "-ActorKind",
          "agent",
          "-ActorId",
          "docs-reconciler",
        ],
      ],
      [
        "generate_docs_reference",
        { output_directory: "docs/reference" },
        "generate-reference",
        ["-OutputDirectory", "docs/reference"],
      ],
      [
        "validate_docs_artifacts",
        { mode: "profile", revision: "f".repeat(40) },
        "validate",
        ["-Mode", "profile", "-Revision", "f".repeat(40)],
      ],
    ];

    for (const [toolName, input, subcommand, options] of inputs) {
      const { deps, calls } = harness();
      const resolved = resolveDocsToolInput(toolName, {
        workspace_root: VIRTUAL_WORKSPACE_ROOT,
        ...input,
      });

      // Act
      const outcome = await invokeDocsCommand(resolved, deps);

      // Assert
      expect(calls).toEqual([
        {
          executable: PWSH_PATH,
          args: [
            "-NoProfile",
            "-File",
            ".claude/lib/docs/Invoke-DocsCommand.ps1",
            "-Command",
            subcommand,
            "-Json",
            ...options,
          ],
          cwd: VIRTUAL_WORKSPACE_ROOT,
          stdin: "",
        },
      ]);
      expect(outcome.envelope.command).toBe(subcommand);
    }
  });

  it("fails with DOCS_WORKSPACE_ROOT_INVALID before any other check for a relative workspace root", async () => {
    // Arrange
    const { deps, calls, order } = harness();

    // Act
    const error = await captureHostError(() =>
      invokeDocsCommand(request({ workspaceRoot: "relative/root" }), deps),
    );

    // Assert
    expect(error.code).toBe("DOCS_WORKSPACE_ROOT_INVALID");
    expect(error.message.startsWith("DOCS_WORKSPACE_ROOT_INVALID: ")).toBe(
      true,
    );
    expect(order).toEqual([]);
    expect(calls).toEqual([]);
  });

  it("fails with DOCS_ENTRY_SCRIPT_MISSING naming push_down_claude_customizations without launching", async () => {
    // Arrange
    const { deps, calls, order } = harness({ scriptPresent: false });

    // Act
    const error = await captureHostError(() =>
      invokeDocsCommand(request(), deps),
    );

    // Assert
    expect(error.code).toBe("DOCS_ENTRY_SCRIPT_MISSING");
    expect(error.message).toContain("push_down_claude_customizations");
    expect(order).toEqual(["entry-script"]);
    expect(calls).toEqual([]);
  });

  it("fails with DOCS_PWSH_UNAVAILABLE without launching when pwsh does not resolve", async () => {
    // Arrange
    const { deps, calls } = harness({ pwsh: undefined });

    // Act
    const error = await captureHostError(() =>
      invokeDocsCommand(request(), deps),
    );

    // Assert
    expect(error.code).toBe("DOCS_PWSH_UNAVAILABLE");
    expect(calls).toEqual([]);
  });

  it("maps a launcher launch error to DOCS_PWSH_UNAVAILABLE", async () => {
    // Arrange
    const { deps, calls } = harness({
      outcome: () => ({
        exitCode: null,
        stdout: "",
        stderr: "",
        launchError: "spawn pwsh ENOENT",
      }),
    });

    // Act
    const error = await captureHostError(() =>
      invokeDocsCommand(request(), deps),
    );

    // Assert
    expect(error.code).toBe("DOCS_PWSH_UNAVAILABLE");
    expect(error.message).toContain("spawn pwsh ENOENT");
    expect(calls).toHaveLength(1);
  });

  it("checks workspace root, entry script and pwsh in that order", async () => {
    // Arrange
    const { deps, order } = harness();

    // Act
    await invokeDocsCommand(
      request({ workspaceRoot: `${VIRTUAL_WORKSPACE_ROOT}/` }),
      deps,
    );

    // Assert
    expect(order).toEqual(["entry-script", "pwsh"]);
  });

  it("resolves only pwsh and never falls back to powershell", () => {
    // Arrange
    const onlyWindowsPowerShell = createDefaultPwshResolver({
      pathValue: "C:\\Windows\\System32\\WindowsPowerShell\\v1.0",
      pathExtValue: ".EXE",
      platform: "win32",
      exists: (candidate) => candidate.toLowerCase().endsWith("powershell.exe"),
    });
    const withPwsh = createDefaultPwshResolver({
      pathValue: "/usr/bin:/opt/microsoft/powershell/7",
      pathExtValue: undefined,
      platform: "linux",
      exists: (candidate) => candidate === "/opt/microsoft/powershell/7/pwsh",
    });
    const fileSystem = new InMemoryFileSystem();

    // Act
    const defaults = createDefaultDocsDependencies({ fileSystem });
    const injected = createDefaultDocsDependencies({
      fileSystem,
      environment: {
        pathValue: "/opt/microsoft/powershell/7",
        pathExtValue: undefined,
        platform: "linux",
        exists: () => true,
      },
    });

    // Assert
    expect(onlyWindowsPowerShell()).toBeUndefined();
    expect(withPwsh()).toBe("/opt/microsoft/powershell/7/pwsh");
    expect(injected.resolvePwsh()).toBe("/opt/microsoft/powershell/7/pwsh");
    expect(typeof defaults.launcher.launch).toBe("function");
    expect(defaults.fileSystem).toBe(fileSystem);
  });

  it("returns the parsed envelope and stderr for exit codes 0 to 3 without retrying", async () => {
    for (const exitCode of [0, 1, 2, 3]) {
      // Arrange
      const { deps, calls } = harness({
        outcome: () => ({
          exitCode,
          stdout: envelope("coverage", exitCode),
          stderr: "detail line",
        }),
      });

      // Act
      const outcome = await invokeDocsCommand(request(), deps);

      // Assert
      expect(outcome.envelope.exit_code).toBe(exitCode);
      expect(outcome.stderr).toBe("detail line");
      expect(calls).toHaveLength(1);
    }
  });

  it("propagates envelope parse failures", async () => {
    // Arrange
    const cases: ReadonlyArray<readonly [DiscoveryProcessOutcome, string]> = [
      [{ exitCode: 3, stdout: "", stderr: "boom" }, "DOCS_ENVELOPE_EMPTY"],
      [
        { exitCode: 1, stdout: "not json", stderr: "" },
        "DOCS_ENVELOPE_MALFORMED",
      ],
      [
        { exitCode: 2, stdout: envelope("coverage", 1), stderr: "" },
        "DOCS_ENVELOPE_EXIT_MISMATCH",
      ],
      [
        { exitCode: 0, stdout: envelope("check", 0), stderr: "" },
        "DOCS_ENVELOPE_COMMAND_MISMATCH",
      ],
    ];

    for (const [processOutcome, code] of cases) {
      const { deps, calls } = harness({ outcome: () => processOutcome });

      // Act
      const error = await captureHostError(() =>
        invokeDocsCommand(request(), deps),
      );

      // Assert
      expect(error.code).toBe(code);
      expect(calls).toHaveLength(1);
    }
  });
});
