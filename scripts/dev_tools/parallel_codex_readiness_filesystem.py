"""Load guarded repository evidence for explicit parallel Codex readiness.

Purpose and usage:
    Assemble launch, status, routing-receipt, ledger, and committed-kickoff
    evidence from repository-relative paths for the pure readiness validator.
    Callers build an injectable context, then pass checkpoint JSON to the public
    builder.

Flow and invariants:
    Guard every supplied path, read JSON through the filesystem boundary, bind
    kickoff content to its plan-home Git ref, normalize one shared ledger, and
    return evidence plus deterministic errors. No path may escape the workspace.

Raises and side effects:
    Pure helpers raise nothing. Concrete adapters may read the filesystem or run
    read-only Git commands and can propagate adapter-specific I/O errors where
    their method contracts state so. No function mutates caller-owned input.
"""

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
    """Define the read-only storage boundary used by the evidence loader.

    Implementations answer file existence and UTF-8 text reads only. Callers
    inject one into ``ParallelReadinessFileContext``; the loader controls path
    construction and ordering. Paths must already be workspace-contained.
    Implementations may perform read I/O but must not mutate storage.
    """

    def is_file(self, path: Path) -> bool:
        """Check guarded ``path``; return file status after read-only metadata I/O."""

        ...

    def read_text(self, path: Path) -> str:
        """Read guarded ``path``; return text or raise an I/O/decoding error."""

        ...


class LocalParallelReadinessFileSystem:
    """Provide production read-only filesystem access through ``pathlib``.

    The adapter is stateless: construct once or per context, then let the loader
    call ``is_file`` before ``read_text``. It preserves caller paths and performs
    only local metadata and UTF-8 read I/O; containment remains the loader's
    responsibility.
    """

    def is_file(self, path: Path) -> bool:
        """Check guarded ``path``; return ``Path.is_file`` after metadata I/O."""

        return path.is_file()

    def read_text(self, path: Path) -> str:
        """Read guarded ``path``; return UTF-8 text or raise its read error."""

        return path.read_text(encoding="utf-8")


class ParallelReadinessGitRepository(Protocol):
    """Define read-only Git identity queries for committed-kickoff binding.

    Implementations resolve commits and blob hashes only. The loader supplies
    guarded refs and paths, compares returned identities, and treats ``None`` as
    unresolved evidence. Implementations may invoke Git but must not mutate the
    index, worktree, refs, or repository configuration.
    """

    def resolve_commit(self, ref: str) -> str | None:
        """Resolve ``ref``; return its hash or None after read-only Git I/O."""

        ...

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        """Resolve ``path`` at ``ref``; return its hash or None via read-only Git."""

        ...

    def worktree_blob_hash(self, path: str) -> str | None:
        """Hash worktree ``path``; return its hash or None without index writes."""

        ...


def _normalize_git_hash_result(code: int, output: str) -> str | None:
    """Use ``code`` and trimmed ``output``; return a lowercase hash or None."""

    # Trust output only when both command success and hash shape agree.
    if code != 0 or _HASH_RE.fullmatch(output) is None:
        return None
    return output.lower()


class GitParallelReadinessRepository:
    """Provide read-only kickoff identity queries through an injected runner.

    Construct with the repository root and optionally a fake runner for tests.
    Each public query runs one allowed Git command, then validates and normalizes
    stdout. The root and runner remain fixed; commands use ``allow_error`` and
    never mutate repository state.
    """

    def __init__(
        self, workspace_root: Path, runner: CommandRunner | None = None
    ) -> None:
        """Store ``workspace_root`` and optional ``runner``; return None, no I/O."""

        self._root = workspace_root
        self._runner = runner or SubprocessRunner()

    def _run(self, arguments: Sequence[str]) -> tuple[int, str]:
        """Run Git ``arguments``; return code/trimmed stdout after process I/O."""

        result = self._runner.run(["git", *arguments], cwd=self._root, allow_error=True)
        return result.code, result.stdout.strip()

    def resolve_commit(self, ref: str) -> str | None:
        """Resolve ``ref``; return its lowercase commit hash or None."""

        code, output = self._run(["rev-parse", "--verify", f"{ref}^{{commit}}"])
        return _normalize_git_hash_result(code, output)

    def committed_blob_hash(self, ref: str, path: str) -> str | None:
        """Resolve ``path`` at ``ref``; return its lowercase blob hash or None."""

        code, output = self._run(["rev-parse", "--verify", f"{ref}:{path}"])
        return _normalize_git_hash_result(code, output)

    def worktree_blob_hash(self, path: str) -> str | None:
        """Hash worktree ``path``; return lowercase identity or None, no writes."""

        code, output = self._run(["hash-object", "--", path])
        return _normalize_git_hash_result(code, output)


@dataclass(frozen=True)
class ParallelReadinessFileContext:
    """Carry immutable dependencies for file-backed readiness loading.

    Construct through ``build_parallel_readiness_file_context`` and pass to the
    evidence builder. ``workspace_root`` contains all guarded reads;
    ``artifact_path`` identifies the checkpoint; adapters provide read-only
    file and Git access. Construction itself has no side effect.
    """

    workspace_root: Path
    artifact_path: Path
    file_system: ParallelReadinessFileSystem
    git: ParallelReadinessGitRepository


@dataclass(frozen=True)
class ParallelReadinessBuildResult:
    """Carry assembled evidence and deterministic loader errors.

    The builder returns one instance per checkpoint parse. ``evidence`` is None
    only when checkpoint JSON cannot produce a mapping; otherwise it contains
    partial guarded evidence even when ``errors`` is non-empty. The frozen value
    has no behavior or side effects after construction.
    """

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
    """Build an immutable loader context with injectable read boundaries.

    Args:
        workspace_root (Path): Repository root containing all evidence.
        artifact_path (Path): Absolute or workspace-relative checkpoint path.
        file_system: Optional read-only filesystem adapter.
        git: Optional read-only Git adapter; takes precedence over ``runner``.
        runner: Optional runner used only when constructing the default Git adapter.

    Returns:
        ParallelReadinessFileContext: Absolute root/path and selected adapters.
    """

    # Resolve paths once so every later guarded read shares the same root boundary.
    root = workspace_root.absolute()
    path = artifact_path if artifact_path.is_absolute() else root / artifact_path
    return ParallelReadinessFileContext(
        workspace_root=root,
        artifact_path=path,
        file_system=file_system or LocalParallelReadinessFileSystem(),
        git=git or GitParallelReadinessRepository(root, runner),
    )


def _guarded_path(value: object) -> str | None:
    """Validate ``value`` and return a normalized relative POSIX path or None."""

    # Reject non-text, blank, host-specific, and absolute forms before parsing.
    if (
        not isinstance(value, str)
        or not value.strip()
        or "\\" in value
        or value.startswith("/")
        or _DRIVE_RE.match(value) is not None
    ):
        return None
    path = PurePosixPath(value)
    # Dot segments can change containment semantics and are never canonical evidence.
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
    """Read guarded JSON and append labeled errors instead of parse exceptions.

    Args:
        context: Injected repository dependencies.
        relative (str): Guarded repository-relative path.
        label (str): Human-readable evidence identity.
        errors (list[str]): Mutable ordered diagnostic accumulator.

    Returns:
        object: Parsed JSON value, or None after a missing/read/parse error.

    Side effects:
        Reads one file and appends diagnostics to ``errors``.
    """

    path = context.workspace_root / Path(relative)
    # Missing evidence gets a stable diagnostic without attempting a read.
    if not context.file_system.is_file(path):
        errors.append(f"{label} is missing at {relative!r}.")
        return None
    # Convert expected adapter and JSON failures into deterministic validation errors.
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
    """Load the kickoff and bind its path, content, and Git identities.

    Args:
        state: Parsed checkpoint mapping.
        context: Injected repository dependencies.
        errors: Mutable ordered diagnostic accumulator.

    Returns:
        Mapping[str, object] | None: Bound identity evidence, or None when a
        prerequisite prevents safe construction.

    Side effects:
        Reads kickoff text, runs read-only Git queries, and appends errors.
    """

    # Establish the checkpoint-selected path before any repository access.
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
    # Read and parse only the single conventional kickoff path.
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
    # Bind parsed identities to the checkpoint slug and conventional plan-home ref.
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
    # Compare committed and worktree identities before returning trusted evidence.
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
    """Assemble guarded evidence and deterministic loader diagnostics.

    Args:
        text (str): Serialized checkpoint JSON.
        context: Injected repository and artifact context.

    Returns:
        ParallelReadinessBuildResult: Partial evidence plus ordered errors, or
        no evidence for syntactically invalid/non-mapping checkpoint input.

    Side effects:
        Performs guarded file reads and read-only Git queries through adapters.
    """

    # Reject unreadable root input without duplicating the owning schema diagnostics.
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
    # Load each readable item's launch/status records and shared receipt references.
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
        # Cross-bind launch and status records before accepting their ledger.
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
        # The first ledger becomes canonical; every later item must match it exactly.
        if normalized_ledger is None:
            normalized_ledger = normalized
            ledger = current_ledger
        elif normalized != normalized_ledger:
            errors.append(
                "Parallel launch records must carry one identical normalized "
                "enforceability ledger."
            )
        # Load each required authority receipt under its guarded persisted path.
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
    # Complete cross-record validation only after all item evidence is assembled.
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
