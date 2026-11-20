import { describe, expect, it, jest } from "@jest/globals";

import type { MigrateDevelopmentDocsResult } from "../../src/lib/development-docs-migration/migrate-development-docs-service-call";
import { handleMigrateDevelopmentDocs } from "../../src/mcp-handlers/development-docs-migration-handler";
import type { RepoAutomationService } from "../../src/repo-automation-service-contract";
import { createMockService } from "../mcp-server-test-service";

type MigrateMethod = NonNullable<
  RepoAutomationService["migrateDevelopmentDocs"]
>;

const RESULT: MigrateDevelopmentDocsResult = {
  tool: "migrate_development_docs",
  workspaceRoot: "/work",
  summary: "migrate_development_docs dry-run",
  artifacts: [],
};

describe("handleMigrateDevelopmentDocs", () => {
  it("delegates the resolved input to the service method", async () => {
    // Arrange
    const service = createMockService();
    const migrate = jest.fn<MigrateMethod>(async () => RESULT);
    service.migrateDevelopmentDocs = migrate;

    // Act
    const result = await handleMigrateDevelopmentDocs(
      {
        workspace_root: "/work",
        mode: "apply",
        rename_decisions_path: "d.json",
        report_directory: "r",
      },
      service,
    );

    // Assert
    expect(result).toBe(RESULT);
    expect(migrate).toHaveBeenCalledWith({
      workspaceRoot: "/work",
      mode: "apply",
      renameDecisionsPath: "d.json",
      reportDirectory: "r",
    });
  });

  it("throws an explicit error naming migrateDevelopmentDocs when the method is absent", async () => {
    await expect(
      handleMigrateDevelopmentDocs(
        { workspace_root: "/work", mode: "dry-run" },
        createMockService(),
      ),
    ).rejects.toThrow("migrateDevelopmentDocs");
  });

  it("propagates an input error without calling the service", async () => {
    // Arrange
    const service = createMockService();
    const migrate = jest.fn<MigrateMethod>(async () => RESULT);
    service.migrateDevelopmentDocs = migrate;

    // Act / Assert
    await expect(
      handleMigrateDevelopmentDocs(
        { workspace_root: "/work", mode: "x" },
        service,
      ),
    ).rejects.toThrow("mode is required");
    expect(migrate).not.toHaveBeenCalled();
  });
});
