# Evidence Timestamp Disclosure

Timestamp: 2026-11-24T09-49
Command: date -u +%Y-%m-%dT%H-%M (this file), and a review of how the stamps of this run's evidence files were produced
EXIT_CODE: 0
Output Summary:
- Rule: an evidence filename stamp is the UTC time read from the clock immediately before the write.
- Finding: for most Write-tool artifacts of this run, the stamp was taken from a `date -u` value printed by a command run shortly before the write (typically 0 to 3 minutes earlier), not from a clock read immediately before the write. Two stamps were typed without a matching clock read: `qa-gates/contract-scope.2026-11-24T09-47.md` (clock read 09-45 before its command set) and `qa-gates/self-review.2026-11-24T09-48.md` (written when the clock read 09-46 or 09-47, so its stamp is later than its write time).
- Effect: the lexicographic-greatest selection still picks the intended file for every artifact kind: `qa-gates/self-review.2026-11-24T09-49.md`, written after a clock read of 09-49, is the authoritative self-review and is the greatest `self-review.*.md`.
- No evidence file was renamed, edited, or deleted; this disclosure is appended instead, as the append-only rule requires.
- Corrective action for later runs: read the clock in the same command that writes each evidence file.
