# Fixture Immutability and Error-String Preservation (P5-T5, Issue #849)

Timestamp: 2026-10-10T14-31
Command: git diff --name-status --merge-base origin/main -- tests/fixtures/orchestrator_state_issue_adoption
EXIT_CODE: 0
Output Summary: five `A` entries, exactly the five P1 fixtures; the porcelain listing for the fixture directory is empty; no `M`, `D`, or `R` entry. The module diff removes six lines, none containing `Checkpoint issue_adoption`, `must name a markdown`, or `when waiving` (AC-8).

## 1. Fixture directory name-status against the merge-base

```text
A	tests/fixtures/orchestrator_state_issue_adoption/epic-decomposition-waives-entry-tool-without-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/filed-before-orchestration-invalid-present-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/valid-bug-large-filed-before-orchestration-without-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/valid-bug-preparation-filed-before-orchestration-without-record.json
A	tests/fixtures/orchestrator_state_issue_adoption/valid-large-transferred-waives-feature-entry-tool-without-record.json
```

## 2. Fixture directory porcelain status

Porcelain command: git status --porcelain -- tests/fixtures/orchestrator_state_issue_adoption
Porcelain exit status: 0

```text
(empty output)
```

Union of the two listings: the five P1 fixture files (D1 through D5), each as added (`A`); no untracked (`??`), `M`, `D`, or `R` entry. The 29 baseline fixtures are unchanged relative to the merge-base.

## 3. Validator module diff against the merge-base

Module diff command: git diff -U0 --merge-base origin/main -- scripts/dev_tools/_orchestrator_state_issue_adoption.py extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
Module diff exit status: 0

Every removed (`-`) line, quoted verbatim:

```text
-        [object] $PotentialRecord
-    $potentialRecord = (Get-CheckpointObjectMember -Owner $adoption -Name 'potential_record').Value
-    $errors.AddRange([string[]]@(Get-AdoptionPotentialRecordError -WaivedTool $waived.Value -PotentialRecord $potentialRecord))
-  errors.push(...potentialRecordErrors(waived, adoption["potential_record"]));
-    waived: Sequence[str], potential_record: object
-    """Require a potential record when a promotion-entry tool is waived (rule 9)."""
```

Token check: none of the six removed lines contains `Checkpoint issue_adoption`, `must name a markdown`, or `when waiving`. No validator error string was removed or altered.
