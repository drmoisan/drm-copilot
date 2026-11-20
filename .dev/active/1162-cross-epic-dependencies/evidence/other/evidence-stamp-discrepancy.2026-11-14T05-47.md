# Evidence Filename Stamp Discrepancy

Timestamp: 2026-11-14T05-47
Command: date -u -r <file> +%Y-%m-%dT%H-%M for each evidence file written in this run, compared with its filename stamp
EXIT_CODE: 0
Output Summary: five files written in this run carry a filename stamp one minute from their UTC write time. The stamps were taken from the clock reading of the recorded command instead of a reading taken immediately before the write. The files are not renamed, because evidence is append-only; this note records the write times. Every later evidence file in this run is stamped from a clock reading taken immediately before its write.

| File | Write time (UTC, from mtime) |
|---|---|
| evidence/other/task-check.P3-T1.2026-11-14T05-24.md | 2026-11-14T05-25 |
| evidence/other/task-check.P3-T4.2026-11-14T05-28.md | 2026-11-14T05-29 |
| evidence/other/task-check.P4-T3.2026-11-14T05-37.md | 2026-11-14T05-38 |
| evidence/other/task-check.P4-T5.2026-11-14T05-43.md | 2026-11-14T05-42 |
| evidence/other/frozen-digests.2026-11-14T05-45.md | 2026-11-14T05-46 |

The `Timestamp:` field of each file is the clock reading of the command it records and is unaffected. The ordering of the files by name matches their write order, so the lexicographically-greatest selection rule still picks the most recent file of each name.
