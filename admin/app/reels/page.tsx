"use client";

import { useState, useEffect } from "react";
import { Trash2, Heart, MessageCircle, Upload, X, Play } from "lucide-react";
import { uploadReelToFirebase, isFirebaseConfigured } from "@/lib/firebase";

interface Reel {
    id: string;
    videoUrl: string;
    thumbnailUrl?: string; // Optional
    description: string;
    hashtags: string[];
    likes: { userId: string; email: string; name: string; timestamp: string }[];
    comments: { id: string; userId: string; email: string; name: string; text: string; timestamp: string }[];
    createdAt: string;
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "/api";

export default function ReelsPage() {
    const [reels, setReels] = useState<Reel[]>([]);
    const [loading, setLoading] = useState(true);
    const [showUpload, setShowUpload] = useState(false);
    const [selectedReel, setSelectedReel] = useState<Reel | null>(null); // For detail view

    // Upload Form State
    const [videoFile, setVideoFile] = useState<File | null>(null);
    const [description, setDescription] = useState("");
    const [hashtags, setHashtags] = useState("");
    const [uploading, setUploading] = useState(false);

    useEffect(() => {
        fetchReels();
    }, []);

    const fetchReels = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const res = await fetch(`${API_BASE}/admin/reels`);
            const data = await res.json();
            if (data.success && Array.isArray(data.data)) {
                setReels(data.data);
            } else {
                setReels([]);
            }
        } catch (error) {
            console.error("Error fetching reels:", error);
            setReels([]);
        } finally {
            setLoading(false);
        }
    };

    const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            setVideoFile(e.target.files[0]);
        }
    };

    const toBase64 = (file: File) => new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = () => resolve(reader.result as string);
        reader.onerror = error => reject(error);
    });

    const handleUpload = async () => {
        if (!videoFile) return alert("Please select a video");

        if (videoFile.size > 50 * 1024 * 1024) {
            return alert("Video is too large. Max 50MB.");
        }

        setUploading(true);
        try {
            let videoUrl: string;
            if (isFirebaseConfigured()) {
                const firebaseUrl = await uploadReelToFirebase(videoFile);
                if (!firebaseUrl) throw new Error("Firebase upload failed");
                videoUrl = firebaseUrl;
            } else {
                const base64Video = await toBase64(videoFile);
                const uploadRes = await fetch(`${API_BASE}/admin/upload-video`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ video: base64Video, name: "reel_upload" }),
                });
                const uploadData = await uploadRes.json();
                if (!uploadData.success) throw new Error(uploadData.error || "Upload failed");
                videoUrl = uploadData.url;
            }

            // Create Reel Entry
            const createRes = await fetch(`${API_BASE}/admin/reels`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    videoUrl,
                    description,
                    hashtags: hashtags.split(",").map(tag => tag.trim()).filter(t => t),
                }),
            });

            const createData = await createRes.json();
            if (createData.success) {
                await fetchReels(false);
                setShowUpload(false);
                resetForm();
            } else {
                alert("Failed to save reel: " + (createData.error || "Unknown error"));
            }
        } catch (error: any) {
            alert("Error uploading: " + (error?.message || "Unknown error"));
        } finally {
            setUploading(false);
        }
    };

    const resetForm = () => {
        setVideoFile(null);
        setDescription("");
        setHashtags("");
    };

    const handleDelete = async (id: string, e: React.MouseEvent) => {
        e.stopPropagation();
        if (!confirm("Are you sure you want to delete this reel?")) return;
        try {
            const res = await fetch(`${API_BASE}/admin/reels/${id}`, { method: "DELETE" });
            const data = await res.json();
            if (data.success) {
                if (selectedReel?.id === id) setSelectedReel(null);
                await fetchReels(false);
            } else {
                alert("Failed to delete: " + (data.error || "Unknown error"));
            }
        } catch (error) {
            console.error("Error deleting:", error);
            alert("Error deleting reel. Please try again.");
        }
    };

    const handleDeleteComment = async (reelId: string, commentId: string, e: React.MouseEvent) => {
        e.stopPropagation();
        if (!confirm("Remove this comment?")) return;
        try {
            const res = await fetch(`${API_BASE}/admin/reels/${reelId}/comments/${commentId}`, { method: "DELETE" });
            const data = await res.json();
            if (data.success) {
                setReels(prev => prev.map(r => 
                    r.id === reelId 
                        ? { ...r, comments: r.comments.filter(c => c.id !== commentId) } 
                        : r
                ));
                if (selectedReel?.id === reelId) {
                    setSelectedReel(prev => prev ? { ...prev, comments: prev.comments.filter(c => c.id !== commentId) } : null);
                }
            }
        } catch (error) {
            console.error("Error deleting comment:", error);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Reels Management</h1>
                    <p className="text-gray-500">Upload and track engagement</p>
                </div>
                <button
                    onClick={() => setShowUpload(true)}
                    className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-2 rounded-xl flex items-center gap-2 transition-colors font-medium shadow-lg shadow-orange-200"
                >
                    <Upload size={18} />
                    Upload Reel
                </button>
            </div>

            {/* Stats Grid could go here */}

            {loading ? (
                <div className="text-center py-20 text-gray-500">Loading reels...</div>
            ) : reels.length === 0 ? (
                <div className="text-center py-20 bg-gray-50 rounded-2xl border border-dashed border-gray-200">
                    <div className="bg-orange-50 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                        <Play size={32} className="text-orange-400 ml-1" />
                    </div>
                    <p className="text-gray-500 font-medium">No reels uploaded yet</p>
                    <p className="text-gray-400 text-sm mt-1">Share your first moment with the community</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    {reels.map(reel => (
                        <div
                            key={reel.id}
                            onClick={() => setSelectedReel(reel)}
                            className="group bg-white rounded-2xl border border-gray-100 overflow-hidden hover:shadow-xl transition-all duration-300 cursor-pointer relative"
                        >
                            {/* Video Thumbnail / Preview */}
                            <div className="aspect-[9/16] bg-black relative">
                                <video
                                    src={`${API_BASE.replace('/api', '')}/${reel.videoUrl}`}
                                    className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity"
                                    muted
                                    loop
                                    onMouseOver={e => e.currentTarget.play()}
                                    onMouseOut={e => {
                                        e.currentTarget.pause();
                                        e.currentTarget.currentTime = 0;
                                    }}
                                />
                                <div className="absolute top-3 right-3">
                                    <button
                                        onClick={(e) => handleDelete(reel.id, e)}
                                        className="bg-black/50 hover:bg-red-500 text-white p-2 rounded-full backdrop-blur-sm transition-colors"
                                    >
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                                <div className="absolute inset-0 flex items-center justify-center pointer-events-none group-hover:opacity-0 transition-opacity">
                                    <Play size={48} className="text-white/80" />
                                </div>
                            </div>

                            {/* Content */}
                            <div className="p-4">
                                <p className="text-sm text-gray-800 line-clamp-2 font-medium mb-2 min-h-[2.5em]">
                                    {reel.description || "No description"}
                                </p>
                                <div className="flex flex-wrap gap-1 mb-3">
                                    {reel.hashtags.slice(0, 3).map(tag => (
                                        <span key={tag} className="text-[10px] bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">#{tag}</span>
                                    ))}
                                </div>

                                {/* Stats */}
                                <div className="flex items-center justify-between pt-3 border-t border-gray-50">
                                    <div className="flex items-center gap-1.5 text-pink-500">
                                        <Heart size={16} fill="currentColor" />
                                        <span className="text-sm font-semibold">{reel.likes.length}</span>
                                    </div>
                                    <div className="flex items-center gap-1.5 text-blue-500">
                                        <MessageCircle size={16} fill="currentColor" />
                                        <span className="text-sm font-semibold">{reel.comments.length}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Upload Modal */}
            {showUpload && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl">
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                            <h3 className="text-xl font-bold text-gray-900">Upload New Reel</h3>
                            <button onClick={() => setShowUpload(false)} className="text-gray-400 hover:text-gray-600">
                                <X size={24} />
                            </button>
                        </div>
                        <div className="p-6 space-y-4">
                            {/* File Input */}
                            <div className="border-2 border-dashed border-gray-200 rounded-xl p-8 text-center hover:border-orange-300 transition-colors bg-gray-50">
                                {!videoFile ? (
                                    <>
                                        <div className="bg-white w-12 h-12 rounded-full shadow-sm flex items-center justify-center mx-auto mb-3">
                                            <Upload className="text-orange-500" size={24} />
                                        </div>
                                        <label className="block text-sm font-medium text-gray-700 cursor-pointer">
                                            <span>Click to upload video</span>
                                            <input type="file" accept="video/mp4,video/*" className="hidden" onChange={handleFileSelect} />
                                        </label>
                                        <p className="text-xs text-gray-400 mt-1">MP4, MOV (Max 50MB)</p>
                                    </>
                                ) : (
                                    <div className="flex items-center gap-3 bg-white p-3 rounded-lg shadow-sm border border-gray-100">
                                        <div className="bg-orange-100 p-2 rounded-lg">
                                            <Play size={20} className="text-orange-600" />
                                        </div>
                                        <div className="flex-1 text-left overflow-hidden">
                                            <p className="text-sm font-medium text-gray-900 truncate">{videoFile.name}</p>
                                            <p className="text-xs text-gray-500">{(videoFile.size / (1024 * 1024)).toFixed(1)} MB</p>
                                        </div>
                                        <button onClick={() => setVideoFile(null)} className="text-red-400 hover:text-red-500">
                                            <X size={18} />
                                        </button>
                                    </div>
                                )}
                            </div>

                            {/* Form Fields */}
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                                <textarea
                                    value={description}
                                    onChange={e => setDescription(e.target.value)}
                                    className="w-full px-4 py-2 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500"
                                    rows={3}
                                    placeholder="What's this reel about?"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Hashtags</label>
                                <input
                                    value={hashtags}
                                    onChange={e => setHashtags(e.target.value)}
                                    className="w-full px-4 py-2 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500"
                                    placeholder="astrology, dailyhoroscope, vedic"
                                />
                                <p className="text-xs text-gray-400 mt-1">Comma separated</p>
                            </div>
                        </div>
                        <div className="p-6 border-t border-gray-100 bg-gray-50 flex justify-end gap-3">
                            <button
                                onClick={() => setShowUpload(false)}
                                className="px-4 py-2 text-gray-600 font-medium hover:bg-gray-100 rounded-lg transition-colors"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleUpload}
                                disabled={uploading || !videoFile}
                                className="px-6 py-2 bg-orange-500 hover:bg-orange-600 text-white font-medium rounded-lg shadow-lg shadow-orange-200 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                            >
                                {uploading ? "Uploading..." : "Publish Reel"}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Detail View Modal */}
            {selectedReel && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-end">
                    <div className="w-full max-w-2xl h-full bg-white shadow-2xl animate-in slide-in-from-right duration-300 flex flex-col">
                        {/* Header */}
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                            <div>
                                <h3 className="text-xl font-bold text-gray-900">Reel Insights</h3>
                                <p className="text-sm text-gray-500">Track engagement details</p>
                            </div>
                            <button onClick={() => setSelectedReel(null)} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
                                <X size={24} className="text-gray-500" />
                            </button>
                        </div>

                        <div className="flex-1 overflow-y-auto p-6 space-y-8">
                            {/* Video Preview Small */}
                            <div className="flex gap-4 items-start bg-gray-50 p-4 rounded-xl">
                                <video
                                    src={`${API_BASE.replace('/api', '')}/${selectedReel.videoUrl}`}
                                    className="w-24 h-40 object-cover rounded-lg bg-black"
                                />
                                <div>
                                    <p className="font-medium text-gray-900">{selectedReel.description}</p>
                                    <div className="flex flex-wrap gap-1 mt-2">
                                        {selectedReel.hashtags.map(t => <span key={t} className="text-xs bg-white border border-gray-200 px-2 py-0.5 rounded-full text-gray-600">#{t}</span>)}
                                    </div>
                                    <p className="text-xs text-gray-400 mt-2">Posted on {new Date(selectedReel.createdAt).toLocaleDateString()}</p>
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-6">
                                {/* Likes Section */}
                                <div>
                                    <div className="flex items-center gap-2 mb-4">
                                        <Heart className="text-pink-500 fill-pink-500" size={20} />
                                        <h4 className="font-bold text-gray-800">Likes ({selectedReel.likes.length})</h4>
                                    </div>
                                    <div className="bg-gray-50 rounded-xl p-1 min-h-[200px] max-h-[400px] overflow-y-auto">
                                        {selectedReel.likes.length === 0 ? (
                                            <p className="text-center text-gray-400 text-sm py-8">No likes yet</p>
                                        ) : (
                                            <div className="space-y-1">
                                                {selectedReel.likes.map((like, i) => (
                                                    <div key={i} className="flex items-center gap-3 p-3 hover:bg-white rounded-lg transition-colors">
                                                        <div className="w-8 h-8 rounded-full bg-pink-100 text-pink-600 flex items-center justify-center font-bold text-xs">
                                                            {like.name?.[0]?.toUpperCase() || "U"}
                                                        </div>
                                                        <div className="flex-1 min-w-0">
                                                            <p className="text-sm font-medium text-gray-900 truncate">{like.name || "User"}</p>
                                                            <p className="text-xs text-gray-500 truncate">{like.email}</p>
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                </div>

                                {/* Comments Section */}
                                <div>
                                    <div className="flex items-center gap-2 mb-4">
                                        <MessageCircle className="text-blue-500 fill-blue-500" size={20} />
                                        <h4 className="font-bold text-gray-800">Comments ({selectedReel.comments.length})</h4>
                                    </div>
                                    <div className="bg-gray-50 rounded-xl p-1 min-h-[200px] max-h-[400px] overflow-y-auto">
                                        {selectedReel.comments.length === 0 ? (
                                            <p className="text-center text-gray-400 text-sm py-8">No comments yet</p>
                                        ) : (
                                            <div className="space-y-1">
                                                {selectedReel.comments.map((comment, i) => (
                                                    <div key={comment.id || i} className="p-3 hover:bg-white rounded-lg transition-colors flex justify-between items-start gap-2">
                                                        <div className="flex-1 min-w-0">
                                                            <div className="flex items-center gap-2 mb-1">
                                                                <span className="font-semibold text-xs text-gray-900">{comment.name || "User"}</span>
                                                                <span className="text-[10px] text-gray-400">{new Date(comment.timestamp).toLocaleDateString()}</span>
                                                            </div>
                                                            <p className="text-sm text-gray-600 leading-snug">{comment.text}</p>
                                                            <p className="text-[10px] text-gray-400 mt-1 truncate">{comment.email}</p>
                                                        </div>
                                                        <button
                                                            onClick={(e) => handleDeleteComment(selectedReel.id, comment.id, e)}
                                                            className="flex-shrink-0 p-2 text-red-400 hover:bg-red-50 hover:text-red-600 rounded-lg transition-colors"
                                                            title="Remove comment"
                                                        >
                                                            <Trash2 size={16} />
                                                        </button>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
