---
title: "2026-04-26-codex-native-converter-164-remediation"
issue: 164
owner: "atomic_planner"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-26T19-20"
source_of_truth:
	- "docs/features/active/2026-04-26-codex-native-converter-164/spec.md"
	- "docs/features/active/2026-04-26-codex-native-converter-164/user-story.md"
	- "docs/features/active/2026-04-26-codex-native-converter-164/remediation-inputs.2026-04-26T19-20.md"
review_inputs:
	- "docs/features/active/2026-04-26-codex-native-converter-164/policy-audit.2026-04-26T19-20.md"
	- "docs/features/active/2026-04-26-codex-native-converter-164/code-review.2026-04-26T19-20.md"
	- "docs/features/active/2026-04-26-codex-native-converter-164/feature-audit.2026-04-26T19-20.md"
plan_path: "docs/features/active/2026-04-26-codex-native-converter-164/remediation-plan.2026-04-26T19-20.md"
work_mode_source: "docs/features/active/2026-04-26-codex-native-converter-164/issue.md"
work_mode_marker: "- Work Mode: full-feature"
---

# Atomic Remediation Plan — Feature #164

## Overview

This plan remediates the post-implementation feature-review findings for `codex-native-converter` without reopening delivered feature behavior. The acceptance criteria in `user-story.md` are already PASS, so the scope is limited to structural policy compliance for the touched TypeScript production files and to a clean review rerun after those fixes land.

## Deterministic Inputs

- Repository root: `c:\Users\DanMoisan\repos\drm-copilot-wt-20260426132938-bug-wt-script`
- Target plan path: `docs/features/active/2026-04-26-codex-native-converter-164/remediation-plan.2026-04-26T19-20.md`
- Authoritative remediation scope: `docs/features/active/2026-04-26-codex-native-converter-164/remediation-inputs.2026-04-26T19-20.md`
- Review context:
	- `docs/features/active/2026-04-26-codex-native-converter-164/policy-audit.2026-04-26T19-20.md`
	- `docs/features/active/2026-04-26-codex-native-converter-164/code-review.2026-04-26T19-20.md`
	- `docs/features/active/2026-04-26-codex-native-converter-164/feature-audit.2026-04-26T19-20.md`
- Acceptance-criteria sources:
	- `docs/features/active/2026-04-26-codex-native-converter-164/spec.md`
	- `docs/features/active/2026-04-26-codex-native-converter-164/user-story.md`
- Canonical feature evidence root: `docs/features/active/2026-04-26-codex-native-converter-164/evidence/`
- Deterministic Windows-safe line-count command form: `pwsh -NoProfile -Command "(Get-Content '<path>' | Measure-Object -Line).Lines"`

## In-Scope Remediation Findings

| Ref | Summary |
|---|---|
| R-1 | Reduce `extensions/drm-copilot/src/extension.ts` to 500 lines or fewer without changing public command behavior. |
| R-2 | Reduce `extensions/drm-copilot/src/repo-automation-service.ts` to 500 lines or fewer without changing the repo-automation service contract. |
| R-3 | Regenerate review artifacts against the correct working-tree scope after remediation and confirm the policy findings are closed. |

## Deterministic Constraints

- Do not modify `.github/instructions/*.md` files.
- Do not expand scope beyond R-1 through R-3 from `remediation-inputs.2026-04-26T19-20.md`.
- Keep the Python-first converter architecture intact; the TypeScript layer must remain a thin wrapper over the bundled Python engine.
- Preserve the existing command ID `drmCopilotExtension.runCodexNativeConverter` and MCP tool name `run_codex_native_converter`.
- Every evidence artifact created during remediation must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Use these exact TypeScript commands from the repository root for the final QA loop:
	- `npm --prefix extensions/drm-copilot run format`
	- `npm --prefix extensions/drm-copilot run lint`
	- `npm --prefix extensions/drm-copilot run typecheck`
	- `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- If any TypeScript QA step changes files or fails, restart the TypeScript QA loop from formatting.

### Phase 0 — Context, Policy Reads, and Baseline Evidence

- [x] [P0-T1] Read `.github/copilot-instructions.md` first and update `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-20.md` with the first ordered entry.
	- Acceptance: The artifact contains `Timestamp:`, `Command: document-policy-reads`, `EXIT_CODE: 0`, `Output Summary:`, `Policy Order: 1`, and `Files Read:` listing `.github/copilot-instructions.md` as the first entry.

- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` second and update `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-20.md` with the second ordered entry.
	- Acceptance: The artifact contains `Policy Order: 1..2` and `Files Read:` listing `.github/copilot-instructions.md` followed by `.github/instructions/general-code-change.instructions.md` in that exact order.

- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` third and update `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-20.md` with the third ordered entry.
	- Acceptance: The artifact contains `Policy Order: 1..3` and `Files Read:` listing the first three required policy files in the exact executor-required order.

- [x] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md` fourth and update `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-20.md` with the fourth ordered entry.
	- Acceptance: The artifact contains `Policy Order: 1..4` and `Files Read:` listing the first four required policy files in the exact executor-required order.

- [x] [P0-T5] Read `.github/instructions/typescript-unit-test.instructions.md` fifth and finalize `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/phase0-instructions-read.2026-04-26T19-20.md`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: document-policy-reads`, `EXIT_CODE: 0`, `Output Summary: Phase 0 policy files read in full-feature order`, `Policy Order: 1..5`, and `Files Read:` listing all five required policy files in the exact required order.

- [x] [P0-T6] Capture baseline TypeScript formatting status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-typescript-format-check.2026-04-26T19-20.md` using the non-mutating command `npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot exec prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`, `EXIT_CODE:`, and `Output Summary:` describing whether the current baseline is already formatted or which file set requires formatting.

- [x] [P0-T7] Capture baseline TypeScript lint status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-typescript-lint.2026-04-26T19-20.md` using `npm --prefix extensions/drm-copilot run lint`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE:`, and `Output Summary:` summarizing pass/fail status and the primary diagnostic count.

- [x] [P0-T8] Capture baseline TypeScript type-check status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-typescript-typecheck.2026-04-26T19-20.md` using `npm --prefix extensions/drm-copilot run typecheck`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE:`, and `Output Summary:` summarizing pass/fail status and the primary diagnostic count.

- [x] [P0-T9] Capture baseline TypeScript test-and-coverage status in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-typescript-test-coverage.2026-04-26T19-20.md` using `npm --prefix extensions/drm-copilot run test:unit -- --coverage`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: npm --prefix extensions/drm-copilot run test:unit -- --coverage`, `EXIT_CODE:`, and `Output Summary:` with numeric coverage headline values for the baseline run.

- [x] [P0-T10] Capture the current line count for `extensions/drm-copilot/src/extension.ts` in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-extension-lines.2026-04-26T19-20.md` using `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/extension.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/extension.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:` equal to the current line count.

- [x] [P0-T11] Capture the current line count for `extensions/drm-copilot/src/repo-automation-service.ts` in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-repo-automation-service-lines.2026-04-26T19-20.md` using `pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`.
	- Acceptance: The artifact contains `Timestamp:`, `Command: pwsh -NoProfile -Command "(Get-Content 'extensions/drm-copilot/src/repo-automation-service.ts' | Measure-Object -Line).Lines"`, `EXIT_CODE: 0`, and a numeric `Output Summary:` equal to the current line count.

- [x] [P0-T12] Write `docs/features/active/2026-04-26-codex-native-converter-164/evidence/baseline/remediation-scope.2026-04-26T19-20.md` recording that all user-story acceptance criteria are already PASS and that remediation scope is limited to R-1 through R-3.
	- Acceptance: The artifact contains `Timestamp:`, `Command: document-remediation-scope`, `EXIT_CODE: 0`, `Output Summary: Acceptance criteria remain PASS; remediation scope limited to R-1 through R-3`, `Acceptance Criteria Reopened: no`, and enumerates only R-1 through R-3.

### Phase 1 — `extension.ts` Split

- [x] [P1-T1] Identify the converter-related or adjacent repo-automation registration block(s) in `extensions/drm-copilot/src/extension.ts` that can be extracted without changing external behavior.
	- Acceptance: A short design note or code comment identifies the exact extracted concern boundaries before code movement begins.

- [x] [P1-T2] Extract the selected `extension.ts` logic into one or more focused modules under `extensions/drm-copilot/src/` and update imports so activation behavior remains unchanged.
	- Acceptance: `drmCopilotExtension.runCodexNativeConverter` is still registered and existing registration tests still compile.

- [x] [P1-T3] Capture the post-split line count for `extensions/drm-copilot/src/extension.ts` in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/other/remediation-extension-lines-after.2026-04-26T19-20.md`.
	- Acceptance: The artifact records a numeric `Output Summary:` that is `<= 500`.

### Phase 2 — `repo-automation-service.ts` Split

- [x] [P2-T1] Identify the converter-specific or adjacent helper logic in `extensions/drm-copilot/src/repo-automation-service.ts` that can move into focused helper modules while keeping the public service contract stable.
	- Acceptance: A short design note or code comment identifies the exact extracted concern boundaries before code movement begins.

- [x] [P2-T2] Extract the selected service logic into one or more focused modules under `extensions/drm-copilot/src/` and update imports so `runCodexNativeConverter` and the rest of the service API continue to behave the same way.
	- Acceptance: Existing callers and tests compile without public API changes.

- [x] [P2-T3] Capture the post-split line count for `extensions/drm-copilot/src/repo-automation-service.ts` in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/other/remediation-repo-automation-service-lines-after.2026-04-26T19-20.md`.
	- Acceptance: The artifact records a numeric `Output Summary:` that is `<= 500`.

### Phase 3 — Final TypeScript QA Loop

- [x] [P3-T1] Run the final TypeScript formatting gate and capture `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-typescript-format.2026-04-26T19-20.md` with `npm --prefix extensions/drm-copilot run format`.
	- Acceptance: The artifact records `EXIT_CODE: 0`.

- [x] [P3-T2] Run the final TypeScript lint gate and capture `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-typescript-lint.2026-04-26T19-20.md` with `npm --prefix extensions/drm-copilot run lint`.
	- Acceptance: The artifact records `EXIT_CODE: 0`.

- [x] [P3-T3] Run the final TypeScript type-check gate and capture `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-typescript-typecheck.2026-04-26T19-20.md` with `npm --prefix extensions/drm-copilot run typecheck`.
	- Acceptance: The artifact records `EXIT_CODE: 0`.

- [x] [P3-T4] Run the final TypeScript test-and-coverage gate and capture `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-typescript-test-coverage.2026-04-26T19-20.md` with `npm --prefix extensions/drm-copilot run test:unit -- --coverage`.
	- Acceptance: The artifact records `EXIT_CODE: 0` and preserves changed-file coverage at `>= 90%` for the touched files.

### Phase 4 — Review Rerun

- [x] [P4-T1] Refresh PR context against `development` only if the existing artifacts are stale for the post-remediation head state, then record the outcome in `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-pr-context-status.2026-04-26T19-20.md`.
	- Acceptance: The artifact explicitly states whether the review scope is a commit range or the working-tree appendix.

- [x] [P4-T2] Regenerate `policy-audit`, `code-review`, and `feature-audit` artifacts after remediation and validate them with `scripts.dev_tools.validate_orchestration_artifacts`.
	- Acceptance: The rerun artifacts are newer than the baseline review artifacts and each validator call returns success.

- [x] [P4-T3] Write `docs/features/active/2026-04-26-codex-native-converter-164/evidence/qa-gates/remediation-final-verdict.2026-04-26T19-20.md` summarizing the post-remediation line counts, final TypeScript QA results, and updated review-artifact outcomes.
	- Acceptance: The artifact contains `Verdict: go` only if both oversized files are `<= 500` lines and the rerun review artifacts report no remaining FAIL findings.