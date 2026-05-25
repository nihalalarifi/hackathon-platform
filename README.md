# Hackathon Management Platform

A full-stack platform for managing hackathon events, built with a Flutter web frontend and a Flask REST API backend. It supports four user roles — participant, mentor, judge, and organizer — each with tailored features for managing teams, mentoring sessions, judging, and event scheduling.

## Why We Built This

Organizing a hackathon involves coordinating many moving parts: team formation, mentoring sessions, judging, and scheduling — typically handled through disconnected spreadsheets and group chats. This platform centralizes everything into one system, giving each role exactly the tools they need without the noise of everything else.

## Features

- **Role-based access control** — four distinct roles (Participant, Mentor, Judge, Organizer), each with a dedicated dashboard and permissions
- **Team management** — participants can create teams, invite others, and view team status in real time
- **Mentoring sessions** — mentors can schedule, edit, and delete sessions; participants can view and book them by team
- **Judging system** — judges can select and remove winners with full audit visibility
- **Event scheduling** — organizers can create and manage the hackathon schedule
- **JWT authentication** — secure stateless auth with token-based session management
- **Flutter web frontend** — single-page app with a dark cyberpunk-inspired UI, runs in any browser

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter (Dart) | Cross-platform web frontend |
| Flask (Python) | REST API backend |
| SQLAlchemy | ORM and database management |
| SQLite | Local relational database |
| Flask-CORS | Cross-origin request handling |
| PyJWT | JWT token generation and verification |
| Werkzeug | Password hashing |
| shared_preferences | Client-side token persistence |

## Project Structure

```
hackathon-platform/
├── backend/
│   ├── app.py              # Flask REST API — all routes, models, auth
│   └── requirements.txt    # Python dependencies
├── frontend/
│   ├── lib/
│   │   └── main.dart       # Flutter app — all screens and API calls
│   └── pubspec.yaml        # Flutter dependencies
└── README.md
```

## Installation & Setup

### Backend

```bash
# 1. Clone the repository
git clone https://github.com/nihalalarifi/hackathon-platform.git
cd hackathon-platform/backend

# 2. Create and activate a virtual environment
python3 -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment
# Open app.py and set a real SECRET_KEY before running in production

# 5. Run the backend
python3 app.py
# API will be available at http://localhost:5000
```

### Frontend

```bash
# 1. Install Flutter SDK from https://flutter.dev if not already installed

# 2. Navigate to the frontend directory
cd hackathon-platform/frontend

# 3. Install dependencies
flutter pub get

# 4. Set your backend URL
# Open lib/main.dart and update:
#   static const String baseUrl = 'http://YOUR_BACKEND_HOST:5000/api';

# 5. Run the app
flutter run -d chrome   # for web
# or
flutter run             # for connected device
```

## Environment Variables

Before running in production, set the following in `backend/app.py`:

```
SECRET_KEY=YOUR_SECRET_KEY_HERE
```

Generate a strong key with: `python3 -c "import secrets; print(secrets.token_hex(32))"`

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | /api/register | Create a new user account |
| POST | /api/login | Authenticate and receive JWT |
| GET | /api/profile | Get current user profile |
| POST | /api/register/:role | Register as participant / mentor / judge / organizer |
| GET | /api/teams | List all teams |
| POST | /api/teams | Create a new team |
| POST | /api/teams/:id/join | Join a team |
| GET | /api/mentor/sessions | List mentoring sessions |
| POST | /api/mentor/sessions | Create a session |
| PUT | /api/mentor/sessions/:id | Edit a session |
| DELETE | /api/mentor/sessions/:id | Delete a session |
| POST | /api/judge/select-winner | Select a winning team |
| GET | /api/schedule | Get event schedule |
| POST | /api/schedule | Add a schedule item |

## Technical Challenge

The hardest problem was designing a single REST API that serves four completely different user roles without duplicating logic or exposing restricted endpoints.

The solution was a JWT-based token system that encodes the user's role at login, combined with a reusable `token_required` decorator that validates the token on every protected route. Role-specific routes simply check the decoded role field and return 403 if it does not match — keeping authorization logic co-located with each route rather than scattered across middleware layers. This made it straightforward to add the mentor edit/delete endpoints later without touching the auth system at all.

## License

MIT
