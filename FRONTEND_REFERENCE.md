# Frontend Reference

## Sample Code

The `sample_code/` directory contains the **Anchor** project (job-cards), which serves as design inspiration for the Resume Tweaker frontend.

### Key Characteristics of Anchor

- **Astro-based** frontend with TypeScript
- **BAML integration** for LLM features
- **Local-first** data approach (IndexedDB)
- **Calm, focused UI** designed to reduce cognitive load
- **Micro-step oriented** interactions

### Directory Structure

```
sample_code/
├── src/
│   ├── components/    # Reusable UI components
│   ├── content/       # Content files
│   ├── layouts/       # Page layouts
│   ├── lib/          # Utility functions and logic
│   ├── pages/        # Astro pages
│   └── styles/       # CSS/styling
├── baml_src/         # BAML function definitions
└── baml_client/      # Generated BAML client code
```

## Design Inspiration

The Resume Tweaker should adopt similar principles:

1. **Calm, focused interface** - Minimize distractions
2. **Clear action steps** - Guide users through the tweaking process
3. **Streaming feedback** - Show progress as LLM generates output
4. **Session-based tracking** - Anonymous but persistent within session

## Route Structure

Since Resume Tweaker will be deployed at `resume.tweaking.app` (subdomain):

- `/` - Main resume tweaking interface (formerly `/tweak`)
- `/profile` - User's submission history (to be implemented)
- `/health` - Health check endpoint for Railway

No need for `/tweak` route since the subdomain itself indicates the purpose.
