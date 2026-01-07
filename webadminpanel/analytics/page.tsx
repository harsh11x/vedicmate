'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { 
  BarChart3,
  TrendingUp,
  DollarSign,
  Package,
  ShoppingCart,
  Users,
  Star,
  Eye,
  Calendar,
  ArrowUp,
  ArrowDown,
  Minus,
  PieChart,
  Activity,
  Target
} from 'lucide-react'
import { toast } from 'sonner'

interface AnalyticsData {
  totalRevenue: number
  totalOrders: number
  totalProducts: number
  averageOrderValue: number
  conversionRate: number
  topProducts: Array<{
    id: string
    name: string
    sales: number
    revenue: number
    rating: number
  }>
  categoryBreakdown: Array<{
    category: string
    count: number
    revenue: number
    percentage: number
  }>
  revenueGrowth: number
  orderGrowth: number
  customerGrowth: number
  monthlySales: Array<{
    month: string
    revenue: number
    orders: number
  }>
  recentActivity: Array<{
    type: string
    message: string
    time: string
    amount?: number
  }>
}

export default function AnalyticsPage() {
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [timeRange, setTimeRange] = useState('30d')

  useEffect(() => {
    loadAnalytics()
  }, [timeRange])

  const loadAnalytics = async () => {
    setIsLoading(true)
    try {
      // Load real data from products and orders
      const [productsRes, ordersRes] = await Promise.all([
        fetch('/api/admin/products', { credentials: 'include' }),
        fetch('/api/admin/orders', { credentials: 'include' })
      ])

      if (productsRes.ok && ordersRes.ok) {
        const productsData = await productsRes.json()
        const ordersData = await ordersRes.json()

        if (productsData.success && ordersData.success) {
          const calculatedAnalytics = calculateAnalytics(productsData.products, ordersData.orders)
          setAnalytics(calculatedAnalytics)
        }
      }
    } catch (error) {
      console.error('Error loading analytics:', error)
      toast.error('Failed to load analytics data')
    } finally {
      setIsLoading(false)
    }
  }

  const calculateAnalytics = (products: any[], orders: any[]): AnalyticsData => {
    // Default values for when there are no orders yet
    const totalRevenue = orders.length > 0 ? orders.reduce((sum, order) => sum + order.total, 0) : 0
    const totalOrders = orders.length
    const totalProducts = products.length
    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0

    // Calculate category breakdown
    const categoryMap = new Map()
    products.forEach(product => {
      const category = product.category
      if (!categoryMap.has(category)) {
        categoryMap.set(category, { count: 0, revenue: 0 })
      }
      const data = categoryMap.get(category)
      data.count++
      
      // Calculate revenue from orders for this product
      const productRevenue = orders
        .filter(order => order.items.some((item: any) => item.productId === product.id))
        .reduce((sum, order) => sum + order.total, 0)
      data.revenue += productRevenue
    })

    const categoryBreakdown = Array.from(categoryMap.entries()).map(([category, data]) => ({
      category: category.charAt(0).toUpperCase() + category.slice(1),
      count: data.count,
      revenue: data.revenue,
      percentage: totalProducts > 0 ? (data.count / totalProducts) * 100 : 0
    }))

    // Calculate top products
    const topProducts = products
      .map(product => {
        const productOrders = orders.filter(order => 
          order.items.some((item: any) => item.productId === product.id)
        )
        const sales = productOrders.reduce((sum, order) => 
          sum + order.items.filter((item: any) => item.productId === product.id)[0]?.quantity || 0, 0
        )
        const revenue = productOrders.reduce((sum, order) => sum + order.total, 0)
        
        return {
          id: product.id,
          name: product.name,
          sales,
          revenue,
          rating: product.rating || 0
        }
      })
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, 5)

    // Mock growth data (in real app, compare with previous period)
    const revenueGrowth = 12.5
    const orderGrowth = 8.3
    const customerGrowth = 15.2

    // Mock monthly sales (last 6 months)
    const monthlySales = [
      { month: 'Aug', revenue: totalRevenue * 0.2, orders: Math.floor(totalOrders * 0.2) },
      { month: 'Jul', revenue: totalRevenue * 0.18, orders: Math.floor(totalOrders * 0.18) },
      { month: 'Jun', revenue: totalRevenue * 0.15, orders: Math.floor(totalOrders * 0.15) },
      { month: 'May', revenue: totalRevenue * 0.17, orders: Math.floor(totalOrders * 0.17) },
      { month: 'Apr', revenue: totalRevenue * 0.16, orders: Math.floor(totalOrders * 0.16) },
      { month: 'Mar', revenue: totalRevenue * 0.14, orders: Math.floor(totalOrders * 0.14) }
    ].reverse()

    // Recent activity
    const recentActivity = orders.length > 0 
      ? orders
        .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        .slice(0, 5)
        .map(order => ({
          type: 'order',
          message: `New order from ${order.customerInfo.name}`,
          time: new Date(order.createdAt).toLocaleDateString(),
          amount: order.total
        }))
      : [
        // Default message for when there are no orders yet
        {
          type: 'info',
          message: 'No orders yet. Your order history will appear here.',
          time: new Date().toLocaleDateString(),
          amount: 0
        }
      ]

    return {
      totalRevenue,
      totalOrders,
      totalProducts,
      averageOrderValue,
      conversionRate: 3.2, // Mock conversion rate
      topProducts,
      categoryBreakdown,
      revenueGrowth,
      orderGrowth,
      customerGrowth,
      monthlySales,
      recentActivity
    }
  }

  const getGrowthIcon = (growth: number) => {
    if (growth > 0) return <ArrowUp className="h-4 w-4 text-green-600" />
    if (growth < 0) return <ArrowDown className="h-4 w-4 text-red-600" />
    return <Minus className="h-4 w-4 text-gray-500" />
  }

  const getGrowthColor = (growth: number) => {
    if (growth > 0) return 'text-green-600'
    if (growth < 0) return 'text-red-600'
    return 'text-gray-500'
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-red-600 mb-4"></div>
          <p className="text-red-900 font-semibold">Loading Analytics...</p>
        </div>
      </div>
    )
  }

  if (!analytics) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 flex items-center justify-center">
        <p className="text-red-900">Failed to load analytics data</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 space-y-4 sm:space-y-0">
          <div>
            <h1 className="text-3xl font-bold text-red-900 mb-2">Analytics Dashboard</h1>
            <p className="text-amber-700">Comprehensive business insights and performance metrics</p>
          </div>
          <div className="flex items-center space-x-4">
            <Select value={timeRange} onValueChange={setTimeRange}>
              <SelectTrigger className="w-32">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="7d">Last 7 days</SelectItem>
                <SelectItem value="30d">Last 30 days</SelectItem>
                <SelectItem value="90d">Last 3 months</SelectItem>
                <SelectItem value="365d">Last year</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Key Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Total Revenue</p>
                  <p className="text-2xl font-bold text-red-900">₹{analytics.totalRevenue.toLocaleString()}</p>
                  <div className="flex items-center mt-1">
                    {getGrowthIcon(analytics.revenueGrowth)}
                    <span className={`text-sm ml-1 ${getGrowthColor(analytics.revenueGrowth)}`}>
                      {analytics.revenueGrowth > 0 ? '+' : ''}{analytics.revenueGrowth}%
                    </span>
                  </div>
                </div>
                <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-green-600 rounded-full flex items-center justify-center">
                  <DollarSign className="h-6 w-6 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Total Orders</p>
                  <p className="text-2xl font-bold text-red-900">{analytics.totalOrders}</p>
                  <div className="flex items-center mt-1">
                    {getGrowthIcon(analytics.orderGrowth)}
                    <span className={`text-sm ml-1 ${getGrowthColor(analytics.orderGrowth)}`}>
                      {analytics.orderGrowth > 0 ? '+' : ''}{analytics.orderGrowth}%
                    </span>
                  </div>
                </div>
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center">
                  <ShoppingCart className="h-6 w-6 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Avg. Order Value</p>
                  <p className="text-2xl font-bold text-red-900">₹{Math.round(analytics.averageOrderValue).toLocaleString()}</p>
                  <div className="flex items-center mt-1">
                    {getGrowthIcon(5.2)}
                    <span className="text-sm ml-1 text-green-600">+5.2%</span>
                  </div>
                </div>
                <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-purple-600 rounded-full flex items-center justify-center">
                  <TrendingUp className="h-6 w-6 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">Conversion Rate</p>
                  <p className="text-2xl font-bold text-red-900">{analytics.conversionRate}%</p>
                  <div className="flex items-center mt-1">
                    {getGrowthIcon(2.1)}
                    <span className="text-sm ml-1 text-green-600">+2.1%</span>
                  </div>
                </div>
                <div className="w-12 h-12 bg-gradient-to-br from-orange-500 to-orange-600 rounded-full flex items-center justify-center">
                  <Target className="h-6 w-6 text-white" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Top Products */}
          <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center text-red-900">
                <Package className="h-5 w-5 mr-2" />
                Top Performing Products
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {analytics.topProducts.map((product, index) => (
                  <div key={product.id} className="flex items-center justify-between p-3 bg-white rounded-lg border border-amber-100">
                    <div className="flex items-center space-x-3">
                      <div className="w-8 h-8 bg-gradient-to-br from-amber-400 to-red-500 rounded-full flex items-center justify-center text-white font-bold">
                        {index + 1}
                      </div>
                      <div>
                        <p className="font-semibold text-red-900">{product.name}</p>
                        <div className="flex items-center space-x-2 text-sm text-gray-600">
                          <span>{product.sales} sold</span>
                          <span>•</span>
                          <div className="flex items-center">
                            <Star className="h-3 w-3 text-yellow-500 mr-1" />
                            {product.rating}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-bold text-red-900">₹{product.revenue.toLocaleString()}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Category Breakdown */}
          <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center text-red-900">
                <PieChart className="h-5 w-5 mr-2" />
                Category Performance
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {analytics.categoryBreakdown.map((category) => (
                  <div key={category.category} className="p-3 bg-white rounded-lg border border-amber-100">
                    <div className="flex items-center justify-between mb-2">
                      <span className="font-semibold text-red-900">{category.category}</span>
                      <span className="text-sm text-gray-600">{category.percentage.toFixed(1)}%</span>
                    </div>
                    <div className="flex items-center justify-between text-sm text-gray-600 mb-2">
                      <span>{category.count} products</span>
                      <span>₹{category.revenue.toLocaleString()}</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div 
                        className="bg-gradient-to-r from-amber-500 to-red-600 h-2 rounded-full" 
                        style={{ width: `${category.percentage}%` }}
                      ></div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Revenue Trend */}
        <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm mb-8">
          <CardHeader>
            <CardTitle className="flex items-center text-red-900">
              <BarChart3 className="h-5 w-5 mr-2" />
              Revenue Trends (Last 6 Months)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-end justify-between h-64 p-4">
              {analytics.monthlySales.map((month) => (
                <div key={month.month} className="flex flex-col items-center">
                  <div className="text-xs text-gray-600 mb-2">₹{(month.revenue / 1000).toFixed(0)}k</div>
                  <div 
                    className="w-12 bg-gradient-to-t from-red-600 to-amber-500 rounded-t-md"
                    style={{ height: `${(month.revenue / Math.max(...analytics.monthlySales.map(m => m.revenue))) * 200}px` }}
                  ></div>
                  <div className="text-sm font-semibold text-red-900 mt-2">{month.month}</div>
                  <div className="text-xs text-gray-600">{month.orders} orders</div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Recent Activity */}
        <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
          <CardHeader>
            <CardTitle className="flex items-center text-red-900">
              <Activity className="h-5 w-5 mr-2" />
              Recent Activity
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {analytics.recentActivity.map((activity, index) => (
                <div key={index} className="flex items-center justify-between p-3 bg-white rounded-lg border border-amber-100">
                  <div className="flex items-center space-x-3">
                    <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center">
                      <ShoppingCart className="h-4 w-4 text-white" />
                    </div>
                    <div>
                      <p className="font-semibold text-red-900">{activity.message}</p>
                      <p className="text-sm text-gray-600">{activity.time}</p>
                    </div>
                  </div>
                  {activity.amount && (
                    <Badge className="bg-green-100 text-green-800">
                      ₹{activity.amount.toLocaleString()}
                    </Badge>
                  )}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
