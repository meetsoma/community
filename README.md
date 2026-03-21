# Soma Community

Shared protocols, muscles, skills, and templates for [Soma](https://soma.gravicity.ai) agents.

## What's Here

| Directory | What | Format |
|-----------|------|--------|
| `protocols/` | Behavioral rules — how your agent *acts* | Markdown with YAML frontmatter |
| `muscles/` | Learned patterns — reusable workflows | Markdown with digest blocks |
| `skills/` | Domain expertise — task-specific knowledge | `name/SKILL.md` directories |
| `templates/` | Full agent configs — identity + protocols + skills | `.soma/` bundles |
| `extensions/` | TypeScript hooks — lifecycle, UI, tools | `.ts` files |
| `themes/` | Visual themes — colors, statusline styles | JSON/TS |

## Install

From within a Soma session:

```bash
# Install a protocol
/install protocol breath-cycle

# Install a muscle
/install muscle docker-deploy

# Install a skill
/install skill logo-creator

# Browse what's available
/list remote

# Bootstrap from a template
soma init --template devops
```

## Using Manually

```bash
# Protocol → .soma/protocols/
cp community/protocols/code-review.md your-project/.soma/protocols/

# Muscle → .soma/memory/muscles/
cp community/muscles/docker-deploy.md your-project/.soma/memory/muscles/

# Skill → ~/.soma/skills/ (global) or .soma/skills/ (project)
cp -r community/skills/logo-creator ~/.soma/skills/
```

## Specifications

Community protocols are operational derivatives of formal specifications in [curtismercier/protocols](https://github.com/curtismercier/protocols). Each protocol's `spec-ref` field links to its source specification for the full rationale and design decisions.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for format requirements and submission guidelines.

### Quick Start

1. Fork this repo
2. Add your protocol/muscle/skill/template
3. Ensure frontmatter follows the [format guide](#format-requirements)
4. Open a PR with a description of what it does and why it's useful

### Format Requirements

**Protocols** must have:
- `type: protocol`, `name`, `heat-default`, `breadcrumb`, `applies-to` in frontmatter
- A `## TL;DR` section
- Clear `## When to Apply` and `## When NOT to Apply` sections

**Muscles** must have:
- `type: muscle`, `status: active`, `triggers`, `tags` in frontmatter
- `<!-- digest:start -->` / `<!-- digest:end -->` markers
- `heat` set to `0` (users control their own heat)
- `triggers` is the single activation list (merged from old `triggers` + `keywords` + `topic`)

**Skills** must have:
- A `SKILL.md` file with `name`, `description`, `version`, `author`, `keywords`
- Self-contained — no external dependencies beyond standard tools

**Templates** must have:
- A `README.md` explaining what the template sets up
- A `.soma/` directory with identity, settings, and any bundled protocols/muscles

## License

Core protocols and conceptual frameworks are **CC BY 4.0** — original work by [Curtis Mercier](https://github.com/curtismercier). Attribution is required when redistributing or building upon these designs.

Community contributions follow the same CC BY 4.0 license unless the contributor specifies otherwise in their file's frontmatter.

The Soma agent software itself (meetsoma/soma-agent, meetsoma/cli) is MIT licensed separately. See [LICENSE](./LICENSE) for details.
