import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone", // ✅ Required for Docker & Kubernetes

  // ✅ Allow production build even with ESLint / TS issues
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },

  async rewrites() {
    return [
      {
        source: "/api/:path*",
        // ⚠️ IMPORTANT:
        // This MUST be your Kubernetes backend service name later
        destination: "http://todo-backend:8000/api/:path*",
      },
    ];
  },
};

export default nextConfig;
