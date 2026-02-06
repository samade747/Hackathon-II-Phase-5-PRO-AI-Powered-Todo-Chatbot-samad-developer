import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone", // ✅ REQUIRED for Docker standalone build
  reactCompiler: true,

  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "http://127.0.0.1:8000/api/:path*", // Backend proxy
      },
    ];
  },
};

export default nextConfig;
