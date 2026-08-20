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
