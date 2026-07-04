# Feature Audit: require-pr-author-agent-for-prs (#231) — F-1 Re-Verification

**Audit Date:** 2026-06-24
**Feature Folder:** `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231`
**Base Branch:** `main` (commit `258aa903542346cc534c03da39e4b938223c1f2d`)
**Head Branch:** `feature/require-pr-author-agent-for-prs-231` (commit `cbf915c30e23bf8ee10978c13137885bea4280e9`)
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (blocking finding F-1)

---

## Scope and Baseline

- **Base branch:** `main` (commit `258aa903542346cc534c03da39e4b938223c1f2d`)
- **Head branch/commit:** `feature/require-pr-author-agent-for-prs-231` (commit `cbf915c30e23bf8ee10978c13137885bea4280e9`)
- **Merge base:** `258aa903542346cc534c03da39e4b938223c1f2d`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/**`
  - Live re-measurement: PowerShell toolchain (Invoke-Formatter, Invoke-ScriptAnalyzer, Invoke-Pester) this audit
- **Feature folder used:** `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231`
- **Requirements source:** `spec.md` (AC1–AC8) and `user-story.md` (6 items) — both authoritative for `full-feature`.
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`; AC sources are `spec.md` and `user-story.md` per the work-mode contract.
- **Scope note:** This is a re-audit of the full branch diff (`258aa90..cbf915c`), comprising the original implementation commit `0beb721` and the F-1 remediation commit `cbf915c`. The audit covers the complete feature, not the F-1 fix in isolation. The prematurely-checked items flagged in the prior review (AC3, AC5, and the corresponding user-story items) are re-verified against current evidence.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary (AC1–AC8, the resolved/design-complete criteria)
- `user-story.md` — primary (the 6 issue-level criteria)

### From spec.md

1. AC1: A `pr-author.md` agent exists under `.claude/agents/` and runs the `pr-author` skill, with a bundled Claude mirror and updated Codex (`pr-author.toml`) and GitHub Copilot (`pr-author.agent.md`) equivalents; declares the required tools allowlist and embeds the sentinel write/delete protocol.
2. AC2: No PR can be opened via `gh pr create --body-file` unless a valid `artifacts/pr_author_authorization.json` sentinel is present (`issued_by == "pr-author"`, within TTL). Missing, expired, wrong-issuer, or malformed sentinels are blocked (Cases D/E/F and malformed).
3. AC3: PR body edits via `gh pr edit --body-file` are subject to the same Cases D/E/F authorization check; `gh pr edit --body` (inline) remains blocked by Case A.
4. AC4: Enforcement and agent definitions are consistent across Claude, Codex, and GitHub Copilot and their bundled copies, with Claude root/bundled identical and the Codex hook added and wired.
5. AC5: Hook behavior is covered by tests — allowed: valid sentinel; blocked: missing/expired/wrong-issuer/malformed sentinel, inline body (Case A), no body flag (Case B), missing context (Case C). All pre-existing tests continue to pass.
6. AC6: The orchestrate skill documents mandatory delegation to the `pr-author` agent for PR creation, and settings wiring permits `Agent(pr-author)` for the orchestrator.
7. AC7: The new SubagentStop validator hook (`validate-pr-author-output.ps1`) verifies the `pr-author` agent's output reports a PR URL or PR number, and is covered by tests.
8. AC8: All documentation describing the enforcement characterizes it as a policy guardrail, not a cryptographic/security control, and records the forgeability limitation.

### From user-story.md

US1. A `pr-author.md` agent exists under `.claude/agents/` and runs the `pr-author` skill, with bundled Codex and GitHub Copilot equivalents.
US2. No PR can be opened (`gh pr create`) except by the `pr-author` agent; main-thread or other-agent attempts are blocked by a PreToolUse hook.
US3. PR body edits (`gh pr edit` with a body) are likewise restricted to the `pr-author` agent.
US4. The enforcement is consistent across the Claude, Codex, and GitHub Copilot ecosystems and their bundled copies.
US5. Hook behavior is covered by tests (allowed: pr-author agent; blocked: non-agent / inline body / missing context).
US6. The orchestrate skill documents mandatory delegation to the `pr-author` agent for PR creation.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC1 | pr-author agent + bundled/Codex/Copilot equivalents | PASS | `.claude/agents/pr-author.md` (4006 B) + bundled mirror; `.codex/agents/pr-author.toml`; `customizations/.github/agents/pr-author.agent.md` | `ls`, diff | All four equivalents present. |
| AC2 | gh pr create blocked unless valid sentinel | PASS | Cases D/E/F + malformed in `Test-PrAuthorAuthorization`; tests block missing/invalid/expired/malformed | `Invoke-Pester` | 44/44 pass. |
| AC3 | gh pr edit --body-file under same check; inline `gh pr edit --body` blocked by Case A | PASS | Unified Case A guard (hook L215) blocks inline edit body before no-body short-circuit; equals form covered | `Invoke-Pester` (inline-edit-body block cases) | **F-1 resolved.** Prematurely-checked item now substantiated by live tests. |
| AC4 | Cross-ecosystem consistency | PASS | root == bundled byte-identical; Codex == root + 3-line header | `diff` root/bundled/Codex | Parity holds. |
| AC5 | Hook covered by tests incl. inline body, no body, missing context; pre-existing tests pass | PASS | 44 tests incl. two inline-edit-body BLOCK + `--title` ALLOW regression; backward-compat table | `Invoke-Pester` | **F-1 inline-body test gap closed.** |
| AC6 | orchestrate skill documents delegation; settings permit Agent(pr-author) | PASS | `orchestrate/SKILL.md` L70–77; `.claude/settings.json` L33 `Agent(pr-author)`, L165–169 SubagentStop matcher | `grep` | Delegation documented; matcher wired. |
| AC7 | validate-pr-author-output.ps1 verifies PR URL/number; covered by tests | PASS | `validate-pr-author-output.ps1` + 15 tests | `Invoke-Pester` | 15/15 pass; 86.49% coverage. |
| AC8 | Docs characterize enforcement as guardrail, record forgeability | PASS | Hook NOTES blocks; spec.md 2.3; validator NOTES | inspection | No "tamper-proof"/"security boundary" language. |
| US1 | pr-author agent + Codex/Copilot equivalents | PASS | Same as AC1 | `ls` | — |
| US2 | gh pr create restricted to pr-author agent | PASS | Same as AC2 (sentinel gate attributes to pr-author) | `Invoke-Pester` | — |
| US3 | PR body edits restricted to pr-author agent | PASS | Same as AC3; inline edit body now blocked; `--body-file` edit gated by sentinel | `Invoke-Pester` | **F-1 resolved.** Prematurely-checked item now substantiated. |
| US4 | Cross-ecosystem consistency | PASS | Same as AC4 | `diff` | — |
| US5 | Hook covered by tests incl. inline body / missing context | PASS | Same as AC5; inline-edit-body block tests now exist | `Invoke-Pester` | **F-1 test gap closed.** |
| US6 | orchestrate skill documents delegation | PASS | Same as AC6 | `grep` | — |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 14 criteria (8 spec + 6 user-story)
- **PARTIAL:** 0
- **UNVERIFIED:** 0
- **FAIL:** 0

**F-1 resolution confirmation:** The blocking finding F-1 (inline `gh pr edit --body` allowed because the Case A guard was scoped to `gh pr create` only) is resolved. The unified Case A guard now blocks inline `--body` on both `gh pr create` and `gh pr edit` (quoted and equals forms) before the edit no-body allow short-circuit, while `gh pr edit --title`/`--add-label` (no body flag) remain allowed. Cases B/C and sentinel Cases D/E/F are unchanged. The prematurely-checked items (AC3, AC5, US3, US5) are now substantiated by live tests (44/44 in the enforce suite) and the backward-compatibility evidence.

**Top gaps preventing PASS:**
1. None.

**Recommended follow-up verification steps:**
1. None required for merge. Optionally, exercise the hook in PR context once a PR exists to confirm runtime behavior matches the unit-test decisions (the feature design notes the chicken-and-egg constraint; not a merge blocker).

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- All evaluated criteria are PASS.
- All checkbox items in `spec.md` (AC1–AC8) and `user-story.md` (6 items) are already marked `[x]` with an AC reconciliation note added during the F-1 remediation cycle. This re-audit confirms the `[x]` state is now supported by verified evidence; no checkbox state change is required.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: 14 (8 in spec.md + 6 in user-story.md)
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed; all `[x]`, now evidence-supported. |
| `user-story.md` | 6 | 6 | 0 | Checkbox-backed; all `[x]`, now evidence-supported. |

No source-file checkbox change was made in this re-audit because all items were already `[x]` and are now substantiated; changing nothing preserves the existing reconciliation notes.
