import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type {
  CommandResult,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { resolveCodexTopology } from "../../../src/lib/validate/codex-topology-resolver";
import type { ReadinessGitRepository } from "../../../src/lib/validate/epic-planner-git-integrity";
import { validateEpicReadinessIntegrity } from "../../../src/lib/validate/epic-planner-readiness-integrity";
import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";
import { validateOrchestrationServiceCall } from "../../../src/lib/validate/validate-orchestration-service-call";
import { addLaunchEvidence } from "./epic-planner-launch-evidence-test-support";

const ROOT = "C:/workspace";
const STATE_PATH =
  "C:/workspace/artifacts/orchestration/epic-planner-state.json";
const BRANCH = "epic/sample-epic-integration";
const COMMIT_ONE = "1".repeat(40);
const COMMIT_TWO = "2".repeat(40);
const PLAN_ONE_HASH = "a".repeat(40);
const PLAN_TWO_HASH = "b".repeat(40);
const KICKOFF_HASH = "c".repeat(40);
const MANIFEST_HASH = "d".repeat(40);
type JsonRecord = Record<string, unknown>;

class MemoryFileSystem implements FileSystem {
  public constructor(
    public readonly files: Map<string, string>,
    private readonly directories: Set<string>,
  ) {}

  public glob(root: string, pattern: string): string[] {
    const normalizedRoot = root.replace(/\/+$/, "");
    const marker = pattern.includes("preflight") ? "preflight" : "research";
    return [...this.files.keys()].filter(
      (path) => path.startsWith(`${normalizedRoot}/`) && path.includes(marker),
    );
  }

  public isFile(path: string): boolean {
    return this.files.has(path);
  }
  public exists(path: string): boolean {
    return this.files.has(path) || this.directories.has(path);
  }
  public isDirectory(path: string): boolean {
    return this.directories.has(path);
  }
  public listDirectory(path: string): string[] {
    const prefix = `${path.replace(/\/+$/, "")}/`;
    return [...this.files.keys()]
      .filter((candidate) => candidate.startsWith(prefix))
      .map((candidate) => candidate.slice(prefix.length).split("/")[0] ?? "")
      .filter((value, index, values) => values.indexOf(value) === index)
      .sort();
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

class MemoryGitRepository implements ReadinessGitRepository {
  public readonly refs = new Set([BRANCH]);
  public readonly commits = new Set([COMMIT_ONE, COMMIT_TWO]);
  public readonly ancestors = new Set([
    `${COMMIT_ONE}:${BRANCH}`,
    `${COMMIT_TWO}:${BRANCH}`,
  ]);
  public readonly lastCommits = new Map([
    ["docs/features/active/feature-101/plan.md", COMMIT_ONE],
    ["docs/features/completed/feature-102/plan.md", COMMIT_TWO],
  ]);
  public readonly committedHashes = new Map([
    [`${COMMIT_ONE}:docs/features/active/feature-101/plan.md`, PLAN_ONE_HASH],
    [
      `${COMMIT_TWO}:docs/features/completed/feature-102/plan.md`,
      PLAN_TWO_HASH,
    ],
    [`${BRANCH}:docs/features/epics/sample-epic/epic-kickoff.md`, KICKOFF_HASH],
    [`${BRANCH}:docs/features/epics/sample-epic/epic.md`, MANIFEST_HASH],
  ]);
  public readonly worktreeHashes = new Map([
    ["docs/features/active/feature-101/plan.md", PLAN_ONE_HASH],
    ["docs/features/completed/feature-102/plan.md", PLAN_TWO_HASH],
    ["docs/features/epics/sample-epic/epic-kickoff.md", KICKOFF_HASH],
    ["docs/features/epics/sample-epic/epic.md", MANIFEST_HASH],
  ]);

  public refExists(ref: string): boolean {
    return this.refs.has(ref);
  }

  public commitExists(commit: string): boolean {
    return this.commits.has(commit);
  }

  public isAncestor(commit: string, ref: string): boolean {
    return this.ancestors.has(`${commit}:${ref}`);
  }

  public lastCommit(path: string): string | undefined {
    return this.lastCommits.get(path);
  }

  public committedBlobHash(ref: string, path: string): string | undefined {
    return this.committedHashes.get(`${ref}:${path}`);
  }

  public worktreeBlobHash(path: string): string | undefined {
    return this.worktreeHashes.get(path);
  }
}

function modelReceipt(delegationId: string): JsonRecord {
  return {
    logical_agent: "orchestrator",
    deployment_agent: "orchestrator-c3-elevated",
    phase: "preparation",
    complexity_band: "C3",
    execution_context: "epic_preparation_child",
    orchestration_complexity_ceiling: "C3",
    c3_overlay_applied: true,
    c3_overlay_reason: "epic_context",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "high",
    delegation_id: delegationId,
  };
}

function topologyReceipt(rootPersona?: "epic-planner"): JsonRecord {
  const value =
    rootPersona === undefined
      ? resolveCodexTopology(["python"], 1, 1, "epic_preparation_child")
      : resolveCodexTopology([], 0, 0, "standalone", { rootPersona });
  return { ...value, phase: "preparation" };
}

function feature(issueNum: number, folder: string, wave: number): JsonRecord {
  const delegationId = `prepare-${issueNum}`;
  return {
    issue_num: issueNum,
    feature_folder: folder,
    depends_on: wave === 0 ? [] : [101],
    wave,
    complexity_band: "C3",
    preparation_status: "prepared",
    research_path:
      issueNum === 102
        ? `${folder}/research.md`
        : `artifacts/research/feature-${issueNum}.md`,
    plan_path: `${folder}/plan.md`,
    preflight_status: "PREFLIGHT: ALL CLEAR",
    branch_name: `feature/feature-${issueNum}`,
    worktree_path: `/repo/worktrees/feature-${issueNum}`,
    delegation_receipt: {
      delegation_id: delegationId,
      feature_folder: folder,
      issue_num: issueNum,
      agent_name: "orchestrator-c3-elevated",
    },
    model_routing_receipt: modelReceipt(delegationId),
    launch_receipt_path: `artifacts/orchestration/epic-child-launches/preparation/feature-${issueNum}.receipt.json`,
    launch_status_path:
      "artifacts/orchestration/epic-child-launches/preparation/wave.preparation.status.json",
    topology_receipt: topologyReceipt(),
  };
}

function state(): JsonRecord {
  return {
    objective: "prepare two features",
    epic_feature_folder: "sample-epic",
    epic_manifest_path: "docs/features/epics/sample-epic/epic.md",
    integration_branch: BRANCH,
    max_parallel_features: 4,
    epic_worthiness: { verdict: "epic", rationale: "two features" },
    features: [
      feature(101, "docs/features/active/feature-101", 0),
      feature(102, "docs/features/completed/feature-102", 1),
    ],
    kickoff_prompt_path: "artifacts/orchestration/epic-kickoff-sample-epic.md",
    completed_steps: ["decomposition", "preparation", "fan-in"],
    next_step: "EPIC_EXECUTION_READY",
    last_updated: "2026-07-10T10:00:00Z",
    topology_receipt: topologyReceipt("epic-planner"),
  };
}

function kickoff(
  planTwo = "docs/features/completed/feature-102/plan.md",
): string {
  return [
    "# Epic Kickoff: sample-epic",
    "## Invocation Prompt",
    "Run `/epic-run sample-epic` to execute this epic.",
    "Use the epic-orchestrator subagent to execute the prepared epic at",
    "docs/features/epics/sample-epic/epic.md. Reuse epic/sample-epic-integration.",
    "Every child resumes at atomic execution from its committed plan-path;",
    "do not repeat planning or preflight.",
    "## Feature Summary",
    "| issue_num | feature_folder | wave | complexity | plan-path |",
    "| --- | --- | --- | --- | --- |",
    "| 101 | docs/features/active/feature-101 | 0 | C3 | " +
      "docs/features/active/feature-101/plan.md |",
    `| 102 | docs/features/completed/feature-102 | 1 | C3 | ${planTwo} |`,
  ].join("\n");
}

function fixture(): {
  readonly state: Record<string, unknown>;
  readonly text: string;
  readonly fs: MemoryFileSystem;
  readonly git: MemoryGitRepository;
} {
  const value = state();
  const text = JSON.stringify(value);
  const kickoffText = kickoff();
  const files = new Map<string, string>([
    [STATE_PATH, text],
    ["C:/workspace/docs/features/epics/sample-epic/epic.md", "# Epic"],
    [
      "C:/workspace/docs/features/epics/sample-epic/epic-kickoff.md",
      kickoffText,
    ],
    [
      "C:/workspace/artifacts/orchestration/epic-kickoff-sample-epic.md",
      kickoffText,
    ],
  ]);
  const directories = new Set<string>();
  for (const folder of [
    "docs/features/active/feature-101",
    "docs/features/completed/feature-102",
  ]) {
    directories.add(`C:/workspace/${folder}`);
    files.set(`C:/workspace/${folder}/issue.md`, "# Issue");
    files.set(`C:/workspace/${folder}/spec.md`, "# Specification");
    files.set(`C:/workspace/${folder}/user-story.md`, "# User Story");
    files.set(`C:/workspace/${folder}/research.md`, "# Research");
    files.set(`C:/workspace/${folder}/plan.md`, "# Plan");
    files.set(
      `C:/workspace/${folder}/evidence/preflight.md`,
      "PREFLIGHT: ALL CLEAR",
    );
  }
  files.set("C:/workspace/artifacts/research/feature-101.md", "# Research");
  files.set("C:/workspace/artifacts/research/feature-102.md", "# Research");
  addLaunchEvidence(files, value);
  return {
    state: value,
    text,
    fs: new MemoryFileSystem(files, directories),
    git: new MemoryGitRepository(),
  };
}

function context(value: ReturnType<typeof fixture>) {
  return {
    workspaceRoot: ROOT,
    artifactPath: STATE_PATH,
    fileSystem: value.fs,
    git: value.git,
  };
}

describe("epic planner repository readiness", () => {
  it("accepts a baseline kickoff by deriving commits and blob hashes from Git", () => {
    const value = fixture();

    expect(
      validateEpicPlannerStateText(value.text, {
        requireReadyForExecution: true,
        readinessContext: context(value),
      }),
    ).toEqual([]);
  });

  it("requires issue, research, specification, and preflight evidence", () => {
    const value = fixture();
    value.fs.files.delete(
      "C:/workspace/docs/features/active/feature-101/issue.md",
    );
    value.fs.files.delete("C:/workspace/artifacts/research/feature-101.md");
    value.fs.files.delete(
      "C:/workspace/docs/features/active/feature-101/spec.md",
    );
    value.fs.files.delete(
      "C:/workspace/docs/features/active/feature-101/evidence/preflight.md",
    );

    const errors = validateEpicPlannerStateText(value.text, {
      requireReadyForExecution: true,
      readinessContext: context(value),
    });

    expect(errors.some((error) => error.includes("issue.md"))).toBe(true);
    expect(errors.some((error) => error.includes("research evidence"))).toBe(
      true,
    );
    expect(errors.some((error) => error.includes("spec.md"))).toBe(true);
    expect(errors.some((error) => error.includes("preflight evidence"))).toBe(
      true,
    );
  });

  it("cross-binds the structural kickoff feature table to planner state", () => {
    const value = fixture();
    const changed = kickoff(
      "docs/features/completed/feature-102/other-plan.md",
    );
    value.fs.files.set(
      "C:/workspace/docs/features/epics/sample-epic/epic-kickoff.md",
      changed,
    );
    value.fs.files.set(
      "C:/workspace/artifacts/orchestration/epic-kickoff-sample-epic.md",
      changed,
    );

    const errors = validateEpicPlannerStateText(value.text, {
      requireReadyForExecution: true,
      readinessContext: context(value),
    });

    expect(
      errors.some((error) =>
        error.includes("feature table must exactly match"),
      ),
    ).toBe(true);
  });

  it("blocks integration ancestry failures and changed plan bytes", () => {
    const value = fixture();
    value.git.ancestors.delete(`${COMMIT_TWO}:${BRANCH}`);
    value.git.worktreeHashes.set(
      "docs/features/active/feature-101/plan.md",
      "e".repeat(40),
    );

    const errors = validateEpicPlannerStateText(value.text, {
      requireReadyForExecution: true,
      readinessContext: context(value),
    });

    expect(errors.some((error) => error.includes("is not on"))).toBe(true);
    expect(errors.some((error) => error.includes("committed plan drift"))).toBe(
      true,
    );
  });
});

class FixtureCommandRunner implements CommandRunner {
  public constructor(private readonly git: MemoryGitRepository) {}

  public run(args: readonly string[]): CommandResult {
    const command = args.slice(1);
    const path = command.at(-1) ?? "";
    if (command[0] === "rev-parse" && path.endsWith("^{commit}")) {
      return result(this.git.refExists(path.slice(0, -9)) ? path : undefined);
    }
    if (command[0] === "cat-file") {
      return result(
        this.git.commitExists(path.slice(0, -9)) ? "exists" : undefined,
      );
    }
    if (command[0] === "merge-base") {
      return result(
        this.git.isAncestor(command[2] ?? "", command[3] ?? "")
          ? "ancestor"
          : undefined,
      );
    }
    if (command[0] === "log") {
      return result(this.git.lastCommit(path));
    }
    if (command[0] === "hash-object") {
      return result(this.git.worktreeBlobHash(path));
    }
    if (command[0] === "rev-parse") {
      const separator = path.indexOf(":");
      return result(
        this.git.committedBlobHash(
          path.slice(0, separator),
          path.slice(separator + 1),
        ),
      );
    }
    return result(undefined);
  }
}

function result(stdout: string | undefined): CommandResult {
  return stdout === undefined
    ? { stdout: "", stderr: "not found", code: 1 }
    : { stdout, stderr: "", code: 0 };
}

describe("repository-aware validation service", () => {
  it("threads artifact path, filesystem, and Git runner into readiness", () => {
    const value = fixture();

    expect(
      validateOrchestrationServiceCall({
        fileSystem: value.fs,
        runner: new FixtureCommandRunner(value.git),
        workspaceRoot: ROOT,
        artifactType: "epic-planner-state",
        artifactPath: "artifacts/orchestration/epic-planner-state.json",
        requireReadyForExecution: true,
      }).summary,
    ).toBe(
      "Validated epic-planner-state artifact at " +
        "'artifacts/orchestration/epic-planner-state.json'.",
    );
  });
});

describe("repository readiness failure boundaries", () => {
  it("rejects unsafe or cross-feature paths and explicit preflight evidence drift", () => {
    const value = fixture();
    const features = value.state["features"] as Record<string, unknown>[];
    features[0]!["plan_path"] = "docs/features/completed/feature-102/plan.md";
    features[0]!["research_path"] = "docs/unrelated/research.md";
    features[0]!["preflight_evidence_path"] = "../outside/preflight.md";
    features[1]!["feature_folder"] = "docs/features/archive/feature-102";
    const text = JSON.stringify(value.state);
    value.fs.files.set(STATE_PATH, text);

    const errors = validateEpicPlannerStateText(text, {
      requireReadyForExecution: true,
      readinessContext: {
        ...context(value),
        artifactPath: "C:/workspace/other/state.json",
      },
    });

    expect(errors.join("\n")).toContain("plan_path must be inside");
    expect(errors.join("\n")).toContain(
      "research_path must be under artifacts/research",
    );
    expect(errors.join("\n")).toContain("must stay within the workspace root");
    expect(errors.join("\n")).toContain("artifact path must be");
    expect(errors.join("\n")).toContain("feature_folder must be under");
  });

  it("binds the artifact root, manifest, branch, kickoff copies, and slug", () => {
    const value = fixture();
    const outsideContext = {
      ...context(value),
      artifactPath: "D:/outside/state.json",
    };
    const stateWithDrift = {
      ...value.state,
      epic_manifest_path: "docs/features/epics/sample-epic/other.md",
      integration_branch: "epic/other-integration",
    };
    value.fs.files.set(
      "C:/workspace/artifacts/orchestration/epic-kickoff-sample-epic.md",
      kickoff().replace("do not repeat planning", "do not repeat execution"),
    );

    const errors = validateEpicReadinessIntegrity(
      stateWithDrift,
      JSON.stringify(stateWithDrift),
      outsideContext,
    );

    expect(errors.join("\n")).toContain("artifact path must stay within");
    expect(errors.join("\n")).toContain("epic_manifest_path must be");
    expect(errors.join("\n")).toContain("integration_branch must be");
    expect(errors.join("\n")).toContain("kickoff bytes must match");

    expect(
      validateEpicReadinessIntegrity(
        { ...value.state, epic_feature_folder: "Invalid Slug" },
        "{}",
        context(value),
      ).join("\n"),
    ).toContain("epic_feature_folder must be a slug");
  });
});
