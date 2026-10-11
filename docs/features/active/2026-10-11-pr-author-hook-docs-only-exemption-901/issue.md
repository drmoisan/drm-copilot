# 2026-10-11-pr-author-hook-docs-only-exemption

- Work Mode: minor-audit
- Issue: #901
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/901
- Related: #903 (source of the #850 review notes; #903 is closed by a different item)
- Lifecycle records (cited by ref, not copied): `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-pr-author-hook-blocks-docs-only-prs-without-checkpoint.md` (#901); `origin/docs/followups-2026-10-11:docs/features/potential/promoted/2026-10-11-round-2-review-nits-and-evidence-timestamps.md` (#903)

## Problem / Why

The pr-author PreToolUse hook (`.claude/hooks/enforce-pr-author-skill.ps1` with `.claude/hooks/enforce-pr-author-skill-helpers.ps1`) requires an orchestrator-state checkpoint that passes `--require-pr-creation-ready` before `gh pr create --body-file` is allowed. A documentation-only branch created outside an orchestration has no checkpoint, so an agent cannot open its PR through pr-author (issue #901). Run records and follow-up documentation remain on unmerged branches until an operator opens the PR by hand.

The #850 code review (`docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/code-review.2026-10-09T01-12.md`, rows L19-L23 and L25) recorded six non-blocking notes on the same hook family that were collected in #903 and remain open.

## Implementation Intent

Operator decision (A): the hook exempts a branch whose diff from the base touches only paths under `docs/**`. For such a branch, `gh pr create --body-file` is allowed without an orchestrator-state checkpoint. The exemption fails closed on any changed path outside `docs/**`, on an empty diff, and whenever the diff or the base cannot be computed. The exemption replaces only the orchestrator-state checkpoint preflight; it does not relax the body-file and receipt checks unless research shows those checks also depend on the checkpoint, in which case the plan states the decision explicitly.

The same rule applies to the bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. No Codex counterpart of this hook exists under `.codex/hooks/` on main at 2ef8d361; if research finds one, the same rule applies to it.

The #850 notes are each fixed, or, where a note should not change, the reason is recorded in the plan and in an evidence artifact.

## Acceptance Criteria

- [ ] AC-1: When every path in the branch diff from the resolved base is under `docs/`, the pr-author hook allows `gh pr create --body-file ...` with no orchestrator-state checkpoint present, and a Pester test asserts the allow decision.
- [ ] AC-2: The exemption fails closed: the hook denies (with the existing checkpoint-preflight denial or a new documented denial code) when any changed path is outside `docs/` (including `.claude/`, `.github/`, root files, and a path such as `docsx/` or `doc/` that only shares a prefix), when the diff is empty, when the base cannot be resolved, and when the diff command fails. Each of these branches has its own Pester test.
- [ ] AC-3: Branches that carry a valid orchestrator-state checkpoint behave as before; the existing pr-author hook Pester suites pass unchanged or with documented, behavior-preserving edits.
- [ ] AC-4: The bundled mirror copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` are byte-identical to the edited `.claude/hooks/` files, verified by the repository's existing parity test or a recorded comparison.
- [ ] AC-5: #850 note L19: a body PR number above Int32.MaxValue no longer throws or exits 1 in `enforce-pr-author-skill.artifact-root.ps1`; it produces a deterministic deny decision, asserted by a Pester test.
- [ ] AC-6: #850 note L20: the unparseable `pr_gate.pr_number` branch is covered by a Pester test.
- [ ] AC-7: #850 notes L21 (`PSUseSingularNouns` suppression), L22 (duplicated positive-JSON-integer rule), and L23 (`[long]` vs `[int]` TryParse) are each either fixed or recorded with a no-change rationale in an evidence artifact under this feature folder.
- [ ] AC-8: #850 note L25: the stale `.NOTES` text "No external module dependencies" in `enforce-pr-author-skill.ps1` is corrected to match the file's actual dependencies.
- [ ] AC-9: No edited PowerShell file exceeds 500 lines; PoshQC format and analyze report no new findings on the edited files; the Pester suites for the pr-author hook family pass; line coverage of the edited hook files is at least 85% as reported by CI.
- [ ] AC-10: The hook's header documentation (`.SYNOPSIS`/`.DESCRIPTION`/`.NOTES`) describes the docs-only exemption and its fail-closed conditions.

## Dependencies / Risks

- Edits stay within the pr-author hook family (`.claude/hooks/enforce-pr-author-skill*.ps1`, their bundled mirrors, and their tests). Other hook files may be owned by a concurrent epic.
- Enforcement hooks must not use Python; PowerShell only.
- The exemption is a weakening of an enforcement gate; prefix matching must be exact (`docs/` with the trailing slash) and every failure path must deny.
- PowerShell verification uses the PoshQC MCP tools and CI evidence only; no `sh`, `bash`, or `pwsh` wrapper scripts run Pester or PSScriptAnalyzer.

## Verification Steps

- PoshQC MCP format, analyze, and test against the edited files and the pr-author hook test suites.
- CI per-file coverage for the edited hook files.

## Evidence Checklist
- [ ] baseline
- [ ] targeted verification
- [ ] end-state
