import {ApiGatewayManagementApiClient, PostToConnectionCommand} from "@aws-sdk/client-apigatewaymanagementapi";

const apiGatewayEndpoint = process.env.API_GATEWAY_ENDPOINT!;

const apiGatewayClient = new ApiGatewayManagementApiClient({endpoint: "https://" + apiGatewayEndpoint});

const handler = async (request: any): Promise<any> => {
  const event = request.Records[0].Sns;
  console.log("GOT", event);

  const params = {
    ConnectionId: event.MessageAttributes.connection_id.Value,
    Data: event.Message
  };

  await apiGatewayClient.send(new PostToConnectionCommand(params));
};

export {handler};
