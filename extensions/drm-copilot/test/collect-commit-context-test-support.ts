import { childProcessMock, fsMock } from "./extension-test-harness";

/**
 * In-memory capture of files written and directories created by the in-process
 * `collectCommitContext` port, so tests observe the produced artifact and
 * parent-directory creation without touching the real filesystem.
 */
const writtenFiles = new Map<string, string>();
const ensuredDirs: string[] = [];

/**
 * Wire the harness `node:fs` write/mkdir mocks to record into the in-memory
 * capture maps and clear prior state. Call inside a test's Arrange step.
 *
 * @returns The capture maps; `writtenFiles` keys are forward-slash-normalized.
 */
export function installInProcessFsCaptures(): {
  readonly writtenFiles: Map<string, string>;
  readonly ensuredDirs: string[];
} {
  writtenFiles.clear();
  ensuredDirs.length = 0;
  fsMock.writeFileSync.mockImplementation(
    (filePath: string, content: string) => {
      writtenFiles.set(String(filePath).replace(/\\/g, "/"), String(content));
    },
  );
  fsMock.mkdirSync.mockImplementation((dirPath: string) => {
    ensuredDirs.push(String(dirPath).replace(/\\/g, "/"));
  });
  return { writtenFiles, ensuredDirs };
}

/**
 * Configure `spawnSync` to return per-git-args output for the in-process
 * `collectCommitContext` port. Staged diffs return empty (no staged changes);
 * all other sections return non-empty content so every header renders.
 *
 * SubprocessRunner decodes stdout/stderr only when they are Buffers, so results
 * use Buffer streams to match the real spawnSync shape.
 *
 * @param override Optional callback keyed by the joined argument list to
 *   customize a specific call's `status`/`stdout`/`stderr`; return `null` to
 *   fall through to the default routing.
 */
export function setCollectCommitContextGitOutput(
  override?: (joined: string) => {
    status: number;
    stdout: string;
    stderr?: string;
  } | null,
): void {
  childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
    const args = (rawArgs[1] as ReadonlyArray<string> | undefined) ?? [];
    const joined = args.join(" ");
    const custom = override?.(joined);
    if (custom) {
      return {
        status: custom.status,
        stdout: Buffer.from(custom.stdout, "utf8"),
        stderr: Buffer.from(custom.stderr ?? "", "utf8"),
      };
    }
    const ok = (
      text: string,
    ): { status: number; stdout: Buffer; stderr: Buffer } => ({
      status: 0,
      stdout: Buffer.from(text, "utf8"),
      stderr: Buffer.from("", "utf8"),
    });
    if (joined.includes("remote")) {
      return ok("origin\thttps://example.com/repo.git (fetch)");
    }
    if (joined.includes("rev-parse") && joined.includes("HEAD")) {
      return ok("main");
    }
    if (joined.includes("@{u}")) {
      return ok("origin/main");
    }
    if (joined.includes("status")) {
      return ok("## main...origin/main");
    }
    if (joined.includes("--cached")) {
      return ok("");
    }
    if (joined.includes("diff") && joined.includes("--name-status")) {
      return ok("M\tsrc/app.ts");
    }
    if (
      joined.includes("diff") &&
      joined.includes("HEAD") &&
      joined.includes("--stat")
    ) {
      return ok("1 file changed");
    }
    if (
      joined.includes("diff") &&
      joined.includes("HEAD") &&
      joined.includes("--name-only")
    ) {
      return ok("module.py");
    }
    if (joined.includes("ls-files")) {
      return ok("untracked.txt");
    }
    if (joined.includes("diff")) {
      return ok("diff --git a/src/app.ts b/src/app.ts");
    }
    if (joined.includes("log")) {
      return ok("abc123\nA <a@x>\nDate\nC <c@x>\nDate\nfeat: x\n\nbody");
    }
    return ok("");
  });
}
