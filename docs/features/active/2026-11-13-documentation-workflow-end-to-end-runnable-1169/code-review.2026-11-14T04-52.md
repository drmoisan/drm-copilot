# Code Review: Documentation Workflow End-to-End Runnable, Part A (Issue #1169), Re-audit After the Second Main Sync

**Review Date:** 2026-11-14
**Branch:** `feature/documentation-workflow-end-to-end-runnable-1169` @ `e94b2c38dd0d270a1043c98b9cd5888605721ce7` (PR #1175)
**Base:** `main`, merge base `063504dc4b2ea08a2c5bd39b57d70ce5963815ed`
**Scope:** full branch diff `063504dc4..e94b2c38d`, 180 files (PowerShell hooks, docs library, Pester suites, skill copies, engineering documentation, pack manifests, feature folder). The review re-reads the whole diff and gives particular attention to the merge `0f0db27cb`, which brought in PR #1174 (issue #1160) and resolved conflicts in the four preimplementation-gate copies.
**Prior review:** `code-review.2026-11-14T03-45.md` (PASS at `0580d77d7`).

## Executive Summary

The merge resolution is correct and complete. No blocking finding exists.

- **Resolution content:** `git show --remerge-diff 0f0db27cb` shows the same resolution in all four copies (Claude gate, Codex gate, and their bundle copies). It keeps the #1160 line `if (($bookkeeping = Get-OrchestrationBookkeepingStagingResult ...).Allowed)`, then the #1169 line `if (($docs = Get-OrchestrationDocsEstateContextResult ...).Allowed)`. The deny reason appends `$cleanup.DenySuffix + $bookkeeping.DenySuffix + $docs.DenySuffix`.
- **Leg order:** both legs only allow. Their order changes only which leg admits a command that both legs admit, and never changes an outcome.
- **Checkpoint interaction:** the bookkeeping leg needs a checkpoint, and the docs leg does not apply when a checkpoint is present. Without a checkpoint, a docs-estate command therefore reaches the docs leg with an empty bookkeeping suffix.
- **Real-process probes:** both shipped gates at head ran from scratch repositories.
  - They admit the docs-only `git add` and the `-F`, `--file=`, and `--message=` commit forms.
  - They deny outside-`docs/` add operands and staged paths with the documented sub-codes.
  - With no profile, they return the base deny text with no suffix.
- **Codex comment condensation:** a two-line comment became one line, so the Codex gate stays at the 500-line Codex hook cap (exactly 500 logical lines). The comment keeps the issue references (#707, #663 D2) and the reason.
- **Mirrors and suites:** all four gate copies are byte-identical in pairs. The full parallel Pester run at head passes 24065 tests with 0 failures. That count includes the #1160 bookkeeping-leg suites (46 and 47 tests) and the docs suites (52 and 55 tests).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1` (four byte-identical copies) | `Get-OrchestrationDocsEstateContextResult`, the `[string]::IsNullOrEmpty($profileText)` check | R1-N1 (non-blocking, carried from the prior review). A zero-byte `docs-profile.json` reads as absent in the A1 leg (no `DOCS_LEG_PROFILE_INVALID` suffix), while the A2 leg reports `DOCS_DELEGATION_PROFILE_INVALID`. Both legs deny; only the diagnostic differs. | No change required. If the diagnostics are aligned later, record in the spec whether a zero-byte file counts as absent or invalid. | Recorded plan decision; the behavior stays fail-closed. | Reviewer real-process probe at head: a zero-byte profile with `git commit -F msg.txt` returns the base deny text with no suffix on both runtimes. |
| Low | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle copy | whole file (500 logical lines) | R2-N1 (non-blocking). After the merge, the Codex gate is exactly at the 500-line Codex hook cap. The merge kept it there by condensing a header comment. The next leg added to this gate cannot fit without relocating code first. | When the next leg is added, move it, or an existing block, into a sibling file, as `-cleanup`, `-docs`, and `-epic-scope` already do. Do not condense comments again. | Recorded so that the next change plans for the relocation instead of more comment edits. | Reviewer logical-line count: 500 (Codex), 487 (Claude). The merge commit body states the cap. |
| Warning | `.claude/lib/docs/DocsLedgerCommands.psm1` and its `claude-customizations` bundle copy | whole file | 707 logical lines (700-line advisory tier). Unchanged since the prior review. | None required. | File-size advisory tier. | Reviewer logical-line count. |
| Warning | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | whole file | 757 logical lines (700-line advisory tier). Unchanged since the prior review. | Consider splitting by decision step when the file is next extended. | File-size advisory tier. | Same count. |
| Info | `0f0db27cb` | merge commit message | R1-N2 from the prior review asked for a merge subject on later main syncs. This merge uses one ("Merge origin/main (#1160 preimplementation-gate changes) into the #1169 branch") and its body states the resolution and the post-merge gate results. | None required. | Closes the prior note. | `git log -1 0f0db27cb`. |

## Merge Verification Detail

| Item | Verification | Result |
|---|---|---|
| Conflict resolution | `git show --remerge-diff 0f0db27cb`: four conflicted files, one hunk each at the final allow and deny lines; the Codex copies also carry the comment condensation | Both legs kept; suffix order cleanup, bookkeeping, docs |
| Branch diff of the main gates | `git diff 063504dc4 HEAD` over both gates: the guarded dot-source line, the docs leg line, the deny-suffix term, and the Codex comment | Matches the spec's "guarded dot-source and call site only", plus the comment |
| Mirror parity | `cmp` of 25 branch files against their bundle copies; SHA-256 of the four copies of each mirrored hook | Byte-identical |
| Behavior at head | Real-process probes of both gates with a discriminating profile, no profile, and a zero-byte profile | Same results as at the prior review's head |
| Unchanged suites | `git diff 063504dc4 HEAD` over both preimplementation cleanup suites and `enforce-model-routing-receipt.Cleanup.Tests.ps1` | Empty |
| Coverage | Reviewer parallel Pester at head, parse of the JaCoCo report | Claude gate 96.47%, Codex gate 100.00%; changed lines 97.41% |

## Positive Observations

- The resolution keeps the leg pattern used by the gates. Each leg returns `Allowed` and `DenySuffix`, and the deny text concatenates the suffixes, so adding the #1160 leg needed no change to the docs leg.
- The executor ran the full parallel Pester and pytest gates after the merge and recorded them in a new evidence file rather than editing the earlier one.
- The merge commit body records the resolution rule, the cap-driven comment change, and the gate results.

## Typed-Python Review

Not applicable: the branch changes no Python file.

## Verdict

PASS. No blocking finding. Notes R1-N1 and R2-N1 and the two file-size warnings are non-blocking.
