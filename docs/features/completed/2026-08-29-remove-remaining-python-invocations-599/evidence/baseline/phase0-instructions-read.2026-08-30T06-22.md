# Phase 0 Policy Read — Issue #599

Timestamp: 2026-08-30T06-22
Task: [P0-T1]
Branch: feature/remove-remaining-python-invocations-599-r2
Worktree: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501

Policy Order: the eleven files below were read in the exact order stated by [P0-T1], which
follows the order defined by the `policy-compliance-order` skill. Each path is repository-relative
and each file was read in full from the worktree named above.

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/shell.md`
6. `.claude/rules/python.md`
7. `.claude/rules/python-suppressions.md`
8. `.claude/rules/typescript.md`
9. `.claude/rules/typescript-suppressions.md`
10. `.claude/rules/plan-acceptance-gates.md`
11. `.claude/rules/tonality.md`

## Constraints Carried Forward Into Phases 1 Through 6

- **Toolchain loop order** (`general-code-change.md`): format, lint, type-check,
  architecture-boundary, unit test, contract, integration. Restart from step 1 whenever a stage
  fails or rewrites a file.
- **File size limit** (`general-code-change.md`, `shell.md`): no production, test, or reusable
  script file exceeds 500 lines. This is the rule P1-T7 gates.
- **Coverage thresholds** (`general-unit-test.md`, `quality-tiers.md`): line coverage >= 85%
  uniformly across T1 through T4. Branch coverage >= 75% applies only to languages whose tooling
  measures it; **Pester and kcov are exempt from the branch threshold** because neither measures
  branch coverage. The exemption is a threshold exemption only — bash production files remain in
  the coverage denominator.
- **Coverage exclusion policy** (`general-unit-test.md`): no production file may be excluded from
  measurement.
- **Test file location** (`general-unit-test.md`, `shell.md`): tests mirror the production tree;
  bash tests live in `tests/shell/*.bats`. Colocation in the production tree is prohibited.
- **Temporary files in tests are prohibited** (`general-code-change.md`, `general-unit-test.md`,
  `shell.md`). Use checked-in fixtures. This governs the corpus and fixture tasks in Phases 2 and 3.
- **Bash toolchain is native** (`shell.md`): `bash scripts/bash/shell-qc.sh` invokes `shfmt`,
  `shellcheck`, `bats`, and `kcov` directly. No Python interpreter and no Poetry are involved. On
  Windows the toolchain runs under WSL.
- **Bash discovery roots** (`shell.md`): `tools/`, `scripts/`, and `.claude/lib/bash/`. The kcov
  include pattern covers all three, so the two new files this feature adds are linted, formatted,
  and coverage-measured without configuration change.
- **Bash coding standards** (`shell.md`): `set -euo pipefail` first; capture intentionally non-zero
  tool exits with `|| rc=$?`; shellcheck-clean with inline justified suppressions only; shfmt
  default formatting (tab indentation); quote all expansions.
- **Python toolchain** (`python.md`): `poetry run black`, `poetry run ruff check`,
  `poetry run pyright`, `poetry run pytest`.
- **TypeScript toolchain** (`typescript.md`): `npm run format`, `npm run lint`,
  `npm run typecheck`, Jest for tests.
- **Suppressions** (`python-suppressions.md`, `typescript-suppressions.md`): every `# noqa`,
  `# type: ignore`, `eslint-disable-next-line`, and `@ts-expect-error` must match a pre-authorized
  pattern or carry explicit user approval. `// @ts-ignore`, `// @ts-nocheck`, and file-level
  `eslint-disable` are prohibited.
- **Plan acceptance gates** (`plan-acceptance-gates.md`): G1 through G9. G1 and G2 are Blocking;
  G3 through G9 ship as Warnings. Relevant to this plan's own acceptance conditions: G7 classifies
  `ruff` as write-mode conservatively, which the plan records at [P0-T5] as an expected warning
  rather than a defect.
- **Tone** (`tonality.md`): professional, factual, neutral. No humor, no hyperbole, metaphor only
  when strictly utilitarian. Evidence-first wording — state what was verified and how.

## Verification

Acceptance for [P0-T1] is that this artifact exists and carries `Timestamp:`, `Policy Order:`, and
the eleven file paths in the exact order the task states. All three are present above.

EXIT_CODE: 0

Output Summary: Eleven policy files read in the required order from the worktree. No policy file
was modified. Reading is a read-only operation and rewrote no tracked file.
