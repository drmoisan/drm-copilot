import { describe, expect, it, jest } from "@jest/globals";
import * as path from "node:path";

import type { FileSystem } from "../../../src/lib/file-system";
import type { CommandRunner } from "../../../src/lib/subprocess-runner";
import type { HandoffFailureCode } from "../../../src/lib/validate/orchestration-handoff-contract";
import { createProductionHandoffMaterializer } from "../../../src/lib/validate/orchestration-handoff-materializer-production";
import { createHandoffPathBoundary } from "../../../src/lib/validate/orchestration-handoff-path-boundary";
import {
  OrchestrationHandoffMaterializer,
  type HandoffMaterializerDependencies,
} from "../../../src/lib/validate/orchestration-handoff-materializer";
import { describeHandoffFailureCause } from "../../../src/lib/validate/orchestration-handoff-materializer-request";
import type {
  TransitionPreparedOrchestrationRequest,
  TransitionPreparedOrchestrationResult,
} from "../../../src/mcp-repo-automation-tool-definitions-handoff";
import {
  archivePathFor,
  candidatePathFor,
  createScenario,
  encoder,
  workspacePath,
  type ScenarioOptions,
} from "./orchestration-handoff-materializer-test-support";

/** An error carrying a system code and a message that names an absolute path. */
function codedError(code: string): Error {
  return Object.assign(
    new Error(`operation failed for ${workspacePath("private/secret.json")}`),
    { code },
  );
}

type Scenario = ReturnType<typeof createScenario>;

/** Make one path's read throw while every other read keeps its default. */
function failReadAt(scenario: Scenario, filePath: string, error: Error): void {
  const original = scenario.readFile.getMockImplementation();
  if (original === undefined) throw new Error("readFile has no implementation");
  scenario.readFile.mockImplementation((candidate: string) => {
    if (candidate === filePath) throw error;
    return original(candidate);
  });
}

/** Make one path's write throw while every other write keeps its default. */
function failWriteAt(scenario: Scenario, filePath: string, error: Error): void {
  const original = scenario.writeFile.getMockImplementation();
  if (original === undefined)
    throw new Error("writeFile has no implementation");
  scenario.writeFile.mockImplementation((candidate, content, options) => {
    if (candidate === filePath) throw error;
    original(candidate, content, options);
  });
}

async function runScenario(
  options: ScenarioOptions,
  arrange: (scenario: Scenario) => void = () => undefined,
  dependencies: (
    base: HandoffMaterializerDependencies,
  ) => HandoffMaterializerDependencies = (base) => base,
): Promise<TransitionPreparedOrchestrationResult> {
  const scenario = createScenario(options);
  arrange(scenario);
  const materializer = new OrchestrationHandoffMaterializer(
    dependencies(scenario.dependencies),
  );
  return materializer.transition(scenario.request);
}

const MATERIALIZE: Partial<TransitionPreparedOrchestrationRequest> = {
  mode: "materialize",
};

/**
 * Issue #645 (R18): blocked handoff results carry a redaction-safe
 * `<stage>: <token>` failure cause. These cases pin the token rule and prove
 * that no error message (and so no host path or environment value) can reach
 * the cause string.
 */

describe("describeHandoffFailureCause", () => {
  it.each([
    {
      label: "(a) an uppercase string code is the token",
      error: Object.assign(new Error("x"), { code: "EACCES" }),
      expected: "checkpoint-read: EACCES",
    },
    {
      label: "(b) a non-identifier string code falls back to the error name",
      error: Object.assign(new Error("x"), { code: "eacces-lower" }),
      expected: "checkpoint-read: Error",
    },
    {
      label: "(c) a numeric code falls back to the error name",
      error: Object.assign(new Error("x"), { code: 13 }),
      expected: "checkpoint-read: Error",
    },
    {
      label: "(d) an Error subclass without a code uses its name",
      error: new TypeError("x"),
      expected: "checkpoint-read: TypeError",
    },
    {
      label: "(e) a thrown string is a non-error value",
      error: "boom",
      expected: "checkpoint-read: non-error value",
    },
    {
      label: "(f) undefined is a non-error value",
      error: undefined,
      expected: "checkpoint-read: non-error value",
    },
    {
      label: "(g) a plain object with an uppercase code uses the code",
      error: { code: "ENOENT" },
      expected: "checkpoint-read: ENOENT",
    },
  ])("$label", ({ error, expected }) => {
    // Arrange
    const stage = "checkpoint-read";

    // Act
    const cause = describeHandoffFailureCause(stage, error);

    // Assert
    expect(cause).toBe(expected);
  });

  it("never copies an error message, path, or environment value into the cause", () => {
    // Arrange
    const messages = [
      "C:\\Users\\operator\\AppData\\secret.json",
      "/home/operator/.ssh/id_rsa",
      "HOME=/home/operator",
    ];
    const errors = messages.flatMap((message) => [
      { message, error: new Error(message) },
      {
        message,
        error: Object.assign(new Error(message), { code: "EACCES" }),
      },
    ]);

    // Act
    const causes = errors.map(({ message, error }) => ({
      message,
      cause: describeHandoffFailureCause("checkpoint-read", error),
    }));

    // Assert
    expect(causes).toHaveLength(6);
    for (const { message, cause } of causes) {
      expect(cause).not.toContain(message);
      expect(cause).not.toContain("/");
      expect(cause).not.toContain("\\");
      expect(cause).not.toContain("operator");
    }
  });
});

interface MaterializerCase {
  readonly row: string;
  readonly options: ScenarioOptions;
  readonly arrange?: (scenario: Scenario) => void;
  readonly dependencies?: (
    base: HandoffMaterializerDependencies,
  ) => HandoffMaterializerDependencies;
  readonly code: HandoffFailureCode | null;
  readonly cause: string | undefined;
}

const MATERIALIZER_CASES: readonly MaterializerCase[] = [
  {
    row: "M1 source checkpoint read throws EACCES",
    options: {},
    arrange: (scenario) =>
      failReadAt(scenario, scenario.sourcePath, codedError("EACCES")),
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "checkpoint-read: EACCES",
  },
  {
    row: "M2 envelope bytes are invalid UTF-8",
    options: { envelopeBytes: Uint8Array.of(0xff, 0xfe, 0xfd) },
    code: "HANDOFF_UNSUPPORTED_VERSION",
    cause: "envelope-decode: ERR_ENCODING_INVALID_ENCODED_DATA",
  },
  {
    row: "M3 git status rejects with ENOENT",
    options: {},
    arrange: (scenario) => {
      jest
        .mocked(scenario.dependencies.git.readPorcelainStatus)
        .mockRejectedValueOnce(codedError("ENOENT"));
    },
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "git-status: ENOENT",
  },
  {
    row: "M4 destination projection is invalid",
    options: { projectionErrors: ["invalid"] },
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "destination-projection: invalid",
  },
  {
    row: "M5 archive write throws EEXIST and readback throws EACCES",
    options: { request: MATERIALIZE },
    arrange: (scenario) => {
      const archivePath = archivePathFor(scenario.sourceSha256);
      failWriteAt(scenario, archivePath, codedError("EEXIST"));
      failReadAt(scenario, archivePath, codedError("EACCES"));
    },
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "archive-write: EEXIST; archive-readback: EACCES",
  },
  {
    row: "M6 archive write fails and leaves a mismatched archive",
    options: { request: MATERIALIZE, writeFailureAt: "archive" },
    code: "HANDOFF_SOURCE_HASH_MISMATCH",
    cause: "archive-write: Error",
  },
  {
    row: "M7 candidate write throws EEXIST and readback throws EACCES",
    options: { request: MATERIALIZE },
    arrange: (scenario) => {
      const candidatePath = candidatePathFor(scenario.envelopeSha256);
      failWriteAt(scenario, candidatePath, codedError("EEXIST"));
      failReadAt(scenario, candidatePath, codedError("EACCES"));
    },
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "candidate-write: EEXIST; candidate-readback: EACCES",
  },
  {
    row: "M8 candidate path already holds different bytes",
    options: { request: MATERIALIZE },
    arrange: (scenario) =>
      scenario.files.set(
        candidatePathFor(scenario.envelopeSha256),
        encoder.encode("different candidate"),
      ),
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "candidate-write: Error",
  },
  {
    row: "M9 written candidate fails projection validation",
    options: { request: MATERIALIZE, candidateProjectionErrors: ["invalid"] },
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "candidate-validate: HANDOFF_CANDIDATE_MISMATCH",
  },
  {
    row: "M10 replace throws EPERM",
    options: { request: MATERIALIZE },
    arrange: (scenario) =>
      scenario.replaceFile.mockImplementationOnce(() => {
        throw codedError("EPERM");
      }),
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "candidate-replace: EPERM",
  },
  {
    row: "M11 replace throws EPERM and cleanup throws EBUSY",
    options: { request: MATERIALIZE },
    arrange: (scenario) => {
      scenario.replaceFile.mockImplementationOnce(() => {
        throw codedError("EPERM");
      });
      scenario.removeFile.mockImplementationOnce(() => {
        throw codedError("EBUSY");
      });
    },
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "candidate-replace: EPERM; candidate-cleanup: EBUSY",
  },
  {
    row: "M12 idempotent retry over an archive holding the source bytes",
    options: { request: MATERIALIZE },
    arrange: (scenario) =>
      scenario.files.set(
        archivePathFor(scenario.sourceSha256),
        scenario.sourceBytes,
      ),
    code: null,
    cause: undefined,
  },
  {
    row: "M13 workspace root is relative",
    options: { request: { workspaceRoot: "relative-root" } },
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "workspace-root: unresolved",
  },
  {
    row: "M14 source checkpoint path escapes the workspace",
    options: { request: { sourceCheckpointPath: "../outside.json" } },
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "target-path: unresolved",
  },
  {
    row: "M15 envelope archive path escapes the workspace",
    options: {
      transformEnvelope: (envelope) => ({
        ...envelope,
        source: { ...envelope.source, archivePath: "../escape.json" },
      }),
    },
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "target-path: unresolved",
  },
  {
    row: "M16 topology authority forwards its failure cause",
    options: {},
    dependencies: (base) => ({
      ...base,
      topology: {
        resolve: async () => ({
          status: "blocked",
          handoffId: "handoff-614",
          handoffEnvelopeSha256: "0".repeat(64),
          primaryFailureCode: "HANDOFF_VALIDATOR_UNAVAILABLE",
          affectedPaths: [],
          unsupportedCapabilities: [],
          resolution: null,
          failureCause: "envelope-read: ENOENT",
        }),
      },
    }),
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "envelope-read: ENOENT",
  },
  {
    row: "M17 default dry run validates",
    options: {},
    code: null,
    cause: undefined,
  },
];

describe("materializer blocked-result failure causes", () => {
  it.each(MATERIALIZER_CASES)(
    "$row",
    async ({ options, arrange, dependencies, code, cause }) => {
      // Arrange
      const arrangeScenario = arrange ?? (() => undefined);

      // Act
      const result = await runScenario(options, arrangeScenario, dependencies);

      // Assert
      expect(result.primaryFailureCode).toBe(code);
      if (cause === undefined) {
        expect(result).not.toHaveProperty("failureCause");
        expect(result.status).toBe(
          options.request?.mode === "materialize"
            ? "materialized"
            : "validated",
        );
      } else {
        expect(result.failureCause).toBe(cause);
        expect(result.status).toBe("blocked");
      }
    },
  );
});

describe("path-boundary guarded resolution", () => {
  const workspaceRoot = path.resolve("guarded-workspace");
  const canonicalRoot = workspaceRoot.replaceAll("\\", "/");
  const directory = { isDirectory: () => true };

  it("B1 returns the canonical root and target when realpath succeeds", () => {
    // Arrange
    const boundary = createHandoffPathBoundary({
      realpath: (targetPath) => targetPath,
      stat: () => directory,
    });

    // Act
    const root = boundary.resolveWorkspaceRoot(workspaceRoot);
    const target = boundary.resolveExistingTarget(
      canonicalRoot,
      "artifacts/handoff.json",
    );

    // Assert
    expect(root).toBe(canonicalRoot);
    expect(target).toBe(`${canonicalRoot}/artifacts/handoff.json`);
  });

  it("B2 returns null from both resolvers when realpath throws EACCES", () => {
    // Arrange
    const boundary = createHandoffPathBoundary({
      realpath: () => {
        throw codedError("EACCES");
      },
      stat: () => directory,
    });

    // Act
    const root = boundary.resolveWorkspaceRoot(workspaceRoot);
    const target = boundary.resolveExistingTarget(
      canonicalRoot,
      "artifacts/handoff.json",
    );

    // Assert
    expect(root).toBeNull();
    expect(target).toBeNull();
  });
});

describe("destination projection parse failure", () => {
  it("P1 names the parse failure stage without echoing the input", () => {
    // Arrange
    const fileSystem = {
      glob: () => [],
      isFile: () => false,
      exists: () => false,
      isDirectory: () => false,
      listDirectory: () => [],
      readTextFile: () => "",
      writeTextFile: () => undefined,
      ensureDir: () => undefined,
    } satisfies FileSystem;
    const runner: CommandRunner = {
      run: () => ({ stdout: "", stderr: "", code: 0 }),
    };
    const materializer = createProductionHandoffMaterializer(
      fileSystem,
      runner,
    );

    // Act
    const errors =
      materializer.dependencies.validator.validateDestinationProjection("{");

    // Assert
    expect(errors).toEqual([
      "destination checkpoint must be valid JSON (destination-projection: SyntaxError)",
    ]);
  });
});
