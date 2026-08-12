import type { FileSystem } from "../../../src/lib/file-system";
import type {
  CommandResult,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { buildParallelCodexReadinessEvidence } from "../../../src/lib/validate/parallel-codex-readiness-filesystem";
import { kickoff, kickoffWithIntegrity } from "./parallel-kickoff-fixtures";

const ROOT = "/repo";
const COMMIT = "e".repeat(40);
const KICKOFF_PATH = "docs/features/parallel/sample-run/parallel-kickoff.md";

class MemoryFileSystem implements FileSystem {
  public readonly reads: string[] = [];

  public constructor(private readonly files: Map<string, string>) {}

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
    this.reads.push(path);
    const value = this.files.get(path);
    if (value === undefined) throw new Error(`Unexpected read: ${path}`);
    return value;
  }

  public writeTextFile(): void {
    throw new Error("writeTextFile is not available in readiness tests");
  }

  public ensureDir(): void {
    throw new Error("ensureDir is not available in readiness tests");
  }
}

class GitRunner implements CommandRunner {
  public constructor(private readonly drift = false) {}

  public run(args: readonly string[]): CommandResult {
    const joined = args.join(" ");
    if (joined.includes("^{commit}")) {
      return { stdout: COMMIT, stderr: "", code: 0 };
    }
    if (joined.includes(":" + KICKOFF_PATH)) {
      return { stdout: "blob-one", stderr: "", code: 0 };
    }
    if (joined.includes("hash-object")) {
      return {
        stdout: this.drift ? "blob-two" : "blob-one",
        stderr: "",
        code: 0,
      };
    }
    return { stdout: "", stderr: "unsupported", code: 1 };
  }
}

type JsonRecord = Record<string, unknown>;

function state(secondItem = false): JsonRecord {
  return {
    parallel_slug: "sample-run",
    kickoff_prompt_path: KICKOFF_PATH,
    items: [
      {
        launch_receipt_path: "artifacts/orchestration/item-101.launch.json",
        launch_status_path: "artifacts/orchestration/item-101.status.json",
      },
      ...(secondItem
        ? [
            {
              launch_receipt_path:
                "artifacts/orchestration/item-102.launch.json",
              launch_status_path:
                "artifacts/orchestration/item-102.status.json",
            },
          ]
        : []),
    ],
  };
}

function launch(item: number, status: "PRESERVED" | "DEGRADED" = "PRESERVED") {
  const prefix = `artifacts/orchestration/item-${String(item)}`;
  return {
    launch_receipt_path: `${prefix}.launch.json`,
    launch_status_path: `${prefix}.status.json`,
    authority_receipt_path: `${prefix}.authority.json`,
    delegation_receipt_path: `${prefix}.delegation.json`,
    topology_receipt_path: `${prefix}.topology.json`,
    model_routing_receipt_path: `${prefix}.model-routing.json`,
    enforceability_ledger: [{ gate_id: "G01", status }],
  };
}

function validFiles(secondItem = false): Map<string, string> {
  const files = new Map<string, string>([
    [`${ROOT}/${KICKOFF_PATH}`, kickoffWithIntegrity()],
  ]);
  for (const item of secondItem ? [101, 102] : [101]) {
    const prefix = `artifacts/orchestration/item-${String(item)}`;
    files.set(`${ROOT}/${prefix}.launch.json`, JSON.stringify(launch(item)));
    files.set(
      `${ROOT}/${prefix}.status.json`,
      JSON.stringify({
        state: "completed",
        launch_receipt_path: `${prefix}.launch.json`,
      }),
    );
    for (const suffix of [
      "authority",
      "delegation",
      "topology",
      "model-routing",
    ]) {
      files.set(
        `${ROOT}/${prefix}.${suffix}.json`,
        JSON.stringify({ receipt: suffix }),
      );
    }
  }
  return files;
}

function build(
  checkpoint: JsonRecord,
  fs: MemoryFileSystem,
  runner: CommandRunner = new GitRunner(),
) {
  return buildParallelCodexReadinessEvidence(JSON.stringify(checkpoint), {
    fileSystem: fs,
    workspaceRoot: ROOT,
    artifactPath: `${ROOT}/artifacts/orchestration/parallel-planner-state.json`,
    runner,
  });
}

describe("parallel Codex readiness filesystem evidence", () => {
  it("loads guarded launch, status, receipt, ledger, and kickoff evidence", () => {
    const result = build(state(), new MemoryFileSystem(validFiles()));

    expect(result.errors).toEqual([]);
    expect(result.evidence?.kickoffIdentity).toMatchObject({
      path: KICKOFF_PATH,
      planning_commit: COMMIT,
    });
    expect(result.evidence?.enforceabilityLedger).toEqual([
      { gate_id: "G01", status: "PRESERVED" },
    ]);
  });

  it("rejects traversal without reading outside the workspace", () => {
    const checkpoint = state();
    (checkpoint["items"] as JsonRecord[])[0]!["launch_receipt_path"] =
      "../outside.json";
    const fs = new MemoryFileSystem(validFiles());

    const result = build(checkpoint, fs);

    expect(result.errors.join("\n")).toContain(
      "launch/status paths must be guarded repository-relative paths",
    );
    expect(fs.reads.some((path) => path.includes("outside"))).toBe(false);
  });

  it.each(["C:/absolute.json", "/absolute.json", "nested\\receipt.json"])(
    "rejects non-relative POSIX launch path %s",
    (launchPath) => {
      const checkpoint = state();
      (checkpoint["items"] as JsonRecord[])[0]!["launch_receipt_path"] =
        launchPath;
      const fs = new MemoryFileSystem(validFiles());

      const result = build(checkpoint, fs);

      expect(result.errors.join("\n")).toContain(
        "launch/status paths must be guarded repository-relative paths",
      );
      expect(fs.reads.some((path) => path.includes(launchPath))).toBe(false);
    },
  );

  it.each([
    [
      "launch record",
      "artifacts/orchestration/item-101.launch.json",
      "Parallel checkpoint items[0] launch record is missing at 'artifacts/orchestration/item-101.launch.json'.",
    ],
    [
      "launch status",
      "artifacts/orchestration/item-101.status.json",
      "Parallel checkpoint items[0] launch status is missing at 'artifacts/orchestration/item-101.status.json'.",
    ],
    [
      "authority receipt",
      "artifacts/orchestration/item-101.authority.json",
      "Parallel checkpoint items[0] authority_receipt_path is missing at 'artifacts/orchestration/item-101.authority.json'.",
    ],
    [
      "delegation receipt",
      "artifacts/orchestration/item-101.delegation.json",
      "Parallel checkpoint items[0] delegation_receipt_path is missing at 'artifacts/orchestration/item-101.delegation.json'.",
    ],
    [
      "topology receipt",
      "artifacts/orchestration/item-101.topology.json",
      "Parallel checkpoint items[0] topology_receipt_path is missing at 'artifacts/orchestration/item-101.topology.json'.",
    ],
    [
      "model-routing receipt",
      "artifacts/orchestration/item-101.model-routing.json",
      "Parallel checkpoint items[0] model_routing_receipt_path is missing at 'artifacts/orchestration/item-101.model-routing.json'.",
    ],
  ])("rejects a missing %s", (_label, relativePath, expected) => {
    const files = validFiles();
    files.delete(`${ROOT}/${relativePath}`);

    expect(build(state(), new MemoryFileSystem(files)).errors[0]).toBe(
      expected,
    );
  });

  it("rejects an unguarded committed kickoff path", () => {
    const checkpoint = state();
    checkpoint["kickoff_prompt_path"] = "../outside.md";

    expect(
      build(checkpoint, new MemoryFileSystem(validFiles())).errors,
    ).toContain(
      "Parallel checkpoint kickoff_prompt_path must be a guarded repository-relative path.",
    );
  });

  it("rejects a missing committed kickoff", () => {
    const files = validFiles();
    files.delete(`${ROOT}/${KICKOFF_PATH}`);

    expect(build(state(), new MemoryFileSystem(files)).errors).toContain(
      `Parallel committed kickoff is missing at '${KICKOFF_PATH}'.`,
    );
  });

  it("rejects malformed referenced JSON", () => {
    const files = validFiles();
    files.set(`${ROOT}/artifacts/orchestration/item-101.topology.json`, "{");

    expect(
      build(state(), new MemoryFileSystem(files)).errors.join("\n"),
    ).toContain(
      "topology_receipt_path at 'artifacts/orchestration/item-101.topology.json' is not valid JSON",
    );
  });

  it("requires the same normalized ledger across items", () => {
    const files = validFiles(true);
    files.set(
      `${ROOT}/artifacts/orchestration/item-102.launch.json`,
      JSON.stringify(launch(102, "DEGRADED")),
    );

    expect(build(state(true), new MemoryFileSystem(files)).errors).toContain(
      "Parallel launch records must carry one identical normalized enforceability ledger.",
    );
  });

  it("rejects a nonzero LOST ledger", () => {
    const files = validFiles();
    files.set(
      `${ROOT}/artifacts/orchestration/item-101.launch.json`,
      JSON.stringify({
        ...launch(101),
        enforceability_ledger: [{ gate_id: "G01", status: "LOST" }],
      }),
    );

    expect(
      build(state(), new MemoryFileSystem(files)).errors.join("\n"),
    ).toContain("status LOST blocks parallel readiness");
  });

  it("rejects launch and status binding mismatches", () => {
    const files = validFiles();
    files.set(
      `${ROOT}/artifacts/orchestration/item-101.status.json`,
      JSON.stringify({ state: "completed", launch_receipt_path: "other.json" }),
    );

    expect(build(state(), new MemoryFileSystem(files)).errors).toContain(
      "Parallel checkpoint items[0] launch status receipt binding is mismatched.",
    );
  });

  it("rejects kickoff worktree drift from the plan-home ref", () => {
    expect(
      build(state(), new MemoryFileSystem(validFiles()), new GitRunner(true))
        .errors,
    ).toContain(
      "Parallel committed kickoff worktree content must match the plan-home ref blob.",
    );
  });

  it("requires committed kickoff integrity", () => {
    const files = validFiles();
    files.set(`${ROOT}/${KICKOFF_PATH}`, kickoff());

    expect(build(state(), new MemoryFileSystem(files)).errors).toContain(
      "Parallel committed kickoff planning_commit is required.",
    );
  });

  it("rejects an unguarded referenced receipt path", () => {
    const files = validFiles();
    files.set(
      `${ROOT}/artifacts/orchestration/item-101.launch.json`,
      JSON.stringify({
        ...launch(101),
        topology_receipt_path: "../topology.json",
      }),
    );

    expect(
      build(state(), new MemoryFileSystem(files)).errors.join("\n"),
    ).toContain(
      "topology_receipt_path must be a guarded repository-relative path",
    );
  });

  it("does not mutate checkpoint input or loaded evidence text", () => {
    const checkpoint = state();
    const checkpointText = JSON.stringify(checkpoint);
    const files = validFiles();
    const snapshot = new Map(files);

    build(checkpoint, new MemoryFileSystem(files));

    expect(JSON.stringify(checkpoint)).toBe(checkpointText);
    expect(files).toEqual(snapshot);
  });
});
