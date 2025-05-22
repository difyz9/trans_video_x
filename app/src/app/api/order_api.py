from flask import Blueprint, request, jsonify
from ..models import db # Assuming db is initialized in main.py or a shared models.py
from sqlalchemy.exc import IntegrityError
import datetime
from app.models.order_model import OrderModel
from ..utils.extract_url import extract_video_id

# Define a Blueprint for the task API
order_bp = Blueprint('url_bp', __name__)



@order_bp.route('/save-url', methods=['POST'])
def save_url_handler():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    print(f"Received data for /save-url: {data}")

    required_fields = ['url'] # Define required fields for UrlTask
    for field in required_fields:
        if field not in data or data[field] is None: # Check for presence and non-null
            return jsonify({"error": f"Missing or null required field: {field}"}), 400

    try:
        # Parse timestamp string to datetime object if it exists
        timestamp_str = data.get('timestamp')
        parsed_timestamp = None
        if timestamp_str:
            try:
                parsed_timestamp = datetime.datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
            except ValueError:
                return jsonify({"error": "Invalid timestamp format. Expected ISO 8601 format."}), 400
        else:
            # 如果没有提供时间戳，使用当前时间
            parsed_timestamp = datetime.datetime.utcnow()

        new_url_task = OrderModel(
            id=data.get('id'),
            url=data.get('url'),
            videoId = extract_video_id(data.get('url')), # Extract video ID from URL
            title=data.get('title'),
            description=data.get('description'),
            playlist_id=data.get('playlistId'),      # Map from camelCase
            operation_type=data.get('operationType'),# Map from camelCase
            timestamp=parsed_timestamp,
            status=data.get('status', 'pending') # Default status if not provided
        )

        db.session.add(new_url_task)
        db.session.commit()

        return jsonify({
            'success': True,
            'message': f'Received and processed URL: {new_url_task.url}',
            'id': new_url_task.id,
            'code': 200
        }), 201

    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": f"UrlTask with id {data.get('id')} already exists or other integrity constraint failed."}), 409
    except Exception as e:
        db.session.rollback()
        print(f"Database error while saving UrlTask: {e}")
        return jsonify({"error": "Failed to save URL task to database", "details": str(e)}), 500

@order_bp.route('/url_tasks', methods=['GET'])
def get_url_tasks_route():
    """API endpoint to retrieve a list of all URL tasks."""
    try:
        url_tasks = OrderModel.query.all()
        return jsonify([task.to_dict() for task in url_tasks]), 200
    except Exception as e:
        print(f"Error retrieving URL tasks: {e}")
        return jsonify({"error": "Failed to retrieve URL tasks", "details": str(e)}), 500

@order_bp.route('/url_task/<string:task_id>', methods=['GET'])
def get_url_task_route(task_id):
    """API endpoint to retrieve a single URL task by its ID."""
    try:
        url_task = OrderModel.query.get(task_id)
        if url_task:
            return jsonify(url_task.to_dict()), 200
        else:
            return jsonify({"error": "URL task not found"}), 404
    except Exception as e:
        print(f"Error retrieving URL task {task_id}: {e}")
        return jsonify({"error": "Failed to retrieve URL task", "details": str(e)}), 500

@order_bp.route('/url_task/<string:task_id>', methods=['PUT'])
def update_url_task_route(task_id):
    """API endpoint to update an existing URL task."""
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    print(f"Received data for updating URL task {task_id}: {data}")

    try:
        url_task = OrderModel.query.get(task_id)
        if not url_task:
            return jsonify({"error": "URL task not found"}), 404

        # Update fields if they are provided in the request
        if 'url' in data:
            url_task.url = data['url']
        if 'title' in data:
            url_task.title = data['title']
        if 'description' in data:
            url_task.description = data['description']
        if 'playlistId' in data: # map from camelCase
            url_task.playlist_id = data['playlistId']
        if 'operationType' in data: # map from camelCase
            url_task.operation_type = data['operationType']
        if 'status' in data:
            url_task.status = data['status']
        if 'processingMessage' in data: # map from camelCase
            url_task.processing_message = data['processingMessage']
        
        # Timestamp might be updated if provided, parse it
        if 'timestamp' in data and data['timestamp']:
            try:
                url_task.timestamp = datetime.datetime.fromisoformat(data['timestamp'].replace('Z', '+00:00'))
            except ValueError:
                return jsonify({"error": "Invalid timestamp format. Expected ISO 8601 format."}), 400
        
        # Note: id and createdAt are usually not updated manually.

        db.session.commit()
        return jsonify({"message": "URL task updated successfully", "task": url_task.to_dict()}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error updating URL task {task_id}: {e}")
        return jsonify({"error": "Failed to update URL task", "details": str(e)}), 500

@order_bp.route('/url_task/<string:task_id>', methods=['DELETE'])
def delete_url_task_route(task_id):
    """API endpoint to delete a URL task."""
    try:
        url_task = OrderModel.query.get(task_id)
        if not url_task:
            return jsonify({"error": "URL task not 1 found"}), 404

        db.session.delete(url_task)
        db.session.commit()
        return jsonify({"message": "URL task deleted successfully", "taskId": task_id}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error deleting URL task {task_id}: {e}")
        return jsonify({"error": "Failed to delete URL task", "details": str(e)}), 500
