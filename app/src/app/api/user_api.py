from app.models import db,User
from flask import Flask, request, jsonify

from flask import Flask, Blueprint
#  创建蓝图对象
user_bp = Blueprint('user', __name__)

# 路由：添加用户
@user_bp.route('/user', methods=['POST'])
def add_user():
    data = request.json
    username = data.get('username')
    email = data.get('email')

    if not username or not email:
        return jsonify({'error': 'Username and email are required'}), 400

    new_user = User(username=username, email=email)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'User added', 'user': {'id': new_user.id, 'username': new_user.username, 'email': new_user.email}}), 201



# 路由：获取所有用户
@user_bp.route('/users', methods=['GET'])
def get_users():
    users = User.query.all()
    return jsonify([{'id': user.id, 'username': user.username, 'email': user.email} for user in users])



# 路由：获取单个用户
@user_bp.route('/user/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = User.query.get(user_id)
    if user:
        return jsonify({'id': user.id, 'username': user.username, 'email': user.email})
    else:
        return jsonify({'error': 'User not found'}), 404

# 路由：更新用户
@user_bp.route('/user/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    data = request.json
    username = data.get('username')
    email = data.get('email')

    if username:
        user.username = username
    if email:
        user.email = email

    db.session.commit()
    return jsonify({'message': 'User updated', 'user': {'id': user.id, 'username': user.username, 'email': user.email}})

# 路由：删除用户
@user_bp.route('/user/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    db.session.delete(user)
    db.session.commit()
    return jsonify({'message': 'User deleted'})
