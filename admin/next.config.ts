import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    // !! WARN !!
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    ignoreBuildErrors: true,
  },

  /*
  devIndicators: {
    buildActivity: false,
  },
  */
  async rewrites() {
    const backend = process.env.NEXT_PUBLIC_API_BACKEND || process.env.NEXT_PUBLIC_API_URL?.replace(/\/api\/?$/, '') || 'http://localhost:3001';
    const base = backend.replace(/\/+$/, '');
    return [
      { source: '/api/:path*', destination: `${base}/api/:path*` },
      { source: '/socket.io/:path*', destination: `${base}/socket.io/:path*` },
      { source: '/assets/:path*', destination: `${base}/assets/:path*` },
      { source: '/reels/:path*', destination: `${base}/reels/:path*` },
    ];
  },
};

export default nextConfig;
