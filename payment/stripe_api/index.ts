const stripe = require('stripe');
const AWS = require('aws-sdk');

interface HttpRequest {
    readonly queryStringParameters?: any;
    readonly headers?: any;
    readonly type?: string;
    readonly methodArn?: string;
    readonly body: string;
    readonly requestContext: {http: {path: string, method: string}}
}

interface HttpResult {
    readonly statusCode: number;
    readonly body?: string;
    readonly headers?: any;
}

const stripeApiToken = process.env.STRIPE_API_TOKEN!;

async function handler(request: HttpRequest): Promise<HttpResult> {
    console.log("Request", request);
    console.log("Tok", stripeApiToken);
    const [head, prefix, ...path] = request.requestContext.http.path.split("/")
    console.log(head, prefix, path);
    switch (path.join("/")) {
        case "webhook":
            return stripeWebhook(request);
        case "create-session":
            if (request.requestContext.http.method = "OPTIONS") {
                return {statusCode: 200, body: "", headers: {Allow: "OPTIONS, GET"}};
            }
            return stripeCreateSession(request);
        default:
            console.error("Unknown request", path);
            return {statusCode: 404, body: "NotFound"};
    }
};

async function stripeWebhook(event: HttpRequest): Promise<HttpResult> {
    try {
        const signature = event.headers["Stripe-Signature"]
        const eventReceived = stripe.webhooks.constructEvent(event.body, signature, stripeApiToken)
        console.log("Valid stripe webhook message", eventReceived);
        return {statusCode: 200, body: ""};
    } catch (e) {
        console.error("Error handling webhook message", e);
        return {statusCode: 500, body: ""};
    }
};

async function stripeCreateSession(event: HttpRequest): Promise<HttpResult> {
    try {
        console.log(event);
        return {statusCode: 302, headers: {Location: 'https://google.com'}}
    } catch (e) {
        console.error("Error handling webhook message", e);
        return {statusCode: 500, body: ""};
    }
};

export {handler};
