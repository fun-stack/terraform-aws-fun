interface HttpRequest {
    readonly queryStringParameters?: any;
    readonly type?: string;
    readonly methodArn?: string;
}

interface HttpResult {
    readonly statusCode: number;
    readonly body?: string;
}

const stripeApiToken = process.env.STRIPE_API_TOKEN!;

const handler = async (request: HttpRequest): Promise<HttpResult> => {
    console.log("Request", request);
    console.log("Tok", stripeApiToken);
    return {
        statusCode: 200,
        body: "Hi"
    };
};

export {handler};
