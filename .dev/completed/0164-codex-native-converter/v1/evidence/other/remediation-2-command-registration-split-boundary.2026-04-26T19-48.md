Timestamp: 2026-04-26T19:56:29.2722493-04:00
Subject: repo-automation command-registration split boundaries

Planned helper surfaces:
1. `repo-automation-command-registration-admin.ts`
   - Scope: low-prompt or infrastructure-oriented registrations that either dispatch directly or manage review/support workflows.
   - Commands: `collectCommitContext`, `collectPrContext`, `pushDownCopilotCustomizations`, `pushDownCodexAndAgentsCustomizations`, `pushDownClaudeCustomizations`, `runCodexNativeConverter`, `syncAgentsFromInstructions`, and `listMcpTools`.
   - Why this is cohesive: these commands coordinate repository automation, conversion, or review-support actions and share the same service-plus-output dependencies without participating in feature-folder promotion flows.

2. `repo-automation-command-registration-feature-workflows.ts`
   - Scope: feature-entry and issue-promotion registrations that prompt for short names, issue numbers, promotion type, work mode, or feature metadata before delegating to the service.
   - Commands: `newPotentialBugEntry`, `newPotentialEntry`, `linkParentChild`, `potentialToIssue`, and `newActiveFeatureFolder`.
   - Why this is cohesive: these commands form a single family around potential-entry promotion and feature-folder creation. They share the same prompt helpers, workflow-argument parsing, and service delegation shape.

Assembly plan:
- Keep `repo-automation-command-registration.ts` as the thin public coordinator that exports `registerRepoAutomationCommands`.
- Move the shared `RepoAutomationCommandRegistrationOptions` type into a dedicated support file so helper modules can import it without circular dependencies.
- Preserve behavior by keeping command IDs, prompt text, workflow-argument resolution, and service method calls identical; only the file boundaries change.
