import {promisify} from 'util';
import * as Axios from 'axios';
import * as jsonwebtoken from 'jsonwebtoken';
import jwkToPem from 'jwk-to-pem';

export interface ClaimVerifyRequest {
    readonly queryStringParameters?: any;
    readonly type?: string;
    readonly methodArn?: string;
}

export interface ClaimVerifyResult {
    readonly principalId: string;
    readonly policyDocument: any;
    readonly context: any;
}

interface AWSPolicyStatement {
    Action: string;
    Effect: string;
    Resource: string;
}

interface AWSPolicy {
    Version: string;
    Statement: AWSPolicyStatement[];
}

interface TokenHeader {
    kid: string;
    alg: string;
}
interface PublicKey {
    alg: string;
    e: string;
    kid: string;
    kty: string;
    n: string;
    use: string;
}
interface PublicKeyMeta {
    instance: PublicKey;
    pem: string;
}

interface PublicKeys {
    keys: PublicKey[];
}

interface MapOfKidToPublicKey {
    [key: string]: PublicKeyMeta;
}

interface Claim {
    token_use: string;
    auth_time: number;
    iss: string;
    iat: number
    exp: number;
    client_id: string;
    jti: string;
    scope: string;
    sub: string
    username: string;
    version: number;
}

const cognitoPoolId = process.env.COGNITO_POOL_ID!;
const cognitoApiScopes = process.env.COGNITO_API_SCOPES!;
const allowUnauthenticated = process.env.ALLOW_UNAUTHENTICATED! === "true";
const awsRegion = process.env.AWS_REGION!;
const cognitoIssuer = `https://cognito-idp.${awsRegion}.amazonaws.com/${cognitoPoolId}`;

let cacheKeys: MapOfKidToPublicKey | undefined;
const getPublicKeys = async (): Promise<MapOfKidToPublicKey> => {
    if (!cacheKeys) {
        const url = `${cognitoIssuer}/.well-known/jwks.json`;
        const publicKeys = await Axios.default.get<PublicKeys>(url);
        cacheKeys = publicKeys.data.keys.reduce((agg, current) => {
            const pem = jwkToPem(current);
            agg[current.kid] = {instance: current, pem};
            return agg;
        }, {} as MapOfKidToPublicKey);
        return cacheKeys;
    } else {
        return cacheKeys;
    }
};

const verifyPromised = promisify(jsonwebtoken.verify.bind(jsonwebtoken));

function generatePolicy(resource: string, effect: string): AWSPolicy {
    return {
        Version: '2012-10-17',
        Statement: [
            {
                Action: 'execute-api:Invoke',
                Effect: effect,
                Resource: resource
            }
        ],
    };
}

const handler = async (request: ClaimVerifyRequest): Promise<ClaimVerifyResult> => {
    try {
        console.log(`user claim verify invoked for ${JSON.stringify(request)}`);
        const token = request.queryStringParameters.token;
        if (!token) {
            if (allowUnauthenticated) {
                return {
                    principalId: 'anon',
                    policyDocument: generatePolicy(request.methodArn, "Allow"),
                    context: null
                }
            }

            throw new Error('token is empty');
        }

        const tokenSections = token.split('.');
        if (tokenSections.length < 2) {
            throw new Error('requested token is invalid');
        }
        const headerJSON = Buffer.from(tokenSections[0], 'base64').toString('utf8');
        const header = JSON.parse(headerJSON) as TokenHeader;
        const keys = await getPublicKeys();
        const key = keys[header.kid];
        if (key === undefined) {
            throw new Error('claim made for unknown kid');
        }
        const claim = await verifyPromised(token, key.pem) as Claim;
        const currentSeconds = Math.floor((new Date()).valueOf() / 1000);
        if (currentSeconds > claim.exp || currentSeconds < claim.auth_time) {
            throw new Error('claim is expired or invalid');
        }
        if (!cognitoApiScopes.split(" ").every(scope => claim.scope.split(" ").some(s => s == scope))) {
            throw new Error(`claim misses scope, required: ${cognitoApiScopes}`);
        }
        if (claim.iss !== cognitoIssuer) {
            throw new Error('claim issuer is invalid');
        }
        if (claim.token_use !== 'access') {
            throw new Error('claim use is not access');
        }

        console.log(`claim confirmed for ${claim.username}`);
        return {
            principalId: 'user',
            policyDocument: generatePolicy(request.methodArn, "Allow"),
            context: claim
        };
    } catch (error) {
        console.error("Failed to verify token", error);
        return {
            principalId: null,
            policyDocument: generatePolicy(request.methodArn, "Deny"),
            context: {}
        };
    }
};

export {handler};
