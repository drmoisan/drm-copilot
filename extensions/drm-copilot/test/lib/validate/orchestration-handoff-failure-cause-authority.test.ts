import { describe, expect, it } from "@jest/globals";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import * as path from "node:path";

import type { FileSystem } from "../../../src/lib/file-system";
import { resolvePortableHandoffAuthority } from "../../../src/lib/validate/orchestration-handoff-authority-service";
import type { HandoffCheckoutContext } from "../../../src/lib/validate/orchestration-handoff-checkout-context";
import type { HandoffFailureCode } from "../../../src/lib/validate/orchestration-handoff-contract";
import type { HandoffPathBoundary } from "../../../src/lib/validate/orchestration-handoff-path-boundary";
import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
} from "../../../src/mcp-repo-automation-tool-definitions-handoff";

/**
 * Issue #645 (R18): the authority service's blocked results carry a
 * redaction-safe `<stage>: <token>` failure cause. Split from
 * `orchestration-handoff-failure-cause.test.ts` on the 480-line overflow
 * recorded by the P5-T11 placement decision.
 */

/** An error carrying a system code and a message that names an absolute path. */
function codedError(code: string): Error {
  return Object.assign(
    new Error("operation failed for /home/operator/private/secret.json"),
    { code },
  );
}

interface AuthorityFixture {
  binding: Record<string, string>;
  destination: { provider: "claude" | "codex" };
  identity: { issue_number: number; feature_folder: string; work_mode: string };
  plan: { path: string; sha256: string };
}

interface AuthorityCase {
  readonly row: string;
  readonly envelopeReadError?: Error;
  readonly planReadError?: Error;
  readonly unresolved?: "workspace-root" | "envelope" | "plan";
  readonly code: HandoffFailureCode | null;
  readonly cause: string | undefined;
}

function hashText(text: string): string {
  return createHash("sha256").update(text, "utf8").digest("hex");
}

function runAuthority(scenario: AuthorityCase): PortableHandoffAuthorityResult {
  const fixture = JSON.parse(
    readFileSync(
      path.resolve(
        __dirname,
        "../../../../../tests/fixtures/orchestration-handoff/contract/valid-ordinary-claude-to-codex.json",
      ),
      "utf8",
    ),
  ) as AuthorityFixture;
  const planText = "# Atomic plan\n";
  fixture.plan.sha256 = hashText(planText);
  const envelopeText = JSON.stringify(fixture);
  const binding = fixture.binding;
  const request = {
    workspaceRoot: binding["workspace_root"],
    handoffEnvelopePath: "artifacts/orchestration/handoff.json",
    expectedHandoffEnvelopeSha256: hashText(envelopeText),
    destinationProvider: fixture.destination.provider,
    expectedRepositoryId: binding["repository_id"],
    expectedWorkspaceRoot: binding["workspace_root"],
    expectedBranch: binding["branch"],
    expectedSourceHeadSha: binding["source_head_sha"],
    allowedHeadRelationship: binding["allowed_head_relationship"],
    expectedIssueNumber: fixture.identity.issue_number,
    expectedFeatureFolder: fixture.identity.feature_folder,
    expectedWorkMode: fixture.identity.work_mode,
    expectedPlanPath: fixture.plan.path,
    expectedPlanSha256: hashText(planText),
  } as PortableHandoffReferenceRequest;
  const envelopePath = "/canonical/handoff.json";
  const planPath = "/canonical/plan.md";
  const pathBoundary: HandoffPathBoundary = {
    resolveWorkspaceRoot: () =>
      scenario.unresolved === "workspace-root" ? null : "/canonical",
    resolveExistingTarget: (_root, repositoryPath) => {
      if (repositoryPath === request.handoffEnvelopePath) {
        return scenario.unresolved === "envelope" ? null : envelopePath;
      }
      return scenario.unresolved === "plan" ? null : planPath;
    },
    resolveCreatableTarget: () => null,
  };
  const fileSystem = {
    glob: () => [],
    isFile: () => true,
    exists: () => true,
    isDirectory: () => false,
    listDirectory: () => [],
    readTextFile: (filePath: string) => {
      const failure =
        filePath === envelopePath
          ? scenario.envelopeReadError
          : scenario.planReadError;
      if (failure !== undefined) throw failure;
      return filePath === envelopePath ? envelopeText : planText;
    },
    writeTextFile: () => undefined,
    ensureDir: () => undefined,
  } satisfies FileSystem;
  const checkoutContext: HandoffCheckoutContext = {
    observe: () => ({
      status: "observed",
      repositoryId: request.expectedRepositoryId,
      workspaceRoot: request.expectedWorkspaceRoot,
      branch: request.expectedBranch,
      headSha: request.expectedSourceHeadSha,
    }),
    isHeadRelationshipSatisfied: () => true,
  };
  return resolvePortableHandoffAuthority(
    fileSystem,
    request,
    "topology",
    pathBoundary,
    checkoutContext,
  );
}

const AUTHORITY_CASES: readonly AuthorityCase[] = [
  {
    row: "A1 envelope read throws ENOENT",
    envelopeReadError: codedError("ENOENT"),
    code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    cause: "envelope-read: ENOENT",
  },
  {
    row: "A2 plan read throws EACCES",
    planReadError: codedError("EACCES"),
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "plan-read: EACCES",
  },
  {
    row: "A3 workspace root does not resolve",
    unresolved: "workspace-root",
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "workspace-root: unresolved",
  },
  {
    row: "A4 envelope path does not resolve",
    unresolved: "envelope",
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "target-path: unresolved",
  },
  {
    row: "A5 plan path alone does not resolve",
    unresolved: "plan",
    code: "HANDOFF_PLAN_PATH_INVALID",
    cause: "target-path: unresolved",
  },
  {
    row: "A6 all reads succeed with matching hashes",
    code: null,
    cause: undefined,
  },
];

describe("authority blocked-result failure causes", () => {
  it.each(AUTHORITY_CASES)("$row", (scenario) => {
    // Arrange
    const { code, cause } = scenario;

    // Act
    const result = runAuthority(scenario);

    // Assert
    expect(result.primaryFailureCode).toBe(code);
    if (cause === undefined) {
      expect(result.status).toBe("validated");
      expect(result).not.toHaveProperty("failureCause");
    } else {
      expect(result.status).toBe("blocked");
      expect(result.failureCause).toBe(cause);
    }
  });
});
