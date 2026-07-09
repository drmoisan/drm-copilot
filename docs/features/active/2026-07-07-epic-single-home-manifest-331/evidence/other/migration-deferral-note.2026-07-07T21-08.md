# Migration-Deferral Note (P4-T9, satisfies AC-6) (#331)

Timestamp: 2026-07-07T21-08

Recorded text for the change description / PR notes for #331:

> Deferred: per-consumer migration of existing epics to the single-home layout.
> Migrating epic #260 (store-lockup-resilience) — and any other epic already
> realized in the legacy two-tree layout (`docs/features/epics/<slug>/epic-plan.md`
> + `epic-status.md` plus a separate `docs/features/active/<date>-<slug>-<issue>/`
> folder with `initiative.md`) — to the new single-home layout
> (`docs/features/epics/<slug>/{epic.md, epic-status.md}`) is a deferred,
> per-consumer-repo follow-up. This change is additive and key-gated, so the legacy
> two-tree layout and folder-basename-keyed manifests remain valid and validate
> byte-identically; migration is therefore low-cost and non-urgent. This feature
> (#331) does not migrate #260 or any other existing epic, and it does not
> implement the epic-status hand-edit guard (both are out of scope per the spec
> Non-Goals).

This note MUST be included in the #331 change description / PR body so the deferral
is explicit and traceable, satisfying AC-6 ("Change description records the deferred
per-consumer migration (incl. TaskMaster epic #260)").
