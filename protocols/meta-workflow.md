---
name: meta-workflow
type: protocol
status: active
description: "The operating cadence — how work flows in a project. Three nested loops (session / feature / evolution); the cadence self-amends from its own observations. The body IS the project; instantiate this as a per-project META_WORKFLOW.md."
heat-default: warm
tags: [workflow, cadence, cycles, evolution, context-engineering, multi-project]
applies-to: [always]
scope: bundled
tier: core
created: 2026-06-10
updated: 2026-06-10
version: 1.0.0
author: meetsoma
license: CC BY 4.0
---
# Meta-Workflow Protocol

> The **cadence** — how an idea becomes shipped, verified, consolidated work, and how the way you work
> improves from its own incidents. `breath-cycle` governs a single session; this governs the arc above
> it (a feature, a cycle) and the loop above *that* (the workflow rewriting itself). The **body is the
> project**: its identity is the project's context, its services/infra are *body parts*, and this is
> how work flows through it.

## TL;DR
- Three nested loops: **BREATH** (a session — `breath-cycle`) → **ARC** (a feature/cycle, 7 stages) → **EVOLUTION** (the cadence amends itself from observations).
- The ARC loop: **GROUND → DECIDE → PLAN → BUILD → VERIFY → CONSOLIDATE → REFLECT.** Each stage has a gate ("done = …"). Never skip GROUND or REFLECT.
- **Process-by-evidence, not by vibe:** every amendment to how you work cites the observation(s) that drove it.
- **Docs index the source, they don't duplicate it** (PCE). A stale duplicate is worse than a pointer.
- Instantiate this in a project as a living **`META_WORKFLOW.md`** (its own ledger, register, cycles). This protocol is the *shape*; the instance holds the *content*. A project can run many; a workspace navigates project ↔ parent scope.

## The three nested loops

```
   ┌─ BREATH (a session) ───────────────────────────────────────────────┐
   │  inhale → hold → exhale         (the breath-cycle protocol)         │
   │  one shift. The preload carries the ARC position + open decisions    │
   │  + the observation harvest forward across amnesia.                  │
   └────────────────────────────────────────────────────────────────────┘
        ┌─ ARC (a feature / cycle) ──────────────────────────────────────┐
        │  GROUND → DECIDE → PLAN → BUILD → VERIFY → CONSOLIDATE → REFLECT │
        │  one piece of work, many sessions. REFLECT(n) feeds GROUND(n+1). │
        └────────────────────────────────────────────────────────────────┘
             ┌─ EVOLUTION (the workflow itself) ──────────────────────────┐
             │  observations → ledger → amendment (cites its evidence)     │
             │  the cadence improves from its own incidents.              │
             └────────────────────────────────────────────────────────────┘
```

Each loop feeds the one outside it. A session's preload carries the arc's position; an arc's
reflection feeds the evolution ledger. The inner loop is owned by `breath-cycle`; this protocol owns
the middle and outer loops.

## The ARC loop — 7 stages

Each stage has a **gate**: what "done" means, so you always know where the work sits. An arc may
ping-pong (BUILD ↔ VERIFY) but never skips GROUND or REFLECT.

| # | Stage | What you do | Gate (done = ) | Leans on |
|---|---|---|---|---|
| 1 | **GROUND** | Read the real consumers; verify *live* state (run it, don't assume); search for prior art / existing cycles before scoping. | You know the **real** current state, not the documented one. | `pre-flight`, `tool-discipline` |
| 2 | **DECIDE** | Surface the forks as options + leaning + implication. The user sets scope. | A scoped direction + open forks in the **Decision Register**. | §Decision Register |
| 3 | **PLAN** | Turn scope into a living plan a fresh agent could execute (phases, forward-pointers). | A plan that survives amnesia. | `implementation-plans`, `plan-hygiene` |
| 4 | **BUILD** | Lay pipe one unit at a time. Test → commit → push. No orphan/untested work. | Shipped, pushed, tested. | `workflow` |
| 5 | **VERIFY** | Probe the **real artifact** — run the path, open the page, check the output. Not "should work." | Proof, not theory. | `quality-standards` |
| 6 | **CONSOLIDATE** | Update the plan/index/body/breadcrumbs. Demote stale, preserve history, forward-point. | The substrate reflects reality. | `session-checkpoints` |
| 7 | **REFLECT** | Harvest observations → ledger. Write the preload + a roadmap-style session log. | Continuity + evolution-input captured. | `breath-cycle` (exhale), `pattern-evolution` |

**The close:** REFLECT(n) → GROUND(n+1) (the next arc inherits real state) **and** → EVOLUTION (the
ledger). An arc that ships code but skips CONSOLIDATE/REFLECT leaves debt: drift + lost lessons.

## The EVOLUTION loop — the cadence rewrites itself

The cadence is **living**: it describes what you actually do that works, and amends itself from
observations. This is the determinism Curtis named: *process-by-evidence, not process-by-vibe.*

- **Observation Ledger** (append-only). At REFLECT, log 1–3 honest notes, each typed
  `worked` / `didn't` / `gap` / `infra`.
- **Amendment rule:** when an observation **recurs (≥2×) or is high-impact**, it amends the cadence —
  a new stage-rule, a new tool, a new habit — and the amendment **cites the observation id(s)**. No
  un-sourced rules.
- This is the *process* sibling of `pattern-evolution` (which matures *content*: skill → muscle →
  protocol → automation). A recurring observation resolves into either a **muscle** (knowledge, via
  `pattern-evolution`) or a **cadence amendment** (process, here). Same instinct — friction becomes
  mechanism — applied to two different things.

## The Decision Register

Open forks live here until built, so they're never re-litigated or lost. Status: `open` (surfaced,
not decided) · `scoped` (direction set) · `built` (laid). Surface open forks in every preload until
`built`. Decisions are substrate, not chat — write them down.

## The RESUME block (PCE for a cycle)

Every **active** plan/cycle carries one RESUME block at the top — the single thing a future session
reads to know where to go, then it **opens the source it names**, not the block:

```
> **RESUME (<session> · <stage>):** <one-line status — what's true now>.
> **Next:** <the single next action>.
> **⚠ READ FIRST (source of truth — this block may lag):** `<file>` (<why>) · `<exact cmd>`.
```

Keep it **current** (update or delete on every touch — a stale RESUME is worse than none); it
**points, never duplicates**; it's **assertive** ("read before continuing") so the loader actually
opens the source. It's the per-cycle analogue of the preload's resume point.

## PCE — docs are an index to source, not a duplicate

**Programmatic Context Engineering:** decide what a future session reads to regain exactly the context
it needs — and nothing it doesn't. Most "documentation debt" is a *context-economics* problem, not a
writing one. Two waste modes, both costly:

- **Stale duplication** — a hand-written fact drifts from its source; the reader trusts a lie.
- **Over-documentation** — prose restates what the code/canonical doc already says; the reader reads
  the prose instead of the truth.

**The write-test** (apply before writing any fact): *derivable from source? → point to it. Opinion /
decision / gotcha / where-you-left-off? → write it, terse.* When you must state a derived fact, name
its source so it stays re-verifiable and prunable. Prune stale on sight.

## Body parts — the project's organs

The body is the project; its services and infra are **body parts** (a deploy target, an issue
tracker, a CDN, a vision provider, a database). Each is a lazy "organ" — a reference file loaded on
demand, not eager weight in every boot.

A body part is an **index to live source + the tool to read it fresh**, never a cache of learned
doc-prose (platforms and docs drift — a cached "what I read once" is the costliest stale). Per topic,
write the **source of truth + how to fetch it** (a doc URL + `browser`, a config path + `read`, a
probe command); keep inline only your **durable, hard-won specifics** (your instance, your traps,
your patterns) — those aren't in anyone's docs. See the `DNA` body doc, §Lazy-vs-Eager, for the
convention and the canonical shape (a *Resources → source-of-truth → how-to-fetch* table, read first).

**Multi-project:** one `.soma` per project; the project's body = its context; shared identity and
method live up at the parent/workspace scope, project specifics live local. The body chain walks
child → parent, so child files load first. A project may run its own META_WORKFLOW + cycles.

## The preload contract

The preload is REFLECT's output — the session handoff that survives amnesia. It must carry: the
**arc + stage** (where to resume in the loop, not just what happened) · **what shipped** (roadmap
form: ordered steps, commits, synthesized — not a transcript) · **start-here** (present-imperative,
exact commands) · the **open Decision Register forks** · 1–3 **observations** for the ledger · **open
loops/traps** (file:line + next command) · and **who you were** (the self before the worker). Format
details: `breath-cycle` §Preload Quality.

## Instantiate it in your project

This protocol is the **shape**. To use it, give the project a living **`META_WORKFLOW.md`** that holds
the *content*: its own Observation Ledger, its own Decision Register, its cycles. Treat it as the
project's operating system, written by the COO who keeps the incident log — never "done," every arc
leaves it a little truer. The protocol ships with Soma; the instance is yours.

## When to Apply

Any project with work that spans more than one session — a feature, a cycle, an arc. Read the
project's `META_WORKFLOW.md` (if it has one) **unprompted** at boot, on a rotation trigger, at a stage
transition, and before scoping new work (`breath-cycle` §Rotation is self-initiated).

## When NOT to Apply

One-off tasks that begin and end in a single session with nothing to carry forward don't need the arc
or evolution loops — the breath cycle alone suffices. Don't manufacture cycles for work that isn't one.

---

<!--
Licensed under CC BY 4.0 — https://creativecommons.org/licenses/by/4.0/
Author: meetsoma · synthesized from operating cadences proven across multiple Soma projects (2026-06).
-->
