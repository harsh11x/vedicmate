"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { io } from "socket.io-client";

const API_BASE = "http://15.207.36.26:3001/api";

interface Stats {
  orders: { total: number; pending: number; delivered: number; revenue: number };
  customRequests: { total: number; pending: number; scheduled: number; completed: number; totalRevenue: number };
  liveSessions: { total: number; scheduled: number; live: number; completed: number };
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [recentRequests, setRecentRequests] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Socket Listeners for Real-time Updates
    const socket = io(API_BASE.replace('/api', '')); // Connect to root

    socket.on('custom-requests-update', () => fetchStats());
    socket.on('live-sessions-update', () => fetchStats());
    socket.on('orders-update', () => fetchStats());
    socket.on('products-update', () => fetchStats()); // Listen for stock updates

    fetchStats();

    return () => {
      socket.disconnect();
    };
  }, []);

  const fetchStats = async () => {
    try {
      setError(null);
      const [ordersRes, requestsRes, sessionsRes, recentRes] = await Promise.all([
        fetch(`${API_BASE}/admin/orders/stats`).catch(() => null),
        fetch(`${API_BASE}/admin/custom-requests/stats`).catch(() => null),
        fetch(`${API_BASE}/admin/live-sessions`).catch(() => null),
        fetch(`${API_BASE}/admin/custom-requests`).catch(() => null),
      ]);

      const ordersData = ordersRes ? await ordersRes.json().catch(() => ({})) : {};
      const requestsData = requestsRes ? await requestsRes.json().catch(() => ({})) : {};
      const sessionsData = sessionsRes ? await sessionsRes.json().catch(() => ({})) : {};
      const recentData = recentRes ? await recentRes.json().catch(() => ({})) : {};

      setStats({
        orders: ordersData.data || { total: 0, pending: 0, delivered: 0, revenue: 0 },
        customRequests: requestsData.data || { total: 0, pending: 0, scheduled: 0, completed: 0, totalRevenue: 0 },
        liveSessions: {
          total: sessionsData.count || 0,
          scheduled: sessionsData.data?.filter((s: any) => s.status === "scheduled").length || 0,
          live: sessionsData.data?.filter((s: any) => s.status === "live").length || 0,
          completed: sessionsData.data?.filter((s: any) => s.status === "completed").length || 0,
        },
      });
      setRecentRequests(recentData.data?.slice(0, 5) || []);
    } catch (err) {
      setError("Unable to connect to server");
      console.error("Error fetching stats:", err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-36 shimmer rounded-2xl" />
          ))}
        </div>
      </div>
    );
  }

  const statCards = [
    {
      title: "Custom Requests",
      value: stats?.customRequests.total || 0,
      subtitle: `${stats?.customRequests.pending || 0} pending`,
      icon: "🙏",
      gradient: "from-orange-400 to-orange-600",
      bgColor: "bg-orange-50",
      textColor: "text-orange-600",
      borderClass: "stat-card-orange",
      href: "/custom-requests"
    },
    {
      title: "Live Sessions",
      value: stats?.liveSessions.total || 0,
      subtitle: stats?.liveSessions.live ? `${stats.liveSessions.live} live now` : `${stats?.liveSessions.scheduled || 0} scheduled`,
      icon: "📹",
      gradient: "from-purple-400 to-purple-600",
      bgColor: "bg-purple-50",
      textColor: "text-purple-600",
      borderClass: "stat-card-purple",
      pulse: (stats?.liveSessions.live || 0) > 0,
      href: "/live-sessions"
    },
    {
      title: "Product Orders",
      value: stats?.orders.total || 0,
      subtitle: `${stats?.orders.pending || 0} processing`,
      icon: "🛒",
      gradient: "from-blue-400 to-blue-600",
      bgColor: "bg-blue-50",
      textColor: "text-blue-600",
      borderClass: "stat-card-blue",
      href: "/orders"
    },
    {
      title: "Total Revenue",
      value: `₹${((stats?.customRequests.totalRevenue || 0) + (stats?.orders.revenue || 0)).toLocaleString()}`,
      subtitle: "All time earnings",
      icon: "💰",
      gradient: "from-green-400 to-green-600",
      bgColor: "bg-green-50",
      textColor: "text-green-600",
      borderClass: "stat-card-green",
      href: "#"
    },
  ];

  return (
    <div className="space-y-8">
      {/* Error Banner */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-2xl p-4 flex items-center gap-3">
          <span className="text-2xl">⚠️</span>
          <div>
            <p className="font-semibold text-red-700">{error}</p>
            <p className="text-sm text-red-500">Make sure the backend server is running on port 4000</p>
          </div>
        </div>
      )}

      {/* Welcome Card */}
      <div className="bg-gradient-to-r from-orange-500 to-pink-500 rounded-3xl p-8 text-white relative overflow-hidden shadow-xl shadow-orange-200">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-0 w-48 h-48 bg-white/10 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2" />
        <div className="relative">
          <h1 className="text-3xl font-bold mb-2">Welcome back! 🙏</h1>
          <p className="text-white/80 text-lg">Here's what's happening with your Vedic services today.</p>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((stat, index) => (
          <Link
            key={stat.title}
            href={stat.href}
            className={`bg-white rounded-2xl p-6 shadow-sm hover:shadow-xl transition-all duration-300 hover:-translate-y-1 ${stat.borderClass} stat-card fade-in`}
            style={{ animationDelay: `${index * 0.1}s`, opacity: 0 }}
          >
            <div className="flex items-start justify-between mb-4">
              <div className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${stat.gradient} flex items-center justify-center text-2xl shadow-lg ${stat.pulse ? 'pulse-live' : ''}`}>
                {stat.icon}
              </div>
              {stat.pulse && (
                <span className="px-3 py-1.5 text-xs font-bold bg-red-100 text-red-600 rounded-full animate-pulse">
                  LIVE
                </span>
              )}
            </div>
            <p className={`text-3xl font-bold ${stat.textColor} mb-1`}>{stat.value}</p>
            <p className="text-sm font-semibold text-gray-700">{stat.title}</p>
            <p className="text-xs text-gray-400 mt-1">{stat.subtitle}</p>
          </Link>
        ))}
      </div>

      {/* Two Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Custom Requests */}
        <div className="bg-white rounded-2xl p-6 shadow-sm fade-in" style={{ animationDelay: "0.4s", opacity: 0 }}>
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-lg font-bold text-gray-800">Recent Requests</h3>
            <Link href="/custom-requests" className="text-sm font-semibold text-orange-500 hover:text-orange-600 transition-colors">
              View All →
            </Link>
          </div>
          {recentRequests.length > 0 ? (
            <div className="space-y-3">
              {recentRequests.map((req: any) => (
                <div key={req.id} className="flex items-center justify-between p-4 rounded-xl bg-gray-50 hover:bg-orange-50 transition-colors">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-orange-100 to-orange-200 flex items-center justify-center text-xl">
                      🙏
                    </div>
                    <div>
                      <p className="font-semibold text-gray-800">{req.serviceName}</p>
                      <p className="text-xs text-gray-400">{req.userName || "Unknown User"}</p>
                    </div>
                  </div>
                  <span className={`${req.status === 'pending' ? 'badge-pending' :
                    req.status === 'scheduled' ? 'badge-scheduled' :
                      req.status === 'completed' ? 'badge-completed' : 'badge-cancelled'
                    }`}>
                    {req.status}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12 bg-gray-50 rounded-xl">
              <div className="text-5xl mb-3">🙏</div>
              <p className="text-gray-500 font-medium">No custom requests yet</p>
              <p className="text-xs text-gray-400 mt-1">Requests will appear here</p>
            </div>
          )}
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-2xl p-6 shadow-sm fade-in" style={{ animationDelay: "0.5s", opacity: 0 }}>
          <h3 className="text-lg font-bold text-gray-800 mb-6">Quick Actions</h3>
          <div className="grid grid-cols-2 gap-4">
            <Link
              href="/custom-requests"
              className="group p-5 rounded-xl bg-gradient-to-br from-orange-50 to-orange-100 border-2 border-orange-200 hover:border-orange-400 transition-all hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center text-2xl mb-4 shadow-lg shadow-orange-200 group-hover:scale-110 transition-transform">
                🙏
              </div>
              <p className="font-bold text-gray-800">View Requests</p>
              <p className="text-xs text-gray-500 mt-1">Manage puja bookings</p>
            </Link>

            <Link
              href="/live-sessions"
              className="group p-5 rounded-xl bg-gradient-to-br from-purple-50 to-purple-100 border-2 border-purple-200 hover:border-purple-400 transition-all hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center text-2xl mb-4 shadow-lg shadow-purple-200 group-hover:scale-110 transition-transform">
                📹
              </div>
              <p className="font-bold text-gray-800">Live Sessions</p>
              <p className="text-xs text-gray-500 mt-1">Start video sessions</p>
            </Link>

            <Link
              href="/orders"
              className="group p-5 rounded-xl bg-gradient-to-br from-blue-50 to-blue-100 border-2 border-blue-200 hover:border-blue-400 transition-all hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-2xl mb-4 shadow-lg shadow-blue-200 group-hover:scale-110 transition-transform">
                🛒
              </div>
              <p className="font-bold text-gray-800">View Orders</p>
              <p className="text-xs text-gray-500 mt-1">Track shipments</p>
            </Link>

            <Link
              href="/products"
              className="group p-5 rounded-xl bg-gradient-to-br from-green-50 to-green-100 border-2 border-green-200 hover:border-green-400 transition-all hover:-translate-y-1"
            >
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-green-400 to-green-600 flex items-center justify-center text-2xl mb-4 shadow-lg shadow-green-200 group-hover:scale-110 transition-transform">
                📦
              </div>
              <p className="font-bold text-gray-800">Products</p>
              <p className="text-xs text-gray-500 mt-1">Manage inventory</p>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
