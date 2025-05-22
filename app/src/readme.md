pip freeze > requirements.txt



``` 

curl -X POST http://127.0.0.1:5000/api/user \
-H "Content-Type: application/json" \
-d '{"username": "john_doe", "email": "john@example.com"}'



curl http://127.0.0.1:5000/api/users


curl http://127.0.0.1:5000/api/user/1


curl -X PUT http://127.0.0.1:5000/api/user/1 \
-H "Content-Type: application/json" \
-d '{"username": "john_doe_updated", "email": "john_updated@example.com"}'



curl -X DELETE http://127.0.0.1:5000/user/1

```