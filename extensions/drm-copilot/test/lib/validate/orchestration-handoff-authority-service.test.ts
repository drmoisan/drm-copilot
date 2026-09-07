import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import * as path from "node:path";
import { describe, expect, it, jest } from "@jest/globals";

import type {
  PortableHandoffProvider,
  PortableHandoffReferenceRequest,
} from "../../../src/mcp-repo-automation-tool-definitions-handoff";
import type { FileSystem } from "../../../src/lib/file-system";
import {
  resolvePortableHandoffAuthority,
  type PortableAuthorityKind,
} from "../../../src/lib/validate/orchestration-handoff-authority-service";
import type {
  CheckoutObservation,
  HandoffCheckoutContext,
} from "../../../src/lib/validate/orchestration-handoff-checkout-context";
import type { HandoffPathBoundary } from "../../../src/lib/validate/orchestration-handoff-path-boundary";

interface EnvelopeFixture {
  binding: {
    repository_id: string;
    workspace_root: string;
    branch: string;
    source_head_sha: string;
    allowed_head_relationship: "equal" | "equal_or_descendant";
  };
  destination: { provider: PortableHandoffProvider };
  identity: { issue_number: number; feature_folder: string; work_mode: string };
  plan: { path: string; sha256: string };
}

interface ScenarioOptions {
  readonly bindingWorkspaceRoot?: string;
  readonly blockedRepositoryPaths?: readonly string[];
  readonly envelopeText?: string;
  readonly expectedEnvelopeSha256?: string;
  readonly fixtureName?: string;
  readonly handoffEnvelopePath?: string;
  readonly headRelationshipSatisfied?: boolean;
  readonly mutateEnvelope?: (fixture: EnvelopeFixture) => void;
  readonly observation?: CheckoutObservation;
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
  // Snapshotted from the pristine fixture before any envelope mutation, so a
  // mutated envelope can never redefine the values it is validated against.
  const expectedPlanPath = fixture.plan.path;
  const expectedContext = {
    expectedRepositoryId: fixture.binding.repository_id,
    expectedWorkspaceRoot:
      options.requestWorkspaceRoot ?? fixture.binding.workspace_root,
    expectedBranch: fixture.binding.branch,
    expectedSourceHeadSha: fixture.binding.source_head_sha,
    allowedHeadRelationship: fixture.binding.allowed_head_relationship,
    expectedIssueNumber: fixture.identity.issue_number,
    expectedFeatureFolder: fixture.identity.feature_folder,
    expectedWorkMode: fixture.identity.work_mode,
    expectedPlanPath,
    expectedPlanSha256: sha256(planText),
  } as const;
  if (options.bindingWorkspaceRoot !== undefined) {
    fixture.binding.workspace_root = options.bindingWorkspaceRoot;
  }
  options.mutateEnvelope?.(fixture);
  const envelopeText = options.envelopeText ?? JSON.stringify(fixture);
  const handoffEnvelopePath =
    options.handoffEnvelopePath ?? "artifacts/orchestration/handoff.json";
  const request: PortableHandoffReferenceRequest = {
    workspaceRoot: expectedContext.expectedWorkspaceRoot,
    handoffEnvelopePath,
    expectedHandoffEnvelopeSha256:
      options.expectedEnvelopeSha256 ?? sha256(envelopeText),
    destinationProvider:
      options.requestProvider ?? fixture.destination.provider,
    ...expectedContext,
  };
  const observation: CheckoutObservation = options.observation ?? {
    status: "observed",
    repositoryId: expectedContext.expectedRepositoryId,
    workspaceRoot: expectedContext.expectedWorkspaceRoot,
    branch: expectedContext.expectedBranch,
    headSha: expectedContext.expectedSourceHeadSha,
  };
  const observe = jest.fn<(workspaceRoot: string) => CheckoutObservation>(
    () => observation,
  );
  const isHeadRelationshipSatisfied = jest.fn(
    () => options.headRelationshipSatisfied ?? true,
  );
  const checkoutContext: HandoffCheckoutContext = {
    observe,
    isHeadRelationshipSatisfied,
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
      if (repositoryPath === expectedPlanPath) return canonicalPlanPath;
      return null;
    }),
    resolveCreatableTarget: jest.fn(() => null),
  };
  const resolve = (kind: PortableAuthorityKind) =>
    resolvePortableHandoffAuthority(
      fileSystem,
      request,
      kind,
      pathBoundary,
      checkoutContext,
    );
  return {
    fileSystem,
    isHeadRelationshipSatisfied,
    observe,
    pathBoundary,
    readTextFile,
    request,
    resolve,
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
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).not.toHaveBeenCalled();
  });

  it.each(["topology", "provider_routing"] as const)(
    "rejects a canonical plan escape for %s before reading the plan",
    (kind) => {
      // Arrange
      const scenario = createScenario({
        blockedRepositoryPaths: [
          "docs/features/active/portable-handoff-614/plan.md",
        ],
      });

      // Act
      const result = scenario.resolve(kind);

      // Assert
      expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
      expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
      expect(scenario.readTextFile).not.toHaveBeenCalledWith(canonicalPlanPath);
    },
  );

  it("reports an envelope read failure without attempting a plan read", () => {
    // Arrange
    const scenario = createScenario({ envelopeReadFailure: true });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports an envelope hash mismatch before contract parsing", () => {
    // Arrange
    const scenario = createScenario({ expectedEnvelopeSha256: "f".repeat(64) });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_SOURCE_HASH_MISMATCH");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports contract parse failure before plan resolution", () => {
    // Arrange
    const scenario = createScenario({ envelopeText: "{" });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_UNSUPPORTED_VERSION");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports a plan read failure after canonical plan resolution", () => {
    // Arrange
    const scenario = createScenario({ planReadFailure: true });

    // Act
    const result = scenario.resolve("provider_routing");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).toHaveBeenLastCalledWith(canonicalPlanPath);
  });

  it("reports provider mismatch before resolving or reading the plan", () => {
    // Arrange
    const scenario = createScenario({ requestProvider: "claude" });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe(
      "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    );
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("preserves primary-error ordering for simultaneous validation failures", () => {
    // Arrange
    const scenario = createScenario({
      bindingWorkspaceRoot: "C:/different-workspace",
      requestWorkspaceRoot: "C:/requested-workspace",
      planSha256: "0".repeat(64),
    });

    // Act
    const result = scenario.resolve("topology");

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
      const topology = topologyScenario.resolve("topology");
      const routing = routingScenario.resolve("provider_routing");

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

type MutationTarget = "binding" | "identity" | "plan";

/** Overwrite exactly one envelope field so each case isolates one binding. */
function mutate(
  section: MutationTarget,
  key: string,
  value: string | number,
): (fixture: EnvelopeFixture) => void {
  return (fixture) => {
    (fixture[section] as Record<string, unknown>)[key] = value;
  };
}

function observedCheckout(
  overrides: Partial<Omit<CheckoutObservation, "status">> = {},
): CheckoutObservation {
  return {
    status: "observed",
    repositoryId: "github.com/drmoisan/drm-copilot",
    workspaceRoot: "C:/Users/operator/drm-copilot",
    branch: "feature/portable-handoff-614",
    headSha: "0".repeat(40),
    ...overrides,
  };
}

describe("independent binding authority over a mutated envelope", () => {
  it.each([
    ["binding", "repository_id", "gh/x", "HANDOFF_REPOSITORY_MISMATCH"],
    ["binding", "workspace_root", "C:/attacker", "HANDOFF_WORKSPACE_MISMATCH"],
    ["binding", "branch", "feature/other", "HANDOFF_BRANCH_LINEAGE_MISMATCH"],
    ["identity", "issue_number", 999, "HANDOFF_ISSUE_FEATURE_MISMATCH"],
    ["identity", "feature_folder", "docs/x", "HANDOFF_ISSUE_FEATURE_MISMATCH"],
    ["identity", "work_mode", "full-bug", "HANDOFF_ISSUE_FEATURE_MISMATCH"],
    ["plan", "path", "docs/x/plan.md", "HANDOFF_PLAN_PATH_INVALID"],
    ["plan", "sha256", "9".repeat(64), "HANDOFF_PLAN_HASH_MISMATCH"],
  ] as const)(
    "blocks a self-consistent envelope whose %s.%s contradicts the independent context",
    (section, key, value, expectedCode) => {
      // Arrange
      const scenario = createScenario({
        mutateEnvelope: mutate(section, key, value),
      });

      // Act
      const result = scenario.resolve("topology");

      // Assert
      expect(result.status).toBe("blocked");
      expect(result.primaryFailureCode).toBe(expectedCode);
    },
  );

  it.each([
    ["repository", { repositoryId: "gh/x" }, "HANDOFF_REPOSITORY_MISMATCH"],
    ["workspace", { workspaceRoot: "C:/other" }, "HANDOFF_WORKSPACE_MISMATCH"],
    ["branch", { branch: "other" }, "HANDOFF_BRANCH_LINEAGE_MISMATCH"],
  ] as const)(
    "blocks when the observed checkout %s contradicts the independent context",
    (_field, override, expectedCode) => {
      // Arrange
      const scenario = createScenario({
        observation: observedCheckout(override),
      });

      // Act
      const result = scenario.resolve("topology");

      // Assert
      expect(result.status).toBe("blocked");
      expect(result.primaryFailureCode).toBe(expectedCode);
    },
  );

  it("blocks an equal_or_descendant relationship the boundary reports as unrelated", () => {
    // Arrange
    const scenario = createScenario({ headRelationshipSatisfied: false });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_BRANCH_LINEAGE_MISMATCH");
  });

  it("blocks an equal relationship whose observed HEAD differs from the expected source HEAD", () => {
    // Arrange
    const observedHeadSha = "d".repeat(40);
    const scenario = createScenario({
      headRelationshipSatisfied: false,
      mutateEnvelope: mutate("binding", "allowed_head_relationship", "equal"),
      observation: observedCheckout({ headSha: observedHeadSha }),
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_BRANCH_LINEAGE_MISMATCH");
    expect(scenario.isHeadRelationshipSatisfied).toHaveBeenCalledWith(
      expect.objectContaining({ observedHeadSha }),
    );
  });

  it("delegates relationship validity to the boundary using only independent values", () => {
    // Arrange
    const scenario = createScenario({
      mutateEnvelope: mutate("binding", "allowed_head_relationship", "equal"),
    });

    // Act
    scenario.resolve("topology");

    // Assert
    expect(scenario.isHeadRelationshipSatisfied).toHaveBeenCalledWith({
      workspaceRoot: scenario.request.expectedWorkspaceRoot,
      expectedSourceHeadSha: scenario.request.expectedSourceHeadSha,
      observedHeadSha: scenario.request.expectedSourceHeadSha,
      allowedHeadRelationship: scenario.request.allowedHeadRelationship,
    });
  });

  it("fails closed when the checkout observation is unavailable", () => {
    // Arrange
    const scenario = createScenario({
      observation: { status: "unavailable", reason: "git is unavailable" },
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
  });

  it("selects registry-order precedence when several bindings are invalid at once", () => {
    // Arrange
    const scenario = createScenario({
      mutateEnvelope: (fixture) => {
        mutate("binding", "repository_id", "github.com/x/y")(fixture);
        mutate("binding", "workspace_root", "C:/attacker")(fixture);
        mutate("identity", "issue_number", 999)(fixture);
        mutate("plan", "sha256", "9".repeat(64))(fixture);
      },
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_REPOSITORY_MISMATCH");
  });

  it("performs no filesystem write and no Git mutation while validating", () => {
    // Arrange
    const scenario = createScenario({
      mutateEnvelope: mutate("binding", "branch", "feature/other"),
    });

    // Act
    scenario.resolve("provider_routing");

    // Assert
    expect(scenario.fileSystem.writeTextFile).not.toHaveBeenCalled();
    expect(scenario.fileSystem.ensureDir).not.toHaveBeenCalled();
    expect(scenario.observe).toHaveBeenCalledWith(
      scenario.request.expectedWorkspaceRoot,
    );
  });
});
