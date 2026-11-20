# AC File-Size Interpretation — Addendum (Issue #1028)

Timestamp: 2026-11-18T02-40
Command: wc -l scripts/harness-generation/sources/rules/parallel-orchestration.md config/harness-parity-matrix.json
EXIT_CODE: 0
Output Summary: 852 lines in scripts/harness-generation/sources/rules/parallel-orchestration.md; 11896 lines in config/harness-parity-matrix.json.

Supersedes-in-part: `ac-file-size-interpretation.2026-11-18T01-58.md` (not edited; evidence is append-only).

The earlier record named `config/harness-parity-matrix.json` as the one added or changed file above 800 lines. The feature review of 2026-11-18 (code-review.2026-11-18T02-32.md, Minor finding) identified a second file above 800 lines: `scripts/harness-generation/sources/rules/parallel-orchestration.md` (852 lines, added on this branch).

That file is Markdown. Markdown documentation is exempt from the file-size limit (`.claude/rules/general-code-change.md`, `## File Size Limit`), and the spec states that Markdown outputs are exempt. The interpretation in the earlier record therefore holds unchanged: every added or changed file covered by the file-size policy is at or below 800 lines, and the two files above 800 lines (one JSON data file, one Markdown source) are outside that policy.

Recorded by: orchestrator, in response to the review finding.
