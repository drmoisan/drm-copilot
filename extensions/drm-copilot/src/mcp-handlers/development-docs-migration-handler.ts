/**
 * Thin handler of `migrate_development_docs` (issue #1016).
 *
 * It resolves the input and calls the optional service method. Input errors
 * and a host without the method are thrown to the dispatcher's failure path.
 */
import type { MigrateDevelopmentDocsResult } from "../lib/development-docs-migration/migrate-development-docs-service-call";
import { resolveMigrateDevelopmentDocsToolInput } from "../mcp-tool-inputs-development-docs";
import type { RepoAutomationService } from "../repo-automation-service-contract";

/**
 * Run one `migrate_development_docs` call.
 *
 * @param rawInput The raw MCP arguments.
 * @param service The shared repo-automation service.
 * @returns The service result.
 * @throws Error For invalid input or a host without `migrateDevelopmentDocs`.
 */
export async function handleMigrateDevelopmentDocs(
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<MigrateDevelopmentDocsResult> {
  const input = resolveMigrateDevelopmentDocsToolInput(rawInput);
  if (service.migrateDevelopmentDocs === undefined) {
    throw new Error(
      "This host does not provide migrateDevelopmentDocs for migrate_development_docs.",
    );
  }
  return service.migrateDevelopmentDocs(input);
}
