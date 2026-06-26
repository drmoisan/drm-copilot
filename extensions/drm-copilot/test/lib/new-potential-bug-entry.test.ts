import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../src/lib/file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../src/lib/subprocess-runner";
import {
  createBugEntry,
  defaultEnvLookup,
  defaultGitConfigLookup,
  getAuthor,
  renderContent,
  validateShortName,
} from "../../src/lib/new-potential-bug-entry";

/**
 * Tests for the in-process `new-potential-bug-entry` port (F6), mirroring the
 * scenarios in `tests/scripts/dev_tools/test_new_potential_bug_entry.py`. All
 * external interactions (filesystem, git, which, env, editor launch) are
 * injected; no real subprocess, filesystem, or temp file is used.
 */

/**
 * Map-backed in-memory {@link FileSystem} fake. Records `ensureDir` calls and
 * `writeTextFile` content; `readTextFile` throws for an absent path to mirror
 * the Python `copy_file` raising `FileNotFoundError`. `glob`/`isFile` are
 * unused by the unit under test.
 */
class InMemoryFileSystem implements FileSystem {
  readonly files = new Map<string, string>();
  readonly ensuredDirs: string[] = [];

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.files.has(path);
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

  ensureDir(path: string): void {
    this.ensuredDirs.push(path);
  }
}

/**
 * Build a {@link CommandRunner} stub that returns a fixed result and records the
 * argument lists it was invoked with.
 */
function makeRunner(
  result: CommandResult,
  recorded: { args: string[][]; options: (CommandRunOptions | undefined)[] },
): CommandRunner {
  return {
    run(args: readonly string[], options?: CommandRunOptions): CommandResult {
      recorded.args.push([...args]);
      recorded.options.push(options);
      return result;
    },
  };
}

describe("validateShortName", () => {
  it("accepts a valid kebab-case name without throwing", () => {
    // Arrange / Act / Assert
    expect(() => {
      validateShortName("api-timeout");
    }).not.toThrow();
  });

  it("rejects an invalid name with the byte-identical Python message", () => {
    // Arrange / Act / Assert
    expect(() => {
      validateShortName("Invalid Name");
    }).toThrow(
      "Aborted: 'Invalid Name' is invalid. Use kebab-case letters/numbers only (e.g., api-timeout).",
    );
  });

  it("rejects an empty string", () => {
    // Arrange / Act / Assert
    expect(() => {
      validateShortName("");
    }).toThrow(
      "Aborted: '' is invalid. Use kebab-case letters/numbers only (e.g., api-timeout).",
    );
  });
});

describe("renderContent", () => {
  it("replaces all occurrences of every placeholder", () => {
    // Arrange: each placeholder appears more than once to exercise replace-all.
    const template =
      "<bug-name> on YYYY-MM-DD by - Author: name\n" +
      "<bug-name> again YYYY-MM-DD";

    // Act
    const rendered = renderContent(
      template,
      "api-timeout",
      "2025-12-15",
      "Jane",
    );

    // Assert
    expect(rendered).toBe(
      "api-timeout on 2025-12-15 by - Author: Jane\n" +
        "api-timeout again 2025-12-15",
    );
  });
});

describe("getAuthor", () => {
  it("returns git config user.name when present", () => {
    // Arrange
    const gitLookup = (key: string): string | undefined =>
      key === "user.name" ? "Jane Doe" : undefined;
    const envLookup = (): string | undefined => "env-user";

    // Act
    const author = getAuthor(gitLookup, envLookup);

    // Assert
    expect(author).toBe("Jane Doe");
  });

  it("falls back to USERNAME env when git lookup is blank", () => {
    // Arrange
    const gitLookup = (): string | undefined => undefined;
    const envLookup = (name: string): string | undefined =>
      name === "USERNAME" ? "env-user" : undefined;

    // Act
    const author = getAuthor(gitLookup, envLookup);

    // Assert
    expect(author).toBe("env-user");
  });

  it("returns 'Unknown' when both lookups return undefined", () => {
    // Arrange / Act
    const author = getAuthor(
      () => undefined,
      () => undefined,
    );

    // Assert
    expect(author).toBe("Unknown");
  });
});

describe("defaultEnvLookup", () => {
  it("returns undefined for a blank value", () => {
    // Arrange: set a whitespace-only value on a dedicated variable.
    const name = "DRM_TEST_BLANK_ENV";
    const previous = process.env[name];
    process.env[name] = "   ";
    try {
      // Act
      const value = defaultEnvLookup(name);
      // Assert
      expect(value).toBeUndefined();
    } finally {
      // Restore prior state so the test leaves no global side effect.
      if (previous === undefined) {
        delete process.env[name];
      } else {
        process.env[name] = previous;
      }
    }
  });
});

describe("defaultGitConfigLookup", () => {
  it("returns undefined when the runner reports a git failure (allowError path)", () => {
    // Arrange: a non-zero exit code models git being absent or failing.
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner({ stdout: "", stderr: "", code: 1 }, recorded);

    // Act
    const value = defaultGitConfigLookup(runner, "user.name");

    // Assert: undefined returned, and the call used allowError so it did not throw.
    expect(value).toBeUndefined();
    expect(recorded.args[0]).toEqual(["git", "config", "user.name"]);
    expect(recorded.options[0]).toEqual({ allowError: true });
  });

  it("returns the trimmed stdout when git succeeds", () => {
    // Arrange
    const recorded = {
      args: [] as string[][],
      options: [] as (CommandRunOptions | undefined)[],
    };
    const runner = makeRunner(
      { stdout: "  Jane Doe \n", stderr: "", code: 0 },
      recorded,
    );

    // Act
    const value = defaultGitConfigLookup(runner, "user.name");

    // Assert
    expect(value).toBe("Jane Doe");
  });
});

// Editor-launcher / PATH-probe tests live in
// `new-potential-bug-entry-launcher.test.ts` to keep both files under 500 lines.

describe("createBugEntry", () => {
  const template = "<bug-name> on YYYY-MM-DD by - Author: name";

  it("defaults the entry date to today's YYYY-MM-DD when no entryDate is given", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    const templateRoot = "/ext/feature-templates";
    fs.files.set(`${templateRoot}/bug/potential_bug.md`, template);

    // Act: omit entryDate so the production today-date branch runs.
    const created = createBugEntry({
      shortName: "api-timeout",
      workspace: "/workspace",
      fs,
      templateRoot,
      authorProvider: () => "Jane",
      codeLauncher: () => true,
    });

    // Assert: the created path carries a YYYY-MM-DD-prefixed filename.
    expect(created).toMatch(
      /^\/workspace\/docs\/features\/potential\/\d{4}-\d{2}-\d{2}-api-timeout\.md$/,
    );
  });

  it("writes the rendered file at the workspace potential path and returns it", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    const templateRoot = "/ext/feature-templates";
    fs.files.set(`${templateRoot}/bug/potential_bug.md`, template);

    // Act
    const created = createBugEntry({
      shortName: "api-timeout",
      workspace: "/workspace",
      fs,
      templateRoot,
      authorProvider: () => "Jane Doe",
      codeLauncher: () => true,
      entryDate: "2025-12-15",
    });

    // Assert
    expect(created).toBe(
      "/workspace/docs/features/potential/2025-12-15-api-timeout.md",
    );
    expect(fs.files.get(created)).toBe(
      "api-timeout on 2025-12-15 by - Author: Jane Doe",
    );
  });

  it("uses templateRoot/bug/potential_bug.md when templateRoot is provided", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    const templateRoot = "/ext/feature-templates";
    fs.files.set(`${templateRoot}/bug/potential_bug.md`, template);

    // Act
    const created = createBugEntry({
      shortName: "api-timeout",
      workspace: "/workspace",
      fs,
      templateRoot,
      authorProvider: () => "Jane",
      codeLauncher: () => true,
      entryDate: "2025-12-15",
    });

    // Assert: read came from the templateRoot path (write succeeded => present).
    expect(fs.files.get(created)).toBe(
      "api-timeout on 2025-12-15 by - Author: Jane",
    );
  });

  it("falls back to the workspace template when templateRoot is undefined", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    fs.files.set(
      "/workspace/docs/features/templates/bug/potential_bug.md",
      template,
    );

    // Act
    const created = createBugEntry({
      shortName: "api-timeout",
      workspace: "/workspace",
      fs,
      authorProvider: () => "Jane",
      codeLauncher: () => true,
      entryDate: "2025-12-15",
    });

    // Assert
    expect(created).toBe(
      "/workspace/docs/features/potential/2025-12-15-api-timeout.md",
    );
    expect(fs.files.get(created)).toBe(
      "api-timeout on 2025-12-15 by - Author: Jane",
    );
  });

  it("calls ensureDir on the target directory before writing", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    fs.files.set("/ext/bug/potential_bug.md", template);

    // Act
    createBugEntry({
      shortName: "api-timeout",
      workspace: "/workspace",
      fs,
      templateRoot: "/ext",
      authorProvider: () => "Jane",
      codeLauncher: () => true,
      entryDate: "2025-12-15",
    });

    // Assert
    expect(fs.ensuredDirs).toContain("/workspace/docs/features/potential");
  });

  it("emits the two WARNING lines through log when the launcher returns false", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    fs.files.set("/ext/bug/potential_bug.md", template);
    const logged: string[] = [];

    // Act
    const created = createBugEntry({
      shortName: "api-timeout",
      workspace: "/workspace",
      fs,
      templateRoot: "/ext",
      authorProvider: () => "Jane",
      codeLauncher: () => false,
      entryDate: "2025-12-15",
      log: (message) => logged.push(message),
    });

    // Assert
    expect(logged).toEqual([
      "WARNING: VS Code 'code' command not found. Open file manually:",
      `  ${created}`,
    ]);
  });

  it("throws a file-not-found error when the template path is absent", () => {
    // Arrange: no template registered in the fake.
    const fs = new InMemoryFileSystem();

    // Act / Assert
    expect(() =>
      createBugEntry({
        shortName: "api-timeout",
        workspace: "/workspace",
        fs,
        templateRoot: "/ext",
        authorProvider: () => "Jane",
        codeLauncher: () => true,
        entryDate: "2025-12-15",
      }),
    ).toThrow(/File not found/);
  });

  it("throws the validation error and performs no write for an invalid short name", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act / Assert
    expect(() =>
      createBugEntry({
        shortName: "Invalid Name",
        workspace: "/workspace",
        fs,
        templateRoot: "/ext",
        authorProvider: () => "Jane",
        codeLauncher: () => true,
        entryDate: "2025-12-15",
      }),
    ).toThrow(
      "Aborted: 'Invalid Name' is invalid. Use kebab-case letters/numbers only (e.g., api-timeout).",
    );
    // Validation runs before any filesystem work, so nothing was written.
    expect(fs.files.size).toBe(0);
    expect(fs.ensuredDirs).toHaveLength(0);
  });
});
