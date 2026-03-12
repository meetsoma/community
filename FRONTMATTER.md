# Community Hub Frontmatter Standard

All community content must pass `scripts/validate-frontmatter.sh` before merge.

Content types follow the **AMPS** model: **A**utomations · **M**uscles · **P**rotocols · **S**kills — plus Templates for bundling.

## Schemas by Type

### Protocol

```yaml
---
type: protocol
name: kebab-case-name              # matches filename
status: active                     # draft | active | stable | dormant | archived | deprecated
heat-default: warm                 # cold | warm | hot — initial system prompt tier
applies-to: [always]               # signal matching: always, git, typescript, python, etc.
breadcrumb: "One-liner TL;DR..."   # QUOTED — used for warm injection + hub card
author: Curtis Mercier
license: CC BY 4.0
version: 1.0.0
tier: core                         # core | official | community | pro
tags: [workflow, memory]           # hub card tags + search
created: 2026-03-10
updated: 2026-03-10
---
```

**Agent runtime reads:** `name`, `breadcrumb`, `heat-default`, `applies-to`, `scope`, `tier`
**Website hub reads:** `name`, `breadcrumb`, `tier`, `tags`, `heat-default`, `author`, `version`

### Muscle

```yaml
---
type: muscle
name: kebab-case-name              # matches filename
breadcrumb: "One-liner TL;DR..."   # QUOTED — hub card description
tier: core                         # core | official | community | pro
topic: [design, icons]             # canonical tags — agent + website both read this
keywords: [icon-audit, svg]        # agent search terms (finer grain)
status: active                     # draft | active | stable | dormant | archived | deprecated
heat: 0                            # numeric 0-15 — agent runtime tracks this
heat-default: warm                 # cold | warm | hot — initial tier + website display
loads: 0                           # boot load counter — agent runtime tracks this
author: Curtis Mercier
license: MIT
version: 1.0.0
created: 2026-03-10
updated: 2026-03-10
---
```

**Agent runtime reads:** `topic`, `keywords`, `heat`, `loads`, `status`
**Website hub reads:** `name`, `breadcrumb`, `tier`, `topic` (as tag fallback), `heat-default`, `author`, `version`

**Body convention:** Muscles use `<!-- digest:start/end -->` for a blockquote TL;DR (agent-facing digest).

### Template

Templates use **two files**:

**`template.json`** (structured metadata — website + installer reads this):
```json
{
  "name": "architect",
  "description": "One-liner for hub card",
  "author": "meetsoma",
  "version": "1.0.0",
  "tier": "official",
  "requires": {
    "protocols": ["breath-cycle"],
    "muscles": [],
    "skills": []
  }
}
```

**`identity.md`** (install-time placeholder — stamped with project data):
```yaml
---
type: identity
agent: soma
template: architect
project: "{{PROJECT_NAME}}"
created: "{{DATE}}"
---
```

### Skill (planned)

```yaml
---
type: skill
name: skill-name
breadcrumb: "One-liner..."
tier: community
topic: [topic1, topic2]
keywords: [keyword1, keyword2]
status: active
heat-default: warm
author: Author Name
license: MIT
version: 1.0.0
created: 2026-03-10
updated: 2026-03-10
---
```

### Automation

```yaml
---
type: automation
name: automation-name
breadcrumb: "One-liner..."
tier: community
topic: [workflow, ci]
keywords: [hook, pre-commit]
status: active
author: Author Name
license: MIT
version: 1.0.0
created: 2026-03-10
updated: 2026-03-10
---
```

Automations are executable community content — workflows, hooks, and rituals that run without thinking. Unlike scripts (internal enforcement) or extensions (framework hooks), automations are shareable hub content triggered by slash commands.

**No heat system** — automations are always available when installed (they don't fade in/out of context like muscles/protocols).

### Extension (internal)

Extensions are TypeScript hooks into the agent lifecycle. They are framework-specific runtime code, not hub content. Type is `extension`.

## Field Reference

| Field | Required | Values | Notes |
|-------|----------|--------|-------|
| `type` | ✅ | `protocol`, `muscle`, `skill`, `automation`, `extension`, `identity` | Always first field |
| `name` | ✅ | kebab-case | Matches filename |
| `status` | ✅ | `draft`, `active`, `stable`, `dormant`, `archived`, `deprecated` | |
| `breadcrumb` | ✅* | Quoted string | *Not required for identity files |
| `version` | ✅ | semver | |
| `author` | ✅ | Name or handle | |
| `license` | ✅ | SPDX identifier | |
| `created` | ✅ | YYYY-MM-DD | |
| `updated` | ✅ | YYYY-MM-DD | Change with every meaningful edit |
| `tier` | ✅ | `core`, `official`, `community`, `pro` | |
| `tags` | protocols | Array | Hub card tags |
| `topic` | muscles | Array | Canonical tags for muscles |
| `keywords` | optional | Array | Finer-grain search terms |
| `heat-default` | protocols + muscles | `cold`, `warm`, `hot` | Initial system prompt tier |
| `heat` | muscles only | numeric 0-15 | Runtime-managed |
| `loads` | muscles only | numeric | Runtime-managed |
| `applies-to` | protocols | Array of signals | `always`, `git`, `typescript`, etc. |
| `scope` | optional | `bundled`, `hub` | Distribution scope (default: `hub`) |
| `depends-on` | optional | Object | Cross-type dependencies (see below) |

## Validation

```bash
# Validate all content
./scripts/validate-frontmatter.sh

# Validate specific directory
./scripts/validate-frontmatter.sh protocols/

# Show fix suggestions
./scripts/validate-frontmatter.sh --fix
```

## Distribution Scope (`scope`)

Controls where content is distributed:

| Scope | Meaning | Who gets it |
|-------|---------|-------------|
| `bundled` | Ships with `meetsoma` npm package | Every Soma install |
| `hub` | Available on SomaHub | Users who `/install` it |

Default is `hub`. Only `tier: core` content can be `scope: bundled`.

Bundled content is Soma's DNA — the minimum set that makes the system work. Everything else lives on the hub and can be installed via templates or `/install`.

> **Note:** `workspace` and `internal` scopes exist conceptually but aren't used in the community repo — workspace content lives in project `.soma/` directories, internal content lives in Gravicity's private tooling.

## Dependencies (`depends-on`)

Any AMPS content can declare dependencies on other hub content:

```yaml
depends-on:
  protocols: [breath-cycle]
  muscles: [micro-exhale]
  automations: [frontmatter-date-hook]
  skills: []
```

- Only list the types you depend on (empty arrays can be omitted)
- `install` resolves dependencies automatically; missing deps trigger a warning
- Circular dependencies are rejected

## Key Design Decisions

- **`breadcrumb` not `description`** — one field for both warm prompt injection AND hub card display. No duplication.
- **`topic` not `tags` for muscles** — agent runtime reads `topic`. Website falls back to it. Single source of truth.
- **`heat` (numeric) + `heat-default` (string) coexist** — `heat` is runtime state, `heat-default` is the initial/display value.
- **`tier` vocabulary differs by context** — community hub uses `core`/`official`/`community`/`pro`. Agent runtime uses `free`/`enterprise`. The hub tiers describe authorship; runtime tiers describe access.
- **`scope` vs `tier`** — `tier` = who wrote it (trust). `scope` = where it ships (distribution). A `tier: core` protocol can be `scope: hub` (Gravicity-authored but not bundled). Only bundled content ships in the npm package.
