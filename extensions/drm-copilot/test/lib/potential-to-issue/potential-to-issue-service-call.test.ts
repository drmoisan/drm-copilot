import { describe, expect, it } from "@jest/globals";

import {
  type CommandResult,
  type CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { potentialToIssueServiceCall } from "../../../src/lib/potential-to-issue/potential-to-issue-service-call";
import { resolvePotentialToIssueToolInput } from "../../../src/mcp-tool-inputs";
import {
  FakeGhClient,
  FakePotentialFileSystem,
  type RecordedGhCall,
  WORKSPACE,
} from "./promotion-test-support";

/**
 * Tests for the in-process `potentialToIssueServiceCall` helper (F7). The helper
 * preserves the prior service return contract and the prior non-zero-exit
 * failure surface. All external interactions are injected: a fake
 * {@link FakePotentialFileSystem}, an injected fake gh client, and a recording
 * {@link CommandRunner} stub. No real subprocess, filesystem, or temp file runs.
 */

/** Recording {@link CommandRunner} stub (never reached when gh is injected). */
function makeRunner(recorded: string[][]): CommandRunner {
  return {
    run(args: readonly string[]): CommandResult {
      recorded.push([...args]);
      return { stdout: "", stderr: "", code: 0 };
    },
  };
}

/**
 * Filesystem fake that reports one designated path as absent.
 *
 * Used to drive the receipt post-condition: the promotion still moves the file
 * normally, but the reported destination fails its existence check.
 */
class BlockedPathPotentialFileSystem extends FakePotentialFileSystem {
  /**
   * @param blockedPath Path whose existence check always reports false.
   */
  constructor(private readonly blockedPath: string) {
    super();
  }

  /**
   * @param path Path to test.
   * @returns False for the blocked path; otherwise the inherited answer.
   */
  override exists(path: string): boolean {
    return path === this.blockedPath ? false : super.exists(path);
  }
}

/** Seed a feature potential with all required sections. */
function seedFeature(fs: FakePotentialFileSystem, path: string): void {
  fs.files.set(
    path,
    [
      "# Feature Title",
      "## Problem / Why",
      "why",
      "## Proposed Behavior",
      "behave",
      "## Acceptance Criteria (early draft)",
      "criteria",
      "## Constraints & Risks",
      "risk",
      "## Test Conditions to Consider",
      "tests",
    ].join("\n"),
  );
}

const POTENTIAL = "/workspace/docs/features/potential/sample.md";

/** Slug returned by the injected resolver seam in the resolution tests. */
const RESOLVED_SLUG = "drmoisan/drm-copilot";

/** Workspace root that is not the process working directory. */
const DIFFERING_WORKSPACE = "/other-checkout";

/** Potential record living under {@link DIFFERING_WORKSPACE}. */
const DIFFERING_POTENTIAL = `${DIFFERING_WORKSPACE}/docs/features/potential/sample.md`;

/**
 * Workspace root equal to the process working directory.
 *
 * The promotion workflow joins the workspace root with forward slashes, so the
 * host separator is normalized here and every expected value below is derived
 * from this one constant. That keeps the assertions deterministic on any host.
 */
const PROCESS_ROOT = process.cwd().replace(/\\/g, "/");

/** Potential record living under {@link PROCESS_ROOT}. */
const PROCESS_POTENTIAL = `${PROCESS_ROOT}/docs/features/potential/sample.md`;

/**
 * Recording resolver seam that captures the workspace value it was handed.
 *
 * @param recorded Sink that receives one entry per resolver invocation.
 * @returns A resolver returning {@link RESOLVED_SLUG}.
 */
function makeRecordingResolver(
  recorded: string[],
): (workspaceRoot: string) => string {
  return (workspaceRoot: string): string => {
    recorded.push(workspaceRoot);
    return RESOLVED_SLUG;
  };
}

describe("potentialToIssueServiceCall — success", () => {
  it("returns the preserved tool, workspaceRoot, summary, destinationPath, and artifacts", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
      {
        output: ['{"number":123,"updatedAt":"2024-01-02T00:00:00Z"}'],
        exitCode: 0,
      },
    );

    // Act
    const result = potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: WORKSPACE,
      potentialPath: POTENTIAL,
      promotionType: "feature",
      workMode: "full",
    });

    // Assert
    expect(result.tool).toBe("potential_to_issue");
    expect(result.workspaceRoot).toBe(WORKSPACE);
    expect(result.summary).toBe(
      `Promoted '${POTENTIAL}' as a feature workflow in full mode.`,
    );
    expect(result.destinationPath).toBe(
      "/workspace/docs/features/potential/promoted/sample.md",
    );
    expect(result.artifacts).toEqual(["https://example.com/issues/123"]);
  });

  it("forwards the emitted workflow lines to the injected log sink", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );
    const logged: string[] = [];

    // Act
    potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: WORKSPACE,
      potentialPath: POTENTIAL,
      promotionType: "feature",
      workMode: "full",
      log: (m) => logged.push(m),
    });

    // Assert: the workflow's progress lines reached the log sink.
    expect(logged).toContain("Selected mode: full-feature");
    expect(logged).toContain(
      "Creating issue: Feature: Feature Title (label: feature)",
    );
  });

  it("passes promotionType/workMode/potentialPath/workspaceRoot through to the workflow", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/9"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );

    // Act
    const result = potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: WORKSPACE,
      potentialPath: POTENTIAL,
      promotionType: "refactor",
      workMode: "full",
    });

    // Assert: the create call carried the refactor label; summary reflects inputs.
    const createCall = gh.calls.find(
      (c) => c[0] === "create",
    ) as RecordedGhCall;
    expect(createCall[1][2]).toBe("refactor");
    expect(result.summary).toBe(
      `Promoted '${POTENTIAL}' as a refactor workflow in full mode.`,
    );
  });
});

describe("potentialToIssueServiceCall — target repository resolution", () => {
  it("resolves the target repository from a workspace root that differs from the process working directory", () => {
    // Arrange: an injected fake gh client (so no RealGhClient is constructed and
    // no real gh is located or executed), the in-memory filesystem fake, the
    // recording command runner, and a resolver seam that records the workspace
    // value it was handed.
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, DIFFERING_POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );
    const recordedWorkspaces: string[] = [];

    // Act
    const result = potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: DIFFERING_WORKSPACE,
      potentialPath: DIFFERING_POTENTIAL,
      promotionType: "feature",
      workMode: "full",
      repoSlugResolver: makeRecordingResolver(recordedWorkspaces),
    });

    // Assert: resolution ran exactly once against the supplied workspace root,
    // and the resolved slug is echoed on the returned record.
    expect(recordedWorkspaces).toEqual([DIFFERING_WORKSPACE]);
    expect(result.targetRepository).toBe(RESOLVED_SLUG);
  });

  it("resolves the target repository when the workspace root matches the process working directory", () => {
    // Arrange: the same-repository case (R3). The workspace root is the process
    // working directory, and the gh client is again an injected fake, so no
    // RealGhClient is constructed and no real gh is located or executed.
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, PROCESS_POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );
    const recordedWorkspaces: string[] = [];

    // Act
    const result = potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: PROCESS_ROOT,
      potentialPath: PROCESS_POTENTIAL,
      promotionType: "feature",
      workMode: "full",
      repoSlugResolver: makeRecordingResolver(recordedWorkspaces),
    });

    // Assert: resolution ran against that checkout and its slug is echoed.
    expect(recordedWorkspaces).toEqual([PROCESS_ROOT]);
    expect(result.targetRepository).toBe(RESOLVED_SLUG);

    // Assert: every pre-existing element of the result is unchanged in form and
    // value. These three assertions carry the same expected values as the
    // pre-existing success test, rebased only on the workspace root in use.
    expect(result.summary).toBe(
      `Promoted '${PROCESS_POTENTIAL}' as a feature workflow in full mode.`,
    );
    expect(result.destinationPath).toBe(
      `${PROCESS_ROOT}/docs/features/potential/promoted/sample.md`,
    );
    expect(result.artifacts).toEqual(["https://example.com/issues/123"]);
  });
});

describe("potentialToIssueServiceCall — relative potential_path summary (AC-6)", () => {
  it("pins the summary form to the workspace-resolved absolute path for a relative input", () => {
    // Arrange: a workspace-relative potential_path is normalized by the resolver
    // against WORKSPACE, then handed to the service call. The summary must echo
    // the resolved absolute path, not the original relative text.
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/7"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );
    const resolved = resolvePotentialToIssueToolInput({
      workspace_root: WORKSPACE,
      potential_path: "docs/features/potential/sample.md",
      promotion_type: "feature",
      work_mode: "full",
    });

    // Act
    const result = potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: resolved.workspaceRoot,
      potentialPath: resolved.potentialPath,
      promotionType: resolved.promotionType,
      workMode: resolved.workMode,
    });

    // Assert: the resolved absolute path equals POTENTIAL and the summary pins it.
    expect(resolved.potentialPath).toBe(POTENTIAL);
    expect(result.summary).toBe(
      `Promoted '${POTENTIAL}' as a feature workflow in full mode.`,
    );
  });
});

describe("potentialToIssueServiceCall — failure surface", () => {
  it("throws preserving the prior non-zero-exit contract with the gh output", () => {
    // Arrange: gh create returns a non-zero exit (non-missing-label).
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient({
      output: ["gh: forbidden", "exit"],
      exitCode: 2,
    });

    // Act / Assert: the thrown Error preserves "Command exited with code 2."
    expect(() =>
      potentialToIssueServiceCall({
        fileSystem: fs,
        runner: makeRunner([]),
        gh,
        workspaceRoot: WORKSPACE,
        potentialPath: POTENTIAL,
        promotionType: "feature",
        workMode: "full",
      }),
    ).toThrow("Command exited with code 2.");
  });

  it("propagates a PromotionError unchanged (unauthenticated gh)", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient(
      { output: [], exitCode: 0 },
      null,
      { output: [], exitCode: 0 },
      false,
    );

    // Act / Assert
    expect(() =>
      potentialToIssueServiceCall({
        fileSystem: fs,
        runner: makeRunner([]),
        gh,
        workspaceRoot: WORKSPACE,
        potentialPath: POTENTIAL,
        promotionType: "feature",
        workMode: "full",
      }),
    ).toThrow("GitHub CLI is not authenticated. Run 'gh auth login' first.");
  });
});

describe("potentialToIssueServiceCall receipt post-condition", () => {
  const DESTINATION = "/workspace/docs/features/potential/promoted/sample.md";

  it("throws when the promoted destination is absent", () => {
    // Arrange: the promoted destination reports as absent after the move.
    const build = (): FakePotentialFileSystem => {
      const fs = new BlockedPathPotentialFileSystem(DESTINATION);
      seedFeature(fs, POTENTIAL);
      return fs;
    };
    const makeGh = (): FakeGhClient =>
      new FakeGhClient(
        { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
        { output: [], exitCode: 0 },
      );

    // Act / Assert
    expect(() =>
      potentialToIssueServiceCall({
        fileSystem: build(),
        runner: makeRunner([]),
        gh: makeGh(),
        workspaceRoot: WORKSPACE,
        potentialPath: POTENTIAL,
        promotionType: "feature",
        workMode: "full",
      }),
    ).toThrow("potential_to_issue");
    expect(() =>
      potentialToIssueServiceCall({
        fileSystem: build(),
        runner: makeRunner([]),
        gh: makeGh(),
        workspaceRoot: WORKSPACE,
        potentialPath: POTENTIAL,
        promotionType: "feature",
        workMode: "full",
      }),
    ).toThrow(DESTINATION);
  });

  it("returns the enriched record when the destination exists", () => {
    // Arrange: nothing is blocked, so the promoted destination exists.
    const fs = new FakePotentialFileSystem();
    seedFeature(fs, POTENTIAL);
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );

    // Act
    const result = potentialToIssueServiceCall({
      fileSystem: fs,
      runner: makeRunner([]),
      gh,
      workspaceRoot: WORKSPACE,
      potentialPath: POTENTIAL,
      promotionType: "feature",
      workMode: "full",
    });

    // Assert
    expect(result.destinationPath).toBe(DESTINATION);
    expect(result.artifacts).toEqual(["https://example.com/issues/123"]);
  });
});
