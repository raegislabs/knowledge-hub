# Accessibility Guide

## WCAG 2.1 Standards

### Levels of Conformance

**Level A** (Minimum):
- Basic accessibility features
- Must be met for legal compliance in many jurisdictions

**Level AA** (Recommended):
- Addresses major barriers
- Industry standard target
- **Our minimum standard**

**Level AAA** (Enhanced):
- Highest level of accessibility
- May not be achievable for all content

### Four Principles (POUR)

1. **Perceivable** - Information must be presentable to users
2. **Operable** - UI components must be operable
3. **Understandable** - Information and operation must be understandable
4. **Robust** - Content must be robust enough for assistive technologies

## Semantic HTML

### Use Appropriate Elements

```html
<!-- ✅ Good - Semantic HTML -->
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Title</h1>
    <p>Content</p>
  </article>
</main>

<footer>
  <p>&copy; 2024</p>
</footer>
```

```html
<!-- ❌ Bad - Divs for everything -->
<div class="header">
  <div class="nav">
    <div class="link">Home</div>
  </div>
</div>

<div class="content">
  <div class="title">Title</div>
  <div>Content</div>
</div>
```

### Semantic Elements Reference

| Element | Purpose | Example |
|---------|---------|---------|
| `<header>` | Introductory content | Site header, article header |
| `<nav>` | Navigation links | Main menu, breadcrumbs |
| `<main>` | Primary content | Page content (one per page) |
| `<article>` | Self-contained content | Blog post, news article |
| `<section>` | Thematic grouping | Chapter, tab panel |
| `<aside>` | Tangentially related | Sidebar, related links |
| `<footer>` | Footer content | Site footer, article footer |
| `<figure>` | Self-contained media | Images with captions |

## ARIA Attributes

### When to Use ARIA

**First Rule of ARIA**: Don't use ARIA if native HTML works.

```html
<!-- ✅ Good - Native HTML -->
<button>Click Me</button>

<!-- ❌ Bad - Unnecessary ARIA -->
<div role="button" tabindex="0">Click Me</div>
```

**Use ARIA when**:
- Native HTML doesn't provide needed semantics
- Building custom widgets (tabs, tooltips, modals)
- Adding dynamic status updates

### Common ARIA Roles

```html
<!-- Landmark roles (use native HTML instead) -->
<div role="navigation">  <!-- Use <nav> instead -->
<div role="main">        <!-- Use <main> instead -->
<div role="banner">      <!-- Use <header> instead -->

<!-- Widget roles -->
<div role="dialog" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Action</h2>
</div>

<div role="tablist">
  <button role="tab" aria-selected="true">Tab 1</button>
  <button role="tab" aria-selected="false">Tab 2</button>
</div>

<div role="tabpanel">Content</div>

<!-- Live regions -->
<div role="alert">Error: Form submission failed</div>
<div role="status" aria-live="polite">Loading...</div>
```

### ARIA States and Properties

```html
<!-- Labels and descriptions -->
<button aria-label="Close dialog">×</button>
<input aria-describedby="password-help" />
<div id="password-help">Password must be 8+ characters</div>

<!-- States -->
<button aria-pressed="true">Bold</button>
<button aria-expanded="false">Show More</button>
<input aria-invalid="true" aria-errormessage="email-error" />

<!-- Relationships -->
<button aria-controls="dropdown-menu">Menu</button>
<ul id="dropdown-menu" aria-labelledby="menu-button">
  <li>Item 1</li>
</ul>

<!-- Live regions -->
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>
```

### ARIA in React Components

```typescript
function Dialog({ isOpen, onClose, title, children }) {
  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="dialog-title"
      hidden={!isOpen}
    >
      <h2 id="dialog-title">{title}</h2>
      <div>{children}</div>
      <button onClick={onClose} aria-label="Close dialog">
        ×
      </button>
    </div>
  );
}

function Accordion({ items }) {
  const [expandedId, setExpandedId] = useState(null);

  return (
    <div>
      {items.map(item => (
        <div key={item.id}>
          <button
            aria-expanded={expandedId === item.id}
            aria-controls={`panel-${item.id}`}
            onClick={() => setExpandedId(item.id)}
          >
            {item.title}
          </button>
          <div
            id={`panel-${item.id}`}
            role="region"
            aria-labelledby={`button-${item.id}`}
            hidden={expandedId !== item.id}
          >
            {item.content}
          </div>
        </div>
      ))}
    </div>
  );
}
```

## Keyboard Navigation

### Focusable Elements

**Naturally focusable**:
- `<a>` with href
- `<button>`
- `<input>`, `<select>`, `<textarea>`
- `<summary>` (inside `<details>`)

**Make custom elements focusable**:
```html
<!-- Add tabindex="0" to include in tab order -->
<div role="button" tabindex="0" onClick={handleClick}>
  Custom Button
</div>

<!-- tabindex="-1" for programmatic focus only -->
<div tabindex="-1" ref={errorRef}>
  Error message
</div>
```

### Keyboard Event Handling

```typescript
function AccessibleButton({ onClick, children }) {
  const handleKeyDown = (e: React.KeyboardEvent) => {
    // Enter or Space triggers button
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      onClick?.();
    }
  };

  return (
    <div
      role="button"
      tabIndex={0}
      onClick={onClick}
      onKeyDown={handleKeyDown}
    >
      {children}
    </div>
  );
}

function KeyboardNavigableList({ items }) {
  const [focusedIndex, setFocusedIndex] = useState(0);
  const itemRefs = useRef([]);

  const handleKeyDown = (e: React.KeyboardEvent, index: number) => {
    let newIndex = index;

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        newIndex = Math.min(index + 1, items.length - 1);
        break;
      case 'ArrowUp':
        e.preventDefault();
        newIndex = Math.max(index - 1, 0);
        break;
      case 'Home':
        e.preventDefault();
        newIndex = 0;
        break;
      case 'End':
        e.preventDefault();
        newIndex = items.length - 1;
        break;
    }

    setFocusedIndex(newIndex);
    itemRefs.current[newIndex]?.focus();
  };

  return (
    <ul role="listbox">
      {items.map((item, index) => (
        <li
          key={item.id}
          role="option"
          tabIndex={index === focusedIndex ? 0 : -1}
          ref={el => itemRefs.current[index] = el}
          onKeyDown={e => handleKeyDown(e, index)}
          aria-selected={index === focusedIndex}
        >
          {item.label}
        </li>
      ))}
    </ul>
  );
}
```

### Keyboard Shortcuts Reference

| Pattern | Keys | Usage |
|---------|------|-------|
| **Tab navigation** | `Tab`, `Shift+Tab` | Move focus forward/backward |
| **Activation** | `Enter`, `Space` | Activate buttons, links |
| **Arrow keys** | `↑↓←→` | Navigate lists, menus, tabs |
| **Escape** | `Esc` | Close dialogs, cancel operations |
| **Home/End** | `Home`, `End` | Jump to first/last item |

## Focus Management

### Focus Indicators

```css
/* ✅ Good - Visible focus indicator */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ❌ Bad - No focus indicator */
button:focus {
  outline: none; /* Never do this! */
}

/* ✅ Better - Custom focus ring */
button:focus-visible {
  box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.4);
  outline: none;
}
```

### Focus Trapping (Modals)

```typescript
import { useRef, useEffect } from 'react';

function Modal({ isOpen, onClose, children }) {
  const modalRef = useRef<HTMLDivElement>(null);
  const previousFocusRef = useRef<HTMLElement | null>(null);

  useEffect(() => {
    if (!isOpen) return;

    // Save previously focused element
    previousFocusRef.current = document.activeElement as HTMLElement;

    // Get focusable elements
    const focusableElements = modalRef.current?.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );

    if (!focusableElements?.length) return;

    const firstElement = focusableElements[0] as HTMLElement;
    const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement;

    // Focus first element
    firstElement.focus();

    const handleKeyDown = (e: KeyboardEvent) => {
      // Close on Escape
      if (e.key === 'Escape') {
        onClose();
        return;
      }

      // Trap focus on Tab
      if (e.key === 'Tab') {
        if (e.shiftKey) {
          if (document.activeElement === firstElement) {
            e.preventDefault();
            lastElement.focus();
          }
        } else {
          if (document.activeElement === lastElement) {
            e.preventDefault();
            firstElement.focus();
          }
        }
      }
    };

    document.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener('keydown', handleKeyDown);
      // Restore focus when modal closes
      previousFocusRef.current?.focus();
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      className="modal-overlay"
    >
      <div className="modal-content">
        {children}
      </div>
    </div>
  );
}
```

## Color Contrast

### WCAG AA Requirements

- **Normal text** (< 18pt): 4.5:1 contrast ratio
- **Large text** (≥ 18pt or ≥ 14pt bold): 3:1 contrast ratio
- **UI components**: 3:1 contrast ratio

### Testing Contrast

```typescript
// Use tools like:
// - Chrome DevTools (Inspect > Accessibility)
// - axe DevTools extension
// - WebAIM Contrast Checker

// Example: Ensure sufficient contrast
const colors = {
  // ✅ Good - 7.5:1 contrast
  text: '#212121',      // Dark gray
  background: '#FFFFFF', // White

  // ❌ Bad - 2.1:1 contrast
  lightText: '#999999',  // Light gray
  background: '#FFFFFF', // White
};
```

### Don't Rely on Color Alone

```typescript
// ❌ Bad - Color is only indicator
function StatusBadge({ status }) {
  const color = status === 'success' ? 'green' : 'red';
  return <span style={{ color }}>{status}</span>;
}

// ✅ Good - Color + icon + text
function StatusBadge({ status }) {
  const isSuccess = status === 'success';

  return (
    <span className={isSuccess ? 'success' : 'error'}>
      {isSuccess ? '✓' : '✗'} {status}
    </span>
  );
}
```

## Screen Reader Support

### ARIA Live Regions

```typescript
function LiveRegionExample() {
  const [message, setMessage] = useState('');

  return (
    <>
      {/* Polite - Wait for user to finish */}
      <div aria-live="polite" aria-atomic="true">
        {message}
      </div>

      {/* Assertive - Interrupt immediately */}
      <div role="alert" aria-live="assertive">
        Critical error occurred!
      </div>

      {/* Status - Non-critical updates */}
      <div role="status" aria-live="polite">
        Loading...
      </div>
    </>
  );
}
```

### Hidden Content

```typescript
// Visually hidden but available to screen readers
const visuallyHiddenStyle = {
  position: 'absolute',
  width: '1px',
  height: '1px',
  padding: 0,
  margin: '-1px',
  overflow: 'hidden',
  clip: 'rect(0, 0, 0, 0)',
  whiteSpace: 'nowrap',
  border: 0,
};

function SkipLink() {
  return (
    <a href="#main-content" style={visuallyHiddenStyle}>
      Skip to main content
    </a>
  );
}

// Hide from screen readers
<div aria-hidden="true">Decorative content</div>
```

## Forms Accessibility

### Labels and Instructions

```typescript
// ✅ Good - Proper labels and error handling
function AccessibleForm() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');

  return (
    <form>
      <div>
        <label htmlFor="email">
          Email Address <span aria-label="required">*</span>
        </label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={e => setEmail(e.target.value)}
          aria-required="true"
          aria-invalid={!!error}
          aria-describedby={error ? 'email-error email-help' : 'email-help'}
        />
        <div id="email-help">We'll never share your email</div>
        {error && (
          <div id="email-error" role="alert">
            {error}
          </div>
        )}
      </div>
    </form>
  );
}
```

### Error Handling

```typescript
function FormWithErrors() {
  const [errors, setErrors] = useState({});
  const errorSummaryRef = useRef<HTMLDivElement>(null);

  const handleSubmit = (e) => {
    e.preventDefault();

    // Validation
    const newErrors = validate(formData);

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);

      // Focus error summary
      errorSummaryRef.current?.focus();
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {Object.keys(errors).length > 0 && (
        <div
          ref={errorSummaryRef}
          role="alert"
          tabIndex={-1}
          aria-labelledby="error-summary-title"
        >
          <h2 id="error-summary-title">Please fix the following errors:</h2>
          <ul>
            {Object.entries(errors).map(([field, error]) => (
              <li key={field}>
                <a href={`#${field}`}>{error}</a>
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Form fields */}
    </form>
  );
}
```

## Testing Accessibility

### Automated Testing

```typescript
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('should have no accessibility violations', async () => {
  const { container } = render(<MyComponent />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Manual Testing Checklist

- [ ] Keyboard navigation works (Tab, Enter, Arrow keys)
- [ ] Focus indicators visible
- [ ] Screen reader announces content correctly
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 UI)
- [ ] Zoom to 200% without loss of functionality
- [ ] Forms have labels and error messages
- [ ] Images have alt text
- [ ] Videos have captions
- [ ] Headings are in logical order (h1, h2, h3...)

### Tools

- **Automated**: axe DevTools, Lighthouse, WAVE
- **Screen Readers**: NVDA (Windows), JAWS (Windows), VoiceOver (Mac/iOS)
- **Contrast**: WebAIM Contrast Checker, Chrome DevTools
- **Keyboard**: Test manually with keyboard only

## Common Patterns

### Accessible Modal

```typescript
<div role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <h2 id="modal-title">Confirm Action</h2>
  <p>Are you sure?</p>
  <button onClick={confirm}>Yes</button>
  <button onClick={cancel}>No</button>
</div>
```

### Accessible Tabs

```typescript
<div role="tablist">
  <button role="tab" aria-selected="true" aria-controls="panel-1">Tab 1</button>
  <button role="tab" aria-selected="false" aria-controls="panel-2">Tab 2</button>
</div>
<div id="panel-1" role="tabpanel" aria-labelledby="tab-1">Content 1</div>
<div id="panel-2" role="tabpanel" aria-labelledby="tab-2" hidden>Content 2</div>
```

### Accessible Dropdown

```typescript
<button aria-haspopup="true" aria-expanded={isOpen} aria-controls="menu">
  Menu
</button>
<ul id="menu" role="menu" hidden={!isOpen}>
  <li role="menuitem">Option 1</li>
  <li role="menuitem">Option 2</li>
</ul>
```
