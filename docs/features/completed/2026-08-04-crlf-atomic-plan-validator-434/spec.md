# crlf-atomic-plan-validator (Spec)

- **Issue:** #434
- **Parent (optional):** none
- **Owner:** TBD
- **Last Updated:** 2026-08-04T09-49
- **Status:** Draft
- **Version:** 0.1

## Context
The TypeScript MCP atomic-plan validator splits input only on LF. Canonical plans
with CRLF or lone-CR line endings retain a trailing carriage return and valid
phase and task lines fail their end-anchored structural regular expressions.

Environment:
- OS/version: Windows 11
- Python version: Not applicable
- Command/flags used: `validate_orchestration_artifacts` with `artifact_type = plan`
- Data source or fixture: Canonical completed atomic-plan text encoded with LF, CRLF, or CR line endings

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Encode a canonical atomic plan containing phase headings and completed task lines using CRLF or CR line endings.
2. Validate the plan through the MCP `validate_orchestration_artifacts` tool.
3. ...

Expected:
The validator accepts structurally identical canonical plans regardless of LF,
CRLF, or CR line endings.

Actual:
The LF version validates, but CRLF and CR versions fail canonical phase/task
validation because the validator uses `text.split("\n")` and leaves `\r` on
each line. TaskMaster issue #400's CRLF-only plan demonstrates the failure.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `Line N: phase heading must match \`### Phase N — <Title>\`.` and `Line N: task line must match \`- [ ] [P#-T#] <Title>\`.`


## Scope & Non-Goals
- In scope:
  - Normalize physical-line separation only in `validatePlanText` so canonical
    atomic plans validate equivalently with LF (`\n`), CRLF (`\r\n`), and lone
    CR (`\r`) line endings.
  - Add a deterministic, table-driven Jest regression using the existing
    completed-task `VALID_PLAN` fixture.
  - Verify the extension and generated npm MCP bundle preserve the three-way
    validation parity before release publication.
- Out of scope / non-goals:
  - Changing canonical phase/task syntax, phase/task sequencing rules,
    diagnostic messages, dispatcher routes, or MCP tool schemas.
  - Normalizing plan file contents on disk, mutating artifacts, or accepting
    malformed phase/task lines.
  - Extending line-ending changes to unrelated validators or artifact types.
- Explicitly excluded systems, integrations, or datasets:
  - Python reference-validator changes, VS Code host integration tests, new
    dependencies, configuration keys, feature flags, and data migrations.

## Root Cause Analysis
`extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` line 73
uses LF-only splitting. The Python reference validator uses line-ending-neutral
`splitlines()` and accepts the same content. With `text.split("\n")`, CRLF
input retains `\r` at the end of each physical line, causing end-anchored
`PLAN_PHASE_RE` and `PLAN_TASK_RE` matches to fail. A lone-CR plan is not split
into source lines at all.


## Proposed Fix

### Design summary (what changes where):
Replace the LF-only separator in `validatePlanText` with the single
line-ending expression `/\r\n|\n|\r/`. Keep the CRLF alternative first so it is
consumed as one physical-line boundary. This is a one-line production change.

### Boundaries and invariants to preserve:
- Preserve source-order traversal, one-based reported line numbers, phase
  resets, expected task-number tracking, empty-input behavior, and final-line
  handling.
- Preserve `PLAN_PHASE_RE`, `PLAN_TASK_RE`, all validation error strings, and
  the public `validate_orchestration_artifacts` input/output contract.
- The only behavior change is that otherwise identical valid plans are split
  into the same source lines for LF, CRLF, and CR input.

### Dependencies or blocked work:
- Existing extension and package Node dependencies are sufficient; no schema,
  package, or configuration change is required.
- Release publication remains gated on successful extension quality checks and
  generated-bundle smoke validation.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`

#### Functions/classes/CLI commands impacted:
- `validatePlanText(text: string): string[]` changes only its source-line
  separator.
- `validateArtifact` and the MCP
  `validate_orchestration_artifacts` `artifact_type: "plan"` route retain their
  existing interfaces and delegate to the updated validator.

#### Data flow and validation changes:
- The existing MCP request reads plan text and passes it unchanged to
  `validateArtifact`, which delegates to `validatePlanText`.
- `validatePlanText` will convert text to source lines using
  `/\r\n|\n|\r/` before applying the existing phase and task checks. It does
  not trim lines or alter the text passed to any other validator.

#### Error handling and logging updates:
- No error-message, logging, or telemetry update is required. Existing errors
  continue to report malformed structural content and source line numbers.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag is required. Revert the delimiter-only change and its
  regression test together if rollback is necessary.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input remains a plan text string supplied through the existing MCP
  `validate_orchestration_artifacts` request with `artifact_type: "plan"`.
- Output remains a `string[]` of validation errors; a structurally valid plan
  returns `[]` for each of LF, CRLF, and CR separators.

#### Required configuration keys and defaults:
- None.

#### Backward-compatibility expectations:
- LF behavior remains unchanged. CRLF and CR plans gain parity with the Python
  reference validator without changing canonical plan syntax or public APIs.

#### Performance constraints (latency/throughput/memory):
- Maintain linear traversal of the input and one source-line array; no
  additional I/O, process launch, or dependency is permitted in the validator.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): canonical plan text can be supplied
  with any of the three documented separators, and the generated package MCP
  server is available for release smoke validation.
- Constraints (budget, performance, compatibility): use the minimum one-line
  normalization; preserve all existing structural-validation semantics and do
  not create temporary test files or launch the VS Code host.
- External dependencies (services, libraries, releases): existing Node/Jest
  dependencies and the npm publication workflow only; no new dependency or
  service integration.

## Data / API / Config Impact
- User-facing or API changes: no schema or tool-name change; valid CRLF and CR
  plans now produce the same successful validation result as LF plans.
- Data or migration considerations: none; validation reads text without
  persisting or rewriting plan artifacts.
- Logging/telemetry updates (if any): none; existing diagnostic output remains
  unchanged for malformed content.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flags or
  configuration schemas change. The published npm bundle must contain the
  updated validator before the release is published.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: add failing CRLF completed-task coverage, then prove LF, CRLF, and CR validation parity.
- [x] Integration scenario to retest: run the generated MCP bundle against canonical plan content with each line ending.
- [x] Manual verification notes: no manual validation is required; the release workflow must publish and inspect the immutable npm bundle.

- Regression tests to add or update: add
  `accepts a valid plan with LF, CRLF, or CR line endings` in
  `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`.
  Use table entries for `\n`, `\r\n`, and `\r`, each derived from
  `VALID_PLAN.split("\n").join(lineEnding)`, and assert
  `validatePlanText` returns `[]`. The fixture must retain
  `- [x] [P1-T1] Third task` to cover the completed-task regression.
- Unit tests (Jest) for the fixed behavior and boundaries: run the added
  three-separator parity test and all existing validator tests. The regression
  must fail for CRLF and CR before the delimiter change, then pass for all
  three variants after it.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  retain and pass existing malformed phase heading, malformed task line,
  orphan task, phase mismatch, task-number sequence, no-phase, and no-task
  tests. Confirm no whitespace trimming weakens the end-anchored grammar.
- Error handling and logging verification: assert unchanged malformed-plan
  messages through existing tests; no logs are introduced.
- Coverage impact and targets for changed lines/modules: run configured
  `test:coverage` and retain its 85% line and 75% branch thresholds for
  `src/lib/validate/orchestration-artifacts.ts`.
- Toolchain commands to run (format → lint → type-check → test): from
  `extensions/drm-copilot`, run `npm run format`, `npm run lint`,
  `npm run typecheck`, `npm run test:unit`, and `npm run test:coverage` in a
  final clean sequence. Then run `npm run bundle:mcp-server`,
  `npm --prefix ../../packages/mcp-server run prepack`, and
  `npm --prefix ../../packages/mcp-server run build`.
- Manual validation steps (if required): the generated-bundle smoke is
  authorized manual QA, not a Jest test. Prefer in-memory payloads when the
  MCP protocol supports them. Otherwise, after verifying the exact absolute
  path, create LF, CRLF, and CR byte variants only in a uniquely named
  directory beneath the system temporary directory; invoke the package through
  normal stdio, record all responses, then remove only that verified directory
  and prove the worktree is clean. Do not add tracked fixtures or use
  temporary assets in Jest.


## Acceptance Criteria
- [x] `validatePlanText` returns `[]` for the same canonical completed plan
  encoded with LF, CRLF, and lone-CR separators.
- [x] `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`
  contains and passes `accepts a valid plan with LF, CRLF, or CR line endings`,
  using the existing completed-task fixture for all three variants.
- [x] Existing malformed-plan and numbering tests pass with their current
  error-message contracts, proving phase/task grammar and diagnostics were not
  weakened.
- [x] The production change is limited to replacing the source-line delimiter
  in `validatePlanText`; no public MCP schema, dispatcher route, dependency,
  configuration, or unrelated artifact validator changes.
- [x] `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`,
  and `npm run test:coverage` pass in one final sequence from
  `extensions/drm-copilot`.
- [x] Extension MCP bundling, package `prepack`, package `build`, and a normal
  stdio smoke of the generated package MCP server verify successful plan
  validation for LF, CRLF, and CR before npm publication.
- [x] No logging, telemetry, documentation, configuration, or data migration
  update is required; the release evidence records that this was verified.

## Risks & Mitigations
- Technical or operational risks: incorrectly ordering the line-ending
  alternatives could treat CRLF as two boundaries; trimming lines or changing
  regular expressions could weaken canonical structural validation; testing
  only the extension could omit the published bundle.
- Mitigations and rollbacks: use `/\r\n|\n|\r/` with CRLF first, retain the
  existing expressions and diagnostics, prove all three variants in Jest and
  generated-package smoke validation, and revert the single delimiter change
  with its regression if a rollback is required.

## Rollout & Follow-up
- Release/rollout steps: complete the final extension quality sequence, bundle
  the extension, run package `prepack` and `build`, perform the three-separator
  generated MCP stdio smoke, then publish and inspect the immutable npm bundle
  through the existing release workflow.
- Post-fix monitoring or clean-up tasks: retain the release receipt showing
  LF/CRLF/CR success. No runtime telemetry or additional cleanup is required.
- Links: [Issue #434](https://github.com/drmoisan/drm-copilot/issues/434);
  `artifacts/research/2026-08-04T09-53-crlf-atomic-plan-validator-434-research.md`.
