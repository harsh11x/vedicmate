"use client";

import { useEffect, useState } from "react";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "https://15.207.36.26:3001/api";

interface LiveSession {
    id: string;
    sessionId: string;
    customRequestId: string;
    userId: string;
    panditId: string;
    panditName: string;
    title: string;
    description: string;
    scheduledDate: string;
    scheduledTime: string;
    duration: number;
    status: string;
    roomId: string;
    isLive: boolean;
    startedAt: string | null;
    endedAt: string | null;
    createdAt: string;
}

export default function LiveSessionsPage() {
    const [sessions, setSessions] = useState<LiveSession[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState("all");
    const [error, setError] = useState<string | null>(null);

    const fetchSessions = async () => {
        try {
            setError(null);
            const url = filter === "all"
                ? `${API_BASE}/admin/live-sessions`
                : `${API_BASE}/admin/live-sessions?status=${filter}`;
            const res = await fetch(url);
            if (!res.ok) throw new Error("Failed to fetch");
            const data = await res.json();
            setSessions(data.data || []);
        } catch (err) {
            setError("Unable to connect to server");
            console.error("Error:", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSessions();
        const interval = setInterval(fetchSessions, 10000);
        return () => clearInterval(interval);
    }, [filter]);

    const startSession = async (id: string) => {
        try {
            await fetch(`${API_BASE}/admin/live-sessions/${id}/start`, { method: "PUT" });
            fetchSessions();
        } catch (err) {
            console.error("Error:", err);
        }
    };

    const endSession = async (id: string) => {
        try {
            await fetch(`${API_BASE}/admin/live-sessions/${id}/end`, { method: "PUT" });
            fetchSessions();
        } catch (err) {
            console.error("Error:", err);
        }
    };

    const filters = [
        { value: "all", label: "All Sessions" },
        { value: "scheduled", label: "Scheduled", color: "bg-purple-500" },
        { value: "live", label: "Live", color: "bg-red-500" },
        { value: "completed", label: "Completed", color: "bg-green-500" },
    ];

    const liveSessions = sessions.filter(s => s.status === "live");

    if (loading) {
        return (
            <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                    <div key={i} className="h-28 shimmer rounded-2xl" />
                ))}
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Error Banner */}
            {error && (
                <div className="bg-red-50 border border-red-200 rounded-2xl p-4 flex items-center gap-3">
                    <span className="text-2xl">⚠️</span>
                    <p className="font-semibold text-red-700">{error}</p>
                </div>
            )}

            {/* Live Now Banner */}
            {liveSessions.length > 0 && (
                <div className="bg-gradient-to-r from-red-500 to-pink-500 rounded-3xl p-6 text-white shadow-xl shadow-red-200">
                    <div className="flex items-center gap-4 mb-4">
                        <div className="relative">
                            <div className="w-5 h-5 bg-white rounded-full animate-ping absolute" />
                            <div className="w-5 h-5 bg-white rounded-full relative" />
                        </div>
                        <h2 className="text-2xl font-bold">
                            {liveSessions.length} Session{liveSessions.length > 1 ? "s" : ""} Live Now
                        </h2>
                    </div>
                    <div className="space-y-3">
                        {liveSessions.map((session) => (
                            <div key={session.id} className="flex items-center justify-between bg-white/20 backdrop-blur p-4 rounded-xl">
                                <div className="flex items-center gap-4">
                                    <div className="w-12 h-12 rounded-xl bg-white/30 flex items-center justify-center text-2xl">
                                        📹
                                    </div>
                                    <div>
                                        <p className="font-bold">{session.title}</p>
                                        <p className="text-sm text-white/80">by {session.panditName}</p>
                                    </div>
                                </div>
                                <button onClick={() => endSession(session.id)} className="px-5 py-2.5 bg-white text-red-600 font-bold rounded-xl hover:bg-red-50 transition-colors">
                                    End Session
                                </button>
                            </div>
                        ))}
                    </div>
                </div>
            )}

            {/* Header with Filters */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-2 overflow-x-auto pb-2 md:pb-0">
                    {filters.map((f) => (
                        <button
                            key={f.value}
                            onClick={() => setFilter(f.value)}
                            className={`px-5 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all ${filter === f.value
                                ? "bg-gradient-to-r from-purple-500 to-purple-600 text-white shadow-lg shadow-purple-200"
                                : "bg-white text-gray-600 hover:text-gray-900 hover:bg-gray-50 border border-gray-200"
                                }`}
                        >
                            {f.color && <span className={`inline-block w-2 h-2 ${f.color} rounded-full mr-2`} />}
                            {f.label}
                        </button>
                    ))}
                </div>
                <button onClick={fetchSessions} className="btn-secondary flex items-center gap-2">
                    <span>↻</span> Refresh
                </button>
            </div>

            {/* Sessions List */}
            {sessions.length === 0 ? (
                <div className="bg-white rounded-2xl p-16 text-center shadow-sm">
                    <div className="text-6xl mb-4">📹</div>
                    <h3 className="text-xl font-bold text-gray-800 mb-2">No Live Sessions</h3>
                    <p className="text-gray-500">Schedule sessions from Custom Requests to appear here</p>
                </div>
            ) : (
                <div className="space-y-4">
                    {sessions.map((session, index) => (
                        <div
                            key={session.id}
                            className={`bg-white rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all duration-300 fade-in ${session.status === 'live' ? 'ring-2 ring-red-500' : ''}`}
                            style={{ animationDelay: `${index * 0.05}s`, opacity: 0 }}
                        >
                            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                                {/* Left: Session Info */}
                                <div className="flex items-start gap-4">
                                    <div className={`w-14 h-14 rounded-2xl flex items-center justify-center text-2xl ${session.status === 'live'
                                        ? 'bg-gradient-to-br from-red-400 to-red-600 pulse-live'
                                        : session.status === 'scheduled'
                                            ? 'bg-gradient-to-br from-purple-100 to-purple-200'
                                            : 'bg-gradient-to-br from-green-100 to-green-200'
                                        }`}>
                                        {session.status === 'live' ? '🔴' : session.status === 'scheduled' ? '📅' : '✅'}
                                    </div>
                                    <div>
                                        <div className="flex items-center gap-3 mb-1">
                                            <h3 className="text-lg font-bold text-gray-800">{session.title}</h3>
                                            <span className={`${session.status === 'live' ? 'badge-live' :
                                                session.status === 'scheduled' ? 'badge-scheduled' : 'badge-completed'
                                                }`}>
                                                {session.status === 'live' ? '🔴 LIVE' : session.status}
                                            </span>
                                        </div>
                                        <p className="text-sm text-gray-400 font-mono">{session.sessionId}</p>
                                        <div className="flex flex-wrap items-center gap-4 mt-3 text-sm text-gray-500">
                                            <span className="flex items-center gap-1.5">👤 {session.panditName}</span>
                                            <span className="flex items-center gap-1.5">📅 {session.scheduledDate} {session.scheduledTime}</span>
                                            <span className="flex items-center gap-1.5">⏱️ {session.duration} mins</span>
                                        </div>
                                    </div>
                                </div>

                                {/* Right: Actions */}
                                <div className="flex items-center gap-3 mt-4 lg:mt-0">
                                    {session.status === "scheduled" && (
                                        <button onClick={() => startSession(session.id)} className="btn-success">
                                            ▶️ Start Session
                                        </button>
                                    )}

                                    {session.status === "live" && (
                                        <button onClick={() => endSession(session.id)} className="btn-danger">
                                            ⏹️ End Session
                                        </button>
                                    )}

                                    {session.status === "completed" && (
                                        <span className="text-sm text-gray-400">
                                            Ended {session.endedAt ? new Date(session.endedAt).toLocaleTimeString() : ""}
                                        </span>
                                    )}
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Help Card */}
            <div className="bg-gradient-to-r from-purple-50 to-purple-100 rounded-2xl p-6 border border-purple-200">
                <div className="flex items-start gap-4">
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center text-2xl shadow-lg shadow-purple-200">
                        💡
                    </div>
                    <div>
                        <h3 className="font-bold text-gray-800 mb-2">How Live Sessions Work</h3>
                        <ol className="list-decimal list-inside space-y-1 text-sm text-gray-600">
                            <li>Accept a Custom Request and schedule a Live Session</li>
                            <li>Click <span className="text-green-600 font-semibold">"Start Session"</span> when ready to go live</li>
                            <li>Users receive notification and can join the video call</li>
                            <li>Click <span className="text-red-600 font-semibold">"End Session"</span> when complete</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    );
}
