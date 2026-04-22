# Feature Audit: github-instructions-not-migrated-to-claude (#151)

**Audit Date:** 2026-04-18T18-50
**Work Mode:** `full-bug` (AC source: `spec.md` only)
**Scope:** Feature-vs-base audit against `origin/development` @ `d742a7f8efef1ec95500edca6b2bd525bb78b819`.
**Head:** `bug/github-instructions-not-migrated-to-claude-151` @ `b749258af75778cfdc24993363e83f7f91aab3aa`

## Scope and Baseline

The spec at `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md` declares 13 acceptance criteria. Because `issue.md` carries `- Work Mode: full-bug`, the authoritative AC source is `spec.md` only; `user-story.md` is not evaluated (it does not exist for this `full-bug` feature).

Baseline: the feature branch diverged from `origin/development` at merge-base `d742a7f8`. The branch includes 128 changed files (production, test, docs, config, agents, skills, hooks). This audit covers the full feature-vs-base range, consistent with the `feature-review-workflow` SKILL Scope Invariant.

This audit supersedes `feature-audit.2026-04-18T14-00.md` (prior, plan-scoped, now rejected as non-conformant with the Scope Invariant).

## Acceptance Criteria Inventory

Source: `spec.md`, section `## Acceptance Criteria`.

| AC | Description (abridged) |
|---|---|
| AC-1 | `.claude/rules/general-code-change.md` exists with `paths: **`, summarizes cross-language design principles and toolchain loop order. |
| AC-2 | `.claude/rules/general-unit-test.md` exists with `paths: **`, states repo-wide >= 80% and new-code >= 90% coverage floors. |
| AC-3 | `.claude/rules/typescript.md` Testing Standards includes coverage thresholds and `npm run test:unit:coverage`. |
| AC-4 | `.claude/rules/python.md` Testing Standards includes repo-wide >= 80% floor. |
| AC-5 | `.claude/rules/csharp.md` Testing Standards includes coverage thresholds. |
| AC-6 | `.claude/rules/powershell.md` Testing Standards includes coverage thresholds. |
| AC-7 | `.claude/rules/tonality.md` exists with `paths: **`; covers humor, hyperbole, and metaphor prohibitions. |
| AC-8 | `.claude/rules/typescript-suppressions.md` exists with `paths: **/*.ts`, lists `eslint-disable-next-line` and `@ts-expect-error` patterns. |
| AC-9 | `.claude/rules/python-suppressions.md` exists with `paths: **/*.py`, lists S603, ARG002, B008, BLE001, S110 suppression patterns. |
| AC-10 | `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: **/*.py`, covers docstring mandates and intent comments. |
| AC-11 | `feature-review-workflow/SKILL.md` Step 5 includes coverage; Step 8 includes coverage regression as a remediation trigger. |
| AC-12 | `.claude/agents/feature-review.md` includes coverage-verification instructions. |
| AC-13 | `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` is byte-identical to `.github/agents/feature-review.agent.md`. |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | **PASS** | `.claude/rules/general-code-change.md` exists; frontmatter `paths: - "**"`; file summarizes design principles (simplicity-first, reusability, extensibility, separation-of-concerns) and the mandatory toolchain loop order (format → lint → type check → test). Verified by `Read` at HEAD. |
| AC-2 | **PASS** | `.claude/rules/general-unit-test.md` exists; frontmatter `paths: - "**"`; file states "Repository-wide line coverage must remain >= 80%" and "Any new module, class, or method must target >= 90% coverage." Verified by `Grep`. |
| AC-3 | **PASS** | `.claude/rules/typescript.md` lines 42-44 contain: `- Repository-wide line coverage must remain >= 80%`, `- Any new module, class, or method must reach >= 90% coverage`, `- Coverage command: \`npm run test:unit:coverage\``. Verified by `Grep`. |
| AC-4 | **PASS** | `.claude/rules/python.md` line 88 contains `- Repository-wide line coverage must remain >= 80%`. Verified by `Grep`. |
| AC-5 | **PASS** | `.claude/rules/csharp.md` lines 39-40 contain `- Repository-wide line coverage must remain >= 80%` and `- Any new module, class, or method must reach >= 90% coverage`. Verified by `Grep`. |
| AC-6 | **PASS** | `.claude/rules/powershell.md` lines 46-47 contain the same thresholds as AC-5. Verified by `Grep`. |
| AC-7 | **PASS** | `.claude/rules/tonality.md` exists with `paths: - "**"`. Sections `## Humor and Joking — Prohibited` (line 23), `## Hyperbole — Prohibited` (line 35), `## Metaphors — Tightly Restricted` (line 45) cover all three required prohibitions. |
| AC-8 | **PASS** | `.claude/rules/typescript-suppressions.md` exists with `paths: - "**/*.ts"`. Line 27: ``**Pattern:** `// eslint-disable-next-line <rule-name> -- <reason>` ``. Line 38: ``**Pattern:** `// @ts-expect-error -- <reason>` ``. |
| AC-9 | **PASS** | `.claude/rules/python-suppressions.md` exists with `paths: - "**/*.py"`. Sections cover S603 (line 25), ARG002 (line 35), B008 (line 43), BLE001 (line 75), S110 (line 111) with required `# noqa: ...` comment formats. |
| AC-10 | **PASS** | `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: - "**/*.py"`. Sections: `## Mandatory Class Docstrings` (line 15), `## Mandatory Function and Method Docstrings` (line 29). Line 13 covers intent comments for iteration and branching. |
| AC-11 | **PASS** | `.claude/skills/feature-review-workflow/SKILL.md` line 95 introduces coverage as step 5 item 5; lines 101-105 define thresholds and per-file/repo-wide rules; line 137 lists "coverage regression below policy threshold"; line 138 lists "coverage artifact absent for any language that has changed files" as remediation triggers. |
| AC-12 | **PASS** | `.claude/agents/feature-review.md` line 83 begins `## Coverage Verification`; lines 85-115 describe the evidence-based verification procedure, including the per-language artifact table and thresholds. |
| AC-13 | **PASS** | `git diff --exit-code .github/agents/feature-review.agent.md extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` → exit 0. Files byte-identical. |

### Verdict Counts

- PASS: 13
- PARTIAL: 0
- FAIL: 0
- UNVERIFIED: 0

All 13 acceptance criteria satisfied at HEAD `b749258`.

## Summary

All 13 acceptance criteria for issue #151 are satisfied by the HEAD of branch `bug/github-instructions-not-migrated-to-claude-151`. Content, YAML frontmatter, skill/agent wiring, and bundled-mirror synchronization are complete and verifiable from file inspection.

However, the acceptance criteria are satisfied in isolation. The full feature-vs-base audit also covers non-AC branch content (TypeScript and PowerShell source changes), and that broader review identifies blocking findings recorded in `policy-audit.2026-04-18T18-50.md` and `code-review.2026-04-18T18-50.md`:

- PowerShell repo-wide coverage at 27.66% (below 80% floor).
- Two new `.claude/hooks/*.ps1` files with no visible Pester test coverage.
- Three production TypeScript files at or above 500 lines (two worsened on this branch).
- TypeScript and PowerShell toolchain-run evidence artifacts are absent or stale for this review window.

Because the SKILL contract treats feature-vs-base scope as a single audit unit and because the `## Acceptance Criteria Check-off` step is the AC-specific outcome, AC status and overall PR readiness are reported separately:

- **AC status:** All 13 PASS.
- **PR readiness:** NO-GO. Remediation required per SKILL Step 8. See `remediation-inputs.2026-04-18T18-50.md`.

## Acceptance Criteria Check-off

All 13 AC items in `spec.md` are already marked `[x]` at HEAD `b749258`. Re-verification in this audit confirmed the check-off is accurate. No additional check-off action is required because the AC source file already reflects delivered status.

**Source of truth:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`, lines 283-295.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`
- Total AC items: 13
- Checked off (delivered): 13
- Remaining (unchecked): 0
- Items remaining: (none)
