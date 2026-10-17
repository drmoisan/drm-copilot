# Historical AFTER Derivation After the Classifier Change (P4-T3)

Timestamp: 2026-10-09T03-50
Command: poetry run python -c "<exact P0-T13 command>" (re-run verbatim; the command text is recorded in evidence/baseline/historical-after-derivation.2026-10-09T02-51.md)
EXIT_CODE: 0
Output Summary: three lines. Per-run comparison with P0-T13:
  epic-655-followups: NO-CHANGE
  backlog-2026-09-26: edges[1] (a 588, b 622) cost 152 -> 160; every other field (both edges' a, b, benefit, hard, reason; edge 528-588 cost 8; tolerated_overlaps []; cohorts [[513, 588, 594], [528, 622]]) unchanged
  followups-2026-09-27: NO-CHANGE
The cost rise of 8 equals one same_file weight: extensions/drm-copilot/jest.config.cjs, recorded in both items 588 and 622, now survives normalization in both.

## Output (verbatim)

```text
epic-655-followups {"cohorts": [[660], [663]], "edges": [{"a": 660, "b": 663, "benefit": 1, "cost": 8, "hard": true, "reason": "path_overlap"}], "tolerated_overlaps": []}
backlog-2026-09-26 {"cohorts": [[513, 588, 594], [528, 622]], "edges": [{"a": 528, "b": 588, "benefit": 2, "cost": 8, "hard": false, "reason": "path_overlap"}, {"a": 588, "b": 622, "benefit": 4, "cost": 160, "hard": false, "reason": "path_overlap"}], "tolerated_overlaps": []}
followups-2026-09-27 {"cohorts": [[707, 712, 714, 715], [706, 709, 711, 716], [708], [710], [713]], "edges": [{"a": 706, "b": 707, "benefit": 4, "cost": 16, "hard": false, "reason": "path_overlap"}, {"a": 706, "b": 708, "benefit": 4, "cost": 16, "hard": false, "reason": "path_overlap"}, {"a": 706, "b": 710, "benefit": 4, "cost": 16, "hard": false, "reason": "path_overlap"}, {"a": 706, "b": 713, "benefit": 4, "cost": 16, "hard": false, "reason": "path_overlap"}, {"a": 706, "b": 715, "benefit": 2, "cost": 48, "hard": false, "reason": "path_overlap"}, {"a": 707, "b": 708, "benefit": 4, "cost": 100, "hard": true, "reason": "path_overlap"}, {"a": 707, "b": 709, "benefit": 4, "cost": 50, "hard": true, "reason": "path_overlap"}, {"a": 707, "b": 710, "benefit": 4, "cost": 132, "hard": true, "reason": "path_overlap"}, {"a": 707, "b": 711, "benefit": 2, "cost": 8, "hard": false, "reason": "path_overlap"}, {"a": 707, "b": 713, "benefit": 4, "cost": 148, "hard": true, "reason": "path_overlap"}, {"a": 708, "b": 709, "benefit": 4, "cost": 34, "hard": true, "reason": "path_overlap"}, {"a": 708, "b": 710, "benefit": 4, "cost": 52, "hard": true, "reason": "path_overlap"}, {"a": 708, "b": 713, "benefit": 4, "cost": 76, "hard": true, "reason": "path_overlap"}, {"a": 709, "b": 710, "benefit": 4, "cost": 66, "hard": true, "reason": "path_overlap"}, {"a": 709, "b": 713, "benefit": 4, "cost": 82, "hard": true, "reason": "path_overlap"}, {"a": 710, "b": 713, "benefit": 4, "cost": 196, "hard": true, "reason": "path_overlap"}, {"a": 714, "b": 716, "benefit": 2, "cost": 16, "hard": false, "reason": "path_overlap"}], "tolerated_overlaps": [{"a": 708, "b": 711, "benefit": 2, "cost": 2, "reasons": ["module_overlap"]}]}
```
