/* eslint-disable */
const serverlessHttp = require("serverless-http");
const { default: NextServer } = require("next/dist/server/next-server");
const baseLogger = require("pino")({ level: "debug" });

/**
 * See https://github.com/dougmoscrop/serverless-http/issues/227 for prior art on
 * how we integrate NextJS & Serverless-HTTP.
 */
const NEXT_ROOT = `${__dirname}/packages/site`;
const REQUIRED_FILES_JSON = `${NEXT_ROOT}/.next/required-server-files.json`;

const config = require(REQUIRED_FILES_JSON).config;
const nextServer = new NextServer({
  // Hostname/port don't matter - we're not actually starting the HTTP server.
  hostname: "localhost",
  port: 3000,
  dir: NEXT_ROOT,
  dev: false,
  customServer: false,
  conf: config,
});
const nextHandler = nextServer.getRequestHandler();
const shimmedNextHandler = (req, res, parsedUrl) => {
  const logger = baseLogger.child({
    url: req.url,
    method: req.method,
    requestContext: req.requestContext,
  });
  logger.debug("handler-lambda::nextHandler");

  // monkey patch (not sure if it works) - https://github.com/dougmoscrop/serverless-http/issues/227#issuecomment-1922467440
  const innerWrite = res.write;
  const write = (...args) => {
    innerWrite.call(res, args);
    return true;
  };
  res.write = write;

  return nextHandler(req, res, parsedUrl);
};

const serverlessHandler = serverlessHttp(shimmedNextHandler, {
  // This will strip the APIG stage prefix off.
  basePath: "/default",
  // enable binary support for all content types:
  binary: ["*/*"],
  request: (request, _, context) => {
    // nextjs has a built in body parser middleware that won't parse
    // the body if there's already a body field on the request,
    // and serverless-http adds body field to the request, so
    // remove it:
    delete request.body;
    request.context = context;
  },
  response: (response, _, context) => {
    if (context.awsRequestId) {
      response.headers["x-lambda-request-id"] = context.awsRequestId;
    }
    const method = response.req.method;
    // Cache any successful response to a GET/HEAD request in the CDN for 5 minutes.
    if ((method === "GET" || method === "HEAD") && response.statusCode < 400) {
      response.headers["cache-control"] =
        "s-maxage=300, max-age=0, must-revalidate";
    }
  },
});

module.exports.handler = (event, context) => {
  const logger = baseLogger.child({
    resource: event.resource,
    path: event.path,
    method: event.httpMethod,
  });
  logger.debug("handler-lambda::rootHandler");
  return serverlessHandler(event, context);
};
