# Authority-Service Split Verbatim Check (P1-T5)

Timestamp: 2026-10-09T03-12
Task: [P1-T5]
Working directory: worktree root
Command: (a) git blame -s --contents extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-test-support.ts origin/main -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts; (b) git blame -s --contents extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts origin/main -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts; (c) git blame -s --contents extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-binding.test.ts origin/main -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts
EXIT_CODE: 0 (each of the three commands exited 0)

Zero lines (Grep tool, pattern `^0+ `, line numbers on, over the recorded outputs):

| Output | Zero lines | Anchor line | Lines from anchor to end | Non-zero lines from anchor to end |
| --- | --- | --- | --- | --- |
| (a) support | 4, 22, 39, 63, 75 | 22 `export interface EnvelopeFixture {` | 158 (22-179) | 154 |
| (b) retained | 1, 3, 4, 5 | 7 `describe("portable orchestration handoff authority service", () => {` | 148 (7-154) | 148 |
| (c) binding | 1, 3, 5, 6, 7 | 9 `type MutationTarget = "binding" \| "identity" \| "plan";` | 171 (9-179) | 171 |

- (a): the zero lines are line 4 (`import { jest } from "@jest/globals";`, before the anchor) plus exactly the four declaration lines carrying the added `export ` (lines 22, 39, 63, 75). Anchor line plus the 157 lines after it hold 154 non-zero lines. PASS.
- (b): every zero line (1, 3, 4, 5) precedes the anchor at line 7; the anchor and the 147 lines after it carry non-zero commits. PASS.
- (c): every zero line (1, 3, 5, 6, 7) precedes the anchor at line 9; the anchor and the 170 lines after it carry non-zero commits. PASS.

Output Summary: Pass (AC-10 verbatim half). All three commands exit 0. The moved support, retained, and binding blocks are byte-identical to the origin/main source lines apart from the four planned `export ` prefixes; only import lines are new.

## Output (a), verbatim

```
803464e0a   1) import { createHash } from "node:crypto";
803464e0a   2) import { readFileSync } from "node:fs";
803464e0a   3) import * as path from "node:path";
000000000   4) import { jest } from "@jest/globals";
803464e0a   5) 
803464e0a   6) import type {
803464e0a   7)   PortableHandoffProvider,
c81de764f   8)   PortableHandoffWorkMode,
803464e0a   9)   PortableHandoffReferenceRequest,
803464e0a  10) } from "../../../src/mcp-repo-automation-tool-definitions-handoff";
803464e0a  11) import type { FileSystem } from "../../../src/lib/file-system";
d5898c388  12) import {
d5898c388  13)   resolvePortableHandoffAuthority,
d5898c388  14)   type PortableAuthorityKind,
d5898c388  15) } from "../../../src/lib/validate/orchestration-handoff-authority-service";
d5898c388  16) import type {
d5898c388  17)   CheckoutObservation,
d5898c388  18)   HandoffCheckoutContext,
d5898c388  19) } from "../../../src/lib/validate/orchestration-handoff-checkout-context";
803464e0a  20) import type { HandoffPathBoundary } from "../../../src/lib/validate/orchestration-handoff-path-boundary";
803464e0a  21) 
000000000  22) export interface EnvelopeFixture {
d5898c388  23)   binding: {
d5898c388  24)     repository_id: string;
d5898c388  25)     workspace_root: string;
d5898c388  26)     branch: string;
d5898c388  27)     source_head_sha: string;
d5898c388  28)     allowed_head_relationship: "equal" | "equal_or_descendant";
d5898c388  29)   };
d5898c388  30)   destination: { provider: PortableHandoffProvider };
c81de764f  31)   identity: {
c81de764f  32)     issue_number: number;
c81de764f  33)     feature_folder: string;
c81de764f  34)     work_mode: PortableHandoffWorkMode;
c81de764f  35)   };
d5898c388  36)   plan: { path: string; sha256: string };
803464e0a  37) }
803464e0a  38) 
000000000  39) export interface ScenarioOptions {
803464e0a  40)   readonly bindingWorkspaceRoot?: string;
803464e0a  41)   readonly blockedRepositoryPaths?: readonly string[];
803464e0a  42)   readonly envelopeText?: string;
803464e0a  43)   readonly expectedEnvelopeSha256?: string;
803464e0a  44)   readonly fixtureName?: string;
803464e0a  45)   readonly handoffEnvelopePath?: string;
d5898c388  46)   readonly headRelationshipSatisfied?: boolean;
d5898c388  47)   readonly mutateEnvelope?: (fixture: EnvelopeFixture) => void;
d5898c388  48)   readonly observation?: CheckoutObservation;
803464e0a  49)   readonly planReadFailure?: boolean;
803464e0a  50)   readonly planSha256?: string;
803464e0a  51)   readonly planText?: string;
803464e0a  52)   readonly requestProvider?: PortableHandoffProvider;
803464e0a  53)   readonly requestWorkspaceRoot?: string;
803464e0a  54)   readonly envelopeReadFailure?: boolean;
803464e0a  55) }
803464e0a  56) 
803464e0a  57) const fixtureRoot = path.resolve(
803464e0a  58)   __dirname,
803464e0a  59)   "../../../../../tests/fixtures/orchestration-handoff/contract",
803464e0a  60) );
803464e0a  61) const canonicalWorkspaceRoot = "C:/canonical-workspace";
803464e0a  62) const canonicalEnvelopePath = `${canonicalWorkspaceRoot}/handoff.json`;
000000000  63) export const canonicalPlanPath = `${canonicalWorkspaceRoot}/plan.md`;
803464e0a  64) 
803464e0a  65) function sha256(content: string): string {
803464e0a  66)   return createHash("sha256").update(content, "utf8").digest("hex");
803464e0a  67) }
803464e0a  68) 
803464e0a  69) function loadFixture(name: string): EnvelopeFixture {
803464e0a  70)   return JSON.parse(
803464e0a  71)     readFileSync(path.join(fixtureRoot, name), "utf8"),
803464e0a  72)   ) as EnvelopeFixture;
803464e0a  73) }
803464e0a  74) 
000000000  75) export function createScenario(options: ScenarioOptions = {}) {
803464e0a  76)   const fixture = loadFixture(
803464e0a  77)     options.fixtureName ?? "valid-ordinary-claude-to-codex.json",
803464e0a  78)   );
803464e0a  79)   const planText = options.planText ?? "# Atomic plan\n";
803464e0a  80)   fixture.plan.sha256 = options.planSha256 ?? sha256(planText);
d5898c388  81)   // Snapshotted from the pristine fixture before any envelope mutation, so a
d5898c388  82)   // mutated envelope can never redefine the values it is validated against.
d5898c388  83)   const expectedPlanPath = fixture.plan.path;
d5898c388  84)   const expectedContext = {
d5898c388  85)     expectedRepositoryId: fixture.binding.repository_id,
d5898c388  86)     expectedWorkspaceRoot:
d5898c388  87)       options.requestWorkspaceRoot ?? fixture.binding.workspace_root,
d5898c388  88)     expectedBranch: fixture.binding.branch,
d5898c388  89)     expectedSourceHeadSha: fixture.binding.source_head_sha,
d5898c388  90)     allowedHeadRelationship: fixture.binding.allowed_head_relationship,
d5898c388  91)     expectedIssueNumber: fixture.identity.issue_number,
d5898c388  92)     expectedFeatureFolder: fixture.identity.feature_folder,
d5898c388  93)     expectedWorkMode: fixture.identity.work_mode,
d5898c388  94)     expectedPlanPath,
d5898c388  95)     expectedPlanSha256: sha256(planText),
d5898c388  96)   } as const;
803464e0a  97)   if (options.bindingWorkspaceRoot !== undefined) {
803464e0a  98)     fixture.binding.workspace_root = options.bindingWorkspaceRoot;
803464e0a  99)   }
d5898c388 100)   options.mutateEnvelope?.(fixture);
803464e0a 101)   const envelopeText = options.envelopeText ?? JSON.stringify(fixture);
803464e0a 102)   const handoffEnvelopePath =
803464e0a 103)     options.handoffEnvelopePath ?? "artifacts/orchestration/handoff.json";
803464e0a 104)   const request: PortableHandoffReferenceRequest = {
d5898c388 105)     workspaceRoot: expectedContext.expectedWorkspaceRoot,
803464e0a 106)     handoffEnvelopePath,
803464e0a 107)     expectedHandoffEnvelopeSha256:
803464e0a 108)       options.expectedEnvelopeSha256 ?? sha256(envelopeText),
803464e0a 109)     destinationProvider:
803464e0a 110)       options.requestProvider ?? fixture.destination.provider,
d5898c388 111)     ...expectedContext,
d5898c388 112)   };
d5898c388 113)   const observation: CheckoutObservation = options.observation ?? {
d5898c388 114)     status: "observed",
d5898c388 115)     repositoryId: expectedContext.expectedRepositoryId,
d5898c388 116)     workspaceRoot: expectedContext.expectedWorkspaceRoot,
d5898c388 117)     branch: expectedContext.expectedBranch,
d5898c388 118)     headSha: expectedContext.expectedSourceHeadSha,
d5898c388 119)   };
d5898c388 120)   const observe = jest.fn<(workspaceRoot: string) => CheckoutObservation>(
d5898c388 121)     () => observation,
d5898c388 122)   );
c81de764f 123)   const isHeadRelationshipSatisfied = jest.fn<
c81de764f 124)     HandoffCheckoutContext["isHeadRelationshipSatisfied"]
c81de764f 125)   >(() => options.headRelationshipSatisfied ?? true);
d5898c388 126)   const checkoutContext: HandoffCheckoutContext = {
d5898c388 127)     observe,
d5898c388 128)     isHeadRelationshipSatisfied,
803464e0a 129)   };
803464e0a 130)   const blockedPaths = new Set(options.blockedRepositoryPaths ?? []);
803464e0a 131)   const readTextFile = jest.fn((filePath: string): string => {
803464e0a 132)     if (filePath === canonicalEnvelopePath) {
803464e0a 133)       if (options.envelopeReadFailure === true) throw new Error("read failed");
803464e0a 134)       return envelopeText;
803464e0a 135)     }
803464e0a 136)     if (filePath === canonicalPlanPath) {
803464e0a 137)       if (options.planReadFailure === true) throw new Error("read failed");
803464e0a 138)       return planText;
803464e0a 139)     }
803464e0a 140)     throw new Error(`Unexpected read: ${filePath}`);
803464e0a 141)   });
803464e0a 142)   const fileSystem = {
803464e0a 143)     glob: jest.fn(() => []),
803464e0a 144)     isFile: jest.fn(() => true),
803464e0a 145)     exists: jest.fn(() => true),
803464e0a 146)     isDirectory: jest.fn(() => false),
803464e0a 147)     listDirectory: jest.fn(() => []),
803464e0a 148)     readTextFile,
803464e0a 149)     writeTextFile: jest.fn(),
803464e0a 150)     ensureDir: jest.fn(),
803464e0a 151)   } satisfies FileSystem;
803464e0a 152)   const pathBoundary: HandoffPathBoundary = {
803464e0a 153)     resolveWorkspaceRoot: jest.fn(() => canonicalWorkspaceRoot),
c81de764f 154)     resolveExistingTarget: jest.fn((_root: string, repositoryPath: string) => {
803464e0a 155)       if (blockedPaths.has(repositoryPath)) return null;
803464e0a 156)       if (repositoryPath === handoffEnvelopePath) return canonicalEnvelopePath;
d5898c388 157)       if (repositoryPath === expectedPlanPath) return canonicalPlanPath;
803464e0a 158)       return null;
803464e0a 159)     }),
803464e0a 160)     resolveCreatableTarget: jest.fn(() => null),
803464e0a 161)   };
d5898c388 162)   const resolve = (kind: PortableAuthorityKind) =>
d5898c388 163)     resolvePortableHandoffAuthority(
d5898c388 164)       fileSystem,
d5898c388 165)       request,
d5898c388 166)       kind,
d5898c388 167)       pathBoundary,
d5898c388 168)       checkoutContext,
d5898c388 169)     );
803464e0a 170)   return {
803464e0a 171)     fileSystem,
d5898c388 172)     isHeadRelationshipSatisfied,
d5898c388 173)     observe,
803464e0a 174)     pathBoundary,
803464e0a 175)     readTextFile,
803464e0a 176)     request,
d5898c388 177)     resolve,
803464e0a 178)   };
803464e0a 179) }
```

## Output (b), verbatim

```
000000000   1) import { describe, expect, it } from "@jest/globals";
d5898c388   2) import {
000000000   3)   canonicalPlanPath,
000000000   4)   createScenario,
000000000   5) } from "./orchestration-handoff-authority-service-test-support";
803464e0a   6) 
803464e0a   7) describe("portable orchestration handoff authority service", () => {
803464e0a   8)   it("rejects a canonical envelope escape before any file read", () => {
803464e0a   9)     // Arrange
803464e0a  10)     const scenario = createScenario({
803464e0a  11)       handoffEnvelopePath: "../handoff.json",
803464e0a  12)       blockedRepositoryPaths: ["../handoff.json"],
803464e0a  13)     });
803464e0a  14) 
803464e0a  15)     // Act
d5898c388  16)     const result = scenario.resolve("topology");
803464e0a  17) 
803464e0a  18)     // Assert
803464e0a  19)     expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
803464e0a  20)     expect(scenario.readTextFile).not.toHaveBeenCalled();
803464e0a  21)   });
803464e0a  22) 
d5898c388  23)   it.each(["topology", "provider_routing"] as const)(
d5898c388  24)     "rejects a canonical plan escape for %s before reading the plan",
d5898c388  25)     (kind) => {
d5898c388  26)       // Arrange
d5898c388  27)       const scenario = createScenario({
d5898c388  28)         blockedRepositoryPaths: [
d5898c388  29)           "docs/features/active/portable-handoff-614/plan.md",
d5898c388  30)         ],
d5898c388  31)       });
803464e0a  32) 
d5898c388  33)       // Act
d5898c388  34)       const result = scenario.resolve(kind);
803464e0a  35) 
d5898c388  36)       // Assert
d5898c388  37)       expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
d5898c388  38)       expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
d5898c388  39)       expect(scenario.readTextFile).not.toHaveBeenCalledWith(canonicalPlanPath);
d5898c388  40)     },
d5898c388  41)   );
803464e0a  42) 
803464e0a  43)   it("reports an envelope read failure without attempting a plan read", () => {
803464e0a  44)     // Arrange
803464e0a  45)     const scenario = createScenario({ envelopeReadFailure: true });
803464e0a  46) 
803464e0a  47)     // Act
d5898c388  48)     const result = scenario.resolve("topology");
803464e0a  49) 
803464e0a  50)     // Assert
803464e0a  51)     expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
803464e0a  52)     expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
803464e0a  53)   });
803464e0a  54) 
803464e0a  55)   it("reports an envelope hash mismatch before contract parsing", () => {
803464e0a  56)     // Arrange
803464e0a  57)     const scenario = createScenario({ expectedEnvelopeSha256: "f".repeat(64) });
803464e0a  58) 
803464e0a  59)     // Act
d5898c388  60)     const result = scenario.resolve("topology");
803464e0a  61) 
803464e0a  62)     // Assert
803464e0a  63)     expect(result.primaryFailureCode).toBe("HANDOFF_SOURCE_HASH_MISMATCH");
803464e0a  64)     expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
803464e0a  65)   });
803464e0a  66) 
803464e0a  67)   it("reports contract parse failure before plan resolution", () => {
803464e0a  68)     // Arrange
d5898c388  69)     const scenario = createScenario({ envelopeText: "{" });
803464e0a  70) 
803464e0a  71)     // Act
d5898c388  72)     const result = scenario.resolve("topology");
803464e0a  73) 
803464e0a  74)     // Assert
803464e0a  75)     expect(result.primaryFailureCode).toBe("HANDOFF_UNSUPPORTED_VERSION");
803464e0a  76)     expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
803464e0a  77)   });
803464e0a  78) 
803464e0a  79)   it("reports a plan read failure after canonical plan resolution", () => {
803464e0a  80)     // Arrange
803464e0a  81)     const scenario = createScenario({ planReadFailure: true });
803464e0a  82) 
803464e0a  83)     // Act
d5898c388  84)     const result = scenario.resolve("provider_routing");
803464e0a  85) 
803464e0a  86)     // Assert
803464e0a  87)     expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
803464e0a  88)     expect(scenario.readTextFile).toHaveBeenLastCalledWith(canonicalPlanPath);
803464e0a  89)   });
803464e0a  90) 
803464e0a  91)   it("reports provider mismatch before resolving or reading the plan", () => {
803464e0a  92)     // Arrange
803464e0a  93)     const scenario = createScenario({ requestProvider: "claude" });
803464e0a  94) 
803464e0a  95)     // Act
d5898c388  96)     const result = scenario.resolve("topology");
803464e0a  97) 
803464e0a  98)     // Assert
803464e0a  99)     expect(result.primaryFailureCode).toBe(
803464e0a 100)       "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
803464e0a 101)     );
803464e0a 102)     expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
803464e0a 103)   });
803464e0a 104) 
803464e0a 105)   it("preserves primary-error ordering for simultaneous validation failures", () => {
803464e0a 106)     // Arrange
803464e0a 107)     const scenario = createScenario({
803464e0a 108)       bindingWorkspaceRoot: "C:/different-workspace",
d5898c388 109)       requestWorkspaceRoot: "C:/requested-workspace",
803464e0a 110)       planSha256: "0".repeat(64),
803464e0a 111)     });
803464e0a 112) 
803464e0a 113)     // Act
d5898c388 114)     const result = scenario.resolve("topology");
803464e0a 115) 
803464e0a 116)     // Assert
803464e0a 117)     expect(result.primaryFailureCode).toBe("HANDOFF_WORKSPACE_MISMATCH");
803464e0a 118)     expect(scenario.readTextFile).toHaveBeenCalledTimes(2);
803464e0a 119)   });
803464e0a 120) 
803464e0a 121)   it.each([
803464e0a 122)     [
803464e0a 123)       "valid-ordinary-claude-to-codex.json",
803464e0a 124)       "codex_topology_policy",
803464e0a 125)       "codex_model_policy",
803464e0a 126)     ],
803464e0a 127)     [
803464e0a 128)       "valid-parallel-codex-to-claude.json",
803464e0a 129)       "claude_native_worktree_policy",
803464e0a 130)       "model_policy",
803464e0a 131)     ],
803464e0a 132)   ] as const)(
803464e0a 133)     "resolves topology and routing for destination provider in %s",
803464e0a 134)     (fixtureName, topologyPolicy, routingPolicy) => {
803464e0a 135)       // Arrange
803464e0a 136)       const topologyScenario = createScenario({ fixtureName });
803464e0a 137)       const routingScenario = createScenario({ fixtureName });
803464e0a 138) 
803464e0a 139)       // Act
d5898c388 140)       const topology = topologyScenario.resolve("topology");
d5898c388 141)       const routing = routingScenario.resolve("provider_routing");
803464e0a 142) 
803464e0a 143)       // Assert
803464e0a 144)       expect(topology).toMatchObject({
803464e0a 145)         status: "validated",
803464e0a 146)         resolution: { topology_policy: topologyPolicy },
803464e0a 147)       });
803464e0a 148)       expect(routing).toMatchObject({
803464e0a 149)         status: "validated",
803464e0a 150)         resolution: { routing_policy: routingPolicy },
803464e0a 151)       });
803464e0a 152)     },
803464e0a 153)   );
803464e0a 154) });
```

## Output (c), verbatim

```
000000000   1) import { describe, expect, it } from "@jest/globals";
803464e0a   2) 
000000000   3) import type { CheckoutObservation } from "../../../src/lib/validate/orchestration-handoff-checkout-context";
d5898c388   4) import {
000000000   5)   createScenario,
000000000   6)   type EnvelopeFixture,
000000000   7) } from "./orchestration-handoff-authority-service-test-support";
d5898c388   8) 
d5898c388   9) type MutationTarget = "binding" | "identity" | "plan";
d5898c388  10) 
d5898c388  11) /** Overwrite exactly one envelope field so each case isolates one binding. */
d5898c388  12) function mutate(
d5898c388  13)   section: MutationTarget,
d5898c388  14)   key: string,
d5898c388  15)   value: string | number,
d5898c388  16) ): (fixture: EnvelopeFixture) => void {
d5898c388  17)   return (fixture) => {
d5898c388  18)     (fixture[section] as Record<string, unknown>)[key] = value;
d5898c388  19)   };
d5898c388  20) }
d5898c388  21) 
d5898c388  22) function observedCheckout(
d5898c388  23)   overrides: Partial<Omit<CheckoutObservation, "status">> = {},
d5898c388  24) ): CheckoutObservation {
d5898c388  25)   return {
d5898c388  26)     status: "observed",
d5898c388  27)     repositoryId: "github.com/drmoisan/drm-copilot",
d5898c388  28)     workspaceRoot: "C:/Users/operator/drm-copilot",
d5898c388  29)     branch: "feature/portable-handoff-614",
d5898c388  30)     headSha: "0".repeat(40),
d5898c388  31)     ...overrides,
d5898c388  32)   };
d5898c388  33) }
d5898c388  34) 
d5898c388  35) describe("independent binding authority over a mutated envelope", () => {
d5898c388  36)   it.each([
d5898c388  37)     ["binding", "repository_id", "gh/x", "HANDOFF_REPOSITORY_MISMATCH"],
d5898c388  38)     ["binding", "workspace_root", "C:/attacker", "HANDOFF_WORKSPACE_MISMATCH"],
d5898c388  39)     ["binding", "branch", "feature/other", "HANDOFF_BRANCH_LINEAGE_MISMATCH"],
d5898c388  40)     ["identity", "issue_number", 999, "HANDOFF_ISSUE_FEATURE_MISMATCH"],
d5898c388  41)     ["identity", "feature_folder", "docs/x", "HANDOFF_ISSUE_FEATURE_MISMATCH"],
d5898c388  42)     ["identity", "work_mode", "full-bug", "HANDOFF_ISSUE_FEATURE_MISMATCH"],
d5898c388  43)     ["plan", "path", "docs/x/plan.md", "HANDOFF_PLAN_PATH_INVALID"],
d5898c388  44)     ["plan", "sha256", "9".repeat(64), "HANDOFF_PLAN_HASH_MISMATCH"],
d5898c388  45)   ] as const)(
d5898c388  46)     "blocks a self-consistent envelope whose %s.%s contradicts the independent context",
d5898c388  47)     (section, key, value, expectedCode) => {
d5898c388  48)       // Arrange
d5898c388  49)       const scenario = createScenario({
d5898c388  50)         mutateEnvelope: mutate(section, key, value),
d5898c388  51)       });
d5898c388  52) 
d5898c388  53)       // Act
d5898c388  54)       const result = scenario.resolve("topology");
d5898c388  55) 
d5898c388  56)       // Assert
d5898c388  57)       expect(result.status).toBe("blocked");
d5898c388  58)       expect(result.primaryFailureCode).toBe(expectedCode);
d5898c388  59)     },
d5898c388  60)   );
d5898c388  61) 
d5898c388  62)   it.each([
d5898c388  63)     ["repository", { repositoryId: "gh/x" }, "HANDOFF_REPOSITORY_MISMATCH"],
d5898c388  64)     ["workspace", { workspaceRoot: "C:/other" }, "HANDOFF_WORKSPACE_MISMATCH"],
d5898c388  65)     ["branch", { branch: "other" }, "HANDOFF_BRANCH_LINEAGE_MISMATCH"],
d5898c388  66)   ] as const)(
d5898c388  67)     "blocks when the observed checkout %s contradicts the independent context",
d5898c388  68)     (_field, override, expectedCode) => {
d5898c388  69)       // Arrange
d5898c388  70)       const scenario = createScenario({
d5898c388  71)         observation: observedCheckout(override),
d5898c388  72)       });
d5898c388  73) 
d5898c388  74)       // Act
d5898c388  75)       const result = scenario.resolve("topology");
d5898c388  76) 
d5898c388  77)       // Assert
d5898c388  78)       expect(result.status).toBe("blocked");
d5898c388  79)       expect(result.primaryFailureCode).toBe(expectedCode);
d5898c388  80)     },
d5898c388  81)   );
d5898c388  82) 
d5898c388  83)   it("blocks an equal_or_descendant relationship the boundary reports as unrelated", () => {
d5898c388  84)     // Arrange
d5898c388  85)     const scenario = createScenario({ headRelationshipSatisfied: false });
d5898c388  86) 
d5898c388  87)     // Act
d5898c388  88)     const result = scenario.resolve("topology");
d5898c388  89) 
d5898c388  90)     // Assert
d5898c388  91)     expect(result.primaryFailureCode).toBe("HANDOFF_BRANCH_LINEAGE_MISMATCH");
d5898c388  92)   });
d5898c388  93) 
d5898c388  94)   it("blocks an equal relationship whose observed HEAD differs from the expected source HEAD", () => {
d5898c388  95)     // Arrange
d5898c388  96)     const observedHeadSha = "d".repeat(40);
d5898c388  97)     const scenario = createScenario({
d5898c388  98)       headRelationshipSatisfied: false,
d5898c388  99)       mutateEnvelope: mutate("binding", "allowed_head_relationship", "equal"),
d5898c388 100)       observation: observedCheckout({ headSha: observedHeadSha }),
d5898c388 101)     });
d5898c388 102) 
d5898c388 103)     // Act
d5898c388 104)     const result = scenario.resolve("topology");
d5898c388 105) 
d5898c388 106)     // Assert
d5898c388 107)     expect(result.primaryFailureCode).toBe("HANDOFF_BRANCH_LINEAGE_MISMATCH");
d5898c388 108)     expect(scenario.isHeadRelationshipSatisfied).toHaveBeenCalledWith(
d5898c388 109)       expect.objectContaining({ observedHeadSha }),
d5898c388 110)     );
d5898c388 111)   });
d5898c388 112) 
d5898c388 113)   it("delegates relationship validity to the boundary using only independent values", () => {
d5898c388 114)     // Arrange
d5898c388 115)     const scenario = createScenario({
d5898c388 116)       mutateEnvelope: mutate("binding", "allowed_head_relationship", "equal"),
d5898c388 117)     });
d5898c388 118) 
d5898c388 119)     // Act
d5898c388 120)     scenario.resolve("topology");
d5898c388 121) 
d5898c388 122)     // Assert
d5898c388 123)     expect(scenario.isHeadRelationshipSatisfied).toHaveBeenCalledWith({
d5898c388 124)       workspaceRoot: scenario.request.expectedWorkspaceRoot,
d5898c388 125)       expectedSourceHeadSha: scenario.request.expectedSourceHeadSha,
d5898c388 126)       observedHeadSha: scenario.request.expectedSourceHeadSha,
d5898c388 127)       allowedHeadRelationship: scenario.request.allowedHeadRelationship,
d5898c388 128)     });
d5898c388 129)   });
d5898c388 130) 
d5898c388 131)   it("fails closed when the checkout observation is unavailable", () => {
d5898c388 132)     // Arrange
d5898c388 133)     const scenario = createScenario({
d5898c388 134)       observation: { status: "unavailable", reason: "git is unavailable" },
d5898c388 135)     });
d5898c388 136) 
d5898c388 137)     // Act
d5898c388 138)     const result = scenario.resolve("topology");
d5898c388 139) 
d5898c388 140)     // Assert
d5898c388 141)     expect(result.status).toBe("blocked");
d5898c388 142)     expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
d5898c388 143)   });
d5898c388 144) 
d5898c388 145)   it("selects registry-order precedence when several bindings are invalid at once", () => {
d5898c388 146)     // Arrange
d5898c388 147)     const scenario = createScenario({
d5898c388 148)       mutateEnvelope: (fixture) => {
d5898c388 149)         mutate("binding", "repository_id", "github.com/x/y")(fixture);
d5898c388 150)         mutate("binding", "workspace_root", "C:/attacker")(fixture);
d5898c388 151)         mutate("identity", "issue_number", 999)(fixture);
d5898c388 152)         mutate("plan", "sha256", "9".repeat(64))(fixture);
d5898c388 153)       },
d5898c388 154)     });
d5898c388 155) 
d5898c388 156)     // Act
d5898c388 157)     const result = scenario.resolve("topology");
d5898c388 158) 
d5898c388 159)     // Assert
d5898c388 160)     expect(result.primaryFailureCode).toBe("HANDOFF_REPOSITORY_MISMATCH");
d5898c388 161)   });
d5898c388 162) 
d5898c388 163)   it("performs no filesystem write and no Git mutation while validating", () => {
d5898c388 164)     // Arrange
d5898c388 165)     const scenario = createScenario({
d5898c388 166)       mutateEnvelope: mutate("binding", "branch", "feature/other"),
d5898c388 167)     });
d5898c388 168) 
d5898c388 169)     // Act
d5898c388 170)     scenario.resolve("provider_routing");
d5898c388 171) 
d5898c388 172)     // Assert
d5898c388 173)     expect(scenario.fileSystem.writeTextFile).not.toHaveBeenCalled();
d5898c388 174)     expect(scenario.fileSystem.ensureDir).not.toHaveBeenCalled();
d5898c388 175)     expect(scenario.observe).toHaveBeenCalledWith(
d5898c388 176)       scenario.request.expectedWorkspaceRoot,
d5898c388 177)     );
d5898c388 178)   });
d5898c388 179) });
```
