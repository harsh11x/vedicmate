"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { setCookie } from "cookies-next";
import Image from "next/image";

export default function LoginPage() {
    const router = useRouter();
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        // Simulate API delay
        await new Promise((resolve) => setTimeout(resolve, 800));

        // Hardcoded credentials
        if (username.trim() === "admin" && password === "admin@123") {
            setCookie("admin_authenticated", "true", { maxAge: 60 * 60 * 24 }); // 1 Day
            router.push("/");
        } else {
            setError("Invalid username or password");
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
            <div className="bg-white p-10 rounded-2xl shadow-xl w-full max-w-sm border border-gray-100">
                <div className="text-center mb-8 flex flex-col items-center">
                    <div className="relative w-24 h-24 mb-4">
                        <Image
                            src="/logo.png"
                            alt="Vedic Mate Logo"
                            fill
                            className="object-contain"
                            priority
                        />
                    </div>
                    <h1 className="text-2xl font-bold text-gray-800">Admin Portal</h1>
                    <p className="text-gray-500 text-sm mt-1">Sign in to manage Vedic Mate</p>
                </div>

                <form onSubmit={handleLogin} className="space-y-5">
                    {error && (
                        <div className="bg-red-50 text-red-600 p-3 rounded-md text-xs text-center border border-red-100">
                            {error}
                        </div>
                    )}

                    <div className="space-y-4">
                        <div>
                            <label className="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5">Username</label>
                            <input
                                type="text"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none transition-all text-gray-800 placeholder-gray-400 bg-gray-50 focus:bg-white"
                                placeholder="Enter your username"
                                required
                            />
                        </div>

                        <div>
                            <label className="block text-xs font-semibold text-gray-600 uppercase tracking-wider mb-1.5">Password</label>
                            <input
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none transition-all text-gray-800 placeholder-gray-400 bg-gray-50 focus:bg-white"
                                placeholder="Enter your password"
                                required
                            />
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className={`w-full py-3 rounded-lg text-white font-semibold text-sm shadow-md transition-all mt-2 ${loading
                            ? "bg-orange-300 cursor-not-allowed"
                            : "bg-orange-600 hover:bg-orange-700 active:scale-[0.98]"
                            }`}
                    >
                        {loading ? "Authenticating..." : "Sign In"}
                    </button>

                    <div className="text-center mt-4">
                        <p className="text-xs text-gray-400">© 2025 Vedic Mate. Secure Access.</p>
                    </div>
                </form>
            </div>
        </div>
    );
}
