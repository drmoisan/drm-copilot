import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../../src/lib/file-system";
import {
  type CommandResult,
  type CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { GhClient } from "../../../src/lib/pr-context/gh-client-core";

/**
 * Tests for the issue/PR detail port (`pr_context/github.py` part 2/3). Covers
 * `issueDetails`, `prDetails`, `closingIssues`, and `currentPr` including the
 * label/assignee/author guards, comment formatting, user-story local-vs-remote
 * resolution, and the fallback strings. A queued fake runner returns scripted
 * results in call order; an in-memory filesystem backs local story reads.
 */

/** Queued fake `CommandRunner`; returns the next scripted result per call. */
class QueueRunner implements CommandRunner {
  private readonly queue: CommandResult[];

  constructor(results: CommandResult[]) {
    this.queue = [...results];
  }

  run(args: readonly string[]): CommandResult {
    const next = this.queue.shift();
    if (next === undefined) {
      throw new Error(`Unexpected extra runner call: ${args.join(" ")}`);
    }
    return next;
  }
}

/** Map-backed in-memory `FileSystem` for local user-story resolution. */
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

/** Build a client with scripted results, seeding the filesystem if provided. */
function buildClient(
  results: CommandResult[],
  seed?: Record<string, string>,
): { client: GhClient; fs: InMemoryFileSystem } {
  const runner = new QueueRunner(results);
  const fs = new InMemoryFileSystem();
  if (seed) {
    for (const [path, content] of Object.entries(seed)) {
      fs.files.set(path, content);
    }
  }
  const client = new GhClient({
    runner,
    cwd: CWD,
    fileSystem: fs,
    ghPath: "/usr/bin/gh",
  });
  return { client, fs };
}

describe("issueDetails", () => {
  it("applies fallback strings for a minimal payload", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(JSON.stringify({ number: 1 })),
    ]);
    const details = client.issueDetails("1");
    expect(details.number).toBe("#1");
    expect(details.title).toBe("(no title)");
    expect(details.state).toBe("(unknown)");
    expect(details.author).toBe("(unknown)");
    expect(details.body).toBe("(no body)");
  });

  it("extracts labels, assignees, and body", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          body: "Issue body text",
          labels: [{ name: "bug" }],
          assignees: [{ login: "user1" }],
        }),
      ),
    ]);
    const details = client.issueDetails("1");
    expect(details.labels).toEqual(["bug"]);
    expect(details.assignees).toEqual(["user1"]);
    expect(details.body).toBe("Issue body text");
  });

  it("skips non-object label and assignee entries", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          labels: ["not a dict", { name: "bug" }],
          assignees: ["not a dict", { login: "assignee1" }],
        }),
      ),
    ]);
    const details = client.issueDetails("1");
    expect(details.labels).toEqual(["bug"]);
    expect(details.assignees).toEqual(["assignee1"]);
  });

  it("formats comments and skips malformed entries", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          comments_url:
            "https://api.github.com/repos/owner/repo/issues/1/comments",
        }),
      ),
      result(
        JSON.stringify([
          "not a dict",
          {
            user: { login: "testuser" },
            created_at: "2024-01-01T00:00:00Z",
            body: "Test comment",
          },
        ]),
      ),
    ]);
    const details = client.issueDetails("1");
    expect(details.comments).toHaveLength(1);
    expect(details.comments[0]).toBe(
      "testuser at 2024-01-01T00:00:00Z: Test comment",
    );
  });

  it("uses (unknown) for a comment without a user", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          comments_url:
            "https://api.github.com/repos/owner/repo/issues/1/comments",
        }),
      ),
      result(
        JSON.stringify([
          { body: "Comment without user", created_at: "2024-01-01T00:00:00Z" },
        ]),
      ),
    ]);
    const details = client.issueDetails("1");
    expect(details.comments[0]).toContain("(unknown)");
  });

  it("resolves a local user-story file before the repo API", () => {
    const { client } = buildClient(
      [
        AUTH_OK,
        REPO_OK,
        result(
          JSON.stringify({
            number: 1,
            title: "Feature request",
            body: "[user-story.md](docs/features/active/test/user-story.md)",
          }),
        ),
      ],
      {
        "/repo/docs/features/active/test/user-story.md": "# User Story Content",
      },
    );
    const details = client.issueDetails("1");
    expect(details.userStoryPath).toBe(
      "docs/features/active/test/user-story.md",
    );
    expect(details.userStoryContent).toBe("# User Story Content");
  });

  it("fetches the user story from the repo API when not local", () => {
    const encoded = Buffer.from("# Remote User Story", "utf8").toString(
      "base64",
    );
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          title: "Feature",
          body: "[user-story.md](docs/features/active/test/user-story.md)",
        }),
      ),
      result(JSON.stringify({ content: encoded })),
    ]);
    const details = client.issueDetails("1");
    expect(details.userStoryPath).toBe(
      "docs/features/active/test/user-story.md",
    );
    expect(details.userStoryContent).toBe("# Remote User Story");
  });
});

describe("prDetails", () => {
  it("returns basic PR details", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(JSON.stringify({ number: 1, title: "Test" })),
    ]);
    const details = client.prDetails("1");
    expect(details.number).toBe("#1");
    expect(details.title).toBe("Test");
  });

  it("extracts all fields", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          title: "Test PR",
          body: "PR body",
          state: "open",
          headRefName: "feature-branch",
          baseRefName: "main",
          labels: [{ name: "bug" }],
          assignees: [{ login: "dev1" }],
        }),
      ),
    ]);
    const details = client.prDetails("1");
    expect(details.body).toBe("PR body");
    expect(details.state).toBe("open");
    expect(details.headRef).toBe("feature-branch");
    expect(details.baseRef).toBe("main");
    expect(details.labels).toEqual(["bug"]);
    expect(details.assignees).toEqual(["dev1"]);
  });

  it("extracts files changed", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          files: [{ path: "src/main.py" }, { path: "tests/test_main.py" }],
        }),
      ),
    ]);
    expect(client.prDetails("1").filesChanged).toEqual([
      "src/main.py",
      "tests/test_main.py",
    ]);
  });

  it("skips malformed labels, assignees, and closing issues", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 1,
          labels: ["not a dict", { name: "bug" }, { no_name_field: "v" }],
          assignees: ["not a dict", { login: "dev1" }, { no_login_field: "v" }],
          closingIssuesReferences: [
            "not a dict",
            { number: 5 },
            { no_number: "v" },
          ],
        }),
      ),
    ]);
    const details = client.prDetails("1");
    expect(details.labels).toEqual(["bug"]);
    expect(details.assignees).toEqual(["dev1"]);
    expect(details.closingIssues).toEqual(["#5"]);
  });

  it("extracts the author login", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(JSON.stringify({ number: 1, author: { login: "contributor1" } })),
    ]);
    expect(client.prDetails("1").author).toBe("contributor1");
  });

  it("raises when the repo cannot be resolved", () => {
    // Auth ok but repo view returns invalid JSON, so hydration left repo unset.
    const { client } = buildClient([AUTH_OK, result("invalid")]);
    expect(() => client.prDetails("1")).toThrow(
      "GitHub CLI is authenticated but failed to resolve repository.",
    );
  });

  it("raises on a non-object payload", () => {
    const { client } = buildClient([AUTH_OK, REPO_OK, result("[]")]);
    expect(() => client.prDetails("1")).toThrow(
      "Unexpected pull request payload format.",
    );
  });
});

describe("closingIssues", () => {
  it("extracts and sorts closing references", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(JSON.stringify({ closingIssuesReferences: [{ number: 5 }] })),
    ]);
    expect(client.closingIssues()).toEqual(["#5"]);
  });

  it("returns an empty list when there are no references", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(JSON.stringify({ closingIssuesReferences: [] })),
    ]);
    expect(client.closingIssues()).toEqual([]);
  });
});

describe("currentPr", () => {
  it("returns null when gh is unavailable", () => {
    const runner = new QueueRunner([]);
    const client = new GhClient({
      runner,
      cwd: CWD,
      fileSystem: new InMemoryFileSystem(),
      whichGh: () => undefined,
    });
    expect(client.currentPr()).toBeNull();
  });

  it("returns null when no PR is active (non-zero exit)", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result("", "no pull request", 1),
    ]);
    expect(client.currentPr()).toBeNull();
  });

  it("returns null on invalid JSON", () => {
    const { client } = buildClient([AUTH_OK, REPO_OK, result("invalid")]);
    expect(client.currentPr()).toBeNull();
  });

  it("returns null when the number is missing", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(JSON.stringify({ title: "no number" })),
    ]);
    expect(client.currentPr()).toBeNull();
  });

  it("returns the PR with extracted fields on success", () => {
    const { client } = buildClient([
      AUTH_OK,
      REPO_OK,
      result(
        JSON.stringify({
          number: 42,
          title: "Current PR",
          author: { login: "contributor1" },
          labels: ["not a dict", { name: "feature" }],
          assignees: ["not a dict", { login: "dev1" }],
          closingIssuesReferences: ["not a dict", { number: 10 }],
        }),
      ),
    ]);
    const pr = client.currentPr();
    expect(pr).not.toBeNull();
    expect(pr?.number).toBe("#42");
    expect(pr?.author).toBe("contributor1");
    expect(pr?.labels).toEqual(["feature"]);
    expect(pr?.assignees).toEqual(["dev1"]);
    expect(pr?.closingIssues).toEqual(["#10"]);
  });
});
