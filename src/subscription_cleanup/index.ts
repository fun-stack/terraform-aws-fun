import {DynamoDBClient, QueryCommand, BatchWriteItemCommand, AttributeValue} from "@aws-sdk/client-dynamodb";
import {SNSClient, PublishCommand} from "@aws-sdk/client-sns";

const subscriptionsTable = process.env.DYNAMO_SUBSCRIPTIONS_TABLE!;
const inputTopic = process.env.SNS_INPUT_TOPIC!;
const region = process.env.AWS_REGION!;

const snsClient = new SNSClient({region: region});
const dynamoClient = new DynamoDBClient({region: region});

const handler = async (request: any): Promise<any> => {
  const event = request.Records[0].Sns;
  console.log("GOT", event);

  const deleteItems = async (items: {connection_id: AttributeValue, subscription_key: AttributeValue}[]): Promise<any> => {
    const params = {
      RequestItems: {
        [subscriptionsTable]: items.map(item => {
          return {
            DeleteRequest: {
              Key: item
            }
          };
        })
      }
    };

    const data = await dynamoClient.send(new BatchWriteItemCommand(params));
    console.log("DELETE", data);
  }

  const recurse = async (nextToken: {[key: string]: AttributeValue;}): Promise<any> => {
    const params = {
      Message: event.Message,
      MessageAttributes: {...event.MessageAttributes, __next_token: {DataType: "String", StringValue: JSON.stringify(nextToken)}},
      TopicArn: inputTopic,
    };

    const data = await snsClient.send(new PublishCommand(params));
    console.log("RECURSE", data);
  }

  const params = {
    TableName: subscriptionsTable,
    IndexName: "connection_id",
    ExpressionAttributeValues: {":connection_id": {S: event.Message}},
    KeyConditionExpression: "connection_id = :connection_id",
    ProjectionExpression: "connection_id, subscription_key",
    ExclusiveStartKey: event.MessageAttributes.__next_token != null ? JSON.parse(event.MessageAttributes.__next_token.Value) : undefined,
  };

  const result = await dynamoClient.send(new QueryCommand(params));
  console.log("DYNAMO", result);

  const promises = [];
  if (result.Items != null && result.Items.length > 0) {
    promises.push(deleteItems(result.Items.map(item => {
      return {connection_id: item.connection_id, subscription_key: item.subscription_key};
    })));
  }

  if (result.LastEvaluatedKey != null) {
    promises.push(recurse(result.LastEvaluatedKey));
  }

  await Promise.all(promises);
};

export {handler};
