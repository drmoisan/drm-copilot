# P3-T7 reproducible bounded gate harnesses

Timestamp: 2026-10-19T00-23

These throwaway harnesses execute from SCRATCH outside the workspace. They are evidence, not published runtime tools.
The native duration covers the entire multi-case composition. Individual API call durations were not measured.

## issue-980-p3t7-gate.py

SHA256: a850b2ac9cde243f154cd271b8511ce8e6904e6c60edcd139aad95aba8b3a9b5

```python
"""Record one bounded task gate with exact source bindings and sanitized output."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

sys.stdout.reconfigure(encoding="utf-8")

repo = Path.cwd()
scratch = Path(__file__).parent
feature = repo / "docs/features/active/2026-10-17-legacy-discovery-and-parity-980"
stage, label, *command = sys.argv[1:]
paths = [
    "packages/discovery-runtime/src/drm_copilot_discovery/migration_models.py",
    "packages/discovery-runtime/src/drm_copilot_discovery/migration_conversion.py",
    "packages/discovery-runtime/src/drm_copilot_discovery/migration_v1.py",
    "tests/discovery_runtime/test_migration_v1.py",
    "tests/discovery_runtime/test_migration_unknowns.py",
]

def bindings():
    return {path: {"sha256": hashlib.sha256((repo / path).read_bytes()).hexdigest(),
                   "physical_lines": len((repo / path).read_text("utf-8").splitlines())}
            for path in paths}

def sanitize(value):
    for path, replacement in [(scratch, "SCRATCH"), (repo, ".")]:
        for spelling in {str(path), path.as_posix(), str(path.resolve()), path.resolve().as_posix()}:
            value = re.sub(re.escape(spelling), lambda match: replacement, value, flags=re.I)
    value = re.sub(r"[A-Za-z]:\\[^\r\n]*?\\site-packages\\", "PYTHON_ENV/", value)
    value = re.sub(r"[A-Za-z]:\\[^\r\n]*?\\Python313\\", "PYTHON_RUNTIME/", value)
    return value

before = bindings()
started = datetime.datetime.now(datetime.timezone.utc)
timer = time.monotonic()
env = dict(os.environ, PYTHONIOENCODING="utf-8", COVERAGE_FILE=str(scratch / "issue-980-p3t7-coverage.sqlite"))
result = subprocess.run(command, cwd=repo, env=env, text=True, encoding="utf-8", errors="replace", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
duration = round(time.monotonic() - timer, 3)
finished = datetime.datetime.now(datetime.timezone.utc)
stamp = finished.strftime("%Y-%m-%dT%H-%M")
output = sanitize(result.stdout)
record = {
    "stage": int(stage), "label": label, "started": started.isoformat(), "finished": finished.isoformat(),
    "command": sanitize(subprocess.list2cmdline(command)), "exit_code": result.returncode, "duration_seconds": duration,
    "source_before": before, "source_after": bindings(), "output": output,
}
prefix = feature / "evidence/regression-testing" / (label + "." + stamp)
Path(str(prefix) + ".json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
Path(str(prefix) + ".md").write_text(
    "# " + label + "\n\nTimestamp: " + finished.isoformat() + "\nCommand: " + record["command"] +
    "\nEXIT_CODE: " + str(result.returncode) + "\nOutput Summary: " +
    ("PASS" if result.returncode == 0 else "FAIL") + " scoped P3-T7 stage " + stage +
    "; duration " + str(duration) + " seconds. Exact source hashes are in the paired JSON receipt.\n\n```text\n" +
    output.rstrip() + "\n```\n", encoding="utf-8")
sequence = scratch / "issue-980-p3t7-sequence.json"
records = json.loads(sequence.read_text("utf-8")) if sequence.exists() else []
records.append({key: value for key, value in record.items() if key != "output"})
sequence.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
print(output, end="")
print("Receipt: " + Path(str(prefix) + ".json").relative_to(repo).as_posix())
sys.exit(result.returncode)
```

## issue-980-p3t7-tests.py

SHA256: f5afabb3d100ce225e5a515a6df0ff82e322ea58a9f3e128c55e4ef03f8d2840

```python
"""Run the exact migration case population in one process and bind its order."""
import hashlib
import json
from pathlib import Path
import sys
import pytest

scratch = Path(__file__).parent
mode, *extra = sys.argv[1:]
paths = ["tests/discovery_runtime/test_migration_v1.py", "tests/discovery_runtime/test_migration_unknowns.py"]
sys.path.insert(0, str(Path.cwd()))

class Order:
    def pytest_collection_modifyitems(self, items):
        if mode == "reverse":
            items.reverse()
        content = {"mode": mode, "node_ids": [item.nodeid for item in items],
                   "files": {path: hashlib.sha256(Path(path).read_bytes()).hexdigest() for path in paths}}
        (scratch / ("issue-980-p3t7-" + mode + "-nodes.json")).write_text(json.dumps(content, indent=2) + "\n", encoding="utf-8")

sys.exit(pytest.main(["-o", "addopts=-ra", *paths, "-q", *extra], plugins=[Order()]))
```

## issue-980-p3t7-coverage-audit.py

SHA256: e7f792f9dee19b2b35beac0b68de4b15df700209e67df0fdb4e1276aa064afd7

```python
"""Compute exact new-module, class, callable and changed-line coverage from raw data."""
import ast
import hashlib
import json
from pathlib import Path
import sys

scratch = Path(__file__).parent
data = json.loads((scratch / "issue-980-p3t7-final-coverage.json").read_text("utf-8"))
rows = []
failures = []
for name, entry in sorted(data["files"].items()):
    path = Path(name)
    covered, missing = set(entry["executed_lines"]), set(entry["missing_lines"])
    measured = covered | missing
    summary = entry["summary"]
    line = 100 * len(covered) / len(measured)
    branch = 100 * summary["covered_branches"] / summary["num_branches"] if summary["num_branches"] else 100
    units = []
    tree = ast.parse(path.read_text("utf-8"))
    for node in ast.walk(tree):
        if not isinstance(node, (ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef, ast.Lambda)):
            continue
        start = min([node.lineno, *(d.lineno for d in getattr(node, "decorator_list", []))])
        end = node.end_lineno
        owned = measured & set(range(start, end + 1))
        if not owned:
            continue
        hit = owned & covered
        percent = 100 * len(hit) / len(owned)
        identifier = getattr(node, "name", "lambda") + ":" + str(node.lineno)
        units.append({"unit": identifier, "kind": type(node).__name__, "covered": len(hit), "total": len(owned), "line_percent": percent, "missing": sorted(owned - covered)})
        if percent < 90:
            failures.append(name + " " + identifier)
    physical = len(path.read_text("utf-8").splitlines())
    if line < 90 or branch < 75 or physical > 500:
        failures.append(name)
    rows.append({"path": path.as_posix(), "sha256": hashlib.sha256(path.read_bytes()).hexdigest(), "line_percent": line, "branch_percent": branch, "covered_lines": len(covered), "measured_lines": len(measured), "physical_lines": physical, "changed_line_comparison": "New file against accepted e58a61428bdf98a97f66f57f08793a743eff28f2; every executable line is new and measured", "units": units})
    print(f"PASS {name}: lines {len(covered)}/{len(measured)} ({line:.2f}%), branches {branch:.2f}%, {len(units)} class/callable ranges")
result = {"ok": not failures, "accepted_baseline": "e58a61428bdf98a97f66f57f08793a743eff28f2", "files": rows, "failures": failures}
(scratch / "issue-980-p3t7-coverage-audit.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
if failures:
    print("FAIL " + "; ".join(failures))
sys.exit(bool(failures))
```

## issue-980-p3t7-architecture.py

SHA256: 00ade34e466af292f935a19bd48237d6235ce2ea184e187b39a368f9c15e59fc

```python
"""Verify migration modules retain package and pure conversion boundaries."""
import ast
from pathlib import Path
import subprocess
import sys

root = Path.cwd()
for name in ("migration_models", "migration_conversion", "migration_v1"):
    path = root / "packages/discovery-runtime/src/drm_copilot_discovery" / (name + ".py")
    text = path.read_text("utf-8")
    tree = ast.parse(text)
    imports = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            imports.append(node.module)
        elif isinstance(node, ast.Import):
            imports.extend(alias.name for alias in node.names)
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name):
            assert node.func.id not in {"open", "exec", "eval"}, (name, node.lineno)
    assert not any(value.startswith(("scripts", "subprocess", "socket", "requests", "http", "urllib")) for value in imports), name
    assert len(text.splitlines()) <= 500, name
    if name != "migration_v1":
        assert not any(value.endswith(("init_io", "mutation_filesystem")) for value in imports), name
    print("PASS migration package/pure boundary: " + name)
for name in ("test_migration_v1", "test_migration_unknowns"):
    text = (root / "tests/discovery_runtime" / (name + ".py")).read_text("utf-8")
    assert len(text.splitlines()) <= 500, name
    assert not any(token in text for token in ("tmp_path", "tmpdir", "TemporaryDirectory", "NamedTemporaryFile", "tempfile")), name
    print("PASS in-memory test boundary: " + name)
sys.exit(subprocess.call([sys.executable, "-m", "pytest", "-o", "addopts=-ra", "tests/discovery_runtime/test_package_contract.py", "-k", "canonical_modules_do_not_import_repository_tooling", "-q"]))
```

## issue-980-p3t7-native.py

SHA256: e1b467ca331db88bb3145f692514ad387de82c2701d2d3cfc4a2d771736cc8a9

```python
"""Run bounded native migration composition outside the repository and unit tests."""
from __future__ import annotations

import json
import sys
import time
from dataclasses import replace
from hashlib import sha256
from pathlib import Path
from uuid import uuid4

from drm_copilot_discovery.catalog import V1_KINDS, load_catalog, schema_path
from drm_copilot_discovery.draft_contracts import draft_object
from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.init_projection import InitializationRequest, InitializationTemplates
from drm_copilot_discovery.migration_models import MigrationBinding, MigrationRequest, MigrationSource, MIGRATION_EXTENSION
from drm_copilot_discovery.migration_v1 import plan_migration, commit_migration
from drm_copilot_discovery.models import JsonObject, to_plain_value

repo, scratch, output = map(Path, sys.argv[1:4])
catalog = load_catalog()
templates = InitializationTemplates.load(read=lambda path: (repo / path).read_bytes())
environment = draft_object(id="characterization", platform="desktop", operating_mode="online", client_id=None, extensions=JsonObject(()))
base = scratch / ("issue-980-p3t7-native-" + uuid4().hex)
base.mkdir()
checks = []
started = time.monotonic()


def check(name, condition):
    if not condition:
        raise AssertionError(name)
    checks.append(name)
    print("PASS " + name, flush=True)


def tree(root):
    return {path.relative_to(root).as_posix(): sha256(path.read_bytes()).hexdigest()
            for path in sorted(root.rglob("*")) if path.is_file()}


def fixture(name):
    root = base / name
    (root / "application").mkdir(parents=True)
    (root / "legacy").mkdir()
    sources = []
    bindings = []
    for kind in V1_KINDS:
        filename = Path(schema_path(kind, "1.0.0")).name.replace(".schema.json", ".example.json")
        content = (repo / "examples/discovery/v1" / filename).read_bytes()
        source = MigrationSource(path="legacy/" + kind + ".json", kind=kind, content=content)
        (root / source.path).write_bytes(content)
        sources.append(source)
        bindings.append(MigrationBinding(source_id=json.loads(content)["id"], feature_ids=("feature-alpha",), environment=environment))
    request = MigrationRequest(initialization=InitializationRequest(
        system_id="synthetic-system", system_name="Synthetic system", role="combined",
        repository_id="synthetic-repository", production_roots=("application",),
        documentation_roots=("legacy",), artifact_root="docs/migration/draft-v2"),
        sources=tuple(sources), bindings=tuple(bindings))
    revocations = []
    io = InitializationIO.local(workspace_root=str(root.resolve()), lock_path=str((base / (name + ".lock")).resolve()),
                                catalog=catalog, invalidate_authority=lambda: revocations.append("revoked"))
    return root, request, io, revocations


class FailLast:
    def __init__(self, original, path):
        self.original, self.path = original, path
    def guard(self):
        return self.original.guard()
    def create_exclusive(self, target, content):
        if target.path == self.path:
            raise OSError("Controlled final publication failure")
        return self.original.create_exclusive(target, content)
    def replace_if_digest(self, target, content, *, expected_sha256):
        return self.original.replace_if_digest(target, content, expected_sha256=expected_sha256)


try:
    root, request, io, revoked = fixture("complete")
    originals = tree(root)
    plan = plan_migration(request, io=io, templates=templates)
    check("all seven kinds form a structurally valid draft", plan.mutation.validation.ok and len(plan.report["mappings"]) == 7)
    dry = commit_migration(plan, io=io, dry_run=True)
    check("dry run preserves exact original tree and authority", dry.ok and tree(root) == originals and not revoked and not (root / "docs").exists())
    result = commit_migration(plan, io=io)
    if not result.ok:
        raise AssertionError("native publication: " + str(result.error))
    check("native guarded publication reports every created artifact", result.publication is not None and all(item.status == "created" for item in result.publication.artifacts))
    check("original bytes survive native publication", all(tree(root)[path] == digest for path, digest in originals.items()))
    report_path = plan.mutation.baseline.snapshot.profile.artifacts["reports"] + "/migration-report.json"
    persisted = json.loads((root / report_path).read_bytes())
    check("persisted report remains an immutable projection", persisted == to_plain_value(plan.report) and persisted["extensions"][MIGRATION_EXTENSION]["publication"] == "projection-only")
    check("mapped output hashes match exact native bytes", all(sha256((root / item["new_path"]).read_bytes()).hexdigest() == item["new_sha256"] for item in persisted["mappings"]))
    before = tree(root)
    repeat = plan_migration(request, io=io, templates=templates)
    repeated = commit_migration(repeat, io=io)
    check("exact repeat skips publication without changing bytes", repeated.ok and repeated.publication is not None and all(item.status == "skipped" for item in repeated.publication.artifacts) and tree(root) == before)
    check("repeat preserves identical immutable mapping", repeat.report == plan.report)
    path = root / persisted["mappings"][0]["new_path"]
    path.write_bytes(path.read_bytes() + b" ")
    conflicting = tree(root)
    try:
        plan_migration(request, io=io, templates=templates)
    except ValueError:
        check("different existing output fails without overwrite", tree(root) == conflicting)
    else:
        raise AssertionError("Different destination bytes were accepted")

    root, request, io, revoked = fixture("partial")
    originals = tree(root)
    plan = plan_migration(request, io=io, templates=templates)
    blocked_path = plan.mutation.baseline.snapshot.profile.artifacts["unspecified_behaviors"]
    io.primitives = FailLast(io.primitives, blocked_path)
    result = commit_migration(plan, io=io)
    check("controlled native partial publication returns failure", not result.ok and result.publication is not None and any(item.status == "created" for item in result.publication.artifacts) and any(item.status == "conflict" for item in result.publication.artifacts))
    check("partial failure retains uncertainty and originals", blocked_path in result.uncertain_paths and all(tree(root)[path] == digest for path, digest in originals.items()))
    persisted = json.loads((root / report_path).read_bytes())
    check("persisted report never claims partial completion", persisted["result"] == "pass" and persisted["extensions"][MIGRATION_EXTENSION]["publication"] == "projection-only" and all(item["status"] == "planned" for item in persisted["mappings"]) and result.report["result"] == "fail")
    check("migration never activates the draft root", not any(base.rglob("activation.json")) and result.report["activation_switched"] is False)
    data = {"ok": True, "checks": checks, "duration_seconds": round(time.monotonic() - started, 3), "platform": sys.platform,
            "native_provider": "InitializationIO.local", "partial_failure": "Injected final primitive refusal; other operations use native provider", "scratch": "SCRATCH", "source_files": len(originals)}
except Exception as error:
    data = {"ok": False, "checks": checks, "duration_seconds": round(time.monotonic() - started, 3), "error": str(error).replace(str(base), "SCRATCH"), "scratch": "SCRATCH"}
    output.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    raise
output.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
```
