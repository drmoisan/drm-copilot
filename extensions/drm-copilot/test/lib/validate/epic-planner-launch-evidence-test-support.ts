/** In-memory launcher evidence fixtures for epic-planner readiness tests. */

import { createHash } from "node:crypto";

import type { FileSystem } from "../../../src/lib/file-system";
import type { ReadinessGitRepository } from "../../../src/lib/validate/epic-planner-git-integrity";
import type { EpicReadinessContext } from "../../../src/lib/validate/epic-planner-readiness-integrity";

type JsonRecord = Record<string, unknown>;

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function binding(feature: JsonRecord): JsonRecord {
  const delegation = feature["delegation_receipt"];
  const model = feature["model_routing_receipt"];
  if (!isRecord(delegation) || !isRecord(model)) {
    throw new Error("feature routing fixture is incomplete");
  }
  return {
    issue_num: feature["issue_num"],
    feature_folder: feature["feature_folder"],
    delegation_id: delegation["delegation_id"],
    deployment_agent: model["deployment_agent"],
    model: model["model"],
    model_reasoning_effort: model["model_reasoning_effort"],
    execution_context: "epic_preparation_child",
    branch_name: feature["branch_name"],
    worktree_path: feature["worktree_path"],
  };
}

/** Add one sealed shared preparation wave to an in-memory repository. */
export function addLaunchEvidence(
  files: Map<string, string>,
  state: JsonRecord,
  root = "C:/workspace",
): void {
  const value = state["features"];
  if (!Array.isArray(value) || !value.every(isRecord)) {
    throw new Error("planner feature fixture is incomplete");
  }
  const features = value;
  const artifact = "artifacts/orchestration/epic-child-launches/preparation";
  const absoluteArtifact = `${root}/${artifact}`;
  const specPath = `${absoluteArtifact}/launch-spec.json`;
  const launches = features.map((feature) => ({
    launch_id: `feature-${String(feature["issue_num"])}`,
    ...binding(feature),
  }));
  const specText = JSON.stringify({ wave_id: "preparation", launches });
  files.set(specPath, specText);
  const specSha256 = createHash("sha256")
    .update(specText, "utf8")
    .digest("hex");
  const statusLaunches: JsonRecord = {};
  for (const feature of features) {
    const launchId = `feature-${String(feature["issue_num"])}`;
    const sessionId = `session-${String(feature["issue_num"])}`;
    const receiptPath = `${absoluteArtifact}/${launchId}.receipt.json`;
    files.set(
      receiptPath,
      JSON.stringify({
        schema_version: 2,
        state: "completed",
        exit_code: 0,
        launch_id: launchId,
        wave_id: "preparation",
        ...binding(feature),
        spec_path: specPath,
        spec_sha256: specSha256,
        receipt_path: receiptPath,
        status_path: `${absoluteArtifact}/wave.preparation.status.json`,
        codex_session_id: sessionId,
        session_bound_at: "2026-07-10T09:00:00+00:00",
        completed_at: "2026-07-10T09:30:00+00:00",
      }),
    );
    statusLaunches[launchId] = {
      state: "completed",
      exit_code: 0,
      receipt_path: receiptPath,
      codex_session_id: sessionId,
      completed_at: "2026-07-10T09:30:00+00:00",
    };
  }
  files.set(
    `${absoluteArtifact}/wave.preparation.status.json`,
    JSON.stringify({
      schema_version: 2,
      wave_id: "preparation",
      state: "completed",
      failure: "",
      launches: statusLaunches,
    }),
  );
}

class LaunchEvidenceFileSystem implements FileSystem {
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

const UNUSED_GIT: ReadinessGitRepository = {
  refExists: () => false,
  commitExists: () => false,
  isAncestor: () => false,
  lastCommit: () => undefined,
  committedBlobHash: () => undefined,
  worktreeBlobHash: () => undefined,
};

function feature(issueNum: number): JsonRecord {
  const delegationId = `prepare-${issueNum}`;
  const folder = `docs/features/active/feature-${issueNum}`;
  const launchRoot = "artifacts/orchestration/epic-child-launches/preparation";
  return {
    issue_num: issueNum,
    feature_folder: folder,
    branch_name: `feature/feature-${issueNum}`,
    worktree_path: `/repo/worktrees/feature-${issueNum}`,
    delegation_receipt: {
      delegation_id: delegationId,
      feature_folder: folder,
      issue_num: issueNum,
      agent_name: "orchestrator-c3-elevated",
    },
    model_routing_receipt: {
      delegation_id: delegationId,
      deployment_agent: "orchestrator-c3-elevated",
      model: "gpt-5.6-sol",
      model_reasoning_effort: "high",
      execution_context: "epic_preparation_child",
    },
    launch_receipt_path: `${launchRoot}/feature-${issueNum}.receipt.json`,
    launch_status_path: `${launchRoot}/wave.preparation.status.json`,
  };
}

export interface LaunchEvidenceFixture {
  readonly state: JsonRecord;
  readonly files: Map<string, string>;
  readonly context: EpicReadinessContext;
}

/** Build a minimal repository fixture for direct launch-evidence validation. */
export function launchEvidenceFixture(): LaunchEvidenceFixture {
  const state: JsonRecord = { features: [feature(101), feature(102)] };
  const files = new Map<string, string>();
  addLaunchEvidence(files, state);
  return {
    state,
    files,
    context: {
      workspaceRoot: "C:/workspace",
      artifactPath:
        "C:/workspace/artifacts/orchestration/epic-planner-state.json",
      fileSystem: new LaunchEvidenceFileSystem(files),
      git: UNUSED_GIT,
    },
  };
}
