import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../../src/lib/file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { GhClient } from "../../../src/lib/pr-context/gh-client-core";

/**
 * Tests for the `GhClient` core port (`pr_context/github.py` availability,
 * classification, file-fetch, CI status). A queued fake `CommandRunner` returns
 * scripted results in call order (mirroring the Python `side_effect` lists), an
 * in-memory `FileSystem` backs local reads, and `whichGh` is injected so PATH is
 * never touched.
 */

/** Queued fake `CommandRunner`; returns the next scripted result per call. */
class QueueRunner implements CommandRunner {
  readonly calls: { args: readonly string[]; options?: CommandRunOptions }[] =
    [];
  private readonly queue: CommandResult[];

  constructor(results: CommandResult[]) {
    this.queue = [...results];
  }

  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    this.calls.push({ args, options });
    const next = this.queue.shift();
    if (next === undefined) {
      throw new Error(`Unexpected extra runner call: ${args.join(" ")}`);
    }
    return next;
  }
}

/** Map-backed in-memory `FileSystem`; only `exists`/`readTextFile` are used. */
class InMemoryFileSystem implements FileSystem {
  readonly files = new Map<string, string>();

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  exists(path: string): boolean {
    return this.files.has(path);
  }

  isDirectory(): boolean {
    return false;
  }

  listDirectory(): string[] {
    return [];
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`File not found: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
  }

  ensureDir(): void {
    // no-op
  }
}

const CWD = "/repo";
const result = (stdout: string, stderr = "", code = 0): CommandResult => ({
  stdout,
  stderr,
  code,
});

const AUTH_OK = result("Logged in");
const REPO_OK = result('{"nameWithOwner": "owner/repo"}');

/** Build a GhClient with scripted runner results and an explicit gh path. */
function buildClient(
  results: CommandResult[],
  options?: { ghPath?: string; whichGh?: () => string | undefined },
): { client: GhClient; runner: QueueRunner; fs: InMemoryFileSystem } {
  const runner = new QueueRunner(results);
  const fs = new InMemoryFileSystem();
  const client = new GhClient({
    runner,
    cwd: CWD,
    fileSystem: fs,
    ...(options?.ghPath === undefined ? {} : { ghPath: options.ghPath }),
    ...(options?.whichGh === undefined ? {} : { whichGh: options.whichGh }),
  });
  return { client, runner, fs };
}

describe("GhClient availability", () => {
  it("reports the not-installed message when gh cannot be resolved", () => {
    // Arrange: whichGh resolves nothing and no explicit path is given.
    const { client } = buildClient([], { whichGh: () => undefined });

    // Assert
    expect(client.available).toBe(false);
    expect(client.statusMessage).toBeNull();
    expect(() => client.ensureAvailable()).toThrow(
      "GitHub CLI (gh) is not installed. Install from https://cli.github.com/.",
    );
  });

  it("reports the auth-failure message with a Details suffix", () => {
    // Arrange: auth status fails with stderr text.
    const { client } = buildClient([result("", "not logged in", 1)], {
      ghPath: "/usr/bin/gh",
    });

    // Assert
    expect(client.available).toBe(false);
    expect(client.statusMessage).toBeNull();
    expect(() => client.ensureAvailable()).toThrow(
      "GitHub CLI is installed but not authenticated. Run 'gh auth login' to authenticate. Details: not logged in",
    );
  });

  it("reports authenticated status when fully configured", () => {
    // Arrange
    const { client } = buildClient([AUTH_OK, REPO_OK], {
      ghPath: "/usr/bin/gh",
    });

    // Assert
    expect(client.available).toBe(true);
    expect(client.statusMessage).toBe(
      "GitHub CLI authenticated for owner/repo",
    );
  });

  it("marks unavailable when repo resolution returns invalid JSON", () => {
    // Arrange: auth ok but repo view returns non-JSON.
    const { client } = buildClient([AUTH_OK, result("invalid")], {
      ghPath: "/usr/bin/gh",
    });

    // Assert: the repo-resolution failure message is recorded.
    expect(client.available).toBe(false);
    expect(() => client.ensureAvailable()).toThrow(
      "GitHub CLI is authenticated but failed to resolve repository. Ensure network access and repository permissions.",
    );
  });
});

describe("GhClient.classifyEntity", () => {
  it("returns 'issue' for an issue payload", () => {
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result('{"number": 1}')],
      {
        ghPath: "/usr/bin/gh",
      },
    );
    expect(client.classifyEntity("1")).toBe("issue");
  });

  it("returns 'pull' when the payload carries a pull_request key", () => {
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result('{"number": 1, "pull_request": {}}')],
      { ghPath: "/usr/bin/gh" },
    );
    expect(client.classifyEntity("1")).toBe("pull");
  });

  it("returns null on a tolerated 404", () => {
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result("", "404 Not Found", 1)],
      { ghPath: "/usr/bin/gh" },
    );
    expect(client.classifyEntity("999")).toBeNull();
  });
});

describe("GhClient.requestJson", () => {
  it("raises with the context and code for a non-404 error", () => {
    const { client } = buildClient([AUTH_OK, REPO_OK, result("", "boom", 2)], {
      ghPath: "/usr/bin/gh",
    });
    expect(() =>
      client.requestJson(["gh", "api", "x"], { context: "Fetch thing" }),
    ).toThrow("Fetch thing failed (2): boom");
  });

  it("raises invalid-JSON when stdout cannot be parsed", () => {
    const { client } = buildClient([AUTH_OK, REPO_OK, result("not json")], {
      ghPath: "/usr/bin/gh",
    });
    expect(() =>
      client.requestJson(["gh", "api", "x"], { context: "Fetch thing" }),
    ).toThrow("Fetch thing returned invalid JSON");
  });
});

describe("GhClient.fetchRepoFile", () => {
  it("decodes base64 content", () => {
    // Arrange: content base64-encoded as gh would return it.
    const content = "test content";
    const encoded = Buffer.from(content, "utf8").toString("base64");
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result(JSON.stringify({ content: encoded }))],
      { ghPath: "/usr/bin/gh" },
    );

    // Act / Assert
    expect(client.fetchRepoFile("test.txt")).toBe(content);
  });

  it("returns null when the file fetch fails (404)", () => {
    const { client } = buildClient([AUTH_OK, REPO_OK, result("", "404", 1)], {
      ghPath: "/usr/bin/gh",
    });
    expect(client.fetchRepoFile("missing.txt")).toBeNull();
  });

  it("returns null when content is not a string", () => {
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result(JSON.stringify({ content: 123 }))],
      { ghPath: "/usr/bin/gh" },
    );
    expect(client.fetchRepoFile("test.txt")).toBeNull();
  });
});

describe("GhClient.ciStatus", () => {
  it("selects the first run status", () => {
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result(JSON.stringify([{ status: "success" }]))],
      { ghPath: "/usr/bin/gh" },
    );
    expect(client.ciStatus("abc123")).toEqual(["success", []]);
  });

  it("falls back to conclusion when status is absent", () => {
    const { client } = buildClient(
      [AUTH_OK, REPO_OK, result(JSON.stringify([{ conclusion: "failure" }]))],
      { ghPath: "/usr/bin/gh" },
    );
    expect(client.ciStatus("abc123")).toEqual(["failure", []]);
  });

  it("returns [null, []] for an empty run list", () => {
    const { client } = buildClient([AUTH_OK, REPO_OK, result("[]")], {
      ghPath: "/usr/bin/gh",
    });
    expect(client.ciStatus("abc123")).toEqual([null, []]);
  });
});
