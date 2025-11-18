// Vedic Mate Backend Server (Express)
import express from 'express'
import cors from 'cors'

const app = express()
app.use(cors())
app.use(express.json())

// In-memory demo store (replace with DB later)
const state = {
  platformFeePercent: 35,
  pandits: [
    {
      id: 'p1',
      name: 'Pandit Ravi Shankar',
      profile_image: null,
      specializations: ['Vedic Astrology', 'Palmistry', 'Numerology'],
      experience_years: 15,
      rating: 4.8,
      total_reviews: 2341,
      languages: ['Hindi', 'English', 'Sanskrit'],
      service_pricing: { consultation: 25.0, video_call: 30.0, voice_call: 25.0, chat: 20.0 },
      bio: 'Experienced Vedic astrologer with 15+ years of practice. Specialized in Vedic astrology, Palmistry, and Numerology. Known for accurate predictions and spiritual guidance.',
      certifications: ['Vedic Astrology Certification', 'Jyotish Expert'],
      is_verified: true,
      is_available: true,
      status: 'active',
      totalEarnings: 125000,
    },
    {
      id: 'p2',
      name: 'Acharya Priya Sharma',
      profile_image: null,
      specializations: ['Numerology', 'Tarot Reading', 'Vastu Shastra'],
      experience_years: 12,
      rating: 4.9,
      total_reviews: 1890,
      languages: ['Hindi', 'English'],
      service_pricing: { consultation: 30.0, video_call: 35.0, voice_call: 30.0, chat: 25.0 },
      bio: 'Renowned numerologist and tarot reader with 12 years of experience. Expert in Vastu Shastra and provides detailed life guidance.',
      certifications: ['Numerology Master', 'Tarot Expert'],
      is_verified: true,
      is_available: true,
      status: 'active',
      totalEarnings: 98000,
    },
    {
      id: 'p3',
      name: 'Guru Vikash Joshi',
      profile_image: null,
      specializations: ['Vastu Shastra', 'Gemology', 'Remedies'],
      experience_years: 20,
      rating: 4.7,
      total_reviews: 1567,
      languages: ['Hindi', 'English', 'Gujarati'],
      service_pricing: { consultation: 35.0, video_call: 40.0, voice_call: 35.0, chat: 30.0 },
      bio: 'Master in Vastu Shastra and Gemology with 20 years of expertise. Provides effective remedies and spiritual solutions.',
      certifications: ['Vastu Expert', 'Gemologist'],
      is_verified: true,
      is_available: true,
      status: 'active',
      totalEarnings: 156000,
    },
    {
      id: 'p4',
      name: 'Sidhi',
      profile_image: null,
      specializations: ['Vedic', 'Vastu', 'Prashana'],
      experience_years: 10,
      rating: 4.96,
      total_reviews: 212197,
      languages: ['English', 'Hindi'],
      service_pricing: { consultation: 27.0, video_call: 32.0, voice_call: 27.0, chat: 22.0 },
      bio: 'Sidhi is a Vedic astrologer in India. She loves to help her clients when they are in need. Her predictions are known for their accuracy and she provides spiritual guidance based on ancient Vedic principles.',
      certifications: ['Vedic Astrology Expert'],
      is_verified: true,
      is_available: true,
      status: 'active',
      totalEarnings: 245000,
    },
  ],
  bookings: [],
  transactions: [
    { id: 't1', createdAt: Date.now()-86400000, clientId: 'c1', clientName: 'John Doe', panditId: 'p1', panditName: 'Pandit Ravi Shankar', type: 'payment', amount: 678.5, bookingId: 'b1' },
    { id: 't2', createdAt: Date.now()-43200000, clientId: 'c2', clientName: 'Aditi Verma', panditId: null, panditName: null, type: 'deposit', amount: 1000, bookingId: null },
  ],
  wallets: [
    { clientId: 'c1', clientName: 'John Doe', balance: 1450.0, lastTransaction: Date.now()-3600000 },
    { clientId: 'c2', clientName: 'Aditi Verma', balance: 250.0, lastTransaction: Date.now()-7200000 },
  ],
  payouts: [
    { id: 'po1', createdAt: Date.now()-7200000, panditId: 'p1', panditName: 'Pandit Ravi Shankar', amount: 2500, status: 'pending' },
    { id: 'po2', createdAt: Date.now()-17200000, panditId: 'p2', panditName: 'Pandit Priya Sharma', amount: 1800, status: 'completed' },
  ],
  live: [
    { id: 'l1', title: 'Daily Horoscope Reading', viewers: 1256, panditName: 'Pandit Ravi Shankar', panditId: 'p1' },
    { id: 'l2', title: 'Marriage Compatibility Analysis', viewers: 843, panditName: 'Acharya Priya Sharma', panditId: 'p2' },
    { id: 'l3', title: 'Vastu Consultation Live', viewers: 567, panditName: 'Guru Vikash Joshi', panditId: 'p3' },
    { id: 'l4', title: 'Vedic Remedies Session', viewers: 1234, panditName: 'Sidhi', panditId: 'p4' },
    { id: 'l5', title: 'Numerology Reading', viewers: 432, panditName: 'Acharya Priya Sharma', panditId: 'p2' },
  ],
}

// Health
app.get('/api/health', (req, res) => res.json({ ok: true }))

// Settings
app.get('/api/settings', (req, res) => res.json({ platformFeePercent: state.platformFeePercent }))
app.post('/api/settings', (req, res) => {
  const { platformFeePercent } = req.body
  if (typeof platformFeePercent === 'number') state.platformFeePercent = platformFeePercent
  res.json({ ok: true })
})

// Pandits
app.get('/api/pandits', (req, res) => res.json(state.pandits))
app.post('/api/pandits', (req, res) => {
  const pandit = { id: String(Date.now()), status: 'pending', rating: 0, totalEarnings: 0, ...req.body }
  state.pandits.push(pandit)
  res.json(pandit)
})
app.put('/api/pandits/:id', (req, res) => {
  const { id } = req.params
  const idx = state.pandits.findIndex(p => p.id === id)
  if (idx === -1) return res.status(404).json({ error: 'Not found' })
  state.pandits[idx] = { ...state.pandits[idx], ...req.body }
  res.json(state.pandits[idx])
})
app.post('/api/pandits/:id/block', (req, res) => {
  const { id } = req.params
  const p = state.pandits.find(p => p.id === id)
  if (!p) return res.status(404).json({ error: 'Not found' })
  p.status = 'blocked'
  res.json({ ok: true })
})

// Transactions
app.get('/api/transactions', (req, res) => res.json(state.transactions))

// Wallets
app.get('/api/wallets', (req, res) => res.json(state.wallets))

// Payouts
app.get('/api/payouts', (req, res) => res.json(state.payouts))

// Live sessions
app.get('/api/live', (req, res) => res.json(state.live))

const PORT = process.env.PORT || 4000
app.listen(PORT, () => console.log(`Vedic Mate server running on :${PORT}`))
