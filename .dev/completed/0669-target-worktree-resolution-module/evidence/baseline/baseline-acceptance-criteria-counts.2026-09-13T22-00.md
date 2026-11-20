# Baseline — Acceptance-Criteria Checkbox Counts

Timestamp: 2026-09-17T08:02:05-04:00
Command: for spec.md slice lines strictly between '## Acceptance Criteria' and '## Definition of Done'; for user-story.md strictly between '## Acceptance Criteria' and '## Non-Goals'; count $_.StartsWith('- [ ] ') and $_.StartsWith('- [x] ')
EXIT_CODE: 0
Output Summary: spec.md total=51 checked=0 unchecked=51 (heading lines 652/732); user-story.md total=51 checked=0 unchecked=51 (heading lines 159/239).

| File | Slice (heading lines, exclusive) | Total checkbox lines | Checked | Unchecked |
| --- | --- | --- | --- | --- |
| spec.md | 652 .. 732 | 51 | 0 | 51 |
| user-story.md | 159 .. 239 | 51 | 0 | 51 |
