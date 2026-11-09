# `progress-report-critical-path-velocity` — User Story

- Issue: #1153
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09T09-45

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

Observed in a live epic on 2026-11-09:

- The v2 rewrite of the `epic-progress-report` skill (typed steps) removed task-based progress and velocity. The report has no tasks per hour, no recent velocity, no SD, and no range.
- The headline "about N hours left" is the serial sum over step types (remaining steps times their median, summed), decision D7. It ignores parallelism. With 5 features running at once it read 20 to 22 h. The wave-parallel figure on the same line read 12.5 h, and measured throughput implied about 6 to 8 h.
- The wave-parallel figure takes the slowest feature in each wave. It ignores the actual dependency edges, the concurrency cap, and each feature's own pace.
- Aggregate (parallel) velocity is not a stable measure. It scales with the number of running features and drops to zero during contention or stalls. Per-step medians measured during contention, such as 100-minute test runs, inflate every estimate.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] TL;DR shows task progress, sequential and aggregate velocity, a critical-path headline with the named chain, and the serial sum labelled as an upper bound.
- [ ] Per-feature remaining time uses that feature's sequential velocity, falling back to the pooled median.
- [ ] Critical path respects depends-on edges, epic-level tail steps, and `max_parallel_features`.
- [ ] Paused, blocked or waiting time is excluded from sequential velocity.
- [ ] Default TL;DR cadence is 20 minutes in the skill's scheduling prompts.
- [ ] Unit tests cover the scenarios in section 7; the toolchain passes; coverage thresholds are met.


## Non-Goals

Call out what is explicitly excluded from this feature.
