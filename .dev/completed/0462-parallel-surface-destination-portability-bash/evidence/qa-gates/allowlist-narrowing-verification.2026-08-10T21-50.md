# QA Gate — RI-2 Allowlist Narrowing Verification

Timestamp: 2026-08-10T21-50
Issue: #462
Task: [P3-T6] (verifies [P3-T1] through [P3-T5])

Delivered grant, replacing the single `Bash(bash .claude/lib/bash/*)` entry in all six locations:

```
Bash(bash .claude/lib/bash/compute-cohorts.sh*)
Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)
Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)
```

## Command (a1) — repo `parallel-planner.md` frontmatter parse

Command:

```
poetry run python -c "import re,yaml; t=open('.claude/agents/parallel-planner.md',encoding='utf-8').read(); m=re.match(r'^---\r?\n(.*?)\r?\n---',t,re.S); d=yaml.safe_load(m.group(1)); print(sorted(x for x in d['tools'] if 'lib/bash' in x))"
```

EXIT_CODE: 0

Output Summary:

```
['Bash(bash .claude/lib/bash/compute-cohorts.sh*)', 'Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)', 'Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)']
```

The frontmatter is valid YAML after the edit and the `tools` list carries exactly the three entries.
The single-line `-c` form was used per Binding Environment Constraint 3; the command produced output,
confirming it executed.

## Command (a2) — repo `parallel-orchestrator.md` frontmatter parse

Command: same invocation against `.claude/agents/parallel-orchestrator.md`

EXIT_CODE: 0

Output Summary:

```
['Bash(bash .claude/lib/bash/compute-cohorts.sh*)', 'Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)', 'Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)']
```

## Command (b1) — repo `settings.json` grant assertion

Command:

```
node -e "const s=JSON.parse(require('fs').readFileSync('.claude/settings.json','utf8')); const a=s.permissions.allow; console.log(a.filter(x=>x.includes('lib/bash')).join('|')); console.log('OLD_PRESENT=' + a.includes('Bash(bash .claude/lib/bash/*)'))"
```

EXIT_CODE: 0

Output Summary:

```
Bash(bash .claude/lib/bash/compute-cohorts.sh*)|Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)|Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)
OLD_PRESENT=false
```

JSON parses, the three entries are present in order, the old pattern is absent.

## Command (b2) — bundled `settings.json` grant assertion

Command: same invocation against
`extensions/drm-copilot/resources/claude-customizations/.claude/settings.json`

EXIT_CODE: 0

Output Summary:

```
Bash(bash .claude/lib/bash/compute-cohorts.sh*)|Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)|Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)
OLD_PRESENT=false
```

## Command (c) — repo-wide sweep for the old pattern

Command: `git grep -n "bash .claude/lib/bash/\*)"`

EXIT_CODE: 0 (matches found, all expected)

Output Summary: 8 files match, **all under `docs/features/**`** and all historical records:

| File | Nature |
| --- | --- |
| `<FEATURE>/code-review.2026-08-10T13-30.md` | prior review, records the finding that led to RI-2 |
| `<FEATURE>/evidence/other/permission-surface-callout.2026-08-10T17-08.md:55` | the amended disclosure artifact's explicit historical note describing the superseded single grant |
| `<FEATURE>/evidence/qa-gates/acceptance-criteria-checkoff.2026-08-10T17-02.md` | prior AC check-off record |
| `<FEATURE>/evidence/qa-gates/poetry-grep.2026-08-10T17-05.md` | prior QA gate record |
| `<FEATURE>/feature-audit.2026-08-10T13-30.md` | prior audit |
| `<FEATURE>/plan.2026-08-10T09-36.md` | original execution plan |
| `<FEATURE>/policy-audit.2026-08-10T13-30.md` | prior policy audit |
| `<FEATURE>/research/2026-08-10T09-45-...-research.md` | original research |

Confirming filter:

```
git grep -l "bash .claude/lib/bash/\*)" | grep -v "^docs/features/"
```

EXIT_CODE: 1 (no matches) — **zero occurrences** of the old pattern under `.claude/`,
`extensions/`, `tests/`, `scripts/`, or `src/`. No test, skill, rule, or production file pins the
superseded string.

## Prose Consumers

- `grep -c "The same allowlist entry" .claude/agents/parallel-planner.md` -> `0`
- `grep -c "The same allowlist entry" extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` -> `0`
- `grep -c "lib/bash/\*)" .claude/agents/parallel-planner.md` -> `0`
- `grep -c "lib/bash/\*)" .claude/agents/parallel-orchestrator.md` -> `0`

Both prose sites in `parallel-planner.md` were rewritten. The cohort/concurrency site now names all
three entries and states that the two commands shown require the first two; the manifest site names
`Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)` specifically, because after the
narrowing the claim that "the same allowlist entry" covers it is false. The single prose site in
`parallel-orchestrator.md` names all three entries and identifies the manifest entry as the one
covering the command shown.

## Interpretation Note (recorded for audit)

P3-T2 directs that the pre-edit line 154 prose "name the three entry-point-specific entries
(plural)". The two commands in the code block immediately below that sentence require only two of
the three grants. The sentence was therefore written to name all three entries as the delivered
grant set and then to state that the two commands below require the first two of them. This
satisfies the plan's plural-entry direction without asserting the factually incorrect claim that the
manifest grant is needed for the cohort and concurrency commands — the same accuracy concern that
P3-T2 raises for the line-161 rewrite.

## Mirror Parity

Verified at P3-T4 and re-verified at P5-T1: all three repo/bundle pairs hash-match after the edits.

Output Summary: Both agent frontmatters parse and list exactly the three narrowed entries. Both
`settings.json` copies parse and carry the three entries with the old pattern absent. The repo-wide
sweep finds the old string only in eight historical `docs/features/**` artifacts and in zero
production-surface files. RI-2 is delivered across all six locations plus the disclosure artifact.
