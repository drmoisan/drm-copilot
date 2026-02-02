from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.atomic_executor.plan_parser import PlanParser

plan_path = Path(
    "docs/features/active/2026-02-01-extension-code-barrier-2/plan.2026-02-01T11-35.md"
)
parser = PlanParser(plan_path)
model = parser.parse()

for task in model.tasks:
    if task.task_id == "P1-T1":
        print(f"Task: {task.task_id}")
        print(f"Title: {task.title}")
        print(f"Expect Fail: {task.expect_fail}")
        print(f"Test Ref: {task.test_ref}")
