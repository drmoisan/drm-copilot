"""Deterministic ``threading.Thread`` stand-ins for the fix-all runtime tests.

``fix_all_runtime.run_fix_all`` launches one daemon thread per branch and relies
on a bounded wall-clock grace period for cancel propagation between them, so a
test that asserts what one branch observed about another branch's failure is
decided by the operating-system scheduler rather than by its own inputs. That
violates the determinism requirement in ``.claude/rules/general-unit-test.md``.

The stand-ins here remove the scheduler from the picture entirely by running
branch targets synchronously in a caller-chosen order. They are installed with
``monkeypatch.setattr(runtime.threading, "Thread", <stand-in>)``.

Two stand-ins are provided:

``make_ordered_thread_class``
    Runs every branch target, in a supplied order, on the first ``join``.
``SkipBranchThread``
    Runs every branch target except one, so that branch's result stays unset.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, ClassVar

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

    from scripts.dev_tools import fix_all


class ThreadRegistry:
    """Per-class record of stand-in threads awaiting a synchronous join.

    One registry belongs to one class object produced by
    ``make_ordered_thread_class``. Holding the mutable state here rather than in
    a module-level or shared class-level attribute is what keeps two tests in
    the same session from observing each other's registrations.

    Attributes:
        branch_order: Branch names in the order their targets must run.
        pending: Stand-in threads registered by ``start`` and not yet run.
        joined: Whether the pending targets have already been run.
    """

    def __init__(self, *, branch_order: Sequence[str]) -> None:
        self.branch_order: tuple[str, ...] = tuple(branch_order)
        self.pending: list[OrderedThread] = []
        self.joined: bool = False


class OrderedThread:
    """Thread stand-in that defers its target until an ordered join.

    ``start`` registers the target without running it, so no branch makes
    progress while the runtime is still launching lanes. The first ``join``
    runs every registered target on the calling thread, ordered by the
    registry's ``branch_order``; later ``join`` calls are no-ops because the
    runtime joins each of its five threads in turn.

    This class is not used directly. ``make_ordered_thread_class`` returns a
    fresh subclass carrying the ``registry`` this base only declares.

    Attributes:
        registry: State shared by the instances of one generated subclass.
    """

    registry: ClassVar[ThreadRegistry]

    def __init__(
        self,
        *,
        target: Callable[[str, Callable[[], fix_all.BranchResult]], None],
        args: tuple[str, Callable[[], fix_all.BranchResult]],
        daemon: bool,
    ) -> None:
        self._target = target
        self._args = args
        self._daemon = daemon

    @property
    def branch_name(self) -> str:
        """Return the branch name the runtime passed as the first target arg."""
        return self._args[0]

    def start(self) -> None:
        """Register the target for the ordered join without running it."""
        type(self).registry.pending.append(self)

    def join(self) -> None:
        """Run every registered target once, in the configured branch order."""
        registry = type(self).registry
        # Guard: the runtime joins all five threads, but the targets must run
        # exactly once, so only the first join does the work.
        if registry.joined:
            return
        registry.joined = True

        order = registry.branch_order

        def sort_key(item: tuple[int, OrderedThread]) -> tuple[int, int]:
            registration_index, thread = item
            name = thread.branch_name
            # Unlisted branches sort after every listed one; ``sorted`` is
            # stable, so they keep their registration order among themselves.
            position = order.index(name) if name in order else len(order)
            return (position, registration_index)

        for _, thread in sorted(enumerate(registry.pending), key=sort_key):
            thread.run_target()

    def run_target(self) -> None:
        """Invoke the registered target with the registered arguments."""
        self._target(*self._args)


def make_ordered_thread_class(*, order: Sequence[str]) -> type[OrderedThread]:
    """Build a thread stand-in class that runs branches in a fixed order.

    A fresh class object is returned on every call, each with its own
    ``ThreadRegistry``. No state is shared between calls, so two tests may
    install stand-ins in the same session without interfering.

    Args:
        order: Branch names in the order their targets must run. Branches that
            are not named run afterwards, in registration order.

    Returns:
        A subclass of ``OrderedThread`` suitable for patching over
        ``threading.Thread`` in ``scripts.dev_tools.fix_all_runtime``.
    """

    class _OrderedThread(OrderedThread):
        """Generated stand-in bound to one registry."""

        registry: ClassVar[ThreadRegistry] = ThreadRegistry(branch_order=order)

    return _OrderedThread


class SkipBranchThread:
    """Thread stand-in that runs every branch target except a skipped one.

    Purpose:
        Deterministically leave one branch's result unrecorded (without raising
        an exception in a worker thread) so the runtime aggregation hits its
        missing/None-result path.

    Attributes:
        skip_branch: Name of the branch whose ``_runner`` target is suppressed.
    """

    skip_branch = "json"

    def __init__(
        self,
        *,
        target: Callable[[str, Callable[[], fix_all.BranchResult]], None],
        args: tuple[str, Callable[[], fix_all.BranchResult]],
        daemon: bool,
    ) -> None:
        self._target = target
        self._args = args
        self._daemon = daemon

    def start(self) -> None:
        """Run the target synchronously unless it is the skipped branch."""
        branch_name = self._args[0]
        # Routing: suppress only the configured branch so its result stays unset;
        # all other branches run their target synchronously.
        if branch_name == self.skip_branch:
            return
        self._target(*self._args)

    def join(self) -> None:
        """No-op join; targets already ran synchronously in ``start``."""
        return
