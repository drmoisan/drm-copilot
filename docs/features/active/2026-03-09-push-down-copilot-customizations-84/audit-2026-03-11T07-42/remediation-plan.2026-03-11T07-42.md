# Remediation Plan — push-down-copilot-customizations (#84)

- **Issue:** 84
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-11T07-42
- **Status:** Planned
- **Version:** review-remediation-1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- Authoritative remediation scope: [`remediation-inputs.2026-03-11T07-42.md`](./remediation-inputs.2026-03-11T07-42.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance & Context
- [x] [P0-T1] Verify the review artifacts `policy-audit.2026-03-11T07-42.md`, `code-review.2026-03-11T07-42.md`, `feature-audit.2026-03-11T07-42.md`, and `remediation-inputs.2026-03-11T07-42.md` exist under `docs/features/active/2026-03-09-push-down-copilot-customizations-84/`
  - Acceptance: Each file path exists and is readable.
- [x] [P0-T2] Record the current line count of `extensions/drm-copilot/src/extension.ts` and confirm the file exceeds the repo’s 500-line cap before refactoring
  - Acceptance: `Get-Content extensions/drm-copilot/src/extension.ts | Measure-Object -Line` reports a value greater than `500`.
- [x] [P0-T3] Confirm the bundled wrapper still contains the review-flagged `Any` usage before changing it
  - Acceptance: `Select-String -Path extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py -Pattern 'from typing import Any|publisher_module: Any'` returns both flagged matches.
- [x] [P0-T4] Confirm the README still contains stale `Scaffold` documentation strings before editing it
  - Acceptance: `Select-String -Path extensions/drm-copilot/README.md -Pattern 'Scaffold Extension|Scaffold Utils|Scaffold: Collect Commit Context'` returns at least one match.

### Phase 1 — Reduce `extension.ts` to policy-compliant size
- [x] [P1-T1] Create `extensions/drm-copilot/src/command-runtime.ts` and move `RuntimeKind`, `RuntimeResolution`, `CommandSpec`, `createOutputChannel`, `getWorkspaceRoot`, `detectRuntime`, `runCommandWithOutput`, and `executeBundledScript` out of `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extension.ts` imports these symbols from `./command-runtime` and no longer defines them inline.
- [x] [P1-T2] Create `extensions/drm-copilot/src/pr-context-branches.ts` and move `BranchDiscoveryResult`, `runGitForTextOutput`, `scoreBranchForPriority`, `sortRemoteBranchCandidates`, `discoverPrBaseBranches`, and `pickPrBaseBranch` out of `extensions/drm-copilot/src/extension.ts`
  - Acceptance: `extension.ts` imports these symbols from `./pr-context-branches` and no longer defines them inline.
- [x] [P1-T3] Keep `extensions/drm-copilot/src/extension.ts` limited to placeholder specs, command registration, `activate`, and `deactivate`, and reduce the touched file to `<= 500` lines
  - Acceptance: `Get-Content extensions/drm-copilot/src/extension.ts | Measure-Object -Line` reports `<= 500`.
- [x] [P1-T4] Re-run the focused extension registration/execution tests after the extraction without changing their asserted behavior
  - Acceptance: `npm --prefix extensions/drm-copilot exec -- jest test/extension.test.ts test/extension.integration.test.ts test/extension.collect-pr-context.test.ts test/extension.placeholder-commands.test.ts` exits `0`.

### Phase 2 — Restore a typed Python wrapper boundary
- [x] [P2-T1] Define a local typed contract in `extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py` that describes the imported publisher module surface needed by the wrapper
  - Acceptance: The wrapper file contains a protocol, typed adapter, or equivalent narrow contract for `push_down_customizations` and `RealPushDownFileSystem`.
- [x] [P2-T2] Replace `from typing import Any` and `publisher_module: Any = ...` in the wrapper with the typed contract from `[P2-T1]` without adding suppressions
  - Acceptance: `Select-String -Path extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py -Pattern '\bAny\b|type: ignore|# noqa'` returns no matches.
- [x] [P2-T3] Preserve the wrapper's runtime path contract while completing the typing cleanup
  - Acceptance: `Select-String -Path extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py -Pattern 'resources/scripts|resources/customizations|artifact_root|--destination'` returns all four expected strings.

### Phase 3 — Correct README drift
- [x] [P3-T1] Update `extensions/drm-copilot/README.md` so the title and command labels use current `drm-copilot` naming instead of stale `Scaffold` wording
  - Acceptance: The README contains `# drm-copilot` and `drm-copilot: Collect Commit Context`.
- [x] [P3-T2] Update `extensions/drm-copilot/README.md` so all output-channel references use the actual channel name `drm-copilot`
  - Acceptance: `Select-String -Path extensions/drm-copilot/README.md -Pattern 'Scaffold Utils'` returns no matches and `Select-String -Path extensions/drm-copilot/README.md -Pattern 'drm-copilot'` returns the updated output-channel text.
- [x] [P3-T3] Keep README command documentation aligned with `extensions/drm-copilot/package.json` and `extensions/drm-copilot/src/extension.ts` without changing runtime behavior
  - Acceptance: The README contains `drmCopilotExtension.collectCommitContext`, `drmCopilotExtension.collectPrContext`, and `drmCopilotExtension.pushDownCopilotCustomizations`.

### Phase 4 — Final QA
- [x] [P4-T1] Run extension-scope TypeScript formatting check after the refactor
  - Acceptance: `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exits `0`.
- [x] [P4-T2] Run extension-scope ESLint after the refactor
  - Acceptance: `npm --prefix extensions/drm-copilot run lint` exits `0`.
- [x] [P4-T3] Run extension-scope type checking after the refactor
  - Acceptance: `npm --prefix extensions/drm-copilot run typecheck` exits `0`.
- [x] [P4-T4] Run extension-scope unit tests with coverage after the refactor
  - Acceptance: `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` exits `0`.
- [x] [P4-T5] Run Python formatting check after the wrapper typing cleanup
  - Acceptance: `poetry run black --check .` exits `0`.
- [x] [P4-T6] Run Python lint after the wrapper typing cleanup
  - Acceptance: `poetry run ruff check` exits `0`.
- [x] [P4-T7] Run Python type checking after the wrapper typing cleanup
  - Acceptance: `poetry run pyright` exits `0`.
- [x] [P4-T8] Run the full Python test suite with coverage after the wrapper typing cleanup
  - Acceptance: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` exits `0`.

## Test Plan

- **Unit:** Existing Jest tests under `extensions/drm-copilot/test/*.test.ts` and existing Pytest push-down tests under `tests/scripts/dev_tools/` must remain green.
- **Integration:** Existing extension integration coverage for bundled wrapper execution and PR-context compatibility must remain green.
- **Manual/CLI:** Use the line-count and `Select-String` verification commands in Phases 0-3 to confirm the structural/doc fixes landed exactly as intended.

## Open Questions / Notes

- This plan is intentionally limited to the three follow-ups identified in the 2026-03-11 review set. It does **not** reopen feature acceptance criteria, which are already marked PASS in `feature-audit.2026-03-11T07-42.md`.
- No public command IDs, runtime contracts, or artifact paths should change while executing this remediation plan.
