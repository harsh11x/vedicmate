'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Switch } from '@/components/ui/switch'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { 
  Settings,
  Store,
  CreditCard,
  Mail,
  Shield,
  Bell,
  Globe,
  Palette,
  Save,
  Eye,
  EyeOff,
  User,
  Phone,
  MapPin
} from 'lucide-react'
import { toast } from 'sonner'

interface StoreSettings {
  storeName: string
  storeDescription: string
  storeEmail: string
  storePhone: string
  storeAddress: {
    street: string
    city: string
    state: string
    pincode: string
    country: string
  }
  currency: string
  timezone: string
  language: string
}

interface PaymentSettings {
  razorpayEnabled: boolean
  razorpayKeyId: string
  razorpayKeySecret: string
}

interface NotificationSettings {
  emailNotifications: boolean
  smsNotifications: boolean
  orderNotifications: boolean
  lowStockAlerts: boolean
  lowStockThreshold: number
  adminEmail: string
  adminPhone: string
}

interface SecuritySettings {
  twoFactorAuth: boolean
  sessionTimeout: number
  passwordChangeRequired: boolean
  loginAttempts: number
}

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('store')
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [showSecrets, setShowSecrets] = useState(false)

  const [storeSettings, setStoreSettings] = useState<StoreSettings>({
    storeName: 'Punjab Heritage',
    storeDescription: 'Authentic Punjabi crafts including handmade jutti and exquisite phulkari',
    storeEmail: 'store@punjabheritage.com',
    storePhone: '+91 98765 43210',
    storeAddress: {
      street: '123 Heritage Street',
      city: 'Chandigarh',
      state: 'Punjab',
      pincode: '160001',
      country: 'India'
    },
    currency: 'INR',
    timezone: 'Asia/Kolkata',
    language: 'en'
  })

  const [paymentSettings, setPaymentSettings] = useState<PaymentSettings>({
    razorpayEnabled: true,
    razorpayKeyId: 'rzp_test_xxxxx',
    razorpayKeySecret: 'xxxxx_secret_key'
  })

  const [notificationSettings, setNotificationSettings] = useState<NotificationSettings>({
    emailNotifications: true,
    smsNotifications: false,
    orderNotifications: true,
    lowStockAlerts: true,
    lowStockThreshold: 10,
    adminEmail: 'harshdevsingh2004@gmail.com',
    adminPhone: '+91 98765 43210'
  })

  const [securitySettings, setSecuritySettings] = useState<SecuritySettings>({
    twoFactorAuth: false,
    sessionTimeout: 7,
    passwordChangeRequired: false,
    loginAttempts: 5
  })

  useEffect(() => {
    loadSettings()
  }, [])

  const loadSettings = async () => {
    setIsLoading(true)
    try {
      // In a real app, load from API
      // For now, using default values
      await new Promise(resolve => setTimeout(resolve, 500)) // Simulate API call
    } catch (error) {
      console.error('Error loading settings:', error)
      toast.error('Failed to load settings')
    } finally {
      setIsLoading(false)
    }
  }

  const saveSettings = async () => {
    setIsSaving(true)
    try {
      // In a real app, save to API/database
      await new Promise(resolve => setTimeout(resolve, 1000)) // Simulate API call
      
      toast.success('Settings saved successfully!')
    } catch (error) {
      console.error('Error saving settings:', error)
      toast.error('Failed to save settings')
    } finally {
      setIsSaving(false)
    }
  }

  const resetToDefaults = () => {
    if (confirm('Are you sure you want to reset all settings to default values?')) {
      // Reset logic here
      toast.success('Settings reset to defaults')
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-red-600 mb-4"></div>
          <p className="text-red-900 font-semibold">Loading Settings...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-red-50 p-6">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 space-y-4 sm:space-y-0">
          <div>
            <h1 className="text-3xl font-bold text-red-900 mb-2">Settings</h1>
            <p className="text-amber-700">Configure your store settings and preferences</p>
          </div>
          <div className="flex space-x-3">
            <Button 
              variant="outline" 
              onClick={resetToDefaults}
              className="border-red-300 text-red-700 hover:bg-red-50"
            >
              Reset to Defaults
            </Button>
            <Button 
              onClick={saveSettings}
              disabled={isSaving}
              className="bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800"
            >
              {isSaving ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Saving...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4 mr-2" />
                  Save Settings
                </>
              )}
            </Button>
          </div>
        </div>

        {/* Settings Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList className="grid w-full grid-cols-4 lg:w-auto lg:grid-cols-4 bg-white/80 border-2 border-amber-200">
            <TabsTrigger value="store" className="flex items-center space-x-2">
              <Store className="h-4 w-4" />
              <span className="hidden sm:inline">Store</span>
            </TabsTrigger>
            <TabsTrigger value="payments" className="flex items-center space-x-2">
              <CreditCard className="h-4 w-4" />
              <span className="hidden sm:inline">Payments</span>
            </TabsTrigger>
            <TabsTrigger value="notifications" className="flex items-center space-x-2">
              <Bell className="h-4 w-4" />
              <span className="hidden sm:inline">Notifications</span>
            </TabsTrigger>
            <TabsTrigger value="security" className="flex items-center space-x-2">
              <Shield className="h-4 w-4" />
              <span className="hidden sm:inline">Security</span>
            </TabsTrigger>
          </TabsList>

          {/* Store Settings */}
          <TabsContent value="store" className="space-y-6">
            <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="flex items-center text-red-900">
                  <Store className="h-5 w-5 mr-2" />
                  Store Information
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <Label htmlFor="storeName">Store Name</Label>
                    <Input
                      id="storeName"
                      value={storeSettings.storeName}
                      onChange={(e) => setStoreSettings({...storeSettings, storeName: e.target.value})}
                      placeholder="Punjab Heritage"
                    />
                  </div>
                  <div>
                    <Label htmlFor="storeEmail">Store Email</Label>
                    <Input
                      id="storeEmail"
                      type="email"
                      value={storeSettings.storeEmail}
                      onChange={(e) => setStoreSettings({...storeSettings, storeEmail: e.target.value})}
                      placeholder="store@punjabheritage.com"
                    />
                  </div>
                </div>

                <div>
                  <Label htmlFor="storeDescription">Store Description</Label>
                  <Textarea
                    id="storeDescription"
                    value={storeSettings.storeDescription}
                    onChange={(e) => setStoreSettings({...storeSettings, storeDescription: e.target.value})}
                    placeholder="Describe your store..."
                    rows={3}
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <Label htmlFor="storePhone">Store Phone</Label>
                    <Input
                      id="storePhone"
                      value={storeSettings.storePhone}
                      onChange={(e) => setStoreSettings({...storeSettings, storePhone: e.target.value})}
                      placeholder="+91 98765 43210"
                    />
                  </div>
                  <div>
                    <Label htmlFor="currency">Currency</Label>
                    <Select value={storeSettings.currency} onValueChange={(value) => setStoreSettings({...storeSettings, currency: value})}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="INR">Indian Rupee (₹)</SelectItem>
                        <SelectItem value="USD">US Dollar ($)</SelectItem>
                        <SelectItem value="EUR">Euro (€)</SelectItem>
                        <SelectItem value="GBP">British Pound (£)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div>
                  <Label className="text-base font-semibold text-red-900 mb-4 block">Store Address</Label>
                  <div className="grid grid-cols-1 gap-4 p-4 bg-amber-50 rounded-lg border border-amber-200">
                    <div>
                      <Label htmlFor="street">Street Address</Label>
                      <Input
                        id="street"
                        value={storeSettings.storeAddress.street}
                        onChange={(e) => setStoreSettings({
                          ...storeSettings, 
                          storeAddress: {...storeSettings.storeAddress, street: e.target.value}
                        })}
                        placeholder="123 Heritage Street"
                      />
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      <div>
                        <Label htmlFor="city">City</Label>
                        <Input
                          id="city"
                          value={storeSettings.storeAddress.city}
                          onChange={(e) => setStoreSettings({
                            ...storeSettings, 
                            storeAddress: {...storeSettings.storeAddress, city: e.target.value}
                          })}
                          placeholder="Chandigarh"
                        />
                      </div>
                      <div>
                        <Label htmlFor="state">State</Label>
                        <Input
                          id="state"
                          value={storeSettings.storeAddress.state}
                          onChange={(e) => setStoreSettings({
                            ...storeSettings, 
                            storeAddress: {...storeSettings.storeAddress, state: e.target.value}
                          })}
                          placeholder="Punjab"
                        />
                      </div>
                      <div>
                        <Label htmlFor="pincode">Pincode</Label>
                        <Input
                          id="pincode"
                          value={storeSettings.storeAddress.pincode}
                          onChange={(e) => setStoreSettings({
                            ...storeSettings, 
                            storeAddress: {...storeSettings.storeAddress, pincode: e.target.value}
                          })}
                          placeholder="160001"
                        />
                      </div>
                      <div>
                        <Label htmlFor="country">Country</Label>
                        <Input
                          id="country"
                          value={storeSettings.storeAddress.country}
                          onChange={(e) => setStoreSettings({
                            ...storeSettings, 
                            storeAddress: {...storeSettings.storeAddress, country: e.target.value}
                          })}
                          placeholder="India"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Payment Settings */}
          <TabsContent value="payments" className="space-y-6">
            <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="flex items-center text-red-900">
                  <CreditCard className="h-5 w-5 mr-2" />
                  Payment Gateway Settings
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Razorpay Settings */}
                <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h3 className="font-semibold text-blue-900">Razorpay Integration</h3>
                      <p className="text-sm text-blue-700">Accept online payments via Razorpay</p>
                    </div>
                    <Switch
                      checked={paymentSettings.razorpayEnabled}
                      onCheckedChange={(checked) => setPaymentSettings({...paymentSettings, razorpayEnabled: checked})}
                    />
                  </div>
                  
                  {paymentSettings.razorpayEnabled && (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="razorpayKeyId">Razorpay Key ID</Label>
                        <div className="relative">
                          <Input
                            id="razorpayKeyId"
                            type={showSecrets ? 'text' : 'password'}
                            value={paymentSettings.razorpayKeyId}
                            onChange={(e) => setPaymentSettings({...paymentSettings, razorpayKeyId: e.target.value})}
                            placeholder="rzp_test_xxxxx"
                          />
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            className="absolute right-0 top-0 h-full px-3"
                            onClick={() => setShowSecrets(!showSecrets)}
                          >
                            {showSecrets ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                          </Button>
                        </div>
                      </div>
                      <div>
                        <Label htmlFor="razorpayKeySecret">Razorpay Key Secret</Label>
                        <Input
                          id="razorpayKeySecret"
                          type={showSecrets ? 'text' : 'password'}
                          value={paymentSettings.razorpayKeySecret}
                          onChange={(e) => setPaymentSettings({...paymentSettings, razorpayKeySecret: e.target.value})}
                          placeholder="xxxxx_secret_key"
                        />
                      </div>
                    </div>
                  )}
                </div>


              </CardContent>
            </Card>
          </TabsContent>

          {/* Notification Settings */}
          <TabsContent value="notifications" className="space-y-6">
            <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="flex items-center text-red-900">
                  <Bell className="h-5 w-5 mr-2" />
                  Notification Preferences
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Admin Contact */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <Label htmlFor="adminEmail">Admin Email</Label>
                    <Input
                      id="adminEmail"
                      type="email"
                      value={notificationSettings.adminEmail}
                      onChange={(e) => setNotificationSettings({...notificationSettings, adminEmail: e.target.value})}
                      placeholder="harshdevsingh2004@gmail.com"
                    />
                  </div>
                  <div>
                    <Label htmlFor="adminPhone">Admin Phone</Label>
                    <Input
                      id="adminPhone"
                      value={notificationSettings.adminPhone}
                      onChange={(e) => setNotificationSettings({...notificationSettings, adminPhone: e.target.value})}
                      placeholder="+91 98765 43210"
                    />
                  </div>
                </div>

                {/* Notification Types */}
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 bg-amber-50 rounded-lg border border-amber-200">
                    <div>
                      <h3 className="font-semibold text-amber-900">Email Notifications</h3>
                      <p className="text-sm text-amber-700">Receive notifications via email</p>
                    </div>
                    <Switch
                      checked={notificationSettings.emailNotifications}
                      onCheckedChange={(checked) => setNotificationSettings({...notificationSettings, emailNotifications: checked})}
                    />
                  </div>

                  <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg border border-blue-200">
                    <div>
                      <h3 className="font-semibold text-blue-900">SMS Notifications</h3>
                      <p className="text-sm text-blue-700">Receive notifications via SMS</p>
                    </div>
                    <Switch
                      checked={notificationSettings.smsNotifications}
                      onCheckedChange={(checked) => setNotificationSettings({...notificationSettings, smsNotifications: checked})}
                    />
                  </div>

                  <div className="flex items-center justify-between p-4 bg-green-50 rounded-lg border border-green-200">
                    <div>
                      <h3 className="font-semibold text-green-900">Order Notifications</h3>
                      <p className="text-sm text-green-700">Get notified for new orders</p>
                    </div>
                    <Switch
                      checked={notificationSettings.orderNotifications}
                      onCheckedChange={(checked) => setNotificationSettings({...notificationSettings, orderNotifications: checked})}
                    />
                  </div>

                  <div className="p-4 bg-red-50 rounded-lg border border-red-200">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <h3 className="font-semibold text-red-900">Low Stock Alerts</h3>
                        <p className="text-sm text-red-700">Get alerted when products are running low</p>
                      </div>
                      <Switch
                        checked={notificationSettings.lowStockAlerts}
                        onCheckedChange={(checked) => setNotificationSettings({...notificationSettings, lowStockAlerts: checked})}
                      />
                    </div>
                    
                    {notificationSettings.lowStockAlerts && (
                      <div className="md:w-1/2">
                        <Label htmlFor="lowStockThreshold">Alert Threshold (items)</Label>
                        <Input
                          id="lowStockThreshold"
                          type="number"
                          value={notificationSettings.lowStockThreshold}
                          onChange={(e) => setNotificationSettings({...notificationSettings, lowStockThreshold: parseInt(e.target.value)})}
                          placeholder="10"
                        />
                      </div>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Security Settings */}
          <TabsContent value="security" className="space-y-6">
            <Card className="border-2 border-amber-200 bg-white/80 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="flex items-center text-red-900">
                  <Shield className="h-5 w-5 mr-2" />
                  Security & Access Control
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <Label htmlFor="sessionTimeout">Session Timeout (days)</Label>
                    <Select 
                      value={securitySettings.sessionTimeout.toString()} 
                      onValueChange={(value) => setSecuritySettings({...securitySettings, sessionTimeout: parseInt(value)})}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="1">1 Day</SelectItem>
                        <SelectItem value="3">3 Days</SelectItem>
                        <SelectItem value="7">7 Days (Recommended)</SelectItem>
                        <SelectItem value="14">14 Days</SelectItem>
                        <SelectItem value="30">30 Days</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="loginAttempts">Max Login Attempts</Label>
                    <Input
                      id="loginAttempts"
                      type="number"
                      value={securitySettings.loginAttempts}
                      onChange={(e) => setSecuritySettings({...securitySettings, loginAttempts: parseInt(e.target.value)})}
                      placeholder="5"
                    />
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 bg-purple-50 rounded-lg border border-purple-200">
                    <div>
                      <h3 className="font-semibold text-purple-900">Two-Factor Authentication</h3>
                      <p className="text-sm text-purple-700">Add an extra layer of security to your account</p>
                    </div>
                    <Switch
                      checked={securitySettings.twoFactorAuth}
                      onCheckedChange={(checked) => setSecuritySettings({...securitySettings, twoFactorAuth: checked})}
                    />
                  </div>

                  <div className="flex items-center justify-between p-4 bg-orange-50 rounded-lg border border-orange-200">
                    <div>
                      <h3 className="font-semibold text-orange-900">Regular Password Change</h3>
                      <p className="text-sm text-orange-700">Require password changes every 90 days</p>
                    </div>
                    <Switch
                      checked={securitySettings.passwordChangeRequired}
                      onCheckedChange={(checked) => setSecuritySettings({...securitySettings, passwordChangeRequired: checked})}
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
