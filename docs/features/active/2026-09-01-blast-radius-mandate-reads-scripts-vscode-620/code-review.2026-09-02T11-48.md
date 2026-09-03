# Code Review — Issue #620 (blast-radius-mandate-reads-scripts-vscode)

- Timestamp: 2026-09-02T11-48
- Branch: `bug/blast-radius-mandate-reads-scripts-vscode-620` @ `7e74ed77b68695eae2b8de2a4179fc97c576e655`
- Base: `origin/main` @ `dd98630c4b786280b2740eb01a75592870b22bbd`

## Change Summary

This branch makes a single functional edit repeated across two committed copies of a truth table: it appends the literal `"scripts/vscode/**"` as a new final element of the `mandate_reads` array in:

- `config/blast-radius.json` (repo root, +1 line to the array plus a trailing comma on the prior entry)
- `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (bundled copy, identical edit)

No production code (Python, PowerShell, TypeScript, C#) is added, modified, or removed. The remaining 14 changed files are Markdown: the feature folder's `issue.md`, `plan.2026-09-01T08-22.md`, the promoted potential-feature record, and 11 timestamped evidence artifacts.

## Diff Review

```diff
-    ".agents/skills/**"
+    ".agents/skills/**",
+    "scripts/vscode/**"
```

applied identically in both files. Confirmed via `git diff` that each file's change is exactly one `@@` hunk touching only the `mandate_reads` array; no other key (`version`, `shared_surfaces`, `shared_surface_globs`, `modules`, `over_breadth_fraction`) is touched.

## Design Principles Assessment

- **Simplicity first.** The fix is the minimal data change that resolves the defect: one new glob entry in an existing, purpose-built exclusion list (`mandate_reads`), reusing a mechanism the codebase already applies to `.claude/rules/**` and `quality-tiers.yml` per `.claude/rules/parallel-orchestration.md` ("Read-by-mandate classification"). No new code path, no new abstraction, no speculative generalization.
- **Reusability.** The fix does not duplicate logic; it extends an existing, already-generalized mechanism (`derive_blast_radius` / `validate_blast_radius` both consume the same `mandate_reads` list). No copy-paste introduced.
- **Extensibility.** Not applicable at this granularity — the change is a data entry, not an API. The exclusion list itself remains open to future entries without any structural change.
- **Separation of concerns.** Not applicable — no code logic changed.
- **Parity contract preserved.** `config/blast-radius.json` and the bundled copy are edited identically, keeping the three Class-1 keys (`version`, `over_breadth_fraction`, `mandate_reads`) byte-identical, per `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and `.claude/rules/parallel-orchestration.md`. Verified independently: `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` passes (see policy audit).
- **Doctrine consistency.** The issue correctly identifies that this fix applies an existing, already-documented classification doctrine (mandate-read exclusion for citations of a path as a command an item *runs*, distinct from a path an item *writes*) rather than introducing new semantics. `.claude/rules/parallel-orchestration.md` §"Read-by-mandate classification" constraint 1 ("the planner remains obliged to enumerate a genuine write explicitly") is unmodified by this branch (empty diff on that file), so the fix does not weaken the write-declaration obligation it is required to preserve (issue AC7).

## Correctness Observations

- JSON syntax: both files remain valid JSON after the edit (independently re-verifiable; evidence records `EXIT_CODE: 0` / `valid` pre- and post-edit for both copies).
- Placement: the new entry is appended as the last element of `mandate_reads`, matching the plan's literal instruction (`P1-T1`/`P1-T2`) and avoiding disruption to array ordering elsewhere in the file.
- No unrelated reformatting: each file's diff is a single 2-line hunk (trailing comma + new line), not a whole-file re-serialization, which would have obscured the intended change and risked incidental parity drift.

## Test Coverage of the Change

The change is covered by two pre-existing, unmodified test suites rather than new tests:

- `tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` — asserts `mandate_reads` (among other Class-1 keys) is byte-identical between the two copies. This generically covers any future edit to `mandate_reads`, including this one, without needing a new test authored per entry.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` ("Committed blast-radius truth table cross-copy key partition ... declares equal values for the runtime-describing keys in both copies") — the PowerShell-side mirror of the same assertion.

Neither test asserts the specific presence of `"scripts/vscode/**"` in the array; both assert the cross-copy parity invariant that this change must preserve. This is consistent with the existing repository convention (the same generic tests would have caught the original defect described in the issue — an asymmetric edit to only one copy — had one been made). No new unit test was added specifically for the new glob entry; given the entry is pure data consumed by already-tested derivation logic (`derive_blast_radius`), and the issue does not request new behavioral test coverage for the derivation logic itself (only the parity tests are named in the issue's "Proposed Fix / Validation Ideas"), this is a reasonable scope boundary for a `minor-audit` change. No `derive_blast_radius`-level test exercising the new `scripts/vscode/**` exclusion in an actual blast-radius derivation (e.g., asserting a citation of a `scripts/vscode/**` script no longer produces a `path_overlap` conflict edge) was added on this branch; that gap does not block this minor-audit fix but is worth noting as a follow-up observation.

## Naming, Style, and Readability

`"scripts/vscode/**"` matches the existing glob convention used by neighboring entries (`".agents/skills/**"`, `".claude/agent-memory/**"`) — a directory path with a trailing `/**` recursive-subtree glob. Consistent with existing style.

## Evidence Quality

Evidence artifacts consistently record `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields per the evidence-and-timestamp-conventions skill, and are placed under the canonical `evidence/{baseline,other,qa-gates}/` subdirectories. The `p2-t4-push-down-execution` artifact is notably candid about a partial/negative outcome (the push-down tool call succeeded but did not achieve its intended effect) rather than glossing over it — this matches the repository's evidence-first tonality requirement.

## Findings

No Blocking or Warning-level code-quality findings. The change is minimal, correctly scoped, consistent with existing doctrine and test coverage, and does not introduce risk disproportionate to its size.

**Observation (non-blocking):** No derivation-level regression test (asserting `derive_blast_radius` no longer emits a `path_overlap` conflict edge for a `scripts/vscode/**` citation) was added. This would strengthen confidence that the fix resolves the originally reported symptom (spurious conflict edges) rather than only the byte-parity invariant between the two config copies. Recommended as a follow-up, not a blocker for this minor-audit fix.
