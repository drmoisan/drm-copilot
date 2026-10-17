# Error Strings Moved Unchanged (P6-T1)

Timestamp: 2026-10-16T06-37
Command: git diff -U0 254b5a5420ff37e894ed0b69f19971f4843f5214 -- scripts/dev_tools/epic_planner_git_integrity.py scripts/dev_tools/epic_planner_readiness.py extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts > SCRATCH/rc2/cycle-prod.diff; grep -e '^-[^-]' SCRATCH/rc2/cycle-prod.diff > SCRATCH/rc2/cycle-removed.txt; grep -e '^+[^+]' SCRATCH/rc2/cycle-prod.diff > SCRATCH/rc2/cycle-added.txt; grep -e 'must ' -e 'Epic planner' SCRATCH/rc2/cycle-removed.txt > SCRATCH/rc2/cycle-removed-msg.txt; grep -e 'must ' -e 'Epic planner' SCRATCH/rc2/cycle-added.txt > SCRATCH/rc2/cycle-added-msg.txt; sed -e 's/^[-+][[:space:]]*//' SCRATCH/rc2/cycle-removed-msg.txt > SCRATCH/rc2/cycle-removed-stripped.txt; sed -e 's/^[-+][[:space:]]*//' SCRATCH/rc2/cycle-added-msg.txt > SCRATCH/rc2/cycle-added-stripped.txt; sort SCRATCH/rc2/cycle-removed-stripped.txt > SCRATCH/rc2/cycle-removed-sorted.txt; sort SCRATCH/rc2/cycle-added-stripped.txt > SCRATCH/rc2/cycle-added-sorted.txt; diff SCRATCH/rc2/cycle-removed-sorted.txt SCRATCH/rc2/cycle-added-sorted.txt; grep -c -e '.' SCRATCH/rc2/cycle-removed-sorted.txt
EXIT_CODE: 0
Output Summary:
- CYCLE_BASE_SHA substituted: 254b5a5420ff37e894ed0b69f19971f4843f5214
- diff of the two sorted lists printed nothing, exit 0.
- Count: 6 (three message lines per runtime moved from the readiness module to the git-integrity module).
- Removed (sorted, verbatim):
  errors: [`${field} must be a non-empty repository-relative path.`],
  return { errors: [`${field} must stay within the workspace root.`] };
  return { errors: [`${field} must use forward slashes.`] };
  return None, [f"{field} must be a non-empty repository-relative path."]
  return None, [f"{field} must stay within the workspace root."]
  return None, [f"{field} must use forward slashes."]
- Added (sorted, verbatim): identical to the removed list.
- Spec AC11 (no error string added, removed, or reworded) holds for this cycle.
