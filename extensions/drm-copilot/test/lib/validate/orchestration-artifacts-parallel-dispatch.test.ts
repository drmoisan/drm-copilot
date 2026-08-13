import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type { CommandRunner } from "../../../src/lib/subprocess-runner";
import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";
import { validateArtifact } from "../../../src/lib/validate/orchestration-artifacts";
import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";
import {
  buildValidParallelState,
  type JsonRecord,
} from "./parallel-state-test-support";

/**
 * Dispatch tests for the two parallel-orchestration artifact types.
 *
 * These live in their own file because the pre-existing
 * `orchestration-artifacts.test.ts` is already at the 500-line policy cap. The
 * assertions mirror the epic dispatch cases: each type must reach its Phase 4
 * core, each gate flag must be threaded through, and the unsupported-type
 * fallback must stay unchanged.
 */

const ORCHESTRATOR_COMPLETION_ERROR =
  "Parallel checkpoint completion validation failed: open mode requires a mutations[] entry with op 'close'.";

const ORCHESTRATOR_ITEM_COMPLETION_ERROR =
  "Parallel checkpoint items[0] completion validation failed: merge_status is not merged or worktree_removed; found: None.";

const PLANNER_READY_SENTINEL_ERROR =
  "Parallel planner checkpoint next_step must be 'PARALLEL_EXECUTION_READY'; found: None.";
const MUTATION_SEQUENCE_ERROR =
  "Parallel checkpoint mutations[0] recolor_generation 2 must equal the expected recompute generation 1.";
const UNRESOLVED_DRIFT_ERROR =
  "Parallel checkpoint unresolved drift for items [444] blocks admission and completion.";
const PUBLIC_ROOT = "C:/workspace";
const PUBLIC_KICKOFF =
  "docs/features/parallel/public-ready/parallel-kickoff.md";
const PUBLIC_COMMIT = "e".repeat(40);

class ReadinessFileSystem implements FileSystem {
  public constructor(public readonly files: Map<string, string>) {}
  public glob(): string[] {
    return [];
  }
  public isFile(path: string): boolean {
    return this.files.has(path);
  }
  public exists(path: string): boolean {
    return this.files.has(path);
  }
  public isDirectory(): boolean {
    return false;
  }
  public listDirectory(): string[] {
    return [];
  }
  public readTextFile(path: string): string {
    const value = this.files.get(path);
    if (value === undefined) throw new Error(`Unexpected read: ${path}`);
    return value;
  }
  public writeTextFile(): void {
    throw new Error("not used");
  }
  public ensureDir(): void {
    throw new Error("not used");
  }
}

const readinessRunner: CommandRunner = {
  run(args) {
    if (args.join(" ").includes("^{commit}")) {
      return { stdout: PUBLIC_COMMIT, stderr: "", code: 0 };
    }
    return { stdout: "same-blob", stderr: "", code: 0 };
  },
};

function publicReadyState(): JsonRecord {
  return {
    objective: "prepare a public parallel run",
    parallel_slug: "public-ready",
    parallel_manifest_path: "docs/features/parallel/public-ready/parallel.md",
    mode: "closed",
    max_concurrency: 4,
    items: [444, 445].map((issue) => ({
      issue_num: issue,
      feature_folder: `2026-08-10-public-${String(issue)}`,
      kind: "feature",
      state: "prepared",
      blast_radius: {
        paths: [`item-${String(issue)}/**`],
        modules: [`item-${String(issue)}`],
        shared_surfaces: [],
        contracts: [],
        source: "declared",
        computed_at: "2026-08-10T20-25",
      },
      preparation_status: "prepared",
      research_path: `docs/features/active/item-${String(issue)}/research.md`,
      plan_path: `docs/features/active/item-${String(issue)}/plan.md`,
      preflight_status: "PREFLIGHT: ALL CLEAR",
      complexity_band: "C2",
      cohort: 0,
      batch: 0,
      branch: `feature/public-${String(issue)}`,
      worktree_path: `C:/worktrees/public-${String(issue)}`,
      launch_receipt_path: `artifacts/orchestration/public-ready/${String(issue)}.launch.json`,
      launch_status_path: `artifacts/orchestration/public-ready/${String(issue)}.status.json`,
    })),
    cohorts: [{ index: 0, generation: 0, item_keys: [444, 445] }],
    conflict_edges: [],
    recolor_generation: 0,
    completed_steps: ["manifest_parsed"],
    next_step: "PARALLEL_EXECUTION_READY",
    last_updated: "2026-08-10T20-25",
    kickoff_prompt_path: PUBLIC_KICKOFF,
  };
}

function publicReadyFiles(state: JsonRecord): Map<string, string> {
  const files = new Map<string, string>();
  files.set(
    `${PUBLIC_ROOT}/${PUBLIC_KICKOFF}`,
    [
      "# Parallel Kickoff: public-ready",
      "## Invocation Prompt",
      "Run `/parallel-run public-ready` to execute this parallel run.",
      "Use the parallel-orchestrator subagent at docs/features/parallel/public-ready/parallel.md.",
      "The plan-home branch parallel/public-ready-plan contains the plans; items resume at atomic execution from their committed plan-path on their own pushed feature branch.",
      "## Item Summary",
      "| issue_num | feature_folder | cohort | complexity | branch | plan-path |",
      "| --- | --- | --- | --- | --- | --- |",
      "| 444 | docs/features/active/item-444 | 0 | C2 | feature/public-444 | docs/features/active/item-444/plan.md |",
      "| 445 | docs/features/active/item-445 | 0 | C2 | feature/public-445 | docs/features/active/item-445/plan.md |",
      "## Integrity",
      `planning_commit: ${PUBLIC_COMMIT}`,
    ].join("\n"),
  );
  (state["items"] as JsonRecord[]).forEach((item) => {
    const issue = item["issue_num"] as number;
    const launchPath = item["launch_receipt_path"] as string;
    const statusPath = item["launch_status_path"] as string;
    const topology = {
      ...resolveCodexTopology(["python"], 1, 1, "standalone"),
      phase: `parallel-item-${String(issue)}`,
    };
    const model = {
      ...resolveCodexDeployment(
        topology["logical_agent"] as string,
        "C2",
        "standalone",
        "C4",
      ),
      phase: `parallel-item-${String(issue)}`,
    };
    const receiptPaths = {
      authority_receipt_path: `${launchPath}.authority`,
      delegation_receipt_path: `${launchPath}.delegation`,
      topology_receipt_path: `${launchPath}.topology`,
      model_routing_receipt_path: `${launchPath}.model-routing`,
    };
    const launch = {
      schema_version: 2,
      surface: "parallel",
      parallel_slug: state["parallel_slug"],
      item_key: issue,
      cohort: item["cohort"],
      batch: item["batch"],
      base_branch: "main",
      pr_target: "main",
      head_branch: item["branch"],
      worktree_path: item["worktree_path"],
      deployment_agent: model["deployment_agent"],
      model: model["model"],
      model_reasoning_effort: model["model_reasoning_effort"],
      permissions: "orchestrator-workspace",
      ...receiptPaths,
      launch_receipt_path: launchPath,
      launch_status_path: statusPath,
      launch_spec_sha256: "a".repeat(64),
      enforceability_ledger: [{ gate_id: "G01", status: "PRESERVED" }],
    };
    files.set(`${PUBLIC_ROOT}/${launchPath}`, JSON.stringify(launch));
    files.set(
      `${PUBLIC_ROOT}/${statusPath}`,
      JSON.stringify({
        schema_version: 2,
        state: "completed",
        launch_receipt_path: launchPath,
      }),
    );
    files.set(
      `${PUBLIC_ROOT}/${receiptPaths.authority_receipt_path}`,
      JSON.stringify({
        schema_version: 1,
        surface: "parallel",
        parallel_slug: state["parallel_slug"],
        item_key: issue,
        authorized: true,
      }),
    );
    files.set(
      `${PUBLIC_ROOT}/${receiptPaths.delegation_receipt_path}`,
      JSON.stringify({
        delegation_id: `parallel-${String(issue)}`,
        agent_name: model["deployment_agent"],
      }),
    );
    files.set(
      `${PUBLIC_ROOT}/${receiptPaths.topology_receipt_path}`,
      JSON.stringify(topology),
    );
    files.set(
      `${PUBLIC_ROOT}/${receiptPaths.model_routing_receipt_path}`,
      JSON.stringify(model),
    );
  });
  return files;
}

/** Return a shape-valid checkpoint carrying both former false-accept defects. */
function semanticFalseAcceptCheckpoint(): JsonRecord {
  const state = buildValidParallelState();
  state["recolor_generation"] = 2;
  state["cohorts"] = [{ index: 0, generation: 2, item_keys: [444, 445] }];
  state["mutations"] = [
    {
      op: "requeue",
      item_key: 444,
      at: "2026-08-10T21-00",
      prior_state: "in_flight",
      new_state: "blocked",
      disposition: null,
      recolor_generation: 2,
    },
  ];
  state["drift_events"] = [
    {
      item_key: 444,
      declared: ["scripts/dev_tools/**"],
      observed: ["scripts/dev_tools/a.py", "outside/unowned.txt"],
      escaped_paths: ["outside/unowned.txt"],
      at: "2026-08-10T21-00",
      action: "raised_blocking_finding",
    },
  ];
  return state;
}

describe("validateArtifact parallel dispatch", () => {
  it("routes parallel-orchestrator-state to the parallel orchestrator validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text: "[]",
    });

    // Assert
    expect(errors).toEqual(["Parallel checkpoint root must be a JSON object."]);
  });

  it("returns the direct validator's ordered mutation and drift findings", () => {
    const text = JSON.stringify(semanticFalseAcceptCheckpoint());
    const directErrors = validateParallelOrchestratorStateText(text);

    const dispatchErrors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text,
    });

    expect(dispatchErrors).toEqual(directErrors);
    expect(dispatchErrors).toEqual(
      expect.arrayContaining([MUTATION_SEQUENCE_ERROR, UNRESOLVED_DRIFT_ERROR]),
    );
    expect(dispatchErrors.indexOf(MUTATION_SEQUENCE_ERROR)).toBeLessThan(
      dispatchErrors.indexOf(UNRESOLVED_DRIFT_ERROR),
    );
  });

  it("routes parallel-planner-state to the parallel planner validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "[]",
    });

    // Assert
    expect(errors).toEqual([
      "Parallel planner checkpoint root must be a JSON object.",
    ]);
  });

  it("threads requireComplete into parallel-orchestrator-state", () => {
    // Arrange
    const text = JSON.stringify({
      mode: "open",
      items: [{ issue_num: 1, feature_folder: "f", state: "in_progress" }],
    });

    // Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text,
      requireComplete: true,
    });

    // Assert
    expect(errors).toContain(ORCHESTRATOR_ITEM_COMPLETION_ERROR);
    expect(errors).toContain(ORCHESTRATOR_COMPLETION_ERROR);
  });

  it("leaves the completion gate off for parallel-orchestrator-state by default", () => {
    // Arrange
    const text = JSON.stringify({
      mode: "open",
      items: [{ issue_num: 1, feature_folder: "f", state: "in_progress" }],
    });

    // Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text,
    });

    // Assert
    expect(errors).not.toContain(ORCHESTRATOR_ITEM_COMPLETION_ERROR);
    expect(errors).not.toContain(ORCHESTRATOR_COMPLETION_ERROR);
  });

  it("threads requireReadyForExecution into parallel-planner-state", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "{}",
      requireReadyForExecution: true,
    });

    // Assert
    expect(errors).toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  it("accepts explicit planner readiness with valid file-backed evidence", () => {
    const state = publicReadyState();
    const fs = new ReadinessFileSystem(publicReadyFiles(state));

    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: JSON.stringify(state),
      requireReadyForExecution: true,
      artifactPath: `${PUBLIC_ROOT}/artifacts/orchestration/parallel-planner-state.json`,
      runner: readinessRunner,
      fs,
      root: PUBLIC_ROOT,
    });

    expect(errors).toEqual([]);
  });

  it("rejects explicit planner readiness when guarded evidence is missing", () => {
    const state = publicReadyState();
    const files = publicReadyFiles(state);
    files.delete(
      `${PUBLIC_ROOT}/artifacts/orchestration/public-ready/444.launch.json`,
    );

    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: JSON.stringify(state),
      requireReadyForExecution: true,
      artifactPath: `${PUBLIC_ROOT}/artifacts/orchestration/parallel-planner-state.json`,
      runner: readinessRunner,
      fs: new ReadinessFileSystem(files),
      root: PUBLIC_ROOT,
    });

    expect(errors.join("\n")).toContain("launch record is missing");
    expect(errors.join("\n")).toContain("external launch record is missing");
  });

  it("leaves the readiness gate off for parallel-planner-state by default", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "{}",
    });

    // Assert
    expect(errors).not.toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  it("ignores the readiness flag on the parallel orchestrator route", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text: JSON.stringify({ mode: "open" }),
      requireReadyForExecution: true,
    });

    // Assert
    expect(errors).not.toContain(ORCHESTRATOR_COMPLETION_ERROR);
    expect(errors).not.toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  it("ignores the completion flag on the parallel planner route", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "{}",
      requireComplete: true,
    });

    // Assert
    expect(errors).not.toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  // This case previously asserted that `parallel-kickoff` fell through to the
  // unsupported-artifact-type branch. That expectation became false by design:
  // `docs/features/epics/parallel-orchestration/epic.md`, section "Planner
  // Adjudication: the kickoff-contract boundary (F3 / F4)", assigns the
  // kickoff-contract module and the `parallel-kickoff` artifact type to the
  // parallel-planner-surface feature, and this repository's
  // `.claude/rules/parallel-orchestration.md`, section "F3 Scope Boundary —
  // kickoff contract deferred to F4", records the same boundary.
  it("routes the parallel kickoff type to the kickoff validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-kickoff",
      text: "",
    });

    // Assert
    expect(errors).toEqual(["Parallel kickoff is empty."]);
  });

  it("does not require committed context when kickoff readiness is disabled", () => {
    const errors = validateArtifact({
      artifactType: "parallel-kickoff",
      text: "",
      requireReadyForExecution: false,
    });

    expect(errors).toEqual(["Parallel kickoff is empty."]);
  });

  it("requires every committed-evidence dependency for kickoff readiness", () => {
    const errors = validateArtifact({
      artifactType: "parallel-kickoff",
      text: "",
      requireReadyForExecution: true,
    });

    expect(errors).toContain(
      "Parallel committed kickoff evidence context requires filesystem, " +
        "workspace root, artifact path, and Git runner.",
    );
  });

  it("requires committed file-backed identity for a ready kickoff", () => {
    const state = publicReadyState();
    const fs = new ReadinessFileSystem(publicReadyFiles(state));
    const text = fs.readTextFile(`${PUBLIC_ROOT}/${PUBLIC_KICKOFF}`);

    expect(
      validateArtifact({
        artifactType: "parallel-kickoff",
        text,
        requireReadyForExecution: true,
        artifactPath: `${PUBLIC_ROOT}/${PUBLIC_KICKOFF}`,
        runner: readinessRunner,
        fs,
        root: PUBLIC_ROOT,
      }),
    ).toEqual([]);
  });

  it("keeps the unsupported-artifact-type fallback unchanged", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-status-doc",
      text: "",
    });

    // Assert
    expect(errors).toEqual(["Unsupported artifact type: parallel-status-doc"]);
  });
});
