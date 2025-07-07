const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
    console.log("Received event:", JSON.stringify(event));
    const method = event.httpMethod;

    if (method === "GET") {
        const id = event.pathParameters.id;
        const result = await dynamo.get({
            TableName: TABLE_NAME,
            Key: { id },
        }).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(result.Item),
        };
    } else if (method === "POST") {
        const body = JSON.parse(event.body);
        await dynamo.put({
            TableName: TABLE_NAME,
            Item: body,
        }).promise();

        return {
            statusCode: 201,
            body: JSON.stringify({ message: "Item created", item: body }),
        };
    }

    return { statusCode: 405, body: "Method Not Allowed" };
};
