# F7 Behavior-Parity Capture

Timestamp: 2026-06-26T01-15
Command: node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" (from extensions/drm-copilot/)
EXIT_CODE: 0

Output Summary:
The in-process TypeScript port reproduces the observable behavior of the bundled
`potential_to_issue.py` and `potential_to_issue_content.py`. Each parity property
below maps to one or more passing Jest tests.

Potential-file parsing:
- getFeatureName (H1 + (Potential) marker + filename fallback) -> content.test.ts "getFeatureName" cases.
- getFeaturePath (whitespace->underscore, disallowed-char strip) -> content.test.ts "getFeaturePath" cases.
- getSection (body extraction, missing heading, next-## stop, CRLF) -> content.test.ts "getSection" cases.

Issue-body construction (feature/bug/minor-audit) incl. default Evidence Checklist:
- buildBody / buildBugBody / buildMinorAuditBody exact composition -> content.test.ts "body builders".
- feature/bug/minor-audit routing + default checklist -> promotion.test.ts "feature promotion success",
  "bug promotion", "minor-audit routing".

Work-mode / promotion-type normalization + PromotionError re-wrap:
- normalizeRequestedWorkMode legacy `full` -> full-feature, and the re-wrapped
  incompatible combination -> promotion.test.ts "work-mode normalization".

gh issue create arg vector and stdin body:
- ["issue","create","--title",t,"--body-file","-","--label",type] with body on stdin
  -> gh-client.test.ts "issueCreate".

gh label create color/description:
- ["label","create",label,"--color","0e8a16","--description","Feature work"]
  -> gh-client.test.ts "ensureLabel".

gh issue view --json field list:
- ["issue","view",n,"--json","number,title,url,author,updatedAt"]
  -> gh-client.test.ts "issueView".

Missing-label recovery:
- single ensureLabel retry, no retry on non-zero ensureLabel, label-specific match
  -> promotion.missing-label.test.ts "missing-label recovery" + "isMissingLabelFailure".

Smart-punctuation normalization (replace-all):
- all mapped characters replaced everywhere -> content.test.ts "normalizeSmartPunctuation"
  and promotion.missing-label.test.ts "normalizes smart punctuation".

Metadata updates (updateMetadataLines title + Status string):
- title rewrite + Issue/Issue URL/Last Updated/Status byte-identical
  -> content.test.ts "updateMetadataLines" + promotion.test.ts "feature promotion success".

Move to docs/features/potential/promoted/:
- destination path + recorded move -> promotion.test.ts "feature promotion success",
  promotion.missing-label.test.ts "recovers ... and moves the file".

Non-zero-exit return + failure-surface preservation:
- non-zero create returns exit code with emitted output (no destination)
  -> promotion.test.ts "failure path"; the service-call helper re-surfaces it as
  `Command exited with code <n>.` -> potential-to-issue-service-call.test.ts
  "failure surface" and extension.potential-to-issue.test.ts "surfaces a non-zero
  in-process promotion failure".

extractLastUpdated deterministic parsing:
- valid date, invalid JSON, non-string updatedAt, unparseable timestamp
  -> content.test.ts "extractLastUpdated" (no wall-clock access).

Preserved service return contract:
- tool: "potential_to_issue", workspaceRoot, byte-identical summary, plus
  destinationPath (normalized promoted path) and artifacts (created issue URL)
  -> potential-to-issue-service-call.test.ts "success".

Preserved MCP input contract:
- potential_path / promotion_type / work_mode unchanged; mcp-tool-inputs.ts,
  handlePotentialToIssue, and the tool name `potential_to_issue` are NOT modified;
  their tests pass unmodified (full suite: 908 passed).

Recorded decisions:
- artifacts/destinationPath decision (P4-T1): both fields are set on success.
  `RepoAutomationExecutionResult` already supports them and no existing extension
  test asserts their absence for potential_to_issue, so the enrichment is additive.
- Failure-surface contract (P0-T2/P4-T1): prior Python-spawn path threw
  `Command exited with code <n>.`; the helper preserves this by throwing an Error
  whose message starts with that text and appends the emitted gh output lines. The
  missing-python-runtime requirement is intentionally inverted (the command now
  succeeds with no python present).
