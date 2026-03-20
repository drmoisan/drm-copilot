Final QA Command Manifest

[P3-T1]
Command: npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-format.md

[P3-T2]
Command: npm --prefix extensions/drm-copilot run lint
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-lint.md

[P3-T3]
Command: npm --prefix extensions/drm-copilot run typecheck
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-typecheck.md

[P3-T4]
Command: npm --prefix extensions/drm-copilot run test:unit
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/ts-test-unit.md

[P3-T5]
Command: poetry run black --check .
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-format.md

[P3-T6]
Command: poetry run ruff check
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-lint.md

[P3-T7]
Command: poetry run pyright
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-typecheck.md

[P3-T8]
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
Evidence File: docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/qa-gates/py-test-cov.md
