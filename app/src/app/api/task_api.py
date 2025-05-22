from flask import Blueprint, request, jsonify
from ..models import db # Assuming db is initialized in main.py or a shared models.py
from sqlalchemy.exc import IntegrityError
import datetime

# Define a Blueprint for the task API
task_bp = Blueprint('task_bp', __name__)

# Define the Task model (ideally, this would be in a central models.py)
# If you have a central models.py, import Task from there instead.
class Task(db.Model):
    __tablename__ = 'tasks' # Explicitly define table name

    id = db.Column(db.Text, primary_key=True)
    cosObjectKey = db.Column(db.Text)
    name = db.Column(db.Text, nullable=False)
    path = db.Column(db.Text)
    size = db.Column(db.Integer)
    formattedSize = db.Column(db.Text)
    type = db.Column(db.Text)
    uploadTime = db.Column(db.Text) # Consider db.DateTime if you want to query by date/time
    sourceLanguage = db.Column(db.Text)
    targetLanguage = db.Column(db.Text)
    status = db.Column(db.Text, nullable=False)
    errorMessage = db.Column(db.Text)
    createdAt = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def __repr__(self):
        return f'<Task {self.id} - {self.name}>'

    def to_dict(self):
        """Helper method to convert Task object to a dictionary."""
        return {
            'id': self.id,
            'cosObjectKey': self.cosObjectKey,
            'name': self.name,
            'path': self.path,
            'size': self.size,
            'formattedSize': self.formattedSize,
            'type': self.type,
            'uploadTime': self.uploadTime,
            'sourceLanguage': self.sourceLanguage,
            'targetLanguage': self.targetLanguage,
            'status': self.status,
            'errorMessage': self.errorMessage,
            'createdAt': self.createdAt.isoformat() if self.createdAt else None
        }


@task_bp.route('/save_task', methods=['POST'])
def save_task_route(): # Renamed to avoid conflict if 'save_task' is used elsewhere
    """
    API endpoint to save a new task to the database using SQLAlchemy.
    Expects JSON data in the request body.
    """
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    print(f"Received data for save_task: {data}") # For debugging

    required_fields = ['id', 'name', 'status']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    new_task = Task(
        id=data.get('id'),
        cosObjectKey=data.get('cosObjectKey'),
        name=data.get('name'),
        path=data.get('path'),
        size=data.get('size'),
        formattedSize=data.get('formattedSize'),
        type=data.get('type'),
        uploadTime=data.get('uploadTime'),
        sourceLanguage=data.get('sourceLanguage'),
        targetLanguage=data.get('targetLanguage'),
        status=data.get('status'),
        errorMessage=data.get('errorMessage')
        # createdAt is handled by default
    )

    try:
        db.session.add(new_task)
        db.session.commit()
        return jsonify({"message": "Task saved successfully", "taskId": new_task.id}), 201
    except IntegrityError: # Handles cases like duplicate primary key
        db.session.rollback()
        return jsonify({"error": f"Task with id {new_task.id} already exists or other integrity constraint failed."}), 409
    except Exception as e:
        db.session.rollback()
        print(f"Database error: {e}") # Log the error
        return jsonify({"error": "Failed to save task to database", "details": str(e)}), 500

@task_bp.route('/tasks', methods=['GET'])
def get_tasks_route():
    """API endpoint to retrieve a list of all tasks."""
    try:
        tasks = Task.query.all()
        return jsonify([task.to_dict() for task in tasks]), 200
    except Exception as e:
        print(f"Error retrieving tasks: {e}")
        return jsonify({"error": "Failed to retrieve tasks", "details": str(e)}), 500

@task_bp.route('/task/<string:task_id>', methods=['GET'])
def get_task_route(task_id):
    """API endpoint to retrieve a single task by its ID."""
    try:
        task = Task.query.get(task_id)
        if task:
            return jsonify(task.to_dict()), 200
        else:
            return jsonify({"error": "Task not found"}), 404
    except Exception as e:
        print(f"Error retrieving task {task_id}: {e}")
        return jsonify({"error": "Failed to retrieve task", "details": str(e)}), 500

@task_bp.route('/task/<string:task_id>', methods=['PUT'])
def update_task_route(task_id):
    """API endpoint to update an existing task."""
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    print(f"Received data for updating task {task_id}: {data}")

    try:
        task = Task.query.get(task_id)
        if not task:
            return jsonify({"error": "Task not found"}), 404

        # Update fields if they are provided in the request
        if 'cosObjectKey' in data:
            task.cosObjectKey = data['cosObjectKey']
        if 'name' in data:
            task.name = data['name']
        if 'path' in data:
            task.path = data['path']
        if 'size' in data:
            task.size = data['size']
        if 'formattedSize' in data:
            task.formattedSize = data['formattedSize']
        if 'type' in data:
            task.type = data['type']
        if 'uploadTime' in data:
            task.uploadTime = data['uploadTime']
        if 'sourceLanguage' in data:
            task.sourceLanguage = data['sourceLanguage']
        if 'targetLanguage' in data:
            task.targetLanguage = data['targetLanguage']
        if 'status' in data:
            task.status = data['status']
        if 'errorMessage' in data:
            task.errorMessage = data['errorMessage']
        
        # Note: createdAt is usually not updated manually.
        # id should not be updated.

        db.session.commit()
        return jsonify({"message": "Task updated successfully", "task": task.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error updating task {task_id}: {e}")
        return jsonify({"error": "Failed to update task", "details": str(e)}), 500

@task_bp.route('/task/<string:task_id>', methods=['DELETE'])
def delete_task_route(task_id):
    """API endpoint to delete a task."""
    try:
        task = Task.query.get(task_id)
        if not task:
            return jsonify({"error": "Task not found"}), 404

        db.session.delete(task)
        db.session.commit()
        return jsonify({"message": "Task deleted successfully", "taskId": task_id}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error deleting task {task_id}: {e}")
        return jsonify({"error": "Failed to delete task", "details": str(e)}), 500
