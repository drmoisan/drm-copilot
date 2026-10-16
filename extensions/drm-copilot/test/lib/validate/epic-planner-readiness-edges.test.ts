import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type { ReadinessGitRepository } from "../../../src/lib/validate/epic-planner-git-integrity";
import { validateEpicReadinessIntegrity } from "../../../src/lib/validate/epic-planner-readiness-integrity";

const ROOT = "C:/workspace";
const FOLDER = "docs/features/active/feature-101";
const PLAN = "docs/features/active/feature-101/plan.md";
const RESEARCH = "artifacts/research/feature-101.md";
const EVIDENCE = "docs/features/active/feature-101/evidence/preflight.md";
const OTHER_EVIDENCE = "docs/features/active/feature-102/evidence/preflight.md";
const MANIFEST = "docs/features/epics/sample-epic/epic.md";
const BRANCH = "epic/sample-epic-integration";
const KICKOFF = "docs/features/epics/sample-epic/epic-kickoff.md";

const PLAN_INSIDE_ERROR =
  "Epic planner checkpoint features[0].plan_path must be inside its feature_folder.";
const INDEX_ONE_PLAN_INSIDE_ERROR =
  "Epic planner checkpoint features[1].plan_path must be inside its feature_folder.";
const EVIDENCE_INSIDE_ERROR =
  "Epic planner checkpoint features[0].preflight_evidence_path must be inside its feature_folder.";
const PREFLIGHT_REQUIRED_ERROR =
  "Execution readiness requires preflight evidence containing 'PREFLIGHT: ALL CLEAR' under docs/features/active/feature-101.";
const KICKOFF_SLUG_ERROR =
  "Committed kickoff slug and /epic-run slug must match state 'sample-epic'.";
const UNREADABLE_ISSUE_ERROR =
  "Execution readiness could not read Epic planner checkpoint features[0] issue.md docs/features/active/feature-101/issue.md: Error: denied";

const KICKOFF_TEXT = [
  "# Epic Kickoff: other-epic",
  "## Invocation Prompt",
  "Run `/epic-run sample-epic` to execute this epic.",
  "Use the epic-orchestrator subagent to execute the prepared epic at",
  "docs/features/epics/sample-epic/epic.md. Reuse epic/sample-epic-integration.",
  "Every child resumes at atomic execution from its committed plan-path;",
  "do not repeat planning or preflight.",
  "## Feature Summary",
  "| issue_num | feature_folder | wave | complexity | plan-path |",
  "| --- | --- | --- | --- | --- |",
  `| 101 | ${FOLDER} | 0 | C3 | ${PLAN} |`,
].join("\n");

class EdgeFileSystem implements FileSystem {
  public constructor(
    public readonly files: Map<string, string>,
    private readonly unreadable: ReadonlySet<string> = new Set(),
  ) {}

  public glob(): string[] {
    return [];
  }

  public isFile(path: string): boolean {
    return this.files.has(path);
  }

  public exists(path: string): boolean {
    return this.files.has(path);
  }

  public isDirectory(path: string): boolean {
    return path === `${ROOT}/${FOLDER}`;
  }

  public listDirectory(): string[] {
    return [];
  }

  public readTextFile(path: string): string {
    if (this.unreadable.has(path)) {
      throw new Error("denied");
    }
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

/** Build an in-memory repository holding every required feature document. */
function repositoryFiles(): Map<string, string> {
  return new Map([
    [`${ROOT}/${FOLDER}/issue.md`, "# Issue"],
    [`${ROOT}/${FOLDER}/spec.md`, "# Spec"],
    [`${ROOT}/${FOLDER}/user-story.md`, "# User story"],
    [`${ROOT}/${FOLDER}/plan.md`, "# Plan"],
    [`${ROOT}/${RESEARCH}`, "# Research"],
    [`${ROOT}/${EVIDENCE}`, "PREFLIGHT: ALL CLEAR"],
  ]);
}

/** Build one keyless feature entry with the given overrides. */
function feature(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    feature_folder: FOLDER,
    plan_path: PLAN,
    research_path: RESEARCH,
    ...overrides,
  };
}

/** Validate readiness for the given features against an in-memory repository. */
function errorsFor(
  features: readonly unknown[],
  files = repositoryFiles(),
  unreadable: ReadonlySet<string> = new Set(),
): string[] {
  return validateEpicReadinessIntegrity(
    {
      epic_feature_folder: "sample-epic",
      epic_manifest_path: MANIFEST,
      integration_branch: BRANCH,
      features,
    },
    "{}",
    {
      workspaceRoot: ROOT,
      artifactPath: `${ROOT}/artifacts/orchestration/epic-planner-state.json`,
      fileSystem: new EdgeFileSystem(files, unreadable),
      git: UNUSED_GIT,
    },
    { requireLaunchPaths: true },
  );
}

const outsidePlanCases: ReadonlyArray<{
  readonly label: string;
  readonly planPath: string;
}> = [
  { label: "equal-to-folder", planPath: FOLDER },
  { label: "dot-prefixed-folder", planPath: `./${FOLDER}` },
  {
    label: "sibling-prefix",
    planPath: "docs/features/active/feature-1010/plan.md",
  },
];

describe("validateEpicReadinessIntegrity edge cases", () => {
  it.each(outsidePlanCases)("rejects a $label plan_path", ({ planPath }) => {
    const features = [feature({ plan_path: planPath })];

    const errors = errorsFor(features);

    expect(errors).toContain(PLAN_INSIDE_ERROR);
  });

  it("accepts a plan_path inside its feature_folder", () => {
    const features = [feature()];

    const errors = errorsFor(features);

    expect(errors).not.toContain(PLAN_INSIDE_ERROR);
  });

  it("skips a non-object feature entry and keeps its index", () => {
    const features = [
      "not-a-feature",
      feature({ plan_path: "docs/features/active/feature-1010/plan.md" }),
    ];

    const errors = errorsFor(features);

    expect(errors).toContain(INDEX_ONE_PLAN_INSIDE_ERROR);
  });

  it("reports an unreadable required document", () => {
    const unreadable = new Set([`${ROOT}/${FOLDER}/issue.md`]);

    const errors = errorsFor([feature()], repositoryFiles(), unreadable);

    expect(errors).toContain(UNREADABLE_ISSUE_ERROR);
  });

  it("rejects preflight evidence outside its feature_folder", () => {
    const features = [feature({ preflight_evidence_path: OTHER_EVIDENCE })];

    const errors = errorsFor(features);

    expect(errors).toContain(EVIDENCE_INSIDE_ERROR);
    expect(errors).toContain(PREFLIGHT_REQUIRED_ERROR);
  });

  it("skips unreadable preflight evidence", () => {
    const features = [feature({ preflight_evidence_path: EVIDENCE })];
    const unreadable = new Set([`${ROOT}/${EVIDENCE}`]);

    const errors = errorsFor(features, repositoryFiles(), unreadable);

    expect(errors).toContain(PREFLIGHT_REQUIRED_ERROR);
    expect(errors).not.toContain(EVIDENCE_INSIDE_ERROR);
  });

  it("reports a kickoff slug that differs from the state", () => {
    const files = repositoryFiles();
    files.set(`${ROOT}/${KICKOFF}`, KICKOFF_TEXT);

    const errors = errorsFor([feature()], files);

    expect(errors).toContain(KICKOFF_SLUG_ERROR);
  });
});
