"use client";

import { useState, useEffect, useRef } from 'react';
import { io, Socket } from 'socket.io-client';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';

// Connect to socket (AWS IP)
// Connect to socket (AWS IP)
const socket = io('http://15.207.36.26:3001', {
    transports: ['websocket'],
    autoConnect: false
});

export default function LivePoojaPage() {
    const [isConnected, setIsConnected] = useState(false);
    const [isLive, setIsLive] = useState(false);
    const [messages, setMessages] = useState<any[]>([]);
    const [gifts, setGifts] = useState<any[]>([]);
    const [viewerCount, setViewerCount] = useState(0);
    const videoRef = useRef<HTMLVideoElement>(null);
    const [stream, setStream] = useState<MediaStream | null>(null);

    // WebRTC: Keep track of peer connections (userId -> RTCPeerConnection)
    const peersRef = useRef<{ [key: string]: RTCPeerConnection }>({});

    useEffect(() => {
        socket.connect();

        socket.on('connect', () => {
            setIsConnected(true);
            socket.emit('join-pooja', { name: 'Admin' });
        });

        socket.on('disconnect', () => setIsConnected(false));

        socket.on('viewer-update', (data: any) => {
            setViewerCount(data.count);
        });

        socket.on('new-pooja-message', (data: any) => {
            setMessages(prev => [...prev, data]);
        });

        socket.on('gift-received', (data: any) => {
            setGifts(prev => [data, ...prev]);
            setMessages(prev => [...prev, {
                type: 'gift',
                senderName: data.senderName,
                message: `Sent ${data.giftName}`,
                timestamp: Date.now()
            }]);
        });

        // WebRTC Signaling Handlers
        socket.on('user-joined', async ({ userId }: { userId: string }) => {
            console.log("User joined, initiating connection:", userId);
            if (isLive && stream) {
                createPeerConnection(userId, stream);
            }
        });

        socket.on('answer', async ({ sender, sdp }: { sender: string, sdp: any }) => {
            const pc = peersRef.current[sender];
            if (pc) {
                await pc.setRemoteDescription(new RTCSessionDescription(sdp));
            }
        });

        socket.on('ice-candidate', async ({ sender, candidate }: { sender: string, candidate: any }) => {
            const pc = peersRef.current[sender];
            if (pc) {
                await pc.addIceCandidate(new RTCIceCandidate(candidate));
            }
        });

        return () => {
            socket.disconnect();
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
            }
            // Close all peers
            Object.values(peersRef.current).forEach(pc => pc.close());
        };
    }, [isLive, stream]);

    const createPeerConnection = async (targetUserId: string, localStream: MediaStream) => {
        const pc = new RTCPeerConnection({
            iceServers: [
                { urls: 'stun:stun.l.google.com:19302' },
                { urls: 'stun:stun1.l.google.com:19302' }
            ]
        });

        localStream.getTracks().forEach(track => pc.addTrack(track, localStream));

        pc.onicecandidate = (event) => {
            if (event.candidate) {
                socket.emit('ice-candidate', {
                    target: targetUserId,
                    candidate: event.candidate
                });
            }
        };

        const offer = await pc.createOffer();
        await pc.setLocalDescription(offer);

        socket.emit('offer', {
            target: targetUserId,
            sdp: offer
        });

        peersRef.current[targetUserId] = pc;
    };

    // Handle Camera Access
    useEffect(() => {
        const startCamera = async () => {
            // Warn about insecure origin


            try {
                const mediaStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                setStream(mediaStream);
                if (videoRef.current) {
                    videoRef.current.srcObject = mediaStream;
                }
            } catch (err) {
                console.error("Error accessing camera:", err);
                alert("Could not access camera. Ensure you are on localhost/HTTPS and have granted permissions.");
            }
        };

        if (isLive) {
            startCamera();
        } else {
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
                setStream(null);
                // Close peers when stopping
                Object.values(peersRef.current).forEach(pc => pc.close());
                peersRef.current = {};
            }
        }
    }, [isLive]);

    const toggleLive = () => {
        const newState = !isLive;
        setIsLive(newState);

        if (newState) {
            socket.emit('admin-start-session', { title: 'Daily Pooja' });
        } else {
            socket.emit('admin-end-session');
        }
    };

    return (
        <div className="p-8 space-y-8 bg-orange-50/50 min-h-screen">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-800">Live Pooja Control</h1>
                    <p className="text-gray-500">Manage daily live sessions & interaction</p>
                </div>
                <div className="flex gap-4 items-center">
                    <Badge variant={isConnected ? "default" : "destructive"}>
                        {isConnected ? 'Socket Connected' : 'Disconnected'}
                    </Badge>
                    <Button
                        size="lg"
                        className={isLive ? "bg-red-500 hover:bg-red-600 animate-pulse" : "bg-green-600 hover:bg-green-700"}
                        onClick={toggleLive}
                    >
                        {isLive ? 'End Live Session' : 'Start Live Stream'}
                    </Button>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Stream Preview with Aesthetic Frame */}
                <Card className="p-1 bg-gradient-to-br from-orange-400 via-red-500 to-purple-600 col-span-2 overflow-hidden shadow-2xl rounded-xl">
                    <div className="relative bg-black aspect-video rounded-lg overflow-hidden border-4 border-yellow-500/30">
                        {isLive ? (
                            <>
                                <video
                                    ref={videoRef}
                                    autoPlay
                                    muted
                                    playsInline
                                    className="w-full h-full object-cover"
                                />
                                <div className="absolute top-4 left-4 bg-red-600 px-3 py-1 rounded text-white font-bold animate-pulse shadow-lg flex items-center gap-2">
                                    <span className="w-2 h-2 bg-white rounded-full animate-ping"></span>
                                    LIVE
                                </div>
                                <div className="absolute top-4 right-4 bg-black/50 px-3 py-1 rounded text-white font-medium border border-white/20 backdrop-blur-sm">
                                    👁️ {viewerCount} Viewers
                                </div>
                                {/* Decorative Corner Frames */}
                                <div className="absolute top-0 left-0 w-16 h-16 border-t-4 border-l-4 border-yellow-400 rounded-tl-lg pointer-events-none opacity-80"></div>
                                <div className="absolute top-0 right-0 w-16 h-16 border-t-4 border-r-4 border-yellow-400 rounded-tr-lg pointer-events-none opacity-80"></div>
                                <div className="absolute bottom-0 left-0 w-16 h-16 border-b-4 border-l-4 border-yellow-400 rounded-bl-lg pointer-events-none opacity-80"></div>
                                <div className="absolute bottom-0 right-0 w-16 h-16 border-b-4 border-r-4 border-yellow-400 rounded-br-lg pointer-events-none opacity-80"></div>
                            </>
                        ) : (
                            <div className="w-full h-full flex flex-col items-center justify-center bg-gray-900 text-white">
                                <div className="bg-gray-800 w-20 h-20 rounded-full flex items-center justify-center mb-6 border-4 border-gray-700">
                                    <span className="text-4xl">🎥</span>
                                </div>
                                <p className="text-xl font-medium text-gray-300">Stream is Offline</p>
                                <p className="text-sm text-gray-500 mt-2">Click "Start Live Stream" to begin camera preview</p>
                            </div>
                        )}
                    </div>
                </Card>

                {/* Gift Log */}
                <Card className="p-0 h-[500px] flex flex-col bg-white border-2 border-orange-100 shadow-xl overflow-hidden rounded-xl">
                    <div className="bg-gradient-to-r from-orange-100 to-yellow-50 p-4 border-b border-orange-200">
                        <h3 className="font-bold flex items-center gap-2 text-orange-900">
                            <span>🎁</span> Recent Gifts
                        </h3>
                    </div>

                    <div className="flex-1 overflow-y-auto space-y-3 p-4 bg-orange-50/30">
                        {gifts.length === 0 && (
                            <div className="flex flex-col items-center justify-center h-full text-gray-400">
                                <span className="text-4xl mb-2 opacity-50">🤲</span>
                                <p>Waiting for donations...</p>
                            </div>
                        )}
                        {gifts.map((gift, i) => (
                            <div key={i} className="flex items-center gap-3 p-3 bg-white rounded-lg border border-orange-100 shadow-sm animate-in slide-in-from-right">
                                <span className="text-3xl bg-orange-100 p-2 rounded-full">{gift.giftIcon || '🎁'}</span>
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
            <Card className="p-6 bg-white border-2 border-gray-100 shadow-lg rounded-xl">
                <h3 className="font-bold mb-4 text-gray-800">Live Chat</h3>
                <div className="h-64 overflow-y-auto bg-gray-50 rounded-lg p-4 space-y-2 border border-gray-200">
                    {messages.map((msg, i) => (
                        <div key={i} className={`text-sm py-1 border-b border-gray-100 last:border-0 ${msg.type === 'gift' ? 'text-orange-600 bg-orange-50 rounded px-2' : ''}`}>
                            <span className="font-bold text-gray-900">{msg.senderName}:</span>
                            <span className="ml-2 text-gray-600">{msg.message}</span>
                        </div>
                    ))}
                    {messages.length === 0 && <p className="text-gray-400 italic text-center mt-20">Chat is quiet...</p>}
                </div>
                <div className="mt-4 flex gap-2">
                    <Input placeholder="Send admin message..." className="border-gray-300" />
                    <Button className="bg-gray-900 hover:bg-black">Send</Button>
                </div>
            </Card>
        </div>
    );
}
