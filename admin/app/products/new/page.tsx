"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

const API_BASE = "https://15.207.36.26:3001/api";

interface Product {
    name: string;
    description: string;
    price: number;
    originalPrice: number;
    category: string;
    stock: number;
    images: string[];
    isActive: boolean;
}

export default function NewProductPage() {
    const router = useRouter();

    const [product, setProduct] = useState<Product>({
        name: "",
        description: "",
        price: 0,
        originalPrice: 0,
        category: "puja-items",
        stock: 0,
        images: [],
        isActive: true
    });

    const [saving, setSaving] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [successMessage, setSuccessMessage] = useState<string | null>(null);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
        const { name, value, type } = e.target;
        setProduct(prev => ({
            ...prev,
            [name]: type === 'number' ? parseFloat(value) : value
        }));
    };

    const handleToggle = () => {
        setProduct(prev => ({ ...prev, isActive: !prev.isActive }));
    };

    const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (file.size > 5 * 1024 * 1024) {
            setError("Image size should be less than 5MB");
            return;
        }

        const reader = new FileReader();
        reader.onloadend = async () => {
            const base64String = reader.result as string;

            // Upload to server
            try {
                const res = await fetch(`${API_BASE}/admin/upload`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ image: base64String, name: 'product' })
                });

                if (!res.ok) throw new Error('Upload failed');

                const data = await res.json();
                if (data.success) {
                    setProduct(prev => ({
                        ...prev,
                        images: [...prev.images, data.url]
                    }));
                }
            } catch (err) {
                console.error("Upload error:", err);
                setError("Failed to upload image");
            }
        };
        reader.readAsDataURL(file);
    };

    const removeImage = (index: number) => {
        setProduct(prev => ({
            ...prev,
            images: prev.images.filter((_, i) => i !== index)
        }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setSaving(true);
        setError(null);
        setSuccessMessage(null);

        try {
            const res = await fetch(`${API_BASE}/admin/products`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(product),
            });

            if (!res.ok) throw new Error("Failed to create product");

            setSuccessMessage("Product created successfully!");
            setTimeout(() => {
                router.push("/products");
                router.refresh();
            }, 1000);
        } catch (err: any) {
            setError(err.message || "Failed to create product");
            setSaving(false);
        }
    };

    return (
        <div className="max-w-4xl mx-auto pb-10">
            {/* Header */}
            <div className="flex items-center gap-4 mb-8">
                <Link href="/products" className="p-2 hover:bg-gray-100 rounded-lg transition-colors text-gray-600">
                    ← Back
                </Link>
                <h1 className="text-2xl font-bold text-gray-800">Add New Product</h1>
            </div>

            {/* Notifications */}
            {error && (
                <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-red-700 font-medium flex items-center gap-2">
                    ⚠️ {error}
                </div>
            )}
            {successMessage && (
                <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl text-green-700 font-medium flex items-center gap-2">
                    ✅ {successMessage}
                </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
                {/* Main Info Card */}
                <div className="bg-white rounded-2xl p-6 shadow-sm border border-orange-50/50">
                    <h2 className="text-lg font-bold text-gray-800 mb-4 border-b pb-2">Basic Information</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="space-y-2 col-span-2">
                            <label className="text-sm font-semibold text-gray-600">Product Name</label>
                            <input
                                type="text"
                                name="name"
                                value={product.name}
                                onChange={handleChange}
                                required
                                placeholder="e.g. 5 Mukhi Rudraksha"
                                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 outline-none transition-all"
                            />
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm font-semibold text-gray-600">Category</label>
                            <select
                                name="category"
                                value={product.category}
                                onChange={handleChange}
                                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 outline-none transition-all bg-white"
                            >
                                <option value="puja-items">Puja Items</option>
                                <option value="gemstones">Gemstones</option>
                                <option value="yantras">Yantras</option>
                                <option value="rudrakshas">Rudrakshas</option>
                                <option value="idols">Idols</option>
                                <option value="books">Books</option>
                                <option value="mala">Mala</option>
                            </select>
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm font-semibold text-gray-600">Status</label>
                            <div
                                onClick={handleToggle}
                                className={`cursor-pointer px-4 py-3 rounded-xl border flex items-center justify-between transition-all ${product.isActive
                                    ? "bg-green-50 border-green-200 text-green-700"
                                    : "bg-gray-50 border-gray-200 text-gray-500"
                                    }`}
                            >
                                <span className="font-medium">{product.isActive ? "Active (Visible)" : "Inactive (Hidden)"}</span>
                                <div className={`w-10 h-6 rounded-full p-1 transition-colors ${product.isActive ? "bg-green-500" : "bg-gray-300"}`}>
                                    <div className={`bg-white w-4 h-4 rounded-full shadow-sm transition-transform ${product.isActive ? "translate-x-4" : ""}`} />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-2 col-span-2">
                            <label className="text-sm font-semibold text-gray-600">Product Images</label>
                            <div className="flex flex-wrap gap-4">
                                {product.images.map((img, idx) => (
                                    <div key={idx} className="relative w-24 h-24 rounded-lg overflow-hidden border border-gray-200 group">
                                        <img src={`https://15.207.36.26:3001/${img}`} alt="Product" className="w-full h-full object-cover" />
                                        <button
                                            type="button"
                                            onClick={() => removeImage(idx)}
                                            className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                                        >
                                            ✕
                                        </button>
                                    </div>
                                ))}
                                <label className="w-24 h-24 flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:border-orange-500 hover:bg-orange-50 transition-colors">
                                    <span className="text-2xl text-gray-400">+</span>
                                    <span className="text-xs text-gray-500">Upload</span>
                                    <input type="file" className="hidden" accept="image/*" onChange={handleImageUpload} />
                                </label>
                            </div>
                        </div>

                        <div className="space-y-2 col-span-2">
                            <label className="text-sm font-semibold text-gray-600">Description</label>
                            <textarea
                                name="description"
                                value={product.description}
                                onChange={handleChange}
                                rows={4}
                                placeholder="Describe the product features and benefits..."
                                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 outline-none transition-all resize-none"
                            />
                        </div>
                    </div>
                </div>

                {/* Pricing & Inventory */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="bg-white rounded-2xl p-6 shadow-sm border border-orange-50/50">
                        <h2 className="text-lg font-bold text-gray-800 mb-4 border-b pb-2">Pricing</h2>
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-600">Sale Price (₹)</label>
                                <input
                                    type="number"
                                    name="price"
                                    value={product.price}
                                    onChange={handleChange}
                                    min="0"
                                    className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 outline-none transition-all"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-600">Original Price (₹)</label>
                                <input
                                    type="number"
                                    name="originalPrice"
                                    value={product.originalPrice}
                                    onChange={handleChange}
                                    min="0"
                                    className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 outline-none transition-all"
                                />
                                <p className="text-xs text-gray-400">Set higher than sale price to show discount</p>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white rounded-2xl p-6 shadow-sm border border-orange-50/50">
                        <h2 className="text-lg font-bold text-gray-800 mb-4 border-b pb-2">Inventory</h2>
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-semibold text-gray-600">Stock Quantity</label>
                                <input
                                    type="number"
                                    name="stock"
                                    value={product.stock}
                                    onChange={handleChange}
                                    min="0"
                                    className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-orange-500 focus:ring-4 focus:ring-orange-500/10 outline-none transition-all"
                                />
                            </div>
                            <div className="pt-2">
                                <div className={`p-3 rounded-lg text-sm ${product.stock > 10 ? "bg-green-50 text-green-700" : "bg-red-50 text-red-700"
                                    }`}>
                                    Initial Status: <strong>{product.stock > 0 ? "In Stock" : "Out of Stock"}</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-4 pt-4">
                    <button
                        type="submit"
                        disabled={saving}
                        className="flex-1 bg-gradient-to-r from-orange-500 to-red-500 text-white font-bold py-4 rounded-xl shadow-lg shadow-orange-500/20 hover:shadow-orange-500/40 hover:-translate-y-1 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {saving ? "Creating Product..." : "Create Product"}
                    </button>
                    <Link
                        href="/products"
                        className="px-8 py-4 bg-white border border-gray-200 text-gray-700 font-bold rounded-xl hover:bg-gray-50 transition-all"
                    >
                        Cancel
                    </Link>
                </div>
            </form>
        </div>
    );
}
