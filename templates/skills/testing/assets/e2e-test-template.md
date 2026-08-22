# End-to-End (E2E) Test Template

## Overview

End-to-end tests verify complete user workflows from the UI through the entire application stack. They simulate real user interactions in a browser environment.

**Use this template when:**
- Testing critical user journeys (login, checkout, onboarding)
- Validating complete workflows across multiple pages
- Verifying UI interactions and visual feedback
- Testing browser-specific behavior
- Ensuring integration of frontend, backend, and database

---

## Template Structure

### Basic E2E Test (Playwright)

```javascript
// Playwright
import { test, expect } from '@playwright/test';

test.describe('User Authentication', () => {
  test('should allow user to login with valid credentials', async ({ page }) => {
    // Arrange - Navigate to login page
    await page.goto('/login');

    // Act - Fill in login form
    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="login-button"]');

    // Assert - Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toContainText('Welcome');
  });

  test('should display error for invalid credentials', async ({ page }) => {
    // Arrange
    await page.goto('/login');

    // Act
    await page.fill('[data-testid="email-input"]', 'invalid@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');
    await page.click('[data-testid="login-button"]');

    // Assert
    await expect(page.locator('[data-testid="error-message"]')).toContainText('Invalid credentials');
    await expect(page).toHaveURL('/login'); // Still on login page
  });
});
```

### Basic E2E Test (Cypress)

```javascript
// Cypress
describe('User Authentication', () => {
  beforeEach(() => {
    // Reset database state
    cy.task('db:seed');
  });

  it('should allow user to login with valid credentials', () => {
    // Arrange
    cy.visit('/login');

    // Act
    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="login-button"]').click();

    // Assert
    cy.url().should('include', '/dashboard');
    cy.get('[data-testid="welcome-message"]').should('contain', 'Welcome');
  });

  it('should display error for invalid credentials', () => {
    // Arrange
    cy.visit('/login');

    // Act
    cy.get('[data-testid="email-input"]').type('invalid@example.com');
    cy.get('[data-testid="password-input"]').type('wrongpassword');
    cy.get('[data-testid="login-button"]').click();

    // Assert
    cy.get('[data-testid="error-message"]').should('contain', 'Invalid credentials');
    cy.url().should('include', '/login');
  });
});
```

---

## Page Object Model Pattern

### Page Object Definition

```javascript
// Playwright - pages/LoginPage.js
export class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.locator('[data-testid="email-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.errorMessage = page.locator('[data-testid="error-message"]');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  async getErrorMessage() {
    return await this.errorMessage.textContent();
  }
}
```

### Using Page Objects in Tests

```javascript
// Playwright
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';

test('user can login and see dashboard', async ({ page }) => {
  // Arrange
  const loginPage = new LoginPage(page);
  const dashboardPage = new DashboardPage(page);

  // Act
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');

  // Assert
  await expect(page).toHaveURL('/dashboard');
  await expect(dashboardPage.welcomeMessage).toContainText('Welcome');
});
```

---

## Common E2E Test Patterns

### 1. Form Submission Workflows

```javascript
// Playwright
test('should submit contact form successfully', async ({ page }) => {
  // Arrange
  await page.goto('/contact');

  // Act - Fill form
  await page.fill('[name="name"]', 'John Doe');
  await page.fill('[name="email"]', 'john@example.com');
  await page.fill('[name="message"]', 'Hello, this is a test message');
  await page.click('[type="submit"]');

  // Assert - Success message appears
  await expect(page.locator('.success-message')).toBeVisible();
  await expect(page.locator('.success-message')).toContainText('Thank you');

  // Assert - Form is cleared
  await expect(page.locator('[name="name"]')).toHaveValue('');
  await expect(page.locator('[name="email"]')).toHaveValue('');
  await expect(page.locator('[name="message"]')).toHaveValue('');
});

test('should validate required fields', async ({ page }) => {
  // Arrange
  await page.goto('/contact');

  // Act - Submit without filling
  await page.click('[type="submit"]');

  // Assert - Validation errors appear
  await expect(page.locator('.error-message')).toContainText('Name is required');
  await expect(page.locator('.error-message')).toContainText('Email is required');
});
```

### 2. Multi-Step User Journeys

```javascript
// Playwright - E-commerce checkout flow
test('complete checkout process', async ({ page }) => {
  // Step 1: Add product to cart
  await page.goto('/products/laptop');
  await page.click('[data-testid="add-to-cart"]');
  await expect(page.locator('.cart-badge')).toContainText('1');

  // Step 2: Go to cart
  await page.click('[data-testid="cart-icon"]');
  await expect(page).toHaveURL('/cart');
  await expect(page.locator('.cart-item')).toHaveCount(1);

  // Step 3: Proceed to checkout
  await page.click('[data-testid="checkout-button"]');
  await expect(page).toHaveURL('/checkout');

  // Step 4: Fill shipping information
  await page.fill('[name="address"]', '123 Main St');
  await page.fill('[name="city"]', 'Springfield');
  await page.fill('[name="zipcode"]', '12345');
  await page.click('[data-testid="continue-to-payment"]');

  // Step 5: Fill payment information
  await page.fill('[name="card-number"]', '4111111111111111');
  await page.fill('[name="expiry"]', '12/25');
  await page.fill('[name="cvc"]', '123');
  await page.click('[data-testid="place-order"]');

  // Step 6: Verify order confirmation
  await expect(page).toHaveURL(/\/order-confirmation/);
  await expect(page.locator('.order-success')).toContainText('Order placed successfully');
  await expect(page.locator('.order-number')).toBeVisible();
});
```

### 3. Navigation and Routing

```javascript
// Playwright
test('should navigate through main pages', async ({ page }) => {
  // Home page
  await page.goto('/');
  await expect(page.locator('h1')).toContainText('Welcome');

  // Navigate to About
  await page.click('a[href="/about"]');
  await expect(page).toHaveURL('/about');
  await expect(page.locator('h1')).toContainText('About Us');

  // Navigate to Contact
  await page.click('a[href="/contact"]');
  await expect(page).toHaveURL('/contact');
  await expect(page.locator('h1')).toContainText('Contact');

  // Navigate back to Home
  await page.click('a[href="/"]');
  await expect(page).toHaveURL('/');
});

test('should handle 404 page', async ({ page }) => {
  // Navigate to non-existent page
  await page.goto('/non-existent-page');

  // Assert 404 page is shown
  await expect(page.locator('h1')).toContainText('404');
  await expect(page.locator('a[href="/"]')).toBeVisible(); // Home link
});
```

### 4. Authentication Flows

```javascript
// Playwright
test.describe('Authentication Flow', () => {
  test('should complete full registration and login cycle', async ({ page }) => {
    // Step 1: Register new user
    await page.goto('/register');
    await page.fill('[name="email"]', `user-${Date.now()}@example.com`);
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'SecurePass123!');
    await page.click('[type="submit"]');

    // Step 2: Verify email sent message
    await expect(page.locator('.success-message')).toContainText('Check your email');

    // Step 3: Simulate email verification (for testing)
    // Note: In real scenarios, you'd intercept the email or use a test email service
    await page.goto('/verify-email?token=test-token');
    await expect(page.locator('.success-message')).toContainText('Email verified');

    // Step 4: Login with new credentials
    await page.goto('/login');
    await page.fill('[name="email"]', email);
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('[type="submit"]');

    // Step 5: Verify logged in
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
  });

  test('should logout successfully', async ({ page }) => {
    // Arrange - Login first
    await loginAsUser(page, 'user@example.com', 'password123');

    // Act - Logout
    await page.click('[data-testid="user-menu"]');
    await page.click('[data-testid="logout-button"]');

    // Assert - Redirected to home, no user menu
    await expect(page).toHaveURL('/');
    await expect(page.locator('[data-testid="user-menu"]')).not.toBeVisible();
  });
});
```

### 5. Dynamic Content and Loading States

```javascript
// Playwright
test('should handle loading states', async ({ page }) => {
  // Arrange
  await page.goto('/users');

  // Assert - Loading spinner appears
  await expect(page.locator('.loading-spinner')).toBeVisible();

  // Wait for content to load
  await page.waitForSelector('.user-list');

  // Assert - Loading spinner disappears, content appears
  await expect(page.locator('.loading-spinner')).not.toBeVisible();
  await expect(page.locator('.user-list .user-item')).toHaveCount(10);
});

test('should load more items on scroll', async ({ page }) => {
  // Arrange
  await page.goto('/feed');
  await page.waitForSelector('.post-item');

  // Act - Scroll to bottom
  const initialCount = await page.locator('.post-item').count();
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));

  // Wait for new items to load
  await page.waitForTimeout(1000); // Wait for API call
  await page.waitForSelector(`.post-item:nth-child(${initialCount + 1})`);

  // Assert - More items loaded
  const newCount = await page.locator('.post-item').count();
  expect(newCount).toBeGreaterThan(initialCount);
});
```

### 6. Modal and Dialog Interactions

```javascript
// Playwright
test('should open and close modal dialog', async ({ page }) => {
  // Arrange
  await page.goto('/dashboard');

  // Act - Open modal
  await page.click('[data-testid="open-modal-button"]');

  // Assert - Modal is visible
  await expect(page.locator('[data-testid="modal"]')).toBeVisible();
  await expect(page.locator('[data-testid="modal-title"]')).toContainText('Confirm Action');

  // Act - Close modal
  await page.click('[data-testid="modal-close-button"]');

  // Assert - Modal is hidden
  await expect(page.locator('[data-testid="modal"]')).not.toBeVisible();
});

test('should confirm deletion via modal', async ({ page }) => {
  // Arrange
  await page.goto('/items');

  // Act - Click delete on first item
  await page.click('[data-testid="delete-button"]:first-of-type');

  // Assert - Confirmation modal appears
  await expect(page.locator('[data-testid="confirm-dialog"]')).toBeVisible();

  // Act - Confirm deletion
  await page.click('[data-testid="confirm-button"]');

  // Assert - Item is removed
  await expect(page.locator('.success-toast')).toContainText('Item deleted');
  await page.waitForTimeout(500); // Wait for animation
  await expect(page.locator('[data-testid="item-1"]')).not.toBeVisible();
});
```

---

## Test Data Management

### Seeding Test Data

```javascript
// Playwright - Using fixtures
test.use({
  storageState: 'tests/auth.json', // Reuse authenticated session
});

test.beforeEach(async ({ page, context }) => {
  // Seed database via API
  await context.request.post('/api/test/seed', {
    data: {
      users: [
        { email: 'user1@example.com', name: 'User 1' },
        { email: 'user2@example.com', name: 'User 2' },
      ],
      posts: [
        { title: 'Post 1', content: 'Content 1' },
        { title: 'Post 2', content: 'Content 2' },
      ],
    },
  });
});

test.afterEach(async ({ context }) => {
  // Clean up test data
  await context.request.post('/api/test/cleanup');
});
```

### Using Fixtures

```javascript
// Playwright - Custom fixtures
import { test as base } from '@playwright/test';

const test = base.extend({
  authenticatedPage: async ({ page, context }, use) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('[type="submit"]');
    await page.waitForURL('/dashboard');

    await use(page);
  },
});

test('should access protected page', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('/admin');
  await expect(authenticatedPage.locator('h1')).toContainText('Admin Panel');
});
```

---

## Visual Testing

```javascript
// Playwright - Screenshot comparison
test('homepage should match visual snapshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png');
});

test('button should have correct styling', async ({ page }) => {
  await page.goto('/components');
  const button = page.locator('[data-testid="primary-button"]');
  await expect(button).toHaveScreenshot('primary-button.png');
});
```

---

## Accessibility Testing

```javascript
// Playwright - Using axe-core
import { injectAxe, checkA11y } from 'axe-playwright';

test('homepage should be accessible', async ({ page }) => {
  await page.goto('/');
  await injectAxe(page);
  await checkA11y(page);
});

test('form should have proper labels', async ({ page }) => {
  await page.goto('/contact');

  // Check for aria-labels
  await expect(page.locator('[name="email"]')).toHaveAttribute('aria-label', 'Email address');
  await expect(page.locator('[name="message"]')).toHaveAttribute('aria-label', 'Your message');
});
```

---

## Network Interception

```javascript
// Playwright - Mocking API responses
test('should handle API failure gracefully', async ({ page }) => {
  // Intercept API call and return error
  await page.route('/api/users', route => {
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Server error' }),
    });
  });

  // Navigate to page that calls API
  await page.goto('/users');

  // Assert error message is shown
  await expect(page.locator('.error-message')).toContainText('Failed to load users');
});

test('should display users from API', async ({ page }) => {
  // Intercept API and return mock data
  await page.route('/api/users', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify([
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' },
      ]),
    });
  });

  await page.goto('/users');

  // Assert mock data is displayed
  await expect(page.locator('.user-item')).toHaveCount(2);
  await expect(page.locator('.user-item').first()).toContainText('Alice');
});
```

---

## E2E Testing Best Practices

### 1. Use Data Attributes for Selectors

```html
<!-- Good - Stable selectors -->
<button data-testid="login-button">Login</button>
<input data-testid="email-input" type="email" />

<!-- Avoid - Brittle selectors -->
<button class="btn btn-primary">Login</button> <!-- CSS classes can change -->
<input type="email" id="email-input-123" /> <!-- IDs can be dynamic -->
```

### 2. Wait for Elements Properly

```javascript
// Good - Wait for element to be visible
await page.waitForSelector('[data-testid="success-message"]', { state: 'visible' });

// Good - Wait for network idle
await page.waitForLoadState('networkidle');

// Avoid - Arbitrary timeouts
await page.waitForTimeout(5000); // Flaky and slow
```

### 3. Keep Tests Independent

```javascript
// Good - Each test is self-contained
test.beforeEach(async ({ page, context }) => {
  await context.request.post('/api/test/reset');
});

test('test 1', async ({ page }) => {
  // This test doesn't depend on test 2
});

test('test 2', async ({ page }) => {
  // This test doesn't depend on test 1
});
```

---

## Running E2E Tests

### Playwright Configuration

```javascript
// playwright.config.js
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Cypress Configuration

```javascript
// cypress.config.js
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    supportFile: 'tests/support/e2e.js',
    specPattern: 'tests/e2e/**/*.cy.js',
    video: false,
    screenshotOnRunFailure: true,
  },
});
```

---

## E2E Testing Anti-Patterns

### ❌ Testing Everything with E2E Tests

```javascript
// BAD - Unit test would be faster
test('should add two numbers', async ({ page }) => {
  await page.goto('/calculator');
  await page.fill('[name="a"]', '2');
  await page.fill('[name="b"]', '3');
  await page.click('[data-testid="add"]');
  await expect(page.locator('.result')).toContainText('5');
});

// GOOD - Use E2E for critical user journeys only
test('should complete checkout flow', async ({ page }) => {
  // This is a complex user journey that requires E2E testing
});
```

### ❌ Not Using Page Object Model for Complex Tests

```javascript
// BAD - Duplicated selectors and logic
test('test 1', async ({ page }) => {
  await page.fill('[data-testid="email-input"]', 'user@example.com');
  await page.fill('[data-testid="password-input"]', 'password');
  await page.click('[data-testid="login-button"]');
});

test('test 2', async ({ page }) => {
  await page.fill('[data-testid="email-input"]', 'user2@example.com');
  await page.fill('[data-testid="password-input"]', 'password');
  await page.click('[data-testid="login-button"]');
});

// GOOD - Reusable page object
const loginPage = new LoginPage(page);
await loginPage.login('user@example.com', 'password');
```

---

## Quick Reference

| Framework | Run Tests | Headed Mode | Debug Mode |
|-----------|-----------|-------------|------------|
| Playwright | `npx playwright test` | `npx playwright test --headed` | `npx playwright test --debug` |
| Cypress | `npx cypress run` | `npx cypress open` | `npx cypress open --browser chrome` |

---

## Related Templates

- **unit-test-template.md** - For testing individual functions
- **integration-test-template.md** - For testing API and database integration
- **test-data-template.md** - For creating test fixtures and seed data
- **testing-strategies.md** - Choosing when to use E2E vs other test types
