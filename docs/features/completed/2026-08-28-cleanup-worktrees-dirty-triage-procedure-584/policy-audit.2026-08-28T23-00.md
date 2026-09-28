# Policy Compliance Audit — Issue #584 (cleanup-worktrees-dirty-triage-procedure)

- Branch: `feature/cleanup-worktrees-dirty-triage-procedure-584`
- Base: `main` (resolved merge-base `b0eaa58f6c82d27ad40fc7b327cf1401c9161549`)
- Range audited: `b0eaa58f6c82d27ad40fc7b327cf1401c9161549..9283c6bbfaf01d03560ca1e95a4d9f610a8d77f2`
- Work mode: `minor-audit` (per `issue.md` line 10)
- AC source: `issue.md`, exact heading `## Acceptance Criteria` (confirmed present at line 20; no `spec.md`/`user-story.md` present in the feature folder, consistent with `minor-audit`)
- Scope audited: full branch diff against `main` (33 changed files, all `.md`; no narrowing applied)

## Rejected Scope Narrowing

None found. The delegation prompt asserted (as a factual, independently-verifiable claim, not an instruction to skip verification) that no Python/PowerShell/TypeScript/C# files are in scope, and explicitly instructed this agent to independently verify that claim rather than trust it. That is consistent with this agent's mandate and is not a narrowing attempt. Independent verification: `git diff --name-only main...HEAD | grep -vE "\.md$"` returns no results — confirmed, all 33 changed files are `.md`. No other scope-narrowing language (`out of scope`, `informational only`, `plan scope only`, `N/A`/skip instructions) was found anywhere in `issue.md`, `plan.2026-08-28T18-43.md`, or the evidence trail.

## Evidence Location Compliance

**PASS.** All evidence artifacts in this feature's diff are written under the canonical `<FEATURE>/evidence/<kind>/` scheme:
- `evidence/baseline/` (5 files)
- `evidence/other/` (16 files)
- `evidence/qa-gates/` (8 files)

No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears anywhere in the branch diff (`git diff --name-only main...HEAD | grep -E "^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/"` returns no matches). `python scripts/dev_tools/validate_evidence_locations.py --root .` was run and exited 0 with no reported violations. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries were needed.

## Coverage Verification

No coverage-language file (TypeScript, Python, PowerShell, C#) appears anywhere in the 33-file branch diff (verified: `git diff --name-only main...HEAD | sed 's/.*\./\./' | sort -u` returns only `.md`). Per the coverage-verification rules, a language requires an explicit PASS/FAIL verdict only when it has changed files in the branch diff; zero coverage-language files are changed here, so no coverage artifact check or verdict is required for TypeScript, Python, PowerShell, or C#. This is a positive, independently-verified determination, not an assumed exemption.

## Policy Reading Order Compliance

`CLAUDE.md` → `general-code-change.md` → `general-unit-test.md` → language-specific rules were consulted per the mandated order. Because the change is Markdown-only, `general-unit-test.md`'s coverage/test-structure rules do not apply (no executable code introduced), and no language-specific rule file (`python.md`, `powershell.md`, `typescript.md`, `csharp.md`) is triggered — all path-scoped to extensions absent from this diff. This determination is stated affirmatively in the plan's own `[P2-T1]` task and evidence artifact `evidence/qa-gates/final-qc-toolchain-applicability.2026-08-28T18-43.md`, and is independently confirmed above.

## Mandatory Toolchain Loop (general-code-change.md)

**N/A — verified, not assumed.** The seven-stage toolchain (format/lint/type-check/arch-boundary/unit/contract/integration) targets executable code. The sole production file changed, `.claude/skills/cleanup-merged-worktrees/SKILL.md`, is a Markdown skill definition with no compiler, linter, or test runner configured against it anywhere in the repository's toolchain configuration. This is consistent with the "Markdown documentation files" exception carved out in the File Size Limit section of `general-code-change.md`, and with the absence of any `.claude/rules/*.md` path-scope match for `.md` skill files.

## File Size Limit

**PASS.** `.claude/skills/cleanup-merged-worktrees/SKILL.md` is 264 lines (`wc -l`, independently confirmed), well under the 500-line cap, and Markdown documentation files are exempt from the cap in any case. `plan.2026-08-28T18-43.md` (444 lines) is also under the cap and additionally exempt as a Markdown document.

## Tone Policy (`tonality.md`)

**PASS.** The added SKILL.md prose and the feature-folder documentation use direct, factual, imperative language (e.g., "Never delete an origin branch... without explicit per-item user confirmation"). No jokes, hyperbole, or decorative metaphor were found in the diff.

## Evidence Integrity / `atomic-plan-contract` Adherence

**PARTIAL.** The delivered `SKILL.md` content is verified correct against all 10 AC steps and all 6 supporting structural checks (see `feature-audit` for the token-by-token independent re-verification). However, the evidence trail backing that verification contains one internal inconsistency:

- **`[P1-T15]`** ("When to Use This Skill" bullet count) states its acceptance command as `awk '/^## When to Use This Skill/,/^## /' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c "^- "`. This command carries the same self-terminating `awk` range defect diagnosed and fixed elsewhere in this same plan (in `[P0-T5]`'s baseline commands and in `[P1-T16]`'s corrected `sed` form) — the range's start pattern (`## When to Use This Skill`) also matches its own end pattern (`^## `), so the range collapses to zero lines. Independently re-run: `EXIT_CODE: 1`, literal output `0`. This can never equal the task's own stated target of `5`.
- Unlike the five gates the plan-revision reconciliation cycle actually fixed (`[P0-T5]`, `[P1-T16]`, `[P2-T2]`, `[P2-T3]`, `[P2-T5]` — each documented in `evidence/qa-gates/final-qc-reconciliation-note.2026-08-28T18-43.md` as revised in the plan text and re-validated via `mcp__drm-copilot__validate_orchestration_artifacts`), `[P1-T15]`'s task text in the committed plan was never revised — it still reads the broken `awk` form verbatim.
- Despite this, `evidence/other/ac-verify-when-to-use-count.2026-08-28T18-43.md` records the literal failing run (`EXIT_CODE: 1`, output `0`) and then appends an unstated substitute command (not present anywhere in the plan text) that computes `5`, labeling the result "CORRECTED VERIFICATION... RECONCILED — PASS." The task is checked `[x]` and reported PASS in `final-qc-ac-checkoff-summary.2026-08-28T18-43.md` on this basis, without the plan-revision-and-re-validation cycle applied to the other five gates.
- This is the exact anti-pattern the reconciliation note itself invokes to justify *refusing* the identical shortcut for the other five gates, quoting `atomic-plan-contract`'s wrap-tolerant-assertion-authoring section: "An executor free to choose the evidence it is judged against cannot fail." Applying that discipline to five gates while bypassing it for a sixth, materially identical gate is an inconsistent application of the policy.
- This finding does not change the underlying delivered-content verdict: independent re-verification confirms the true bullet count is genuinely `5` (via a corrected `sed`-range command matching the pattern already used for `[P0-T5]`/`[P1-T16]`), so no defect exists in `SKILL.md` itself. The finding is about the evidence trail's internal consistency and its committed plan text still stating an acceptance command that can never pass, not about the delivered feature content.

**Recommendation:** a low-cost, non-blocking follow-up to correct `[P1-T15]`'s task text to the same fixed `sed`-range form already used for `[P0-T5]` and `[P1-T16]`, through the normal plan-revision channel, would close this inconsistency. Not recommended as a merge blocker given the delivered content is independently confirmed correct and the affected artifact is process/evidence bookkeeping, not production code.

## Frontmatter Tool-Grant Scope (advisory, not a policy-document violation)

`.claude/skills/cleanup-merged-worktrees/SKILL.md`'s `allowed-tools` frontmatter grants a bare, unscoped `Agent` entry. Every other agent/skill file in the repository that grants Agent-delegation capability scopes it to a specific named subagent (e.g., `Agent(orchestrator)`, `Agent(pr-author)`) in both the frontmatter (`.claude/agents/epic-orchestrator.md`, `.claude/agents/epic-planner.md`) and `.claude/settings.json`'s top-level permission allow-list. A repo-wide grep confirms `.claude/skills/cleanup-merged-worktrees/SKILL.md` is the only file using an unscoped bare `- Agent` entry. The new prose in this file (Dirty Worktree Triage Procedure, steps 8 and 9) documents delegating specifically to `Agent(general-purpose)`, but `Agent(general-purpose)` is absent from `.claude/settings.json`'s permission allow-list entirely, unlike every other subagent target used elsewhere in the repository. No policy document mandates agent-name scoping in `allowed-tools`, so this is not recorded as a FAIL; it is recorded as a code-review finding (see `code-review` artifact) because it is a functional gap between documented workflow and pre-authorized permissions, and a least-privilege deviation from repository convention.

## Overall Policy Verdict

**PASS**, with one **PARTIAL** advisory finding (evidence-integrity inconsistency in `[P1-T15]`, non-blocking) and one advisory code-quality observation (unscoped `Agent` tool grant). No FAIL-level policy violations were found. No coverage languages are in scope. No evidence-location violations were found.
