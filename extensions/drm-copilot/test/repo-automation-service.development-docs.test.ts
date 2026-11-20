import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationService } from "../src/repo-automation-service";
import type { CommandResult } from "../src/lib/subprocess-runner";
import {
  FakeCommandRunner,
  InMemoryFileSystem,
} from "./lib/development-docs-migration/migration-test-fakes";

describe("DefaultRepoAutomationService.migrateDevelopmentDocs", () => {
  it("delegates to the migration service call with the injected file system and runner", async () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      "/work/docs/features/active/2026-10-30-foo-1016/spec.md": "spec",
    });
    const runner = new FakeCommandRunner((args): CommandResult => {
      if (args[1] === "rev-parse") {
        return { stdout: "true", stderr: "", code: 0 };
      }
      if (args[1] === "ls-files" && !args.includes("--others")) {
        return {
          stdout: "docs/features/active/2026-10-30-foo-1016/spec.md\0",
          stderr: "",
          code: 0,
        };
      }
      return { stdout: "", stderr: "", code: 0 };
    });
    const service = createRepoAutomationService({
      extensionRoot: "/extension",
      output: { appendLine: () => undefined },
      fileSystem,
      runner,
    });

    // Act
    const result = await service.migrateDevelopmentDocs?.({
      workspaceRoot: "/work",
      mode: "dry-run",
    });

    // Assert
    expect(result?.tool).toBe("migrate_development_docs");
    expect(result?.summary).toContain("moves: 1");
    expect(result?.summary).toContain("renames: 1");
    expect(
      runner.calls.every((recorded) => recorded.options?.cwd === "/work"),
    ).toBe(true);
    expect(fileSystem.writes).toEqual([]);
  });
});
