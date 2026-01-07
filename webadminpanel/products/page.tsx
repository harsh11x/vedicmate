'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { 
  Plus, 
  Edit, 
  Trash2,
  Search,
  Package
} from 'lucide-react'
import { toast } from 'sonner'
import ProductForm from '@/components/admin/ProductForm'

interface Product {
  id?: string;
  name: string;
  punjabiName: string;
  description: string;
  punjabiDescription: string;
  price: number;
  originalPrice: number;
  category: 'men' | 'women' | 'kids' | 'fulkari';
  productType: 'jutti' | 'fulkari';
  subcategory?: string;
  stock: number;
  stockQuantity?: number;
  isActive: boolean;
  images: string[];
  sizes: string[];
  colors: string[];
  createdAt?: string;
  updatedAt?: string;
}

export default function ProductsManagement() {
  const router = useRouter()
  const [products, setProducts] = useState<Product[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [isLoading, setIsLoading] = useState(true)
  const [showDialog, setShowDialog] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)

  const categories = [
    { value: 'all', label: 'All Categories' },
    { value: 'men', label: 'Men\'s Products' },
    { value: 'women', label: 'Women\'s Products' },
    { value: 'kids', label: 'Kids\' Products' },
    { value: 'fulkari', label: 'Fulkari' }
  ]

  useEffect(() => {
    loadProducts()
  }, [])

  const loadProducts = async () => {
    setIsLoading(true)
    try {
      const response = await fetch('/api/admin/products', { credentials: 'include' })
      if (response.ok) {
        const data = await response.json()
        if (data.success) {
          // Map the API response to include productType field
          const mappedProducts = data.products.map((product: any) => ({
            ...product,
            productType: product.subcategory || 'jutti' // Map subcategory to productType
          }))
          setProducts(mappedProducts)
          
          // No auto-seeding - only show products manually added by admin
          if (mappedProducts.length === 0) {
            console.log('No products found - admin must add products manually')
          }
        } else {
          toast.error('Failed to load products')
        }
      } else {
        toast.error('Failed to load products')
      }
    } catch (error) {
      console.error('Error loading products:', error)
      toast.error('Failed to load products')
    } finally {
      setIsLoading(false)
    }
  }



  const openCreateDialog = () => {
    setEditingProduct(null)
    setShowDialog(true)
  }

  const openEditDialog = (product: Product) => {
    // Map the product data to match what ProductForm expects
    const mappedProduct: Product = {
      ...product,
      productType: (product.subcategory as 'jutti' | 'fulkari') || 'jutti' // Map subcategory to productType
    }
    setEditingProduct(mappedProduct)
    setShowDialog(true)
  }

  const handleDelete = async (productId: string) => {
    if (!confirm('Are you sure you want to delete this product?')) return

    try {
      const response = await fetch(`/api/admin/products?id=${productId}`, {
        method: 'DELETE',
        credentials: 'include'
      })

      if (response.ok) {
        const data = await response.json()
        if (data.success) {
          toast.success('Product deleted successfully')
          loadProducts()
        } else {
          toast.error(data.error || 'Failed to delete product')
        }
      } else {
        toast.error('Failed to delete product')
      }
    } catch (error) {
      console.error('Error deleting product:', error)
      toast.error('Failed to delete product')
    }
  }

  const getCategoryDisplayName = (category: string, productType?: string) => {
    if (category === 'fulkari') return 'Fulkari'
    if (productType === 'jutti') {
      return `${category.charAt(0).toUpperCase() + category.slice(1)}'s Jutti`
    }
    return `${category.charAt(0).toUpperCase() + category.slice(1)}'s Products`
  }

  const getCategoryBadgeColor = (category: string) => {
    switch (category) {
      case 'men': return 'bg-blue-100 text-blue-800'
      case 'women': return 'bg-pink-100 text-pink-800'
      case 'kids': return 'bg-green-100 text-green-800'
      case 'fulkari': return 'bg-purple-100 text-purple-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredProducts = products.filter(product => {
    const matchesSearch = 
      product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      product.punjabiName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      product.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (product.productType && product.productType.toLowerCase().includes(searchTerm.toLowerCase()))
    
    const matchesCategory = selectedCategory === 'all' || product.category === selectedCategory
    
    return matchesSearch && matchesCategory
  })

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-red-600 mb-4"></div>
          <p className="text-red-900 font-semibold">Loading Products...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 space-y-4 sm:space-y-0">
          <div>
            <h1 className="text-3xl font-bold text-red-900 mb-2">Products Management</h1>
            <p className="text-amber-700">Manage your store's product catalog</p>
          </div>
          <div className="flex space-x-2">

            <Button 
              onClick={openCreateDialog}
              className="bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add New Product
            </Button>
          </div>
        </div>

        {/* Filters */}
        <Card className="mb-6 border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
          <CardContent className="p-6">
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="flex-1">
                <div className="relative">
                  <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                  <Input
                    placeholder="Search products..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>
              <div className="sm:w-48">
                <Select value={selectedCategory} onValueChange={setSelectedCategory}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {categories.map((category) => (
                      <SelectItem key={category.value} value={category.value}>
                        {category.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Products List */}
        <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="flex items-center text-red-900">
              <Package className="h-5 w-5 mr-2" />
              Products ({filteredProducts.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {filteredProducts.length > 0 ? (
                filteredProducts.map((product) => (
                  <div key={product.id} className="flex items-center justify-between p-4 bg-white rounded-lg border border-amber-100 hover:shadow-md transition-shadow">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3">
                        <h3 className="font-semibold text-red-900">{product.name}</h3>
                        <Badge variant={product.isActive ? "default" : "secondary"}>
                          {product.isActive ? "Active" : "Inactive"}
                        </Badge>
                        <Badge className={getCategoryBadgeColor(product.category)}>
                          {getCategoryDisplayName(product.category, product.productType)}
                        </Badge>
                      </div>
                      <p className="text-sm text-amber-700 mt-1">{product.punjabiName}</p>
                      <div className="flex items-center space-x-4 mt-2 text-sm text-gray-600">
                        <span>₹{product.price}</span>
                        <span>Stock: {product.stock || product.stockQuantity || 0}</span>
                        <span>Category: {product.category}</span>
                        {product.productType && <span>Type: {product.productType}</span>}
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => openEditDialog(product)}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="text-red-600 hover:text-red-700"
                        onClick={() => handleDelete(product.id!)}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8">
                  <Package className="h-16 w-16 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500">No products found</p>
                  <p className="text-sm text-gray-400 mt-2">Start by adding your first product!</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Product Dialog */}
        <Dialog open={showDialog} onOpenChange={setShowDialog}>
          <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>
                {editingProduct ? 'Edit Product' : 'Add New Product'}
              </DialogTitle>
            </DialogHeader>
            
            <ProductForm
              initialData={editingProduct || undefined}
              isDialog={true}
              onSave={(product) => {
                setShowDialog(false)
                loadProducts() // Reload products
              }}
              onCancel={() => setShowDialog(false)}
            />
          </DialogContent>
        </Dialog>
      </div>
    </div>
  )
}
