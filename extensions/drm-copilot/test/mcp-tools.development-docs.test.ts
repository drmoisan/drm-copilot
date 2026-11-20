import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import type { RepoAutomationService } from "../src/repo-automation-service-contract";
import { createMockService } from "./mcp-server-test-service";

type MigrateMethod = NonNullable<
  RepoAutomationService["migrateDevelopmentDocs"]
>;

const ARGS = {
  workspace_root: "/work",
  mode: "dry-run",
  rename_decisions_path: "d.json",
  report_directory: "reports",
};

describe("dispatchRepoAutomationTool migrate_development_docs", () => {
  it("(a) returns the service summary and artifacts and passes the inputs unchanged", async () => {
    // Arrange
    const service = createMockService();
    const migrate = jest.fn<MigrateMethod>(async () => ({
      tool: "migrate_development_docs",
      workspaceRoot: "/work",
      summary: "moves: 3",
      artifacts: ["reports/a.md", "reports/a.json"],
    }));
    service.migrateDevelopmentDocs = migrate;

    // Act
    const result = await dispatchRepoAutomationTool(
      "migrate_development_docs",
      ARGS,
      service,
    );

    // Assert
    expect(result).toMatchObject({
      ok: true,
      tool: "migrate_development_docs",
      summary: "moves: 3",
      artifacts: ["reports/a.md", "reports/a.json"],
    });
    expect(migrate).toHaveBeenCalledWith({
      workspaceRoot: "/work",
      mode: "dry-run",
      renameDecisionsPath: "d.json",
      reportDirectory: "reports",
    });
  });

  it("(b) returns ok false naming migrateDevelopmentDocs when the service lacks the method", async () => {
    const result = await dispatchRepoAutomationTool(
      "migrate_development_docs",
      ARGS,
      createMockService(),
    );
    expect(result.ok).toBe(false);
    expect(result.summary).toContain("migrateDevelopmentDocs");
  });

  it("(c) returns ok false naming mode for an invalid mode without calling the service", async () => {
    // Arrange
    const service = createMockService();
    const migrate = jest.fn<MigrateMethod>();
    service.migrateDevelopmentDocs = migrate;

    // Act
    const result = await dispatchRepoAutomationTool(
      "migrate_development_docs",
      { workspace_root: "/work", mode: "move" },
      service,
    );

    // Assert
    expect(result.ok).toBe(false);
    expect(result.summary).toContain("mode");
    expect(migrate).not.toHaveBeenCalled();
  });

  it("(d) returns ok false with the message of a rejection", async () => {
    // Arrange
    const service = createMockService();
    service.migrateDevelopmentDocs = jest.fn<MigrateMethod>(async () => {
      throw new Error(
        "migrate_development_docs refused: tracked files have uncommitted changes",
      );
    });

    // Act
    const result = await dispatchRepoAutomationTool(
      "migrate_development_docs",
      ARGS,
      service,
    );

    // Assert
    expect(result).toMatchObject({
      ok: false,
      tool: "migrate_development_docs",
      summary:
        "migrate_development_docs refused: tracked files have uncommitted changes",
    });
  });
});
