# Feature Audit: F5 ts-resolve-prompts (Issue #240)

**Audit Date:** 2026-06-26
**Branch:** `feat/ts-port-resolve-prompts-240` (head `f2425fb`)
**Work Mode:** `full-feature` (from `issue.md`: `- Work Mode: full-feature`)

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`)
- **Merge-base SHA:** `c82de735740fc4b02ee8e69abac135efbfe9cb42`
- **Head SHA:** `f2425fb46b293a0373dbdda32a666f4175791d40`
- **Audit basis:** Full feature-vs-base branch diff (`git diff --name-status c82de73..f2425fb`). The PR-context summary was stale and misclassified TypeScript source as tooling; the authoritative git diff was used.
- **Feature:** F5 of epic #240 — TypeScript port of the bundled `resolve_hard_lock_prompt.py` and `resolve_file_prompt.py` into `extensions/drm-copilot/src/lib/resolve/**`, wiring `resolveExecuteHardLockPrompt` and `resolveAtomicPlanPrompt` to in-process TS. Python source retained (removal is F11).

## Acceptance Criteria Inventory

Under `full-feature`, the authoritative AC sources are `spec.md` and `user-story.md`.

- `spec.md` contains the epic-level ACs (AC-E1..AC-E5) under `## Epic Acceptance Criteria`, plus a `## User Story` narrative and the F1 per-feature ACs. The spec states per-feature ACs are tracked in each feature's `plans/F#-*.plan.md` checklist and that epic ACs are realized incrementally, fully at F11.
- `user-story.md` is **MISSING** from the feature folder. Under `full-feature` this file is a required AC source. This is recorded as a documentation gap (see Summary). The user-story narrative is present inline in `spec.md` (`## User Story`), so the user need is documented even though the dedicated file is absent. This gap is non-blocking for F5 because: (a) the epic ACs in `spec.md` are the operative cross-cutting criteria, (b) the F5-specific ACs are authoritatively tracked in `plans/F5-resolve-prompts.plan.md`, and (c) the missing file predates F5 and is not introduced by this branch.
- F5-specific ACs (AC-F5-1..AC-F5-10) are enumerated in `plans/F5-resolve-prompts.plan.md` under `## F5 Acceptance Criteria Checklist`. These are evaluated below as the feature-scoped criteria.

## Acceptance Criteria Evaluation

### Epic ACs (`spec.md`) — F5 contribution

| ID | Criterion | Verdict (F5 contribution) | Evidence |
|----|-----------|---------------------------|----------|
| AC-E1 | Every Python command invoked by the extension/MCP server has a TS equivalent with behavior parity | PARTIAL (epic-level; F5 delivers its slice) | F5 ports `resolve_hard_lock_prompt.py` and `resolve_file_prompt.py` with parity (messages, exit codes, substitution, output write) per `f5-port-parity.md`. Epic AC-E1 spans all commands and is fully realized at F11; F5's contribution is complete. |
| AC-E2 | TS coverage for ported modules meets policy (line >= 85%, branch >= 75%) | PASS (for F5 modules) | All new `src/lib/resolve/**` files meet thresholds; repo-wide 96.3% line / 88.06% branch. `f5-final-test-coverage.md`, `f5-coverage-delta.md`, independent re-run. |
| AC-E3 | Service methods invoke in-process TS instead of spawning Python; `"python"` branch and bundled Python removed (F11) | PARTIAL (by design) | F5 wires the two service methods to in-process TS (no Python spawn for these commands). Removal of the `"python"` branch and bundled Python is explicitly F11, not F5. |
| AC-E4 | No remaining runtime dependency on a `python` interpreter | PARTIAL (epic-level) | For the two F5 commands, no Python interpreter is invoked. Full elimination across all commands is realized at F11. |
| AC-E5 | All CI gates pass on each feature PR | PASS (local toolchain) | Format/lint/typecheck/test all EXIT 0 independently this audit. CI status at HEAD not available in the PR-context artifact; local gates are green. |

### F5-specific ACs (`plans/F5-resolve-prompts.plan.md`)

| ID | Criterion (abbreviated) | Verdict | Evidence |
|----|--------------------------|---------|----------|
| AC-F5-1 | `hard-lock-prompt.ts` ports bundled `resolve_hard_lock_prompt.py` (template selection/probe, `${plan-path}`/`${work-mode}`/`${fallback-reason}`, nearest-issue.md + `v*` fallback + fail-closed, quiet/output, output write, messages, exit codes) | PASS | `src/lib/resolve/hard-lock-prompt.ts` read in full; `hard-lock-prompt.test.ts` green; `f5-port-parity.md`. |
| AC-F5-2 | `file-prompt-core.ts` + `file-prompt-variables.ts` port bundled `resolve_file_prompt.py` (variable resolution, front-matter strip, minor-audit overrides, user-story/research, unresolved-placeholder check, CLI stdout/stderr + exit codes) | PASS | Files read in full (transforms split into `file-prompt-transforms.ts`); `file-prompt-core.test.ts`, `file-prompt-variables.test.ts` green. |
| AC-F5-3 | `resolve-prompts-service-call.ts` provides two wiring functions; service methods call in-process resolvers preserving return contracts and injected template root/path | PASS | `resolve-prompts-service-call.ts` read in full; service diff shows delegation; `resolve-prompts-service-call.test.ts` green; 100% line/branch coverage on the wiring module. |
| AC-F5-4 | All I/O via injected F1 `FileSystem`; work-mode via `prompt-mode-contract.ts`; no direct `node:fs`; no clipboard/subprocess on quiet/MCP path or in tests | PASS | grep: only `node:fs` token is a doc comment; clipboard seam defaults to no-op-false; tests hermetic. |
| AC-F5-5 | `quiet`-without-`output` guard throws `resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.` at service-call layer before file work; MCP handler injection unchanged | PASS | `resolve-prompts-service-call.ts` L99-103 (verbatim message before file work); `mcp-handlers/...` not in diff. |
| AC-F5-6 | Jest tests under `test/lib/resolve/` mirror Python test scenarios; hermetic | PASS | 4 new test files present and green; in-memory `FileSystem` fakes; no temp files. |
| AC-F5-7 | Extension tests updated to in-process without weakening editor/picker/eligibility or tool-registration/dispatch/handler/input-schema assertions | PASS | grep: NO_PY_WRAPPER_SPAWN_ASSERTIONS; editor/picker/eligibility/registration cases preserved (verified case list). |
| AC-F5-8 | No file > 500 lines; ES modules; no `any`; kebab-case; AAA tests | PASS | `wc -l` max 500 (`repo-automation-service.ts`, compliant), max new 494; grep NO_ANY; ES modules; kebab-case filenames. |
| AC-F5-9 | Format/lint/typecheck/coverage-test pass; each new file line >= 85% / branch >= 75%; no regression on `src/lib/**` | PASS | Independent re-run all EXIT 0; coverage table in policy audit; `f5-coverage-delta.md`. |
| AC-F5-10 | Python `scripts/dev_tools/**`, `resources/templates/*.py`, `resources/scripts/dev_tools/*.py`, `command-runtime.ts`, `"python"` branch unmodified (F11); `resolve_execute_plan_prompt.py` not ported; scope contained | PASS | grep over diff: NONE_TOUCHED for all prohibited paths; `f5-scope-verification.md`. |

## Summary

- F5-specific acceptance criteria (AC-F5-1..AC-F5-10): all **PASS** (10/10), verified by independent toolchain re-run, file reads, coverage inspection, and scope/no-fs/no-any greps.
- Epic ACs in `spec.md`: AC-E2 and AC-E5 PASS for F5's scope; AC-E1, AC-E3, AC-E4 are epic-level and PARTIAL by design (fully realized at F11). F5's contribution to each is complete and correct.
- **Documentation gap (non-blocking):** `user-story.md` is absent from the feature folder. Under `full-feature` it is a nominal AC source. The user-story narrative is present inline in `spec.md` (`## User Story`), and F5 ACs are authoritatively tracked in the F5 plan, so no F5 acceptance criterion is unverifiable as a result. Recommend creating `user-story.md` (or recording the spec-inline narrative as the canonical source) at the epic level; this is not an F5 remediation trigger.
- No blocking findings. No FAIL or PARTIAL verdict on any F5-specific criterion.

## Acceptance Criteria Check-off

The F5 plan checklist (`plans/F5-resolve-prompts.plan.md`) already records AC-F5-1..AC-F5-10 as `[x]` (checked off during execution); this audit confirms each remains satisfied — no changes required.

The `spec.md` epic ACs (AC-E1..AC-E5) remain `[ ]` and are intentionally left unchecked: per the spec, they are realized incrementally and fully at F11. This audit does not check them off, consistent with the `acceptance-criteria-tracking` rule (only criteria evaluated PASS are checked off; the epic ACs are PARTIAL at F5 by design).

`user-story.md` could not be checked off because the file does not exist (documentation gap recorded above).

### Acceptance Criteria Status
- Source: `spec.md` (epic ACs + inline user story); `plans/F5-resolve-prompts.plan.md` (F5 ACs); `user-story.md` MISSING
- Total AC items (F5-specific): 10
- Checked off (delivered + verified this audit): 10
- Remaining (unchecked): 0 F5-specific
- Epic ACs (spec.md): 5 total, intentionally unchecked at F5 (realized at F11)
- Items remaining: none F5-specific; epic AC-E1/E3/E4 remain open by design until F11
