# Feature Audit: Claude Code architecture v2 (#136)

---

**Audit Date:** 2026-04-13
**Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
**Base Branch:** `origin/development`
**Head Branch:** `feature/claude-code-architecture-136`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/development` (`14708b3b0c75ebf36b314f7c1780db1625604ecb`)
- **Head branch/commit:** `feature/claude-code-architecture-136` (`93eea9b6effb35f0842aed0f3a221ef7133ef23f`)
- **Merge base:** `226a39309f3223bd48f3d52a2bc4feca324d34b4`
- **Top merge-base candidates captured during review:**
  - `origin/feature/claude-code-architecture-136` @ `93eea9b6effb35f0842aed0f3a221ef7133ef23f`
  - `origin/feature/bundle-link-parent-child-into-extension-144` @ `226a39309f3223bd48f3d52a2bc4feca324d34b4`
  - `origin/main` @ `ad4157eb5581c1ed01ffbb6f442fd1c74c662ee4`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/**`
  - Additional evidence: current review command output for ESLint, TSC, Jest, JSON validation, and Pester/JUnit
- **Feature folder used:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
- **Requirements source:** `spec.md` Definition of Done + `user-story.md` Acceptance Criteria
- **Work mode resolution note:** Work mode resolves from `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md` with marker `- Work Mode: full-feature`.
- **Scope note:** PR context was refreshed during this review because the saved branch-state artifacts were stale relative to the current head and working tree.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` — primary Definition of Done source
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` — primary acceptance-criteria source

### From `spec.md` — Definition of Done

1. The repository contains a working Claude-native architecture spanning `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/`, with each layer implemented for its intended feature role rather than documented only.
2. The main-thread orchestration flow is implemented so the repository can run end-to-end feature workflows in Claude Code without relying on a forked `orchestrator` worker to perform nested subagent delegation.
3. The repository includes the canonical user-facing workflow skills required by this feature (`orchestrate`, `commit-message`, `pr-author`, `research-issue`, and any required review/status skills), and each one routes to the expected Claude-native runtime surface.
4. The repository includes the bounded repository-canonical worker agents required by this feature (planner, executor, research, review, feature-doc, and language-engineer workers), with project-scoped routing limited to those workers rather than to generic personal personas.
5. The `.claude/settings.json` permissions and `.claude/hooks/*` enforcement layer are implemented and demonstrably block at least the documented disallowed tool/path/command cases while allowing the intended workflow operations.
6. The checkpoint-based resumability flow works with `artifacts/orchestration/orchestrator-state.json`, and an interrupted orchestration run resumes from recorded state instead of restarting from scratch.
7. The sync strategy is implemented and documented so a maintainer can determine how `.claude/` runtime files stay aligned with canonical `.github/` sources and can update them without guessing ownership or mirror rules.
8. The Copilot-to-Claude equivalence documentation is complete, including file-by-file migration maps for canonical `.github/skills`, `.github/agents`, and direct-use `.github/prompts`, plus explicit documentation of non-equivalences and fallback behavior.

### From `user-story.md` — Acceptance Criteria

9. The architecture documentation states explicitly that the provided `20260412-claude-code-github-skills-agents-migration-research.md` research is sufficient to define the migration scope and file-by-file Claude mapping without additional discovery work.
10. The Claude architecture uses a main-thread orchestrator model and does not require a forked `orchestrator` subagent to spawn downstream subagents.
11. A developer can invoke `/orchestrate` by name in a Claude Code session and trigger the full orchestration workflow without manual agent configuration steps beyond opening the repository in Claude Code.
12. A developer can invoke `/commit-message` and receive a conventional commit message formatted according to the repository's canonical conventions.
13. A developer can invoke `/pr-author` and receive a complete, GitHub-ready PR body derived from the pr_context artifacts.
14. A developer can invoke `/research-issue` and receive structured research output written to the correct artifact path under `artifacts/research/`.
15. The migration documentation includes a file-by-file mapping for the canonical `.github/skills/*/SKILL.md` files to their `.claude/skills/*/SKILL.md` targets, including any files that remain documentation-only rather than runtime assets.
16. The migration documentation includes a file-by-file disposition for all `.github/agents/*.agent.md` files, identifying which become project subagents, which become wrapper skills, which remain main-thread-only orchestration logic, and which are personal or library personas that stay out of project scope.
17. The migration documentation identifies the direct-use `.github/prompts/*.prompt.md` entry points that must become `.claude/skills/*/SKILL.md` files rather than `.claude/commands/*` files.
18. The migration documentation distinguishes between repository-enforceable controls (`CLAUDE.md`, `.claude/rules/`, `.claude/settings.json`, `.claude/hooks/*`) and controls that require managed settings outside the repository for non-overrideable enforcement.
19. Subagent tool restrictions correctly block operations outside their declared allowlist (verified by attempting a disallowed operation from within the relevant subagent context).
20. The main-thread orchestrator reads `artifacts/orchestration/orchestrator-state.json` at session start and resumes from the recorded `next_step` rather than restarting from scratch when a valid checkpoint exists.
21. The `PreToolUse` hook blocks at least one representative dangerous-command pattern (for example `rm -rf` or `git push --force`) via the hook script in `.claude/hooks/`.
22. The `SubagentStop` hook blocks premature worker termination when the required completion artifact (plan path, research path, or review artifact path) is absent from the output.
23. A developer can follow the sync strategy documentation in `docs/engineering/claude-code-architecture.md` to determine whether `.claude/` content is current with `.github/` sources and apply updates.
24. The architecture documentation explicitly identifies each non-equivalence between Copilot and Claude and does not claim runtime enforcement for behaviors that are enforced only by prompt conventions.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Claude-native architecture spans `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/` | PASS | `p5-t1.runtime-structure-validation.2026-04-12T15-57.md`; direct file inspection of `CLAUDE.md`, `.claude/settings.json`, `.claude/hooks/validate-bash.ps1` | `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development`; file inspection | The required layers exist in the v2 implementation. |
| 2 | Main-thread orchestration flow is implemented without a forked `orchestrator` worker | PASS | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t1.orchestrator-prd-feature.2026-04-13T09-09.md`; `.../p1-t2.orchestrator-review-status-workers.2026-04-13T09-09.md`; `.../p1-t3.orchestrator-language-engineers.2026-04-13T09-09.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t7.poshqc-test.2026-04-13T09-09.md` | file inspection; targeted Pester run | Main-thread routing is documented and the orchestrator now exposes the documented worker set in the tested runtime surface. |
| 3 | Canonical user-facing workflow skills are present and route to the expected Claude-native runtime surface | PASS | Wrapper skills exist; runtime-structure tests passed; current remediation runtime tests passed | `npm run test:unit:coverage`; targeted Pester run | The static runtime routing surface is complete and tested. Live command invocation remains separately unverified in criteria 11-14. |
| 4 | Repository-canonical worker agents exist with project-scoped routing limited to those workers | PASS | Agent inventory files exist; `.claude/agents/orchestrator.md` allowlist now includes the documented review, feature-doc, status, and language-engineer workers | file inspection; targeted Pester run | The worker files exist and the orchestrator routing contract now covers the committed worker inventory. |
| 5 | Settings and hooks block disallowed cases while allowing intended operations | PASS | `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p2-t7.settings-json-green.2026-04-13T09-09.md`; `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.poshqc-analyze.2026-04-13T09-09.md`; `.../p5-t7.poshqc-test.2026-04-13T09-09.md`; `.../p5-t9.settings-json-validation.2026-04-13T09-09.md` | JSON validation; targeted analyzer/test runs | Disallowed cases remain covered, and the intended PowerShell runtime instructions now align with the tested settings/runtime contract. |
| 6 | Checkpoint resumability works from `artifacts/orchestration/orchestrator-state.json` | UNVERIFIED | `p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` | file inspection only | Stored evidence explicitly says no live checkpoint instance or Claude session was available. |
| 7 | Sync strategy is implemented and documented | PASS | `docs/engineering/claude-code-architecture.md`; user-story criterion 23 evidence | file inspection | The document includes source/derived rules and manual sync procedure. |
| 8 | Copilot-to-Claude equivalence documentation is complete | PASS | `p4-t2.architecture-doc-green...`; direct inspection of migration tables | `PoshQC: 4 test (Pester)` | File-by-file maps are present for skills, agents, and prompts. |
| 9 | Research sufficiency statement is explicit | PASS | `docs/engineering/claude-code-architecture.md` opening paragraphs | file inspection | The document states the migration research is sufficient. |
| 10 | Claude architecture uses a main-thread orchestrator model with no forked orchestrator subagent | PASS | `CLAUDE.md`; `.claude/skills/orchestrate/SKILL.md`; `p4-t2.architecture-doc-green...` | file inspection | The no-fork model is explicit in the docs and runtime skill. |
| 11 | `/orchestrate` works in a live Claude session | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | none available in this environment | No live Claude slash-command session was available during review. |
| 12 | `/commit-message` works in a live Claude session | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | none available in this environment | Same environment blocker as above. |
| 13 | `/pr-author` works in a live Claude session | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | none available in this environment | Same environment blocker as above. |
| 14 | `/research-issue` works in a live Claude session | UNVERIFIED | `p5-t4.live-skill-validation.2026-04-12T15-57.md` | none available in this environment | Same environment blocker as above. |
| 15 | Skills migration map is present | PASS | `p4-t2.architecture-doc-green...`; direct doc inspection | `PoshQC: 4 test (Pester)` | The skills migration table is complete. |
| 16 | Agents disposition table is present | PASS | `p4-t2.architecture-doc-green...`; direct doc inspection | `PoshQC: 4 test (Pester)` | The agents disposition table is complete. |
| 17 | Prompts migration table is present | PASS | `p4-t2.architecture-doc-green...`; direct doc inspection | `PoshQC: 4 test (Pester)` | The direct-use prompts table is present. |
| 18 | Repository-enforceable versus managed-settings controls are distinguished | PASS | `docs/engineering/claude-code-architecture.md` sections 5 and 6 | file inspection | The document cleanly separates these control classes. |
| 19 | Subagent tool restrictions block operations outside their allowlist | UNVERIFIED | `p5-t4.live-skill-validation...`; `p5-t2.permissions-and-agent-scope-validation...` | static inspection only | Static permission data exists, but no live disallowed-operation probe was captured. |
| 20 | Main-thread orchestrator reads checkpoint and resumes from `next_step` | UNVERIFIED | `p5-t5.checkpoint-resume-validation...` | static inspection only | No live resume transcript or checkpoint file instance was available. |
| 21 | `PreToolUse` blocks dangerous command patterns | PASS | `p4-t3.validate-bash-green...`; `artifacts/pester/pester-junit.xml`; `validate-bash.Tests.ps1` | `PoshQC: 4 test (Pester)` | The hook behavior is well covered by current Pester results. |
| 22 | `SubagentStop` blocks premature worker termination | UNVERIFIED | `p5-t3.hook-enforcement-validation...` | static inspection only | The configured matcher exists, but no live stop-gate run was captured. |
| 23 | Sync strategy is actionable for maintainers | PASS | `docs/engineering/claude-code-architecture.md` sync procedure | file inspection | The procedure is explicit enough for manual follow-up. |
| 24 | Architecture documentation identifies non-equivalences without overstating enforcement | PASS | `docs/engineering/claude-code-architecture.md` sections 1-2 and 5-6 | file inspection | The document explicitly separates prompt conventions from enforceable runtime behavior. |

---

## Summary

**Overall Feature Readiness:** PARTIAL - LIVE VALIDATION PENDING

**Criteria summary:**
- **PASS:** 16 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 8 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Live Claude-session validation remains unavailable for slash-command behavior, checkpoint resume, and live permission/stop-gate enforcement.
2. The targeted PowerShell final QA run did not produce usable numeric coverage payloads, so changed/new-code PowerShell coverage claims remain unresolved.

**Recommended follow-up verification steps:**

1. Run a live Claude Code validation pass for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, checkpoint resume, and `SubagentStop` behavior, then refresh the v2 evidence artifacts.
2. If PowerShell changed/new-code coverage reporting is required for closure, capture it from a runtime/tooling surface that emits a numeric targeted coverage value.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- Total AC items reviewed from `spec.md`: 8
- Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Total AC items reviewed from `user-story.md`: 16
- Checked off during this review: 0
- Remaining unresolved items: criteria 6, 11, 12, 13, 14, 19, 20, 22

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` | 8 | 7 | 1 | Checkbox-backed; only the checkpoint-resume criterion remains unresolved in `spec.md`. |
| `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` | 16 | 9 | 7 | Checkbox-backed; several live-runtime criteria remain explicitly unverified. |

No source-file checkbox changes were made during this review because unresolved criteria remain in both authoritative files.
