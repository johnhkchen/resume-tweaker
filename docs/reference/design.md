# Design Reference

#reference #architecture

## Design Philosophy

The Resume Tweaker UI is inspired by the **Anchor** project, emphasizing:

1. **Calm, focused interface** - Minimize distractions
2. **Clear action steps** - Guide users through the process
3. **Streaming feedback** - Show progress as LLM generates output
4. **Session-based tracking** - Anonymous but persistent within session

## UI Principles

### Micro-step Oriented

Break complex tasks into small, achievable steps:
1. Paste resume
2. Paste job description
3. Click tweak
4. Review and copy result

### Cognitive Load Reduction

- One primary action per screen
- Clear visual hierarchy
- Minimal options/settings
- Progress indication during streaming

### Feedback & Progress

- Real-time streaming output
- Loading states with meaningful messages
- Success/error states clearly visible
- Copy-to-clipboard confirmation

## Component Patterns

### shadcn/ui Integration

We use shadcn/ui design tokens via Tailwind CSS:

```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  /* ... */
}
```

### Common Components

**Button (Primary)**
```html
<button class="px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90">
  Action
</button>
```

**Textarea**
```html
<textarea class="w-full p-3 border border-input rounded-lg bg-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring">
</textarea>
```

**Card**
```html
<div class="p-4 bg-muted rounded-lg border border-border">
  Content
</div>
```

## Datastar Patterns

### Reactive State

```html
<div data-signals="{ result: '', loading: false, error: '' }">
  <!-- Content reacts to signal changes -->
</div>
```

### SSE Streaming

```html
<form data-on-submit__prevent="$$post('/api/tweak/stream')">
  <!-- Form submits via SSE -->
</form>
```

### Conditional Display

```html
<span data-show="$loading">Working...</span>
<span data-show="!$loading">Submit</span>
```

## Route Structure

Since Resume Tweaker is deployed at `resume.tweaking.app`:

| Route | Purpose |
|-------|---------|
| `/` | Landing page with value proposition |
| `/tweak` | Main resume tweaking interface |
| `/profile` | User's submission history (planned) |
| `/health` | Health check endpoint |

## Color Palette

Using shadcn/ui default theme:

| Token | Usage |
|-------|-------|
| `background` | Page background |
| `foreground` | Primary text |
| `muted` | Secondary backgrounds |
| `muted-foreground` | Secondary text |
| `primary` | Primary buttons, links |
| `destructive` | Error states |
| `border` | Borders, dividers |

## Typography

- **Headings**: `font-bold tracking-tight`
- **Body**: Default sans-serif
- **Code/Results**: `font-mono text-sm`

## Responsive Design

- Mobile-first approach
- Max width container: `max-w-4xl mx-auto`
- Responsive grid: `grid md:grid-cols-3`
- Flexible textareas: `resize-y`

## Related Documents

- [[specification]] - Full product spec
- [[development]] - Local development
