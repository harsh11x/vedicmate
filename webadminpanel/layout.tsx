'use client'

import { useEffect } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import { AdminAuthProvider, useAdminAuth } from '@/contexts/AdminAuthContext'
import { Button } from '@/components/ui/button'
import { LogOut, Settings, Package, ShoppingCart, BarChart3, Home } from 'lucide-react'
import Link from 'next/link'

function AdminLayoutContent({ children }: { children: React.ReactNode }) {
  const { user, isAuthenticated, isLoading, logout } = useAdminAuth()
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {
    if (!isLoading && !isAuthenticated && pathname !== '/admin/login') {
      router.push('/admin/login')
    }
  }, [isAuthenticated, isLoading, pathname, router])

  // Show loading spinner while checking authentication
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-red-600 mb-4"></div>
          <p className="text-red-900 font-semibold">Loading...</p>
        </div>
      </div>
    )
  }

  // Show login page if not authenticated
  if (!isAuthenticated && pathname !== '/admin/login') {
    return null // Will redirect to login
  }

  // Show login page without layout
  if (pathname === '/admin/login') {
    return <>{children}</>
  }

  // Show admin layout for authenticated users
  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50">
      {/* Admin Header */}
      <header className="bg-white/90 backdrop-blur-sm border-b-2 border-amber-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-6">
              <Link href="/admin" className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-orange-600 to-amber-500 rounded-full flex items-center justify-center">
                  <Home className="text-white h-5 w-5" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-orange-900">Admin Panel</h1>
                  <p className="text-sm text-amber-700">Vedic Mate</p>
                </div>
              </Link>

              {/* Navigation */}
              <nav className="hidden md:flex items-center space-x-4">
                <Link
                  href="/admin"
                  className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${pathname === '/admin'
                      ? 'bg-red-100 text-red-900'
                      : 'text-amber-700 hover:bg-amber-100'
                    }`}
                >
                  <BarChart3 className="h-4 w-4 inline mr-2" />
                  Dashboard
                </Link>
                <Link
                  href="/admin/products"
                  className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${pathname.startsWith('/admin/products')
                      ? 'bg-red-100 text-red-900'
                      : 'text-amber-700 hover:bg-amber-100'
                    }`}
                >
                  <Package className="h-4 w-4 inline mr-2" />
                  Products
                </Link>
                <Link
                  href="/admin/orders"
                  className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${pathname.startsWith('/admin/orders')
                      ? 'bg-red-100 text-red-900'
                      : 'text-amber-700 hover:bg-amber-100'
                    }`}
                >
                  <ShoppingCart className="h-4 w-4 inline mr-2" />
                  Orders
                </Link>
                <Link
                  href="/admin/settings"
                  className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${pathname === '/admin/settings'
                      ? 'bg-red-100 text-red-900'
                      : 'text-amber-700 hover:bg-amber-100'
                    }`}
                >
                  <Settings className="h-4 w-4 inline mr-2" />
                  Settings
                </Link>
              </nav>
            </div>

            {/* User Info & Logout */}
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <p className="text-sm font-medium text-red-900">{user?.email}</p>
                <p className="text-xs text-amber-700 capitalize">{user?.role?.replace('_', ' ')}</p>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={logout}
                className="border-red-300 text-red-700 hover:bg-red-50"
              >
                <LogOut className="h-4 w-4 mr-2" />
                Logout
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-6 py-6">
        {children}
      </main>
    </div>
  )
}

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <AdminAuthProvider>
      <AdminLayoutContent>{children}</AdminLayoutContent>
    </AdminAuthProvider>
  )
}
