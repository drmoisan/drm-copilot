# Policy Compliance Audit — Issue #597 (caller-site-invocation-correctness)

- Timestamp: 2026-08-30T07-27
- Feature folder: `docs/features/active/2026-08-29-caller-site-invocation-correctness-597`
- Base branch (resolved): `origin/epic/claude-runtime-portability-integration` @ `4ec38c4c38cff49fc67a228a831340e34c9a378e`
- Merge base: `f134119cd986221417dbd15c98e84f74c9364a5f`
- Feature branch: `bug/caller-site-invocation-correctness-597-r2` @ `7d6ceeb145404e7ca8474ee218cab51fc7aa82f9`
- Work Mode (from `issue.md`): `full-bug` → AC source is `spec.md` only.
- Reviewer scope: full branch diff, merge-base → HEAD (30 changed files, verified independently via `git diff --name-only`), not any narrowed subset.

## Rejected Scope Narrowing

No scope-narrowing attempt was detected in the delegation prompt for this review. The prompt explicitly reaffirmed the full-branch-diff scope invariant rather than narrowing it. No entry required under this heading.

## Full Branch Diff Inventory (independently derived)

`git diff --stat f134119cd986221417dbd15c98e84f74c9364a5f...HEAD` reports 30 files changed, 481 insertions(+), 77 deletions(-):

- 3 production instruction-text files under `.claude/**`: `.claude/agents/parallel-planner.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`.
- 3 byte-identical bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
- 24 feature-folder documentation/evidence files under `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/**` (issue.md, spec.md, plan.2026-08-29T16-05.md, and 21 evidence artifacts).

No file outside `.claude/**`, its bundle mirror, or the feature's own `docs/features/active/**` folder is touched. No `.ps1`, `.psm1`, `.py`, `.ts`, `.tsx`, or `.cs` file appears anywhere in the diff — confirmed by inspecting the full `git diff --name-only` file list; every changed path has a `.md` extension.

## Policy Reading Order Compliance

Verdict: **PASS**

Evidence: `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/baseline/phase0-instructions-read.md` (plan task P0-T1) records `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/powershell.md` read in that order, matching the baseline order in this skill plus the PowerShell language rule pulled in for contextual background (the three edited files are prose instruction text referencing PowerShell invocations, not `.psm1`/`.ps1` source). This reviewer independently read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/quality-tiers.md` (supplied in the system context) before evaluating the change.

## Evidence Location Compliance

Verdict: **PASS**

- All 21 evidence artifacts in this branch are written under the canonical path `docs/features/active/2026-08-29-caller-site-invocation-correctness-597/evidence/{baseline,qa-gates,issue-updates}/`, per `evidence-and-timestamp-conventions`.
- Independently re-ran the canonical scanner: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` → exit code 0, no output (no violations).
- No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears anywhere in the branch diff.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition applies; no delegation prompt in this review specified a non-canonical evidence path.

## Coverage Verification

Verdict: **N/A for all four coverage languages — zero changed files in each.**

This is an acceptable verdict per the coverage-verification contract, which requires explicit PASS/FAIL only for languages with changed files in the branch diff. Independently confirmed via `git diff --name-only`: every changed file has a `.md` extension. No `.ts`/`.tsx`, `.py`, `.ps1`/`.psm1`, or `.cs` file is added, modified, or deleted anywhere in the branch.

| Language | Changed files in branch? | Verdict | Basis |
|---|---|---|---|
| TypeScript | No | N/A | 0 `.ts`/`.tsx` files in diff |
| Python | No | N/A | 0 `.py` files in diff |
| PowerShell | No | N/A | 0 `.ps1`/`.psm1` files in diff (the three edited `.md` files *discuss* PowerShell invocation text but are not PowerShell source) |
| C# | No | N/A | 0 `.cs` files in diff |

No coverage artifact absence finding applies, because no language in the branch diff has changed source files. This distinction (prose describing PowerShell commands inside Markdown vs. an actual `.ps1`/`.psm1` file change) was independently verified by inspecting the diff hunks: the only content changes are inside fenced ```powershell code blocks and a parenthetical sentence within `SKILL.md`/`.md` agent-definition files, not compiled/interpreted source files.

## File Size Limit

Verdict: **PASS (exempt)**. All changed files are Markdown documentation files, an explicit exception to the 500-line production/test/script limit in `.claude/rules/general-code-change.md`. Largest changed file (`plan.2026-08-29T16-05.md`) is 364 lines.

## Coverage Exclusion Policy / Test File Location / I/O Boundaries / Naming

Verdict: **N/A**. These policies govern production and test source code. No source file (production or test) is added, modified, or deleted in this branch; only Markdown instruction text and feature-tracking documents change. No `exclude` entries were added to any coverage config in this diff (independently confirmed — no config file appears in the diff).

## Tonality Compliance

Verdict: **PASS**. The two newly-inserted prose sentences ("The default PowerShell 5.1 execution policy blocks `Import-Module` of a `.psm1` file, so `pwsh` is mandatory here.") and the corrected `parallel-add/SKILL.md` parenthetical are factual, neutral, and free of hyperbole, humor, or metaphor, consistent with `.claude/rules/tonality.md`.

## Cross-Cutting Test Constraint (mirror byte-equality)

Verdict: **PASS**

- Re-ran `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q` → 1 passed.
- Independently re-diffed each of the three repo/mirror pairs (`diff .claude/skills/parallel-plan/SKILL.md extensions/.../parallel-plan/SKILL.md`, and the same for `parallel-add/SKILL.md` and `parallel-planner.md`) → all three exit 0 (byte-identical).

## Regression Suite (BlastRadius conflict truthiness)

Verdict: **PASS**

Re-ran `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1"` → Tests Passed: 29, Failed: 0. Matches the branch's own evidence artifact (`evidence/qa-gates/pester-blast-radius-conflict.2026-08-30T09-31.md`).

## Overall Policy Verdict

**PASS.** No policy violation identified. No remediation required.
