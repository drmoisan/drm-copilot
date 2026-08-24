# Phase 0 — Policy Instructions Read (Issue #393)

Timestamp: 2026-07-21T18-45

Policy Order: The repository policy-compliance reading order was followed:
CLAUDE.md → general-code-change → general-unit-test → language-specific (Python) →
domain-specific (CI workflows) → quality-tiers → tonality.

Files read (verbatim list):

1. `CLAUDE.md` (standing instructions; auto-loaded)
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/self-explanatory-code-commenting.md`
7. `.claude/rules/ci-workflows.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/tonality.md`
10. `.claude/rules/benchmark-baselines.md` (auto-loaded context)
11. `.claude/rules/orchestrator-state.md` (auto-loaded context)

Supporting feature references read:
- `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/spec.md`
- `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/research/2026-07-21T18-45-native-bash-shell-qc-research.md`
- `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/issue.md`
- `scripts/dev_tools/shell_qc.py` (parity source, read in full)
- `scripts/dev_tools/fix_all.py` (skip-marker consumer)
- `scripts/dev_tools/fix_all_branches.py` (hidden consumer)

Output Summary: All required policy files were read in order prior to any mutation.
Work Mode resolved from `issue.md` metadata: `full-feature` (AC source = spec.md + user-story.md;
issue.md carries the AC1–AC9 list mirrored in spec.md).
