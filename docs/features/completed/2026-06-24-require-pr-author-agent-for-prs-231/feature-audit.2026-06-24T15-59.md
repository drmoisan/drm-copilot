# Feature Audit: require-pr-author-agent-for-prs (Issue #231)

**Audit Date:** 2026-06-24
**Work Mode:** full-feature

## Scope and Baseline

- **Base branch:** `main`
- **Merge-base SHA:** `258aa903542346cc534c03da39e4b938223c1f2d`
- **Branch head SHA:** `0beb721d21c86ed944cc1090bae5085f595ea936`
- **Diff scope:** full branch diff against the merge-base (not narrowed to any plan/task subset).
- **AC sources (full-feature):** `spec.md` Section 6 (AC1-AC8) and `user-story.md` (6 issue-mirrored criteria).
- **Changed in-scope production files:** `.claude/hooks/enforce-pr-author-skill.ps1` (modified), `.claude/hooks/validate-pr-author-output.ps1` (new), `.claude/agents/pr-author.md` (new), `.claude/agents/orchestrator.md`, `.claude/settings.json`, `.claude/skills/orchestrate/SKILL.md`, their bundled Claude mirrors, the Codex hook/agent/config, and the Copilot agent doc; tests under `tests/scripts/claude-hooks/`.

## Acceptance Criteria Inventory

### Source: `spec.md` Section 6
1. AC1 — `pr-author.md` agent under `.claude/agents/` runs the `pr-author` skill with bundled Claude mirror and Codex/Copilot equivalents; declares required tools and embeds the sentinel write/delete protocol.
2. AC2 — `gh pr create --body-file` blocked unless a valid `pr_author_authorization.json` sentinel is present (issuer `pr-author`, within TTL); missing/expired/wrong-issuer/malformed blocked (Cases D/E/F + malformed).
3. AC3 — `gh pr edit --body-file` subject to the same D/E/F check; `gh pr edit --body` (inline) remains blocked by Case A.
4. AC4 — Enforcement/agents consistent across Claude/Codex/Copilot and bundled copies; Claude root/bundled identical; Codex hook added and wired.
5. AC5 — Hook behavior covered by tests (valid sentinel allow; missing/expired/wrong-issuer/malformed, inline body, no body flag, missing context blocked); pre-existing tests still pass.
6. AC6 — Orchestrate skill documents mandatory delegation; settings permits `Agent(pr-author)`.
7. AC7 — SubagentStop validator `validate-pr-author-output.ps1` verifies output reports a PR URL/number; covered by tests.
8. AC8 — All documentation characterizes enforcement as a policy guardrail, not a cryptographic/security control, and records forgeability.

### Source: `user-story.md` (issue-mirrored)
- US1 — `pr-author.md` agent exists and runs the skill, with bundled Codex and Copilot equivalents.
- US2 — No PR can be opened (`gh pr create`) except by the `pr-author` agent; other attempts blocked by a PreToolUse hook.
- US3 — PR body edits (`gh pr edit` with a body) likewise restricted to the `pr-author` agent.
- US4 — Enforcement consistent across Claude/Codex/Copilot ecosystems and bundled copies.
- US5 — Hook behavior covered by tests (allowed: pr-author agent; blocked: non-agent / inline body / missing context).
- US6 — Orchestrate skill documents mandatory delegation to the `pr-author` agent.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | `.claude/agents/pr-author.md` present with `skills: [pr-author]`, `memory: project`, SubagentStop hook wiring, tools allowlist incl. `Write(/artifacts/**)`, `Bash(gh pr create *)`, `Bash(gh pr edit *)`; sentinel write/delete protocol embedded. Bundled mirror byte-identical. Codex `pr-author.toml` and Copilot `pr-author.agent.md` updated with the protocol. |
| AC2 | PASS | `Test-PrAuthorAuthorization` implements missing/malformed/invalid/expired; reviewer rerun: Case D/E/F/malformed tests block, valid in-TTL sentinel allows. `gh pr create --body-file` requires a valid sentinel. |
| AC3 | **PARTIAL (FAIL on the inline-edit clause)** | `gh pr edit --body-file` correctly routes through the D/E/F check (verified). However `gh pr edit --body "inline"` returns **allow**, not block; the Case A inline-body guard is scoped to `isPrCreate` only. Contradicts the AC3 clause "`gh pr edit --body` (inline) remains blocked by Case A." Pre-existing condition; no test. See code-review F-1. |
| AC4 | PASS | Claude root vs bundled `diff` byte-identical for all six paired files; Codex hook identical to root apart from the required `# Converted hook` header; `config.toml` wires the Codex PreToolUse hook; Copilot doc updated. |
| AC5 | PARTIAL | Valid/missing/expired/wrong-issuer/malformed, inline `create` body (Case A), no-body (Case B), missing context (Case C) all covered and pass (56/56). Gap: no test for inline `--body` on `gh pr edit` (the AC3 clause), so the asserted blocked behavior is unverified and, as implemented, incorrect. |
| AC6 | PASS | `orchestrate/SKILL.md` adds a "PR Creation Delegation" section mandating delegation and prohibiting direct `gh pr create`/`gh pr edit --body*`; `settings.json` adds `Agent(pr-author)` to the orchestrator allow list and registers the `pr-author` SubagentStop matcher; `orchestrator.md` adds `Agent(pr-author)` and the delegation section. |
| AC7 | PASS | `validate-pr-author-output.ps1` detects PR URL / `PR #<n>` / `gh pr create|edit` + number; 15 tests cover allow/empty/malformed/no-PR/end-to-end. |
| AC8 | PASS | Guardrail-not-cryptographic disclosure + forgeability present in all five documentation surfaces; every `tamper-proof` occurrence is a negation. |
| US1 | PASS | Same evidence as AC1. |
| US2 | PASS | `gh pr create` requires `--body-file` + context + valid sentinel; main-thread/other-agent attempts blocked (Cases A/B/C/D/E/F). |
| US3 | **PARTIAL (FAIL on inline edit)** | Body edits via `gh pr edit --body-file` are gated by the sentinel; but `gh pr edit --body "inline"` is allowed (F-1), so body edits are not fully restricted. |
| US4 | PASS | Same evidence as AC4. |
| US5 | PARTIAL | Same gap as AC5: no test for inline `--body` on `gh pr edit`. |
| US6 | PASS | Same evidence as AC6. |

## Summary

Six of eight spec ACs (AC1, AC2, AC4, AC6, AC7, AC8) and four of six user-story ACs (US1, US2, US4, US6) are PASS. AC3 and US3 are PARTIAL because the inline-`--body`-on-`gh pr edit` path returns allow despite the documented claim that it is blocked. AC5 and US5 are PARTIAL because no test covers that path. The defect is pre-existing in the baseline hook, but this feature documents and asserts the path is closed, so the criteria as written are not satisfied. One Blocking finding (F-1) is routed to remediation. All other quality gates (toolchain, coverage on the line metric, determinism, cross-ecosystem consistency, evidence-location, guardrail disclosure) pass.

## Acceptance Criteria Check-off

Per `acceptance-criteria-tracking`, only PASS criteria are checked off; PARTIAL/FAIL criteria are left flagged.

- The executor had pre-marked all AC items `[x]` in `spec.md` and `user-story.md` prior to this review.
- AC3 / US3 ("`gh pr edit --body` (inline) remains blocked") and AC5 / US5 (test coverage of that path) are evaluated **PARTIAL** by this audit and are **not** verified as delivered. The reviewer leaves the source files unmodified but records that these checked items do not reflect verified behavior; they must be corrected (implementation + test) before they can be honestly checked. This discrepancy is logged as a feature-audit gap and in remediation inputs.
- AC1, AC2, AC4, AC6, AC7, AC8 (spec) and US1, US2, US4, US6 (user-story): verified PASS; their existing `[x]` state is correct.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/spec.md`, `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/user-story.md`
- Total AC items: 14 (8 spec + 6 user-story)
- Verified PASS: 10 (AC1, AC2, AC4, AC6, AC7, AC8, US1, US2, US4, US6)
- PARTIAL / not verified: 4 (AC3, AC5, US3, US5)
- Items remaining (not verified-delivered): AC3 inline-edit-block clause; AC5 test for inline edit body; US3 body-edit restriction (inline); US5 test for inline edit body.
