# Stage I Cycle 2 Ledger Gates

Timestamp: 2026-11-08T19-30
Command: sh SCRATCH/issue-1097-c2-regen.sh (regeneration), sh SCRATCH/issue-1097-c2-ledger.sh (ledger, chain with -StopBefore on every entry, end state, landing, git apply -R --check, pre-image blobs), sh SCRATCH/issue-1097-c2-gates-ef.sh (scratch-index reversal of HEAD against origin/main, entries 0001 to 0009), sh SCRATCH/issue-1097-c1i-codexgen.sh (poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check)
EXIT_CODE: 0
Output Summary:
  Regeneration: git diff --cached --binary --full-index --no-renames <merge base 72e8b299c> -- <38 paths of 0010 ## Files Changed other than the ledger folder> over the staged tree; 38 sections, 0 CR bytes. Pre-image blob ids equal those of the cycle 1 patch (all origin/main blobs). The +/- line multiset differs from the cycle 1 patch only in the F1 skill lines (both copies), the ESS row token, the allowlist reason, the skill digest line, and the two F2 helper rows.
  Revert step 4 values re-derived: origin/main SHA-256 of .claude/skills/epic-orchestrate/SKILL.md 73d5c859...ed7e and .claude/agents/epic-orchestrator.md f76721ce...5e75, equal to the recorded values; unchanged.
  (a) Test-ProcessReductionLedger: IsValid True, 0 errors, 10 index rows. PASS
  (b) Invoke-ProcessReductionChain over 10 entries: IsValid True, 0 errors; -StopBefore each of 0001 to 0010 (10 sub-chains): each IsValid True, 0 errors. PASS
  (c) End-state errors 0 (PRC-LEDGER-END-STATE-RECORDED condition); 0010 created paths 12, present in FinalText 0. PASS
  (d) Get-ProcessReductionLanding for 0010: first only. PASS
  (e) git apply -R --check of the 0010 patch on the live tree: exit 0; 26 modify-section pre-image blobs, 0 missing. PASS
  (f) git apply --cached -R of the patch on a scratch index of HEAD (448d9918c): exit 0; the written tree equals origin/main on all 38 patch paths (git diff --quiet exit 0). Outside the patch paths only docs files and the branch ledger tooling of earlier stages (ProcessReductionChain.psm1 and its test) differ. PASS
  (g) Entries 0001 to 0009 and their patches changed in cycle 2: 0 files. PASS
  (h) Codex generator --check: exit 0. PASS
  Commit: 448d9918c, subject token reduction: 0010; pushed (b0fdc9fba..448d9918c). origin/main was 72e8b299c at fetch (not moved).
