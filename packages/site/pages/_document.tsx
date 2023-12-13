import { Html, Head, Main, NextScript } from "next/document";
import React from "react";

/**
 * Overrides the default Next.js Document so that we can customize the
 * static HTML markup to include scripts that need to be fetched before
 * any part of the page becomes interactive.
 *
 * The structure of this page is heavily dictated by Next.js.
 * This markup is only ever rendered during the initial export. Do not add
 * application logic in this file, use _app.jsx instead.
 *
 * @see https://nextjs.org/docs/advanced-features/custom-document
 */

const MyDocument = () => (
  <Html lang="en">
    <Head />
    <body>
      <Main />
      <NextScript />
    </body>
  </Html>
);

export default MyDocument;
