#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
NEXT_DIR="$SCRIPT_DIR/../.next"
STANDALONE_DIR="$NEXT_DIR/standalone"
DIST_DIR="$SCRIPT_DIR/../../../dist/.next"
set -eo pipefail
shopt -s extglob

pushd "$SCRIPT_DIR/.."
  rm -f "$NEXT_DIR/handler.zip"
  npx next build
  # Remove extra Prisma query engines.
  rm -f $STANDALONE_DIR/node_modules/.prisma/client/libquery_engine-[^rhel]*
  # Copy in our handler file.
  cp $SCRIPT_DIR/handler-lambda.js $STANDALONE_DIR/handler.js
  # Add in serverless-http module.
  serverless_http_module=$(dirname $(node -e "console.log(require.resolve('serverless-http'))"))
  cp -r "$serverless_http_module" $STANDALONE_DIR/node_modules/serverless-http
  # Copy in the static directory. This is only necessary when we're not shipping this to S3.
  #  cp -r "$NEXT_DIR/static" "$STANDALONE_DIR/components/frontend/.next"
  # Copy in the public directory.
  cp -r public $STANDALONE_DIR/packages/site/public
  pushd "$STANDALONE_DIR"
    zip -rq "$NEXT_DIR/handler.zip" .
  popd
  # Move the dist files up to the root of the repo.
  rm -rf "$DIST_DIR" && mkdir -p "$DIST_DIR"
  cp -r "$NEXT_DIR/handler.zip" "$DIST_DIR/handler.zip"
  cp -r "$NEXT_DIR/static" "$DIST_DIR/static"
popd
