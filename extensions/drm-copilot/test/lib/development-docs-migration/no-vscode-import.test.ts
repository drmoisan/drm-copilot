/**
 * Architecture-boundary test (issue #1016): none of the thirteen new production
 * files of the development-docs migration imports the VS Code host module.
 */
import * as fs from "node:fs";
import * as path from "node:path";

import { describe, expect, it } from "@jest/globals";

const SRC = path.resolve(__dirname, "..", "..", "..", "src");

const NEW_PRODUCTION_FILES: ReadonlyArray<string> = [
  "lib/development-docs-migration/folder-rename-plan.ts",
  "lib/development-docs-migration/layout-map.ts",
  "lib/development-docs-migration/migrate-development-docs-service-call.ts",
  "lib/development-docs-migration/migration-apply.ts",
  "lib/development-docs-migration/migration-decisions.ts",
  "lib/development-docs-migration/migration-git.ts",
  "lib/development-docs-migration/migration-plan.ts",
  "lib/development-docs-migration/migration-report.ts",
  "lib/development-docs-migration/reference-rewrite.ts",
  "mcp-development-docs-tool-definitions.ts",
  "mcp-handlers/development-docs-migration-handler.ts",
  "mcp-tool-inputs-development-docs.ts",
  "migrate-development-docs-cli.ts",
];

describe("development-docs migration host boundary", () => {
  it("covers all thirteen new production files", () => {
    expect(NEW_PRODUCTION_FILES).toHaveLength(13);
  });

  it.each(NEW_PRODUCTION_FILES.map((file) => [file]))(
    "%s imports no vscode module",
    (file) => {
      // Arrange
      const source = fs.readFileSync(path.join(SRC, file), "utf8");

      // Assert
      expect(source).not.toMatch(/from\s+["']vscode["']/);
      expect(source).not.toMatch(/require\(\s*["']vscode["']\s*\)/);
    },
  );
});
