Timestamp: 2026-08-25T13:14:00-04:00
Command: Read the required policy, hook, Issue #549 requirements, and research documents in plan order.
EXIT_CODE: 0
Output Summary: Required policy and scope documents were read. This is a Markdown-only skill-document repair; the approved validation loop is strict frontmatter validation, installed Codex validation, byte parity, retired-path/body-scope validation, targeted pytest, and `git diff --check`.

Policy Order:

1. `AGENTS.md`
2. `.agents/skills/general-code-change/SKILL.md`
3. `.agents/skills/general-unit-test/SKILL.md`
4. `.agents/skills/policy-compliance-order/SKILL.md`
5. `.agents/skills/atomic-plan-contract/SKILL.md`
6. `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
7. `.codex/hooks/enforce-evidence-locations.ps1`
8. `docs/features/active/2026-08-25-repair-invalid-codex-skill-frontmatter-549/issue.md`
9. `docs/features/active/2026-08-25-repair-invalid-codex-skill-frontmatter-549/spec.md`
10. `docs/features/active/2026-08-25-repair-invalid-codex-skill-frontmatter-549/research/2026-08-25T13-33-repair-invalid-codex-skill-frontmatter-research.md`

Scope Decision: Modify only the 27 named canonical skill documents and their same-named bundled mirrors. Permitted changes are the 23 frontmatter repairs, the four research-location body corrections, and the `translate-claude-to-codex` existing-research-reference correction. Preserve every other skill body and all files outside the approved feature evidence and plan.
