"""
HACKATHON PLATFORM - COMPLETE BACKEND
Flask REST API with SQLite Database
تم إضافة: قدرة المرشد على تعديل وحذف جلسات الإرشاد
"""

from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
from datetime import datetime, timedelta
from functools import wraps
import os

# Initialize Flask App
app = Flask(__name__)
app.config['SECRET_KEY'] = 'YOUR_SECRET_KEY_HERE'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///hackathon.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize extensions
db = SQLAlchemy(app)

# CORS - السماح لجميع المصادر بما فيها Flutter Web
CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept"],
        "supports_credentials": False
    }
})

@app.after_request
def after_request(response):
    response.headers.set("Access-Control-Allow-Origin", "*")
    response.headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")
    response.headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    return response

# معالج صريح لطلبات OPTIONS (Preflight)
@app.route("/api/<path:path>", methods=["OPTIONS"])
def handle_options(path):
    response = app.make_default_options_response()
    response.headers.set("Access-Control-Allow-Origin", "*")
    response.headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")
    response.headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    response.headers.set("Access-Control-Max-Age", "86400")
    return response

# ======================================
# DATABASE MODELS
# ======================================

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    full_name = db.Column(db.String(120), nullable=False)
    phone = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    participant = db.relationship('Participant', backref='user', uselist=False)
    mentor = db.relationship('Mentor', backref='user', uselist=False)
    judge = db.relationship('Judge', backref='user', uselist=False)
    organizer = db.relationship('Organizer', backref='user', uselist=False)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'full_name': self.full_name,
            'phone': self.phone,
            'participant': self.participant.to_dict() if self.participant else None,
            'mentor': self.mentor.to_dict() if self.mentor else None,
            'judge': self.judge.to_dict() if self.judge else None,
            'organizer': self.organizer.to_dict() if self.organizer else None,
        }

class Participant(db.Model):
    __tablename__ = 'participants'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    skills = db.Column(db.Text)
    interests = db.Column(db.Text)
    team_id = db.Column(db.Integer, db.ForeignKey('teams.id'))
    
    def to_dict(self):
        return {
            'id': self.id,
            'skills': self.skills,
            'interests': self.interests,
            'team_id': self.team_id
        }

class Mentor(db.Model):
    __tablename__ = 'mentors'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    expertise = db.Column(db.Text)
    bio = db.Column(db.Text)
    availability = db.Column(db.String(200))
    
    # Relationships
    sessions = db.relationship('MentorSession', backref='mentor', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'expertise': self.expertise,
            'bio': self.bio,
            'availability': self.availability
        }

class Judge(db.Model):
    __tablename__ = 'judges'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    expertise = db.Column(db.Text)
    organization = db.Column(db.String(200))
    
    def to_dict(self):
        return {
            'id': self.id,
            'expertise': self.expertise,
            'organization': self.organization
        }

class Organizer(db.Model):
    __tablename__ = 'organizers'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    role = db.Column(db.String(100))
    department = db.Column(db.String(100))
    
    def to_dict(self):
        return {
            'id': self.id,
            'role': self.role,
            'department': self.department
        }

class Team(db.Model):
    __tablename__ = 'teams'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    track = db.Column(db.String(100))
    max_members = db.Column(db.Integer, default=5)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    is_winner = db.Column(db.Boolean, default=False)
    winner_place = db.Column(db.Integer, nullable=True)  # 1 = أول, 2 = ثاني, None = لم يفز
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    members = db.relationship('Participant', backref='team', lazy=True)
    sessions = db.relationship('MentorSession', backref='team', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'track': self.track,
            'max_members': self.max_members,
            'is_winner': self.is_winner,
            'winner_place': self.winner_place,
            'members': [{
                'username': m.user.username,
                'full_name': m.user.full_name
            } for m in self.members]
        }

class MentorSession(db.Model):
    __tablename__ = 'mentor_sessions'
    
    id = db.Column(db.Integer, primary_key=True)
    mentor_id = db.Column(db.Integer, db.ForeignKey('mentors.id'), nullable=False)
    team_id = db.Column(db.Integer, db.ForeignKey('teams.id'), nullable=False)
    scheduled_time = db.Column(db.String(100), nullable=False)
    notes = db.Column(db.Text)
    status = db.Column(db.String(50), default='scheduled')  # scheduled, completed, cancelled
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'mentor_id': self.mentor_id,
            'mentor_name': self.mentor.user.full_name if self.mentor else None,
            'team_id': self.team_id,
            'team_name': self.team.name if self.team else None,
            'scheduled_time': self.scheduled_time,
            'notes': self.notes,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class HackathonSchedule(db.Model):
    __tablename__ = 'hackathon_schedule'
    
    id = db.Column(db.Integer, primary_key=True)
    event_name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    start_time = db.Column(db.String(100), nullable=False)
    end_time = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(200))
    
    def to_dict(self):
        return {
            'id': self.id,
            'event_name': self.event_name,
            'description': self.description,
            'start_time': self.start_time,
            'end_time': self.end_time,
            'location': self.location
        }

# ======================================
# AUTHENTICATION DECORATOR
# ======================================

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer TOKEN
            except IndexError:
                return jsonify({'error': 'Invalid token format'}), 401
        
        if not token:
            return jsonify({'error': 'Token is missing'}), 401
        
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.get(data['user_id'])
            if not current_user:
                return jsonify({'error': 'User not found'}), 401
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(current_user, *args, **kwargs)
    
    return decorated

# ======================================
# API ROUTES - AUTHENTICATION
# ======================================

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['username', 'email', 'password', 'full_name']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    # Check if user already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already exists'}), 400
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already exists'}), 400
    
    # Create new user
    user = User(
        username=data['username'],
        email=data['email'],
        full_name=data['full_name'],
        phone=data.get('phone')
    )
    user.set_password(data['password'])
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify({
        'message': 'User registered successfully',
        'user': user.to_dict()
    }), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Username and password required'}), 400
    
    user = User.query.filter_by(username=data['username']).first()
    
    if not user or not user.check_password(data['password']):
        return jsonify({'error': 'Invalid username or password'}), 401
    
    # Generate JWT token
    token = jwt.encode({
        'user_id': user.id,
        'exp': datetime.utcnow() + timedelta(days=7)
    }, app.config['SECRET_KEY'], algorithm="HS256")
    
    return jsonify({
        'message': 'Login successful',
        'token': token,
        'user': user.to_dict()
    }), 200

@app.route('/api/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    return jsonify(current_user.to_dict()), 200

# ======================================
# API ROUTES - ROLE REGISTRATION
# ======================================

@app.route('/api/register/participant', methods=['POST'])
@token_required
def register_participant(current_user):
    if current_user.participant:
        return jsonify({'error': 'Already registered as participant'}), 400
    
    data = request.get_json()
    
    participant = Participant(
        user_id=current_user.id,
        skills=data.get('skills'),
        interests=data.get('interests')
    )
    
    db.session.add(participant)
    db.session.commit()
    
    return jsonify({
        'message': 'Registered as participant successfully',
        'participant': participant.to_dict()
    }), 201

@app.route('/api/register/mentor', methods=['POST'])
@token_required
def register_mentor(current_user):
    if current_user.mentor:
        return jsonify({'error': 'Already registered as mentor'}), 400
    
    data = request.get_json()
    
    mentor = Mentor(
        user_id=current_user.id,
        expertise=data.get('expertise'),
        bio=data.get('bio'),
        availability=data.get('availability')
    )
    
    db.session.add(mentor)
    db.session.commit()
    
    return jsonify({
        'message': 'Registered as mentor successfully',
        'mentor': mentor.to_dict()
    }), 201

@app.route('/api/register/judge', methods=['POST'])
@token_required
def register_judge(current_user):
    if current_user.judge:
        return jsonify({'error': 'Already registered as judge'}), 400
    
    data = request.get_json()
    
    judge = Judge(
        user_id=current_user.id,
        expertise=data.get('expertise'),
        organization=data.get('organization')
    )
    
    db.session.add(judge)
    db.session.commit()
    
    return jsonify({
        'message': 'Registered as judge successfully',
        'judge': judge.to_dict()
    }), 201

@app.route('/api/register/organizer', methods=['POST'])
@token_required
def register_organizer(current_user):
    if current_user.organizer:
        return jsonify({'error': 'Already registered as organizer'}), 400
    
    data = request.get_json()
    
    organizer = Organizer(
        user_id=current_user.id,
        role=data.get('role'),
        department=data.get('department')
    )
    
    db.session.add(organizer)
    db.session.commit()
    
    return jsonify({
        'message': 'Registered as organizer successfully',
        'organizer': organizer.to_dict()
    }), 201

# ======================================
# API ROUTES - TEAMS
# ======================================

@app.route('/api/teams', methods=['GET'])
@token_required
def get_teams(current_user):
    teams = Team.query.all()
    return jsonify([team.to_dict() for team in teams]), 200

@app.route('/api/teams', methods=['POST'])
@token_required
def create_team(current_user):
    # Only mentors and organizers can create teams
    if not (current_user.mentor or current_user.organizer):
        return jsonify({'error': 'Only mentors and organizers can create teams'}), 403
    
    data = request.get_json()
    
    if not data.get('name'):
        return jsonify({'error': 'Team name is required'}), 400
    
    team = Team(
        name=data['name'],
        description=data.get('description'),
        track=data.get('track'),
        max_members=data.get('max_members', 5),
        created_by=current_user.id
    )
    
    db.session.add(team)
    db.session.commit()
    
    return jsonify({
        'message': 'Team created successfully',
        'team': team.to_dict()
    }), 201

@app.route('/api/teams/<int:team_id>/join', methods=['POST'])
@token_required
def join_team(current_user, team_id):
    if not current_user.participant:
        return jsonify({'error': 'Only participants can join teams'}), 403
    
    team = Team.query.get(team_id)
    if not team:
        return jsonify({'error': 'Team not found'}), 404
    
    # Check if already in a team
    if current_user.participant.team_id:
        return jsonify({'error': 'Already in a team. Leave your current team first.'}), 400
    
    # Check if team is full
    if len(team.members) >= team.max_members:
        return jsonify({'error': 'Team is full'}), 400
    
    current_user.participant.team_id = team_id
    db.session.commit()
    
    return jsonify({
        'message': 'Joined team successfully',
        'team': team.to_dict()
    }), 200

@app.route('/api/teams/<int:team_id>/leave', methods=['POST'])
@token_required
def leave_team(current_user, team_id):
    if not current_user.participant:
        return jsonify({'error': 'Only participants can leave teams'}), 403
    
    if current_user.participant.team_id != team_id:
        return jsonify({'error': 'You are not in this team'}), 400
    
    current_user.participant.team_id = None
    db.session.commit()
    
    return jsonify({'message': 'Left team successfully'}), 200

# ======================================
# API ROUTES - MENTOR SESSIONS
# ======================================

@app.route('/api/mentor/sessions', methods=['GET'])
@token_required
def get_mentor_sessions(current_user):
    if not current_user.mentor:
        return jsonify({'error': 'Not registered as mentor'}), 403
    
    sessions = MentorSession.query.filter_by(mentor_id=current_user.mentor.id).all()
    return jsonify({
        'message': 'Sessions retrieved successfully',
        'sessions': [session.to_dict() for session in sessions],
        'count': len(sessions)
    }), 200

@app.route('/api/mentor/sessions', methods=['POST'])
@token_required
def create_mentor_session(current_user):
    """إنشاء جلسة إرشادية جديدة"""
    if not current_user.mentor:
        return jsonify({'error': 'Not registered as mentor'}), 403
    
    data = request.get_json()
    
    if not data.get('team_id') or not data.get('scheduled_time'):
        return jsonify({'error': 'team_id and scheduled_time are required'}), 400
    
    # التحقق من وجود الفريق
    team = Team.query.get(data['team_id'])
    if not team:
        return jsonify({'error': 'Team not found'}), 404
    
    session = MentorSession(
        mentor_id=current_user.mentor.id,
        team_id=data['team_id'],
        scheduled_time=data['scheduled_time'],
        notes=data.get('notes'),
        status=data.get('status', 'scheduled')
    )
    
    db.session.add(session)
    db.session.commit()
    
    return jsonify({
        'message': 'Session scheduled successfully',
        'session': session.to_dict()
    }), 201

@app.route('/api/mentor/sessions/<int:session_id>', methods=['GET'])
@token_required
def get_mentor_session_detail(current_user, session_id):
    """الحصول على تفاصيل جلسة إرشادية معينة"""
    if not current_user.mentor:
        return jsonify({'error': 'Not registered as mentor'}), 403
    
    session = MentorSession.query.get(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    
    # التحقق من أن المرشد هو صاحب الجلسة
    if session.mentor_id != current_user.mentor.id:
        return jsonify({'error': 'Unauthorized - This session does not belong to you'}), 403
    
    return jsonify({
        'message': 'Session retrieved successfully',
        'session': session.to_dict()
    }), 200

@app.route('/api/mentor/sessions/<int:session_id>', methods=['PUT'])
@token_required
def update_mentor_session(current_user, session_id):
    """تعديل جلسة إرشادية"""
    if not current_user.mentor:
        return jsonify({'error': 'Not registered as mentor'}), 403
    
    session = MentorSession.query.get(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    
    # التحقق من أن المرشد هو صاحب الجلسة
    if session.mentor_id != current_user.mentor.id:
        return jsonify({'error': 'Unauthorized - This session does not belong to you'}), 403
    
    data = request.get_json()
    
    # تحديث الحقول المسموحة
    if 'scheduled_time' in data:
        session.scheduled_time = data['scheduled_time']
    
    if 'notes' in data:
        session.notes = data['notes']
    
    if 'status' in data:
        if data['status'] not in ['scheduled', 'completed', 'cancelled']:
            return jsonify({'error': 'Invalid status. Must be: scheduled, completed, or cancelled'}), 400
        session.status = data['status']
    
    if 'team_id' in data:
        # التحقق من وجود الفريق الجديد
        team = Team.query.get(data['team_id'])
        if not team:
            return jsonify({'error': 'Team not found'}), 404
        session.team_id = data['team_id']
    
    session.updated_at = datetime.utcnow()
    db.session.commit()
    
    return jsonify({
        'message': 'Session updated successfully',
        'session': session.to_dict()
    }), 200

@app.route('/api/mentor/sessions/<int:session_id>', methods=['DELETE'])
@token_required
def delete_mentor_session(current_user, session_id):
    """حذف جلسة إرشادية"""
    if not current_user.mentor:
        return jsonify({'error': 'Not registered as mentor'}), 403
    
    session = MentorSession.query.get(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    
    # التحقق من أن المرشد هو صاحب الجلسة
    if session.mentor_id != current_user.mentor.id:
        return jsonify({'error': 'Unauthorized - This session does not belong to you'}), 403
    
    # حفظ بيانات الجلسة قبل الحذف
    deleted_session = session.to_dict()
    
    db.session.delete(session)
    db.session.commit()
    
    return jsonify({
        'message': 'Session deleted successfully',
        'deleted_session': deleted_session
    }), 200

# ======================================
# API ROUTES - ORGANIZER SESSION MANAGEMENT
# ======================================

@app.route('/api/organizer/sessions', methods=['GET'])
@token_required
def organizer_get_all_sessions(current_user):
    """المنظم يستعرض جميع الجلسات الإرشادية"""
    if not current_user.organizer:
        return jsonify({'error': 'Not registered as organizer'}), 403
    
    sessions = MentorSession.query.all()
    return jsonify({
        'message': 'All sessions retrieved successfully',
        'sessions': [session.to_dict() for session in sessions],
        'count': len(sessions)
    }), 200

@app.route('/api/organizer/sessions/<int:session_id>', methods=['PUT'])
@token_required
def organizer_update_session(current_user, session_id):
    """المنظم يعدّل أي جلسة إرشادية"""
    if not current_user.organizer:
        return jsonify({'error': 'Not registered as organizer'}), 403
    
    session = MentorSession.query.get(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    
    data = request.get_json()
    
    if 'scheduled_time' in data:
        session.scheduled_time = data['scheduled_time']
    if 'notes' in data:
        session.notes = data['notes']
    if 'status' in data:
        if data['status'] not in ['scheduled', 'completed', 'cancelled']:
            return jsonify({'error': 'Invalid status'}), 400
        session.status = data['status']
    if 'team_id' in data:
        team = Team.query.get(data['team_id'])
        if not team:
            return jsonify({'error': 'Team not found'}), 404
        session.team_id = data['team_id']
    
    session.updated_at = datetime.utcnow()
    db.session.commit()
    
    return jsonify({
        'message': 'Session updated successfully by organizer',
        'session': session.to_dict()
    }), 200

@app.route('/api/organizer/sessions/<int:session_id>', methods=['DELETE'])
@token_required
def organizer_delete_session(current_user, session_id):
    """المنظم يحذف أي جلسة إرشادية"""
    if not current_user.organizer:
        return jsonify({'error': 'Not registered as organizer'}), 403
    
    session = MentorSession.query.get(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    
    deleted_session = session.to_dict()
    db.session.delete(session)
    db.session.commit()
    
    return jsonify({
        'message': 'Session deleted successfully by organizer',
        'deleted_session': deleted_session
    }), 200

@app.route('/api/sessions/all', methods=['GET'])
@token_required
def get_all_sessions_public(current_user):
    """جلب جميع الجلسات الإرشادية - للمشاركين والجميع"""
    sessions = MentorSession.query.order_by(MentorSession.scheduled_time).all()
    return jsonify({
        'sessions': [s.to_dict() for s in sessions],
        'count': len(sessions)
    }), 200

@app.route('/api/mentor/sessions/team/<int:team_id>', methods=['GET'])
@token_required
def get_team_mentor_sessions(current_user, team_id):
    """الحصول على جميع جلسات الإرشاد لفريق معين"""
    team = Team.query.get(team_id)
    if not team:
        return jsonify({'error': 'Team not found'}), 404
    
    sessions = MentorSession.query.filter_by(team_id=team_id).all()
    
    return jsonify({
        'message': 'Team sessions retrieved successfully',
        'team_name': team.name,
        'sessions': [session.to_dict() for session in sessions],
        'count': len(sessions)
    }), 200

# ======================================
# API ROUTES - JUDGE OPERATIONS
# ======================================

@app.route('/api/judge/winners', methods=['GET'])
@token_required
def get_winners(current_user):
    """جلب الفائزين الحاليين"""
    if not current_user.judge:
        return jsonify({'error': 'Not registered as judge'}), 403
    
    first = Team.query.filter_by(winner_place=1).first()
    second = Team.query.filter_by(winner_place=2).first()
    
    return jsonify({
        'first_place': first.to_dict() if first else None,
        'second_place': second.to_dict() if second else None,
    }), 200

@app.route('/api/judge/select-winner', methods=['POST'])
@token_required
def select_winner(current_user):
    """تعيين فائز في مركز معين (1 أو 2)"""
    if not current_user.judge:
        return jsonify({'error': 'Not registered as judge'}), 403
    
    data = request.get_json()
    
    if not data.get('team_id'):
        return jsonify({'error': 'team_id is required'}), 400
    
    place = data.get('place', 1)
    if place not in [1, 2]:
        return jsonify({'error': 'place must be 1 or 2'}), 400
    
    team = Team.query.get(data['team_id'])
    if not team:
        return jsonify({'error': 'Team not found'}), 404
    
    # إلغاء أي فريق كان في هذا المركز
    prev = Team.query.filter_by(winner_place=place).first()
    if prev and prev.id != team.id:
        prev.winner_place = None
        prev.is_winner = False
    
    # إلغاء المركز القديم لهذا الفريق إن كان له مركز آخر
    if team.winner_place and team.winner_place != place:
        team.winner_place = None
        team.is_winner = False
    
    team.winner_place = place
    team.is_winner = True
    
    db.session.commit()
    
    place_label = 'الأول' if place == 1 else 'الثاني'
    return jsonify({
        'message': f'تم اختيار {team.name} فائزاً في المركز {place_label}',
        'team': team.to_dict(),
        'place': place
    }), 200

@app.route('/api/judge/remove-winner', methods=['POST'])
@token_required
def remove_winner(current_user):
    """إلغاء فوز فريق"""
    if not current_user.judge:
        return jsonify({'error': 'Not registered as judge'}), 403
    
    data = request.get_json()
    place = data.get('place')
    
    if place not in [1, 2]:
        return jsonify({'error': 'place must be 1 or 2'}), 400
    
    team = Team.query.filter_by(winner_place=place).first()
    if not team:
        return jsonify({'error': 'No winner found for this place'}), 404
    
    team.winner_place = None
    team.is_winner = False
    db.session.commit()
    
    place_label = 'الأول' if place == 1 else 'الثاني'
    return jsonify({
        'message': f'تم إلغاء الفائز في المركز {place_label}',
    }), 200

# ======================================
# API ROUTES - SCHEDULE
# ======================================

@app.route('/api/schedule', methods=['GET'])
@token_required
def get_schedule(current_user):
    schedule = HackathonSchedule.query.all()
    return jsonify([event.to_dict() for event in schedule]), 200

@app.route('/api/schedule', methods=['POST'])
@token_required
def create_schedule_event(current_user):
    if not current_user.organizer:
        return jsonify({'error': 'Only organizers can create schedule events'}), 403
    
    data = request.get_json()
    
    event = HackathonSchedule(
        event_name=data['event_name'],
        description=data.get('description'),
        start_time=data['start_time'],
        end_time=data['end_time'],
        location=data.get('location')
    )
    
    db.session.add(event)
    db.session.commit()
    
    return jsonify({
        'message': 'Event created successfully',
        'event': event.to_dict()
    }), 201

# ======================================
# DATABASE INITIALIZATION
# ======================================

# الجدول الزمني الرسمي للهاكاثون
OFFICIAL_SCHEDULE = [
    {
        "event_name": "فتح باب التسجيل",
        "description": "بداية استقبال طلبات التسجيل للمشاركة في الهاكاثون",
        "start_time": "2026-05-01",
        "end_time": "2026-05-01",
        "location": "عبر المنصة"
    },
    {
        "event_name": "نهاية التسجيل",
        "description": "آخر موعد لاستقبال طلبات التسجيل",
        "start_time": "2026-05-07",
        "end_time": "2026-05-07",
        "location": "عبر المنصة"
    },
    {
        "event_name": "تأكيد المشاركين",
        "description": "إعلان قائمة المشاركين المقبولين",
        "start_time": "2026-05-08",
        "end_time": "2026-05-08",
        "location": "عبر المنصة"
    },
    {
        "event_name": "اليوم التعريفي",
        "description": "لقاء تعريفي بالهاكاثون والفرق والمرشدين",
        "start_time": "2026-05-14",
        "end_time": "2026-05-14",
        "location": "القاعة الرئيسية"
    },
    {
        "event_name": "الجلسات الإرشادية",
        "description": "جلسات إرشادية مع المرشدين لمساعدة الفرق",
        "start_time": "2026-05-15",
        "end_time": "2026-05-16",
        "location": "قاعات الإرشاد"
    },
    {
        "event_name": "بدء أيام الهاكاثون",
        "description": "بداية العمل على المشاريع وتطويرها",
        "start_time": "2026-05-21",
        "end_time": "2026-05-22",
        "location": "قاعات العمل"
    },
    {
        "event_name": "الحفل الختامي وإعلان الفائزين",
        "description": "تقديم المشاريع النهائية والحكم وإعلان الفرق الفائزة",
        "start_time": "2026-05-23",
        "end_time": "2026-05-23",
        "location": "القاعة الرئيسية"
    },
]

def reset_schedule():
    """حذف الجدول القديم واستبداله بالجدول الرسمي المحدّث"""
    HackathonSchedule.query.delete()
    for item in OFFICIAL_SCHEDULE:
        event = HackathonSchedule(**item)
        db.session.add(event)
    db.session.commit()
    print(f"✅ تم تحديث الجدول الزمني: {len(OFFICIAL_SCHEDULE)} فقرات")

def migrate_db():
    """إضافة أعمدة جديدة لقاعدة البيانات الموجودة"""
    import sqlite3, os
    db_path = os.path.join(os.path.dirname(__file__), 'instance', 'hackathon.db')
    if not os.path.exists(db_path):
        return
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        # إضافة عمود winner_place إذا لم يكن موجوداً
        cursor.execute("PRAGMA table_info(teams)")
        columns = [row[1] for row in cursor.fetchall()]
        if 'winner_place' not in columns:
            cursor.execute("ALTER TABLE teams ADD COLUMN winner_place INTEGER")
            conn.commit()
            print("✅ تم إضافة عمود winner_place")
        conn.close()
    except Exception as e:
        print(f"Migration note: {e}")

def init_db():
    """Initialize database with sample data"""
    with app.app_context():
        migrate_db()
        db.create_all()
        
        # تحديث الجدول الزمني دائماً عند بدء التشغيل
        reset_schedule()
        
        # إنشاء بيانات أولية فقط إذا لم تكن موجودة
        if User.query.first():
            print("Database already initialized - schedule updated")
            return
        
        print("Database initialized successfully!")

# ======================================
# MAIN
# ======================================

if __name__ == '__main__':
    init_db()
    print("=" * 50)
    print("HACKATHON PLATFORM BACKEND STARTED")
    print("=" * 50)
    print("API running on: http://127.0.0.1:5000")
    print("Database: hackathon.db")
    print("=" * 50)
    app.run(debug=True, host='0.0.0.0', port=5000)