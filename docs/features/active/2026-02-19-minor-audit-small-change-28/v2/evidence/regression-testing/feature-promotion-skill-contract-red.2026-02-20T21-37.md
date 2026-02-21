# Regression Testing Evidence — Feature Promotion Skill Contract (Red)

- Timestamp: 2026-02-20T21-37
- Command: `poetry run pytest tests/unit/test_minor_audit_mode_contract_docs.py -k "feature_promotion_lifecycle_work_mode_contract"`
- EXIT_CODE: 1

## Output Summary

The red-phase contract test failed as expected because `.github/skills/feature-promotion-lifecycle/SKILL.md` does not yet include `--work-mode` in canonical commands or explicit minor-audit output semantics.

## Failure Excerpt

```text
E       AssertionError: assert '--work-mode' in '---\nname: feature-promotion-lifecycle ...'
```
