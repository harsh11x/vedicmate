"use client";

import { useEffect, useState } from "react";

const API_BASE = "/api";

interface CustomRequest {
    id: string;
    requestId: string;
    userId: string;
    type: string;
    serviceName: string;
    description: string;
    preferredDate: string;
    preferredTime: string;
    duration: number;
    price: number;
    status: string;
    paymentStatus: string;
    userName: string;
    userPhone: string;
    userEmail: string;
    notes: string;
    liveSessionId: string | null;
    createdAt: string;
    updatedAt: string;
}

export default function CustomRequestsPage() {
    const [requests, setRequests] = useState<CustomRequest[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedRequest, setSelectedRequest] = useState<CustomRequest | null>(null);
    const [showScheduleModal, setShowScheduleModal] = useState(false);
    const [showAcceptModal, setShowAcceptModal] = useState(false);
    const [showCancelModal, setShowCancelModal] = useState(false);
    const [filter, setFilter] = useState("all");
    const [error, setError] = useState<string | null>(null);
    const [actionNote, setActionNote] = useState("");

    const [scheduleForm, setScheduleForm] = useState({
        panditName: "",
        scheduledDate: "",
        scheduledTime: "",
        duration: 60,
        price: 0,
        notes: "",
    });

    const fetchRequests = async () => {
        try {
            setError(null);
            const url = filter === "all"
                ? `${API_BASE}/admin/custom-requests`
                : `${API_BASE}/admin/custom-requests?status=${filter}`;
            const res = await fetch(url);
            if (!res.ok) throw new Error("Failed to fetch");
            const data = await res.json();
            setRequests(data.requests || data.data || []);
        } catch (err) {
            setError("Unable to connect to server");
            console.error("Error:", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchRequests();
    }, [filter]);

    const getId = (req: CustomRequest & { orderId?: string }) => req.orderId || req.id || req.requestId;

    const updateStatus = async (id: string, status: string, notes?: string) => {
        try {
            await fetch(`${API_BASE}/admin/custom-requests/${id}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ status, notes: notes || undefined }),
            });
            setShowAcceptModal(false);
            setShowCancelModal(false);
            setSelectedRequest(null);
            setActionNote("");
            fetchRequests();
        } catch (err) {
            console.error("Error:", err);
        }
    };

    const createLiveSession = async () => {
        if (!selectedRequest) return;

        try {
            await fetch(`${API_BASE}/admin/custom-requests/${selectedRequest.id}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    status: "scheduled",
                    price: scheduleForm.price,
                    notes: scheduleForm.notes,
                }),
            });

            await fetch(`${API_BASE}/admin/live-sessions`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    customRequestId: selectedRequest.id,
                    userId: selectedRequest.userId,
                    panditName: scheduleForm.panditName,
                    title: selectedRequest.serviceName,
                    scheduledDate: scheduleForm.scheduledDate,
                    scheduledTime: scheduleForm.scheduledTime,
                    duration: scheduleForm.duration,
                }),
            });

            setShowScheduleModal(false);
            setSelectedRequest(null);
            setScheduleForm({ panditName: "", scheduledDate: "", scheduledTime: "", duration: 60, price: 0, notes: "" });
            fetchRequests();
        } catch (err) {
            console.error("Error:", err);
        }
    };

    const filters = [
        { value: "all", label: "All Requests", color: "bg-gray-500" },
        { value: "pending", label: "Pending", color: "bg-yellow-500" },
        { value: "scheduled", label: "Scheduled", color: "bg-purple-500" },
        { value: "completed", label: "Completed", color: "bg-green-500" },
        { value: "cancelled", label: "Cancelled", color: "bg-gray-400" },
    ];

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

            {/* Header with Filters */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-2 overflow-x-auto pb-2 md:pb-0">
                    {filters.map((f) => (
                        <button
                            key={f.value}
                            onClick={() => setFilter(f.value)}
                            className={`px-5 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all ${filter === f.value
                                ? "bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow-lg shadow-orange-200"
                                : "bg-white text-gray-600 hover:text-gray-900 hover:bg-gray-50 border border-gray-200"
                                }`}
                        >
                            {f.value !== "all" && <span className={`inline-block w-2 h-2 ${f.color} rounded-full mr-2`} />}
                            {f.label}
                        </button>
                    ))}
                </div>
                <button onClick={fetchRequests} className="btn-secondary flex items-center gap-2">
                    <span>↻</span> Refresh
                </button>
            </div>

            {/* Requests List */}
            {requests.length === 0 ? (
                <div className="bg-white rounded-2xl p-16 text-center shadow-sm">
                    <div className="text-6xl mb-4">🙏</div>
                    <h3 className="text-xl font-bold text-gray-800 mb-2">No Requests Found</h3>
                    <p className="text-gray-500">Custom puja and havan requests will appear here</p>
                </div>
            ) : (
                <div className="space-y-4">
                    {requests.map((request, index) => (
                        <div
                            key={request.id}
                            className="bg-white rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all duration-300 fade-in"
                            style={{ animationDelay: `${index * 0.05}s`, opacity: 0 }}
                        >
                            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                                {/* Left: Request Info */}
                                <div className="flex items-start gap-4">
                                    <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-orange-100 to-orange-200 flex items-center justify-center text-2xl">
                                        {request.type === 'havan' ? '🔥' : request.type === 'homam' ? '🪔' : '🙏'}
                                    </div>
                                    <div>
                                        <div className="flex items-center gap-3 mb-1">
                                            <h3 className="text-lg font-bold text-gray-800">{request.serviceName || request.serviceType || "Custom Request"}</h3>
                                            <span className={`${request.status === 'pending' ? 'badge-pending' :
                                                request.status === 'scheduled' ? 'badge-scheduled' :
                                                    request.status === 'completed' ? 'badge-completed' : 'badge-cancelled'
                                                }`}>
                                                {request.status}
                                            </span>
                                        </div>
                                        <p className="text-sm text-gray-400 font-mono">{request.orderId || request.requestId || request.id}</p>
                                        <div className="flex flex-wrap items-center gap-4 mt-3 text-sm text-gray-500">
                                            <span className="flex items-center gap-1.5">👤 {request.userName || "Unknown"}</span>
                                            <span className="flex items-center gap-1.5">📞 {request.userPhone || "N/A"}</span>
                                            <span className="flex items-center gap-1.5">📅 {request.preferredDate || request.date || "Flexible"} {request.preferredTime || request.timeSlot || ""}</span>
                                        </div>
                                        {(request as any).adminNotes && (
                                            <p className="mt-2 text-xs text-amber-700 bg-amber-50 px-2 py-1 rounded">Note: {(request as any).adminNotes}</p>
                                        )}
                                    </div>
                                </div>

                                {/* Right: Actions */}
                                <div className="flex items-center gap-3 mt-4 lg:mt-0">
                                    {(request.price > 0 || request.amount > 0) && (
                                        <span className="text-xl font-bold text-orange-600">₹{request.price || request.amount}</span>
                                    )}
                                    {request.amount === "TBD" && <span className="text-sm text-gray-500">Price TBD</span>}

                                    {request.status === "pending" && (
                                        <>
                                            <button
                                                onClick={() => {
                                                    setSelectedRequest(request);
                                                    setShowScheduleModal(true);
                                                }}
                                                className="btn-primary"
                                            >
                                                Schedule Session
                                            </button>
                                            <button
                                                onClick={() => { setSelectedRequest(request); setShowAcceptModal(true); }}
                                                className="px-4 py-2 rounded-xl bg-green-500 hover:bg-green-600 text-white font-semibold text-sm"
                                            >
                                                Accept
                                            </button>
                                            <button
                                                onClick={() => { setSelectedRequest(request); setShowCancelModal(true); }}
                                                className="btn-secondary"
                                            >
                                                Cancel
                                            </button>
                                        </>
                                    )}

                                    {request.status === "scheduled" && request.liveSessionId && (
                                        <a href="/live-sessions" className="btn-secondary">
                                            View Session →
                                        </a>
                                    )}
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Schedule Modal */}
            {showScheduleModal && selectedRequest && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => setShowScheduleModal(false)}>
                    <div
                        className="bg-white rounded-3xl p-8 w-full max-w-lg shadow-2xl"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="text-2xl font-bold text-gray-800">Schedule Live Session</h2>
                            <button onClick={() => setShowScheduleModal(false)} className="text-gray-400 hover:text-gray-600 text-2xl">×</button>
                        </div>

                        <div className="mb-6 p-4 rounded-2xl bg-gradient-to-r from-orange-50 to-orange-100 border border-orange-200">
                            <p className="text-xs text-orange-500 font-semibold mb-1">SERVICE</p>
                            <p className="text-lg font-bold text-gray-800">{selectedRequest.serviceName}</p>
                            <p className="text-sm text-gray-500 mt-1">For: {selectedRequest.userName}</p>
                        </div>

                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Pandit Name</label>
                                <input
                                    type="text"
                                    value={scheduleForm.panditName}
                                    onChange={(e) => setScheduleForm({ ...scheduleForm, panditName: e.target.value })}
                                    placeholder="Pandit Shastri Ji"
                                    className="modern-input"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">Date</label>
                                    <input
                                        type="date"
                                        value={scheduleForm.scheduledDate}
                                        onChange={(e) => setScheduleForm({ ...scheduleForm, scheduledDate: e.target.value })}
                                        className="modern-input"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">Time</label>
                                    <input
                                        type="time"
                                        value={scheduleForm.scheduledTime}
                                        onChange={(e) => setScheduleForm({ ...scheduleForm, scheduledTime: e.target.value })}
                                        className="modern-input"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">Duration (mins)</label>
                                    <input
                                        type="number"
                                        value={scheduleForm.duration}
                                        onChange={(e) => setScheduleForm({ ...scheduleForm, duration: parseInt(e.target.value) })}
                                        className="modern-input"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-2">Price (₹)</label>
                                    <input
                                        type="number"
                                        value={scheduleForm.price}
                                        onChange={(e) => setScheduleForm({ ...scheduleForm, price: parseInt(e.target.value) })}
                                        className="modern-input"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Notes</label>
                                <textarea
                                    value={scheduleForm.notes}
                                    onChange={(e) => setScheduleForm({ ...scheduleForm, notes: e.target.value })}
                                    placeholder="Any additional notes..."
                                    rows={3}
                                    className="modern-input resize-none"
                                />
                            </div>

                            <button onClick={createLiveSession} className="btn-primary w-full py-4 text-base mt-4">
                                Create Live Session
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Accept with Note Modal */}
            {showAcceptModal && selectedRequest && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => { setShowAcceptModal(false); setSelectedRequest(null); setActionNote(""); }}>
                    <div className="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl" onClick={(e) => e.stopPropagation()}>
                        <h2 className="text-xl font-bold text-gray-800 mb-4">Accept Request</h2>
                        <p className="text-sm text-gray-500 mb-4">{selectedRequest.serviceName || selectedRequest.serviceType} - {selectedRequest.userName}</p>
                        <label className="block text-sm font-semibold text-gray-700 mb-2">Note (optional - will be shown to user)</label>
                        <textarea
                            value={actionNote}
                            onChange={(e) => setActionNote(e.target.value)}
                            placeholder="e.g. We will contact you within 24 hours to finalize the session."
                            rows={3}
                            className="modern-input resize-none w-full mb-4"
                        />
                        <div className="flex gap-3">
                            <button onClick={() => { setShowAcceptModal(false); setSelectedRequest(null); setActionNote(""); }} className="btn-secondary flex-1">Cancel</button>
                            <button onClick={() => updateStatus(getId(selectedRequest as any), "accepted", actionNote)} className="flex-1 px-4 py-3 rounded-xl bg-green-500 hover:bg-green-600 text-white font-semibold">Accept</button>
                        </div>
                    </div>
                </div>
            )}

            {/* Cancel with Note Modal */}
            {showCancelModal && selectedRequest && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" onClick={() => { setShowCancelModal(false); setSelectedRequest(null); setActionNote(""); }}>
                    <div className="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl" onClick={(e) => e.stopPropagation()}>
                        <h2 className="text-xl font-bold text-gray-800 mb-4">Cancel Request</h2>
                        <p className="text-sm text-gray-500 mb-4">{selectedRequest.serviceName || selectedRequest.serviceType} - {selectedRequest.userName}</p>
                        <label className="block text-sm font-semibold text-gray-700 mb-2">Reason / Note (will be shown to user)</label>
                        <textarea
                            value={actionNote}
                            onChange={(e) => setActionNote(e.target.value)}
                            placeholder="e.g. We are unable to accommodate this request at the requested time."
                            rows={3}
                            className="modern-input resize-none w-full mb-4"
                        />
                        <div className="flex gap-3">
                            <button onClick={() => { setShowCancelModal(false); setSelectedRequest(null); setActionNote(""); }} className="btn-secondary flex-1">Back</button>
                            <button onClick={() => updateStatus(getId(selectedRequest as any), "cancelled", actionNote)} className="flex-1 px-4 py-3 rounded-xl bg-red-500 hover:bg-red-600 text-white font-semibold">Confirm Cancel</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
