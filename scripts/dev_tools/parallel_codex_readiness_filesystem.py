"""Load guarded repository evidence for explicit parallel Codex readiness."""

from __future__ import annotations

import hashlib
import json
import re
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Protocol, cast

from scripts.dev_tools.parallel_kickoff_contract import parse_parallel_kickoff
from scripts.dev_tools.pr_context.git import CommandRunner, SubprocessRunner
from scripts.dev_tools.validate_parallel_codex_readiness import (
    ParallelCodexReadinessEvidence,
    validate_zero_lost_ledger,
)

_HASH_RE = re.compile(r"^[0-9a-fA-F]{40,64}$")
_DRIVE_RE = re.compile(r"^[A-Za-z]:")
_RECEIPT_PATH_KEYS = (
    "authority_receipt_path",
    "delegation_receipt_path",
    "topology_receipt_path",
    "model_routing_receipt_path",
)


class ParallelReadinessFileSystem(Protocol):
    """Read-only filesystem surface used by the evidence loader."""

    def is_file(self, path: Path) -> bool: ...

    def read_text(self, path: Path) -> str: ...


class LocalParallelReadinessFileSystem:
    """Production filesystem adapter backed by ``pathlib``."""

    def is_file(self, path: Path) -> bool:
        """Return whether ``path`` is a regular file."""

        return path.is_file()

    def read_text(self, path: Path) -> str:
        """Read UTF-8 text from ``path``."""

        return path.read_text(encoding="utf-8")


class ParallelReadinessGitRepository(Protocol):
    """Focused Git queries required to bind the committed kickoff."""

    def resolve_commit(self, ref: str) -> str | None: ...

    def committed_blob_hash(self, ref: str, path: str) -> str | None: ...

    def worktree_blob_hash(self, path: str) -> str | None: ...


class GitParallelReadinessRepository:
    """Git-backed kickoff identity adapter with an injectable runner."""

    def __init__(
        self, workspace_root: Path, runner: CommandRunner | None = None
    ) -> None:
        self._root = workspace_root
        self._runner = runner or SubprocessRunner()

    def _run(self, arguments: Sequence[str]) -> tuple[int, str]:
        result = self._runner.run(["git", *arguments], cwd=self._root, allow_error=True)
        return result.code, result.stdout.strip()

    def resolve_commit(self, ref: str) -> str | None:
        """Resolve ``ref`` to its exact commit object identity."""

        code, output = self._run(["rev-parse", "--verify", f"{ref}^{{commit}}"])
        return output.lower() if code == 0 and _HASH_RE.fullmatch(output) else None

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        """Return the Git blob identity for ``path`` at ``ref``."""

        code, output = self._run(["rev-parse", "--verify", f"{ref}:{path}"])
        return output.lower() if code == 0 and _HASH_RE.fullmatch(output) else None

    def worktree_blob_hash(self, path: str) -> str | None:
        """Return the Git blob identity for the worktree file."""

        code, output = self._run(["hash-object", "--", path])
        return output.lower() if code == 0 and _HASH_RE.fullmatch(output) else None


@dataclass(frozen=True)
class ParallelReadinessFileContext:
    """Injected repository context for file-backed parallel evidence."""

    workspace_root: Path
    artifact_path: Path
    file_system: ParallelReadinessFileSystem
    git: ParallelReadinessGitRepository


@dataclass(frozen=True)
class ParallelReadinessBuildResult:
    """Evidence assembled from guarded paths plus deterministic loader errors."""

    evidence: ParallelCodexReadinessEvidence | None
    errors: tuple[str, ...]


def build_parallel_readiness_file_context(
    workspace_root: Path,
    artifact_path: Path,
    *,
    file_system: ParallelReadinessFileSystem | None = None,
    git: ParallelReadinessGitRepository | None = None,
    runner: CommandRunner | None = None,
) -> ParallelReadinessFileContext:
    """Build the production context while retaining injectable test seams."""

    root = workspace_root.absolute()
    path = artifact_path if artifact_path.is_absolute() else root / artifact_path
    return ParallelReadinessFileContext(
        workspace_root=root,
        artifact_path=path,
        file_system=file_system or LocalParallelReadinessFileSystem(),
        git=git or GitParallelReadinessRepository(root, runner),
    )


def _guarded_path(value: object) -> str | None:
    """Normalize a repository-relative POSIX path or reject it."""

    if (
        not isinstance(value, str)
        or not value.strip()
        or "\\" in value
        or value.startswith("/")
        or _DRIVE_RE.match(value) is not None
    ):
        return None
    path = PurePosixPath(value)
    if any(part in (".", "..") for part in path.parts):
        return None
    return path.as_posix()


def _read_json(
    context: ParallelReadinessFileContext,
    relative: str,
    *,
    label: str,
    errors: list[str],
) -> object:
    """Read one required JSON document without allowing I/O to escape."""

    path = context.workspace_root / Path(relative)
    if not context.file_system.is_file(path):
        errors.append(f"{label} is missing at {relative!r}.")
        return None
    try:
        return cast("object", json.loads(context.file_system.read_text(path)))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        errors.append(f"{label} at {relative!r} is not valid JSON: {exc}.")
        return None


def _build_kickoff_identity(
    state: Mapping[str, object],
    context: ParallelReadinessFileContext,
    errors: list[str],
) -> Mapping[str, object] | None:
    """Load and bind the conventional kickoff to its plan-home Git ref."""

    relative = _guarded_path(state.get("kickoff_prompt_path"))
    if relative is None:
        errors.append(
            "Parallel checkpoint kickoff_prompt_path must be a guarded "
            "repository-relative path."
        )
        return None
    slug = state.get("parallel_slug")
    expected_path = f"docs/features/parallel/{slug}/parallel-kickoff.md"
    if relative != expected_path:
        errors.append(
            "Parallel checkpoint kickoff_prompt_path must be "
            f"{expected_path!r}; found: {relative!r}."
        )
        return None
    path = context.workspace_root / Path(relative)
    if not context.file_system.is_file(path):
        errors.append(f"Parallel committed kickoff is missing at {relative!r}.")
        return None
    try:
        text = context.file_system.read_text(path)
    except (OSError, UnicodeError) as exc:
        errors.append(
            f"Parallel committed kickoff at {relative!r} could not be read: {exc}."
        )
        return None
    parsed, parse_errors = parse_parallel_kickoff(text)
    errors.extend(parse_errors)
    if parsed is None:
        return None
    expected_manifest = f"docs/features/parallel/{slug}/parallel.md"
    expected_branch = f"parallel/{slug}-plan"
    if parsed.slug != slug or parsed.invocation_slug != slug:
        errors.append(
            "Parallel committed kickoff slug identities must match checkpoint "
            "parallel_slug."
        )
    if parsed.manifest_path != expected_manifest:
        errors.append(
            f"Parallel committed kickoff manifest must be {expected_manifest!r}."
        )
    if parsed.plan_home_branch != expected_branch:
        errors.append(
            f"Parallel committed kickoff plan-home branch must be {expected_branch!r}."
        )
    if parsed.planning_commit is None:
        errors.append("Parallel committed kickoff planning_commit is required.")
        return None
    ref = f"origin/{expected_branch}"
    if context.git.resolve_commit(ref) != parsed.planning_commit:
        errors.append(f"Parallel committed kickoff planning_commit must match {ref}.")
    committed = context.git.committed_blob_hash(ref, relative)
    worktree = context.git.worktree_blob_hash(relative)
    if committed is None or worktree is None or committed != worktree:
        errors.append(
            "Parallel committed kickoff worktree content must match the "
            "plan-home ref blob."
        )
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return {
        "schema_version": 1,
        "path": relative,
        "plan_home_ref": ref,
        "planning_commit": parsed.planning_commit,
        "blob_sha256": digest,
        "worktree_sha256": digest,
    }


def build_parallel_codex_readiness_evidence(
    text: str, context: ParallelReadinessFileContext
) -> ParallelReadinessBuildResult:
    """Load guarded launch, status, receipt, ledger, and kickoff evidence."""

    try:
        value = cast("object", json.loads(text))
    except json.JSONDecodeError:
        return ParallelReadinessBuildResult(None, ())
    if not isinstance(value, Mapping):
        return ParallelReadinessBuildResult(None, ())
    state = cast("Mapping[str, object]", value)
    errors: list[str] = []
    launch_records: dict[str, object] = {}
    status_records: dict[str, object] = {}
    receipt_records: dict[str, object] = {}
    ledger: object = None
    normalized_ledger: str | None = None
    items_value = state.get("items")
    items = cast("list[object]", items_value) if isinstance(items_value, list) else []
    for index, item_value in enumerate(items):
        if not isinstance(item_value, Mapping):
            continue
        item = cast("Mapping[str, object]", item_value)
        item_context = f"Parallel checkpoint items[{index}]"
        launch_path = _guarded_path(item.get("launch_receipt_path"))
        status_path = _guarded_path(item.get("launch_status_path"))
        if launch_path is None or status_path is None:
            errors.append(
                f"{item_context} launch/status paths must be guarded "
                "repository-relative paths."
            )
            continue
        launch = _read_json(
            context, launch_path, label=f"{item_context} launch record", errors=errors
        )
        status = _read_json(
            context, status_path, label=f"{item_context} launch status", errors=errors
        )
        launch_records[launch_path] = launch
        status_records[status_path] = status
        if not isinstance(launch, Mapping):
            continue
        record = cast("Mapping[str, object]", launch)
        if record.get("launch_receipt_path") not in (None, launch_path):
            errors.append(f"{item_context} launch record path binding is mismatched.")
        if record.get("launch_status_path") != status_path:
            errors.append(f"{item_context} launch status path binding is mismatched.")
        status_record = (
            cast("Mapping[str, object]", status)
            if isinstance(status, Mapping)
            else None
        )
        if (
            status_record is not None
            and status_record.get("launch_receipt_path") != launch_path
        ):
            errors.append(
                f"{item_context} launch status receipt binding is mismatched."
            )
        current_ledger = record.get("enforceability_ledger")
        normalized = json.dumps(
            current_ledger, sort_keys=True, separators=(",", ":"), ensure_ascii=False
        )
        if normalized_ledger is None:
            normalized_ledger = normalized
            ledger = current_ledger
        elif normalized != normalized_ledger:
            errors.append(
                "Parallel launch records must carry one identical normalized "
                "enforceability ledger."
            )
        for key in _RECEIPT_PATH_KEYS:
            receipt_path = _guarded_path(record.get(key))
            if receipt_path is None:
                errors.append(
                    f"{item_context} {key} must be a guarded repository-relative path."
                )
                continue
            receipt_records[receipt_path] = _read_json(
                context,
                receipt_path,
                label=f"{item_context} {key}",
                errors=errors,
            )
    errors.extend(validate_zero_lost_ledger(ledger, context="Parallel checkpoint"))
    kickoff_identity = _build_kickoff_identity(state, context, errors)
    evidence = ParallelCodexReadinessEvidence(
        launch_records=launch_records,
        status_records=status_records,
        receipt_records=receipt_records,
        enforceability_ledger=ledger,
        kickoff_identity=kickoff_identity,
    )
    return ParallelReadinessBuildResult(evidence, tuple(errors))
