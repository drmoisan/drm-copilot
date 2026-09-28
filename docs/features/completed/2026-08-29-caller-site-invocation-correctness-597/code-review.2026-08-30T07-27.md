# Code Review — Issue #597 (caller-site-invocation-correctness)

- Timestamp: 2026-08-30T07-27
- Scope: full branch diff, `f134119cd986221417dbd15c98e84f74c9364a5f..7d6ceeb145404e7ca8474ee218cab51fc7aa82f9`
- Nature of change: prose/instruction-text correction inside three Markdown files (`.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/agents/parallel-planner.md`) and their three byte-identical bundle mirrors. No production, test, or configuration source code (PowerShell, Python, TypeScript, C#) is added or changed.

## Summary of the Change

Three `Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force` instructions were corrected to a `pwsh`-qualified, root-anchored, fail-fast form:

```powershell
$repoRoot = git rev-parse --show-toplevel
Import-Module (Join-Path $repoRoot '.claude/lib/blast-radius/BlastRadius.psm1') -Force -ErrorAction Stop
```

with adjacent prose explaining that Windows PowerShell 5.1's default execution policy blocks `Import-Module` of a `.psm1`, making `pwsh` mandatory. The `parallel-add/SKILL.md:62` site received the same three corrections expressed as an inline parenthetical rather than a fenced block, preserving its original sentence structure, plus a `$result['conflict']` read-pattern correction replacing a truthiness-prone description ("Read the verdict from the conflict key of the returned hashtable... always truthy...").

## Correctness

- The corrected invocation form matches the spec's locked technical-specification section verbatim (`spec.md` lines 220-225), and is reproduced byte-for-byte at both fenced-block sites (`parallel-plan/SKILL.md:185-186`, `parallel-planner.md:151-152`).
- The `parallel-add/SKILL.md` prose form expresses the identical three corrections (`pwsh` qualifier via the execution-policy sentence, root-anchored `git rev-parse --show-toplevel` path, `-ErrorAction Stop`) without introducing a fenced block, consistent with the spec's explicit prohibition on disrupting that site's sentence structure.
- The `$result['conflict']` read-pattern correction at `parallel-add/SKILL.md:72` matches the pattern already documented at the two untouched reference sites (`BlastRadius.psm1:432-441`, `parallel-plan/SKILL.md:307-311`), so the fix is internally consistent with the codebase's existing convention rather than introducing a new one.
- `git rev-parse --show-toplevel` is a reasonable and already-used-elsewhere pattern for root-anchoring in this repository's PowerShell instruction text; it depends on `git` being on `PATH` and the working directory being inside a clone, both of which are stated as explicit assumptions in `spec.md`.

## Consistency Across Duplicated Sites

- The two fenced-block corrections (`parallel-plan/SKILL.md`, `parallel-planner.md`) are textually identical to each other, which is appropriate since both describe the same operation in the same execution context.
- All three repo/bundle mirror pairs are confirmed byte-identical (`diff` exit 0 for each pair), satisfying the repository's whole-file mirror-parity contract enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

## Blast-Radius Discipline (change containment)

- The diff for `parallel-plan/SKILL.md` was independently inspected with `git diff --unified=0`, confirming the only content change is the single `Import-Module` line (expanded to two lines) plus one inserted two-line sentence; no other line in the file is touched — in particular, the sibling truthiness warning (now at lines 307-311) and the out-of-scope `parallel_lane_assertion` passage (line 315) are untouched by this diff.
- `.claude/lib/blast-radius/BlastRadius.psm1`, `.claude/skills/parallel-orchestrate/SKILL.md`, and `.claude/skills/epic-orchestrate/SKILL.md` do not appear anywhere in the branch diff (confirmed by `git diff` against the merge-base scoped to those four paths, returning no output).
- This containment discipline is a positive practice: the change is a minimal, surgical correction that does not opportunistically touch adjacent, functioning prose.

## Readability and Maintainability

- The inserted execution-policy sentence is short, factual, and placed immediately adjacent to the corrected snippet at each site, giving the reader the "why" without requiring cross-referencing another document.
- The `parallel-add/SKILL.md` prose correction is denser than the fenced-block sites (by design, to preserve the parenthetical structure), but remains a single coherent sentence and does not degrade readability of the surrounding numbered-list item.

## Design Principles (`.claude/rules/general-code-change.md`)

Most of this rule file's guidance (classes/functions/APIs, I/O boundaries, dependency management) does not apply to a documentation-only change — there is no new code surface, no new dependency, and no I/O boundary introduced. The one directly applicable principle, "Fail fast and explicitly," is honored: `-ErrorAction Stop` was added specifically to convert a previously silent-continuation failure mode into an immediate terminating error, matching the fail-fast principle this epic establishes for the `.claude/**` runtime surface.

## Testing Discipline

- No new tests were required or added, correctly reflecting that no executable behavior changed (the module `BlastRadius.psm1` itself, which owns the actual `$result['conflict']` contract and its Pester coverage, is untouched).
- The plan instead re-verifies the two existing regression points that could plausibly be affected by touching this prose: the whole-file bundle-parity test and the `BlastRadius.Conflict.Tests.ps1` truthiness-hazard regression pair. Both were independently re-run by this reviewer and pass (1 passed; 29 passed, 0 failed).
- The plan's own literal-token verification methodology (Phase 2) shows one legitimate corrective iteration: three `verify-*` gates initially failed at `2026-08-30T07-14` because the originally-specified search token `` `pwsh` is mandatory `` wrapped across two physical lines in the rendered Markdown, and the plan explicitly documents the fix (switching to the single-line tail token `mandatory here.`) with a cited rationale (`atomic-plan-contract` rule G6). The re-run at `2026-08-30T09-30` passes cleanly. This is a legitimate diagnose-and-fix iteration on the verification tooling, not a defect in the shipped content — independently confirmed by inspecting the corrected files directly, which do contain the intended text at the stated locations.

## Findings

No blocking or non-blocking code-quality findings. The change is narrowly scoped, internally consistent, matches its own spec precisely, and its regression evidence was independently reproduced by this reviewer.
