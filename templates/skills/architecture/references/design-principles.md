# Design Principles Reference

Core principles for creating maintainable, scalable, and robust software architectures.

## Table of Contents

1. [SOLID Principles](#solid-principles)
2. [General Design Principles](#general-design-principles)
3. [Microservices Principles](#microservices-principles)
4. [API Design Principles](#api-design-principles)
5. [Database Design Principles](#database-design-principles)

---

## SOLID Principles

### 1. Single Responsibility Principle (SRP)

**Definition:** A class/module should have one, and only one, reason to change.

**Key Insight:** Each component should do one thing well.

**Example (Violation):**
```python
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email

    def save_to_database(self):
        # Database logic - WRONG! Not user's responsibility
        db.execute("INSERT INTO users...")

    def send_email(self, message):
        # Email logic - WRONG! Not user's responsibility
        smtp.send(self.email, message)
```

**Example (Correct):**
```python
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email

class UserRepository:
    def save(self, user: User):
        # Database logic belongs here
        db.execute("INSERT INTO users...")

class EmailService:
    def send(self, to: str, message: str):
        # Email logic belongs here
        smtp.send(to, message)
```

**Benefits:**
- Easier to understand and maintain
- Changes to one responsibility don't affect others
- Better testability (mock dependencies)

---

### 2. Open/Closed Principle (OCP)

**Definition:** Software entities should be open for extension, but closed for modification.

**Key Insight:** Add new functionality without changing existing code.

**Example (Violation):**
```python
class PaymentProcessor:
    def process(self, payment_type: str, amount: float):
        if payment_type == "credit_card":
            # Process credit card
            pass
        elif payment_type == "paypal":
            # Process PayPal
            pass
        # Adding new payment type requires modifying this function!
```

**Example (Correct):**
```python
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    @abstractmethod
    def process(self, amount: float):
        pass

class CreditCardPayment(PaymentMethod):
    def process(self, amount: float):
        # Credit card logic
        pass

class PayPalPayment(PaymentMethod):
    def process(self, amount: float):
        # PayPal logic
        pass

class PaymentProcessor:
    def process(self, method: PaymentMethod, amount: float):
        # No modification needed for new payment types!
        method.process(amount)
```

**Benefits:**
- Add features without risking existing functionality
- Easier to extend system
- Reduced risk of bugs in existing code

---

### 3. Liskov Substitution Principle (LSP)

**Definition:** Objects of a superclass should be replaceable with objects of a subclass without breaking the application.

**Key Insight:** Subtypes must be substitutable for their base types.

**Example (Violation):**
```python
class Bird:
    def fly(self):
        return "Flying"

class Penguin(Bird):
    def fly(self):
        # Penguins can't fly! Violates LSP
        raise Exception("Penguins can't fly")

# This breaks when we substitute Penguin for Bird
def make_bird_fly(bird: Bird):
    bird.fly()  # Crashes if bird is Penguin
```

**Example (Correct):**
```python
class Bird:
    def move(self):
        pass

class FlyingBird(Bird):
    def move(self):
        return "Flying"

    def fly(self):
        return "Flying"

class Penguin(Bird):
    def move(self):
        return "Swimming"

# Now works with any Bird subclass
def make_bird_move(bird: Bird):
    bird.move()  # Works for all bird types
```

**Benefits:**
- Predictable behavior in inheritance hierarchies
- More robust polymorphism
- Fewer surprises when using subclasses

---

### 4. Interface Segregation Principle (ISP)

**Definition:** Clients should not be forced to depend on interfaces they don't use.

**Key Insight:** Create focused, specific interfaces rather than large, general ones.

**Example (Violation):**
```python
class Worker(ABC):
    @abstractmethod
    def work(self): pass

    @abstractmethod
    def eat(self): pass

    @abstractmethod
    def sleep(self): pass

class Robot(Worker):
    def work(self):
        return "Working"

    def eat(self):
        # Robots don't eat! Forced to implement unused method
        raise NotImplementedError

    def sleep(self):
        # Robots don't sleep! Forced to implement unused method
        raise NotImplementedError
```

**Example (Correct):**
```python
class Workable(ABC):
    @abstractmethod
    def work(self): pass

class Eatable(ABC):
    @abstractmethod
    def eat(self): pass

class Sleepable(ABC):
    @abstractmethod
    def sleep(self): pass

class Human(Workable, Eatable, Sleepable):
    def work(self): return "Working"
    def eat(self): return "Eating"
    def sleep(self): return "Sleeping"

class Robot(Workable):
    def work(self): return "Working"
    # Robot only implements what it needs
```

**Benefits:**
- More focused interfaces
- Easier to implement
- Better flexibility

---

### 5. Dependency Inversion Principle (DIP)

**Definition:** High-level modules should not depend on low-level modules. Both should depend on abstractions.

**Key Insight:** Depend on interfaces, not concrete implementations.

**Example (Violation):**
```python
class MySQLDatabase:
    def save(self, data):
        # MySQL-specific code
        pass

class UserService:
    def __init__(self):
        # Directly depends on MySQL - hard to swap databases
        self.db = MySQLDatabase()

    def create_user(self, user):
        self.db.save(user)
```

**Example (Correct):**
```python
from abc import ABC, abstractmethod

class Database(ABC):
    @abstractmethod
    def save(self, data): pass

class MySQLDatabase(Database):
    def save(self, data):
        # MySQL implementation
        pass

class PostgreSQLDatabase(Database):
    def save(self, data):
        # PostgreSQL implementation
        pass

class UserService:
    def __init__(self, db: Database):
        # Depends on abstraction - easy to swap implementations
        self.db = db

    def create_user(self, user):
        self.db.save(user)

# Dependency injection
service = UserService(MySQLDatabase())  # or PostgreSQLDatabase()
```

**Benefits:**
- Flexible, swappable implementations
- Easier testing (inject mocks)
- Reduced coupling

---

## General Design Principles

### 6. DRY (Don't Repeat Yourself)

**Definition:** Every piece of knowledge should have a single, unambiguous representation in the system.

**Key Insight:** Avoid duplication of logic.

**Example (Violation):**
```python
def calculate_total_with_tax(price):
    tax = price * 0.08
    return price + tax

def calculate_invoice_with_tax(invoice_amount):
    tax = invoice_amount * 0.08  # Duplicated tax calculation
    return invoice_amount + tax
```

**Example (Correct):**
```python
TAX_RATE = 0.08

def calculate_tax(amount):
    return amount * TAX_RATE

def calculate_total_with_tax(price):
    return price + calculate_tax(price)

def calculate_invoice_with_tax(invoice_amount):
    return invoice_amount + calculate_tax(invoice_amount)
```

**Caution:** Don't abstract too early. Duplication is cheaper than wrong abstraction. Wait for 3rd occurrence before abstracting.

---

### 7. KISS (Keep It Simple, Stupid)

**Definition:** Most systems work best if they are kept simple rather than made complex.

**Key Insight:** Prefer simple solutions over clever ones.

**Example (Over-complicated):**
```python
def is_even(n):
    # Overly clever using bitwise operations
    return (n & 1) == 0 and (n >> 1 << 1) == n
```

**Example (Simple):**
```python
def is_even(n):
    return n % 2 == 0
```

**Guidelines:**
- Choose clarity over cleverness
- Avoid premature optimization
- Use standard patterns over custom solutions
- Write code for humans, not computers

---

### 8. YAGNI (You Aren't Gonna Need It)

**Definition:** Don't add functionality until it's necessary.

**Key Insight:** Implement current requirements only. Don't build for hypothetical future needs.

**Example (YAGNI Violation):**
```python
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email
        # Adding features "just in case"
        self.preferences = {}  # Not needed yet
        self.settings = {}     # Not needed yet
        self.metadata = {}     # Not needed yet
        self.cache = {}        # Not needed yet
```

**Example (YAGNI Applied):**
```python
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email
        # Only what's needed now
        # Add other fields when requirements emerge
```

**Benefits:**
- Less code to maintain
- Faster development
- Avoid building wrong features

---

### 9. Separation of Concerns

**Definition:** Divide system into distinct features with minimal overlap.

**Key Insight:** Each part of the system should address a separate concern.

**Example:**
```python
# Business logic
class OrderService:
    def create_order(self, items):
        order = Order(items)
        return order

# Data persistence
class OrderRepository:
    def save(self, order):
        db.save(order)

# Presentation
class OrderController:
    def create(self, request):
        order = order_service.create_order(request.items)
        order_repository.save(order)
        return {"id": order.id}
```

**Benefits:**
- Easier to understand
- Better modularity
- Parallel development

---

### 10. Law of Demeter (Principle of Least Knowledge)

**Definition:** A method should only call methods of:
1. Itself
2. Its parameters
3. Objects it creates
4. Its direct dependencies

**Key Insight:** Don't talk to strangers. Avoid chaining method calls.

**Example (Violation):**
```python
# Reaching through multiple objects ("train wreck")
total = order.getCustomer().getAddress().getCountry().getTaxRate() * order.getTotal()
```

**Example (Correct):**
```python
# Order exposes method that handles internal complexity
total = order.getTotalWithTax()

# Inside Order class:
def getTotalWithTax(self):
    tax_rate = self.customer.getTaxRate()  # Customer knows how to get tax rate
    return self.total * (1 + tax_rate)
```

**Benefits:**
- Reduced coupling
- Easier refactoring
- More encapsulation

---

## Microservices Principles

### 11. Domain-Driven Design (DDD)

**Key Concepts:**

**Bounded Context:** Clear boundaries around related functionality.
```
┌─────────────────┐    ┌─────────────────┐
│ Order Context   │    │ Inventory       │
│ - Order         │    │   Context       │
│ - OrderItem     │    │ - Product       │
│ - Customer      │    │ - Stock         │
└─────────────────┘    └─────────────────┘
```

**Ubiquitous Language:** Use domain terminology consistently.
- Don't say "record" if domain experts say "prescription"
- Use exact business terms in code

**Aggregates:** Group of related entities treated as a unit.
```python
class Order:  # Aggregate root
    def __init__(self):
        self.items = []  # Part of aggregate

    def add_item(self, item):
        # Enforce business rules
        if len(self.items) >= 100:
            raise ValueError("Max 100 items per order")
        self.items.append(item)

# Always access OrderItems through Order, not directly
```

---

### 12. Service Boundaries

**Principle:** Services should be organized around business capabilities, not technical layers.

**Wrong (Technical Boundaries):**
```
- User Service
- Order Service
- Payment Service
- Notification Service
```

**Better (Business Capabilities):**
```
- Customer Management (user profile, preferences)
- Order Fulfillment (orders, payments, inventory)
- Communication (notifications, emails)
```

**Guidelines:**
- High cohesion within services
- Low coupling between services
- Services own their data
- Independent deployment

---

## API Design Principles

### 13. RESTful Design

**Resources Over Actions:**
```
❌ /getUser?id=123
❌ /createOrder
✅ GET /users/123
✅ POST /orders
```

**HTTP Verbs:**
- `GET` - Retrieve resource (idempotent, safe)
- `POST` - Create resource
- `PUT` - Replace resource (idempotent)
- `PATCH` - Update resource partially
- `DELETE` - Remove resource (idempotent)

**Status Codes:**
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success, no response body
- `400 Bad Request` - Client error
- `401 Unauthorized` - Authentication required
- `404 Not Found` - Resource doesn't exist
- `500 Internal Server Error` - Server error

---

### 14. API Versioning

**Principle:** Version APIs from day 1 to manage breaking changes.

**Strategies:**

**URL Path (Recommended):**
```
/v1/users
/v2/users
```

**Query Parameter:**
```
/users?version=1
```

**Header:**
```
Accept: application/vnd.api+json;version=1
```

**Guidelines:**
- Major version for breaking changes
- Maintain old versions for transition period
- Document deprecation timeline
- Provide migration guides

---

### 15. Idempotency

**Principle:** Multiple identical requests should have same effect as single request.

**Idempotent Operations:**
- `GET /users/123` - Safe to call multiple times
- `PUT /users/123` - Replaces user (same result)
- `DELETE /users/123` - Deletes user (same result)

**Non-Idempotent Operations:**
- `POST /orders` - Creates new order each time

**Making POST Idempotent:**
```http
POST /orders
Idempotency-Key: unique-request-id-123

# Server caches response for 24 hours
# Subsequent requests with same key return cached response
```

---

## Database Design Principles

### 16. Normalization

**Principle:** Organize data to reduce redundancy and dependency.

**First Normal Form (1NF):**
- Atomic values (no lists in columns)
- Unique column names
- Order doesn't matter

**Second Normal Form (2NF):**
- Meet 1NF
- No partial dependencies on composite keys

**Third Normal Form (3NF):**
- Meet 2NF
- No transitive dependencies

**When to Denormalize:**
- Read-heavy workloads
- Performance optimization
- Data warehouse/analytics
- Caching layer

---

### 17. Database per Service

**Principle:** In microservices, each service owns its database.

**Advantages:**
- Service independence
- Different database types per service
- Clear ownership

**Challenges:**
- Data consistency across services
- Joins across databases not possible
- Need event-driven sync

**Solution Patterns:**
- Saga pattern for distributed transactions
- Event sourcing for audit trail
- CQRS for read optimization

---

## Principles in Practice

### Checklist for Architecture Reviews

**Design Quality:**
- [ ] Components have single, clear responsibilities (SRP)
- [ ] Abstractions used for flexibility (DIP)
- [ ] No unnecessary complexity (KISS, YAGNI)
- [ ] Concerns properly separated

**Scalability:**
- [ ] Stateless design where possible
- [ ] Horizontal scaling supported
- [ ] Database scaling strategy defined

**Reliability:**
- [ ] Error handling comprehensive
- [ ] Retry logic for transient failures
- [ ] Circuit breakers for external dependencies
- [ ] Graceful degradation

**Maintainability:**
- [ ] Code is self-documenting
- [ ] Dependencies are explicit
- [ ] Testing strategy defined
- [ ] Clear ownership of components

---

## Anti-Patterns

### 1. God Object
**Problem:** One class/module does too much
**Solution:** Apply SRP, split responsibilities

### 2. Tight Coupling
**Problem:** Components depend heavily on each other
**Solution:** Depend on abstractions (DIP), use events

### 3. Premature Optimization
**Problem:** Optimizing before measuring
**Solution:** Measure first, optimize bottlenecks

### 4. Over-Engineering
**Problem:** Complex solution for simple problem
**Solution:** Apply KISS and YAGNI

### 5. Golden Hammer
**Problem:** Using same solution for every problem
**Solution:** Evaluate alternatives for each use case

---

## Further Reading

**Books:**
- "Clean Architecture" by Robert C. Martin
- "Domain-Driven Design" by Eric Evans
- "Building Microservices" by Sam Newman
- "Design Patterns" by Gang of Four

**Online Resources:**
- Martin Fowler's blog (martinfowler.com)
- Microsoft Azure Architecture Center
- AWS Well-Architected Framework

---

**Related References:**
- [Architectural Patterns](architectural-patterns.md)
- [Scalability Patterns](scalability-patterns.md)
- [System Design Methodology](system-design-methodology.md)
