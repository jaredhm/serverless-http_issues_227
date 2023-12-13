/* eslint-env node */

const path = require("path");

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  compiler: {
    removeConsole: true,
  },
  output: "standalone",
  experimental: {
    outputFileTracingRoot: path.join(__dirname, "..", ".."),
    scrollRestoration: false,
  },
};

module.exports = nextConfig;
