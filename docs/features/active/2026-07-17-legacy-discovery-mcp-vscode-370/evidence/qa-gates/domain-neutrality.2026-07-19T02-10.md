# QA Gate — Domain Neutrality

- Timestamp: 2026-07-19T02-10
- Issue: #370

## SearchScope

All production and test files added or modified by this feature under `extensions/drm-copilot/`:

- `src/runtime-detection.ts`
- `src/repo-automation-execute-discovery.ts`
- `src/repo-automation-service-contract.ts`
- `src/repo-automation-service.ts`
- `src/mcp-tool-inputs-discovery.ts`
- `src/mcp-handlers/discovery-handlers.ts`
- `src/repo-automation-tool-names.ts`
- `src/mcp-tools.ts`
- `src/mcp-discovery-tool-definitions.ts`
- `src/mcp-repo-automation-tool-definitions.ts`
- `src/mcp-tool-definitions.ts`
- `src/discovery-command-registration.ts`
- `src/extension.ts`
- `package.json` (contributes.commands entries)
- `jest.config.cjs`
- New test files: `test/runtime-detection.test.ts`, `test/repo-automation-execute-discovery.test.ts`, `test/repo-automation-service.discovery.test.ts`, `test/mcp-tool-inputs-discovery.test.ts`, `test/mcp-tools.discovery.test.ts`, `test/extension.discovery-commands.test.ts`
- Extended test files: `test/mcp-repo-automation-tool-definitions.test.ts`, `test/mcp-server.test.ts`, and the four `createMockService` builders (`test/mcp-server.test.ts`, `test/mcp-server-epic-validation.test.ts`, `test/mcp-tools.codex-native-converter.test.ts`, `test/mcp-tools.push-down-claude.test.ts`)

## SearchPatterns

Case-insensitive extended regex: `taskmaster|tmw|outlook|email|task-management`

Command: `grep -rniE "taskmaster|tmw|outlook|email|task-management" <files>`

## SearchResult

- none — zero matches across all searched files (grep exit code 1 on every invocation).

## Notes

- The identifiers `dotnet` and `vsto` appear in tool names, command ids, and the mapping table. These name the analyzed technology stack declared by the epic's own domain-neutral feature naming (a build/interop stack), not a consumer domain, and are not in the prohibited-identifier set. Domain specificity (which repository, which paths) is supplied only at runtime via the domain-profile argument.

## Result: PASS

The exposure layer contains no TaskMaster/TMW/Outlook/email/task-management identifier in any tool name, command id, schema field, description, or implementation.
