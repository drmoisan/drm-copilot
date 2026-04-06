---
title: "2026-04-05-ci-failing-error"
issue: 128
owner: "drmoisan"
work_mode: "minor-audit"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-05T19-46"
source_of_truth: "docs/features/active/2026-04-05-ci-failing-error-128/issue.md"
plan_path: "docs/features/active/2026-04-05-ci-failing-error-128/plan.2026-04-05T19-46.md"
---

# 2026-04-05-ci-failing-error (Minimal-Audit Plan)

## Overview

This minor-audit plan constrains Issue #128 to a small TypeScript fix in the extension bundled-path runtime plus focused Jest regression coverage for the Windows-style `C:/extension` fixture path that currently breaks Linux CI. `issue.md` is the only requirements source, and only its explicit `## Acceptance Criteria` section is authoritative for acceptance tracking.

## Deterministic Inputs

- Sole requirements source: `docs/features/active/2026-04-05-ci-failing-error-128/issue.md`
- Acceptance criteria source: `docs/features/active/2026-04-05-ci-failing-error-128/issue.md#acceptance-criteria`
- Non-required documents: `docs/features/active/2026-04-05-ci-failing-error-128/spec.md`, `docs/features/active/2026-04-05-ci-failing-error-128/user-story.md`, and `docs/features/active/2026-04-05-ci-failing-error-128/research.md`
- Constrained production target: `extensions/drm-copilot/src/command-runtime.ts`
- Constrained regression targets: `extensions/drm-copilot/test/extension.test.ts` and `extensions/drm-copilot/test/repo-automation-service.test.ts`
- Focused baseline reproduction surface: the bundled-path Jest scenarios named in `issue.md` for `helloPython`, `helloPowerShell`, `collectCommitContext`, and `newPotentialEntry`

## Deterministic Constraints

- `CON-001`: Use `issue.md` only; do not require, cite, or create `spec.md`, `user-story.md`, or `research.md`.
- `CON-002`: Keep exactly three phases in this order: Phase 0 baseline capture, Phase 1 constrained small-path implementation placeholder, Phase 2 final QC loop.
- `CON-003`: Keep production-code scope limited to `extensions/drm-copilot/src/command-runtime.ts`; any second production file requires replanning.
- `CON-004`: Keep Jest regression scope limited to `extensions/drm-copilot/test/extension.test.ts` and `extensions/drm-copilot/test/repo-automation-service.test.ts`; do not create additional test modules.
- `CON-005`: Every evidence artifact named in this plan must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` when it records a command step.
- `CON-006`: Phase 0 must include `phase0-instructions-read.md` plus one baseline artifact per baseline command step.
- `CON-007`: Phase 2 command tasks are unconditional and executor-facing; no Phase 2 command in this plan may be treated as in-scope/out-of-scope or recorded as skipped.
- `CON-008`: If any Phase 2 command changes files or fails, the executor must restart the QC loop from `[P2-T1]` and record the clean pass artifacts from that final iteration.
- `CON-009`: Only the three checkbox items under `issue.md` → `## Acceptance Criteria` may be checked off, and only after the supporting evidence named in this plan exists.

## Small-Path Directives

`DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

## Evidence Naming Rules

- Store baseline artifacts under `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/`.
- Store targeted regression artifacts under `docs/features/active/2026-04-05-ci-failing-error-128/evidence/regression-testing/`.
- Store implementation and acceptance-mapping artifacts under `docs/features/active/2026-04-05-ci-failing-error-128/evidence/other/`.
- Store final QC artifacts under `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/`.
- Use ISO-8601 timestamps in filenames with the format `yyyy-MM-ddTHH-mm`.

### Phase 0 — Baseline capture

- [x] [P0-T1] Read the mandatory policy files in repository order and write `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/phase0-instructions-read.md`.
	- Acceptance:
		- The artifact exists at the exact path above.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Policy Order:`.
		- The artifact lists these exact files in order: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`.
		- The artifact contains `Work Mode: minor-audit`.
		- The artifact contains `Acceptance Criteria Source: docs/features/active/2026-04-05-ci-failing-error-128/issue.md#acceptance-criteria`.

- [x] [P0-T2] Verify the minor-audit requirements scope and write `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t2.requirements-scope.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t2.requirements-scope.*.md` exists.
		- The artifact contains `Work Mode: minor-audit`.
		- The artifact contains `Requirements Source: docs/features/active/2026-04-05-ci-failing-error-128/issue.md`.
		- The artifact contains `Acceptance Criteria Source: docs/features/active/2026-04-05-ci-failing-error-128/issue.md#acceptance-criteria`.
		- The artifact contains `spec.md: not required`.
		- The artifact contains `user-story.md: not required`.
		- The artifact contains `research.md: not required`.
		- The artifact contains `Production Target: extensions/drm-copilot/src/command-runtime.ts`.
		- The artifact contains `Regression Targets: extensions/drm-copilot/test/extension.test.ts, extensions/drm-copilot/test/repo-automation-service.test.ts`.

- [x] [P0-T3] Run the focused baseline reproduction command `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t3.focused-repro.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t3.focused-repro.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states whether the focused repro passed or failed and names the first observed hybrid-path diagnostic if the command fails.

- [x] [P0-T4] Run the baseline extension formatter command `npm --prefix extensions/drm-copilot run format` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t4.format.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t4.format.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run format`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states either `formatted files` or `no formatting changes reported`.

- [x] [P0-T5] Run the baseline extension lint command `npm --prefix extensions/drm-copilot run lint` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t5.lint.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t5.lint.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run lint`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states either `passed` or names the first blocking ESLint diagnostic.

- [x] [P0-T6] Run the baseline extension type-check command `npm --prefix extensions/drm-copilot run typecheck` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t6.typecheck.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t6.typecheck.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run typecheck`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` states either `passed` or names the first blocking TypeScript diagnostic.

- [x] [P0-T7] Run the baseline extension unit-test command `npm --prefix extensions/drm-copilot run test:unit` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t7.test-unit.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t7.test-unit.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run test:unit`.
		- The artifact contains `EXIT_CODE:`.
		- `Output Summary:` reports suite and test totals and names the first failing bundled-path scenario if the command fails.

- [x] [P0-T8] Record the constrained small-path scope in `docs/features/active/2026-04-05-ci-failing-error-128/evidence/baseline/p0-t8.small-path-scope.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p0-t8.small-path-scope.*.md` exists.
		- The artifact contains `Budget: 1 production TypeScript file + 2 Jest modules`.
		- The artifact contains `Production Target: extensions/drm-copilot/src/command-runtime.ts`.
		- The artifact contains `Regression Targets: extensions/drm-copilot/test/extension.test.ts, extensions/drm-copilot/test/repo-automation-service.test.ts`.
		- The artifact copies the exact three checkbox texts from `issue.md` under `## Acceptance Criteria`.

### Phase 1 — Constrained small-path implementation placeholder

- [ ] [P1-T1] Lock execution scope to `extensions/drm-copilot/src/command-runtime.ts`, `extensions/drm-copilot/test/extension.test.ts`, `extensions/drm-copilot/test/repo-automation-service.test.ts`, `docs/features/active/2026-04-05-ci-failing-error-128/issue.md`, `docs/features/active/2026-04-05-ci-failing-error-128/plan.2026-04-05T19-46.md`, and evidence artifacts under this feature folder.
	- Acceptance:
		- Exactly one artifact matching `docs/features/active/2026-04-05-ci-failing-error-128/evidence/other/p1-t1.scope-lock.*.md` exists.
		- The artifact contains `Allowed Files:` followed by the exact file list above.
		- The artifact contains `Out-of-Scope: any second production TypeScript file`.
		- The artifact contains `spec.md/user-story.md/research.md remain non-required minor-audit inputs`.

- [ ] [P1-T2] [expect-fail] Add or update the `helloPython` Windows-root regression scenario in `extensions/drm-copilot/test/extension.test.ts` so a mocked `extensionUri.fsPath = "C:/extension"` on a POSIX host asserts the bundled Python script path remains `C:/extension/resources/templates/hello_python.py`.
	- Acceptance:
		- `extensions/drm-copilot/test/extension.test.ts` contains the exact scenario string `helloPython preserves C:/extension on POSIX hosts`.
		- `extensions/drm-copilot/test/extension.test.ts` contains the exact expected path string `C:/extension/resources/templates/hello_python.py`.
		- The scenario uses a mocked Windows-style `extensionUri.fsPath` value of `C:/extension`.
		- No production file is modified by this task.

- [ ] [P1-T3] [expect-fail] Add or update the `helloPowerShell` Windows-root regression scenario in `extensions/drm-copilot/test/extension.test.ts` so a mocked `extensionUri.fsPath = "C:/extension"` on a POSIX host asserts the bundled PowerShell script path stays under `C:/extension/resources/templates/` rather than the Linux checkout root.
	- Acceptance:
		- `extensions/drm-copilot/test/extension.test.ts` contains the exact scenario string `helloPowerShell preserves C:/extension on POSIX hosts`.
		- The scenario asserts that the spawned script path starts with `C:/extension/resources/templates/`.
		- No production file is modified by this task.

- [ ] [P1-T4] [expect-fail] Add or update the `collectCommitContext` Windows-root regression scenario in `extensions/drm-copilot/test/repo-automation-service.test.ts` so a mocked `extensionUri.fsPath = "C:/extension"` on a POSIX host asserts the bundled repo-automation script path remains under `C:/extension/resources/templates/`.
	- Acceptance:
		- `extensions/drm-copilot/test/repo-automation-service.test.ts` contains the exact scenario string `collectCommitContext preserves C:/extension on POSIX hosts`.
		- The scenario asserts that the spawned script path starts with `C:/extension/resources/templates/`.
		- No production file is modified by this task.

- [ ] [P1-T5] [expect-fail] Add or update the `newPotentialEntry` Windows-root regression scenario in `extensions/drm-copilot/test/repo-automation-service.test.ts` so a mocked `extensionUri.fsPath = "C:/extension"` on a POSIX host asserts the bundled repo-automation script path remains under `C:/extension/resources/templates/`.
	- Acceptance:
		- `extensions/drm-copilot/test/repo-automation-service.test.ts` contains the exact scenario string `newPotentialEntry preserves C:/extension on POSIX hosts`.
		- The scenario asserts that the spawned script path starts with `C:/extension/resources/templates/`.
		- No production file is modified by this task.

- [ ] [P1-T6] [expect-fail] Run the targeted red Jest command `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"` before changing `extensions/drm-copilot/src/command-runtime.ts` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/regression-testing/p1-t6.red-jest.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p1-t6.red-jest.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"`.
		- `EXIT_CODE:` is non-zero.
		- The artifact contains `Failure:` text naming at least one of the four targeted Windows-root scenarios.

- [ ] [P1-T7] Apply the minimal production change in `extensions/drm-copilot/src/command-runtime.ts` so `resolveBundledScriptPath` preserves Windows drive-prefixed extension roots such as `C:/extension` as absolute paths when the host process runs on POSIX.
	- Acceptance:
		- No production TypeScript file outside `extensions/drm-copilot/src/command-runtime.ts` is modified.
		- `extensions/drm-copilot/src/command-runtime.ts` still exports `resolveBundledScriptPath`.
		- The updated helper contains a deterministic code path that treats `C:/extension`-style roots as absolute before joining the bundled relative path.

- [ ] [P1-T8] Run the targeted green Jest command `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/regression-testing/p1-t8.green-jest.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p1-t8.green-jest.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.test.ts test/repo-automation-service.test.ts -t "helloPython|helloPowerShell|collectCommitContext|newPotentialEntry"`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` names `helloPython`, `helloPowerShell`, `collectCommitContext`, and `newPotentialEntry` as passing Windows-root regression scenarios.

- [ ] [P1-T9] Write the acceptance-criteria mapping artifact `docs/features/active/2026-04-05-ci-failing-error-128/evidence/other/p1-t9.acceptance-mapping.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p1-t9.acceptance-mapping.*.md` exists.
		- The artifact contains `Requirements Source: docs/features/active/2026-04-05-ci-failing-error-128/issue.md`.
		- The artifact copies the exact three checkbox texts from `issue.md` under `## Acceptance Criteria`.
		- The artifact maps each checkbox text to supporting evidence from `p1-t8.green-jest.*.md` and the final QC artifact from `[P2-T4]`.
		- The artifact contains the exact sentence `Only issue.md acceptance-criteria checkboxes may be changed from - [ ] to - [x] after supporting evidence exists; preserve the checkbox text exactly.`

### Phase 2 — Final QC loop

- [ ] [P2-T1] Run the final extension formatter command `npm --prefix extensions/drm-copilot run format` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/p2-t1.format.*.md`; if this command changes files or exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t1.format.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run format`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states either `formatted files` or `already formatted after final pass`.

- [ ] [P2-T2] Run the final extension lint command `npm --prefix extensions/drm-copilot run lint` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/p2-t2.lint.*.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t2.lint.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run lint`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states that ESLint passed with no remaining blocking diagnostics.

- [ ] [P2-T3] Run the final extension type-check command `npm --prefix extensions/drm-copilot run typecheck` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/p2-t3.typecheck.*.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t3.typecheck.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run typecheck`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` states that TypeScript type-checking passed with zero blocking diagnostics.

- [ ] [P2-T4] Run the final extension unit-test command `npm --prefix extensions/drm-copilot run test:unit` and save the result to `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/p2-t4.test-unit.*.md`; if this command exits non-zero, resume the QC loop from `[P2-T1]` after corrections.
	- Acceptance:
		- Exactly one artifact matching `p2-t4.test-unit.*.md` exists.
		- The artifact contains `Timestamp:`.
		- The artifact contains `Command: npm --prefix extensions/drm-copilot run test:unit`.
		- `EXIT_CODE:` is `0`.
		- `Output Summary:` reports suite and test totals and explicitly states that the Windows-root bundled-path regression scenarios for `helloPython`, `helloPowerShell`, `collectCommitContext`, and `newPotentialEntry` passed.

- [ ] [P2-T5] Restart the QC loop from `[P2-T1]` if any command in `[P2-T1]` through `[P2-T4]` changes files or fails.
	- Acceptance:
		- One clean consecutive iteration completes with `EXIT_CODE: 0` for `[P2-T1]`, `[P2-T2]`, `[P2-T3]`, and `[P2-T4]`.
		- The final pass leaves no formatter-induced file changes pending.

- [ ] [P2-T6] Write the clean-pass summary artifact `docs/features/active/2026-04-05-ci-failing-error-128/evidence/qa-gates/p2-t6.clean-pass-summary.*.md`.
	- Acceptance:
		- Exactly one artifact matching `p2-t6.clean-pass-summary.*.md` exists.
		- The artifact cites the exact artifact paths produced by `[P2-T1]`, `[P2-T2]`, `[P2-T3]`, and `[P2-T4]`.
		- The artifact reports final PASS or FAIL status for each of the three acceptance criteria copied from `issue.md`, with citations to `p1-t8.green-jest.*.md` and `p2-t4.test-unit.*.md`.
		- The artifact contains the exact sentence `No Phase 2 command task was skipped.`
		- The artifact contains `Non-Required Docs Confirmed: spec.md not required; user-story.md not required; research.md not required`.
