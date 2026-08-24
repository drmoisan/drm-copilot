# Policy Audit — legacy-discovery-skills (Issue #367) — Cycle 1 Reaudit

- Timestamp: 2026-07-18T22-30
- Branch: `feature/legacy-discovery-skills-367`
- Base: `origin/epic/legacy-discovery-and-parity-integration` (merge-base `e395efb7`)
- Feature commit (HEAD): `bb8f8b79`
- Work Mode: `full-feature` (from `issue.md`)
- Cycle: Remediation Cycle 1 (single blocking finding, single production file changed)
- Cycle inputs: `docs/features/active/2026-07-17-legacy-discovery-skills-367/remediation-inputs.2026-07-18T21-40.md`
- Cycle plan: `docs/features/active/2026-07-17-legacy-discovery-skills-367/remediation-plan.2026-07-18T21-40.md`
- Diff scope: `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD` (full branch diff against the epic base, per the Scope Invariant), 36 files changed, +1920/-61.

## Policy Reading Order (this reaudit)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md` (only production/test language with changed files across the full branch diff)
5. `.claude/rules/typescript.md` (consulted because the remediated regression surfaces in a TypeScript/jest suite, even though no `.ts` source is changed on the branch)
6. `.claude/rules/tonality.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/orchestrator-state.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md` (scanned; not applicable to this cycle's diff — no orchestrator-state, workflow, or benchmark-baseline files changed)

## Change Set Summary (full branch diff vs epic base)

- 7 new skills: `.claude/skills/discovery-{workflow,repo-inventory,coverage-ledger,runtime-characterization,parity-matrix,behavior-reconciliation,validate-artifacts}/SKILL.md` (commit `13234ea0`, previously audited 2026-07-18T21-26, PASS)
- 7 byte-identical bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/` (commit `13234ea0`)
- 1 pytest contract module: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` (415 lines, commit `13234ea0`)
- Feature-folder docs/evidence from the initial review cycle (commit `bff412d1`)
- **Cycle 1 remediation (commit `bb8f8b79`, this reaudit's focus):** exactly one production file changed — `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — 7 insertions, 0 deletions, 0 other lines touched.

## Verdicts

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 1 | Cycle 1 fix is scoped to exactly one file, additive only | PASS | `git show bb8f8b79 --stat`: `.../pack-manifests/core.json \| 7 +++++++`, 1 file changed, 7 insertions(+), 0 deletions. `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD -- extensions/.../pack-manifests/core.json` shows only the 7 added lines; no other pack-manifest file in the same directory (`csharp-legacy.json`, `csharp-modern.json`, `powershell.json`, `python.json`, `typescript.json`) appears in the diff. |
| 2 | `core.json` parses as valid JSON after the edit | PASS | `python -c "import json; json.load(open(...))"` succeeds; re-verified directly in this reaudit. |
| 3 | Seven discovery-skill paths present, contiguous, alphabetical, in the exact required location | PASS | Parsed `paths` array: the 7 `discovery-*` entries appear in strict alphabetical order (`behavior-reconciliation < coverage-ledger < parity-matrix < repo-inventory < runtime-characterization < validate-artifacts < workflow`), inserted immediately after `.claude/skills/commit-message/SKILL.md` and immediately before `.claude/skills/epic-orchestrate/SKILL.md`, matching the remediation-plan [P1-T1] acceptance criterion verbatim. |
| 4 | No other manifest drift introduced by the fix | PASS | The pre-existing `.claude/skills/` sub-block in `core.json` contains one pre-existing out-of-order pair (`.claude/skills/human-exception-runbook/example.runbook.md` before `.../SKILL.md`) that is present identically in the pre-fix baseline (`origin/epic/legacy-discovery-and-parity-integration:core.json`) and untouched by commit `bb8f8b79`. This is pre-existing drift, not introduced by this cycle, and is outside this cycle's remediation scope. No other array or key in `core.json` differs from the pre-fix baseline besides the 7 added lines. |
| 5 | Seven skills and bundle mirrors remain byte-identical (push-down parity invariant) | PASS | `cmp` of all 7 `.claude/skills/discovery-*/SKILL.md` files against their `extensions/drm-copilot/resources/claude-customizations/.claude/skills/discovery-*/SKILL.md` mirrors: all 7 IDENTICAL, independently re-verified in this reaudit. |
| 6 | Python push-down parity gate and legacy-discovery-skills contract module pass after the fix | PASS | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py -q`: 67 passed, 0 failed, independently re-run in this reaudit (matches `evidence/qa-gates/final-qc-python-push-down-parity.2026-07-18T21-40.md`). |
| 7 | Jest pack-manifest completeness suite genuinely passes post-fix | PASS | Independently re-ran `npx jest --config jest.config.cjs --testMatch "**/claude-pack-manifest-completeness.test.ts"` from `extensions/drm-copilot`: `Tests: 7 passed, 7 total`. Independently re-ran the full suite via `npx jest --config jest.config.cjs --testMatch "**/*.test.ts"`: `Test Suites: 158 passed, 158 total`, `Tests: 1886 passed, 1886 total`, 0 failed — matching `evidence/qa-gates/final-qc-jest-pack-manifest-completeness.2026-07-18T21-40.md` exactly. |
| 8 | Literal `npm test -- <file>` invocation failure is an environment artifact, not a feature defect | PASS (documented, non-blocking) | Independently re-ran `npm test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts` from `extensions/drm-copilot`: exits with `No tests found, exiting with code 1`, `testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a2cc0098df79b544e/extensions/drm-copilot/test/**/*.test.ts - 0 matches`, reproducing the raw-backslash-before-dot-prefixed-segment defect documented in `evidence/qa-gates/final-qc-jest-pack-manifest-completeness.2026-07-18T21-40.md` and `evidence/remediation-baseline/baseline-jest-pack-manifest-completeness.2026-07-18T21-40.md`. This defect is reproduced identically pre-fix and post-fix, is tied to this worktree's dot-prefixed `.claude/worktrees/<agent>/` checkout path segment, and does not occur on the `ubuntu-latest` CI runner cited as the authoritative jest result (job URL in `remediation-inputs.2026-07-18T21-40.md`). Treated as an environment artifact per task instructions, cited with evidence, not counted as a blocking finding. |
| 9 | Toolchain — Black / Ruff / Pyright re-verified for the only Python file touched anywhere on the branch | PASS | `poetry run black --check` and `poetry run ruff check` on `test_legacy_discovery_skills_contracts.py` and `test_push_down_claude_resource_contracts.py`: both exit 0, "All checks passed". `poetry run pyright` on the same two files: 0 errors, 0 warnings. (Neither file changed in Cycle 1; re-verified to confirm no drift.) |
| 10 | Policy documents not modified (`.claude/rules/**`, `.github/instructions/**`) | PASS | `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD --name-only` filtered for those prefixes: zero matches. |
| 11 | Domain-neutrality invariant unaffected by the fix | PASS | `core.json` is a manifest listing of file paths only; it introduces no prose text and no banned-substring surface. The 7 skills themselves are unchanged since the initial audit (verified via `cmp` bundle-identity check above, which would fail on any content drift). |
| 12 | Tonality (professional, factual, no humor/hyperbole) | PASS | The single changed file (`core.json`) and the cycle's evidence/plan/inputs Markdown were read in full; language is neutral, literal, and factual. No jokes, emojis, hyperbole, or decorative metaphor found. |

## Evidence Location Compliance

- `scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0 (no violations), re-run in this reaudit.
- `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD --name-only` and `git status --porcelain` filtered for `^artifacts/(baselines|qa|evidence|coverage)/`: zero matches.
- All Cycle 1 evidence resides under `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/{remediation-baseline,qa-gates}/` with ISO-8601 `yyyy-MM-ddTHH-mm` timestamps, consistent with `evidence-and-timestamp-conventions`.

## Rejected Scope Narrowing

None. No caller instruction in this task attempted to narrow the audit below the full branch diff against the resolved epic base; the task explicitly specified the full-diff scope command, which was used verbatim.

## Coverage Verification by Language

- Python: the only language with changed files across the **entire** branch diff (`git diff origin/epic/legacy-discovery-and-parity-integration...HEAD --name-only | grep -E '\.(ts|tsx|py|ps1|cs)$'` returns exactly one file: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py`, added in commit `13234ea0` and unchanged by Cycle 1). Verdict PASS — carried forward from the initial audit (`policy-audit.2026-07-18T21-26.md`): repo-wide line 88.87% (>= 85%), branch 87.28% (>= 75%), zero delta vs baseline. Cycle 1 adds no new or modified Python file, so this verdict is unaffected.
- TypeScript: `core.json` is a JSON manifest, not a `.ts` source file; zero `.ts` files are changed anywhere in the full branch diff. No TypeScript coverage obligation arises from this cycle. (The regression itself was caught by a pre-existing jest suite exercising unchanged `.ts` source; no new or modified TypeScript file requires a coverage artifact.)
- PowerShell, C#: zero changed files in the branch diff; no coverage obligation.

## Observation (non-blocking)

The Cycle 1 remediation artifacts (`remediation-inputs.2026-07-18T21-40.md`, `remediation-plan.2026-07-18T21-40.md`, and the `evidence/remediation-baseline/` and new `evidence/qa-gates/` files) are present on disk but not yet committed to the branch (`git status --porcelain` shows them as untracked `??`). This does not affect the correctness of the `bb8f8b79` fix commit, which is already committed, but the documentation trail should be committed before the branch is considered merge-ready.

## Assumptions

- The resolved base branch is `origin/epic/legacy-discovery-and-parity-integration`, per the task's explicit instruction and consistent with the initial-cycle audit's resolved base.
- The `ubuntu-latest` CI job cited in `remediation-inputs.2026-07-18T21-40.md` is treated as the authoritative jest signal for the literal `npm test` invocation, per task instruction; this reaudit independently reproduced both the local environment defect and the `--testMatch` workaround result to corroborate the evidence file's claims rather than accepting them uncorroborated.

## Blocking Findings

Blocking findings count: 0
