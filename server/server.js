// ============================================================================
// Vedic Mate - Complete Backend Server (All-in-One)
// Express + Socket.IO with Orders, Products, Wallet, and AI Services
// ============================================================================

import express from 'express';
import cors from 'cors';
import { createServer } from 'https';
import { readFileSync } from 'fs';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import Razorpay from 'razorpay';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import axios from 'axios';
import nodemailer from 'nodemailer';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load Certificates
const httpsOptions = {
  key: readFileSync(path.join(__dirname, '..', 'certs', 'server.key')),
  cert: readFileSync(path.join(__dirname, '..', 'certs', 'server.cert'))
};

const app = express();
const httpServer = createServer(httpsOptions, app); // Using HTTPS
const io = new Server(httpServer, {
  cors: {
    origin: ["http://15.207.36.26:3000", "http://localhost:3000", "https://localhost:3000", "https://15.207.36.26:3000", "*"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true
  }
});

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// ============================================================================
// FILE STORAGE SETUP
// ============================================================================

// Serve static assets (images)
app.use('/assets', express.static(path.join(__dirname, 'assets')));

const DATA_DIR = path.join(__dirname, 'data');
const ORDERS_FILE = path.join(DATA_DIR, 'orders.json');
const PRODUCTS_FILE = path.join(DATA_DIR, 'products.json');
const WALLETS_FILE = path.join(DATA_DIR, 'wallets.json');
const TRANSACTIONS_FILE = path.join(DATA_DIR, 'transactions.json');
const SETTINGS_FILE = path.join(DATA_DIR, 'settings.json');
const CUSTOM_REQUESTS_FILE = path.join(DATA_DIR, 'custom_requests.json');
const LIVE_SESSIONS_FILE = path.join(DATA_DIR, 'live_sessions.json');

// Initialize data directory and files
const initializeDataStorage = () => {
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
    console.log('📁 Created data directory');
  }

  if (!fs.existsSync(ORDERS_FILE)) {
    fs.writeFileSync(ORDERS_FILE, JSON.stringify([], null, 2));
    console.log('📄 Created orders.json');
  }

  if (!fs.existsSync(PRODUCTS_FILE)) {
    fs.writeFileSync(PRODUCTS_FILE, JSON.stringify(getDefaultProducts(), null, 2));
    console.log('📄 Created products.json with default products');
  }

  if (!fs.existsSync(WALLETS_FILE)) {
    fs.writeFileSync(WALLETS_FILE, JSON.stringify([], null, 2));
    console.log('📄 Created wallets.json');
  }

  if (!fs.existsSync(TRANSACTIONS_FILE)) {
    fs.writeFileSync(TRANSACTIONS_FILE, JSON.stringify([], null, 2));
    console.log('📄 Created transactions.json');
  }

  if (!fs.existsSync(CUSTOM_REQUESTS_FILE)) {
    fs.writeFileSync(CUSTOM_REQUESTS_FILE, JSON.stringify([], null, 2));
    console.log('📄 Created custom_requests.json');
  }

  if (!fs.existsSync(LIVE_SESSIONS_FILE)) {
    fs.writeFileSync(LIVE_SESSIONS_FILE, JSON.stringify([], null, 2));
    console.log('📄 Created live_sessions.json');
  }

  if (!fs.existsSync(SETTINGS_FILE)) {
    fs.writeFileSync(SETTINGS_FILE, JSON.stringify({
      platformFeePercent: 35,
      minimumBalance: 50.0,
      chatRatePerMinute: 25.0
    }, null, 2));
    console.log('📄 Created settings.json');
  }
};

// Default Vedic products
const getDefaultProducts = () => [
  {
    id: 'rudraksha_5',
    name: '5 Mukhi Rudraksha',
    description: 'Authentic 5 Mukhi Rudraksha bead for peace and prosperity. Blessed by Vedic priests.',
    price: 1499,
    originalPrice: 1999,
    category: 'rudraksha',
    images: ['assets/images/remedies/rudraksha.png'],
    inStock: true,
    isActive: true,
    featured: true,
    stock: 50,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 'yantra_shree',
    name: 'Shree Yantra',
    description: 'Gold plated Shree Yantra for wealth and abundance. Energized with mantras.',
    price: 2999,
    originalPrice: 3999,
    category: 'yantra',
    images: ['assets/images/remedies/yantra.png'],
    inStock: true,
    isActive: true,
    featured: true,
    stock: 30,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 'gemstone_neelam',
    name: 'Blue Sapphire (Neelam)',
    description: 'Natural Blue Sapphire gemstone for Saturn. Certified and authentic.',
    price: 15999,
    originalPrice: 19999,
    category: 'gemstone',
    images: ['assets/images/remedies/gemstone.png'],
    inStock: true,
    isActive: true,
    featured: false,
    stock: 10,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 'mala_tulsi',
    name: 'Tulsi Mala',
    description: 'Sacred Tulsi beads mala for daily prayers and meditation.',
    price: 499,
    originalPrice: 699,
    category: 'mala',
    images: ['assets/images/remedies/mala.png'],
    inStock: true,
    isActive: true,
    featured: false,
    stock: 100,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

// ============================================================================
// FILE HELPERS
// ============================================================================

const readJsonFile = (filePath, defaultValue = []) => {
  try {
    if (!fs.existsSync(filePath)) return defaultValue;
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`Error reading ${filePath}:`, error);
    return defaultValue;
  }
};

const writeJsonFile = (filePath, data) => {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    return true;
  } catch (error) {
    console.error(`Error writing ${filePath}:`, error);
    return false;
  }
};

// Specific file accessors
const readOrders = () => readJsonFile(ORDERS_FILE, []);
const writeOrders = (data) => writeJsonFile(ORDERS_FILE, data);
const readProducts = () => readJsonFile(PRODUCTS_FILE, []);
const writeProducts = (data) => writeJsonFile(PRODUCTS_FILE, data);
const readWallets = () => readJsonFile(WALLETS_FILE, []);
const writeWallets = (data) => writeJsonFile(WALLETS_FILE, data);
const readTransactions = () => readJsonFile(TRANSACTIONS_FILE, []);
const writeTransactions = (data) => writeJsonFile(TRANSACTIONS_FILE, data);
const readSettings = () => readJsonFile(SETTINGS_FILE, { platformFeePercent: 35 });
const writeSettings = (data) => writeJsonFile(SETTINGS_FILE, data);
const readCustomRequests = () => readJsonFile(CUSTOM_REQUESTS_FILE, []);
const writeCustomRequests = (data) => writeJsonFile(CUSTOM_REQUESTS_FILE, data);
const readLiveSessions = () => readJsonFile(LIVE_SESSIONS_FILE, []);
const writeLiveSessions = (data) => writeJsonFile(LIVE_SESSIONS_FILE, data);

// Generate order ID
const generateOrderId = () => {
  const now = new Date();
  const year = now.getFullYear();
  const random = Math.floor(Math.random() * 9999).toString().padStart(4, '0');
  return `VED-${year}-${random}`;
};

// Generate custom request ID
const generateCustomRequestId = () => {
  const now = new Date();
  const year = now.getFullYear();
  const random = Math.floor(Math.random() * 9999).toString().padStart(4, '0');
  return `REQ-${year}-${random}`;
};

// Generate live session ID
const generateSessionId = () => {
  return `LIVE-${Date.now()}-${Math.random().toString(36).substr(2, 6).toUpperCase()}`;
};

// Generate transaction ID
const generateTxId = () => {
  return `tx_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

// Initialize data storage
initializeDataStorage();

// ============================================================================
// WALLET SERVICE (Inline)
// ============================================================================

const WalletService = {
  getBalance(userId) {
    const wallets = readWallets();
    const wallet = wallets.find(w => w.clientId === userId);
    if (!wallet) {
      const newWallet = {
        clientId: userId,
        clientName: 'User',
        balance: 0.0,
        lastTransaction: Date.now(),
        transactions: []
      };
      wallets.push(newWallet);
      writeWallets(wallets);
      return 0.0;
    }
    return wallet.balance || 0.0;
  },

  getWallet(userId) {
    const wallets = readWallets();
    let wallet = wallets.find(w => w.clientId === userId);
    if (!wallet) {
      wallet = {
        clientId: userId,
        clientName: 'User',
        balance: 0.0,
        lastTransaction: Date.now(),
        transactions: []
      };
      wallets.push(wallet);
      writeWallets(wallets);
    }
    return wallet;
  },

  addMoney(userId, amount, type = 'recharge', description = '') {
    if (amount <= 0) throw new Error('Amount must be positive');

    const wallets = readWallets();
    const transactions = readTransactions();

    let wallet = wallets.find(w => w.clientId === userId);
    if (!wallet) {
      wallet = {
        clientId: userId,
        clientName: 'User',
        balance: 0.0,
        lastTransaction: Date.now(),
        transactions: []
      };
      wallets.push(wallet);
    }

    wallet.balance = (wallet.balance || 0) + amount;
    wallet.lastTransaction = Date.now();

    const transaction = {
      id: generateTxId(),
      createdAt: Date.now(),
      clientId: userId,
      type: type,
      amount: amount,
      description: description || `Wallet recharge of ₹${amount}`,
      status: 'completed',
      balanceAfter: wallet.balance
    };

    transactions.push(transaction);
    if (!wallet.transactions) wallet.transactions = [];
    wallet.transactions.push(transaction.id);

    writeWallets(wallets);
    writeTransactions(transactions);

    return { success: true, newBalance: wallet.balance, transaction };
  },

  deductMoney(userId, amount, type = 'service', description = '') {
    if (amount <= 0) throw new Error('Amount must be positive');

    const wallets = readWallets();
    const transactions = readTransactions();

    const wallet = wallets.find(w => w.clientId === userId);
    if (!wallet) throw new Error('Wallet not found');
    if (wallet.balance < amount) throw new Error('Insufficient balance');

    wallet.balance = wallet.balance - amount;
    wallet.lastTransaction = Date.now();

    const transaction = {
      id: generateTxId(),
      createdAt: Date.now(),
      clientId: userId,
      type: type,
      amount: -amount,
      description: description || `Service charge of ₹${amount}`,
      status: 'completed',
      balanceAfter: wallet.balance
    };

    transactions.push(transaction);
    if (!wallet.transactions) wallet.transactions = [];
    wallet.transactions.push(transaction.id);

    writeWallets(wallets);
    writeTransactions(transactions);

    return { success: true, newBalance: wallet.balance, transaction };
  },

  getTransactions(userId, limit = 50) {
    const transactions = readTransactions();
    return transactions
      .filter(t => t.clientId === userId)
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, limit);
  }
};

// ============================================================================
// AI SERVICE (Inline)
// ============================================================================

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';
const GEMINI_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
const OPENAI_BASE_URL = 'https://api.openai.com/v1/chat/completions';

const AIService = {
  pandits: {
    'ai_pandit_1': {
      id: 'ai_pandit_1',
      name: 'Pandit Rajesh Shastri',
      specializations: ['Vedic Astrology', 'Kundli Analysis', 'Marriage Matching'],
      experienceYears: 25,
      gender: 'male',
      bio: 'A renowned Vedic astrologer with 25 years of experience.'
    }
  },

  getPandit(panditId) {
    return this.pandits[panditId] || null;
  },

  getPersonalityPrompt(panditId) {
    const pandit = this.getPandit(panditId);
    if (!pandit) {
      return `You are a wise Vedic astrologer with deep knowledge of Hindu astrology and spiritual practices. Be warm, empathetic, and provide practical guidance based on ancient wisdom.`;
    }

    const { name, specializations, experienceYears, bio } = pandit;
    return `You are ${name}, a Vedic astrologer with ${experienceYears} years of experience specializing in ${specializations.join(', ')}.

YOUR BACKGROUND: ${bio}

GUIDELINES:
1. Respond as ${name} with wisdom and authenticity
2. Use your expertise in ${specializations[0]} to provide accurate guidance
3. Be empathetic, wise, and helpful
4. Provide practical, actionable advice based on Vedic wisdom
5. Never break character or reveal you're an AI`;
  },

  async getWelcomeMessage(panditId) {
    const pandit = this.getPandit(panditId);
    if (!pandit) {
      return 'Namaste! Welcome to Vedic Mate. How may I assist you today? 🙏';
    }
    const { name, specializations } = pandit;
    return `Pranam! I am ${name}, your guide in ${specializations[0]}. How may I assist you today? 🙏`;
  },

  async sendMessage(message, history, panditId) {
    try {
      if (GEMINI_API_KEY && GEMINI_API_KEY !== 'YOUR_GEMINI_API_KEY_HERE') {
        return await this.sendGeminiMessage(message, history, panditId);
      }
      if (OPENAI_API_KEY && OPENAI_API_KEY !== 'YOUR_OPENAI_API_KEY_HERE') {
        return await this.sendOpenAIMessage(message, history, panditId);
      }
      return this.getFallbackResponse(message, panditId);
    } catch (error) {
      console.error('AI Service Error:', error);
      return this.getFallbackResponse(message, panditId);
    }
  },

  async sendGeminiMessage(message, history, panditId) {
    const systemPrompt = this.getPersonalityPrompt(panditId);
    const conversationContext = history.map(h => ({
      role: h.isUser === 'true' || h.isUser === true ? 'user' : 'model',
      parts: [{ text: h.message }]
    }));
    conversationContext.push({ role: 'user', parts: [{ text: message }] });

    const response = await axios.post(
      `${GEMINI_BASE_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: conversationContext,
        systemInstruction: { parts: [{ text: systemPrompt }] },
        generationConfig: { temperature: 0.7, topK: 40, topP: 0.95, maxOutputTokens: 1024 }
      },
      { headers: { 'Content-Type': 'application/json' }, timeout: 30000 }
    );

    if (response.data.candidates?.[0]?.content?.parts?.[0]?.text) {
      return response.data.candidates[0].content.parts[0].text;
    }
    throw new Error('No response from Gemini');
  },

  async sendOpenAIMessage(message, history, panditId) {
    const systemPrompt = this.getPersonalityPrompt(panditId);
    const messages = [
      { role: 'system', content: systemPrompt },
      ...history.map(h => ({
        role: h.isUser === 'true' || h.isUser === true ? 'user' : 'assistant',
        content: h.message
      })),
      { role: 'user', content: message }
    ];

    const response = await axios.post(
      OPENAI_BASE_URL,
      { model: 'gpt-3.5-turbo', messages, temperature: 0.7, max_tokens: 1024 },
      {
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${OPENAI_API_KEY}` },
        timeout: 30000
      }
    );

    if (response.data.choices?.[0]?.message?.content) {
      return response.data.choices[0].message.content;
    }
    throw new Error('No response from OpenAI');
  },

  getFallbackResponse(message, panditId) {
    const pandit = this.getPandit(panditId);
    const lowerMessage = message.toLowerCase();
    const name = pandit?.name || 'Vedic Astrologer';
    const spec = pandit?.specializations?.[0] || 'Vedic astrology';

    if (lowerMessage.includes('kundli') || lowerMessage.includes('birth chart')) {
      return `I can help you with Kundli analysis. Please share your birth details (date, time, place) for a detailed reading.`;
    }
    if (lowerMessage.includes('love') || lowerMessage.includes('relationship')) {
      return `Relationships are important aspects of life. Based on my experience, I can guide you. Could you share more details?`;
    }
    if (lowerMessage.includes('career') || lowerMessage.includes('job')) {
      return `Career guidance is one of my specialties. What specific aspect would you like to know about?`;
    }
    return `Thank you for your question. As ${name}, I specialize in ${spec}. I'm here to help with Vedic guidance. Could you provide more details?`;
  }
};

// ============================================================================
// IN-MEMORY STATE (for pandits, live sessions, etc.)
// ============================================================================

const state = {
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
      bio: 'Experienced Vedic astrologer with 15+ years of practice.',
      certifications: ['Vedic Astrology Certification', 'Jyotish Expert'],
      is_verified: true,
      is_available: true,
      status: 'active',
      totalEarnings: 125000,
    }
  ],
  bookings: [],
  live: [],
  chatSessions: {}
};

// ============================================================================
// WEBSOCKET REAL-TIME UPDATES
// ============================================================================

io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);

  socket.on('join-user-room', (userId) => {
    socket.join(`user-${userId}`);
    console.log(`User ${userId} joined their room`);
  });

  socket.on('request-balance', (userId) => {
    try {
      const balance = WalletService.getBalance(userId);
      socket.emit('balance-update', { userId, balance });
    } catch (error) {
      socket.emit('error', { message: error.message });
    }
  });

  socket.on('chat-message', async (data) => {
    try {
      const { sessionId, userId, panditId, message } = data;
      const history = state.chatSessions[sessionId]?.messages || [];
      const aiResponse = await AIService.sendMessage(message, history, panditId);

      if (!state.chatSessions[sessionId]) {
        state.chatSessions[sessionId] = {
          userId, panditId, messages: [], startTime: Date.now(), isActive: true
        };
      }

      state.chatSessions[sessionId].messages.push(
        { isUser: true, message, timestamp: Date.now() },
        { isUser: false, message: aiResponse, timestamp: Date.now() }
      );

      socket.emit('chat-response', { sessionId, message: aiResponse, timestamp: Date.now() });
      io.to(`user-${userId}`).emit('chat-update', {
        sessionId, messages: state.chatSessions[sessionId].messages
      });
    } catch (error) {
      socket.emit('error', { message: error.message });
    }
  });

  // ===========================================
  // LIVE POOJA & HAVAN SOCKET EVENTS
  // ===========================================

  socket.on('join-pooja', (user) => {
    socket.join('live-pooja-room');

    // Update viewer count (Exclude Admin)
    const viewers = io.sockets.adapter.rooms.get('live-pooja-room')?.size || 0;
    io.to('live-pooja-room').emit('viewer-update', { count: Math.max(0, viewers - 1) });

    // Notify others (Signaling for WebRTC)
    socket.to('live-pooja-room').emit('user-joined', { userId: socket.id });

    if (user && user.name) {
      console.log(`User ${user.name} joined Live Pooja (Total Users: ${viewers})`);
    }
  });

  socket.on('leave-pooja', () => {
    socket.leave('live-pooja-room');
    const viewers = io.sockets.adapter.rooms.get('live-pooja-room')?.size || 0;
    io.to('live-pooja-room').emit('viewer-update', { count: Math.max(0, viewers - 1) });
  });

  // WebRTC Signaling Events
  socket.on('offer', (data) => {
    io.to(data.target).emit('offer', {
      sdp: data.sdp,
      sender: socket.id
    });
  });

  socket.on('answer', (data) => {
    io.to(data.target).emit('answer', {
      sdp: data.sdp,
      sender: socket.id
    });
  });

  socket.on('ice-candidate', (data) => {
    io.to(data.target).emit('ice-candidate', {
      candidate: data.candidate,
      sender: socket.id
    });
  });

  socket.on('pooja-message', (data) => {
    io.to('live-pooja-room').emit('new-pooja-message', {
      ...data,
      timestamp: Date.now()
    });
  });

  socket.on('send-gift', (data) => {
    // Broadcast for animation
    io.to('live-pooja-room').emit('gift-received', {
      ...data,
      timestamp: Date.now()
    });
    console.log(`🎁 Gift: ${data.senderName} sent ${data.giftName} (₹${data.amount})`);
  });

  socket.on('disconnecting', () => {
    // Handle disconnects for viewer count
    if (socket.rooms.has('live-pooja-room')) {
      // The socket technically hasn't left yet, so size is current. 
      // After this event it leaves. So we should emit size - 1.
      const viewers = io.sockets.adapter.rooms.get('live-pooja-room')?.size || 0;
      io.to('live-pooja-room').emit('viewer-update', { count: Math.max(0, viewers - 1) });
    }
  });

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

// ============================================================================
// REST API ENDPOINTS
// ============================================================================

// Health Check
app.get('/api/health', (req, res) => {
  res.json({
    ok: true,
    timestamp: Date.now(),
    services: {
      ai: !!GEMINI_API_KEY || !!OPENAI_API_KEY,
      wallet: true,
      orders: true,
      products: true,
      websocket: true
    }
  });
});

// ==================== AI ENDPOINTS ====================

app.post('/api/ai/welcome', async (req, res) => {
  try {
    const { panditId } = req.body;
    const message = await AIService.getWelcomeMessage(panditId);
    res.json({ success: true, message });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/ai/chat', async (req, res) => {
  try {
    const { message, history, panditId } = req.body;
    if (!message || !panditId) {
      return res.status(400).json({ success: false, error: 'Message and panditId are required' });
    }
    const response = await AIService.sendMessage(message, history || [], panditId);
    res.json({ success: true, response, timestamp: Date.now() });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== WALLET ENDPOINTS ====================

app.get('/api/wallet/balance/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const balance = WalletService.getBalance(userId);
    const wallet = WalletService.getWallet(userId);
    res.json({ success: true, balance, wallet });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/wallet/add', (req, res) => {
  try {
    const { userId, amount, type, description } = req.body;
    if (!userId || !amount) {
      return res.status(400).json({ success: false, error: 'UserId and amount are required' });
    }
    if (amount <= 0) {
      return res.status(400).json({ success: false, error: 'Amount must be positive' });
    }
    const result = WalletService.addMoney(userId, amount, type || 'recharge', description);
    io.to(`user-${userId}`).emit('balance-update', { userId, balance: result.newBalance });
    res.json({ success: true, ...result });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/wallet/deduct', (req, res) => {
  try {
    const { userId, amount, type, description } = req.body;
    if (!userId || !amount) {
      return res.status(400).json({ success: false, error: 'UserId and amount are required' });
    }
    if (amount <= 0) {
      return res.status(400).json({ success: false, error: 'Amount must be positive' });
    }
    const result = WalletService.deductMoney(userId, amount, type || 'service', description);
    io.to(`user-${userId}`).emit('balance-update', { userId, balance: result.newBalance });
    res.json({ success: true, ...result });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/wallet/transactions/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const transactions = WalletService.getTransactions(userId, limit);
    res.json({ success: true, transactions });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== PRODUCTS ENDPOINTS ====================

app.get('/api/products', (req, res) => {
  try {
    const products = readProducts();
    const { category, active, featured } = req.query;
    let filtered = products;
    if (category) filtered = filtered.filter(p => p.category === category);
    if (active === 'true') filtered = filtered.filter(p => p.isActive === true);
    if (featured === 'true') filtered = filtered.filter(p => p.featured === true);
    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/products/:id', (req, res) => {
  try {
    const products = readProducts();
    const product = products.find(p => p.id === req.params.id);
    if (!product) return res.status(404).json({ success: false, error: 'Product not found' });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Get all products
app.get('/api/admin/products', (req, res) => {
  try {
    const products = readProducts();
    const { category, active } = req.query;
    let filtered = products;
    if (category) filtered = filtered.filter(p => p.category === category);
    if (active === 'true') filtered = filtered.filter(p => p.isActive === true);
    if (active === 'false') filtered = filtered.filter(p => p.isActive === false);
    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/admin/products', (req, res) => {
  try {
    const products = readProducts();
    const newProduct = {
      id: `product_${Date.now()}`,
      ...req.body,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    products.push(newProduct);
    writeProducts(products);
    io.emit('products-update', { action: 'add', product: newProduct });
    res.json({ success: true, data: newProduct });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put('/api/admin/products/:id', (req, res) => {
  try {
    const products = readProducts();
    const index = products.findIndex(p => p.id === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Product not found' });
    products[index] = { ...products[index], ...req.body, updatedAt: new Date().toISOString() };
    writeProducts(products);
    io.emit('products-update', { action: 'update', product: products[index] });
    res.json({ success: true, data: products[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Upload Image (Base64)
app.post('/api/admin/upload', (req, res) => {
  try {
    const { image, name } = req.body; // image is base64 string
    if (!image) return res.status(400).json({ success: false, error: 'No image data provided' });

    const matches = image.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
    if (!matches || matches.length !== 3) {
      return res.status(400).json({ success: false, error: 'Invalid base64 string' });
    }

    const type = matches[1];
    const buffer = Buffer.from(matches[2], 'base64');
    const extension = type.split('/')[1];
    const fileName = `${name || 'upload'}_${Date.now()}.${extension}`;

    // Ensure assets directory exists
    const assetsDir = path.join(__dirname, 'assets', 'images', 'products');
    if (!fs.existsSync(assetsDir)) {
      fs.mkdirSync(assetsDir, { recursive: true });
    }

    const filePath = path.join(assetsDir, fileName);
    fs.writeFileSync(filePath, buffer);

    const publicUrl = `assets/images/products/${fileName}`;
    res.json({ success: true, url: publicUrl });
  } catch (error) {
    console.error('Upload Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete('/api/admin/products/:id', (req, res) => {
  try {
    let products = readProducts();
    const index = products.findIndex(p => p.id === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Product not found' });
    const deleted = products[index];
    products = products.filter(p => p.id !== req.params.id);
    writeProducts(products);
    io.emit('products-update', { action: 'delete', productId: req.params.id });
    res.json({ success: true, message: 'Product deleted', data: deleted });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/admin/products/stats', (req, res) => {
  try {
    const products = readProducts();
    const stats = {
      total: products.length,
      active: products.filter(p => p.isActive).length,
      inStock: products.filter(p => p.inStock).length,
      outOfStock: products.filter(p => !p.inStock).length,
      featured: products.filter(p => p.featured).length,
      totalValue: products.reduce((sum, p) => sum + (p.price * (p.stock || 0)), 0),
      categories: products.reduce((acc, p) => { acc[p.category] = (acc[p.category] || 0) + 1; return acc; }, {})
    };
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== ORDERS ENDPOINTS ====================

app.get('/api/orders', (req, res) => {
  try {
    const orders = readOrders();
    const userId = req.headers['x-user-id'];
    let filtered = userId ? orders.filter(o => o.userId === userId) : orders;
    filtered.sort((a, b) => new Date(b.orderDate) - new Date(a.orderDate));
    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/orders/:id', (req, res) => {
  try {
    const orders = readOrders();
    const order = orders.find(o => o.id === req.params.id || o.orderId === req.params.id);
    if (!order) return res.status(404).json({ success: false, error: 'Order not found' });
    res.json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/orders', (req, res) => {
  try {
    const orders = readOrders();
    const orderData = req.body;
    const newOrder = {
      id: `order_${Date.now()}`,
      orderId: generateOrderId(),
      userId: req.headers['x-user-id'] || orderData.userId,
      orderDate: new Date().toISOString(),
      items: orderData.items || [],
      subtotal: orderData.subtotal || 0,
      tax: orderData.tax || 0,
      deliveryCharge: orderData.deliveryCharge || 0,
      totalAmount: orderData.totalAmount || 0,
      paymentStatus: orderData.paymentId ? 'completed' : 'pending',
      paymentId: orderData.paymentId || null,
      deliveryStatus: 'processing',
      shippingAddress: orderData.shippingAddress || {},
      expectedDeliveryDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      trackingNumber: null,
      timeline: [{ status: 'processing', timestamp: new Date().toISOString(), description: 'Order placed successfully' }],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    // DEDUCT STOCK LOGIC
    const products = readProducts();
    let stockUpdated = false;

    if (newOrder.items && newOrder.items.length > 0) {
      newOrder.items.forEach(item => {
        const productIndex = products.findIndex(p => p.id === item.productId || p.id === item.id);
        if (productIndex !== -1) {
          // Reduce stock
          if (products[productIndex].stock > 0) {
            products[productIndex].stock = Math.max(0, products[productIndex].stock - (item.quantity || 1));
            stockUpdated = true;
          }
        }
      });
    }

    if (stockUpdated) {
      writeProducts(products);
      // Notify Admin & App about stock update
      io.emit('products-update', { action: 'batch_update' });
    }

    // Send Email Notification
    const orderItemsHtml = newOrder.items.map(i => `<li>${i.name} (x${i.quantity || 1}) - ₹${i.price}</li>`).join('');
    sendEmailNotification(
      'New Order Received! 📦',
      `<h3>New Order #${newOrder.id}</h3>
       <p><strong>Customer:</strong> ${newOrder.userId} (User ID)</p>
       <p><strong>Amount:</strong> ₹${newOrder.totalAmount}</p>
       <p><strong>Items:</strong></p>
       <ul>${orderItemsHtml}</ul>
       <p>Login to Admin Panel to view details.</p>`
    );

    writeOrders(orders);
    io.emit('orders-update', { action: 'new', order: newOrder });
    res.status(201).json({ success: true, data: newOrder });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Update Order Status
app.put('/api/admin/orders/:id', (req, res) => {
  try {
    const orders = readOrders();
    const index = orders.findIndex(o => o.id === req.params.id || o.orderId === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Order not found' });

    const updates = req.body;
    const oldStatus = orders[index].deliveryStatus;

    // Update fields
    orders[index] = {
      ...orders[index],
      deliveryStatus: updates.deliveryStatus || orders[index].deliveryStatus,
      paymentStatus: updates.paymentStatus || orders[index].paymentStatus,
      trackingNumber: updates.trackingNumber || orders[index].trackingNumber,
      updatedAt: new Date().toISOString()
    };

    writeOrders(orders);

    // Notifications (Email & Socket)
    const newStatus = orders[index].deliveryStatus;
    if (oldStatus !== newStatus) {
      // Send Email
      sendEmailNotification(
        `Order Update: ${newStatus.toUpperCase()} 🚚`,
        `<h3>Order #${orders[index].orderId} Updated</h3>
          <p>Your order status has been updated to: <strong>${newStatus}</strong></p>
          <p>Tracking Number: ${orders[index].trackingNumber || 'N/A'}</p>
          <p>Thanks for choosing Vedic Mate.</p>`
      );

      // Notify specific user room
      io.to(`user-${orders[index].userId}`).emit('order-update', orders[index]);
    }

    io.emit('orders-update', { action: 'updated', order: orders[index] });
    res.json({ success: true, data: orders[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put('/api/orders/:id/cancel', (req, res) => {
  try {
    const orders = readOrders();
    const index = orders.findIndex(o => o.id === req.params.id || o.orderId === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Order not found' });

    const order = orders[index];
    if (['shipped', 'outForDelivery', 'delivered'].includes(order.deliveryStatus)) {
      return res.status(400).json({ success: false, error: 'Cannot cancel order that has been shipped or delivered' });
    }

    orders[index] = {
      ...order,
      deliveryStatus: 'cancelled',
      cancellationReason: req.body.reason || 'Cancelled by user',
      cancelledAt: new Date().toISOString(),
      timeline: [...(order.timeline || []), { status: 'cancelled', timestamp: new Date().toISOString(), description: req.body.reason || 'Order cancelled by user' }],
      updatedAt: new Date().toISOString()
    };
    writeOrders(orders);
    io.emit('orders-update', { action: 'cancelled', order: orders[index] });
    io.to(`user-${order.userId}`).emit('order-status-update', orders[index]);
    res.json({ success: true, data: orders[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/admin/orders', (req, res) => {
  try {
    const orders = readOrders();
    const { status, paymentStatus } = req.query;
    let filtered = orders;
    if (status) filtered = filtered.filter(o => o.deliveryStatus === status);
    if (paymentStatus) filtered = filtered.filter(o => o.paymentStatus === paymentStatus);
    filtered.sort((a, b) => new Date(b.orderDate) - new Date(a.orderDate));
    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put('/api/admin/orders', (req, res) => {
  try {
    const { orderId, updates } = req.body;
    const orders = readOrders();
    const index = orders.findIndex(o => o.id === orderId || o._id === orderId || o.orderId === orderId);
    if (index === -1) return res.status(404).json({ success: false, error: 'Order not found' });

    const order = orders[index];
    const timelineEntry = [];
    if (updates.status && updates.status !== order.deliveryStatus) {
      const statusDescriptions = {
        'processing': 'Order is being processed',
        'confirmed': 'Order confirmed by seller',
        'shipped': 'Order has been shipped',
        'outForDelivery': 'Order is out for delivery',
        'delivered': 'Order delivered successfully',
        'cancelled': 'Order has been cancelled'
      };
      timelineEntry.push({ status: updates.status, timestamp: new Date().toISOString(), description: statusDescriptions[updates.status] || `Status changed to ${updates.status}` });
    }

    orders[index] = {
      ...order,
      deliveryStatus: updates.status || order.deliveryStatus,
      paymentStatus: updates.paymentStatus || order.paymentStatus,
      trackingNumber: updates.trackingNumber || order.trackingNumber,
      expectedDeliveryDate: updates.estimatedDelivery || order.expectedDeliveryDate,
      notes: updates.notes || order.notes,
      actualDeliveryDate: updates.status === 'delivered' ? new Date().toISOString() : order.actualDeliveryDate,
      timeline: [...(order.timeline || []), ...timelineEntry],
      updatedAt: new Date().toISOString()
    };
    writeOrders(orders);
    io.to(`user-${order.userId}`).emit('order-status-update', orders[index]);
    io.emit('orders-update', { action: 'updated', order: orders[index] });
    res.json({ success: true, data: orders[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/admin/orders/stats', (req, res) => {
  try {
    const orders = readOrders();
    const stats = {
      total: orders.length,
      processing: orders.filter(o => o.deliveryStatus === 'processing' || o.deliveryStatus === 'confirmed').length,
      shipped: orders.filter(o => o.deliveryStatus === 'shipped' || o.deliveryStatus === 'outForDelivery').length,
      delivered: orders.filter(o => o.deliveryStatus === 'delivered').length,
      cancelled: orders.filter(o => o.deliveryStatus === 'cancelled').length,
      pendingPayment: orders.filter(o => o.paymentStatus === 'pending').length,
      totalRevenue: orders.filter(o => o.paymentStatus === 'completed' && o.deliveryStatus !== 'cancelled').reduce((sum, o) => sum + (o.totalAmount || 0), 0)
    };
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== SETTINGS ENDPOINTS ====================

app.get('/api/settings', (req, res) => {
  const settings = readSettings();
  res.json(settings);
});

app.post('/api/settings', (req, res) => {
  const settings = readSettings();
  Object.assign(settings, req.body);
  writeSettings(settings);
  res.json({ ok: true, settings });
});

// ==================== PANDITS ENDPOINTS ====================

app.get('/api/pandits', (req, res) => res.json(state.pandits));

app.post('/api/pandits', (req, res) => {
  const pandit = { id: String(Date.now()), status: 'pending', rating: 0, totalEarnings: 0, ...req.body };
  state.pandits.push(pandit);
  res.json(pandit);
});

app.put('/api/pandits/:id', (req, res) => {
  const { id } = req.params;
  const idx = state.pandits.findIndex(p => p.id === id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  state.pandits[idx] = { ...state.pandits[idx], ...req.body };
  res.json(state.pandits[idx]);
});

// ==================== CHAT SESSION ENDPOINTS ====================

app.post('/api/chat/session', (req, res) => {
  try {
    const { userId, panditId } = req.body;
    if (!userId || !panditId) return res.status(400).json({ success: false, error: 'UserId and panditId are required' });

    const sessionId = `${userId}_${panditId}`;
    let session = state.chatSessions[sessionId];

    if (!session) {
      session = { id: sessionId, userId, panditId, messages: [], startTime: Date.now(), isActive: false, isStarted: false };
      state.chatSessions[sessionId] = session;
    }
    res.json({ success: true, session });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/chat/session/:sessionId', (req, res) => {
  const session = state.chatSessions[req.params.sessionId];
  if (!session) return res.status(404).json({ success: false, error: 'Session not found' });
  res.json({ success: true, session });
});

app.post('/api/chat/start', async (req, res) => {
  try {
    const { userId, panditId, sessionId } = req.body;
    if (!userId || !panditId) return res.status(400).json({ success: false, error: 'UserId and panditId are required' });

    const balance = WalletService.getBalance(userId);
    const settings = readSettings();
    const minimumBalance = settings.minimumBalance || 50.0;

    if (balance < minimumBalance) {
      return res.status(402).json({ success: false, error: 'Insufficient balance', required: minimumBalance, current: balance });
    }

    const sid = sessionId || `${userId}_${panditId}`;
    let session = state.chatSessions[sid];

    if (!session) {
      session = { id: sid, userId, panditId, messages: [], startTime: Date.now(), isActive: true, isStarted: true };
      state.chatSessions[sid] = session;
    } else {
      session.isActive = true;
      session.isStarted = true;
    }
    res.json({ success: true, session });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// CUSTOM REQUESTS API (Puja/Havan Bookings)
// ============================================================================

// User: Create custom request
app.post('/api/custom-requests', (req, res) => {
  try {
    const requests = readCustomRequests();
    const requestData = req.body;

    const newRequest = {
      id: `request_${Date.now()}`,
      requestId: generateCustomRequestId(),
      userId: req.headers['x-user-id'] || requestData.userId,
      type: requestData.type || 'puja', // puja, havan, homam, etc.
      serviceName: requestData.serviceName,
      description: requestData.description || '',
      preferredDate: requestData.preferredDate,
      preferredTime: requestData.preferredTime,
      duration: requestData.duration || 60, // minutes
      price: requestData.price || 0,
      paymentStatus: 'pending',
      paymentId: requestData.paymentId || null,
      userId: req.headers['x-user-id'] || requestData.userId || 'guest',
      userName: requestData.userName || 'Guest',
      status: 'pending',
      amount: requestData.amount || 0,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      ...requestData
    };

    // Send Email Notification
    sendEmailNotification(
      'New Custom Request! 🕉️',
      `<h3>New Puja/Havan Request</h3>
       <p><strong>Type:</strong> ${newRequest.category || 'General'}</p>
       <p><strong>Customer:</strong> ${newRequest.userName}</p>
       <p><strong>Details:</strong> ${newRequest.description || 'No details provided'}</p>
       <p><strong>Date:</strong> ${newRequest.proposedDate || 'N/A'}</p>
       <p>Login to Admin Panel to schedule this session.</p>`
    );

    requests.unshift(newRequest);
    writeCustomRequests(requests);

    io.emit('custom-requests-update', { action: 'new', request: newRequest });

    res.status(201).json({ success: true, data: newRequest });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Get their custom requests
app.get('/api/custom-requests', (req, res) => {
  try {
    const requests = readCustomRequests();
    const userId = req.headers['x-user-id'];

    let filtered = userId ? requests.filter(r => r.userId === userId) : [];
    filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Get single request
app.get('/api/custom-requests/:id', (req, res) => {
  try {
    const requests = readCustomRequests();
    const request = requests.find(r => r.id === req.params.id || r.requestId === req.params.id);
    if (!request) return res.status(404).json({ success: false, error: 'Request not found' });
    res.json({ success: true, data: request });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Cancel their request
app.put('/api/custom-requests/:id/cancel', (req, res) => {
  try {
    const requests = readCustomRequests();
    const index = requests.findIndex(r => r.id === req.params.id || r.requestId === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Request not found' });

    const request = requests[index];
    if (['completed', 'cancelled'].includes(request.status)) {
      return res.status(400).json({ success: false, error: 'Cannot cancel this request' });
    }

    requests[index] = {
      ...request,
      status: 'cancelled',
      cancellationReason: req.body.reason || 'Cancelled by user',
      cancelledAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    writeCustomRequests(requests);
    io.emit('custom-requests-update', { action: 'cancelled', request: requests[index] });
    res.json({ success: true, data: requests[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Get all custom requests
app.get('/api/admin/custom-requests', (req, res) => {
  try {
    const requests = readCustomRequests();
    const { status, type } = req.query;

    let filtered = requests;
    if (status) filtered = filtered.filter(r => r.status === status);
    if (type) filtered = filtered.filter(r => r.type === type);

    filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Update custom request
app.put('/api/admin/custom-requests/:id', (req, res) => {
  try {
    const requests = readCustomRequests();
    const index = requests.findIndex(r => r.id === req.params.id || r.requestId === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Request not found' });

    const updates = req.body;
    requests[index] = {
      ...requests[index],
      status: updates.status || requests[index].status,
      paymentStatus: updates.paymentStatus || requests[index].paymentStatus,
      price: updates.price || requests[index].price,
      notes: updates.notes || requests[index].notes,
      liveSessionId: updates.liveSessionId || requests[index].liveSessionId,
      updatedAt: new Date().toISOString()
    };

    writeCustomRequests(requests);

    // Notify user
    io.to(`user-${requests[index].userId}`).emit('custom-request-update', requests[index]);
    io.emit('custom-requests-update', { action: 'updated', request: requests[index] });

    res.json({ success: true, data: requests[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Custom requests stats
app.get('/api/admin/custom-requests/stats', (req, res) => {
  try {
    const requests = readCustomRequests();
    const stats = {
      total: requests.length,
      pending: requests.filter(r => r.status === 'pending').length,
      accepted: requests.filter(r => r.status === 'accepted').length,
      scheduled: requests.filter(r => r.status === 'scheduled').length,
      completed: requests.filter(r => r.status === 'completed').length,
      cancelled: requests.filter(r => r.status === 'cancelled').length,
      totalRevenue: requests.filter(r => r.paymentStatus === 'completed').reduce((sum, r) => sum + (r.price || 0), 0)
    };
    res.json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// LIVE SESSIONS API (For Video Call Havans)
// ============================================================================

// ==================== Razorpay Payment Endpoints ====================

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Create Order (Simulated for verification)
app.post('/api/payment/create-order', async (req, res) => {
  try {
    const { amount, currency = 'INR', receipt } = req.body;

    if (!amount) {
      return res.status(400).json({ success: false, error: 'Amount is required' });
    }

    const options = {
      amount: Math.round(amount * 100), // Convert to paise
      currency,
      receipt: receipt || `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);
    res.json({ success: true, order });
  } catch (error) {
    console.error('Razorpay Order Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Verify Payment
app.post('/api/payment/verify', async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body.toString())
      .digest('hex');

    if (expectedSignature === razorpay_signature) {
      // Payment verified!
      // In a real app, you would update the database here (e.g., mark order as paid, add wallet balance)
      console.log(`Payment Verified: ${razorpay_payment_id}`);
      res.json({ success: true, message: 'Payment verified successfully' });
    } else {
      res.status(400).json({ success: false, error: 'Invalid signature' });
    }
  } catch (error) {
    console.error('Razorpay Verification Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Create live session for a custom request
app.post('/api/admin/live-sessions', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const sessionData = req.body;

    const newSession = {
      id: `session_${Date.now()}`,
      sessionId: generateSessionId(),
      customRequestId: sessionData.customRequestId,
      userId: sessionData.userId,
      panditId: sessionData.panditId || 'admin',
      panditName: sessionData.panditName || 'Vedic Pandit',
      title: sessionData.title || 'Live Havan/Puja',
      description: sessionData.description || '',
      scheduledDate: sessionData.scheduledDate,
      scheduledTime: sessionData.scheduledTime,
      duration: sessionData.duration || 60, // minutes
      status: 'scheduled', // scheduled, live, completed, cancelled
      roomId: `room_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`,
      isLive: false,
      startedAt: null,
      endedAt: null,
      recordingUrl: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    sessions.push(newSession);
    writeLiveSessions(sessions);

    // Update the custom request with session ID
    if (sessionData.customRequestId) {
      const requests = readCustomRequests();
      const reqIndex = requests.findIndex(r => r.id === sessionData.customRequestId || r.requestId === sessionData.customRequestId);
      if (reqIndex !== -1) {
        requests[reqIndex].liveSessionId = newSession.id;
        requests[reqIndex].status = 'scheduled';
        requests[reqIndex].updatedAt = new Date().toISOString();
        writeCustomRequests(requests);

        // Notify user about scheduled session
        io.to(`user-${requests[reqIndex].userId}`).emit('session-scheduled', newSession);
      }
    }

    io.emit('live-sessions-update', { action: 'created', session: newSession });
    res.json({ success: true, data: newSession });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get all live sessions (admin)
app.get('/api/admin/live-sessions', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const { status } = req.query;

    let filtered = sessions;
    if (status) filtered = filtered.filter(s => s.status === status);

    filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Get their sessions
app.get('/api/live-sessions', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const userId = req.headers['x-user-id'];

    let filtered = userId ? sessions.filter(s => s.userId === userId) : [];
    filtered.sort((a, b) => new Date(b.scheduledDate) - new Date(a.scheduledDate));

    res.json({ success: true, data: filtered, count: filtered.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get single session
app.get('/api/live-sessions/:id', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const session = sessions.find(s => s.id === req.params.id || s.sessionId === req.params.id);
    if (!session) return res.status(404).json({ success: false, error: 'Session not found' });
    res.json({ success: true, data: session });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Start live session
app.put('/api/admin/live-sessions/:id/start', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const index = sessions.findIndex(s => s.id === req.params.id || s.sessionId === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Session not found' });

    sessions[index] = {
      ...sessions[index],
      status: 'live',
      isLive: true,
      startedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    writeLiveSessions(sessions);

    // Notify user that session is live
    io.to(`user-${sessions[index].userId}`).emit('session-live', sessions[index]);
    io.emit('live-sessions-update', { action: 'started', session: sessions[index] });

    // Send notification to all users
    io.emit('notification', {
      title: 'Live Pooja Started! 🔔',
      body: `${sessions[index].title} has started. Join now for blessings!`,
      type: 'live_pooja',
      data: { sessionId: sessions[index].id }
    });

    res.json({ success: true, data: sessions[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: End live session
app.put('/api/admin/live-sessions/:id/end', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const index = sessions.findIndex(s => s.id === req.params.id || s.sessionId === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Session not found' });

    sessions[index] = {
      ...sessions[index],
      status: 'completed',
      isLive: false,
      endedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    writeLiveSessions(sessions);

    // Update custom request to completed
    if (sessions[index].customRequestId) {
      const requests = readCustomRequests();
      const reqIndex = requests.findIndex(r => r.id === sessions[index].customRequestId);
      if (reqIndex !== -1) {
        requests[reqIndex].status = 'completed';
        requests[reqIndex].updatedAt = new Date().toISOString();
        writeCustomRequests(requests);
      }
    }

    io.to(`user-${sessions[index].userId}`).emit('session-ended', sessions[index]);
    io.emit('live-sessions-update', { action: 'ended', session: sessions[index] });

    res.json({ success: true, data: sessions[index] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Join session (get room info)
app.post('/api/live-sessions/:id/join', (req, res) => {
  try {
    const sessions = readLiveSessions();
    const session = sessions.find(s => s.id === req.params.id || s.sessionId === req.params.id);
    if (!session) return res.status(404).json({ success: false, error: 'Session not found' });

    if (session.status !== 'live') {
      return res.status(400).json({ success: false, error: 'Session is not live yet' });
    }

    // In production, this would generate a token for video call service (Agora, Twilio, etc.)
    res.json({
      success: true,
      data: {
        roomId: session.roomId,
        sessionId: session.sessionId,
        panditName: session.panditName,
        title: session.title,
        // Add video call token here when using real video service
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// BOOKINGS HISTORY API (Combined view)
// ============================================================================

app.get('/api/bookings', (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    if (!userId) return res.status(400).json({ success: false, error: 'User ID required' });

    const orders = readOrders().filter(o => o.userId === userId);
    const customRequests = readCustomRequests().filter(r => r.userId === userId);
    const liveSessions = readLiveSessions().filter(s => s.userId === userId);

    res.json({
      success: true,
      data: {
        orders: orders.slice(0, 10),
        customRequests: customRequests.slice(0, 10),
        liveSessions: liveSessions.slice(0, 10),
        counts: {
          orders: orders.length,
          customRequests: customRequests.length,
          liveSessions: liveSessions.length
        }
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// START SERVER
// ============================================================================

const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';

httpServer.listen(PORT, HOST, () => {
  console.log('');
  console.log('╔══════════════════════════════════════════════════════════════╗');
  console.log('║                 VEDIC MATE BACKEND SERVER                    ║');
  console.log('╠══════════════════════════════════════════════════════════════╣');
  console.log(`║  🚀 Server running on https://${HOST}:${PORT}                   ║`);
  console.log('║                                                              ║');
  console.log('║  📡 WebSocket: Real-time updates enabled                     ║');
  console.log('║  🛒 Orders: /api/orders, /api/admin/orders                   ║');
  console.log('║  📦 Products: /api/products, /api/admin/products             ║');
  console.log('║  💰 Wallet: /api/wallet/balance, /api/wallet/add             ║');
  console.log('║  🙏 Custom Requests: /api/custom-requests                    ║');
  console.log('║  📹 Live Sessions: /api/live-sessions                        ║');
  console.log('║  🤖 AI Chat: /api/ai/chat, /api/ai/welcome                   ║');
  console.log('║                                                              ║');
  console.log(`║  🤖 AI: ${GEMINI_API_KEY ? 'Gemini' : OPENAI_API_KEY ? 'OpenAI' : 'Fallback Mode'}                                        ║`);
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log('');
});

