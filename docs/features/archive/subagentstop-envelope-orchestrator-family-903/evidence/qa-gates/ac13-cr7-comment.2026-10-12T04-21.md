# AC-13 CR-7 Comment, Static Re-run ([P7-T8] re-run of [P6-T4])

Timestamp: 2026-10-12T04-21
Command: rg -n "One subprocess call" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1 ; rg -n -F "in-process validation (issue #475)" .claude/hooks/validate-orchestrator-output.ps1
EXIT_CODE: 0
Output Summary: first search EXIT_CODE 1 with no match lines; second search EXIT_CODE 0 with exactly one comment match line (313).

Search 1 EXIT_CODE: 1, match lines: none
Search 2 EXIT_CODE: 0, match lines:
313:        # The in-process validation (issue #475) covers both the completion check

Full replacement comment (.claude/hooks/validate-orchestrator-output.ps1:313-317):
        # The in-process validation (issue #475) covers both the completion check
        # and the model-routing check in one call. Surface a model-routing gate
        # failure under its own block reason (its errors name model_routing_receipts
        # or complexity_assessments); otherwise fall back to the routing-contract
        # block reason for a generic completion/routing failure.
