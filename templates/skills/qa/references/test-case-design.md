# Test Case Design Guide

## Overview

This guide provides techniques and best practices for designing effective, comprehensive test cases that maximize coverage while minimizing redundancy.

---

## Test Case Fundamentals

### Anatomy of a Test Case

A well-designed test case contains:

1. **Test Case ID**: Unique identifier (TC-001, TC-LOGIN-001)
2. **Test Case Name**: Descriptive title
3. **Objective**: What is being tested and why
4. **Preconditions**: Required setup before test execution
5. **Test Steps**: Actions to perform
6. **Test Data**: Specific data values to use
7. **Expected Results**: What should happen
8. **Actual Results**: What actually happened (filled during execution)
9. **Status**: Pass/Fail/Blocked
10. **Priority**: Critical/High/Medium/Low
11. **Test Type**: Unit/Integration/System/Regression

---

## Black-Box Testing Techniques

### 1. Equivalence Partitioning

**Concept**: Divide input domain into equivalence classes where all values should behave similarly.

**Process**:
1. Identify input parameters
2. Determine valid and invalid ranges
3. Partition into equivalence classes
4. Select one representative from each class

**Example 1: Age Validation**

```
Requirement: Age must be between 18 and 65

Equivalence Classes:
1. Invalid: age < 18 (e.g., 10)
2. Valid: 18 ≤ age ≤ 65 (e.g., 30)
3. Invalid: age > 65 (e.g., 70)

Test Cases:
TC-001: Test with age = 10 → Expect: Invalid
TC-002: Test with age = 30 → Expect: Valid
TC-003: Test with age = 70 → Expect: Invalid
```

**Example 2: File Upload**

```
Requirement: Accept PDF, DOCX, PNG files; max 5MB

Equivalence Classes:
1. Valid file type: PDF (test with valid PDF)
2. Valid file type: DOCX (test with valid DOCX)
3. Valid file type: PNG (test with valid PNG)
4. Invalid file type: TXT (test with TXT)
5. Valid size: 2MB file
6. Invalid size: 6MB file

Test Cases: 6 tests (one per class)
```

**Benefits**:
- Reduces test cases without losing coverage
- Systematic approach
- Easy to explain and review

---

### 2. Boundary Value Analysis (BVA)

**Concept**: Test at the boundaries of equivalence partitions (errors tend to occur at boundaries).

**Strategy**: Test:
- Minimum value
- Minimum + 1
- Maximum - 1
- Maximum value
- Below minimum
- Above maximum

**Example 1: Integer Input (0-100)**

```
Test Values:
- -1 (below min) → Invalid
- 0 (min boundary) → Valid
- 1 (just above min) → Valid
- 99 (just below max) → Valid
- 100 (max boundary) → Valid
- 101 (above max) → Invalid
```

**Example 2: String Length (5-50 characters)**

```
Test Values:
- 4 chars → Invalid
- 5 chars → Valid
- 6 chars → Valid
- 49 chars → Valid
- 50 chars → Valid
- 51 chars → Invalid
```

**Example 3: Date Range**

```
Requirement: Booking date between 2025-01-01 and 2025-12-31

Test Values:
- 2024-12-31 → Invalid
- 2025-01-01 → Valid
- 2025-01-02 → Valid
- 2025-12-30 → Valid
- 2025-12-31 → Valid
- 2026-01-01 → Invalid
```

**Benefits**:
- High defect detection rate
- Complements equivalence partitioning
- Industry standard technique

---

### 3. Decision Table Testing

**Concept**: Test all combinations of conditions and their resulting actions.

**When to Use**:
- Multiple conditions affect outcome
- Complex business rules
- Combinatorial logic

**Example: Loan Approval**

```
Conditions:
- Credit score ≥ 700 (Y/N)
- Annual income ≥ $50k (Y/N)
- Debt-to-income < 40% (Y/N)

Decision Table:

| Rule | Credit ≥700 | Income ≥50k | DTI <40% | Approval |
|------|-------------|-------------|----------|----------|
| 1    | Y           | Y           | Y        | Approved |
| 2    | Y           | Y           | N        | Denied   |
| 3    | Y           | N           | Y        | Denied   |
| 4    | Y           | N           | N        | Denied   |
| 5    | N           | Y           | Y        | Denied   |
| 6    | N           | Y           | N        | Denied   |
| 7    | N           | N           | Y        | Denied   |
| 8    | N           | N           | N        | Denied   |

Test Cases: 8 (one per rule)
```

**Simplified Decision Table** (Collapsed):

```
| Rule | Credit ≥700 | Income ≥50k | DTI <40% | Approval |
|------|-------------|-------------|----------|----------|
| 1    | Y           | Y           | Y        | Approved |
| 2    | *           | *           | *        | Denied   |

* = any value
Test Cases: 2 (much simpler)
```

**Benefits**:
- Handles complex logic systematically
- Ensures all combinations tested
- Can be simplified to reduce redundancy
- Clear documentation of business rules

---

### 4. State Transition Testing

**Concept**: Test transitions between different states of the system.

**When to Use**:
- System has distinct states
- State changes based on events
- Workflows with specific sequences

**Example: Order Status**

```
States: Draft, Submitted, Paid, Shipped, Delivered, Cancelled

Valid Transitions:
- Draft → Submitted
- Submitted → Paid
- Paid → Shipped
- Shipped → Delivered
- Draft → Cancelled
- Submitted → Cancelled

Invalid Transitions:
- Draft → Paid (skip Submitted)
- Paid → Draft (reverse)
- Delivered → Shipped (reverse)
- Shipped → Cancelled (too late)

State Transition Diagram:

Draft ──submit──> Submitted ──pay──> Paid ──ship──> Shipped ──deliver──> Delivered
  │                   │
  └──cancel──> Cancelled <──cancel──┘

Test Cases:
TC-001: Draft → Submitted → Valid
TC-002: Submitted → Paid → Valid
TC-003: Paid → Shipped → Valid
TC-004: Shipped → Delivered → Valid
TC-005: Draft → Cancelled → Valid
TC-006: Submitted → Cancelled → Valid
TC-007: Draft → Paid → Invalid (should fail)
TC-008: Delivered → Shipped → Invalid (should fail)
```

**Benefits**:
- Ensures valid state transitions work
- Prevents invalid state transitions
- Visualizes system behavior
- Useful for workflow testing

---

### 5. Use Case Testing

**Concept**: Derive test cases from use cases.

**Process**:
1. Identify use case
2. Identify primary (happy path) and alternative flows
3. Create test cases for each flow

**Example: User Login**

```
Use Case: User Login

Actors: User, System

Primary Flow:
1. User navigates to login page
2. User enters valid username
3. User enters valid password
4. User clicks "Login"
5. System validates credentials
6. System redirects to dashboard

Alternative Flows:
A1: Invalid username → Show error "User not found"
A2: Invalid password → Show error "Incorrect password"
A3: Account locked → Show error "Account locked"
A4: Forgot password → Navigate to password reset

Test Cases:
TC-LOGIN-001: Primary flow (valid credentials) → Dashboard
TC-LOGIN-002: Invalid username → Error message
TC-LOGIN-003: Invalid password → Error message
TC-LOGIN-004: Locked account → Error message
TC-LOGIN-005: Forgot password link → Password reset page
```

**Benefits**:
- Covers user perspectives
- Ensures use cases are testable
- Maps requirements to tests
- Good for acceptance testing

---

### 6. Error Guessing

**Concept**: Use experience and intuition to guess where errors might occur.

**When to Use**:
- After systematic techniques applied
- Testing legacy code
- Exploratory testing
- Based on historical defect data

**Common Error-Prone Areas**:

**1. Input Validation**
- Empty strings
- Null/undefined values
- Special characters (', ", <, >, &)
- Very long strings
- Unicode characters
- SQL injection attempts
- XSS payloads

**2. Numeric Inputs**
- Zero
- Negative numbers
- Very large numbers (overflow)
- Decimal vs integer
- Division by zero
- Float precision issues

**3. Date/Time**
- Leap years (Feb 29)
- End of month (30 vs 31 days)
- Timezone issues
- Daylight saving time transitions
- Date formats (MM/DD/YYYY vs DD/MM/YYYY)
- Year 2038 problem (Unix timestamp)

**4. Arrays/Lists**
- Empty array
- Single element
- Null elements in array
- Duplicates
- Unsorted vs sorted
- Very large arrays

**5. Concurrency**
- Race conditions
- Deadlocks
- Resource contention
- Simultaneous updates

**6. Edge Cases**
- First/last item in list
- Exactly at limits (capacity, timeout)
- Just before/after midnight
- Simultaneous users

**Example Error Guessing Test Cases**:

```
Function: search(query)

Error Guessing Tests:
- Empty query: ""
- Null query: null
- Very long query: 10000 characters
- Special chars: <script>alert('xss')</script>
- SQL injection: ' OR '1'='1
- Unicode: 日本語
- Leading/trailing spaces: "  query  "
- Only spaces: "     "
```

---

## White-Box Testing Techniques

### 1. Statement Coverage

**Goal**: Execute every line of code at least once.

**Example**:

```python
def calculate_discount(price, is_member):
    discount = 0  # Statement 1
    if is_member:  # Statement 2
        discount = price * 0.1  # Statement 3
    final_price = price - discount  # Statement 4
    return final_price  # Statement 5

Test Cases for 100% Statement Coverage:
TC-001: price=100, is_member=True → Covers all 5 statements
TC-002: price=100, is_member=False → Covers statements 1,2,4,5 (not 3)

Both tests together = 100% statement coverage
```

---

### 2. Branch Coverage

**Goal**: Execute every branch (true/false) of decision points.

**Example**:

```python
def grade_student(score):
    if score >= 90:  # Branch 1
        return 'A'
    elif score >= 80:  # Branch 2
        return 'B'
    elif score >= 70:  # Branch 3
        return 'C'
    else:  # Branch 4
        return 'F'

Test Cases for 100% Branch Coverage:
TC-001: score=95 → Branch 1 (True)
TC-002: score=85 → Branch 1 (False), Branch 2 (True)
TC-003: score=75 → Branches 1,2 (False), Branch 3 (True)
TC-004: score=65 → Branches 1,2,3 (False), Branch 4

4 tests = 100% branch coverage
```

---

### 3. Path Coverage

**Goal**: Execute every possible path through the code.

**Example**:

```python
def process_order(order, is_member, in_stock):
    if is_member:
        apply_discount(order)
    if in_stock:
        ship_order(order)
    else:
        backorder(order)

Paths:
1. member=T, stock=T → discount + ship
2. member=T, stock=F → discount + backorder
3. member=F, stock=T → ship (no discount)
4. member=F, stock=F → backorder (no discount)

Test Cases: 4 (one per path)
```

**Note**: Path coverage > Branch coverage > Statement coverage (in rigor)

---

## Advanced Test Design Patterns

### 1. Pairwise Testing (All-Pairs)

**Concept**: Test all pairs of parameters instead of all combinations.

**Example**:

```
Parameters:
- Browser: Chrome, Firefox, Safari (3 values)
- OS: Windows, macOS, Linux (3 values)
- Resolution: 1080p, 1440p, 4K (3 values)

All Combinations: 3 × 3 × 3 = 27 tests

Pairwise (Minimal covering array):
TC-001: Chrome, Windows, 1080p
TC-002: Chrome, macOS, 1440p
TC-003: Chrome, Linux, 4K
TC-004: Firefox, Windows, 1440p
TC-005: Firefox, macOS, 4K
TC-006: Firefox, Linux, 1080p
TC-007: Safari, Windows, 4K
TC-008: Safari, macOS, 1080p
TC-009: Safari, Linux, 1440p

9 tests cover all pairs (66% reduction)
```

**Tool**: PICT (Pairwise Independent Combinatorial Testing)

```bash
# pict-input.txt
Browser: Chrome, Firefox, Safari
OS: Windows, macOS, Linux
Resolution: 1080p, 1440p, 4K

# Run PICT
pict pict-input.txt

# Output: Minimal test matrix
```

---

### 2. Exploratory Testing Charters

**Concept**: Time-boxed, structured exploration of features.

**Charter Template**:

```
Explore: {Area to test}
With: {Resources/tools}
To discover: {What you're looking for}

Example:
Explore: User registration form
With: Various input combinations, browser dev tools
To discover: Input validation bugs, UX issues, edge cases
Time box: 60 minutes
```

---

### 3. Property-Based Testing

**Concept**: Define properties that should always hold, generate random inputs.

**Example (Python with Hypothesis)**:

```python
from hypothesis import given
from hypothesis.strategies import integers

# Property: Reversing a list twice returns original
@given(integers())
def test_reverse_property(lst):
    assert reverse(reverse(lst)) == lst

# Property: Adding to a list increases length
@given(integers())
def test_add_increases_length(lst, item):
    original_len = len(lst)
    lst.append(item)
    assert len(lst) == original_len + 1
```

**Benefits**:
- Discovers edge cases automatically
- Tests many inputs quickly
- Finds bugs humans miss

---

## Test Case Organization

### Grouping Strategies

**1. By Feature**
```
tests/
├── authentication/
│   ├── test_login.py
│   ├── test_logout.py
│   └── test_password_reset.py
├── checkout/
│   ├── test_cart.py
│   └── test_payment.py
```

**2. By Test Type**
```
tests/
├── unit/
│   └── test_calculations.py
├── integration/
│   └── test_database.py
└── e2e/
    └── test_user_flow.py
```

**3. By Priority**
```
tests/
├── critical/
│   └── test_payment.py
├── high/
│   └── test_checkout.py
└── medium/
    └── test_ui.py
```

---

### Naming Conventions

**Test Functions**:

```python
# Format: test_{function}_{scenario}_{expected_result}

def test_calculate_discount_with_valid_percent_returns_correct_amount():
    pass

def test_calculate_discount_with_negative_percent_raises_value_error():
    pass

def test_calculate_discount_with_zero_percent_returns_original_price():
    pass
```

**Test Classes**:

```python
class TestUserAuthentication:
    def test_login_with_valid_credentials_succeeds(self):
        pass

    def test_login_with_invalid_password_fails(self):
        pass

    def test_login_with_locked_account_raises_error(self):
        pass
```

---

## Test Data Design

### 1. Representative Data

**Concept**: Use data that represents real-world usage.

**Example**: Testing e-commerce

```python
# Poor: Unrealistic data
user = User(name="Test", email="test@test.com")

# Better: Realistic data
user = User(name="Jane Smith", email="jane.smith@example.com")
```

---

### 2. Data Builders

**Concept**: Fluent API for constructing test data.

```python
class UserBuilder:
    def __init__(self):
        self.name = "John Doe"
        self.email = "john@example.com"
        self.is_member = False

    def with_name(self, name):
        self.name = name
        return self

    def with_email(self, email):
        self.email = email
        return self

    def as_member(self):
        self.is_member = True
        return self

    def build(self):
        return User(self.name, self.email, self.is_member)

# Usage
user = UserBuilder()\.with_name("Jane")\.as_member()\.build()
```

---

### 3. Data Fixtures

**Concept**: Reusable test data setup.

```python
import pytest

@pytest.fixture
def sample_user():
    return User(name="John", email="john@example.com")

@pytest.fixture
def sample_product():
    return Product(name="Widget", price=10.00)

def test_add_to_cart(sample_user, sample_product):
    cart = ShoppingCart(sample_user)
    cart.add(sample_product)
    assert len(cart.items) == 1
```

---

## Test Case Review Checklist

Before finalizing test cases, verify:

### Coverage
- [ ] All requirements covered
- [ ] All user flows tested
- [ ] Edge cases identified
- [ ] Boundary values tested
- [ ] Error conditions included

### Quality
- [ ] Clear, descriptive names
- [ ] One concept per test
- [ ] Independent tests (no dependencies)
- [ ] Repeatable results
- [ ] Fast execution (unit tests)

### Maintainability
- [ ] No duplication
- [ ] Follows naming conventions
- [ ] Uses fixtures/builders
- [ ] Clear assertions
- [ ] Good documentation

### Completeness
- [ ] Preconditions stated
- [ ] Test data specified
- [ ] Expected results clear
- [ ] Priority assigned
- [ ] Test type identified

---

## Common Pitfalls to Avoid

### 1. Testing Implementation, Not Behavior

**Bad**:
```python
def test_uses_cache():
    result = get_user(123)
    assert cache.get.called  # Testing implementation
```

**Good**:
```python
def test_repeated_calls_are_fast():
    first_call_time = time_execution(lambda: get_user(123))
    second_call_time = time_execution(lambda: get_user(123))
    assert second_call_time < first_call_time / 10  # Testing behavior
```

---

### 2. Multiple Assertions Testing Different Things

**Bad**:
```python
def test_user_creation():
    user = create_user("John")
    assert user.name == "John"
    assert user.is_active == True
    assert user.created_at is not None
    assert len(User.all()) == 1  # Different concept
```

**Good**:
```python
def test_user_creation_sets_correct_attributes():
    user = create_user("John")
    assert user.name == "John"
    assert user.is_active == True
    assert user.created_at is not None

def test_user_creation_adds_to_database():
    create_user("John")
    assert len(User.all()) == 1
```

---

### 3. Non-Deterministic Tests

**Bad**:
```python
def test_random_feature():
    value = get_random_value()  # Different every time
    assert value < 100  # May fail randomly
```

**Good**:
```python
def test_random_feature():
    random.seed(42)  # Fixed seed
    value = get_random_value()
    assert value == 87  # Always same result
```

---

### 4. Over-Mocking

**Bad**:
```python
def test_process_order(mocker):
    mocker.patch('module.validate')
    mocker.patch('module.calculate')
    mocker.patch('module.save')
    # Everything mocked, testing nothing real
```

**Better**:
```python
def test_process_order():
    # Use real validation and calculation
    # Only mock external services (database, APIs)
    with mock_database():
        result = process_order(order)
        assert result.total == expected_total
```

---

## Summary

**Key Techniques**:

1. **Equivalence Partitioning**: Group similar inputs
2. **Boundary Value Analysis**: Test at edges
3. **Decision Table**: Test all condition combinations
4. **State Transition**: Test state changes
5. **Use Case Testing**: Test user scenarios
6. **Error Guessing**: Anticipate common errors
7. **Pairwise Testing**: Efficient combinatorial testing

**Best Practices**:

- Use multiple techniques together
- Prioritize based on risk
- Keep tests independent
- Use realistic test data
- Clear, descriptive names
- Fast, repeatable execution

**Recommended Reading**:
- "Software Testing Techniques" by Boris Beizer
- "Lessons Learned in Software Testing" by Cem Kaner
- "Perfect Software and Other Illusions about Testing" by Gerald Weinberg
