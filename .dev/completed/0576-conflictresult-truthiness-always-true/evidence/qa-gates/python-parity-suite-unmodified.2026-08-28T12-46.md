# Python Parity Suite Unmodified — [P3-T6]

Timestamp: 2026-08-28T12-46

Command: `git diff --stat origin/main -- tests/scripts/dev_tools`

EXIT_CODE: 0

## Verbatim Stat Listing

```
 .../dev_tools/test_blast_radius_conflicts.py       | 42 ++++++++++++++++++++++
 .../dev_tools/test_blast_radius_invariants.py      | 10 ++++++
 2 files changed, 52 insertions(+)
```

Two files changed, 52 insertions, zero deletions.

## Supplementary Full-Path Listing

The `--stat` renderer abbreviates the leading path segments to `...`. To remove any ambiguity about
which files the two abbreviated rows name, the same anchored span was additionally listed by full
path:

```
$ git diff --name-only origin/main -- tests/scripts/dev_tools
tests/scripts/dev_tools/test_blast_radius_conflicts.py
tests/scripts/dev_tools/test_blast_radius_invariants.py
```

Exit code 0. Exactly two paths, both under `tests/scripts/dev_tools/`.

## Acceptance Checks

| Check | Result |
| --- | --- |
| The stat listing names `tests/scripts/dev_tools/test_blast_radius_conflicts.py` | Yes, 42 insertions. |
| The stat listing names `tests/scripts/dev_tools/test_blast_radius_invariants.py` | Yes, 10 insertions. |
| The stat listing names no other file | Yes. The summary line reads `2 files changed`. |
| The stat listing does not name the Python parity suite test_blast_radius_parity.py under tests/scripts/dev_tools | Yes. That file exists in the tree — `ls` resolves it — but it appears in neither the stat listing nor the full-path listing, so it is unmodified relative to `origin/main`. |

Output Summary: `EXIT_CODE: 0`. The anchored stat listing over `tests/scripts/dev_tools` names
exactly two files, `test_blast_radius_conflicts.py` with 42 insertions and
`test_blast_radius_invariants.py` with 10 insertions, for 2 files changed and 52 insertions with no
deletions. The Python parity suite test_blast_radius_parity.py under tests/scripts/dev_tools is
present in the tree but absent from the diff, so it is unmodified. The shared fixture corpus was not
extended with a truthiness assertion the two runtimes cannot both satisfy.
