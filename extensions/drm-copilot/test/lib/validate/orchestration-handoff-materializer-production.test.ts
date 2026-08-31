import { describe, expect, it, jest } from "@jest/globals";
import * as path from "node:path";

const mockReadFileSync = jest.fn();
const mockMkdirSync = jest.fn();
const mockWriteFileSync = jest.fn();
const mockRenameSync = jest.fn();
const mockUnlinkSync = jest.fn();

jest.mock("node:fs", () => ({
  readFileSync: mockReadFileSync,
  mkdirSync: mockMkdirSync,
  writeFileSync: mockWriteFileSync,
  renameSync: mockRenameSync,
  unlinkSync: mockUnlinkSync,
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
    const reference = {
      workspaceRoot: "C:/workspace",
      handoffEnvelopePath: "artifacts/orchestration/handoff.json",
      expectedHandoffEnvelopeSha256: "a".repeat(64),
      destinationProvider: "codex",
    } as const;

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
