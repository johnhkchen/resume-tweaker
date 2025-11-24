# Transition: Elixir to Go

#archive #architecture

**Date**: November 24, 2025

This document explains why the project transitioned from Elixir/Phoenix to Go.

## Decision Summary

After encountering GLIBC compatibility issues with `baml_elixir` (Rust NIF dependencies), we transitioned from Elixir/Phoenix to Go.

## Why Move Away from Elixir

1. **Native dependency complexity** - Rust NIFs require careful GLIBC version management
2. **BAML ecosystem** - Go has first-class BAML support (not community-maintained)
3. **Deployment friction** - Even with source compilation, adds build complexity
4. **Contributor accessibility** - Go is more widely known

## Why Go is Better for This Project

1. **BAML first-class support** - Official Go SDK, actively maintained
2. **Static binaries** - No GLIBC version mismatches, simpler deployment
3. **Simpler stack** - Standard HTTP server, no complex framework
4. **Railpack support** - Railway/Railpack handles Go natively
5. **Streaming** - Native SSE support for LLM responses

## What We Kept

### Philosophy & Approach
- Flox for local development
- Railpack for zero-config deployment
- Declarative configuration over Dockerfiles
- The Arch/Nix mindset

### Infrastructure
- Railway project connection
- PostgreSQL database addon
- Custom domain (resume.tweaking.app)
- Health check pattern

## What We Learned

### The GLIBC Challenge

The original Elixir implementation used `baml_elixir`, which includes Rust NIFs. The precompiled binaries required GLIBC 2.38, but Railway's environment had an older version.

**Solution attempted (worked but complex):**
```toml
# railpack.toml
[packages]
rust = "1.83"

[build]
env = { BAML_ELIXIR_BUILD = "true" }
```

This forced source compilation on Railway, avoiding GLIBC mismatches.

### The Strategic Pivot

Even though we solved the technical issue, we realized Go was a better fit:
- BAML has **official** Go SDK (vs community Elixir package)
- Static binaries avoid the entire GLIBC category of problems
- Simpler long-term maintenance

## Technology Comparison

| Aspect | Elixir | Go |
|--------|--------|-----|
| BAML support | Community package | Official SDK |
| Binaries | BEAM + NIFs | Static binary |
| GLIBC concerns | Yes (NIFs) | No (static) |
| Framework | Phoenix (full-featured) | Chi (minimal) |
| Templates | HEEx | Templ |
| Streaming | LiveView | SSE + Datastar |

## Philosophy Maintained

This transition demonstrates:
- **Pragmatic decision-making** over sunk cost fallacy
- **Simple solutions** over complex ones
- **Platform-native approaches** over custom workarounds
- **Learning from challenges** and adapting

The approach was right. The language choice needed adjustment.

## Related Documents

- [[../specification]] - Current project spec
- [[../deployment]] - Current deployment guide
