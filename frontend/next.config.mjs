/** @type {import('next').NextConfig} */
const nextConfig = {
  eslint: {
    ignoreDuringBuilds: true,
  },
  output: "standalone",
  basePath: "/frontend",
  assetPrefix: process.env.NEXT_PUBLIC_FRONTEND_URL,
};
export default nextConfig;
