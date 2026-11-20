# Acceptance-Criteria Check-Off Count (P11-T28)

Timestamp: 2026-09-26T20-45
Branch: N588

Command: awk '/^## Acceptance Criteria/{f=1;next} /^## /{f=0} f&&/^- \[x\]/{x++} f&&/^- \[ \]/{u++} END{print "checked=" x+0, "unchecked=" u+0}' docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/spec.md
EXIT_CODE: 0
Output Summary: Printed exactly `checked=27 unchecked=0`. All 27 items in the spec.md `## Acceptance Criteria` section were checked off individually by [P11-T1] through [P11-T27], each against its named evidence. The spec.md working diff against HEAD is 27 insertions and 27 deletions (checkbox state only; no criterion text changed).
