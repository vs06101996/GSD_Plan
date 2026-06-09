# Product spec: Uber-Eats order service (in-memory)

Build a **Go library** (no HTTP server required) that models food-delivery orders with an actor-guarded state machine. Money is always **integer cents** (`int64`); never use floats for money.

## Module

- Go module name: **`uber-eats`**
- Go version: 1.22+
- Dependency allowed: `github.com/google/uuid`

## Domain types

### Identifiers and menu

- `ItemID` — integer type for menu item IDs.
- `Item` — `Id`, `ItemName`, `ItemDetail`, `Price` (cents).
- `Quantity` — integer type for line quantities.

### Customer and restaurant

- `Customer` — `Id` (UUID), `Name`, `Address`.
- `Restaurant` — `Id` (UUID), `Name`, `Address`, `Menu` (slice of `Item`).

### Order status and actors

**Status** (iota order):

| Value | Name |
|-------|------|
| 0 | Pending |
| 1 | Confirmed |
| 2 | Preparing |
| 3 | PickedUp |
| 4 | Delivered |
| 5 | Cancelled |
| 6 | Rejected |

**Actor** (iota order):

| Value | Name |
|-------|------|
| 0 | Customer |
| 1 | Restaurant |
| 2 | Driver |
| 3 | System |

### Delivery fee strategies

Implement `DeliveryFeeStrategy` with method `CalculateDeliveryFee(distanceKm float64) int64`:

- **FlatDeliveryFee** — fixed `FeeInCents`.
- **DistanceBasedFee** — `BaseFeeInCents + int64(distanceKm) * PerKmFeeInCents` (truncate toward zero).
- **FreeDeliveryFee** — always 0.
- **SurgeDeliveryFee** — wraps another `DeliveryFeeStrategy` and multiplies result by `Multiplier` (float); result truncated to `int64`.

### Order

- Fields: `Id` (UUID), `Owner` (*Customer), `PlacedFrom` (*Restaurant), `OrderItems` (map ItemID → `OrderLine`), `TotalPrice` (cents), `DeliveryFee` (strategy), `DistanceKm` (float).
- `OrderLine`: `Quantity`, `PriceAtOrder` (menu price snapshot in cents at order time).
- Status is private; expose `GetStatus()` / `SetStatus()` with per-order mutex (`Lock`/`Unlock` on Order).
- **`CalculateTotal()`** — sum of `PriceAtOrder * Quantity` for all lines, plus delivery fee from strategy and `DistanceKm`; store in `TotalPrice` and return it.

## State machine

Legal transitions (invalid transitions must return a non-nil error):

| From | To | Allowed actor(s) | Notes |
|------|-----|------------------|-------|
| Pending | Confirmed | (guard only) | Require non-empty `OrderItems` and non-nil `PlacedFrom` |
| Pending | Rejected | Restaurant only | |
| Pending | Cancelled | Customer or System | |
| Confirmed | Preparing | Restaurant only | |
| Confirmed | Cancelled | Customer or System | |
| Preparing | PickedUp | Driver only | |
| Preparing | Cancelled | (no actor guard in reference) | allow transition |
| PickedUp | Delivered | Driver only | |
| Delivered, Cancelled, Rejected | — | terminal | no further transitions |

On transition: find matching edge, run **Guard** (if any), set status, run **Action** (if any); if Action fails, **rollback** status to previous value.

## Order service (public API)

Package path: **`internals/service`** (import as `uber-eats/internals/service`).

```go
type OrderService struct { /* in-memory store + state machine */ }

func NewOrderService() *OrderService

func (s *OrderService) CreateOrder(
    customer *entities.Customer,
    restaurant *entities.Restaurant,
    itemQuantities map[entities.ItemID]entities.Quantity,
    deliveryFee entities.DeliveryFeeStrategy,
    distanceKm float64,
) (*entities.Order, error)
```

- Reject unknown menu item IDs with error.
- Snapshot menu prices into `OrderLine.PriceAtOrder`.
- Call `CalculateTotal()` before persisting.
- New orders start in **Pending**.
- Thread-safe storage (e.g. `sync.RWMutex`).

```go
func (s *OrderService) Transition(orderID uuid.UUID, to entities.Status, actor entities.Actor) error
```

- Return error if order ID not found.
- Delegate to state machine `Apply(order, to, actor)`.

```go
func (s *OrderService) GetOrder(orderID uuid.UUID) (*entities.Order, error)
```

- Return error if not found.

Entities live in package **`internals/entities`**. State machine in **`internals/stateMachine`** with `NewStateMachine()` and `Apply(order, to, actor) error`.

## Acceptance criteria (behavioral; tests are not provided)

1. Create order with known menu items → correct `TotalPrice` including flat fee (example: items 1×2 and 2×1 at prices 1299 and 1499, flat fee 299, distance 5.0 → total **4396** cents).
2. Unknown menu item → error, no order stored.
3. Happy path transitions: Pending → Confirmed (customer) → Preparing (restaurant) → PickedUp (driver) → Delivered (driver).
4. Authorization: customer cannot Pending→Preparing; restaurant can Confirmed→Preparing; customer cannot Preparing→PickedUp; driver can; customer cannot Pending→Rejected; restaurant can.
5. Transition on unknown order ID → error.
6. Invalid jump (e.g. Pending → Delivered) → error.

## Non-goals

- HTTP/API server, database, message queues.
- Payment processing implementation (actions may be no-ops).
- Notifications (comments in actions are fine).

## Deliverable

A compilable Go module `uber-eats` that passes `go build ./...` and `go vet ./...` and satisfies the behaviors above.
