# Phase 0 Instructions Read Evidence

Timestamp: 2026-04-18T00:09:55-04:00

Work Mode: full-bug

Policy Order:
1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. No language-specific policy files were applicable because this plan changes Markdown instruction and agent mirror artifacts only.

Requirement Files Read:
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md`
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`

Acceptance Criteria:
- [ ] AC-1: `.claude/rules/general-code-change.md` exists with `paths: **`, summarizes the cross-language design principles and the mandatory toolchain loop order (format → lint → type-check → test).
- [ ] AC-2: `.claude/rules/general-unit-test.md` exists with `paths: **`, and explicitly states: repository-wide line coverage ≥ 80% and any new module/class/method ≥ 90%.
- [ ] AC-3: `.claude/rules/typescript.md` Testing Standards section includes: coverage thresholds (≥80% repo-wide, ≥90% new code) and the coverage command (`npm run test:unit:coverage`).
- [ ] AC-4: `.claude/rules/python.md` Testing Standards section includes the repo-wide ≥80% coverage floor (in addition to the existing ≥90% new-code statement).
- [ ] AC-5: `.claude/rules/csharp.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
- [ ] AC-6: `.claude/rules/powershell.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
- [ ] AC-7: `.claude/rules/tonality.md` exists with `paths: **`, summarizes the professional tone requirements and the prohibitions on humor, hyperbole, and decorative metaphor.
- [ ] AC-8: `.claude/rules/typescript-suppressions.md` exists with `paths: **/*.ts`, lists the pre-authorized `eslint-disable-next-line` and `@ts-expect-error` patterns with their required comment format.
- [ ] AC-9: `.claude/rules/python-suppressions.md` exists with `paths: **/*.py`, lists at minimum the S603, ARG002, B008, BLE001, and S110 suppression patterns with their pre-authorized comment formats.
- [ ] AC-10: `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: **/*.py`, summarizes mandatory docstring requirements for classes and functions, and the rule that loops and branches must have intent comments.
- [ ] AC-11: `.claude/skills/feature-review-workflow/SKILL.md` Step 5 check list includes a coverage verification step; Step 8 lists coverage regression as a remediation trigger.
- [ ] AC-12: `.claude/agents/feature-review.md` includes instructions for how the reviewer handles coverage — either by verifying existing coverage artifacts or (if the tool policy is expanded) by running the coverage command directly.
- [ ] AC-13: `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` is byte-identical to `.github/agents/feature-review.agent.md`.

## Baseline: bundled-mirror

- File: `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md`
- Line count: 49
- Expected line count noted by plan: 41
- String check: `Coverage Verification` is absent.

## Baseline: self-explanatory-commenting

- File: `.claude/rules/self-explanatory-code-commenting.md`
- Plan expectation: numbered-notes prohibition is absent.
- Observed state: numbered-notes prohibition is present.
- Evidence: lines containing `Note Numbering — Prohibited`, `NOTE 1:`, `NOTE 2:`, and the checklist item for no numbered notes were found.
