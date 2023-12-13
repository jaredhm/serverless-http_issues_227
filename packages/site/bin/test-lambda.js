const { handler } = require("./handler-lambda");

const httpMethod = "HEAD";
const url = "/";

/**
 * The test event for the Serverless HTTP handler.
 *
 * In order to test the `handler-lambda.js`, you must do the following:
 * - Change the NEXT_ROOT in the handler to `${__dirname}/..`
 * - Set the url and the method above.
 * - Create a production build: `npm run build`
 * - Run this script: `node ./packages/site/bin/test-lambda.js`
 */
const event = {
  resource: url,
  path: url,
  httpMethod: httpMethod,
  requestContext: {
    resourcePath: url,
    httpMethod: httpMethod,
    path: `/default${url}`,
  },
  headers: {
    accept: "text/html",
  },
  multiValueHeaders: {
    accept: ["text/html"],
  },
  queryStringParameters: null,
  multiValueQueryStringParameters: null,
  pathParameters: null,
  stageVariables: null,
  body: null,
  isBase64Encoded: false,
};

handler(event, {})
  .then((result) => {
    console.log(result);
  })
  .catch((err) => {
    console.error(err);
  });
