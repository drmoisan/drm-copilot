# Stage G Baseline-Text Check, Stored Patch, and Chain (P2-T9)

Timestamp: 2026-11-08T13-09
Command: sh-launched PowerShell 7 helper under SCRATCH: (1) build the reduction pre-image tree in a temporary index under SCRATCH, where each path's pre-image is the three-way merge of its pre-reduction version (the commit before the crash checkpoint) with the origin/main merge, so the #1124 and #1125 additions belong to the pre-image and not to the reduction, and the new test is absent; (2) stage the paths of the entry's ## Files Changed other than the ledger folder and write patches/0009-less-evidence.patch as git diff --cached --binary --no-renames <pre-image tree> over those paths; (3) recompute the P0-T4 baseline-line lists on the working tree and compare per path; (4) Test-ProcessReductionLedger over Read-ProcessReductionLedger, Test-ProcessReductionEntry over the 0009 entry, Invoke-ProcessReductionChain over Read-ProcessReductionChainInput, and its -StopBefore replay for each stored-patch entry and for 0009's next-lower entry 0008, comparing FinalText of each source path with the P0-T4 whole-file hash
EXIT_CODE: 0
Output Summary:
  Patch: 53 file diffs (52 surfaces and the create hunk of tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1); it carries none of the main-merge additions.
  D13: 52 of 52 paths have baseline lines equal to the P0-T4 record (count and SHA-256); no path differs.
  Ledger: IsValid true, 9 entries, 0 errors. Entry 0009: IsValid true, PatchPath patches/0009-less-evidence.patch, 0 errors.
  Chain: full IsValid true, 0 errors; StopBefore 0001, 0006, 0008, and 0009 each IsValid true, 0 errors.
  Replay before 0008 (0009 reverted against the live tree): 13 source paths equal to their P0-T4 whole-file hash; the 3 sources that the origin/main merge changed (.claude/agents/feature-review.md, .codex/agents/feature-review.toml, .github/skills/feature-review-workflow/SKILL.md) equal the pre-image hash, which is the P0-T4 text plus the merged #1124/#1125 Documentation Surface Check section; the new test is absent.
  No hunk of 0001, 0006, or 0008 needed a rebase: the main-merge additions sit outside every recorded region.

## Helper Output

```text
pre-image tree built over 53 paths
main-merge paths in the reduction set (pre-image includes their #1124/#1125 additions): .claude/agents/feature-review.md, .codex/agents/feature-review.toml, .github/skills/feature-review-workflow/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml, extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md
## D13 baseline-line check
path .claude/skills/atomic-plan-contract/SKILL.md before=33/bacedd858b57 after=33/bacedd858b57 equal
path .agents/skills/atomic-plan-contract/SKILL.md before=32/f8cfaa28e171 after=32/f8cfaa28e171 equal
path .github/skills/atomic-plan-contract/SKILL.md before=28/ab701ee3ff16 after=28/ab701ee3ff16 equal
path extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md before=33/bacedd858b57 after=33/bacedd858b57 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/atomic-plan-contract/SKILL.md before=32/f8cfaa28e171 after=32/f8cfaa28e171 equal
path extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md before=28/ab701ee3ff16 after=28/ab701ee3ff16 equal
path .claude/skills/feature-review-workflow/SKILL.md before=8/40f707d8bbf9 after=8/40f707d8bbf9 equal
path .agents/skills/feature-review-workflow/SKILL.md before=7/06bdd395fbab after=7/06bdd395fbab equal
path .github/skills/feature-review-workflow/SKILL.md before=7/7185f989d772 after=7/7185f989d772 equal
path extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md before=8/40f707d8bbf9 after=8/40f707d8bbf9 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md before=7/06bdd395fbab after=7/06bdd395fbab equal
path extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md before=7/7185f989d772 after=7/7185f989d772 equal
path .claude/skills/orchestrate/SKILL.md before=1/a671ffcceb5d after=1/a671ffcceb5d equal
path .agents/skills/orchestrate/SKILL.md before=1/a671ffcceb5d after=1/a671ffcceb5d equal
path extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md before=1/a671ffcceb5d after=1/a671ffcceb5d equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md before=1/a671ffcceb5d after=1/a671ffcceb5d equal
path .claude/agents/atomic-planner.md before=5/e32d55c59131 after=5/e32d55c59131 equal
path extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-planner.md before=5/e32d55c59131 after=5/e32d55c59131 equal
path .codex/agents/atomic-planner.toml before=5/236889c18706 after=5/236889c18706 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml before=5/236889c18706 after=5/236889c18706 equal
path .claude/agents/atomic-executor.md before=4/e92254d854e4 after=4/e92254d854e4 equal
path extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md before=4/e92254d854e4 after=4/e92254d854e4 equal
path .codex/agents/atomic-executor.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path .claude/agents/feature-review.md before=10/8720a409e53c after=10/8720a409e53c equal
path extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md before=10/8720a409e53c after=10/8720a409e53c equal
path .codex/agents/feature-review.toml before=9/058cd63ceae0 after=9/058cd63ceae0 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml before=9/058cd63ceae0 after=9/058cd63ceae0 equal
path .codex/agents/atomic-planner-c1.toml before=5/236889c18706 after=5/236889c18706 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml before=5/236889c18706 after=5/236889c18706 equal
path .codex/agents/atomic-planner-c2.toml before=5/236889c18706 after=5/236889c18706 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml before=5/236889c18706 after=5/236889c18706 equal
path .codex/agents/atomic-planner-c3.toml before=5/236889c18706 after=5/236889c18706 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml before=5/236889c18706 after=5/236889c18706 equal
path .codex/agents/atomic-planner-c3-elevated.toml before=5/236889c18706 after=5/236889c18706 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml before=5/236889c18706 after=5/236889c18706 equal
path .codex/agents/atomic-planner-c4.toml before=5/236889c18706 after=5/236889c18706 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml before=5/236889c18706 after=5/236889c18706 equal
path .codex/agents/atomic-executor-c1.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path .codex/agents/atomic-executor-c2.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path .codex/agents/atomic-executor-c3.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path .codex/agents/atomic-executor-c3-elevated.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path .codex/agents/atomic-executor-c4.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml before=4/4bc88f55e4d4 after=4/4bc88f55e4d4 equal
path docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md before=19/502c10095c5a after=19/502c10095c5a equal
path extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md before=19/502c10095c5a after=19/502c10095c5a equal
path docs/features/templates/policy_audit/AGENTS.md before=6/fee8d07e407e after=6/fee8d07e407e equal
path extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md before=6/fee8d07e407e after=6/fee8d07e407e equal
## Ledger and chain
ledger IsValid=True entries=9 errors=0
entry 0009 IsValid=True PatchPath=patches/0009-less-evidence.patch errors=0
chain full IsValid=True errors=0
chain StopBefore 0001-parallel-only-test-gates.md IsValid=True errors=0
chain StopBefore 0006-test-suite-baseline-restored.md IsValid=True errors=0
chain StopBefore 0008-g13-guideline-cutoff.md IsValid=True errors=0
replay-hash .claude/skills/atomic-plan-contract/SKILL.md equal (P0-T4 hash)
replay-hash .agents/skills/atomic-plan-contract/SKILL.md equal (P0-T4 hash)
replay-hash .github/skills/atomic-plan-contract/SKILL.md equal (P0-T4 hash)
replay-hash .claude/skills/feature-review-workflow/SKILL.md equal (P0-T4 hash)
replay-hash .agents/skills/feature-review-workflow/SKILL.md equal (P0-T4 hash)
replay-hash .github/skills/feature-review-workflow/SKILL.md equal (pre-image = P0-T4 text plus the main merge addition)
replay-hash .claude/skills/orchestrate/SKILL.md equal (P0-T4 hash)
replay-hash .agents/skills/orchestrate/SKILL.md equal (P0-T4 hash)
replay-hash .claude/agents/atomic-planner.md equal (P0-T4 hash)
replay-hash .codex/agents/atomic-planner.toml equal (P0-T4 hash)
replay-hash .claude/agents/atomic-executor.md equal (P0-T4 hash)
replay-hash .codex/agents/atomic-executor.toml equal (P0-T4 hash)
replay-hash .claude/agents/feature-review.md equal (pre-image = P0-T4 text plus the main merge addition)
replay-hash .codex/agents/feature-review.toml equal (pre-image = P0-T4 text plus the main merge addition)
replay-hash docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md equal (P0-T4 hash)
replay-hash docs/features/templates/policy_audit/AGENTS.md equal (P0-T4 hash)
replay new-test absent=True
chain StopBefore 0009-less-evidence.md IsValid=True errors=0
failures=0
```
