"use client";

import { useEffect, useRef } from "react";
import { useRouter, usePathname } from "next/navigation";
import { deleteCookie } from "cookies-next";

const INACTIVITY_LIMIT_MS = 10 * 60 * 1000; // 10 Minutes

export default function AutoLogout() {
    const router = useRouter();
    const pathname = usePathname();
    const timerRef = useRef<NodeJS.Timeout | null>(null);

    const logout = async () => {
        if (pathname === "/login") return; // Don't logout if already on login page

        // Check if Live Pooja is active before logging out
        try {
            const response = await fetch('https://15.207.36.26:3001/api/admin/live-sessions/session_1768376801443');
            if (response.ok) {
                const data = await response.json();
                if (data.success && data.data.isLive) {
                    console.log('⏸️ Auto-logout prevented: Live Pooja is active');
                    resetTimer(); // Reset timer instead of logging out
                    return;
                }
            }
        } catch (error) {
            console.error('Error checking live session status:', error);
        }

        // Proceed with logout if no live session
        console.log("Auto-logging out due to inactivity...");
        deleteCookie("admin_authenticated");
        window.location.href = "/login";
    };

    const resetTimer = () => {
        if (timerRef.current) clearTimeout(timerRef.current);
        timerRef.current = setTimeout(logout, INACTIVITY_LIMIT_MS);
    };

    useEffect(() => {
        // Events to track activity
        const events = ["mousemove", "keydown", "click", "scroll", "touchstart"];

        // Add listeners
        events.forEach((event) => window.addEventListener(event, resetTimer));

        // Initial timer start
        resetTimer();

        // Cleanup
        return () => {
            events.forEach((event) => window.removeEventListener(event, resetTimer));
            if (timerRef.current) clearTimeout(timerRef.current);
        };
    }, [pathname]); // Reset listeners if path changes (optional but safe)

    return null; // This component renders nothing
}
