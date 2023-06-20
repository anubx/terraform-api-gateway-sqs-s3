import json
import boto3
import os

data = {
    "items": [
        {"id": 1, "name": "Item 1", "price": 10.99},
        {"id": 2, "name": "Item 2", "price": 15.99},
        {"id": 3, "name": "Item 3", "price": 20.99},
    ]
}

def lambda_handler(event, context):

    http_method = event["httpMethod"]

    if http_method == "GET":
        response = {
            "statusCode": 200,
            "body": json.dumps(data)
        }
        message_body = json.dumps(data)
        message = json.loads(message_body)
        print(f'body: {message}')
        send_sqs(message)
        return response

    elif http_method == "POST":
        body = json.loads(event["body"])
        data["items"].append(body)
        response = {
            "statusCode": 200,
            "body": json.dumps(data)
        }
        print(f'body: {body}')
        send_sqs(body)
        return response

    elif http_method == "PUT":
        body = json.loads(event["body"])
        for item in data["items"]:
            if item["id"] == body["id"]:
                item.update(body)
                break
        response = {
            "statusCode": 200,
            "body": json.dumps(data)
        }
        print(f'body: {body}')
        send_sqs(body)
        return response

    elif http_method == "DELETE":
        body = json.loads(event["body"])
        for i, item in enumerate(data["items"]):
            if item["id"] == body["id"]:
                del data["items"][i]
                break
        response = {
            "statusCode": 200,
            "body": json.dumps(data)
        }
        print(f'body: {body}')
        send_sqs(body)
        return response

    else:
        response = {
            "statusCode": 405,
            "body": json.dumps({"error": "Method not allowed"})
        }
        return response

def send_sqs(sqs_msg):

    try:
        queue = os.environ['sqs_queue']
        sqs = boto3.client('sqs')
        sqs.send_message(
        QueueUrl=queue,
        MessageBody=json.dumps(sqs_msg)
        )
        print("SQS message sent successfully to {}".format(queue))
        # return response
    except Exception as e:
        print("Client connection to SQS failed because ", e)
        # response = {
        #     "status" : 500,
        #     "body" : "SQS send message failed"
        # }
        # return response
