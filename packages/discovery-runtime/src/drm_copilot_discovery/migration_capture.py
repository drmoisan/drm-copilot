"""Retain explicitly selected migration originals without altering profile scope.

The adapter preserves trusted InitializationIO ports and the accepted bootstrap
and writer algorithms. Supplemental selection is operation-local; it grants no
new profile roots, sibling reads, schema authority or publication permission.
"""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.init_io import InitializationIO
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.path_models import check_path_collisions
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.snapshot_io import SnapshotIO

if TYPE_CHECKING:
    from drm_copilot_discovery.init_projection import InitializationCapture
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import PathMetadata


def _selection(paths: tuple[str, ...], limits: ParseLimits) -> tuple[str, ...]:
    """Validate paths (exact tuple[str, ...]) under limits; return sorted selection.

    Reserve path/comparison work before normalization. Invalid types/paths raise
    ValueError; exhausted count/text/work raises ReportLimitError. No I/O occurs.
    """
    budget = ReportBudget(limits)
    if type(paths) is not tuple or len(paths) > limits.artifact_records:
        raise ReportLimitError()
    budget.work(len(paths))
    # Exact scalars prevent caller equality/iteration hooks before path checks.
    for path in paths:
        if type(path) is not str:
            raise ValueError("Migration selection requires exact path strings")
        budget.work(
            len(path) * (32 + 4 * limits.nesting_depth + len(paths).bit_length())
        )
        budget.text(path)
        if path.count("/") >= limits.nesting_depth:
            raise ReportLimitError()
    return check_path_collisions(paths)


class _Supplement:
    """Own one capture's prepaid work, raw-byte allowance and physical observations.

    Constructor receives trusted I/O, a captured base and finite ParseLimits.
    Reads remain exact and non-following. Only local dictionaries/counters change;
    failure exposes no partial capture and never changes workspace/profile state.
    """

    def __init__(
        self, io: InitializationIO, base: CapturedWorkspace, limits: ParseLimits
    ) -> None:
        """Bind io (InitializationIO), base (CapturedWorkspace), limits (ParseLimits).

        Return None; reject aggregate excess with ReportLimitError. Existing bytes
        are retained by reference; no profile setting is changed.
        """
        configured = base.snapshot.profile.limits
        self.limits = ParseLimits(
            document_bytes=min(limits.document_bytes, configured.document_bytes),
            artifact_records=min(limits.artifact_records, configured.artifact_records),
            nesting_depth=min(limits.nesting_depth, configured.nesting_depth),
        )
        self.budget = ReportBudget(self.limits)
        self.maximum_files = min(self.limits.artifact_records, configured.source_files)
        self.io, self.base = io, base
        files = base.snapshot.manifest.files
        if len(files) > self.maximum_files:
            raise ReportLimitError()
        self.budget.work(len(files) + len(base.metadata))
        self.bytes_left = self.limits.document_bytes
        # Prepay retained byte comparisons/hashes and path projection/sort costs.
        for file in files:
            self.bytes_left -= len(file.content)
            if self.bytes_left < 0:
                raise ReportLimitError()
            self.budget.work(8 * len(file.content))
            self.path_work(file.path, len(files))
        # Captured metadata keys are copied once, without linear Mapping lookups.
        for path, _ in base.metadata:
            self.path_work(path, len(base.metadata))
        # Index once so coalescing never rescans the immutable input collection.
        self.files = {file.path: file for file in files}
        self.observed: dict[str, PathMetadata] = {}

    def path_work(self, path: str, count: int) -> None:
        """Reserve path (str) work for count (int) retained rows; return None.

        Units cover character visits in prefix checks, hashing, copying and
        sorting. ReportLimitError precedes those operations; no I/O occurs.
        """
        self.budget.work(
            (len(path) + 1) * (32 + 4 * self.limits.nesting_depth + count.bit_length())
        )

    def inspect(self, path: str) -> PathMetadata:
        """Inspect exact path (str); return bounded stable physical PathMetadata.

        Reserve child-name checks/sorts before SnapshotIO traverses them. OSError
        rejects conflicting observations; resource failures propagate. Read-only.
        """
        self.path_work(path, len(self.observed))
        entry = self.io.metadata(path)
        self.budget.work(len(entry.children) + 1)
        self.path_work(entry.identity or "", 1)
        self.path_work(entry.resolved_path or "", 1)
        # Reserve namespace work before SnapshotIO validates the trusted metadata.
        for child in entry.children:
            self.path_work(child, len(entry.children))
        entry = replace(entry, children=tuple(sorted(entry.children)))
        if self.observed.setdefault(path, entry) != entry:
            raise OSError("Migration input metadata changed during capture")
        return entry

    def read(self, path: str, *, limit: int) -> bytes:
        """Read exact path under positive byte limit; return original immutable bytes.

        Reserve maximum read allocation/copy work before the trusted reader runs.
        SnapshotIO checks size/type and unchanged observations; no writes occur.
        """
        self.budget.work(limit)
        return self.io.read_bytes(path, limit=limit)

    def capture(self, paths: tuple[str, ...]) -> CapturedWorkspace:
        """Capture prevalidated paths; return complete base plus original files.

        Enforce aggregate raw bytes independently of JSON LF accounting. Limits,
        unsafe/missing/link inputs and conflicting bytes raise before return.
        Only supplied readers run; no sibling files are enumerated or opened.
        """
        self.budget.work(len(paths))
        if len(self.files) + len(paths) > self.maximum_files:
            # Identical already captured paths consume no additional file slot.
            if (
                len(self.files) + sum(path not in self.files for path in paths)
                > self.maximum_files
            ):
                raise ReportLimitError()
        reader = SnapshotIO(
            workspace_root=self.io.workspace_root,
            metadata=self.inspect,
            read_bytes=self.read,
            max_entries=self.maximum_files,
            max_depth=self.limits.nesting_depth,
        )
        # Select bounded allowances before native reads; retain only actual bytes.
        for path in paths:
            self.path_work(path, len(self.files) + len(paths))
            prior = self.files.get(path)
            available = self.bytes_left if prior is None else max(1, len(prior.content))
            allowance = min(available, self.budget.work_left // 16)
            if allowance < 1:
                raise ReportLimitError()
            content = cast("bytes", reader.read(path, limit=allowance))
            self.budget.work(8 * len(content))
            if prior is not None:
                if prior.content != content:
                    raise OSError("Migration original conflicts with captured bytes")
            else:
                self.bytes_left -= len(content)
                self.files[path] = SnapshotFile(
                    path=path, content=content, category="documentation"
                )
        reader.verify_unchanged()
        self.budget.work(len(self.files) + len(self.observed))
        manifest = replace(
            self.base.snapshot.manifest, files=tuple(self.files.values())
        )
        return replace(
            self.base, snapshot=replace(self.base.snapshot, manifest=manifest)
        )


class _MigrationIO(InitializationIO):
    """Bind one immutable supplemental selection to every accepted recapture route.

    Inherited bootstrap/require_same and guarded publication use the overridden
    capture methods. Public trusted ports retain identity; caller I/O is unchanged.
    Selection does not persist in profile fields or create native authority.
    """

    def __init__(
        self, io: InitializationIO, paths: tuple[str, ...], limits: ParseLimits
    ) -> None:
        """Clone io (InitializationIO), paths (tuple[str, ...]), limits (ParseLimits).

        Return None without I/O; store only checked selection and trusted ports.
        Binding adds no authority, mutable cache or persistent profile setting.
        """
        super().__init__(
            workspace_root=io.workspace_root,
            catalog=io.catalog,
            metadata=io.metadata,
            read_bytes=io.read_bytes,
            primitives=io.primitives,
            open_directory=io.open_directory,
            invalidate_authority=io.invalidate_authority,
            repository=io.repository,
        )
        self._selection = paths
        self._limits = limits

    def capture(
        self,
        *,
        profile_path: str,
        profile_bytes: bytes,
        directories: tuple[str, ...] = (),
    ) -> InitializationCapture:
        """Capture originals plus proposal inputs; return InitializationCapture.

        profile_path (str), profile_bytes (bytes), directories (tuple[str, ...])
        keep their accepted meanings. OSError/ValueError reject unsafe, changed or
        excessive inputs. Physical bytes/stamps remain separate from virtual ones.
        """
        original = super().capture(
            profile_path=profile_path,
            profile_bytes=profile_bytes,
            directories=directories,
        )
        supplement = _Supplement(self, original.proposal_base, self._limits)
        proposal = supplement.capture(self._selection)
        physical = dict(original.physical_metadata)
        metadata = dict(proposal.metadata)
        # Compare actual observations; preserve virtual profile/directory metadata.
        for path, entry in supplement.observed.items():
            if path in physical and physical[path] != entry:
                raise OSError("Migration original conflicts with physical observations")
            physical[path] = entry
            metadata.setdefault(path, entry)
        files = dict(original.physical_files)
        # Exact originals were checked against the proposal before physical retention.
        for path in self._selection:
            files[path] = supplement.files[path].content
        return replace(
            original,
            proposal_base=replace(
                proposal,
                metadata=tuple(metadata.items()),
                supplemental_paths=self._selection,
            ),
            physical_metadata=tuple(sorted(physical.items())),
            physical_files=tuple(sorted(files.items())),
        )

    def physical_capture(self, profile_path: str) -> CapturedWorkspace:
        """Capture actual profile_path (str) and selection; return CapturedWorkspace.

        Used by the inherited migration writer for freshness/CAS. OSError rejects
        conflicting physical observations; other input/limit failures propagate.
        Reads only trusted ports and publishes nothing.
        """
        original = super().physical_capture(profile_path)
        supplement = _Supplement(self, original, self._limits)
        result = supplement.capture(self._selection)
        metadata = dict(original.metadata)
        # No virtual entries exist here, so every duplicate observation must match.
        for path, entry in supplement.observed.items():
            if path in metadata and metadata[path] != entry:
                raise OSError("Migration original conflicts with physical capture")
            metadata[path] = entry
        return replace(
            result, metadata=tuple(metadata.items()), supplemental_paths=self._selection
        )


def bind_migration_inputs(
    io: InitializationIO, *, paths: tuple[str, ...], limits: ParseLimits
) -> InitializationIO:
    """Return io unchanged for empty paths, or a new exact-file capture adapter.

    io (InitializationIO) supplies trusted public ports; paths (tuple[str, ...])
    selects ordinary originals and limits (ParseLimits) bounds supplemental work.
    Invalid types/paths raise ValueError, excess raises ReportLimitError. Binding
    performs no I/O, mutates no collaborator and changes no persisted profile.
    """
    if not isinstance(cast("object", io), InitializationIO):
        raise ValueError("Migration requires trusted initialization I/O")
    selection = _selection(paths, limits)
    return _MigrationIO(io, selection, limits) if selection else io
