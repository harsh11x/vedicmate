"use client";

import { useState, useEffect } from 'react';
import { io, Socket } from 'socket.io-client';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';

// Connect to socket
const socket = io('http://15.207.36.26:4000', {
    transports: ['websocket'],
    autoConnect: false
});

export default function LivePoojaPage() {
    const [isConnected, setIsConnected] = useState(false);
    const [isLive, setIsLive] = useState(false);
    const [messages, setMessages] = useState<any[]>([]);
    const [gifts, setGifts] = useState<any[]>([]);
    const [viewerCount, setViewerCount] = useState(0);

    useEffect(() => {
        socket.connect();

        socket.on('connect', () => {
            setIsConnected(true);
            socket.emit('join-pooja', { name: 'Admin' });
        });

        socket.on('disconnect', () => setIsConnected(false));

        socket.on('new-pooja-message', (data: any) => {
            setMessages(prev => [...prev, data]);
        });

        socket.on('gift-received', (data: any) => {
            setGifts(prev => [data, ...prev]);
            // Also add to chat log
            setMessages(prev => [...prev, {
                type: 'gift',
                senderName: data.senderName,
                message: `Sent ${data.giftName}`,
                timestamp: Date.now()
            }]);
        });

        return () => {
            socket.off('connect');
            socket.off('disconnect');
            socket.off('new-pooja-message');
            socket.off('gift-received');
            socket.disconnect();
        };
    }, []);

    const toggleLive = () => {
        setIsLive(!isLive);
        // Emit event to server if needed to persist status
        // socket.emit('admin-toggle-pooja', !isLive);
    };

    return (
        <div className="p-8 space-y-8 bg-orange-50/50 min-h-screen">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-800">Live Pooja Control</h1>
                    <p className="text-gray-500">Manage daily live sessions</p>
                </div>
                <div className="flex gap-4 items-center">
                    <Badge variant={isConnected ? "default" : "destructive"}>
                        {isConnected ? 'Socket Connected' : 'Disconnected'}
                    </Badge>
                    <Button
                        size="lg"
                        className={isLive ? "bg-red-500 hover:bg-red-600" : "bg-green-600 hover:bg-green-700"}
                        onClick={toggleLive}
                    >
                        {isLive ? 'End Live Session' : 'Start Live Session'}
                    </Button>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Stream Preview */}
                <Card className="p-0 overflow-hidden bg-black aspect-video flex items-center justify-center relative col-span-2">
                    {isLive ? (
                        <>
                            <img
                                src="https://img.freepik.com/free-photo/holy-ritual-fire_1157-36067.jpg"
                                alt="Stream"
                                className="w-full h-full object-cover opacity-80"
                            />
                            <div className="absolute top-4 left-4 bg-red-600 px-3 py-1 rounded text-white font-bold animate-pulse">
                                LIVE
                            </div>
                            <div className="absolute top-4 right-4 bg-black/50 px-3 py-1 rounded text-white font-medium">
                                👁️ 124 Viewers (Mock)
                            </div>
                        </>
                    ) : (
                        <div className="text-center">
                            <div className="bg-gray-800 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                                <span className="text-3xl">🎥</span>
                            </div>
                            <p className="text-gray-400">Stream is Offline</p>
                        </div>
                    )}
                </Card>

                {/* Gift Log */}
                <Card className="p-6 h-[400px] flex flex-col bg-white">
                    <h3 className="font-bold mb-4 flex items-center gap-2">
                        <span>🎁</span> Gift Activity
                    </h3>
                    <div className="flex-1 overflow-y-auto space-y-3">
                        {gifts.length === 0 && (
                            <p className="text-center text-gray-400 mt-20">No gifts yet</p>
                        )}
                        {gifts.map((gift, i) => (
                            <div key={i} className="flex items-center gap-3 p-3 bg-yellow-50 rounded-lg border border-yellow-100">
                                <span className="text-2xl">{gift.giftIcon || '🎁'}</span>
                                <div>
                                    <p className="font-bold text-sm text-gray-800">{gift.senderName}</p>
                                    <p className="text-xs text-orange-600 font-medium">Sent {gift.giftName} (₹{gift.amount})</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </Card>
            </div>

            {/* Chat Log */}
            <Card className="p-6 bg-white">
                <h3 className="font-bold mb-4">Live Chat</h3>
                <div className="h-64 overflow-y-auto bg-gray-50 rounded-lg p-4 space-y-2 border">
                    {messages.map((msg, i) => (
                        <div key={i} className="text-sm">
                            <span className="font-bold text-gray-700">{msg.senderName}:</span>
                            <span className="ml-2 text-gray-600">{msg.message}</span>
                        </div>
                    ))}
                    {messages.length === 0 && <p className="text-gray-400 italic">Chat is quiet...</p>}
                </div>
                <div className="mt-4 flex gap-2">
                    <Input placeholder="Send admin message..." />
                    <Button>Send</Button>
                </div>
            </Card>
        </div>
    );
}
