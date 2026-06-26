import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../../src/lib/file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { GitClient } from "../../../src/lib/pr-context/git-client";

/**
 * Tests for the `GitClient` port (`pr_context/git.py`). A recording fake
 * `CommandRunner` captures the exact argv and options each method passes, and an
 * in-memory `FileSystem` controls the `.git` existence probe used by
 * `resolveRoot`. No real git process or filesystem is touched.
 */

/** One captured invocation of the recording runner. */
interface RecordedCall {
  readonly args: readonly string[];
  readonly options: CommandRunOptions | undefined;
}

/** Recording `CommandRunner` returning a scripted, queued result per call. */
class RecordingRunner implements CommandRunner {
  readonly calls: RecordedCall[] = [];
  private readonly queue: CommandResult[];

  constructor(results: CommandResult[]) {
    this.queue = [...results];
  }

  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    this.calls.push({ args, options });
    const next = this.queue.shift();
    return next ?? { stdout: "", stderr: "", code: 0 };
  }
}

/** Minimal `FileSystem` whose `exists` is controlled by a fixed set. */
class ProbeFileSystem implements FileSystem {
  constructor(private readonly existing: Set<string>) {}

  glob(): string[] {
    return [];
  }

  isFile(): boolean {
    return false;
  }

  exists(path: string): boolean {
    return this.existing.has(path);
  }

  isDirectory(path: string): boolean {
    return this.existing.has(path);
  }

  listDirectory(): string[] {
    return [];
  }

  readTextFile(): string {
    throw new Error("not supported in this fake");
  }

  writeTextFile(): void {
    throw new Error("not supported in this fake");
  }

  ensureDir(): void {
    // no-op
  }
}

const CWD = "/repo";

/** Build a GitClient with the supplied scripted results and existing paths. */
function buildClient(
  results: CommandResult[],
  existing: string[] = [],
): { client: GitClient; runner: RecordingRunner } {
  const runner = new RecordingRunner(results);
  const fs = new ProbeFileSystem(new Set(existing));
  const client = new GitClient(runner, CWD, fs);
  return { client, runner };
}

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });

describe("GitClient.run", () => {
  it("delegates to the runner with a git prefix and default allowError", () => {
    // Arrange
    const { client, runner } = buildClient([ok("ok")]);

    // Act
    const result = client.run(["status", "-s"]);

    // Assert
    expect(runner.calls[0]!.args).toEqual(["git", "status", "-s"]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: false });
    expect(result.stdout).toBe("ok");
  });

  it("passes the allowError flag through", () => {
    // Arrange
    const { client, runner } = buildClient([
      { stdout: "", stderr: "err", code: 1 },
    ]);

    // Act
    const result = client.run(["diff"], { allowError: true });

    // Assert
    expect(runner.calls[0]!.args).toEqual(["git", "diff"]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: true });
    expect(result.code).toBe(1);
  });
});

describe("GitClient.resolveRoot", () => {
  it("returns cwd without invoking git when .git exists", () => {
    // Arrange: the .git probe path is present in the filesystem fake.
    const { client, runner } = buildClient([], ["/repo/.git"]);

    // Act
    const root = client.resolveRoot();

    // Assert
    expect(root).toBe(CWD);
    expect(runner.calls).toHaveLength(0);
  });

  it("falls back to rev-parse --show-toplevel when .git is absent", () => {
    // Arrange
    const { client, runner } = buildClient([ok("/repo/root")]);

    // Act
    const root = client.resolveRoot();

    // Assert
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "rev-parse",
      "--show-toplevel",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: false });
    expect(root).toBe("/repo/root");
  });
});

describe("GitClient simple commands", () => {
  it("revParse composes rev-parse --verify", () => {
    const { client, runner } = buildClient([ok("abc123def")]);
    expect(client.revParse("HEAD")).toBe("abc123def");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "rev-parse",
      "--verify",
      "HEAD",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: false });
  });

  it("remoteVerbose composes remote -v", () => {
    const { client, runner } = buildClient([ok("origin\turl (fetch)")]);
    expect(client.remoteVerbose()).toBe("origin\turl (fetch)");
    expect(runner.calls[0]!.args).toEqual(["git", "remote", "-v"]);
  });

  it("branchName composes rev-parse --abbrev-ref HEAD", () => {
    const { client, runner } = buildClient([ok("feature/test")]);
    expect(client.branchName()).toBe("feature/test");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "rev-parse",
      "--abbrev-ref",
      "HEAD",
    ]);
  });

  it("upstream composes the symbolic-full-name query with allowError", () => {
    const { client, runner } = buildClient([ok("origin/main")]);
    expect(client.upstream()).toBe("origin/main");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "rev-parse",
      "--abbrev-ref",
      "--symbolic-full-name",
      "@{u}",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: true });
  });

  it("upstream returns empty string when no upstream is configured", () => {
    const { client } = buildClient([
      { stdout: "", stderr: "no upstream", code: 128 },
    ]);
    expect(client.upstream()).toBe("");
  });

  it("statusShort composes status -sb", () => {
    const { client, runner } = buildClient([ok("## main\n M file.py")]);
    expect(client.statusShort()).toBe("## main\n M file.py");
    expect(runner.calls[0]!.args).toEqual(["git", "status", "-sb"]);
  });

  it("untracked composes ls-files --others --exclude-standard", () => {
    const { client, runner } = buildClient([ok("new.txt\nother.py")]);
    expect(client.untracked()).toBe("new.txt\nother.py");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "ls-files",
      "--others",
      "--exclude-standard",
    ]);
  });

  it("mergeBase composes merge-base base head", () => {
    const { client, runner } = buildClient([ok("abc123")]);
    expect(client.mergeBase("main", "feature")).toBe("abc123");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "merge-base",
      "main",
      "feature",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: false });
  });

  it("log prepends --date=short and tolerates errors", () => {
    const { client, runner } = buildClient([ok("commit1\ncommit2")]);
    expect(client.log("--oneline", "main..feature")).toBe("commit1\ncommit2");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "log",
      "--date=short",
      "--oneline",
      "main..feature",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: true });
  });

  it("diffRange composes diff with the provided arguments", () => {
    const { client, runner } = buildClient([ok("diff output")]);
    expect(
      client.diffRange(["--stat", "main", "feature", "--", "file.py"]),
    ).toBe("diff output");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "diff",
      "--stat",
      "main",
      "feature",
      "--",
      "file.py",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: true });
  });
});

describe("GitClient diff staged/unstaged composition", () => {
  it("diffNameStatus staged inserts --cached at index 1", () => {
    const { client, runner } = buildClient([ok("M\tfile.py")]);
    expect(client.diffNameStatus({ staged: true })).toBe("M\tfile.py");
    expect(runner.calls[0]!.args).toEqual([
      "git",
      "diff",
      "--cached",
      "--name-status",
    ]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: true });
  });

  it("diffNameStatus unstaged omits --cached", () => {
    const { client, runner } = buildClient([ok("A\tnew.py")]);
    expect(client.diffNameStatus({ staged: false })).toBe("A\tnew.py");
    expect(runner.calls[0]!.args).toEqual(["git", "diff", "--name-status"]);
  });

  it("diffPatch staged appends --cached", () => {
    const { client, runner } = buildClient([ok("diff --git")]);
    expect(client.diffPatch({ staged: true })).toBe("diff --git");
    expect(runner.calls[0]!.args).toEqual(["git", "diff", "--cached"]);
    expect(runner.calls[0]!.options).toEqual({ cwd: CWD, allowError: true });
  });

  it("diffPatch unstaged omits --cached", () => {
    const { client, runner } = buildClient([ok("diff content")]);
    expect(client.diffPatch({ staged: false })).toBe("diff content");
    expect(runner.calls[0]!.args).toEqual(["git", "diff"]);
  });
});
