<div align="center">

<br>

### σ Community

*Shared patterns from real workflows.*

<br>

Protocols, muscles, skills, and templates for [Soma](https://soma.gravicity.ai) agents.

</div>

---

## What's Here

| Directory | What | How it loads |
|---|---|---|
| `protocols/` | Behavioral rules | `/hub install protocol <name>` |
| `muscles/` | Learned patterns | `/hub install muscle <name>` |
| `skills/` | Domain expertise | `/hub install skill <name>` |
| `templates/` | Full agent configs | `soma init --template <name>` |

```bash
# From inside a Soma session:
/hub install protocol breath-cycle
/hub install muscle docker-deploy
/list remote                      # browse everything
```

## Contributing

1. Fork → add your protocol/muscle/skill → open a PR
2. Follow the format below — CI validates frontmatter automatically

### Format

**Protocols** need: `type: protocol`, `name`, `heat-default`, `breadcrumb`, `applies-to`, a `## TL;DR` section.

**Muscles** need: `type: muscle`, `status: active`, `triggers`, `tags`, `## TL;DR` section, `heat: 0`.

**Skills** need: a `SKILL.md` with `name`, `description`, `version`, `author`, `keywords`. Self-contained.

> `triggers` is the single activation list — merged from old `triggers` + `keywords` + `topic` as of v0.6.2.

## Specifications

Community protocols are operational derivatives of formal specs in [curtismercier/protocols](https://github.com/curtismercier/protocols). Each protocol's `spec-ref` links to its source.

## License

**Each item carries its author's licence** in its frontmatter (`license:`), and the hub shows it. That licence wins:
we never relicense or strip it. An item without one is MIT, like the repo itself ([LICENSE](LICENSE)).

Protocols and concepts: **CC BY 4.0** — [Curtis Mercier](https://github.com/curtismercier).
<br>
Other community contributions: the licence in their frontmatter, else MIT.

---

<div align="center">

<sub>MIT © Curtis Mercier — each item keeps its author's licence</sub>

</div>
