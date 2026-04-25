Timestamp: 2026-04-05T14-15
Scope: extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py

Bundled-runtime delta mirrored from the fixed root script:
- Added `FEATURE_LABEL_COLOR` and `FEATURE_LABEL_DESCRIPTION` constants.
- Added `GhClient.ensure_label` to the bundled protocol.
- Added `RealGhClient.ensure_label()` to create the missing `feature` label.
- Added `_is_missing_label_failure()` helper for the known gh error text.
- Added the single-retry recovery branch in `promote_potential()` for `promotion_type == "feature"`.
- Confirmed `extensions/drm-copilot/resources/templates/potential_to_issue.py` already delegates to the bundled runtime without needing wrapper changes.
