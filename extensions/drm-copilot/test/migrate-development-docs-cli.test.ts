import { describe, expect, it, jest } from "@jest/globals";

import type {
  MigrateDevelopmentDocsInput,
  MigrateDevelopmentDocsResult,
} from "../src/lib/development-docs-migration/migrate-development-docs-service-call";
import {
  DEFAULT_CLI_DEPENDENCIES,
  parseMigrateDevelopmentDocsArgs,
  runMigrateDevelopmentDocsCli,
} from "../src/migrate-development-docs-cli";

type Execute = (
  input: MigrateDevelopmentDocsInput,
) => MigrateDevelopmentDocsResult;

const RESULT: MigrateDevelopmentDocsResult = {
  tool: "migrate_development_docs",
  workspaceRoot: "/work",
  summary: "migrate_development_docs dry-run\nmoves: 2\nheld_items: 1",
  artifacts: ["/work/r/a.md"],
};

function deps(execute: Execute) {
  const out: string[] = [];
  const err: string[] = [];
  return {
    out,
    err,
    deps: {
      execute,
      stdout: (text: string) => out.push(text),
      stderr: (text: string) => err.push(text),
    },
  };
}

describe("runMigrateDevelopmentDocsCli", () => {
  it("maps every flag to the service input and prints the Markdown summary with exit 0", () => {
    // Arrange
    const execute = jest.fn<Execute>(() => RESULT);
    const env = deps(execute);

    // Act
    const code = runMigrateDevelopmentDocsCli(
      [
        "--workspace",
        "/work",
        "--mode",
        "apply",
        "--decisions",
        "d.json",
        "--report-dir=r",
      ],
      env.deps,
    );

    // Assert
    expect(code).toBe(0);
    expect(execute).toHaveBeenCalledWith({
      workspaceRoot: "/work",
      mode: "apply",
      renameDecisionsPath: "d.json",
      reportDirectory: "r",
    });
    expect(env.out.join("")).toBe(
      "# migrate_development_docs dry-run\n\n- moves: 2\n- held_items: 1\n- report: /work/r/a.md\n",
    );
    expect(env.err).toEqual([]);
  });

  it("exits 1 with the reason on stderr for a refusal or an execution error", () => {
    // Arrange
    const env = deps(() => {
      throw new Error(
        "migrate_development_docs refused: tracked files have uncommitted changes",
      );
    });
    const thrown = deps(() => {
      throw "plain failure";
    });

    // Act / Assert
    expect(
      runMigrateDevelopmentDocsCli(
        ["--workspace", "/w", "--mode", "dry-run"],
        env.deps,
      ),
    ).toBe(1);
    expect(env.err.join("")).toBe(
      "migrate_development_docs refused: tracked files have uncommitted changes\n",
    );
    expect(env.out).toEqual([]);
    expect(
      runMigrateDevelopmentDocsCli(
        ["--workspace", "/w", "--mode", "dry-run"],
        thrown.deps,
      ),
    ).toBe(1);
    expect(thrown.err.join("")).toBe("plain failure\n");
  });

  it.each([
    [
      ["--workspace", "/w", "--mode", "dry-run", "--force"],
      "unknown argument: --force",
    ],
    [["--mode", "dry-run"], "missing --workspace"],
    [["--workspace", "/w"], "missing --mode"],
    [["--workspace", "/w", "--mode", "move"], "invalid --mode: move"],
    [["--workspace"], "missing value for --workspace"],
    [["--workspace=", "--mode", "apply"], "missing value for --workspace"],
  ])("exits 2 on the usage error %p", (argv, message) => {
    // Arrange
    const execute = jest.fn<Execute>(() => RESULT);
    const env = deps(execute);

    // Act
    const code = runMigrateDevelopmentDocsCli(argv, env.deps);

    // Assert
    expect(code).toBe(2);
    expect(env.err.join("")).toContain(message);
    expect(env.err.join("")).toContain("usage: migrate-development-docs");
    expect(execute).not.toHaveBeenCalled();
  });

  it("parses the minimal form without optional fields", () => {
    expect(
      parseMigrateDevelopmentDocsArgs([
        "--workspace",
        ".",
        "--mode",
        "dry-run",
      ]),
    ).toEqual({
      input: { workspaceRoot: ".", mode: "dry-run" },
    });
  });

  it("writes usage errors to process.stderr through the default dependencies", () => {
    // Arrange
    const write = jest
      .spyOn(process.stderr, "write")
      .mockImplementation(() => true);

    // Act
    const code = runMigrateDevelopmentDocsCli(["--bogus"]);

    // Assert
    expect(code).toBe(2);
    expect(write).toHaveBeenCalledWith(
      expect.stringContaining("unknown argument: --bogus"),
    );
    write.mockRestore();
  });

  it("writes the summary to process.stdout through the default stdout", () => {
    // Arrange
    const write = jest
      .spyOn(process.stdout, "write")
      .mockImplementation(() => true);

    // Act
    DEFAULT_CLI_DEPENDENCIES.stdout("summary\n");

    // Assert
    expect(write).toHaveBeenCalledWith("summary\n");
    write.mockRestore();
  });
});
