# Component Documentation Template

## Component Name: {ComponentName}

{Brief description of what the component does - 1-2 sentences}

## Usage

```tsx
import { ComponentName } from '@/components/ComponentName';

function Example() {
  const handleAction = (value: string) => {
    console.log('Action triggered:', value);
  };

  return (
    <ComponentName
      prop1="Example Title"
      prop2={42}
      onAction={handleAction}
    />
  );
}
```

## Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `prop1` | `string` | Yes | - | Description of prop1 |
| `prop2` | `number` | No | `0` | Description of prop2 |
| `onAction` | `(value: string) => void` | No | - | Callback fired when action occurs |
| `className` | `string` | No | - | Additional CSS class for styling |

## Accessibility

- ✅ Keyboard navigable (Tab, Enter, Space keys supported)
- ✅ Screen reader friendly (ARIA labels and roles)
- ✅ Focus indicators visible
- ✅ ARIA labels and roles properly implemented
- ✅ Color contrast meets WCAG AA standards (4.5:1 minimum)

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Tab` | Navigate to component |
| `Enter` / `Space` | Trigger primary action |
| `Esc` | Close/cancel (if applicable) |

## Examples

### Basic Usage

```tsx
<ComponentName prop1="Hello World" />
```

### With Callback

```tsx
<ComponentName
  prop1="Interactive"
  onAction={(value) => alert(value)}
/>
```

### Custom Styling

```tsx
<ComponentName
  prop1="Styled"
  className="custom-class"
/>
```

### With All Props

```tsx
<ComponentName
  prop1="Complete Example"
  prop2={100}
  onAction={handleAction}
  className="my-custom-class"
/>
```

## States

### Default State

![Default state screenshot or description]

```tsx
<ComponentName prop1="Default" />
```

### Loading State

![Loading state screenshot or description]

```tsx
<ComponentName prop1="Loading" loading={true} />
```

### Error State

![Error state screenshot or description]

```tsx
<ComponentName prop1="Error" error="Something went wrong" />
```

### Disabled State

![Disabled state screenshot or description]

```tsx
<ComponentName prop1="Disabled" disabled={true} />
```

## Testing

### Unit Test Example

```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { ComponentName } from './ComponentName';

test('renders and handles interaction', () => {
  const handleAction = jest.fn();

  render(<ComponentName prop1="Test" onAction={handleAction} />);

  // Check rendering
  expect(screen.getByText('Test')).toBeInTheDocument();

  // Test interaction
  const button = screen.getByLabelText('Submit action');
  fireEvent.click(button);

  expect(handleAction).toHaveBeenCalled();
});
```

### Accessibility Test Example

```tsx
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { ComponentName } from './ComponentName';

expect.extend(toHaveNoViolations);

test('should have no accessibility violations', async () => {
  const { container } = render(<ComponentName prop1="Test" />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

## Variants

### Variant 1: {Name}

![Variant screenshot or description]

```tsx
<ComponentName prop1="Variant 1" variant="primary" />
```

**Use when:** {Description of when to use this variant}

### Variant 2: {Name}

![Variant screenshot or description]

```tsx
<ComponentName prop1="Variant 2" variant="secondary" />
```

**Use when:** {Description of when to use this variant}

## Integration

### With Form

```tsx
import { useForm } from 'react-hook-form';

function FormExample() {
  const { handleSubmit } = useForm();

  const onSubmit = (data) => {
    console.log(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <ComponentName prop1="Form Field" />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### With State Management

```tsx
import { useState } from 'react';

function StateExample() {
  const [value, setValue] = useState('');

  return (
    <ComponentName
      prop1={value}
      onAction={setValue}
    />
  );
}
```

## Styling

### Theming

Component respects theme tokens:

```typescript
// Theme tokens used
theme.colors.background
theme.colors.text
theme.colors.primary
theme.colors.primaryHover
theme.breakpoints.mobile
theme.breakpoints.tablet
```

### Custom Styles

Override styles using className:

```tsx
import styled from 'styled-components';

const CustomComponentName = styled(ComponentName)`
  /* Your custom styles */
  background-color: #custom;
`;
```

## Performance

- ✅ Memoized callbacks prevent unnecessary re-renders
- ✅ Optimized for large lists (if applicable)
- ✅ Lazy loading for heavy components
- ✅ Code splitting implemented

### Performance Tips

1. **Memoization**: Component uses `React.memo()` to prevent re-renders
2. **Callback Stability**: Event handlers wrapped in `useCallback()`
3. **Virtual Scrolling**: Large lists use `react-window` (if applicable)

## Browser Support

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

## Dependencies

```json
{
  "react": "^18.0.0",
  "styled-components": "^5.3.0",
  "other-dependency": "^x.x.x"
}
```

## Known Issues

1. **Issue Description**: Brief description of known limitation
   - **Workaround**: How to work around it
   - **Tracked in**: Link to issue tracker

## Changelog

### v1.0.0 (2024-01-15)
- Initial release
- Basic functionality implemented

### v1.1.0 (2024-02-01)
- Added new prop: `prop2`
- Improved accessibility
- Performance optimizations

## Related Components

- **RelatedComponent1**: Brief description of relationship
- **RelatedComponent2**: Brief description of relationship

## Resources

- [Figma Design](link-to-figma)
- [Storybook](link-to-storybook)
- [API Documentation](link-to-api-docs)
