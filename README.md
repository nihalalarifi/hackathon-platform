# Hackathon Platform

A full-stack hackathon management platform built for a 24-hour hackathon competition. It handles participant registration, team formation, mentor session scheduling, judge scoring, and event scheduling through a REST API backend and a Flutter web frontend.

---

## Why We Built This

Managing a hackathon involves coordinating dozens of moving parts — participants forming teams, mentors booking sessions, judges selecting winners, and organizers tracking the schedule. Existing tools are either too generic or too heavyweight for a single-event hackathon. We built a purpose-specific platform that gives every role (participant, mentor, judge, organizer) their own dedicated interface and permissions, all running from a single deployable stack.

---

## Features

- **Role-based access control** — four distinct roles (Participant, Mentor, Judge, Organizer) each with scoped permissions and dedicated API endpoints
- **Team management** — participants can create teams, join existing ones, and leave; team state is persisted in a relational database
- **Mentor session system** — mentors can create, update, and delete advisory sessions; participants can browse and book available slots
- **Judge winner selection** — judges can nominate and remove winning teams through a protected API
- **Event schedule management** — organizers can post and update the hackathon schedule visible to all participants
- **JWT authentication** — stateless token-based auth with role enforcement on every protected endpoint
- **Flutter web frontend** — cross-platform UI built in Dart, communicating with the backend over HTTP

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Python 3.8+ | Backend language |
| Flask | REST API framework |
| Flask-SQLAlchemy | ORM and database management |
| SQLite | Lightweight relational database |
| Flask-CORS | Cross-origin request handling for Flutter web |
| PyJWT | JWT token generation and validation |
| Werkzeug | Password hashing |
| Flutter / Dart | Cross-platform frontend (web target) |
| HTTP package (Dart) | API communication from frontend |
| shared_preferences | Local token storage on the client |

---

## Project Structure

```
hackathon-platform/
├── backend/
│   ├── app.py              # Flask REST API — all models, routes, and auth logic
│   └── requirements.txt    # Python dependencies
├── frontend/
│   ├── lib/
│   │   └── main.dart       # Complete Flutter application
│   └── pubspec.yaml        # Flutter dependencies
├── setup.sh                # Automated setup script
└── README.md
```

---

## Installation & Setup

### Option 1 — Automated setup

```bash
git clone https://github.com/nihalalarifi/hackathon-platform.git
cd hackathon-platform
chmod +x setup.sh
./setup.sh
```

### Option 2 — Manual setup

**Backend:**

```bash
cd backend
pip3 install -r requirements.txt
python3 app.py
# API runs at http://localhost:5000
```

**Frontend:**

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Configure the backend URL
# Open lib/main.dart and update the baseUrl variable:
# Change: http://YOUR_BACKEND_HOST:5000/api
# To:     http://localhost:5000/api  (or your server's IP)

# Run in browser
flutter run -d chrome
```

---

## Environment Configuration

Before running, update the following values:

**backend/app.py**
```python
app.config['SECRET_KEY'] = 'YOUR_SECRET_KEY_HERE'
# Replace with a strong random string, e.g.:
# python3 -c "import secrets; print(secrets.token_hex(32))"
```

**frontend/lib/main.dart**
```dart
static const String baseUrl = 'http://YOUR_BACKEND_HOST:5000/api';
// Replace YOUR_BACKEND_HOST with localhost or your server IP
```

---

## API Overview

| Method | Endpoint | Role | Description |
|---|---|---|---|
| POST | /api/register | Public | Create a user account |
| POST | /api/login | Public | Authenticate and receive JWT token |
| GET | /api/profile | Any | Get current user profile |
| POST | /api/register/participant | Any | Register as a participant |
| POST | /api/register/mentor | Any | Register as a mentor |
| POST | /api/register/judge | Any | Register as a judge |
| GET | /api/teams | Any | List all teams |
| POST | /api/teams | Participant | Create a team |
| POST | /api/teams/:id/join | Participant | Join a team |
| GET | /api/mentor/sessions | Any | Browse mentor sessions |
| POST | /api/mentor/sessions | Mentor | Create a session |
| PUT | /api/mentor/sessions/:id | Mentor | Update a session |
| DELETE | /api/mentor/sessions/:id | Mentor | Delete a session |
| POST | /api/judge/select-winner | Judge | Nominate a winning team |
| GET | /api/schedule | Any | View event schedule |
| POST | /api/schedule | Organizer | Add a schedule item |

---

## Technical Challenge

The trickiest part was handling CORS correctly for the Flutter web target.

Flutter web compiles to JavaScript and runs in a browser, which enforces strict CORS policies. Unlike a native mobile app, every API call goes through the browser's preflight check — meaning the backend had to respond correctly to `OPTIONS` requests before the real request was even attempted. The default Flask-CORS setup was not sufficient because preflight responses were missing the right headers, causing the frontend to silently fail.

The fix required adding an explicit `OPTIONS` route that catches all `/api/*` paths and returns the correct headers with a `Access-Control-Max-Age` to cache preflight results, plus an `after_request` hook to ensure headers were always attached to actual responses. This brought the frontend-backend communication to a fully working state under Flutter web's stricter browser environment.

---

## License

MIT
