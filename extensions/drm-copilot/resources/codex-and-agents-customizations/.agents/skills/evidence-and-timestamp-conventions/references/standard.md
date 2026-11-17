# Gold Standard: evidence-and-timestamp-conventions

## Objective

Evidence storage and timestamp naming conventions for audits and remediation. Use when storing baseline/regression/QA evidence or naming audit artifacts with ISO-8601 timestamps. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Non-Overridable Authority: This skill is the single source of truth for evidence paths.
- **OB-2** ISO-8601 Timestamp Format: Use `yyyy-MM-ddTHH-mm` for all audit, remediation, and evidence artifacts.
- **OB-3** Canonical Evidence Locations: Evidence is stored in five canonical locations under the feature folder, `evidence/baseline/` for baseline evidence, `evidence/regression-testing/` for regression testing evidence, `evidence/other/` for other evidence, `evidence/qa-gates/` for QA gate evidence and `evidence/issue-updates/` for issue update mirrors, and epic rollups may mirror them under the epic root.
- **OB-4** Feature Scope (Versioned Features): In this repo, a feature may be single-version (docs at feature root) or multi-version (`v1/`, `v2/`, etc.).
- **OB-5** Canonical Evidence Discovery Order: When locating evidence artifacts for audits or plan reconciliation, the default search order for audit fidelity is the feature's `evidence/issue-updates/`, `evidence/regression-testing/`, `evidence/other/`, `evidence/qa-gates/`, `evidence/baseline/` and `evidence/remediation-baseline/` folders, then the same six folders in the same sequence under the epic root; an explicit remediation reconciliation may prefer `remediation-baseline` over `baseline` while still recording the original baseline as the authoritative audit reference, and evidence found anywhere else is recorded as non-canonical with a remediation step to move or copy it into the first applicable canonical location.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Non-Overridable Authority, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under ISO-8601 Timestamp Format, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Canonical Evidence Locations, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Feature Scope (Versioned Features), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Canonical Evidence Discovery Order, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
