# Python Producer/Consumer Seam Test Run

Timestamp: 2026-08-08T15-25

Task: [P3-T9]
Working directory: repository root

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py -q`

EXIT_CODE: 0

Output Summary: PASS. 9 tests passed, 0 failed, in 0.05s. The new module binds the PRODUCER (`.claude/skills/parallel-plan/SKILL.md`, fenced `markdown` template under `## Kickoff Artifact`) to the CONSUMER (`scripts/dev_tools/parallel_kickoff_contract.py`). The two seam tests required by [P3-T4] and [P3-T5] are:

- `test_rendered_template_with_integrity_validates_clean` — the with-`## Integrity` seam test
- `test_rendered_template_without_integrity_validates_clean` — the without-`## Integrity` seam test

## Raw Output

```
.........                                                                [100%]
9 passed in 0.05s
```

## Full Test Inventory

| Test | Plan task |
|---|---|
| `test_extracted_template_is_the_documented_kickoff_block` | [P3-T3] extraction guard |
| `test_rendered_template_with_integrity_validates_clean` | [P3-T4] with-`## Integrity` seam |
| `test_rendered_template_without_integrity_validates_clean` | [P3-T5] without-`## Integrity` seam |
| `test_rendered_template_captures_planning_commit` | [P3-T6] provenance capture (pins B2) |
| `test_resume_boundary_accepts_each_documented_alternant[Every item-resumes]` | [P3-T7] alternant 1 |
| `test_resume_boundary_accepts_each_documented_alternant[Each item-resumes]` | [P3-T7] alternant 2 |
| `test_resume_boundary_accepts_each_documented_alternant[items-resume]` | [P3-T7] alternant 3, plural verb form |
| `test_resume_boundary_rejects_an_undocumented_subject` | [P3-T7] negative case (`Each entry`) |
| `test_committed_fixture_and_template_agree_on_the_resume_clause` | [P3-T8] fixture agreement |

## No External Dependencies

The module reads two committed repository files (`.claude/skills/parallel-plan/SKILL.md` and `tests/fixtures/parallel_kickoff/valid-kickoff.md`) and renders documents as in-memory strings. It creates no temporary file, starts no external process, and touches neither Git nor the network.
