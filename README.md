# Library System

Rails + React application for managing books and borrowings with roles (admin, librarian, student), JWT auth and SPA UI (Vite + React).

## Tech Stack
* Ruby 3.0.7 / Rails 7.1
* PostgreSQL
* Vite 5 + React 18
* Auth: JWT (`JsonWebToken`) + `has_secure_password`
* Authorization: Pundit
* Pagination: Kaminari
* Serialization: ActiveModelSerializers
* Tests: RSpec (primary) – legacy Minitest folder still present

## Features
* Book catalog CRUD (only `librarian` can create/update/destroy)
* Search books by title, author or genre (param `q`)
* Track total vs available copies
* Borrowings with automatic `borrowed_at`, `due_at` (14 days), status lifecycle: `borrowed | overdue | returned`
* Borrowings management page: filters, return action, overdue highlighting
* Return allowed even when overdue

## Roles & Permissions
| Role | Manage Books | Create Borrowings | View All Borrowings |
|------|--------------|------------------|---------------------|
| librarian | yes | no (students only) | yes |
| admin | no (per explicit rule) | no | yes |
| student | no | yes (one active per book) | only own |

## Quick Start
```bash
git clone git@github.com:luana-maia/library_system.git
cd library_system
bundle install
bin/rails db:setup   # create, migrate, seed
npm install
```

### Run (Development)
Separate processes:
```bash
bin/rails s -p 3000
npm run dev   # in another terminal (Vite on 5173)
```
App available at http://localhost:3000

### Environment
Uses Rails credentials (`config/master.key`). No extra ENV needed for dev.

## Seed Users (Login)
| Email | Password | Role |
|-------|----------|------|
| admin@example.com | password | admin |
| librarian@example.com | password | librarian |
| student@example.com | password | student |

## Authentication
POST `/api/login`
Request:
```json
{ "email": "student@example.com", "password": "password" }
```
Response 200:
```json
{ "token": "<jwt>", "user": { "id": 1, "name": "Student", "role": "student" } }
```
Use header: `Authorization: Bearer <jwt>`

## Main Endpoints
### Books
| Method | Path | Description | Permission |
|--------|------|-------------|------------|
| GET | /api/books | List (paged) | public* |
| GET | /api/books?q=term | Search | public* |
| POST | /api/books | Create | librarian |
| PATCH | /api/books/:id | Update | librarian |
| DELETE | /api/books/:id | Delete | librarian |

Payload (create/update):
```json
{ "book": { "title": "Clean Code", "author": "Robert", "isbn": "978...", "genre": "Software", "total_copies": 5, "available_copies": 5 } }
```

### Borrowings
| Method | Path | Description | Permission |
|--------|------|-------------|------------|
| GET | /api/borrowings | List (scoped) | authenticated |
| GET | /api/borrowings/overdue | Overdue only | authenticated |
| POST | /api/borrowings | Create borrowing | student |
| POST | /api/borrowings/:id/return_book | Return | owner or librarian/admin |

Create payload:
```json
{ "borrowing": { "book_id": 3 } }
```
Response includes computed fields: `borrow_duration_days`, `days_remaining`.

### (If present) Dashboard
| GET | /api/dashboard/summary |

## Borrowing Status Values
* borrowed – active
* overdue – active past due date (return still allowed)
* returned – completed (has `returned_at`)

## Front-end
React SPA (code under `app/frontend`). JWT stored in `localStorage`. Pages: Books, Borrowings, Login.

## Tests
Run:
```bash
bundle exec rspec
```
Coverage:
* Models: Book, Borrowing
* Policies: BookPolicy, BorrowingPolicy
* Requests: Auth, Books, Borrowings
Legacy Minitest folder `test/` can be removed once fully migrated.

## JWT Structure
Payload includes `user_id` and `exp` (24h). Invalid/expired tokens return `nil` from decoder.

## Common Errors
| Case | Cause | Fix |
|------|-------|-----|
| 403 Not authorized | Lacking role | Use librarian or owner |
| 422 You already have this book borrowed | Duplicate active borrowing | Return existing first |
| 422 No copies available | Inventory exhausted | Wait for a return |

## Future Enhancements
* Background job to mark overdue
* Due date notifications
* CSV export
* Borrowings pagination UI
* Additional specs: JWT expiry, User model

## Thought Process & Architecture Overview
This section documents the reasoning behind the implementation steps and key trade‑offs made during the exercise.

### 1. Core Objectives
Deliver a small but complete library management system supporting:
* Role‑based access control (librarian manages books; students borrow; admin has visibility but intentionally restricted from book CRUD per requirement)
* Inventory integrity (available copies never negative; borrow/return adjusts counts)
* Borrowing lifecycle with due date and overdue visibility
* Simple, fast to iterate front‑end (React SPA) coexisting inside Rails repo

### 2. Technology Choices
| Area | Choice | Rationale |
|------|--------|-----------|
| Auth | JWT + stateless header | Simple for SPA; avoids session store complexity |
| Authorization | Pundit | Lightweight, explicit policy classes, easy to test |
| Serialization | ActiveModelSerializers | Quick attribute control; adequate for small API |
| Pagination | Kaminari | Widely used; minimal configuration |
| Front-end build | Vite (no React fast refresh plugin) | Faster dev build vs Webpacker; removed plugin to avoid preamble issues |
| Tests | RSpec (plus temporary legacy Minitest) | More expressive DSL for policies & requests |

### 3. Data & Domain Modeling
Entities: User, Book, Borrowing.
* Book owns inventory state (`total_copies`, `available_copies`); callback sets `available_copies` on create.
* Borrowing enforces invariants: availability, uniqueness of active borrowing per user+book.
* Computed fields (`borrow_duration_days`, `days_remaining`) exposed at API layer to eliminate duplicated front‑end date math.

### 4. Security Considerations
* JWT includes `exp` (24h) to discourage long‑lived tokens.
* No refresh tokens (simplicity > full token rotation) – acceptable for exercise scope.
* Pundit `NotAuthorizedError` centrally trapped returning 403 JSON.

### 5. UX Decisions
* Librarian UI hides student‑only actions (borrow buttons, status column) to reduce noise.
* Inline edit for books chosen over separate modal to speed librarian workflows.
* Overdue items still show return action to avoid “dead” rows.
* Search implemented server‑side (LIKE with sanitized pattern) + debounced input on client.

### 6. Performance & Scalability Notes
Current scale assumptions are modest. Potential scaling steps:
* Add DB indexes: `books(isbn)`, `borrowings(user_id, book_id, returned_at)` (some may already exist via PK / FK — can extend if dataset grows).
* Replace LIKE search with full‑text (PG trigram / tsvector) if required.
* Introduce background job to tag overdue rather than computing in scope, if volume impacts query latency.

### 7. Testing Strategy
Focused on behavior with highest risk:
* Policies (enforcing role boundaries)
* Borrowing constraints (inventory decrement, duplicate prevention)
* Book search semantics
* Request flow (auth + CRUD + edge conditions)
Deferred (future): JWT expiry handling test, user model validations, pagination metadata assertions.

### 8. Trade-offs Accepted
* No refresh token / revoke list – simpler but less secure for stolen tokens.
* AMS chosen over JBuilder/Blueprinter for speed; can swap if performance concerns arise.
* Overdue marking is implicit (scope) not persisted—keeps data write‑light but any historical reporting would require persisted state.

### 9. Developer Onboarding TL;DR
1. `bundle install && npm install`
2. `bin/rails db:setup`
3. `bin/rails s` + `npm run dev`
4. Login as `librarian@example.com / password`
5. Run specs: `bundle exec rspec`

## Useful Commands
```bash
# Reset database
bin/rails db:drop db:create db:migrate db:seed

# Console
bin/rails c

# Single spec
bundle exec rspec spec/models/book_spec.rb
```

## Security Notes
* Tokens expire after 24h
* No refresh token – re-login required after expiry

## License
Internal / educational (adjust as needed).

---
