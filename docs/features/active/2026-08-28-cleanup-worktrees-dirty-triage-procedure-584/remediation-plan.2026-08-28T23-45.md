# Remediation Plan — 2026-08-28T23-45 (cycle 1)

Canonical issue number for this feature is 584. Remediates the single Blocking finding in
`docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/remediation-inputs.2026-08-28T23-45.md`:
PR #585 CI required check `quality-checks7 / Code Quality & Tests (3.11)` fails because
`.claude/skills/cleanup-merged-worktrees/SKILL.md` (correctly updated on this branch by cherry-pick
commit `c7e0a28f`) was never mirrored into the bundled payload copy at
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.

## Mechanism Decision

- The `mcp__drm-copilot__push_down_claude_customizations` tool (engine:
  `scripts/dev_tools/push_down_claude_customizations.py`) publishes the already-bundled `.claude`
  content outward into a destination consumer workspace (`destination_root` is the target; the
  effective source defaults to the repository root, from which the tool reads the existing bundle
  at `extensions/drm-copilot/resources/claude-customizations`). It does not write into
  `extensions/drm-copilot/resources/claude-customizations/` itself and is therefore not the
  mechanism for the repo-to-bundle mirror this remediation requires. This is the same conclusion
  reached and recorded for the identical scenario in
  `docs/features/completed/2026-07-22-cleanup-merged-worktrees-396/remediation-plan.2026-07-22T13-42.md`.
  The correct minimal fix is a direct byte-identical file copy, which is what Phase 1 performs.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` is already registered in
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (added by the
  prior #396 remediation cycle), so no pack-manifest edit is required in this cycle — only the
  bundled `SKILL.md` byte content is stale.

## Scope Constraint

- Only one file changes: the bundled `SKILL.md` copy at
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Do not modify `.claude/skills/cleanup-merged-worktrees/SKILL.md` (already correct on this branch),
  `pack-manifests/core.json`, `.claude/settings.json`, any other bundled anchor file, the contract
  tests, or any unrelated file.
- No Python production or test source changes are made in this cycle, so no Python coverage delta
  attaches to it. The targeted contract test node is the verification gate.

### Phase 0 — Baseline capture

- [x] [P0-T1] Read policy files in the required order (`CLAUDE.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`) and write
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/phase0-instructions-read.2026-08-28T23-45.md`
  containing `Timestamp:`, `Policy Order:`, and the explicit list of files read, plus a note that no
  language-specific rule file applies because the sole in-scope file for this cycle is a Markdown
  skill mirror copy, not Python/PowerShell/TypeScript/C# source or test code. Acceptance: artifact
  exists with all three required fields populated.
- [ ] [P0-T2] [expect-fail] Capture the fail-before baseline: run
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v`
  from the repo root and write
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/regression-testing/bundle-contract.fail-before.2026-08-28T23-45.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact
  records a non-zero `EXIT_CODE` with the `AssertionError` naming
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` as the differing file, confirming the current
  local CI failure state.
- [x] [P0-T3] Confirm the exact diff between the repo-side and bundled copies: run
  `git diff --no-index -- .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  from the repo root and write
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/skill-md-bundle-diff.2026-08-28T23-45.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: artifact
  records `EXIT_CODE: 1` (files differ under `--no-index`) with an `Output Summary:` naming the
  "Dirty Worktree Triage Procedure" section, the new `allowed-tools` entries, and the other
  sections identified in `remediation-inputs.2026-08-28T23-45.md` as present only in the repo-side
  copy.
- [x] [P0-T4] Confirm no other bundled resource is affected by this branch's change: run
  `git diff --name-only origin/main...HEAD -- .claude` followed by `git status --porcelain` from the
  repo root and write
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/branch-claude-scope-diff.2026-08-28T23-45.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: the
  `git diff --name-only origin/main...HEAD -- .claude` output contains exactly one line,
  `.claude/skills/cleanup-merged-worktrees/SKILL.md`, confirming this branch introduced no other
  `.claude/**` change that could also be missing from the bundle; the `git status --porcelain`
  output is recorded verbatim in the same artifact.

### Phase 1 — Restore bundle parity for the one affected file

- [x] [P1-T1] Copy `.claude/skills/cleanup-merged-worktrees/SKILL.md` to
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`,
  byte-identical (same content and encoding, no re-wrapping or line-ending changes). Acceptance:
  `git diff --no-index -- .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  exits `0` with empty output, confirming byte-for-byte identity between the two files.

### Phase 2 — Final QC

- [ ] [P2-T1] Re-run
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v`
  from the repo root and write
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/regression-testing/bundle-contract.pass-after.2026-08-28T23-45.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance:
  `EXIT_CODE: 0` with `Output Summary:` recording `1 passed`. `SKIPPED` is not a valid outcome for
  this task.
- [x] [P2-T2] Confirm `git status --porcelain` from the repo root shows only the expected
  bundled-resource file changed and write
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/qa-gates/final-qc-full-repo-status.2026-08-28T23-45.md`
  containing `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Acceptance: (a) exactly
  one line begins with ` M` and it is
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`;
  (b) every remaining line begins with `??` and matches one of the pre-existing untracked entries
  already recorded in
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/evidence/baseline/baseline-git-state.2026-08-28T18-43.md`
  (`claude-session.stderr.log`, `claude-session.stdout.log`,
  `docs/features/active/2026-08-28-cleanup-worktrees-dirty-triage-procedure-584/`,
  `docs/features/potential/promoted/2026-08-28-cleanup-worktrees-dirty-triage-procedure.md`,
  `orchestration-kickoff.md`); no other modified, added, deleted, or renamed tracked-file line is
  present.

## Toolchain Applicability Note

No Python, PowerShell, TypeScript, or C# production or test source file is changed by this cycle;
the sole changed file is a Markdown skill-definition mirror copy. The full seven-stage toolchain
loop (format/lint/type-check/architecture/unit/contract/integration) in
`.claude/rules/general-code-change.md` therefore does not apply beyond the targeted contract test
already run in P0-T2 and P2-T1, which is the applicable contract/schema compatibility check for a
bundled-resource mirror file. This mirrors the toolchain-applicability determination recorded for
the identical scenario in
`docs/features/completed/2026-07-22-cleanup-merged-worktrees-396/remediation-plan.2026-07-22T13-42.md`.
