# Community Hub Frontmatter Standard

All community content must pass `scripts/validate-frontmatter.sh` before merge.

## Schemas by Type

### Protocol

```yaml
---
type: protocol
name: kebab-case-name              # matches filename
status: active                     # active | draft | archived | deprecated
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
status: active                     # active | dormant | retired
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

### Extension / Script (planned)

Same schema as Skill. Type is `extension` or `script`.

## Field Reference

| Field | Required | Values | Notes |
|-------|----------|--------|-------|
| `type` | ✅ | `protocol`, `muscle`, `skill`, `extension`, `script`, `identity` | Always first field |
| `name` | ✅ | kebab-case | Matches filename |
| `status` | ✅ | `active`, `draft`, `dormant`, `retired`, `archived`, `deprecated` | |
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

## Validation

```bash
# Validate all content
./scripts/validate-frontmatter.sh

# Validate specific directory
./scripts/validate-frontmatter.sh protocols/

# Show fix suggestions
./scripts/validate-frontmatter.sh --fix
```

## Key Design Decisions

- **`breadcrumb` not `description`** — one field for both warm prompt injection AND hub card display. No duplication.
- **`topic` not `tags` for muscles** — agent runtime reads `topic`. Website falls back to it. Single source of truth.
- **`heat` (numeric) + `heat-default` (string) coexist** — `heat` is runtime state, `heat-default` is the initial/display value.
- **`tier` vocabulary differs by context** — community hub uses `core`/`official`/`community`/`pro`. Agent runtime uses `free`/`enterprise`. The hub tiers describe authorship; runtime tiers describe access.
