import { beforeEach, describe, expect, it, jest } from "@jest/globals";
import * as path from "node:path";

const mockReadFileSync = jest.fn();
const mockMkdirSync = jest.fn();
const mockWriteFileSync = jest.fn();
const mockRenameSync = jest.fn();
const mockUnlinkSync = jest.fn();
const mockRealpathSyncNative = jest.fn();
const mockStatSync = jest.fn();

jest.mock("node:fs", () => ({
  readFileSync: mockReadFileSync,
  mkdirSync: mockMkdirSync,
  writeFileSync: mockWriteFileSync,
  renameSync: mockRenameSync,
  unlinkSync: mockUnlinkSync,
  realpathSync: { native: mockRealpathSyncNative },
  statSync: mockStatSync,
}));

import type { FileSystem } from "../../../src/lib/file-system";
import type { CommandRunner } from "../../../src/lib/subprocess-runner";
import { createProductionHandoffMaterializer } from "../../../src/lib/validate/orchestration-handoff-materializer-production";

const actualFileSystem =
  jest.requireActual<typeof import("node:fs")>("node:fs");
const validEnvelopeText = actualFileSystem.readFileSync(
  path.resolve(
    __dirname,
    "../../../../../tests/fixtures/orchestration-handoff/contract/valid-ordinary-claude-to-codex.json",
  ),
  "utf8",
);

function createFileSystem(readTextFile = jest.fn(() => validEnvelopeText)) {
  return {
    glob: jest.fn(() => []),
    isFile: jest.fn(() => true),
    exists: jest.fn(() => true),
    isDirectory: jest.fn(() => false),
    listDirectory: jest.fn(() => []),
    readTextFile,
    writeTextFile: jest.fn(),
    ensureDir: jest.fn(),
  } satisfies FileSystem;
}

/**
 * Caller-controlled independent expected context. Every portable handoff
 * request must carry these values; the production boundary must forward them
 * unchanged and must never derive them from the envelope under validation.
 */
const INDEPENDENT_CONTEXT = {
  expectedRepositoryId: "github.com/drmoisan/drm-copilot",
  expectedWorkspaceRoot: "C:/workspace",
  expectedBranch: "feature/portable-handoff-614",
  expectedSourceHeadSha: "0".repeat(40),
  allowedHeadRelationship: "equal_or_descendant",
  expectedIssueNumber: 614,
  expectedFeatureFolder: "docs/features/active/portable-handoff-614",
  expectedWorkMode: "full-feature",
  expectedPlanPath: "docs/features/active/portable-handoff-614/plan.md",
  expectedPlanSha256: "2".repeat(64),
} as const;

function createReference() {
  return {
    workspaceRoot: "C:/workspace",
    handoffEnvelopePath: "artifacts/orchestration/handoff.json",
    expectedHandoffEnvelopeSha256: "a".repeat(64),
    destinationProvider: "codex",
    ...INDEPENDENT_CONTEXT,
  } as const;
}

function validProjection(provider: "claude" | "codex") {
  return JSON.stringify({
    provider,
    checkpoint_expression: `${provider}.orchestrator-state`,
    destination_projector: `portable-to-${provider}-v1`,
    "plan-path": "docs/features/active/portable-handoff-614/plan.md",
    next_step: "atomic_execution",
    portable_handoff: {},
    destination_evidence: {
      status: "pending_first_delegation",
      receipts: [],
    },
  });
}

describe("production orchestration handoff materializer boundaries", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockRealpathSyncNative.mockImplementation(
      (targetPath: string) => targetPath,
    );
    mockStatSync.mockReturnValue({ isDirectory: () => true });
  });

  it("delegates raw filesystem, Git, authority, and clock boundaries", async () => {
    // Arrange
    const fileSystem = createFileSystem(jest.fn(() => "missing"));
    const runner: CommandRunner = {
      run: jest.fn(() => ({ stdout: " M src/file.ts", stderr: "", code: 0 })),
    };
    mockReadFileSync.mockReturnValue(Buffer.from("raw"));
    const materializer = createProductionHandoffMaterializer(
      fileSystem,
      runner,
    );
    const reference = createReference();

    // Act
    expect(
      materializer.dependencies.fileSystem.readFile("source.json"),
    ).toEqual(Buffer.from("raw"));
    materializer.dependencies.fileSystem.createDirectory("archive");
    materializer.dependencies.fileSystem.writeFile(
      "candidate",
      Buffer.from("x"),
    );
    materializer.dependencies.fileSystem.writeFile(
      "exclusive",
      Buffer.from("x"),
      {
        exclusive: true,
      },
    );
    materializer.dependencies.fileSystem.replaceFile(
      "candidate",
      "destination",
    );
    materializer.dependencies.fileSystem.removeFile("candidate");
    const porcelain =
      await materializer.dependencies.git.readPorcelainStatus("C:/workspace");
    const topology =
      await materializer.dependencies.topology.resolve(reference);
    const routing = await materializer.dependencies.routing.resolve(reference);

    // Assert
    expect(mockMkdirSync).toHaveBeenCalledWith("archive", { recursive: true });
    expect(mockWriteFileSync).toHaveBeenNthCalledWith(
      1,
      "candidate",
      expect.any(Buffer),
      {
        flag: "w",
      },
    );
    expect(mockWriteFileSync).toHaveBeenNthCalledWith(
      2,
      "exclusive",
      expect.any(Buffer),
      {
        flag: "wx",
      },
    );
    expect(mockRenameSync).toHaveBeenCalledWith("candidate", "destination");
    expect(mockUnlinkSync).toHaveBeenCalledWith("candidate");
    expect(porcelain).toBe(" M src/file.ts");
    expect(topology.status).toBe("blocked");
    expect(routing.status).toBe("blocked");
    expect(materializer.dependencies.clock.nowIso8601()).toMatch(
      /^\d{4}-\d{2}-\d{2}T/,
    );
  });

  it("validates envelope text and both provider projection shapes", () => {
    // Arrange
    const materializer = createProductionHandoffMaterializer(
      createFileSystem(),
      {
        run: jest.fn(() => ({ stdout: "", stderr: "", code: 0 })),
      },
    );
    const validator = materializer.dependencies.validator;

    // Act / Assert
    expect(
      validator.validateEnvelope(validEnvelopeText).envelope,
    ).not.toBeNull();
    expect(validator.validateEnvelope("{")).toMatchObject({
      envelope: null,
      primaryFailureCode: "HANDOFF_UNSUPPORTED_VERSION",
    });
    expect(
      validator.validateDestinationProjection(validProjection("codex")),
    ).toEqual([]);
    expect(
      validator.validateDestinationProjection(validProjection("claude")),
    ).toEqual([]);
    expect(validator.validateDestinationProjection("{")).toHaveLength(1);
    expect(validator.validateDestinationProjection("[]")).toHaveLength(1);
  });

  it("shares the Node canonical path boundary with authority resolution", async () => {
    // Arrange
    const materializer = createProductionHandoffMaterializer(
      createFileSystem(jest.fn(() => "missing")),
      {
        run: jest.fn(() => ({ stdout: "", stderr: "", code: 0 })),
      },
    );
    const pathBoundary = materializer.dependencies.pathBoundary;
    if (pathBoundary === undefined) {
      throw new Error("Production path boundary must be configured.");
    }
    const resolveWorkspaceRoot = jest.spyOn(
      pathBoundary,
      "resolveWorkspaceRoot",
    );
    const reference = createReference();

    // Act
    const canonicalRoot = pathBoundary.resolveWorkspaceRoot("C:/workspace");
    await materializer.dependencies.topology.resolve(reference);

    // Assert
    expect(canonicalRoot).toBe("C:/workspace");
    expect(resolveWorkspaceRoot).toHaveBeenCalledTimes(2);
    expect(mockRealpathSyncNative).toHaveBeenCalled();
    expect(mockStatSync).toHaveBeenCalledWith("C:/workspace");
  });

  it.each([
    { provider: "other" },
    { checkpoint_expression: "wrong" },
    { destination_projector: "wrong" },
    { "plan-path": null },
    { next_step: null },
    { portable_handoff: null },
    { destination_evidence: null },
    { destination_evidence: { status: "wrong", receipts: [] } },
    {
      destination_evidence: {
        status: "pending_first_delegation",
        receipts: null,
      },
    },
    {
      destination_evidence: {
        status: "pending_first_delegation",
        receipts: ["fabricated"],
      },
    },
  ])("rejects an invalid destination projection %#", (override) => {
    // Arrange
    const materializer = createProductionHandoffMaterializer(
      createFileSystem(),
      {
        run: jest.fn(() => ({ stdout: "", stderr: "", code: 0 })),
      },
    );
    const projection = {
      ...(JSON.parse(validProjection("codex")) as Record<string, unknown>),
      ...override,
    };

    // Act / Assert
    expect(
      materializer.dependencies.validator.validateDestinationProjection(
        JSON.stringify(projection),
      ),
    ).toHaveLength(1);
  });
});

describe("production independent checkout observation boundary", () => {
  const observationCommands = [
    "rev-parse --show-toplevel",
    "remote get-url origin",
    "branch --show-current",
    "rev-parse HEAD",
  ];

  beforeEach(() => {
    jest.clearAllMocks();
    mockRealpathSyncNative.mockImplementation(
      (targetPath: string) => targetPath,
    );
    mockStatSync.mockReturnValue({ isDirectory: () => true });
  });

  it("routes checkout observation through the injected command runner", async () => {
    // Arrange
    // Each observation query is scripted so the boundary reaches all four
    // facts; a runner that fails the first query would stop the observation
    // before the later queries could be routed through it at all.
    const observationOutput: Readonly<Record<string, string>> = {
      "rev-parse --show-toplevel": "C:/workspace",
      "remote get-url origin": "https://github.com/drmoisan/drm-copilot.git",
      "branch --show-current": "feature/portable-handoff-614",
      "rev-parse HEAD": "0".repeat(40),
    };
    const run = jest.fn((args: readonly string[]) => {
      const invocation = args.join(" ");
      const observed = observationCommands.find((subcommand) =>
        invocation.endsWith(subcommand),
      );
      return observed === undefined
        ? { stdout: "", stderr: "", code: 1 }
        : { stdout: observationOutput[observed] ?? "", stderr: "", code: 0 };
    });
    const materializer = createProductionHandoffMaterializer(
      createFileSystem(),
      { run },
    );

    // Act
    await materializer.dependencies.topology.resolve(createReference());

    // Assert
    const invocations = run.mock.calls.map(([args]) =>
      (args as readonly string[]).join(" "),
    );
    for (const subcommand of observationCommands) {
      expect(invocations.some((call) => call.endsWith(subcommand))).toBe(true);
    }
    for (const invocation of invocations) {
      expect(invocation).not.toMatch(/\b(fetch|ls-remote|pull|push|clone)\b/);
    }
  });

  it.each(["dry_run", "materialize"] as const)(
    "performs no write when the %s transition is blocked",
    async (mode) => {
      // Arrange
      mockReadFileSync.mockReturnValue(Buffer.from("unexpected bytes"));
      const materializer = createProductionHandoffMaterializer(
        createFileSystem(),
        { run: jest.fn(() => ({ stdout: "", stderr: "", code: 0 })) },
      );

      // Act
      const result = await materializer.transition({
        ...createReference(),
        sourceCheckpointPath: "artifacts/orchestration/orchestrator-state.json",
        expectedSourceCheckpointSha256: "b".repeat(64),
        mode,
      });

      // Assert
      expect(result.status).toBe("blocked");
      expect(result.destinationCheckpointPath).toBeNull();
      expect(result.destinationCheckpointSha256).toBeNull();
      expect(mockMkdirSync).not.toHaveBeenCalled();
      expect(mockWriteFileSync).not.toHaveBeenCalled();
      expect(mockRenameSync).not.toHaveBeenCalled();
      expect(mockUnlinkSync).not.toHaveBeenCalled();
    },
  );

  it("blocks with an unavailable observation rather than trusting the envelope", async () => {
    // Arrange
    const materializer = createProductionHandoffMaterializer(
      createFileSystem(),
      { run: jest.fn(() => ({ stdout: "", stderr: "", code: 128 })) },
    );

    // Act
    const result =
      await materializer.dependencies.routing.resolve(createReference());

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.resolution).toBeNull();
    expect(mockWriteFileSync).not.toHaveBeenCalled();
    expect(mockRenameSync).not.toHaveBeenCalled();
  });
});
