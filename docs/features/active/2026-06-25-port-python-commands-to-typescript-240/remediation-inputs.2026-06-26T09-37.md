# Remediation Inputs: F11 ts-command-runtime-cleanup (Epic #240)

**Entry Timestamp:** 2026-06-26T09-37
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base Branch:** `main` (merge-base `bbfbab94`)
**Head:** `feat/ts-port-command-runtime-cleanup-240` (`8def2ad`)

## Pointer to Audit Artifacts

- `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/policy-audit.2026-06-26T09-37.md`
- `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/code-review.2026-06-26T09-37.md`
- `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/feature-audit.2026-06-26T09-37.md`

## Blocking Findings

**Blocking finding count: 0.**

There are no FAIL findings and no material/blocking PARTIAL findings. The policy audit verdict is FULLY COMPLIANT (PASS); the code review recommendation is Go. No code remediation is required for merge readiness.

## Non-Blocking Items Documented for Completeness

This artifact is produced to record the single non-blocking PARTIAL acceptance criterion and two pre-existing Info items with explicit guidance. None of these require an atomic remediation plan or worker execution; they are not regressions introduced by F11.

### Item 1 — AC-E5 PARTIAL (external CI observation; not a code defect)

- **Criterion:** AC-E5 "All CI gates pass on each feature PR."
- **Status:** PARTIAL. All local CI-equivalent gates pass for both languages (format/lint/typecheck EXIT 0; TS 1389 tests pass; Python 1123 pass / 19 skip; TS coverage 96.62% line / 88.29% branch; Python 85.72% line / 85.97% branch). The PR-context summary reports CI status at HEAD as "(not available)"; no PR exists yet for this branch, so no CI run on a PR head has been observed.
- **Required action (workflow next step, not code work):** Open the PR for `feat/ts-port-command-runtime-cleanup-240`; confirm the CI workflows — including the Python "Code Quality & Tests" matrix (3.10-3.13) — report green on the PR head. No source change is expected.
- **Verification command(s):** `gh pr checks <pr-number>` after the PR is opened; expect all required checks `success`.
- **Why not blocking:** No CI check has failed; the gate has simply not yet run. The `modified-workflow-needs-green-run` rule does not fire (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` changes in the diff).

### Item 2 — Pre-existing files over 500 lines (Info; outside F11 diff)

- **Files:** `extensions/drm-copilot/src/workflow-command-arguments.ts` (663 lines), `extensions/drm-copilot/test/extension.workflow-commands.test.ts` (774 lines).
- **Status:** Info. Both exist byte-identically at the merge base `bbfbab94` (663 and 774 lines) and are unmodified by F11.
- **Required action (separate follow-up, not F11):** Split each file under the 500-line limit in a dedicated change.
- **Verification command(s):** `wc -l extensions/drm-copilot/src/workflow-command-arguments.ts extensions/drm-copilot/test/extension.workflow-commands.test.ts` (target each <= 500).

### Item 3 — Plan-traceability of two Python test edits (Minor)

- **Files:** `tests/scripts/dev_tools/test_push_down_claude_customizations.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`.
- **Status:** Minor. Both were surgically edited to remove bundled-Python-parity helpers/tests against the deleted `resources/scripts/dev_tools/**` tree, but plan tasks P5-T1..T5 named only `test_push_down_copilot_customizations_helpers.py` for surgical edits.
- **Required action (documentation only):** Record these two additional edits in the F11 plan/evidence for traceability. No code change required; the edits are correct and leave zero bundled references in `tests/`.
- **Verification command(s):** `rg -n "resources/scripts/dev_tools" tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` (expect zero).

## Do Not Do

- Do not weaken or remove any retained `scripts/dev_tools/**` source or `tests/scripts/dev_tools/**` source test.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not re-introduce any `runtimeKind: "python"` path, bundled `.py`, or Python spawn.
- Do not expand scope beyond the three documented items; none requires an atomic remediation plan.
- Do not change the `extensions/drm-copilot` Jest toolchain to Vitest (accepted divergence D1; out of epic scope).

## Disposition

No remediation cycle is required for merge. The next workflow step is to open the PR and observe CI (AC-E5). Items 2 and 3 are non-blocking follow-ups.
