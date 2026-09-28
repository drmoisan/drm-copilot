# Baseline — `.claude/rules/*.md` Frontmatter Inventory (Issue #559)

Timestamp: 2026-08-25T23-48
Task: [P0-T8]

## Command:

```
poetry run python -c "import pathlib,yaml,json;fs=sorted(pathlib.Path('.claude/rules').glob('*.md'));rows=[[str(p).replace(chr(92),'/'),(lambda t:(None if not t.startswith('---') else yaml.safe_load(t.split('---',2)[1])))(p.read_text(encoding='utf-8'))] for p in fs];print(json.dumps([[n,(d.get('paths') if isinstance(d,dict) else 'NO_FRONTMATTER'),(d.get('description') if isinstance(d,dict) else None)] for n,d in rows],indent=1));print('FILECOUNT',len(fs))"
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

The payload is a **single line**. A multi-line `python -c` payload is a known silent no-op in
this environment: it exits 0 without executing, which would fabricate the inventory rather than
take it. The payload was not reformatted across lines.

Detection method: a file is classified `NO_FRONTMATTER` when its text does not begin with `---`.
Otherwise the text between the first and second `---` fences is parsed with `yaml.safe_load` and
its `paths` and `description` keys are read. Classification is therefore by actual YAML parse,
not by a textual guess.

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Required Counts

| Acceptance condition | Expected | Observed | Result |
|---|---|---|---|
| Files matching `.claude/rules/*.md` | 19 | 19 | MATCH |
| Files carrying no frontmatter block | 5 | 5 | MATCH |
| Files carrying an unconditional `paths:` entry | 4 | 4 | MATCH |

`FILECOUNT 19` was printed by the command directly, so the file total is observed rather than
counted by hand from the table.

## Full Inventory (19 files, alphabetical)

| # | File | Frontmatter | `paths:` entries | Class |
|---|---|---|---|---|
| 1 | `.claude/rules/architecture-boundaries.md` | present | `**/*.ts`, `**/*.cs` | scoped |
| 2 | `.claude/rules/benchmark-baselines.md` | **ABSENT** | — | **unscoped** |
| 3 | `.claude/rules/ci-workflows.md` | **ABSENT** | — | **unscoped** |
| 4 | `.claude/rules/csharp.md` | present | `**/*.cs`, `**/*.csproj` | scoped |
| 5 | `.claude/rules/general-code-change.md` | present | `**` | **unconditional** |
| 6 | `.claude/rules/general-unit-test.md` | present | `**` | **unconditional** |
| 7 | `.claude/rules/mermaid.md` | present | `**/*.mmd`, `**/*.mermaid` | scoped |
| 8 | `.claude/rules/orchestrator-state.md` | **ABSENT** | — | **unscoped** |
| 9 | `.claude/rules/parallel-orchestration.md` | **ABSENT** | — | **unscoped** |
| 10 | `.claude/rules/plan-acceptance-gates.md` | **ABSENT** | — | **unscoped** |
| 11 | `.claude/rules/powershell.md` | present | `**/*.ps1`, `**/*.psm1`, `**/*.psd1` | scoped |
| 12 | `.claude/rules/python-suppressions.md` | present | `**/*.py` | scoped |
| 13 | `.claude/rules/python.md` | present | `**/*.py` | scoped |
| 14 | `.claude/rules/quality-tiers.md` | present | `**` | **unconditional** |
| 15 | `.claude/rules/self-explanatory-code-commenting.md` | present | `**/*.py` | scoped |
| 16 | `.claude/rules/shell.md` | present | `**/*.sh`, `**/*.bats`, `scripts/bash/**`, `tests/shell/**` | scoped |
| 17 | `.claude/rules/tonality.md` | present | `**` | **unconditional** |
| 18 | `.claude/rules/typescript-suppressions.md` | present | `**/*.ts` | scoped |
| 19 | `.claude/rules/typescript.md` | present | `**/*.ts` | scoped |

## The Five Files Carrying No Frontmatter Block

These are exactly the five files Phase 2 scopes, in the order the plan's tasks address them:

| Plan task | File |
|---|---|
| `[P2-T1]` | `.claude/rules/ci-workflows.md` |
| `[P2-T2]` | `.claude/rules/benchmark-baselines.md` |
| `[P2-T3]` | `.claude/rules/plan-acceptance-gates.md` |
| `[P2-T4]` | `.claude/rules/orchestrator-state.md` |
| `[P2-T5]` | `.claude/rules/parallel-orchestration.md` |

The observed unscoped set and the Phase 2 target set are identical. No file needing scoping is
missing from Phase 2, and no Phase 2 task targets an already-scoped file.

## The Four Files Carrying an Unconditional Entry

| File | `paths:` | Deliberate? |
|---|---|---|
| `.claude/rules/general-code-change.md` | `**` | yes — cross-language code change policy |
| `.claude/rules/general-unit-test.md` | `**` | yes — cross-language unit test policy |
| `.claude/rules/quality-tiers.md` | `**` | yes — tier map governs every project |
| `.claude/rules/tonality.md` | `**` | yes — tone policy applies to all files and responses |

All four carry the single glob `**`. Each is a repository-wide policy whose applicability is not
conditioned on file type, so an unconditional entry is correct for each. These four are the
deliberate unconditional set that `[P1-T1]`'s
`test_unconditional_rule_set_is_exactly_the_four_deliberate_files` will assert.

## Pre-Change Unconditional Set Under the `[P1-T1]` Definition

`[P1-T1]` defines a rules file carrying **no** frontmatter block as unconditional in effect: with
no `paths:` scoping it loads on every turn. Under that definition the pre-change unconditional
set has **nine** members — the four explicit `**` files above plus the five unscoped files —
not four.

This is the observation that makes `[P1-T3]`'s `[expect-fail]` acceptance correct. Had the
unconditional set been counted only from explicit `**` entries, the pre-change repository would
already satisfy a four-file expectation, the test would pass before the fix, and the
fail-before evidence would be unobtainable. The observed 9-against-4 gap confirms the test will
fail before `[P2-T1]` through `[P2-T5]` and pass after.

| Set | Members | Count |
|---|---|---|
| Explicit `**` entries | general-code-change, general-unit-test, quality-tiers, tonality | 4 |
| No frontmatter block (unconditional in effect) | benchmark-baselines, ci-workflows, orchestrator-state, parallel-orchestration, plan-acceptance-gates | 5 |
| **Pre-change unconditional total** | | **9** |
| **Post-change expected total** | | **4** |

Output Summary: PASS. The inventory lists all 19 files matching `.claude/rules/*.md`, identifies
exactly 5 as carrying no frontmatter block (`benchmark-baselines`, `ci-workflows`,
`orchestrator-state`, `parallel-orchestration`, `plan-acceptance-gates`), and identifies exactly
4 as carrying an unconditional `**` entry (`general-code-change`, `general-unit-test`,
`quality-tiers`, `tonality`). All three counts match the acceptance condition. The unscoped set
is identical to the Phase 2 target set. Under the `[P1-T1]` definition the pre-change
unconditional set has 9 members against a post-change expectation of 4, which confirms the
`[P1-T3]` fail-before is obtainable.
