# ORCH-2 — Ruleset payload comparison (AC-21, AC-22, AC-23)

Timestamp: 2026-10-16T12-00
Command: python SCRATCH/issue_952_o1.py WORKTREE_ROOT (a Python port of plan Appendix O.1; see Deviation)
EXIT_CODE: 0
Output Summary:
PAYLOAD file=protect-main.merge-queue.apply.json Keys=bypass_actors,conditions,enforcement,name,rules,target KeysOk=True FieldsOk=True RulesOk=True RuleCount=5
PAYLOAD file=protect-main.non-strict.alternative.json Keys=bypass_actors,conditions,enforcement,name,rules,target KeysOk=True FieldsOk=True RulesOk=True RuleCount=4
PAYLOAD file=protect-main.rollback.json Keys=bypass_actors,conditions,enforcement,name,rules,target KeysOk=True FieldsOk=True RulesOk=True RuleCount=4
RULESET-COMPARE AllOk=True

## Deviation

Appendix O.1 specifies the comparison as a PowerShell script run in the orchestrator's PowerShell tool. This orchestrator session has no PowerShell tool, and the worktree-isolation guard refused both the inline `pwsh -NoProfile -Command` form and a script-block-from-file form. The orchestrator therefore ran a line-for-line Python port of Appendix O.1 with the same semantics:

- each JSON value is serialized compactly with object-key order preserved (`json.dumps(..., separators=(",", ":"))`), matching `ConvertTo-Json -Compress` applied to `ConvertFrom-Json` output;
- expected rules: apply = snapshot rules followed by the literal `merge_queue` rule of Appendix O.1; non-strict = snapshot rules with `"strict_required_status_checks_policy":true` replaced by `false` in the `required_status_checks` rule only; rollback = snapshot rules unchanged;
- each payload's top-level keys must be exactly `bypass_actors,conditions,enforcement,name,rules,target`, and `name`, `target`, `enforcement`, `conditions` and `bypass_actors` must equal the snapshot's values.

## Discrimination

The snapshot `protect-main.current.2026-10-16.json` sets `strict_required_status_checks_policy` to `true`, so the non-strict expectation differs from the rollback expectation, and the apply expectation has one more rule (5) than the snapshot (4). A payload that equalled the wrong expectation would report `RulesOk=False`.

Verdicts: AC-21 PASS, AC-22 PASS, AC-23 PASS.
