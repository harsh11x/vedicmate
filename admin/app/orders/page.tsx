"use client";

import { useEffect, useState } from "react";

const API_BASE = "/api";

interface Order {
    id: string;
    orderId: string;
    userId: string;
    items: Array<{ name: string; quantity: number; price: number }>;
    totalAmount: number;
    paymentStatus: string;
    deliveryStatus: string;
    shippingAddress: { fullName: string; phone: string; city: string; state: string };
    createdAt: string;
}

export default function OrdersPage() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState("all");
    const [error, setError] = useState<string | null>(null);

    const fetchOrders = async () => {
        try {
            setError(null);
            const url = filter === "all"
                ? `${API_BASE}/admin/orders`
                : `${API_BASE}/admin/orders?status=${filter}`;
            const res = await fetch(url);
            if (!res.ok) throw new Error("Failed to fetch");
            const data = await res.json();
            setOrders(data.data || []);
        } catch (err) {
            setError("Unable to connect to server");
            console.error("Error:", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchOrders();
    }, [filter]);

    const updateStatus = async (id: string, status: string) => {
        try {
            await fetch(`${API_BASE}/admin/orders/${id}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ deliveryStatus: status }),
            });
            fetchOrders();
        } catch (err) {
            console.error("Error:", err);
        }
    };

    const filters = [
        { value: "all", label: "All Orders" },
        { value: "pending", label: "Pending", color: "bg-yellow-500" },
        { value: "processing", label: "Processing", color: "bg-blue-500" },
        { value: "shipped", label: "Shipped", color: "bg-purple-500" },
        { value: "delivered", label: "Delivered", color: "bg-green-500" },
    ];

    const statusOptions = ["pending", "confirmed", "processing", "shipped", "delivered", "cancelled"];

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
                                ? "bg-gradient-to-r from-blue-500 to-blue-600 text-white shadow-lg shadow-blue-200"
                                : "bg-white text-gray-600 hover:text-gray-900 hover:bg-gray-50 border border-gray-200"
                                }`}
                        >
                            {f.color && <span className={`inline-block w-2 h-2 ${f.color} rounded-full mr-2`} />}
                            {f.label}
                        </button>
                    ))}
                </div>
                <button onClick={fetchOrders} className="btn-secondary flex items-center gap-2">
                    <span>↻</span> Refresh
                </button>
            </div>

            {/* Orders List */}
            {orders.length === 0 ? (
                <div className="bg-white rounded-2xl p-16 text-center shadow-sm">
                    <div className="text-6xl mb-4">🛒</div>
                    <h3 className="text-xl font-bold text-gray-800 mb-2">No Orders Found</h3>
                    <p className="text-gray-500">Product orders will appear here</p>
                </div>
            ) : (
                <div className="space-y-4">
                    {orders.map((order, index) => (
                        <div
                            key={order.id}
                            className="bg-white rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all duration-300 fade-in"
                            style={{ animationDelay: `${index * 0.05}s`, opacity: 0 }}
                        >
                            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                                {/* Order Info */}
                                <div className="flex items-start gap-4">
                                    <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center text-2xl">
                                        📦
                                    </div>
                                    <div>
                                        <div className="flex items-center gap-3 mb-1">
                                            <h3 className="text-lg font-bold text-gray-800 font-mono">{order.orderId}</h3>
                                            <span className={`${order.deliveryStatus === 'pending' ? 'badge-pending' :
                                                order.deliveryStatus === 'shipped' ? 'badge-scheduled' :
                                                    order.deliveryStatus === 'delivered' ? 'badge-completed' : 'badge-cancelled'
                                                }`}>
                                                {order.deliveryStatus}
                                            </span>
                                            <span className={`px-3 py-1 text-xs font-semibold rounded-full ${order.paymentStatus === 'completed' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
                                                }`}>
                                                {order.paymentStatus === 'completed' ? '✓ Paid' : 'Payment Pending'}
                                            </span>
                                        </div>
                                        <div className="flex flex-wrap items-center gap-4 mt-2 text-sm text-gray-500">
                                            <span className="flex items-center gap-1.5">👤 {order.shippingAddress?.fullName || "N/A"}</span>
                                            <span className="flex items-center gap-1.5">📍 {order.shippingAddress?.city || "N/A"}</span>
                                            <span className="flex items-center gap-1.5">📦 {order.items?.length || 0} items</span>
                                        </div>
                                        <div className="mt-2 text-xs text-gray-400">
                                            {order.items?.slice(0, 2).map((item, i) => (
                                                <span key={i}>{item.quantity}x {item.name}{i < 1 && order.items.length > 1 ? ", " : ""}</span>
                                            ))}
                                            {(order.items?.length || 0) > 2 && <span> +{order.items.length - 2} more</span>}
                                        </div>
                                    </div>
                                </div>

                                {/* Right: Total & Status */}
                                <div className="flex items-center gap-4 mt-4 lg:mt-0">
                                    <span className="text-2xl font-bold text-blue-600">₹{order.totalAmount?.toLocaleString()}</span>
                                    <select
                                        value={order.deliveryStatus || "pending"}
                                        onChange={(e) => updateStatus(order.id, e.target.value)}
                                        className="modern-select text-sm"
                                    >
                                        {statusOptions.map((s) => (
                                            <option key={s} value={s}>
                                                {s.charAt(0).toUpperCase() + s.slice(1)}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
