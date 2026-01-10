"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

const API_BASE = "https://15.207.36.26:3001/api";

interface Product {
    id: string;
    name: string;
    description: string;
    price: number;
    originalPrice: number;
    category: string;
    stock: number;
    images: string[];
    isActive: boolean;
}

export default function ProductsPage() {
    const router = useRouter();
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedCategory, setSelectedCategory] = useState("all");
    const [error, setError] = useState<string | null>(null);

    const fetchProducts = async () => {
        try {
            setError(null);
            const res = await fetch(`${API_BASE}/admin/products`);
            if (!res.ok) throw new Error("Failed to fetch");
            const data = await res.json();
            setProducts(data.data || []);
        } catch (err) {
            setError("Unable to connect to server");
            console.error("Error:", err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchProducts();
    }, []);

    const categories = ["all", ...new Set(products.map(p => p.category).filter(Boolean))];
    const filteredProducts = selectedCategory === "all"
        ? products
        : products.filter(p => p.category === selectedCategory);

    const getCategoryIcon = (category: string) => {
        const icons: Record<string, string> = {
            'puja-items': '🪔',
            'gemstones': '💎',
            'yantras': '🕉️',
            'rudrakshas': '📿',
            'books': '📚',
            'idols': '🗿',
        };
        return icons[category] || '📦';
    };

    if (loading) {
        return (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {[1, 2, 3, 4, 5, 6].map((i) => (
                    <div key={i} className="h-64 shimmer rounded-2xl" />
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

            {/* Header with Categories */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="flex items-center gap-2 overflow-x-auto pb-2 md:pb-0">
                    {categories.map((cat) => (
                        <button
                            key={cat}
                            onClick={() => setSelectedCategory(cat)}
                            className={`px-5 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all capitalize ${selectedCategory === cat
                                ? "bg-gradient-to-r from-green-500 to-green-600 text-white shadow-lg shadow-green-200"
                                : "bg-white text-gray-600 hover:text-gray-900 hover:bg-gray-50 border border-gray-200"
                                }`}
                        >
                            {cat === "all" ? "All Products" : cat.replace('-', ' ')}
                        </button>
                    ))}
                </div>
                <div className="flex items-center gap-4">
                    <span className="text-sm font-semibold text-gray-500">
                        {filteredProducts.length} product{filteredProducts.length !== 1 ? "s" : ""}
                    </span>
                    <button onClick={fetchProducts} className="btn-secondary flex items-center gap-2">
                        <span>↻</span> Refresh
                    </button>
                    <Link href="/products/new" className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-xl font-semibold transition-colors flex items-center gap-2 shadow-lg shadow-orange-200">
                        <span>+</span> Add Product
                    </Link>
                </div>
            </div>

            {/* Products Grid */}
            {filteredProducts.length === 0 ? (
                <div className="bg-white rounded-2xl p-16 text-center shadow-sm">
                    <div className="text-6xl mb-4">📦</div>
                    <h3 className="text-xl font-bold text-gray-800 mb-2">No Products Found</h3>
                    <p className="text-gray-500">Products will appear here</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    {filteredProducts.map((product, index) => (
                        <div
                            key={product.id}
                            onClick={() => router.push(`/products/${product.id}`)}
                            className="bg-white rounded-2xl overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 hover:-translate-y-1 fade-in group cursor-pointer"
                            style={{ animationDelay: `${index * 0.03}s`, opacity: 0 }}
                        >
                            {/* Product Image */}
                            <div className="h-44 bg-gradient-to-br from-orange-50 to-orange-100 flex items-center justify-center text-6xl relative overflow-hidden">
                                <span className="group-hover:scale-125 transition-transform duration-500">
                                    {getCategoryIcon(product.category)}
                                </span>
                                {/* Stock badge */}
                                <div className={`absolute top-3 right-3 px-3 py-1.5 rounded-xl text-xs font-bold ${product.stock < 10
                                    ? 'bg-red-500 text-white'
                                    : 'bg-green-500 text-white'
                                    }`}>
                                    {product.stock < 10 ? `Only ${product.stock} left` : `${product.stock} in stock`}
                                </div>
                                {!product.isActive && (
                                    <div className="absolute top-3 left-3 px-3 py-1.5 rounded-xl text-xs font-bold bg-gray-500 text-white">
                                        Inactive
                                    </div>
                                )}
                                {product.originalPrice > product.price && (
                                    <div className="absolute bottom-3 left-3 px-3 py-1.5 rounded-xl text-xs font-bold bg-gradient-to-r from-red-500 to-pink-500 text-white">
                                        {Math.round((1 - product.price / product.originalPrice) * 100)}% OFF
                                    </div>
                                )}
                            </div>

                            {/* Product Info */}
                            <div className="p-5">
                                <div className="flex items-start justify-between gap-2 mb-2">
                                    <h3 className="font-bold text-gray-800 group-hover:text-orange-600 transition-colors line-clamp-1">
                                        {product.name}
                                    </h3>
                                </div>
                                <span className="inline-block px-2 py-0.5 bg-orange-100 text-orange-600 rounded text-xs font-semibold capitalize mb-2">
                                    {product.category?.replace('-', ' ')}
                                </span>
                                <p className="text-sm text-gray-400 line-clamp-2 mb-4 h-10">{product.description}</p>
                                <div className="flex items-center justify-between">
                                    <div className="flex items-baseline gap-2">
                                        <span className="text-2xl font-bold text-green-600">₹{product.price}</span>
                                        {product.originalPrice > product.price && (
                                            <span className="text-sm text-gray-400 line-through">₹{product.originalPrice}</span>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Stats Footer */}
            <div className="bg-white rounded-2xl p-6 shadow-sm">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
                    <div className="p-4 rounded-xl bg-gradient-to-br from-gray-50 to-gray-100">
                        <p className="text-3xl font-bold text-gray-800">{products.length}</p>
                        <p className="text-sm text-gray-500 font-medium">Total Products</p>
                    </div>
                    <div className="p-4 rounded-xl bg-gradient-to-br from-green-50 to-green-100">
                        <p className="text-3xl font-bold text-green-600">{products.filter(p => p.isActive).length}</p>
                        <p className="text-sm text-gray-500 font-medium">Active</p>
                    </div>
                    <div className="p-4 rounded-xl bg-gradient-to-br from-red-50 to-red-100">
                        <p className="text-3xl font-bold text-red-600">{products.filter(p => p.stock < 10).length}</p>
                        <p className="text-sm text-gray-500 font-medium">Low Stock</p>
                    </div>
                    <div className="p-4 rounded-xl bg-gradient-to-br from-orange-50 to-orange-100">
                        <p className="text-3xl font-bold text-orange-600">{categories.length - 1}</p>
                        <p className="text-sm text-gray-500 font-medium">Categories</p>
                    </div>
                </div>
            </div>
        </div>
    );
}
