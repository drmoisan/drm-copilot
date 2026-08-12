/** Positive and negative Codex readiness tests for parallel checkpoints. */

import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";
import {
  type ParallelCodexReadinessEvidence,
  validateParallelCodexCheckpointReadiness,
} from "../../../src/lib/validate/parallel-codex-readiness";
import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";
import { validateParallelPlannerStateText } from "../../../src/lib/validate/parallel-planner-state-core";
import {
  buildBlastRadius,
  buildValidParallelState,
  itemAt,
  type JsonRecord,
} from "./parallel-state-test-support";

const KICKOFF_PATH = "docs/features/parallel/wave-one/parallel-kickoff.md";

function buildPlannerItem(issueNum: number, slug: string): JsonRecord {
  return {
    issue_num: issueNum,
    feature_folder: `2026-08-07-${slug}-${String(issueNum)}`,
    kind: "feature",
    state: "prepared",
    blast_radius: buildBlastRadius(),
    preparation_status: "prepared",
    research_path: `docs/features/active/${slug}/research.md`,
    plan_path: `docs/features/active/${slug}/plan.md`,
    preflight_status: "PREFLIGHT: ALL CLEAR",
  };
}

function buildPlannerState(): JsonRecord {
  return {
    objective: "prepare parallel run wave-one",
    parallel_slug: "wave-one",
    parallel_manifest_path: "docs/features/parallel/wave-one/parallel.md",
    mode: "closed",
    max_concurrency: 4,
    items: [
      buildPlannerItem(444, "parallel-schema-validators"),
      buildPlannerItem(445, "parallel-cohort-scheduler"),
    ],
    cohorts: [{ index: 0, generation: 0, item_keys: [444, 445] }],
    conflict_edges: [],
    recolor_generation: 0,
    completed_steps: ["manifest_parsed"],
    next_step: "PARALLEL_EXECUTION_READY",
    last_updated: "2026-08-07T10-00",
    kickoff_prompt_path: KICKOFF_PATH,
  };
}

function bindEvidencePaths(state: JsonRecord): JsonRecord {
  [0, 1].forEach((index) => {
    const item = itemAt(state, index);
    const issue = item["issue_num"] as number;
    Object.assign(item, {
      complexity_band: "C2",
      cohort: 0,
      batch: 0,
      branch: `feature/parallel-${String(issue)}`,
      worktree_path: `C:/worktrees/parallel-${String(issue)}`,
      launch_receipt_path:
        "artifacts/orchestration/parallel-child-launches/" +
        `wave-one/${String(issue)}.receipt.json`,
      launch_status_path:
        "artifacts/orchestration/parallel-child-launches/" +
        `wave-one/${String(issue)}.status.json`,
    });
  });
  return state;
}

function preparedPlannerState(): JsonRecord {
  return bindEvidencePaths(buildPlannerState());
}

function completedOrchestratorState(): JsonRecord {
  const state = bindEvidencePaths(buildValidParallelState());
  [0, 1].forEach((index) => {
    Object.assign(itemAt(state, index), {
      state: "merged",
      merge_status: "worktree_removed",
    });
  });
  state["cohorts"] = [];
  return state;
}

function routingReceipts(itemKey: number): {
  readonly topology: JsonRecord;
  readonly model: JsonRecord;
} {
  const topology: JsonRecord = {
    ...resolveCodexTopology(["python"], 1, 1, "standalone"),
    phase: `parallel-item-${String(itemKey)}`,
  };
  const model: JsonRecord = {
    ...resolveCodexDeployment(
      topology["logical_agent"] as string,
      "C2",
      "standalone",
      "C4",
    ),
    phase: `parallel-item-${String(itemKey)}`,
  };
  return { topology, model };
}

function buildEvidence(
  state: JsonRecord,
  lost = false,
): ParallelCodexReadinessEvidence {
  const launchRecords: Record<string, unknown> = {};
  const statusRecords: Record<string, unknown> = {};
  const receiptRecords: Record<string, unknown> = {};
  const items = state["items"] as JsonRecord[];
  items.forEach((item) => {
    const itemKey = item["issue_num"] as number;
    const receiptPath = item["launch_receipt_path"] as string;
    const statusPath = item["launch_status_path"] as string;
    const authorityPath = `${receiptPath}.authority`;
    const delegationPath = `${receiptPath}.delegation`;
    const topologyPath = `${receiptPath}.topology`;
    const modelPath = `${receiptPath}.model-routing`;
    const { topology, model } = routingReceipts(itemKey);
    launchRecords[receiptPath] = {
      schema_version: 2,
      surface: "parallel",
      parallel_slug: state["parallel_slug"],
      item_key: itemKey,
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
      authority_receipt_path: authorityPath,
      delegation_receipt_path: delegationPath,
      topology_receipt_path: topologyPath,
      model_routing_receipt_path: modelPath,
      launch_receipt_path: receiptPath,
      launch_status_path: statusPath,
      launch_spec_sha256: "a".repeat(64),
    };
    statusRecords[statusPath] = {
      schema_version: 2,
      state: "completed",
      launch_receipt_path: receiptPath,
    };
    receiptRecords[authorityPath] = {
      schema_version: 1,
      surface: "parallel",
      parallel_slug: state["parallel_slug"],
      item_key: itemKey,
      authorized: true,
    };
    receiptRecords[delegationPath] = {
      delegation_id: `parallel-${String(itemKey)}`,
      agent_name: model["deployment_agent"],
    };
    receiptRecords[topologyPath] = topology;
    receiptRecords[modelPath] = model;
  });
  return {
    launchRecords,
    statusRecords,
    receiptRecords,
    enforceabilityLedger: [
      { gate_id: "G01", status: lost ? "LOST" : "PRESERVED" },
    ],
    kickoffIdentity: {
      schema_version: 1,
      path: KICKOFF_PATH,
      plan_home_ref: "origin/parallel/wave-one-plan",
      planning_commit: "b".repeat(40),
      blob_sha256: "c".repeat(64),
      worktree_sha256: "c".repeat(64),
    },
  };
}

function plannerErrors(
  state: JsonRecord,
  evidence?: ParallelCodexReadinessEvidence,
): string[] {
  return validateParallelPlannerStateText(JSON.stringify(state), {
    requireReadyForExecution: true,
    ...(evidence === undefined ? {} : { readinessContext: evidence }),
  });
}

function completionErrors(
  state: JsonRecord,
  evidence?: ParallelCodexReadinessEvidence,
): string[] {
  return validateParallelOrchestratorStateText(JSON.stringify(state), {
    requireComplete: true,
    ...(evidence === undefined ? {} : { readinessContext: evidence }),
  });
}

describe("parallel Codex readiness", () => {
  it("preserves legacy checkpoints outside explicit Codex gates", () => {
    expect(
      validateParallelPlannerStateText(JSON.stringify(buildPlannerState())),
    ).toEqual([]);
    expect(
      validateParallelOrchestratorStateText(
        JSON.stringify(completedOrchestratorState()),
      ),
    ).toEqual([]);
  });

  it("accepts explicit planner readiness with complete external evidence", () => {
    const state = preparedPlannerState();
    expect(plannerErrors(state, buildEvidence(state))).toEqual([]);
  });

  it("accepts explicit orchestrator completion with external evidence", () => {
    const state = completedOrchestratorState();
    expect(completionErrors(state, buildEvidence(state))).toEqual([]);
  });

  it.each(["planner", "orchestrator"])(
    "fails closed when explicit %s validation omits evidence",
    (gate) => {
      const errors =
        gate === "planner"
          ? plannerErrors(preparedPlannerState())
          : completionErrors(completedOrchestratorState());
      expect(errors).toContain(
        `${gate === "planner" ? "Parallel planner checkpoint" : "Parallel checkpoint"} ` +
          "Codex readiness evidence is required.",
      );
    },
  );

  it.each([
    ["launchRecords", "", "external launch record"],
    ["statusRecords", "status", "external launch status"],
    ["receiptRecords", ".authority", "authority receipt"],
    ["receiptRecords", ".topology", "topology receipt"],
    ["receiptRecords", ".model-routing", "model-routing receipt"],
  ] as const)("rejects missing %s evidence", (collection, suffix, expected) => {
    const state = preparedPlannerState();
    const evidence = buildEvidence(state);
    const item = itemAt(state, 0);
    const receiptPath = item["launch_receipt_path"] as string;
    const path =
      suffix === "status"
        ? (item["launch_status_path"] as string)
        : `${receiptPath}${suffix}`;
    delete (evidence[collection] as Record<string, unknown>)[path];
    expect(plannerErrors(state, evidence).join("\n")).toContain(expected);
  });

  it("rejects a mismatched launch-status binding", () => {
    const state = preparedPlannerState();
    const evidence = buildEvidence(state);
    const receiptPath = itemAt(state, 0)["launch_receipt_path"] as string;
    (evidence.launchRecords[receiptPath] as JsonRecord)["launch_status_path"] =
      "artifacts/orchestration/other.status.json";
    expect(plannerErrors(state, evidence).join("\n")).toContain(
      "launch_status_path must be",
    );
  });

  it.each(["epic_slug", "integration_branch", "fan_in_pr"])(
    "rejects mixed state key %s",
    (key) => {
      const state = preparedPlannerState();
      state[key] = "forbidden";
      expect(plannerErrors(state, buildEvidence(state)).join("\n")).toContain(
        `prohibited epic or fan-in key at ${key}`,
      );
    },
  );

  it("rejects a nonzero LOST ledger", () => {
    const state = preparedPlannerState();
    expect(
      plannerErrors(state, buildEvidence(state, true)).join("\n"),
    ).toContain("status LOST blocks parallel readiness");
  });

  it("rejects model identity inconsistent with the referenced receipt", () => {
    const state = preparedPlannerState();
    const evidence = buildEvidence(state);
    const receiptPath = itemAt(state, 0)["launch_receipt_path"] as string;
    (evidence.launchRecords[receiptPath] as JsonRecord)["model"] =
      "gpt-5.6-sol";
    expect(plannerErrors(state, evidence).join("\n")).toContain(
      "model must match model-routing receipt",
    );
  });

  it("reports malformed external evidence in stable order without mutation", () => {
    const state = preparedPlannerState();
    const evidence = buildEvidence(state);
    const item = itemAt(state, 0);
    const receiptPath = item["launch_receipt_path"] as string;
    const statusPath = item["launch_status_path"] as string;
    const record = evidence.launchRecords[receiptPath] as JsonRecord;
    const authorityPath = record["authority_receipt_path"] as string;
    const delegationPath = record["delegation_receipt_path"] as string;

    state["kickoff_prompt_path"] =
      "docs/features/parallel/wrong/parallel-kickoff.md";
    Object.assign(record, {
      launch_receipt_path: "artifacts/orchestration/other.receipt.json",
      permissions: "",
      launch_spec_sha256: "invalid",
    });
    Object.assign(evidence.statusRecords[statusPath] as JsonRecord, {
      schema_version: 1,
      state: "running",
      launch_receipt_path: "artifacts/orchestration/other.receipt.json",
    });
    Object.assign(evidence.receiptRecords[authorityPath] as JsonRecord, {
      surface: "epic",
      parallel_slug: "other",
      item_key: -1,
      authorized: false,
    });
    Object.assign(evidence.receiptRecords[delegationPath] as JsonRecord, {
      delegation_id: "",
      agent_name: "other-agent",
    });
    Object.assign(evidence.kickoffIdentity as JsonRecord, {
      planning_commit: "invalid",
      blob_sha256: "invalid",
      worktree_sha256: "different",
    });
    Object.assign(evidence, {
      enforceabilityLedger: [
        null,
        { gate_id: "", status: "UNKNOWN" },
        { gate_id: "G01", status: "PRESERVED" },
        { gate_id: "G01", status: "PRESERVED" },
      ],
    });
    const stateSnapshot = JSON.stringify(state);
    const evidenceSnapshot = JSON.stringify(evidence);
    const markers = [
      "enforceability_ledger[0] must be an object",
      "enforceability_ledger[1].gate_id must be a non-empty string",
      "enforceability_ledger[1].status must be one of",
      "enforceability_ledger[3].gate_id must be unique",
      "committed kickoff identity.path must match checkpoint kickoff_prompt_path",
      "committed kickoff identity.planning_commit",
      "committed kickoff identity.blob_sha256",
      "committed kickoff identity.worktree_sha256",
      "Codex launch provenance.launch_receipt_path",
      "Codex launch provenance.permissions",
      "Codex launch provenance.launch_spec_sha256",
      "external launch status.schema_version",
      "external launch status.state",
      "external launch status.launch_receipt_path",
      "authority receipt.surface",
      "authority receipt.parallel_slug",
      "authority receipt.item_key",
      "authority receipt.authorized",
      "delegation receipt.delegation_id",
      "delegation receipt.agent_name",
    ];

    const firstRun = plannerErrors(state, evidence);
    const secondRun = plannerErrors(state, evidence);
    const positions = markers.map((marker) =>
      firstRun.findIndex((error) => error.includes(marker)),
    );

    expect(firstRun).toEqual(secondRun);
    expect(positions.every((position) => position >= 0)).toBe(true);
    expect(positions).toEqual(
      [...positions].sort((left, right) => left - right),
    );
    expect(JSON.stringify(state)).toBe(stateSnapshot);
    expect(JSON.stringify(evidence)).toBe(evidenceSnapshot);
  });

  it("keeps the pure helper usable without checkpoint parsing", () => {
    const state = preparedPlannerState();
    expect(
      validateParallelCodexCheckpointReadiness(
        state,
        "Parallel planner checkpoint",
        buildEvidence(state),
      ),
    ).toEqual([]);
  });
});
