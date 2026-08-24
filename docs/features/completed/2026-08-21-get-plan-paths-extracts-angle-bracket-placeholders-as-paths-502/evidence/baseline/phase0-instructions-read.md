# Phase 0 Policy Read Evidence — [P0-T1]

Timestamp: 2026-08-23T00-05

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T1]
Work Mode: full-bug
State captured: PRE-CHANGE baseline

## Policy Order

The reading order required by `CLAUDE.md` and the `policy-compliance-order` skill was followed
exactly, in the sequence named by [P0-T1]:

1. `CLAUDE.md` — repository standing instructions, tone policy, policy-compliance reading order,
   four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles,
   the mandatory seven-stage toolchain loop, the 500-line file-size limit, error handling, naming,
   public-API compatibility, dependency policy, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: the five core
   properties, uniform coverage requirements (line >= 85%, branch >= 75%), the Coverage Exclusion
   Policy prohibiting any `exclude` entry over a production source path, scenario completeness,
   Arrange-Act-Assert structure, the prohibition on temporary files in tests, and the
   `tests/` mirror-layout requirement.
4. `.claude/rules/general-unit-test.md` (test-category and determinism sections) — read as part of
   the same file.
5. `.claude/rules/quality-tiers.md` — the T1 through T4 rigor tiers and the uniform-versus-
   tier-dependent gate matrix; confirms the uniform coverage thresholds and the Pester
   branch-coverage exemption.
6. `.claude/rules/self-explanatory-code-commenting.md` — mandatory class and function docstrings,
   loop and comprehension intent comments, branching decision-logic comments, multi-step-block
   meta-what comments, and the prohibition on numbered notes.
7. `.claude/rules/python.md` — Python toolchain (`poetry run black .`, `poetry run ruff check .`,
   `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`), PEP 8
   naming, strong typing, small cohesive modules, `_prefixed` internal helpers, pytest rules.
8. `.claude/rules/python-suppressions.md` — the pre-authorized `# noqa` and `# type: ignore`
   patterns and the explicitly-unauthorized set. Confirms `F401` is NOT authorized, which is the
   rule the [P2-T3] `--no-fix` lint gate exists to keep observable.
9. `.claude/rules/powershell.md` — PowerShell toolchain via the four PoshQC MCP functions, the
   PowerShell 7+ compatibility requirement, advanced-function standards, the 500-line limit, the
   wrapper-function design seam, Pester testing standards, and the statement that Pester measures
   command and line coverage only.
10. `.claude/rules/typescript.md` — Prettier, ESLint, TSC, Jest toolchain; confirms the extension
    package's script names used by [P0-T10] and [P8-T10].
11. `.claude/rules/parallel-orchestration.md` — the parallel-surface artifact invariants, the
    Blast-Radius Contention Doctrine, and specifically the read-by-mandate classification section
    whose token-shape paragraph [P6-T1] is authorized to amend.
12. `.claude/rules/plan-acceptance-gates.md` — the G1 through G6 acceptance-gate rules, the
    checkable-literal definition, and the placeholder-guard marker set
    (`<`, `>`, `${`, `$(`, `%`) that is the origin of this item's marker set.
13. `quality-tiers.yml` — see the deviation recorded below.

## Files Read

Every file below was read in full in this session.

| Order | File | Status |
| --- | --- | --- |
| 1 | `CLAUDE.md` | read |
| 2 | `.claude/rules/general-code-change.md` | read |
| 3 | `.claude/rules/general-unit-test.md` | read |
| 4 | `.claude/rules/quality-tiers.md` | read |
| 5 | `.claude/rules/self-explanatory-code-commenting.md` | read |
| 6 | `.claude/rules/python.md` | read |
| 7 | `.claude/rules/python-suppressions.md` | read |
| 8 | `.claude/rules/powershell.md` | read |
| 9 | `.claude/rules/typescript.md` | read |
| 10 | `.claude/rules/parallel-orchestration.md` | read |
| 11 | `.claude/rules/plan-acceptance-gates.md` | read |
| 12 | `quality-tiers.yml` | ABSENT at repository root — see deviation |

## Deviation — `quality-tiers.yml` is absent at the repository root

`quality-tiers.yml` does not exist at the repository root of this worktree. This is a pre-existing
repository condition, not a change made by this item, and it is independently on record: the
feature-444 baseline artifact
`docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/quality-tiers-observed.2026-08-07T18-08.md`
recorded the same absence on 2026-08-07.

Verification commands and their results:

```text
$ find . -name "quality-tiers*" -not -path "*/node_modules/*"
./.agents/skills/quality-tiers
./.claude/rules/quality-tiers.md
./docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/baseline/quality-tiers-observed.2026-08-07T18-08.md
./docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/other/quality-tiers-classification.2026-08-07T19-58.md
./extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md
./extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/quality-tiers
```

EXIT_CODE: 0

No file matching `quality-tiers.yml` exists anywhere in the tree. The tier policy itself was
therefore read from `.claude/rules/quality-tiers.md`, which is the rule file that defines the
tier system and states that the YAML map is its source of truth. The absence changes no threshold
applied by this item: the uniform thresholds (line >= 85%, branch >= 75% where measurable) are
stated in the rule file directly and are the figures the Phase 0 and Phase 8 coverage tasks use.

This item does not create `quality-tiers.yml`. Doing so is outside the scope of issue #502 and
would additionally touch a declared shared surface, widening this item's blast radius for a
reason unrelated to the defect under repair.

## Output Summary

All 11 present policy files were read in the required order. One named file, `quality-tiers.yml`,
is absent at the repository root; the absence is pre-existing, independently corroborated by the
feature-444 baseline record, and does not alter any threshold this plan applies. No policy file
was modified.
