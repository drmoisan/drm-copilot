import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import * as path from "node:path";
import { describe, expect, it, jest } from "@jest/globals";

import type {
  PortableHandoffProvider,
  PortableHandoffReferenceRequest,
} from "../../../src/mcp-repo-automation-tool-definitions-handoff";
import type { FileSystem } from "../../../src/lib/file-system";
import { resolvePortableHandoffAuthority } from "../../../src/lib/validate/orchestration-handoff-authority-service";
import type { HandoffPathBoundary } from "../../../src/lib/validate/orchestration-handoff-path-boundary";

interface EnvelopeFixture {
  readonly binding: { workspace_root: string };
  readonly destination: { provider: PortableHandoffProvider };
  readonly plan: { path: string; sha256: string };
}

interface ScenarioOptions {
  readonly bindingWorkspaceRoot?: string;
  readonly blockedRepositoryPaths?: readonly string[];
  readonly envelopeText?: string;
  readonly expectedEnvelopeSha256?: string;
  readonly fixtureName?: string;
  readonly handoffEnvelopePath?: string;
  readonly planReadFailure?: boolean;
  readonly planSha256?: string;
  readonly planText?: string;
  readonly requestProvider?: PortableHandoffProvider;
  readonly requestWorkspaceRoot?: string;
  readonly envelopeReadFailure?: boolean;
}

const fixtureRoot = path.resolve(
  __dirname,
  "../../../../../tests/fixtures/orchestration-handoff/contract",
);
const canonicalWorkspaceRoot = "C:/canonical-workspace";
const canonicalEnvelopePath = `${canonicalWorkspaceRoot}/handoff.json`;
const canonicalPlanPath = `${canonicalWorkspaceRoot}/plan.md`;

function sha256(content: string): string {
  return createHash("sha256").update(content, "utf8").digest("hex");
}

function loadFixture(name: string): EnvelopeFixture {
  return JSON.parse(
    readFileSync(path.join(fixtureRoot, name), "utf8"),
  ) as EnvelopeFixture;
}

function createScenario(options: ScenarioOptions = {}) {
  const fixture = loadFixture(
    options.fixtureName ?? "valid-ordinary-claude-to-codex.json",
  );
  const planText = options.planText ?? "# Atomic plan\n";
  fixture.plan.sha256 = options.planSha256 ?? sha256(planText);
  if (options.bindingWorkspaceRoot !== undefined) {
    fixture.binding.workspace_root = options.bindingWorkspaceRoot;
  }
  const envelopeText = options.envelopeText ?? JSON.stringify(fixture);
  const handoffEnvelopePath =
    options.handoffEnvelopePath ?? "artifacts/orchestration/handoff.json";
  const request: PortableHandoffReferenceRequest = {
    workspaceRoot:
      options.requestWorkspaceRoot ?? fixture.binding.workspace_root,
    handoffEnvelopePath,
    expectedHandoffEnvelopeSha256:
      options.expectedEnvelopeSha256 ?? sha256(envelopeText),
    destinationProvider:
      options.requestProvider ?? fixture.destination.provider,
  };
  const blockedPaths = new Set(options.blockedRepositoryPaths ?? []);
  const readTextFile = jest.fn((filePath: string): string => {
    if (filePath === canonicalEnvelopePath) {
      if (options.envelopeReadFailure === true) throw new Error("read failed");
      return envelopeText;
    }
    if (filePath === canonicalPlanPath) {
      if (options.planReadFailure === true) throw new Error("read failed");
      return planText;
    }
    throw new Error(`Unexpected read: ${filePath}`);
  });
  const fileSystem = {
    glob: jest.fn(() => []),
    isFile: jest.fn(() => true),
    exists: jest.fn(() => true),
    isDirectory: jest.fn(() => false),
    listDirectory: jest.fn(() => []),
    readTextFile,
    writeTextFile: jest.fn(),
    ensureDir: jest.fn(),
  } satisfies FileSystem;
  const pathBoundary: HandoffPathBoundary = {
    resolveWorkspaceRoot: jest.fn(() => canonicalWorkspaceRoot),
    resolveExistingTarget: jest.fn((_root, repositoryPath) => {
      if (blockedPaths.has(repositoryPath)) return null;
      if (repositoryPath === handoffEnvelopePath) return canonicalEnvelopePath;
      if (repositoryPath === fixture.plan.path) return canonicalPlanPath;
      return null;
    }),
    resolveCreatableTarget: jest.fn(() => null),
  };
  return {
    fileSystem,
    pathBoundary,
    readTextFile,
    request,
  };
}

describe("portable orchestration handoff authority service", () => {
  it("rejects a canonical envelope escape before any file read", () => {
    // Arrange
    const scenario = createScenario({
      handoffEnvelopePath: "../handoff.json",
      blockedRepositoryPaths: ["../handoff.json"],
    });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).not.toHaveBeenCalled();
  });

  it("rejects a canonical plan escape before reading the plan", () => {
    // Arrange
    const scenario = createScenario({
      blockedRepositoryPaths: [
        "docs/features/active/portable-handoff-614/plan.md",
      ],
    });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
    expect(scenario.readTextFile).not.toHaveBeenCalledWith(canonicalPlanPath);
  });

  it("reports an envelope read failure without attempting a plan read", () => {
    // Arrange
    const scenario = createScenario({ envelopeReadFailure: true });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports an envelope hash mismatch before contract parsing", () => {
    // Arrange
    const scenario = createScenario({ expectedEnvelopeSha256: "f".repeat(64) });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_SOURCE_HASH_MISMATCH");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports contract parse failure before plan resolution", () => {
    // Arrange
    const invalidEnvelope = "{";
    const scenario = createScenario({ envelopeText: invalidEnvelope });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_UNSUPPORTED_VERSION");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports a missing plan without reading a rejected path", () => {
    // Arrange
    const scenario = createScenario({
      blockedRepositoryPaths: [
        "docs/features/active/portable-handoff-614/plan.md",
      ],
    });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "provider_routing",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports a plan read failure after canonical plan resolution", () => {
    // Arrange
    const scenario = createScenario({ planReadFailure: true });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "provider_routing",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).toHaveBeenLastCalledWith(canonicalPlanPath);
  });

  it("reports provider mismatch before resolving or reading the plan", () => {
    // Arrange
    const scenario = createScenario({ requestProvider: "claude" });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe(
      "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    );
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("preserves primary-error ordering for simultaneous validation failures", () => {
    // Arrange
    const requestWorkspaceRoot = "C:/requested-workspace";
    const scenario = createScenario({
      bindingWorkspaceRoot: "C:/different-workspace",
      requestWorkspaceRoot,
      planSha256: "0".repeat(64),
    });

    // Act
    const result = resolvePortableHandoffAuthority(
      scenario.fileSystem,
      scenario.request,
      "topology",
      scenario.pathBoundary,
    );

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_WORKSPACE_MISMATCH");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(2);
  });

  it.each([
    [
      "valid-ordinary-claude-to-codex.json",
      "codex_topology_policy",
      "codex_model_policy",
    ],
    [
      "valid-parallel-codex-to-claude.json",
      "claude_native_worktree_policy",
      "model_policy",
    ],
  ] as const)(
    "resolves topology and routing for destination provider in %s",
    (fixtureName, topologyPolicy, routingPolicy) => {
      // Arrange
      const topologyScenario = createScenario({ fixtureName });
      const routingScenario = createScenario({ fixtureName });

      // Act
      const topology = resolvePortableHandoffAuthority(
        topologyScenario.fileSystem,
        topologyScenario.request,
        "topology",
        topologyScenario.pathBoundary,
      );
      const routing = resolvePortableHandoffAuthority(
        routingScenario.fileSystem,
        routingScenario.request,
        "provider_routing",
        routingScenario.pathBoundary,
      );

      // Assert
      expect(topology).toMatchObject({
        status: "validated",
        resolution: { topology_policy: topologyPolicy },
      });
      expect(routing).toMatchObject({
        status: "validated",
        resolution: { routing_policy: routingPolicy },
      });
    },
  );
});
