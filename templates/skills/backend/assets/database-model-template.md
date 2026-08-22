# Database Model Template

Use this template for creating SQLAlchemy database models with proper relationships, indexes, and constraints.

## Module Header

```python
"""
Database Model: {model_name}
Description: {brief_description}
Relationships: {list_relationships}
"""

from sqlalchemy import (
    Column, Integer, String, Text, Boolean, DateTime,
    ForeignKey, Index, UniqueConstraint, CheckConstraint
)
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property
from datetime import datetime
from .base import Base
import logging

logger = logging.getLogger(__name__)
```

## Basic Model Structure

```python
class {ModelName}(Base):
    """
    {ModelName} model for storing {description}.

    Attributes:
        id: Primary key
        name: {Description of name field}
        description: {Description of description field}
        created_at: Timestamp of creation
        updated_at: Timestamp of last update

    Relationships:
        - Many-to-one with {RelatedModel} ({relationship_name})
        - One-to-many with {RelatedModel} ({relationship_name})
        - Many-to-many with {RelatedModel} (via {AssociationTable})
    """
    __tablename__ = "{table_name}"

    # Primary Key
    id = Column(Integer, primary_key=True, index=True)

    # Basic Fields
    name = Column(
        String(100),
        nullable=False,
        index=True,
        comment="Name of the {resource}"
    )
    description = Column(
        Text,
        nullable=True,
        comment="Optional description"
    )

    # Boolean Flags
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        index=True,
        comment="Whether the {resource} is active"
    )

    # Foreign Keys
    created_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        comment="User who created this {resource}"
    )

    # Timestamps
    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
        index=True,
        comment="Timestamp of creation"
    )
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=True,
        comment="Timestamp of last update"
    )

    # Relationships
    creator = relationship(
        "User",
        back_populates="{resources}",
        lazy="joined"  # Use joined loading for frequently accessed relations
    )

    # Composite Indexes for common queries
    __table_args__ = (
        # Index for querying by creator and creation date
        Index('idx_{table_name}_creator_created', 'created_by', 'created_at'),

        # Unique constraint on name per creator
        UniqueConstraint('name', 'created_by', name='uq_{table_name}_name_creator'),

        # Check constraint for validation
        CheckConstraint(
            "length(name) >= 1",
            name='ck_{table_name}_name_not_empty'
        ),
    )

    def __repr__(self):
        return f"<{ModelName}(id={self.id}, name='{self.name}')>"

    def __str__(self):
        return self.name
```

## Many-to-One Relationship

```python
class Order(Base):
    """Order model - many orders belong to one user."""
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)

    # Foreign key to user
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )

    # Relationship - many orders to one user
    user = relationship(
        "User",
        back_populates="orders",
        lazy="joined"  # Eager load user when loading order
    )

    __table_args__ = (
        Index('idx_orders_user_created', 'user_id', 'created_at'),
    )
```

## One-to-Many Relationship

```python
class User(Base):
    """User model - one user has many orders."""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)

    # Relationship - one user has many orders
    orders = relationship(
        "Order",
        back_populates="user",
        lazy="dynamic",  # Use dynamic for large collections
        cascade="all, delete-orphan"  # Delete orders when user deleted
    )
```

## Many-to-Many Relationship

```python
# Association table for many-to-many
user_roles = Table(
    'user_roles',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('role_id', Integer, ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
    Column('assigned_at', DateTime, default=datetime.utcnow, nullable=False),
    Index('idx_user_roles_user', 'user_id'),
    Index('idx_user_roles_role', 'role_id'),
)


class User(Base):
    """User model with many-to-many roles."""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)

    # Many-to-many relationship with Role
    roles = relationship(
        "Role",
        secondary=user_roles,
        back_populates="users",
        lazy="selectin"  # Efficient for many-to-many
    )


class Role(Base):
    """Role model."""
    __tablename__ = "roles"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False, index=True)

    # Many-to-many relationship with User
    users = relationship(
        "User",
        secondary=user_roles,
        back_populates="roles",
        lazy="dynamic"
    )
```

## Self-Referential Relationship (Tree Structure)

```python
class Category(Base):
    """Category model with parent-child hierarchy."""
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)

    # Self-referential foreign key
    parent_id = Column(
        Integer,
        ForeignKey('categories.id', ondelete='CASCADE'),
        nullable=True,
        index=True
    )

    # Self-referential relationships
    parent = relationship(
        "Category",
        remote_side=[id],  # Specify the remote side
        back_populates="children"
    )

    children = relationship(
        "Category",
        back_populates="parent",
        cascade="all, delete-orphan"
    )

    __table_args__ = (
        Index('idx_categories_parent', 'parent_id'),
    )
```

## Hybrid Properties (Computed Fields)

```python
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy import select, func


class Product(Base):
    """Product model with computed properties."""
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    price_cents = Column(Integer, nullable=False)  # Store price in cents
    tax_rate = Column(Integer, default=20)  # Tax rate as percentage

    @hybrid_property
    def price(self):
        """Price in dollars (computed from cents)."""
        return self.price_cents / 100

    @price.setter
    def price(self, value):
        """Set price in dollars (stored as cents)."""
        self.price_cents = int(value * 100)

    @price.expression
    def price(cls):
        """SQL expression for price queries."""
        return cls.price_cents / 100

    @hybrid_property
    def price_with_tax(self):
        """Price including tax."""
        return self.price * (1 + self.tax_rate / 100)

    @price_with_tax.expression
    def price_with_tax(cls):
        """SQL expression for querying by price with tax."""
        return (cls.price_cents / 100) * (1 + cls.tax_rate / 100)
```

## Polymorphic Models (Single Table Inheritance)

```python
class Vehicle(Base):
    """Base vehicle model with polymorphic identity."""
    __tablename__ = "vehicles"

    id = Column(Integer, primary_key=True, index=True)
    type = Column(String(50), nullable=False, index=True)  # Discriminator column
    make = Column(String(50), nullable=False)
    model = Column(String(50), nullable=False)

    __mapper_args__ = {
        'polymorphic_identity': 'vehicle',
        'polymorphic_on': type
    }


class Car(Vehicle):
    """Car model (inherits from Vehicle)."""
    num_doors = Column(Integer)

    __mapper_args__ = {
        'polymorphic_identity': 'car',
    }


class Motorcycle(Vehicle):
    """Motorcycle model (inherits from Vehicle)."""
    has_sidecar = Column(Boolean, default=False)

    __mapper_args__ = {
        'polymorphic_identity': 'motorcycle',
    }
```

## Soft Delete Pattern

```python
class SoftDeleteMixin:
    """Mixin for soft delete functionality."""
    deleted_at = Column(DateTime, nullable=True, index=True)

    @hybrid_property
    def is_deleted(self):
        """Check if record is soft deleted."""
        return self.deleted_at is not None

    def soft_delete(self):
        """Mark record as deleted."""
        self.deleted_at = datetime.utcnow()

    def restore(self):
        """Restore soft deleted record."""
        self.deleted_at = None


class Product(SoftDeleteMixin, Base):
    """Product with soft delete."""
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)

    @classmethod
    def active_only(cls):
        """Query helper for active (non-deleted) records."""
        return select(cls).where(cls.deleted_at.is_(None))
```

## Audit Trail Pattern

```python
class AuditMixin:
    """Mixin for audit trail fields."""
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    updated_by = Column(Integer, ForeignKey("users.id"))

    # Track IP addresses
    created_from_ip = Column(String(45))  # IPv6 max length
    updated_from_ip = Column(String(45))


class Document(AuditMixin, Base):
    """Document with full audit trail."""
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    content = Column(Text)

    # Relationships for audit fields
    creator = relationship("User", foreign_keys=[AuditMixin.created_by])
    updater = relationship("User", foreign_keys=[AuditMixin.updated_by])
```

## Usage Instructions

1. **Copy this template** to your models file
2. **Replace placeholders**:
   - `{ModelName}` - Capitalized model name (e.g., "User", "Product")
   - `{table_name}` - Lowercase table name (e.g., "users", "products")
   - `{description}` - Brief description of what the model represents
   - `{resource}` - Lowercase singular resource name
3. **Add fields** - Include all necessary columns for your domain
4. **Define relationships** - Add foreign keys and SQLAlchemy relationships
5. **Add indexes** - Index frequently queried columns
6. **Add constraints** - Add unique constraints, check constraints as needed
7. **Consider mixins** - Use audit, soft delete mixins if appropriate
8. **Write migrations** - Create Alembic migration for the model

## Checklist

- [ ] Primary key defined (usually auto-incrementing integer)
- [ ] All foreign keys have proper ondelete behavior
- [ ] Frequently queried columns are indexed
- [ ] Composite indexes added for multi-column queries
- [ ] Unique constraints added where needed
- [ ] Relationships defined on both sides (bidirectional)
- [ ] Appropriate lazy loading strategy chosen
- [ ] Timestamps (created_at, updated_at) included
- [ ] __repr__ and __str__ methods implemented
- [ ] Table args include all indexes and constraints
- [ ] Comments added to columns for documentation
- [ ] Cascade behavior defined for relationships

## Index Strategy Guide

**When to add indexes:**
- ✅ Primary keys (automatic)
- ✅ Foreign keys (always)
- ✅ Unique fields (email, username)
- ✅ Frequently filtered columns (is_active, type)
- ✅ Frequently sorted columns (created_at)
- ✅ Composite indexes for multi-column queries

**When NOT to add indexes:**
- ❌ Low-cardinality boolean fields (unless frequently queried)
- ❌ Rarely queried columns
- ❌ Write-heavy tables (indexes slow down writes)

## Relationship Loading Strategies

- **lazy="joined"** - Eager load with JOIN (best for frequently accessed, one-to-one)
- **lazy="selectin"** - Efficient for one-to-many, many-to-many
- **lazy="dynamic"** - Returns query object (best for large collections)
- **lazy="subquery"** - Load with subquery (alternative to selectin)
