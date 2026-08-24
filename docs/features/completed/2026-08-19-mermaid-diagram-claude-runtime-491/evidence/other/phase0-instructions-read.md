# Phase 0 — Instructions Read (issue #491)

## [P0-T1] Policy files read

Timestamp: 2026-08-19T10-17

Policy Order: the exact order mandated by `CLAUDE.md` (`## Policy Compliance Reading Order`) and
`.claude/skills/policy-compliance-order/SKILL.md`, restricted to the PowerShell language scope of
this feature.

Files read, in order:

1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules
4. `.github/instructions/powershell-code-change.instructions.md` — PowerShell code change rules
5. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell unit test rules
6. `.claude/rules/powershell.md` — PowerShell toolchain, design seams, mocking, change budget
7. `.claude/rules/general-unit-test.md` — cross-language unit test policy, coverage thresholds

Constraints extracted that bind this feature's execution:

- 500-line limit applies to production PowerShell, test PowerShell, and reusable scripts; Markdown
  documentation files are exempt.
- PowerShell toolchain order is format -> analyze -> test via the MCP functions; type checking is
  not applicable. Restart from format on any failure or file change.
- Per-batch change budget: at most 3 production and 3 test PowerShell files.
- Temporary files in tests are prohibited with no approved exceptions.
- External executables (`git`, `gh`, `actionlint`) must never be mocked directly; mock the wrapper
  seam instead.
- Line coverage >= 85% (uniform across T1-T4). Pester measures no branch coverage, so no
  branch-coverage gate applies to PowerShell.

## [P0-T2] Feature context read

Timestamp: 2026-08-19T10-19

Files read, in order:

1. `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/spec.md` — including
   `## Decisions` D1-D7 and `## Out of Scope` items 1-9
2. `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/user-story.md`
3. `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/issue.md`
4. `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/research/mermaid-validation-technology.2026-08-19T08-39.md`
5. `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/research/claude-runtime-integration-mechanics.2026-08-19T08-39.md`
6. `.github/instructions/mermaid.instructions.md`

Binding decisions recorded from the spec:

- D1: dependency-free structural PowerShell validator under `.claude/lib/mermaid/`, thin hook.
- D2: detection surface includes fenced ```mermaid blocks in Markdown, not only `.mmd`/`.mermaid`.
- D3: opt-out marker `<!-- mermaid-validator: ignore -->` on the immediately preceding line,
  one block of scope, Markdown fences only, never suppresses the managed-diagram guard.
- D4: seven-item fail-open policy.
- D5: distribution (mirror + `core.json`) is part of the deliverable; `references/*.md` is the
  unguarded class.
- D6: rendering is conditional (Artifact, then SendUserFile display: render, then file path plus
  VS Code preview route); the hook never renders.
- D7: out-of-scope items recorded with reasons in the skill and rule text.

## [P0-T3] Work mode and AC source resolution

Timestamp: 2026-08-19T10-19

- `issue.md:10` carries `- Work Mode: full-feature` (verified by grep).
- Per `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-feature` resolves the AC
  sources to BOTH `spec.md` and `user-story.md`.
- `spec.md` AC source: `## Acceptance Criteria` (AC-1 through AC-25), plus
  `## Definition of Done` and `## Seeded Test Conditions (from potential)` checkbox blocks.
- `user-story.md` AC source: `## Acceptance Criteria` (8 story-level checkbox items).
- Check-off protocol: change only `- [ ]` to `- [x]`, one item at a time, only after the work
  satisfying it is implemented and verified. No new AC items are authored.
