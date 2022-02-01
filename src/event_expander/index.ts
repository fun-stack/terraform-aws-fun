import {DynamoDBClient, QueryCommand, AttributeValue} from "@aws-sdk/client-dynamodb";
import {SNSClient, PublishBatchCommand, PublishCommand} from "@aws-sdk/client-sns";

const subscriptionsTable = process.env.DYNAMO_SUBSCRIPTIONS_TABLE!;
const inputTopic = process.env.SNS_INPUT_TOPIC!;
const outputTopic = process.env.SNS_OUTPUT_TOPIC!;
const region = process.env.AWS_REGION!;

const snsClient = new SNSClient({region: region});
const dynamoClient = new DynamoDBClient({region: region});

const batched = <T>(array: T[], count: number): T[][] => {
  if (count <= 0) throw new Error("Invalid count for batched method");
  if (array.length == 0) return [];

  const result = [[]];
  for (let i = 0; i < array.length; i++) {
    const batch = result[result.length - 1];
    batch.push(array[i]);
    if (batch.length === count) result.push([]);
  }

  return result;
}

// https://aws.amazon.com/about-aws/whats-new/2021/11/amazon-sns-supports-publishing-batches-messages-single-api-request/
const maximumPublishBatchSize = 10;

const handler = async (request: any): Promise<any> => {
  const event = request.Records[0].Sns;
  console.log("GOT", event);

  const publishEventBatch = async (items: {connection_id: string, user_id: string | undefined}[]): Promise<any> => {
    const params = {
      PublishBatchRequestEntries: items.map((item, idx) => {
        return {
          Id: idx.toString(),
          Message: event.Message,
          MessageAttributes: Object.assign({connection_id: {DataType: "String", StringValue: item.connection_id}}, item.user_id != null ? {user_id: {DataType: "String", StringValue: item.user_id}} : {}),
        };
      }),
      TopicArn: outputTopic,
    };

    const data = await snsClient.send(new PublishBatchCommand(params));
    console.log("PUBLISH", data);
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
    ExpressionAttributeValues: {":subscription_key": {S: event.MessageAttributes.subscription_key.Value}},
    KeyConditionExpression: "subscription_key = :subscription_key",
    ProjectionExpression: "connection_id, user_id",
    ExclusiveStartKey: event.MessageAttributes.__next_token != null ? JSON.parse(event.MessageAttributes.__next_token.Value) : undefined,
  };

  const result = await dynamoClient.send(new QueryCommand(params));
  console.log("DYNAMO", result);

  const promises = [];
  if (result.Items != null && result.Items.length > 0) {
    const batchItems = batched(result.Items, maximumPublishBatchSize);
    promises.push(...batchItems.map(items => publishEventBatch(items.map(item => {return {connection_id: item.connection_id.S, user_id: item.user_id?.S};}))));
  }

  if (result.LastEvaluatedKey != null) {
    promises.push(recurse(result.LastEvaluatedKey));
  }

  await Promise.all(promises);
};

export {handler};
