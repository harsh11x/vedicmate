"use client";

import { Inter } from "next/font/google";
import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import "./globals.css";
import { getCookie } from "cookies-next";
import AutoLogout from "@/components/AutoLogout";

const inter = Inter({ subsets: ["latin"] });

const navItems = [
  { href: "/", label: "Dashboard", icon: "📊", description: "Overview & Stats" },
  { href: "/custom-requests", label: "Custom Requests", icon: "🙏", description: "Puja & Havan" },
  { href: "/live-sessions", label: "Live Sessions", icon: "📹", description: "Video Calls" },
  { href: "/orders", label: "Orders", icon: "🛒", description: "Product Orders" },
  { href: "/products", label: "Products", icon: "📦", description: "Inventory" },
];

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const [mounted, setMounted] = useState(false);
  const [currentTime, setCurrentTime] = useState("");
  const [serverStatus, setServerStatus] = useState<"connected" | "disconnected" | "checking">("checking");

  const isLoginPage = pathname === "/login";

  // Handle hydration - only render time-based content after mount
  useEffect(() => {
    setMounted(true);

    // Auth Check
    const checkAuth = () => {
      const isAuthenticated = getCookie("admin_authenticated");
      if (!isAuthenticated && !isLoginPage) {
        router.push("/login");
      }
    };
    checkAuth();

    // Update time
    const updateTime = () => {
      setCurrentTime(
        new Date().toLocaleTimeString("en-IN", {
          hour: "2-digit",
          minute: "2-digit",
        })
      );
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);

    // Check server status (Only if authenticated or on dashboard)
    const checkServer = async () => {
      try {
        const res = await fetch("http://15.207.36.26:3001/api/health", {
          signal: AbortSignal.timeout(3000)
        });
        setServerStatus(res.ok ? "connected" : "disconnected");
      } catch {
        setServerStatus("disconnected");
      }
    };

    if (!isLoginPage) {
      checkServer();
      const serverInterval = setInterval(checkServer, 30000);
      return () => {
        clearInterval(interval);
        clearInterval(serverInterval);
      };
    }

    return () => clearInterval(interval);
  }, [pathname, isLoginPage, router]);

  // If on login page, render simpler layout
  if (isLoginPage) {
    return (
      <html lang="en">
        <body className={inter.className}>{children}</body>
      </html>
    );
  }

  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.className} antialiased`} suppressHydrationWarning>
        <AutoLogout />
        <div className="flex min-h-screen">
          {/* Sidebar */}
          <aside className="fixed left-0 top-0 z-40 h-screen w-72 bg-white border-r border-gray-200 shadow-sm">
            {/* Logo */}
            <div className="flex items-center gap-4 p-6 border-b border-gray-100">
              <div className="relative w-10 h-10">
                <Image
                  src="/logo.png"
                  alt="Logo"
                  fill
                  className="object-contain"
                />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900 tracking-tight">Vedic Mate</h1>
                <p className="text-[10px] text-gray-400 font-medium uppercase tracking-widest">Administration</p>
              </div>
            </div>

            {/* Navigation */}
            <nav className="p-4 space-y-1">
              {navItems.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`flex items-center gap-4 px-4 py-3.5 rounded-xl transition-all duration-200 group ${isActive
                      ? "bg-gradient-to-r from-orange-50 to-orange-100 border-l-4 border-orange-500 text-orange-700"
                      : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
                      }`}
                  >
                    <span className={`text-xl transition-transform duration-200 ${isActive ? "scale-110" : "group-hover:scale-110"}`}>
                      {item.icon}
                    </span>
                    <div className="flex-1">
                      <p className={`font-semibold ${isActive ? "text-orange-700" : ""}`}>{item.label}</p>
                      <p className="text-xs text-gray-400">{item.description}</p>
                    </div>
                    {isActive && (
                      <div className="w-2 h-2 bg-orange-500 rounded-full" />
                    )}
                  </Link>
                );
              })}
            </nav>

            {/* Server Status - Bottom */}
            <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-100 bg-gray-50">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Server Status</p>
                  <p className="text-sm text-gray-500 mt-0.5">15.207.36.26:3001</p>
                </div>
                <div className="flex items-center gap-2">
                  <span className={`w-3 h-3 rounded-full ${serverStatus === "connected" ? "bg-green-500 animate-pulse" :
                    serverStatus === "disconnected" ? "bg-red-500" : "bg-yellow-500"
                    }`} />
                  <span className={`text-sm font-semibold ${serverStatus === "connected" ? "text-green-600" :
                    serverStatus === "disconnected" ? "text-red-600" : "text-yellow-600"
                    }`}>
                    {mounted ? (serverStatus === "connected" ? "Online" : serverStatus === "disconnected" ? "Offline" : "...") : "..."}
                  </span>
                </div>
              </div>
            </div>
          </aside>

          {/* Main Content */}
          <main className="flex-1 ml-72">
            {/* Header */}
            <header className="sticky top-0 z-30 bg-white/80 backdrop-blur-xl border-b border-gray-100 px-8 py-5">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-2xl font-bold text-gray-900">
                    {navItems.find((item) => item.href === pathname)?.label || "Dashboard"}
                  </h2>
                  <p className="text-sm text-gray-500 mt-0.5">
                    {navItems.find((item) => item.href === pathname)?.description || "Overview & Analytics"}
                  </p>
                </div>
                <div className="flex items-center gap-6">
                  {/* Time */}
                  <div className="text-right" suppressHydrationWarning>
                    <p className="text-lg font-bold text-gray-900 font-mono">{mounted ? currentTime : "--:--"}</p>
                    <p className="text-xs text-gray-400">
                      {mounted ? new Date().toLocaleDateString("en-IN", {
                        weekday: "short",
                        month: "short",
                        day: "numeric",
                      }) : "Loading..."}
                    </p>
                  </div>

                  {/* Profile */}
                  <div className="flex items-center gap-3 pl-6 border-l border-gray-200">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-orange-400 to-pink-500 flex items-center justify-center text-white font-bold text-sm shadow-lg shadow-orange-200">
                      A
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-gray-900">Admin</p>
                      <p className="text-xs text-gray-400">Super Admin</p>
                    </div>
                  </div>
                </div>
              </div>
            </header>

            {/* Page Content */}
            <div className="p-8">
              {children}
            </div>
          </main>
        </div>
      </body>
    </html>
  );
}
