# Coverage Comparison (P6-T4, loop pass 1)

Timestamp: 2026-10-28T13-31
Command: comparison of evidence/baseline/pester-gss.2026-10-28T13-06.md (P0-T4) with evidence/qa-gates/pester-gss.2026-10-28T13-31.md (P6-T3); changed-line mapping from the missed-line lists in artifacts/pester/powershell-coverage.xml of the P6-T3 run
EXIT_CODE: 0

| File | Baseline | Post-change | Changed-line coverage | Result |
|---|---|---|---|---|
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 97.37% (111/114) | 97.41% (113/116) | 100% (dot-source, two-line fallback call, guidance call in the deny reason: all covered) | no decrease, >= 85% |
| `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | 100.00% (75/75) | 100.00% (77/77) | 100% (new `gh pr view` clause covered by AL-39 to AL-48) | no decrease, >= 85% |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 91.78% (67/73) | 92.86% (78/84) | 100% (`Get-ModelRoutingAuthorAssertedReason` and the pr-author call site covered by AA-01 to AA-12) | no decrease, >= 85% |
| `.claude/hooks/enforce-pr-author-skill.current-branch.ps1` (new) | n/a (new file) | 95.45% (21/22) | 95.45% (new-file coverage) | >= 85% |

Missed-line attribution in the post-change run:

- helpers lines 254, 270, 293: the invalid-receipt-JSON, unreadable-body, and unparseable-`created_at` returns of `Test-PrAuthorReceiptVerification`; the same three statements missed in the baseline (then at 249, 265, 288; shifted by the inserted lines). Not changed by this plan.
- model-routing lines 341 to 349: the six statements of the script entry tail after the dot-source guard; the same six missed in the baseline (then 293 to 301). Not changed by this plan.
- current-branch line 52: the default `GitInvoker` scriptblock body (`git @args 2>$null`), which runs only against the real executable; tests inject a stand-in per the repository mocking rules.

Output Summary: no per-file decrease for the three existing CHF (97.37 -> 97.41, 100 -> 100, 91.78 -> 92.86); the new sibling is at 95.45%; all four CHF are >= 85%; changed lines are covered. Outcome: pass, not remediation-required.
