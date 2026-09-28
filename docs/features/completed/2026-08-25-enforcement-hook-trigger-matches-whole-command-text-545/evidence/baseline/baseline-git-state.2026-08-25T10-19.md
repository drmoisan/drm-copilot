# Phase 0 — Git baseline (issue #545)

Timestamp: 2026-08-25T10-19

Task: [P0-T3]

Command: `git rev-parse --abbrev-ref HEAD && git rev-parse HEAD`

EXIT_CODE: 0

Output Summary:

- Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545`
- HEAD commit SHA (40 characters): `e752bb3d2f948599db652349f85aefabfc45b973`

This is the commit against which every "before the fix" measurement in this plan is taken,
including the two Phase 3 fail-before regression runs and the [P1-T12] line-citation
re-derivation.

---

## Correction — base advanced by a user-performed rebase onto main

Timestamp: 2026-08-25T14-00

Command: `git rev-parse HEAD`, `git merge-base --is-ancestor e752bb3d2f948599db652349f85aefabfc45b973 HEAD`, and `git diff --name-only e752bb3d2f948599db652349f85aefabfc45b973 HEAD` with path filters

EXIT_CODE: 0

The user rebased this branch onto `main` after the Phase 0 baseline above was captured. The
original record is retained unaltered for the audit trail; the corrected values are:

- Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545` (unchanged)
- Superseded baseline HEAD: `e752bb3d2f948599db652349f85aefabfc45b973`
- **Current baseline HEAD (40 characters): `0c7469f8c6e2a8e9915789875b436085e704b114`**

### The rebase did not rewrite history

`git merge-base --is-ancestor e752bb3d… HEAD` returns true, so the superseded commit remains an
ancestor of the new HEAD. This was a fast-forward merge, not a replay onto a new root, and no
previously recorded commit was rewritten.

### Scope of the incoming change, and why no other Phase 0 artifact is invalidated

51 files changed between the two commits. Measured by path-filtered `git diff --name-only`:

| Phase 0 artifact | Sensitive to | Files changed by the rebase | Verdict |
| --- | --- | --- | --- |
| [P0-T1] policy reads | the seven named policy files | **0** | unaffected |
| [P0-T2] feature documents | the three #545 documents | **0** | unaffected |
| [P0-T4] file inventory | the 16 in-scope production copies | **0** | unaffected |
| [P0-T5] format baseline | any `.ps1` / `.psm1` / `.psd1` | **0** | unaffected |
| [P0-T6] analyze baseline | any `.ps1` / `.psm1` / `.psd1` | **0** | unaffected |
| [P0-T7] MCP test baseline | any `*.Tests.ps1` | **0** | unaffected |
| [P0-T8] self-hosted coverage | hooks, their suites, both runsettings | **0** | unaffected |
| [P0-T3] git baseline | the HEAD SHA itself | 1 (HEAD moved) | **corrected above** |

**Not a single PowerShell file changed.** The incoming commits are issue #524 work: feature
documentation under `docs/features/active/…-524/`, one TypeScript validator module and its test,
one Python module and its pytest, and `.claude/rules/orchestrator-state.md` together with its
bundle mirror. `orchestrator-state.md` is not among the seven policy files [P0-T1] read and is
not in this change's scope; it changed in both its canonical and its bundled location in the same
commits, so the Claude push-down mirror relation is preserved.

The Python file `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py`
sits under `tests/scripts`, which is inside the PoshQC scan set, but Pester discovers only
`*.Tests.ps1` and the PoshQC analyzer filters to `.ps1` and `.psm1`, so it enters neither the
test counts of [P0-T7] nor the diagnostic counts of [P0-T6].

### Direct re-measurement after the rebase (not inferred from the diff)

- The twelve existing in-scope copies re-measure at exactly the recorded line counts:
  381, 382, 381, 382, 274, 261, 274, 261, 228, 228, 311, 311.
- All four `hook-command-scanner.ps1` locations are still absent.
- `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` still holds
  **83** entries, and `.codex/hooks/enforce-promotion-mcp-only.ps1` still occurs **0** times in it,
  so the [P0-T8] absent-from-denominator entry remains correct.

Output Summary: The rebase advanced the base from `e752bb3d` to `0c7469f8` without rewriting
history. Zero PowerShell files, zero test suites, zero in-scope production copies, zero policy
files read by [P0-T1], and zero #545 feature documents were touched. [P0-T3] is corrected to the
new HEAD; [P0-T1], [P0-T2], and [P0-T4] through [P0-T8] remain valid and are not re-run.
