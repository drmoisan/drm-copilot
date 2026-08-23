import { describe, expect, it } from "@jest/globals";

import {
  deduplicateSelectedRoutingDiagnostics,
  validateArtifact,
} from "../../../src/lib/validate/orchestration-artifacts";
import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

const REQUIRED_AGENTS = [
  "task-researcher",
  "prd-feature",
  "atomic-planner",
  "atomic-executor",
  "feature-review",
  "pr-author",
];
const REQUIRED_SKILLS = [
  "orchestrate",
  "feature-promotion-lifecycle",
  "atomic-plan-contract",
  "acceptance-criteria-tracking",
  "pr-context-artifacts",
  "pr-base-branch-merge-base",
];
const REQUIRED_MCP_TOOLS = [
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
];
const ROUTING_MATRIX = {
  routes: {
    large: {
      requires_pr_gate: true,
      required_agents: REQUIRED_AGENTS,
      required_skills: REQUIRED_SKILLS,
      required_mcp_tools: REQUIRED_MCP_TOOLS,
    },
  },
};
const BLOCKER_FINGERPRINT_A = `sha256:${"a".repeat(64)}`;
const BLOCKER_FINGERPRINT_B = `sha256:${"b".repeat(64)}`;

function delegationReceipt(agentName: string, index = 1) {
  return {
    step: `handoff-${String(index)}`,
    agent_name: agentName,
    agent_id: `${agentName}-1`,
    skill_source: "orchestrate",
    started_at: "2026-04-07T09:00:00-04:00",
    completed_at: "2026-04-07T09:05:00-04:00",
    result_signal: "COMPLETE",
    artifact_paths: [`artifacts/orchestration/${agentName}.receipt.json`],
  };
}

function baseState(agentName = "atomic-planner"): Record<string, unknown> {
  return {
    objective: "obj",
    change_budget_estimate: "large",
    path_selected: "large",
    "promotion-type": "feature",
    "short-name": "short",
    relativeFile: "docs/features/potential/x.md",
    "long-name": "feature-1",
    "issue-num": "1",
    "feature-folder": "docs/features/active/feature-1",
    "work-mode": "full-feature",
    "plan-path": "docs/features/active/feature-1/plan.md",
    completed_steps: [],
    next_step: "done",
    last_updated: "2026-04-07T10:00:00-04:00",
    step5_status: "not-applicable",
    step6_status: "not-applicable",
    step7_status: "verified",
    step8_status: "not-applicable",
    step9_status: "verified",
    step10_status: "not-applicable",
    delegation_receipts: [delegationReceipt(agentName)],
    blocked_reason: "none",
  };
}

function remediationAttempt(attemptId: number, fingerprint: string) {
  return {
    attempt_id: attemptId,
    source_review_fingerprint: fingerprint,
    plan_path: `plan-${String(attemptId)}.md`,
    preflight: { final_status: "clear" },
    execution_status: "complete",
    candidate_applied: true,
    terminal_disposition: "candidate_applied",
    started_at: `2026-08-17T12:0${String(attemptId)}:00Z`,
    finished_at: `2026-08-17T12:0${String(attemptId)}:30Z`,
    exception_binding: null,
  };
}

function remediationCycle(
  cycleId: number,
  fingerprintBefore: string,
  fingerprintAfter: string,
) {
  return {
    cycle_id: cycleId,
    attempt_id: cycleId,
    commit_sha: `commit-${String(cycleId)}`,
    re_audit_path: `audit-${String(cycleId)}.md`,
    review_verdict: "BLOCKED",
    remediation_action: "AUTONOMOUS",
    blocker_fingerprint_before: fingerprintBefore,
    blocker_fingerprint_after: fingerprintAfter,
    blocking_count: 1,
    exit_condition_met: false,
    completed_at: `2026-08-17T13:0${String(cycleId)}:00Z`,
  };
}

function remediationLimitState(status: string): Record<string, unknown> {
  const fingerprints = [
    BLOCKER_FINGERPRINT_A,
    BLOCKER_FINGERPRINT_B,
    BLOCKER_FINGERPRINT_A,
    BLOCKER_FINGERPRINT_B,
  ];
  const identifiers = [1, 2, 3];
  return {
    ...baseState(),
    remediation_loop: {
      schema_version: 2,
      status,
      max_completed_cycles: 3,
      attempt_count: 3,
      completed_cycle_count: 3,
      last_blocker_fingerprint: BLOCKER_FINGERPRINT_B,
      attempts: identifiers.map((identifier) =>
        remediationAttempt(identifier, fingerprints[identifier - 1]),
      ),
      cycles: identifiers.map((identifier) =>
        remediationCycle(
          identifier,
          fingerprints[identifier - 1],
          fingerprints[identifier],
        ),
      ),
    },
  };
}

function completeLargeState(): Record<string, unknown> {
  return {
    ...baseState(),
    route_id: "large",
    completed_steps: ["S7", "S8", "S9"],
    step8_status: "verified",
    pr_gate: {
      pr_number: 1,
      pr_url: "https://github.com/drmoisan/drm-copilot/pull/1",
      head_branch: "feature-1",
      head_sha: "current-head-sha",
    },
    ci_gate: {
      conclusion: "success",
      head_sha: "current-head-sha",
      verified_at: "2026-04-07T10:00:00Z",
    },
    required_agents: REQUIRED_AGENTS,
    required_skills: REQUIRED_SKILLS,
    required_mcp_tools: REQUIRED_MCP_TOOLS,
    delegation_receipts: REQUIRED_AGENTS.map(delegationReceipt),
    skill_receipts: REQUIRED_SKILLS.map((skill) => ({
      skill,
      required: true,
      acknowledged_at_phase: "completion",
      evidence: `artifact:${skill}`,
    })),
    mcp_call_receipts: REQUIRED_MCP_TOOLS.map((tool) => ({
      tool,
      ok: true,
      evidence: `mcp_call:${tool}`,
    })),
    local_execution_overrides: [],
    delegation_bypasses: [],
    lifecycle_operations: REQUIRED_MCP_TOOLS.map((name) => ({
      name,
      surface: "mcp",
    })),
  };
}

describe("orchestrator-state cross-runtime remediation-v2 parity", () => {
  it("keeps PR readiness independent from Python completion diagnostics", () => {
    const state = completeLargeState();
    delete state["pr_gate"];
    delete state["ci_gate"];
    state["delegation_receipts"] = REQUIRED_AGENTS.filter(
      (agent) => agent !== "pr-author",
    ).map(delegationReceipt);
    const input = {
      artifactType: "orchestrator-state",
      text: JSON.stringify(state),
      routingMatrix: ROUTING_MATRIX,
    };

    expect(
      validateArtifact({ ...input, requirePrCreationReady: true }),
    ).toEqual([]);
    expect(validateArtifact({ ...input, requireComplete: true })).toEqual([
      "Checkpoint completion validation failed: pr_gate must be an object " +
        "with keys: pr_number, pr_url, head_branch, head_sha.",
      "Checkpoint completion validation failed: ci_gate must be an object " +
        "with keys: conclusion, head_sha, verified_at.",
      "Checkpoint missing required agent receipt: pr-author.",
    ]);
  });

  it("accepts Codex commit stewardship without legacy routing receipts", () => {
    const state = baseState("commit-steward-c4");
    state["codex_model_routing_receipts"] = [
      {
        ...resolveCodexDeployment("commit-steward", "C4", "standalone", "C4"),
        phase: "S6_commit_steward",
      },
    ];

    expect("model_routing_receipts" in state).toBe(false);
    expect(
      validateArtifact({
        artifactType: "orchestrator-state",
        text: JSON.stringify(state),
        requireCodexModelRouting: true,
      }),
    ).toEqual([]);
  });

  it("returns each selected routing diagnostic once in Python order", () => {
    const input = {
      artifactType: "orchestrator-state",
      text: JSON.stringify(baseState()),
      requireModelRouting: true,
      requireCodexModelRouting: true,
      requireCodexTopology: true,
    };
    const expected = [
      "ORCH_ROUTING_GATE_LEGACY: Checkpoint model_routing_receipts is missing " +
        "a receipt for delegated agent: atomic-planner.",
      "ORCH_ROUTING_GATE_CODEX_MODEL: Checkpoint " +
        "codex_model_routing_receipts must be a list when present.",
      "ORCH_ROUTING_GATE_CODEX_TOPOLOGY: Checkpoint " +
        "codex_topology_receipts must be a list when present.",
    ];

    expect(validateArtifact(input)).toEqual(expected);
    expect(validateArtifact(input)).toEqual(expected);
  });

  it("matches Python selected-routing diagnostic identity semantics", () => {
    const legacy = "ORCH_ROUTING_GATE_LEGACY: failure for phase S5.";
    const codex = "ORCH_ROUTING_GATE_CODEX_MODEL: failure for phase S5.";
    const unrelated = "Checkpoint unrelated failure.";

    expect(
      deduplicateSelectedRoutingDiagnostics([
        legacy,
        legacy,
        codex,
        unrelated,
        codex,
      ]),
    ).toEqual([legacy, codex, unrelated]);
  });

  it("uses the canonical three-cycle terminal and rejects its legacy alias", () => {
    const canonicalStatus = "blocked_remediation_loop_limit";
    const canonicalState = remediationLimitState(canonicalStatus);
    const legacyState = remediationLimitState("blocked_cycle_limit");
    const validateState = (state: Record<string, unknown>) =>
      validateArtifact({
        artifactType: "orchestrator-state",
        text: JSON.stringify(state),
      });

    expect(
      (canonicalState["remediation_loop"] as Record<string, unknown>)["status"],
    ).toBe(canonicalStatus);
    expect(validateState(canonicalState)).toEqual([]);
    expect(validateState(legacyState)).toEqual([
      "ORCH_REMEDIATION_SCHEMA: remediation_loop.status must be a documented status.",
    ]);
  });
});
