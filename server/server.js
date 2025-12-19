// Vedic Mate Backend Server (Express + Socket.IO)
import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import AIService from './services/aiService.js';
import WalletService from './services/walletService.js';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "*", // In production, specify your Flutter app's origin
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json());

// In-memory demo store (replace with DB later - MongoDB/PostgreSQL)
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
      bio: 'Experienced Vedic astrologer with 15+ years of practice.',
      certifications: ['Vedic Astrology Certification', 'Jyotish Expert'],
      is_verified: true,
      is_available: true,
      status: 'active',
      totalEarnings: 125000,
    },
    // Add more pandits as needed
  ],
  bookings: [],
  transactions: [],
  wallets: [],
  payouts: [],
  live: [],
  chatSessions: {}, // { sessionId: { userId, panditId, messages, startTime, isActive } }
};

// Initialize services
const aiService = new AIService();
const walletService = new WalletService(state);

// ==================== WebSocket Real-time Updates ====================
io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);

  // Join user's room for personalized updates
  socket.on('join-user-room', (userId) => {
    socket.join(`user-${userId}`);
    console.log(`User ${userId} joined their room`);
  });

  // Handle wallet balance updates
  socket.on('request-balance', async (userId) => {
    try {
      const balance = walletService.getBalance(userId);
      socket.emit('balance-update', { userId, balance });
    } catch (error) {
      socket.emit('error', { message: error.message });
    }
  });

  // Handle chat messages
  socket.on('chat-message', async (data) => {
    try {
      const { sessionId, userId, panditId, message } = data;
      
      // Get AI response
      const history = state.chatSessions[sessionId]?.messages || [];
      const aiResponse = await aiService.sendMessage(message, history, panditId);

      // Save messages
      if (!state.chatSessions[sessionId]) {
        state.chatSessions[sessionId] = {
          userId,
          panditId,
          messages: [],
          startTime: Date.now(),
          isActive: true
        };
      }

      state.chatSessions[sessionId].messages.push(
        { isUser: true, message, timestamp: Date.now() },
        { isUser: false, message: aiResponse, timestamp: Date.now() }
      );

      // Emit response to user
      socket.emit('chat-response', {
        sessionId,
        message: aiResponse,
        timestamp: Date.now()
      });

      // Broadcast to user's room
      io.to(`user-${userId}`).emit('chat-update', {
        sessionId,
        messages: state.chatSessions[sessionId].messages
      });
    } catch (error) {
      socket.emit('error', { message: error.message });
    }
  });

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

// ==================== REST API Endpoints ====================

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    ok: true, 
    timestamp: Date.now(),
    services: {
      ai: !!aiService.geminiApiKey || !!aiService.openaiApiKey,
      wallet: true,
      websocket: true
    }
  });
});

// ==================== AI Endpoints ====================

// Get welcome message
app.post('/api/ai/welcome', async (req, res) => {
  try {
    const { panditId } = req.body;
    const message = await aiService.getWelcomeMessage(panditId);
    res.json({ success: true, message });
  } catch (error) {
    console.error('Welcome message error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Send chat message
app.post('/api/ai/chat', async (req, res) => {
  try {
    const { message, history, panditId } = req.body;
    
    if (!message || !panditId) {
      return res.status(400).json({ 
        success: false, 
        error: 'Message and panditId are required' 
      });
    }

    const response = await aiService.sendMessage(
      message,
      history || [],
      panditId
    );

    res.json({ 
      success: true, 
      response,
      timestamp: Date.now()
    });
  } catch (error) {
    console.error('AI chat error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message || 'AI service error' 
    });
  }
});

// ==================== Wallet Endpoints ====================

// Get wallet balance
app.get('/api/wallet/balance/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const balance = walletService.getBalance(userId);
    const wallet = walletService.getWallet(userId);
    
    res.json({ 
      success: true, 
      balance,
      wallet 
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Add money to wallet
app.post('/api/wallet/add', (req, res) => {
  try {
    const { userId, amount, type, description } = req.body;
    
    if (!userId || !amount) {
      return res.status(400).json({ 
        success: false, 
        error: 'UserId and amount are required' 
      });
    }

    if (amount <= 0) {
      return res.status(400).json({ 
        success: false, 
        error: 'Amount must be positive' 
      });
    }

    const result = walletService.addMoney(
      userId, 
      amount, 
      type || 'recharge',
      description
    );

    // Emit real-time update
    io.to(`user-${userId}`).emit('balance-update', {
      userId,
      balance: result.newBalance
    });

    res.json({ 
      success: true, 
      ...result 
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Deduct money from wallet
app.post('/api/wallet/deduct', (req, res) => {
  try {
    const { userId, amount, type, description } = req.body;
    
    if (!userId || !amount) {
      return res.status(400).json({ 
        success: false, 
        error: 'UserId and amount are required' 
      });
    }

    if (amount <= 0) {
      return res.status(400).json({ 
        success: false, 
        error: 'Amount must be positive' 
      });
    }

    const result = walletService.deductMoney(
      userId, 
      amount, 
      type || 'service',
      description
    );

    // Emit real-time update
    io.to(`user-${userId}`).emit('balance-update', {
      userId,
      balance: result.newBalance
    });

    res.json({ 
      success: true, 
      ...result 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Get transaction history
app.get('/api/wallet/transactions/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    const transactions = walletService.getTransactions(userId, limit);
    
    res.json({ 
      success: true, 
      transactions 
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== Chat Session Endpoints ====================

// Get or create chat session
app.post('/api/chat/session', (req, res) => {
  try {
    const { userId, panditId } = req.body;
    
    if (!userId || !panditId) {
      return res.status(400).json({ 
        success: false, 
        error: 'UserId and panditId are required' 
      });
    }

    // Find existing session or create new
    const sessionId = `${userId}_${panditId}`;
    let session = state.chatSessions[sessionId];

    if (!session) {
      session = {
        id: sessionId,
        userId,
        panditId,
        messages: [],
        startTime: Date.now(),
        isActive: false,
        isStarted: false
      };
      state.chatSessions[sessionId] = session;
    }

    res.json({ success: true, session });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get chat session messages
app.get('/api/chat/session/:sessionId', (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = state.chatSessions[sessionId];
    
    if (!session) {
      return res.status(404).json({ 
        success: false, 
        error: 'Session not found' 
      });
    }

    res.json({ success: true, session });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Start chat session (with wallet check)
app.post('/api/chat/start', async (req, res) => {
  try {
    const { userId, panditId, sessionId } = req.body;
    
    if (!userId || !panditId) {
      return res.status(400).json({ 
        success: false, 
        error: 'UserId and panditId are required' 
      });
    }

    // Check wallet balance (minimum ₹50)
    const balance = walletService.getBalance(userId);
    const minimumBalance = 50.0;

    if (balance < minimumBalance) {
      return res.status(402).json({ 
        success: false, 
        error: 'Insufficient balance',
        required: minimumBalance,
        current: balance
      });
    }

    // Get or create session
    const sid = sessionId || `${userId}_${panditId}`;
    let session = state.chatSessions[sid];

    if (!session) {
      session = {
        id: sid,
        userId,
        panditId,
        messages: [],
        startTime: Date.now(),
        isActive: true,
        isStarted: true
      };
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

// ==================== Settings Endpoints ====================

app.get('/api/settings', (req, res) => {
  res.json({ 
    platformFeePercent: state.platformFeePercent,
    minimumBalance: 50.0,
    chatRatePerMinute: 25.0
  });
});

app.post('/api/settings', (req, res) => {
  const { platformFeePercent } = req.body;
  if (typeof platformFeePercent === 'number') {
    state.platformFeePercent = platformFeePercent;
  }
  res.json({ ok: true });
});

// ==================== Pandits Endpoints ====================

app.get('/api/pandits', (req, res) => res.json(state.pandits));

app.post('/api/pandits', (req, res) => {
  const pandit = { 
    id: String(Date.now()), 
    status: 'pending', 
    rating: 0, 
    totalEarnings: 0, 
    ...req.body 
  };
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

app.post('/api/pandits/:id/block', (req, res) => {
  const { id } = req.params;
  const p = state.pandits.find(p => p.id === id);
  if (!p) return res.status(404).json({ error: 'Not found' });
  p.status = 'blocked';
  res.json({ ok: true });
});

// ==================== Other Endpoints ====================

app.get('/api/transactions', (req, res) => res.json(state.transactions));

app.get('/api/wallets', (req, res) => res.json(state.wallets));

app.get('/api/payouts', (req, res) => res.json(state.payouts));

app.get('/api/live', (req, res) => res.json(state.live));

// ==================== Start Server ====================

const PORT = process.env.PORT || 4000;
const HOST = process.env.HOST || '0.0.0.0';

httpServer.listen(PORT, HOST, () => {
  console.log(`🚀 Vedic Mate server running on ${HOST}:${PORT}`);
  console.log(`📡 WebSocket server ready for real-time updates`);
  console.log(`🤖 AI Service: ${aiService.geminiApiKey ? 'Gemini' : aiService.openaiApiKey ? 'OpenAI' : 'Fallback'}`);
});
