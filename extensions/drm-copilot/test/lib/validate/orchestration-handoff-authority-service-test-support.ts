import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import * as path from "node:path";
import { jest } from "@jest/globals";

import type {
  PortableHandoffProvider,
  PortableHandoffWorkMode,
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

export interface EnvelopeFixture {
  binding: {
    repository_id: string;
    workspace_root: string;
    branch: string;
    source_head_sha: string;
    allowed_head_relationship: "equal" | "equal_or_descendant";
  };
  destination: { provider: PortableHandoffProvider };
  identity: {
    issue_number: number;
    feature_folder: string;
    work_mode: PortableHandoffWorkMode;
  };
  plan: { path: string; sha256: string };
}

export interface ScenarioOptions {
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
export const canonicalPlanPath = `${canonicalWorkspaceRoot}/plan.md`;

function sha256(content: string): string {
  return createHash("sha256").update(content, "utf8").digest("hex");
}

function loadFixture(name: string): EnvelopeFixture {
  return JSON.parse(
    readFileSync(path.join(fixtureRoot, name), "utf8"),
  ) as EnvelopeFixture;
}

export function createScenario(options: ScenarioOptions = {}) {
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
  const isHeadRelationshipSatisfied = jest.fn<
    HandoffCheckoutContext["isHeadRelationshipSatisfied"]
  >(() => options.headRelationshipSatisfied ?? true);
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
    resolveExistingTarget: jest.fn((_root: string, repositoryPath: string) => {
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
