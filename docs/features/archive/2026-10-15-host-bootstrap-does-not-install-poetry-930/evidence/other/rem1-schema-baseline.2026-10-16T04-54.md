# Remediation cycle 1 schema baseline (before edits)

Timestamp: 2026-10-16T04-54
Command: for t in 'Timestamp:' 'Command:' 'EXIT_CODE:' 'Output Summary:'; do echo "== $t"; grep -c -F "$t" docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/phase0-instructions-read.2026-10-16T00-17.md docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/phase1-handoff.2026-10-16T02-45.md docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/reduced-audit-handoff.2026-10-16T03-22.md; done
EXIT_CODE: 0
Output Summary: Counts match the expected baseline; no BASELINE-MISMATCH. Twelve path:count lines follow.
== Timestamp:
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/phase0-instructions-read.2026-10-16T00-17.md:1
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/phase1-handoff.2026-10-16T02-45.md:1
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/reduced-audit-handoff.2026-10-16T03-22.md:1
== Command:
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/phase0-instructions-read.2026-10-16T00-17.md:0
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/phase1-handoff.2026-10-16T02-45.md:0
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/reduced-audit-handoff.2026-10-16T03-22.md:0
== EXIT_CODE:
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/phase0-instructions-read.2026-10-16T00-17.md:0
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/phase1-handoff.2026-10-16T02-45.md:0
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/reduced-audit-handoff.2026-10-16T03-22.md:0
== Output Summary:
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/baseline/phase0-instructions-read.2026-10-16T00-17.md:1
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/phase1-handoff.2026-10-16T02-45.md:0
docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/reduced-audit-handoff.2026-10-16T03-22.md:0
