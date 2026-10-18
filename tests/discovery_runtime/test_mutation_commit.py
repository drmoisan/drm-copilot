"""Exercise guarded mutation races and partial failures with memory-only writers."""

from __future__ import annotations

from contextlib import contextmanager
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, commit_mutation
from drm_copilot_discovery.mutation_plan import MutationError, plan_mutation

from tests.discovery_runtime.mutation_test_support import (
    capture,
    collection_change,
    grants_for,
    mutation_case,
    role_plan,
)
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Generator

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, PlannedWrite
    from drm_copilot_discovery.path_models import ResolvedPath

    from tests.discovery_runtime.test_snapshot_io import MemoryStore


class MemoryWriter:
    """Model an atomic guarded adapter with explicit failpoints and local storage.

    Each instance owns its memory store; callbacks simulate races only at named
    I/O boundaries. No filesystem, process, network or global mutable state exists.
    """

    def __init__(self, store: MemoryStore, catalog: SchemaCatalog) -> None:
        """Bind one test store and observable counters/failure controls."""
        self.store, self.catalog = store, catalog
        self.attempts = 0
        self.invalidations = 0
        self.fail_at = 0
        self.fail_after = False
        self.fail_invalidation = False
        self.before_write: Callable[[], None] | None = None
        self.after_write: Callable[[], None] | None = None

    def capture(self) -> CapturedWorkspace:
        """Use actual runtime loading for every before/after complete-state check."""
        return capture(self.store, self.catalog)

    def invalidate_authority(self) -> None:
        """Record revocation or an explicit simulated protected-store failure."""
        self.invalidations += 1
        if self.fail_invalidation:
            raise OSError("authority store unavailable")

    def atomic_write(self, write: PlannedWrite, *, expected: CapturedWorkspace) -> None:
        """Exercise the concrete production safety algorithm over memory primitives."""
        GuardedMutationWriter(
            capture=self.capture,
            invalidate_authority=self.invalidate_authority,
            primitives=self,
        ).atomic_write(write, expected=expected)

    @contextmanager
    def guard(self) -> Generator[None, None, None]:
        """Inject concurrency immediately before acquiring the modeled guard."""
        self.attempts += 1
        if self.before_write is not None:
            self.before_write()
        yield

    def create_exclusive(self, target: ResolvedPath, content: bytes) -> None:
        """Reject existing entries even when their content is identical."""
        if target.path in self.store.files:
            raise FileExistsError("atomic creation collision")
        self._publish(target.path, content)

    def replace_if_digest(
        self, target: ResolvedPath, content: bytes, *, expected_sha256: str
    ) -> None:
        """Model the final digest check inside guarded atomic replacement."""
        if sha256(self.store.files[target.path]).hexdigest() != expected_sha256:
            raise FileExistsError("atomic content precondition changed")
        self._publish(target.path, content)

    def _publish(self, path: str, content: bytes) -> None:
        """Expose bounded before/after commit failures and unrelated side effects."""
        if self.attempts == self.fail_at and not self.fail_after:
            raise OSError("injected write failure")
        self.store.put(path, content)
        if self.after_write is not None:
            self.after_write()
        if self.attempts == self.fail_at and self.fail_after:
            raise OSError("injected uncertain acknowledgement")


def test_commit_creates_all_outputs_and_preserves_unrelated_bytes(
    mutation_catalog: SchemaCatalog,
) -> None:
    """A valid role mutation creates a new parent safely and revokes old authority."""
    store, baseline = mutation_case(mutation_catalog)
    changes, context = role_plan(baseline)
    plan = plan_mutation(
        baseline, changes, grants=grants_for(*changes), invocation=context
    )
    before = dict(store.files)
    writer = MemoryWriter(store, mutation_catalog)
    boundary = GuardedMutationWriter(
        capture=writer.capture,
        invalidate_authority=writer.invalidate_authority,
        primitives=writer,
    )
    result = commit_mutation(plan, writer=boundary)
    assert result.ok, result.findings
    assert writer.attempts == 2 and writer.invalidations == 1
    assert result.authority_invalidated and not result.uncertain_paths
    # Both exact outputs must be reported, with every unrelated captured byte preserved.
    assert all(item.status == "created" for item in result.artifacts)
    # Compare the whole original byte set rather than checking a selected sentinel
    # alone.
    assert all(store.files[path] == content for path, content in before.items())
    assert result.validation.input_sha256 == plan.prospective.sha256


def test_digest_matched_replacement_and_unchanged_skip(
    mutation_catalog: SchemaCatalog,
) -> None:
    """An authored collection can change formatting without changing identity."""
    store, baseline = mutation_case(mutation_catalog)
    original = collection_change(baseline)
    store.put(original.path, original.content)
    baseline = capture(store, mutation_catalog)
    change = replace(collection_change(baseline), content=original.content + b"\n")
    writer = MemoryWriter(store, mutation_catalog)
    result = commit_mutation(
        plan_mutation(baseline, (change,), grants=grants_for(change)), writer=writer
    )
    assert result.ok and result.artifacts[0].status == "updated"
    baseline = writer.capture()
    unchanged = replace(
        change, expected_sha256=baseline.snapshot.file(change.path).sha256
    )
    result = commit_mutation(
        plan_mutation(baseline, (unchanged,), grants=grants_for(unchanged)),
        writer=writer,
    )
    assert result.ok and result.artifacts[0].status == "skipped"
    assert writer.attempts == 1 and writer.invalidations == 1
    assert not result.authority_invalidated


def test_repeatable_dry_run_has_no_writes_directories_or_revocations(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Repeated plans return identical projected output without any writable action."""
    store, baseline = mutation_case(mutation_catalog)
    changes, context = role_plan(baseline)
    plan = plan_mutation(
        baseline, changes, grants=grants_for(*changes), invocation=context
    )
    writer = MemoryWriter(store, mutation_catalog)
    before = (dict(store.files), dict(store.metadata.entries))
    first = commit_mutation(plan, writer=writer, dry_run=True)
    second = commit_mutation(plan, writer=writer, dry_run=True)
    assert first == second and first.ok
    assert (store.files, store.metadata.entries) == before
    assert writer.attempts == writer.invalidations == 0


@pytest.mark.parametrize(
    "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
)
def test_stale_complete_inputs_and_parent_changes_block_before_writes(
    race: str, mutation_catalog: SchemaCatalog
) -> None:
    """The complete read set detects changes beyond the destination's own digest."""
    store, baseline = mutation_case(mutation_catalog)
    store.put("docs/migration/notes.md", b"original")
    baseline = writer_baseline = capture(store, mutation_catalog)
    change = collection_change(baseline)
    plan = plan_mutation(baseline, (change,), grants=grants_for(change))
    # Inject one kind of input drift after planning and before the writer captures
    # again.
    if race == "bytes":
        store.files["docs/migration/notes.md"] = b"changed"
    elif race == "addition":
        store.put("docs/migration/added.md", b"added")
    elif race == "deletion":
        store.metadata.remove("docs/migration/notes.md")
        store.files.pop("docs/migration/notes.md")
    elif race == "identity":
        entry = store.metadata.entries["docs/migration/notes.md"]
        store.metadata.entries["docs/migration/notes.md"] = replace(
            entry, identity="replacement"
        )
    elif race == "parent":
        entry = store.metadata.entries["docs/migration"]
        store.metadata.entries["docs/migration"] = replace(
            entry, kind="symlink", children=()
        )
    else:
        store.put(change.path, change.content)
    before = dict(store.files)
    writer = MemoryWriter(store, mutation_catalog)
    result = commit_mutation(plan, writer=writer)
    assert not result.ok and writer.attempts == 0 and result.authority_invalidated
    assert (
        store.files == before
        and writer_baseline.snapshot.sha256 == plan.baseline.snapshot.sha256
    )


def test_atomic_guard_closes_race_after_python_freshness_check(
    mutation_catalog: SchemaCatalog,
) -> None:
    """The atomic guard preserves a concurrently created destination."""
    store, baseline = mutation_case(mutation_catalog)
    change = collection_change(baseline)
    writer = MemoryWriter(store, mutation_catalog)
    writer.before_write = lambda: store.put(change.path, change.content + b"\n")
    result = commit_mutation(
        plan_mutation(baseline, (change,), grants=grants_for(change)), writer=writer
    )
    assert not result.ok and writer.attempts == 1
    assert store.files[change.path] == change.content + b"\n"
    assert change.path in result.uncertain_paths


@pytest.mark.parametrize("after", [False, True])
def test_partial_failure_stops_remaining_writes_and_reports_uncertainty(
    after: bool, mutation_catalog: SchemaCatalog
) -> None:
    """Earlier writes and the failed attempt remain explicit without rollback."""
    store, baseline = mutation_case(mutation_catalog)
    changes = (collection_change(baseline), collection_change(baseline, decisions=True))
    plan = plan_mutation(baseline, changes, grants=grants_for(*changes))
    writer = MemoryWriter(store, mutation_catalog)
    writer.fail_at, writer.fail_after = 2, after
    result = commit_mutation(plan, writer=writer)
    assert not result.ok and result.authority_invalidated
    # Earlier success remains visible when the next publication fails or loses
    # acknowledgement.
    assert [item.status for item in result.artifacts] == ["created", "conflict"]
    assert plan.writes[0].change.path in store.files
    assert (plan.writes[1].change.path in store.files) is after
    assert result.uncertain_paths == (plan.writes[1].change.path,)
    assert writer.attempts == 2


@pytest.mark.parametrize("effect", ["bytes", "identity"])
def test_unexpected_adapter_side_effects_cannot_report_success(
    effect: str, mutation_catalog: SchemaCatalog
) -> None:
    """Postchecks detect unrelated content and same-byte identity changes."""
    store, _ = mutation_case(mutation_catalog)
    store.put("docs/migration/notes.md", b"original")
    baseline = capture(store, mutation_catalog)
    change = collection_change(baseline)
    writer = MemoryWriter(store, mutation_catalog)

    def disturb() -> None:
        """Inject one explicit nonconforming adapter side effect in memory."""
        # Byte changes and same-byte identity replacement exercise independent
        # postconditions.
        if effect == "bytes":
            store.files["docs/migration/notes.md"] = b"unexpected"
        else:
            store.metadata.entries["docs/migration/notes.md"] = replace(
                store.metadata.entries["docs/migration/notes.md"], identity="unexpected"
            )

    writer.after_write = disturb
    result = commit_mutation(
        plan_mutation(baseline, (change,), grants=grants_for(change)), writer=writer
    )
    assert not result.ok and result.authority_invalidated
    assert change.path in result.uncertain_paths


def test_authority_failure_prevents_every_write(
    mutation_catalog: SchemaCatalog,
) -> None:
    """A protected-store failure cannot leave an apparently revoked state."""
    store, baseline = mutation_case(mutation_catalog)
    change = collection_change(baseline)
    writer = MemoryWriter(store, mutation_catalog)
    writer.fail_invalidation = True
    before = dict(store.files)
    result = commit_mutation(
        plan_mutation(baseline, (change,), grants=grants_for(change)), writer=writer
    )
    assert not result.ok and not result.authority_invalidated
    assert writer.attempts == 0 and store.files == before
    assert "authority invalidation failed" in result.findings[0].message


def test_forged_plan_validation_is_rejected_before_io(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Reconstruct internal plans before trusting success fields."""
    store, baseline = mutation_case(mutation_catalog)
    change = collection_change(baseline)
    plan = plan_mutation(baseline, (change,), grants=grants_for(change))
    forged = replace(plan, validation=replace(plan.validation, input_sha256="0" * 64))
    writer = MemoryWriter(store, mutation_catalog)
    with pytest.raises(MutationError, match="MUTATION_PLAN"):
        commit_mutation(forged, writer=writer)
    assert writer.attempts == writer.invalidations == 0


def test_guarded_writer_rechecks_the_supplied_original_digest(
    mutation_catalog: SchemaCatalog,
) -> None:
    """
    The concrete writer rejects a mismatched precondition even for a current capture.
    """
    store, baseline = mutation_case(mutation_catalog)
    change = collection_change(baseline)
    plan = plan_mutation(baseline, (change,), grants=grants_for(change))
    stale = replace(plan.writes[0], change=replace(change, expected_sha256="0" * 64))
    writer = MemoryWriter(store, mutation_catalog)
    before = dict(store.files)
    with pytest.raises(MutationError, match="MUTATION_PRECONDITION"):
        writer.atomic_write(stale, expected=baseline)
    assert store.files == before and writer.invalidations == 0
