import { describe, expect, it } from "@jest/globals";

import {
  migrateDevelopmentDocsServiceCall,
  resolveAgainstRoot,
  type MigrateDevelopmentDocsInput,
} from "../../../src/lib/development-docs-migration/migrate-development-docs-service-call";
import {
  computeSourceDigest,
  RECORD_ONLY_KEYS,
} from "../../../src/lib/development-docs-migration/migration-decisions";
import type { CommandResult } from "../../../src/lib/subprocess-runner";
import { FakeCommandRunner, InMemoryFileSystem } from "./migration-test-fakes";

const ROOT = "/work";
const FOO = "docs/features/active/2026-10-30-foo-1016";
const NOW = (): Date => new Date("2026-11-20T07:21:00Z");

interface RepoState {
  dirty?: boolean;
  inside?: boolean;
  untracked?: string[];
  extraTracked?: string[];
}

/** In-memory repository plus a runner that answers git from it. */
function repo(files: Record<string, string>, state: RepoState = {}) {
  const rooted: Record<string, string> = {};
  for (const [path, text] of Object.entries(files)) {
    rooted[`${ROOT}/${path}`] = text;
  }
  const fileSystem = new InMemoryFileSystem(rooted);
  const tracked = (): string[] =>
    [...fileSystem.files.keys()]
      .filter(
        (path) =>
          !path.includes("/reports/") && !path.endsWith("decisions.json"),
      )
      .map((path) => path.slice(ROOT.length + 1))
      .concat(state.extraTracked ?? []);
  const runner = new FakeCommandRunner((args): CommandResult => {
    const ok = (stdout: string): CommandResult => ({
      stdout,
      stderr: "",
      code: 0,
    });
    if (args[1] === "rev-parse") {
      return state.inside === false
        ? { stdout: "", stderr: "fatal", code: 128 }
        : ok("true");
    }
    if (args[1] === "status") {
      return ok(state.dirty === true ? " M README.md\0" : "");
    }
    if (args[1] === "ls-files") {
      return ok(
        (args.includes("--others") ? (state.untracked ?? []) : tracked()).join(
          "\0",
        ),
      );
    }
    return ok("");
  });
  return { fileSystem, runner };
}

const BASE = {
  [`${FOO}/spec.md`]: "spec",
  "README.md": `see ${FOO}/spec.md`,
};

function decisionFile(digestFolders: string[]): string {
  const globals: Record<string, unknown> = {
    discovery_templates_target: ".dev/discovery/templates",
    in_tree_rewrite_scope: "links-only",
    commit_split: "single",
  };
  for (const key of RECORD_ONLY_KEYS) {
    globals[key] = "recorded";
  }
  return JSON.stringify({
    version: 1,
    source_digest: computeSourceDigest(digestFolders),
    global_decisions: globals,
  });
}

function call(
  env: ReturnType<typeof repo>,
  input: Partial<MigrateDevelopmentDocsInput> = {},
) {
  return migrateDevelopmentDocsServiceCall({
    fileSystem: env.fileSystem,
    runner: env.runner,
    now: NOW,
    input: { workspaceRoot: ROOT, mode: "dry-run", ...input },
  });
}

describe("migrateDevelopmentDocsServiceCall", () => {
  it("runs git with cwd equal to workspace_root and writes nothing without report_directory", () => {
    // Arrange
    const env = repo(BASE);
    const before = [...env.fileSystem.files.keys()];

    // Act
    const result = call(env);

    // Assert
    expect(
      env.runner.calls.every((recorded) => recorded.options?.cwd === ROOT),
    ).toBe(true);
    expect(env.fileSystem.writes).toEqual([]);
    expect([...env.fileSystem.files.keys()]).toEqual(before);
    expect(result).toMatchObject({
      tool: "migrate_development_docs",
      workspaceRoot: ROOT,
      artifacts: [],
    });
  });

  it("writes both report files only under a relative report_directory with the injected UTC stamp", () => {
    // Arrange
    const env = repo(BASE);

    // Act
    const result = call(env, { reportDirectory: "reports" });

    // Assert
    expect(result.artifacts).toEqual([
      "/work/reports/dev-docs-migration-dry-run.2026-11-20T07-21.md",
      "/work/reports/dev-docs-migration-dry-run.2026-11-20T07-21.json",
    ]);
    expect(env.fileSystem.writes).toEqual(result.artifacts);
    const json = JSON.parse(
      env.fileSystem.readTextFile(result.artifacts[1] ?? ""),
    ) as Record<string, unknown>;
    expect(json["resolved_root"]).toBe("docs/features");
    expect(
      (json["decision_skeleton"] as Record<string, unknown>)["dry_run_report"],
    ).toBe("dev-docs-migration-dry-run.2026-11-20T07-21.json");
  });

  it("reports the root resolved by resolveDevelopmentDocsRoot", () => {
    // Arrange
    const env = repo({
      ...BASE,
      "config/orchestration-routing.json": JSON.stringify({
        development_docs_root: ".dev",
      }),
    });

    env.fileSystem.directories.add(`${ROOT}/.dev`);

    // Act
    const result = call(env, { reportDirectory: "/work/reports" });

    // Assert
    const json = JSON.parse(
      env.fileSystem.readTextFile(result.artifacts[1] ?? ""),
    ) as Record<string, unknown>;
    expect(json["resolved_root"]).toBe(".dev");
  });

  it("carries every summary count in a dry-run result and lists untracked files", () => {
    // Act
    const result = call(repo(BASE, { untracked: [`${FOO}/scratch.log`] }));

    // Assert
    for (const label of [
      "moves:",
      "renames:",
      "held_items:",
      "formatter_errors:",
      "collisions:",
      "files_to_rewrite:",
      "rewrite_occurrences:",
      "excluded_files:",
      "protected_occurrences:",
      "broken_links:",
      "untracked_files: 1",
      "retained_documentation:",
      "kept_folders:",
      "source_digest:",
    ]) {
      expect(result.summary).toContain(label);
    }
    expect(result.summary).toContain(`untracked: ${FOO}/scratch.log`);
  });

  it("refuses apply on uncommitted changes but not a dry run", () => {
    // Arrange
    const env = repo(BASE, { dirty: true });

    // Act / Assert
    expect(() => call(env, { mode: "apply" })).toThrow(
      "tracked files have uncommitted changes",
    );
    expect(() => call(repo(BASE, { dirty: true }))).not.toThrow();
  });

  it("refuses a missing decision file and names its path", () => {
    expect(() =>
      call(repo(BASE), { mode: "apply", renameDecisionsPath: "missing.json" }),
    ).toThrow("decision file not found: missing.json");
  });

  it("applies with a valid relative decision file and summarizes the applied counts and untracked files", () => {
    // Arrange
    const env = repo(
      { ...BASE, "decisions.json": decisionFile([FOO]) },
      { untracked: [`${FOO}/scratch.log`] },
    );

    // Act
    const result = call(env, {
      mode: "apply",
      renameDecisionsPath: "decisions.json",
    });

    // Assert
    const moves = env.runner.calls
      .filter((recorded) => recorded.args[1] === "mv")
      .map((recorded) => recorded.args.slice(3));
    expect(moves).toEqual([
      ["docs/features/active", ".dev/active"],
      [".dev/active/2026-10-30-foo-1016", ".dev/active/1016-foo"],
    ]);
    expect(result.summary).toContain("applied moves: 1");
    expect(result.summary).toContain("applied renames: 1");
    expect(result.summary).toContain("docs/README.md: created");
    expect(result.summary).toContain(`untracked: ${FOO}/scratch.log`);
    expect(result.summary).toContain("held_items: 0");
  });

  it("makes no move and writes nothing, not even a report, when apply refuses", () => {
    // Arrange
    const env = repo({ ...BASE, "decisions.json": decisionFile(["stale"]) });

    // Act / Assert
    expect(() =>
      call(env, {
        mode: "apply",
        renameDecisionsPath: "/work/decisions.json",
        reportDirectory: "reports",
      }),
    ).toThrow("source_digest mismatch");
    expect(env.runner.calls.some((recorded) => recorded.args[1] === "mv")).toBe(
      false,
    );
    expect(env.fileSystem.writes).toEqual([]);
  });

  it("refuses outside a git work tree before listing files", () => {
    const env = repo(BASE, { inside: false });
    expect(() => call(env)).toThrow(
      "workspace_root is not inside a git work tree",
    );
    expect(env.runner.calls).toHaveLength(1);
  });

  it("reports an existing docs/README.md as unchanged after apply", () => {
    const env = repo({
      ...BASE,
      "docs/README.md": "index",
      "decisions.json": decisionFile([FOO]),
    });
    const result = call(env, {
      mode: "apply",
      renameDecisionsPath: "decisions.json",
    });
    expect(result.summary).toContain("docs/README.md: existing, unchanged");
  });

  it("reads a file that cannot be read as skipped rather than failing", () => {
    // Arrange: a tracked path whose content is missing from the file system.
    const env = repo(BASE, { extraTracked: ["ghost.md"] });

    // Act
    const result = call(env, { reportDirectory: "reports" });

    // Assert
    const json = JSON.parse(
      env.fileSystem.readTextFile(result.artifacts[1] ?? ""),
    ) as Record<string, unknown>;
    expect(json["skipped_files"]).toEqual(["ghost.md"]);
  });

  it("resolves relative and absolute paths with forward slashes", () => {
    expect(resolveAgainstRoot("C:\\repo", "a\\b.json")).toBe(
      "C:/repo/a/b.json",
    );
    expect(resolveAgainstRoot("/work", "/abs/x")).toBe("/abs/x");
    expect(resolveAgainstRoot("/work", "D:/abs/x")).toBe("D:/abs/x");
  });
});
