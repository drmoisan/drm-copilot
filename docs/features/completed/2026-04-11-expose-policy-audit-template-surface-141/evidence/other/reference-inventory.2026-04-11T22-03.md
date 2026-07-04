Timestamp: 2026-04-11T22:24:53-04:00
Command: rg -n 'docs/features/templates/policy_audit/AGENTS\.md' .agents .codex .github docs extensions/drm-copilot/resources -g '!docs/features/archive/**'
EXIT_CODE: 0
Output Summary:
- Total matches: 20
- redirect:
  - .github/agents/staged-review.agent.md:51
- preserve-source-doc:
  - docs/features/templates/policy_audit/README.md:110
  - docs/features/templates/policy_audit/README.md:138
  - docs/features/templates/policy_audit/README.md:161
- feature-requirement-text:
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/issue.md:25
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/issue.md:29
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/issue.md:35
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/issue.md:43
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md:12
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md:16
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md:27
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md:50
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md:72
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md:15
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md:29
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md:43
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/research.md:11
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/research.md:40
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/research.md:62
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md:4
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md:15
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md:36
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md:69
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/plan.2026-04-11T22-03.md:79
- historical-evidence:
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/phase0-instructions-read.2026-04-11T22-03.md:10
  - docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/phase0-instructions-read.2026-04-11T22-03.md:25
Scope Decision:
- This plan remains TypeScript extension code + bundled Markdown assets + repository Markdown/agent reference updates only.
- No Python or PowerShell wrapper changes are required based on the current extension seams and reference inventory.
