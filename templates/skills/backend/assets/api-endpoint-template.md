# API Endpoint Implementation Template

Use this template for implementing RESTful API endpoints with FastAPI or similar frameworks.

## Module Header

```python
"""
API Module: {module_name}
Endpoints: {list_of_endpoints}
Description: {brief_description}
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/{resource}", tags=["{resource}"])
```

## Request/Response Schemas

```python
class {Resource}Create(BaseModel):
    """Schema for creating a {resource}."""
    name: str = Field(..., min_length=1, max_length=100, description="Resource name")
    description: Optional[str] = Field(None, max_length=500, description="Optional description")

    class Config:
        schema_extra = {
            "example": {
                "name": "Example Resource",
                "description": "An example description"
            }
        }


class {Resource}Update(BaseModel):
    """Schema for updating a {resource}."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)


class {Resource}Response(BaseModel):
    """Schema for {resource} response."""
    id: int
    name: str
    description: Optional[str]
    created_at: str
    updated_at: Optional[str]

    class Config:
        orm_mode = True


class {Resource}ListResponse(BaseModel):
    """Schema for paginated {resource} list."""
    items: List[{Resource}Response]
    total: int
    page: int
    page_size: int
```

## Create Endpoint

```python
@router.post(
    "/{resources}",
    response_model={Resource}Response,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new {resource}",
    response_description="The created {resource}"
)
async def create_{resource}(
    {resource}: {Resource}Create,
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new {resource}.

    - **name**: Resource name (required, 1-100 chars)
    - **description**: Optional description (max 500 chars)

    Returns the created {resource} with ID and timestamp.

    Raises:
        - 400: Invalid input data
        - 401: Missing or invalid authentication
        - 409: Resource with this name already exists
        - 500: Internal server error
    """
    try:
        # Validate and create resource
        new_{resource} = await {resource}_service.create(
            data={resource}.dict(),
            user_id=current_user["id"]
        )
        logger.info(f"{Resource} created: {new_{resource}.id} by user {current_user['id']}")
        return new_{resource}

    except DuplicateError as e:
        logger.warning(f"Duplicate {resource}: {e}")
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"{Resource} with this name already exists"
        )
    except ValidationError as e:
        logger.warning(f"Validation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error creating {resource}: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create {resource}"
        )
```

## Get Single Resource

```python
@router.get(
    "/{resources}/{{{resource}_id}}",
    response_model={Resource}Response,
    summary="Get a {resource} by ID"
)
async def get_{resource}(
    {resource}_id: int,
    current_user: dict = Depends(get_current_user)
):
    """
    Retrieve a specific {resource} by ID.

    Raises:
        - 401: Missing or invalid authentication
        - 403: Insufficient permissions
        - 404: Resource not found
    """
    {resource} = await {resource}_service.get_by_id({resource}_id)

    if not {resource}:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{Resource} not found"
        )

    # Check permissions
    if not await has_access(current_user, {resource}):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to access this {resource}"
        )

    return {resource}
```

## List Resources (Paginated)

```python
@router.get(
    "/{resources}",
    response_model={Resource}ListResponse,
    summary="List {resources} with pagination"
)
async def list_{resources}(
    page: int = Query(1, ge=1, description="Page number (1-indexed)"),
    page_size: int = Query(20, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, max_length=100, description="Search term"),
    current_user: dict = Depends(get_current_user)
):
    """
    List {resources} with pagination and optional search.

    Query Parameters:
        - page: Page number (default: 1)
        - page_size: Items per page (default: 20, max: 100)
        - search: Optional search term

    Returns paginated list with total count.
    """
    filters = {"user_id": current_user["id"]}
    if search:
        filters["search"] = search

    {resources}, total = await {resource}_service.list_paginated(
        page=page,
        page_size=page_size,
        filters=filters
    )

    return {Resource}ListResponse(
        items={resources},
        total=total,
        page=page,
        page_size=page_size
    )
```

## Update Endpoint

```python
@router.patch(
    "/{resources}/{{{resource}_id}}",
    response_model={Resource}Response,
    summary="Update a {resource}"
)
async def update_{resource}(
    {resource}_id: int,
    {resource}_update: {Resource}Update,
    current_user: dict = Depends(get_current_user)
):
    """
    Update an existing {resource}.

    Only provided fields will be updated (partial update).

    Raises:
        - 400: Invalid input data
        - 401: Missing or invalid authentication
        - 403: Insufficient permissions
        - 404: Resource not found
        - 409: Update would create duplicate
    """
    # Check existence and permissions
    existing = await {resource}_service.get_by_id({resource}_id)
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{Resource} not found"
        )

    if not await has_write_access(current_user, existing):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this {resource}"
        )

    try:
        # Update only provided fields
        update_data = {resource}_update.dict(exclude_unset=True)
        updated_{resource} = await {resource}_service.update(
            {resource}_id=={resource}_id,
            data=update_data
        )
        logger.info(f"{Resource} updated: {resource}_id by user {current_user['id']}")
        return updated_{resource}

    except DuplicateError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Update would create duplicate {resource}"
        )
    except Exception as e:
        logger.error(f"Error updating {resource}: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update {resource}"
        )
```

## Delete Endpoint

```python
@router.delete(
    "/{resources}/{{{resource}_id}}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a {resource}"
)
async def delete_{resource}(
    {resource}_id: int,
    current_user: dict = Depends(get_current_user)
):
    """
    Delete a {resource}.

    Returns 204 No Content on success.

    Raises:
        - 401: Missing or invalid authentication
        - 403: Insufficient permissions
        - 404: Resource not found
        - 409: Cannot delete (has dependencies)
    """
    # Check existence and permissions
    existing = await {resource}_service.get_by_id({resource}_id)
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{Resource} not found"
        )

    if not await has_delete_access(current_user, existing):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to delete this {resource}"
        )

    try:
        await {resource}_service.delete({resource}_id)
        logger.info(f"{Resource} deleted: {resource}_id by user {current_user['id']}")
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    except IntegrityError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Cannot delete {resource} with existing dependencies"
        )
    except Exception as e:
        logger.error(f"Error deleting {resource}: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete {resource}"
        )
```

## Usage Instructions

1. **Copy this template** to your API module file
2. **Replace placeholders**:
   - `{module_name}` - Name of the module (e.g., "User Management API")
   - `{resource}` - Singular lowercase resource name (e.g., "user", "product")
   - `{Resource}` - Singular capitalized resource name (e.g., "User", "Product")
   - `{resources}` - Plural lowercase resource name (e.g., "users", "products")
   - `{list_of_endpoints}` - List of endpoints provided
3. **Customize schemas** - Add/remove fields as needed for your domain
4. **Implement service layer** - Create `{resource}_service` with business logic
5. **Add authentication** - Implement `get_current_user` dependency
6. **Add authorization** - Implement permission checks (`has_access`, etc.)
7. **Configure router** - Mount router in main application
8. **Write tests** - Integration tests for all endpoints

## Checklist

- [ ] All endpoints have Pydantic request/response schemas
- [ ] Authentication dependency added to all endpoints
- [ ] Authorization checks implemented where needed
- [ ] Proper HTTP status codes used (200, 201, 204, 400, 401, 403, 404, 409, 500)
- [ ] Comprehensive error handling with try/except
- [ ] Logging added for important operations
- [ ] Docstrings document parameters and error cases
- [ ] Pagination implemented for list endpoints
- [ ] Input validation with Field constraints
- [ ] Example payloads in schema_extra
