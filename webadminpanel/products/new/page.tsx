'use client'

import React from 'react'
import { Card, CardContent } from '@/components/ui/card'
import ProductForm from '@/components/admin/ProductForm'

export default function NewProductPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 p-6">
      <div className="max-w-4xl mx-auto">
        <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
          <CardContent className="p-8">
            <ProductForm />
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
