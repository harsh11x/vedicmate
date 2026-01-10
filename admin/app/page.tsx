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

      {/* Welcome Section */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Overview</h1>
          <p className="text-gray-500 text-sm mt-1">Real-time insights and performance metrics.</p>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((stat, index) => (
          <Link
            key={stat.title}
            href={stat.href}
            className={`bg-white rounded-xl p-6 border border-gray-100 shadow-sm hover:shadow-md transition-all duration-200 group ${stat.pulse ? 'ring-2 ring-purple-100' : ''}`}
          >
            <div className="flex items-center justify-between mb-4">
              <div className={`w-10 h-10 rounded-lg flex items-center justify-center text-lg ${stat.bgColor} ${stat.textColor}`}>
                {stat.icon}
              </div>
              {stat.pulse && (
                <span className="flex h-2.5 w-2.5 relative">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-purple-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-purple-500"></span>
                </span>
              )}
            </div>
            <div className="space-y-1">
              <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">{stat.title}</p>
            </div>
            <div className="mt-4 pt-4 border-t border-gray-50 flex items-center justify-between">
              <span className="text-xs text-gray-400">{stat.subtitle}</span>
              <span className="text-gray-300 group-hover:text-gray-500 transition-colors">→</span>
            </div>
          </Link>
        ))}
      </div>

      {/* Two Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Recent Custom Requests - Wants 2/3 width */}
        <div className="lg:col-span-2 bg-white rounded-xl border border-gray-100 shadow-sm flex flex-col">
          <div className="p-6 border-b border-gray-100 flex items-center justify-between">
            <h3 className="font-bold text-gray-800">Recent Activity</h3>
            <Link href="/custom-requests" className="text-xs font-semibold text-orange-600 hover:text-orange-700">
              View All Requests
            </Link>
          </div>
          <div className="p-2 flex-1">
            {recentRequests.length > 0 ? (
              <div className="divide-y divide-gray-50">
                {recentRequests.map((req: any) => (
                  <div key={req.id} className="p-4 hover:bg-gray-50 rounded-lg transition-colors flex items-center justify-between group">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 rounded-full bg-orange-50 text-orange-600 flex items-center justify-center text-sm font-bold">
                        {req.userName?.[0]?.toUpperCase() || "?"}
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-gray-900">{req.serviceName || "Custom Request"}</p>
                        <p className="text-xs text-gray-500">{req.userName || "Guest User"}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <span className={`px-2.5 py-1 rounded-full text-[10px] font-semibold uppercase tracking-wider ${req.status === 'pending' ? 'bg-yellow-50 text-yellow-600' :
                        req.status === 'scheduled' ? 'bg-blue-50 text-blue-600' :
                          req.status === 'completed' ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'
                        }`}>
                        {req.status}
                      </span>
                      <span className="text-xs text-gray-400 group-hover:text-orange-500 transition-colors">Manage</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center h-64 text-center">
                <div className="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center text-2xl text-gray-400 mb-4">Inbox</div>
                <p className="text-gray-900 font-medium">No recent requests</p>
                <p className="text-xs text-gray-500 mt-1">New requests will appear here</p>
              </div>
            )}
          </div>
        </div>

        {/* Quick Actions - 1/3 width */}
        <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 h-fit">
          <h3 className="font-bold text-gray-800 mb-4">Quick Navigation</h3>
          <div className="space-y-3">
            {[
              { label: "Manage Orders", href: "/orders", icon: "📦", color: "text-blue-600", bg: "bg-blue-50" },
              { label: "Live Sessions", href: "/live-sessions", icon: "📹", color: "text-purple-600", bg: "bg-purple-50" },
              { label: "Product Inventory", href: "/products", icon: "📊", color: "text-green-600", bg: "bg-green-50" },
              { label: "Service Requests", href: "/custom-requests", icon: "🙏", color: "text-orange-600", bg: "bg-orange-50" },
            ].map((action) => (
              <Link
                key={action.href}
                href={action.href}
                className="flex items-center gap-4 p-3 rounded-lg hover:bg-gray-50 border border-transparent hover:border-gray-100 transition-all group"
              >
                <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-sm ${action.bg} ${action.color}`}>
                  {action.icon}
                </div>
                <span className="text-sm font-medium text-gray-700 group-hover:text-gray-900">{action.label}</span>
                <span className="ml-auto text-gray-300 group-hover:text-gray-400">→</span>
              </Link>
            ))}
          </div>

          <div className="mt-8 pt-6 border-t border-gray-100">
            <div className="p-4 bg-gradient-to-br from-gray-900 to-gray-800 rounded-xl text-white text-center">
              <p className="text-xs opacity-70 mb-1">System Status</p>
              <p className="font-bold text-sm tracking-wide">ALL SYSTEMS OPERATIONAL</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
