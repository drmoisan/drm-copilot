/**
 * `.dev` cases for the validators routed by issue #1035 (P3-T4).
 *
 * Each case proves that a matcher accepts the `.dev` form of a path it already
 * accepts in its `docs/features` form, or that a writer-side path follows the
 * resolved root. Hermetic: in-memory documents and file-system fakes only.
 */
import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  buildFeatureReferenceIndex,
  resolveFeatureReference,
} from "../../../src/lib/validate/epic-orchestrator-state-resolution";
import { validateEpicKickoffText } from "../../../src/lib/validate/epic-kickoff-artifact";
import { findForbiddenPaths } from "../../../src/lib/validate/evidence-locations";
import { resolveIssueAdoption } from "../../../src/lib/validate/orchestrator-state-issue-adoption";
import { validateArtifact } from "../../../src/lib/validate/orchestration-artifacts";
import { validateParallelKickoffText } from "../../../src/lib/validate/parallel-kickoff-artifact";
import { kickoff } from "./parallel-kickoff-fixtures";
import { buildBlastRadius } from "./parallel-state-test-support";

/** Map-backed file system; a directory exists when a file lies beneath it. */
class MapFileSystem implements FileSystem {
  public constructor(public readonly files: Map<string, string>) {}

  public glob(root: string): string[] {
    return [...this.files.keys()].filter((path) => path.startsWith(`${root}/`));
  }

  public isFile(path: string): boolean {
    return this.files.has(path);
  }

  public exists(path: string): boolean {
    return this.files.has(path) || this.isDirectory(path);
  }

  public isDirectory(path: string): boolean {
    return [...this.files.keys()].some((file) => file.startsWith(`${path}/`));
  }

  public listDirectory(): string[] {
    return [];
  }

  public readTextFile(path: string): string {
    const value = this.files.get(path);
    if (value === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return value;
  }

  public writeTextFile(): void {
    throw new Error("not used");
  }

  public ensureDir(): void {
    throw new Error("not used");
  }
}

describe("development-docs matchers accept the .dev root", () => {
  it("epic-orchestrator-state-resolution strips a .dev/active prefix", () => {
    // Arrange
    const index = buildFeatureReferenceIndex([
      { issue_num: 101, feature_folder: ".dev/active/1016-foo" },
    ]);

    // Act / Assert: a hint in either root form resolves to the same feature.
    expect(
      resolveFeatureReference("docs/features/active/1016-foo", index),
    ).toBe(".dev/active/1016-foo");
    expect(resolveFeatureReference(".dev/completed/1016-foo", index)).toBe(
      ".dev/active/1016-foo",
    );
  });

  it("parallel-orchestrator-state-cohort-barrier resolves a .dev folder hint", () => {
    // Arrange: a same-cohort conflict whose edge names one item by its hint.
    const item = (
      issueNum: number,
      folder: string,
    ): Record<string, unknown> => ({
      issue_num: issueNum,
      feature_folder: folder,
      state: "scheduled",
      blast_radius: buildBlastRadius(),
    });
    const state = {
      objective: "dev root barrier",
      completed_steps: [],
      next_step: "cohort_0_launch",
      last_updated: "2026-11-16T00-00",
      route_id: "parallel",
      parallel_slug: "dev-root",
      parallel_manifest_path: ".dev/parallel/dev-root/parallel.md",
      parallel_status_doc_path: ".dev/parallel/dev-root/parallel-status.md",
      mode: "closed",
      max_concurrency: 4,
      current_cohort: 0,
      recolor_generation: 0,
      cohorts: [{ index: 0, generation: 0, item_keys: [444, 445] }],
      items: [item(444, ".dev/active/item-444"), item(445, "item-445")],
      conflict_edges: [
        { a: "docs/features/active/item-444", b: 445, reason: "path_overlap" },
      ],
      mutations: [],
      drift_events: [],
    };

    // Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text: JSON.stringify(state),
    });

    // Assert
    expect(errors).toContain(
      "PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445",
    );
  });

  it("epic-kickoff-artifact accepts a .dev epic manifest", () => {
    // Arrange
    const text = [
      "# Epic Kickoff: sample-epic",
      "## Invocation Prompt",
      "Run `/epic-run sample-epic` to execute this epic.",
      "Use the epic-orchestrator subagent to execute the prepared epic at",
      ".dev/epics/sample-epic/epic.md. Reuse epic/sample-epic-integration.",
      "Every child resumes at atomic execution from its committed plan-path;",
      "do not repeat planning or preflight.",
      "## Feature Summary",
      "| issue_num | feature_folder | wave | complexity | plan-path |",
      "| --- | --- | --- | --- | --- |",
      "| 101 | .dev/active/feature-101 | 0 | C3 | .dev/active/feature-101/plan.md |",
    ].join("\n");

    // Act / Assert
    expect(validateEpicKickoffText(text)).toEqual([]);
  });

  it("parallel-kickoff-artifact accepts a .dev parallel manifest", () => {
    // Arrange
    const text = kickoff().replace(
      "docs/features/parallel/sample-run/parallel.md",
      ".dev/parallel/sample-run/parallel.md",
    );

    // Act / Assert
    expect(validateParallelKickoffText(text)).toEqual([]);
  });

  it("orchestrator-state-issue-adoption accepts a .dev potential record", () => {
    // Arrange
    const state = {
      "issue-num": "509",
      "promotion-type": "feature",
      issue_adoption: {
        issue_num: "509",
        issue_url: "https://github.com/drmoisan/drm-copilot/issues/509",
        origin: "epic_decomposition",
        verified_via: "gh_issue_view",
        verified_at: "2026-09-29T15:15:00Z",
        evidence: "gh issue view 509: number 509, state OPEN",
        waived_tools: ["potential_to_issue", "new_potential_entry"],
        potential_record: ".dev/potential/promoted/2026-08-22-sample.md",
      },
    };

    // Act
    const result = resolveIssueAdoption(state, {
      routeId: "large",
      requiredMcpTools: [
        "new_potential_entry",
        "potential_to_issue",
        "new_active_feature_folder",
        "collect_pr_context",
        "validate_orchestration_artifacts",
      ],
      successfulTools: new Set([
        "new_active_feature_folder",
        "collect_pr_context",
        "validate_orchestration_artifacts",
      ]),
    });

    // Assert
    expect(result.errors).toEqual([]);
  });

  it("evidence-locations names the resolved .dev research hint", () => {
    // Arrange
    const fs = new MapFileSystem(
      new Map([
        [
          "/repo/config/orchestration-routing.json",
          '{"development_docs_root": ".dev"}',
        ],
        ["/repo/.dev/README.md", "x"],
        ["/repo/artifacts/research/notes.md", "x"],
      ]),
    );

    // Act
    const violations = findForbiddenPaths(fs, "/repo");

    // Assert
    expect(violations).toEqual([
      {
        path: "/repo/artifacts/research/notes.md",
        canonical: ".dev/active/<feature>/research/ or .dev/research/",
      },
    ]);
  });
});
