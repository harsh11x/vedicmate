// ============================================================================
// Vedic Mate - Complete Backend Server (All-in-One)
// Express + Socket.IO with Orders, Products, Wallet, and AI Services
// ============================================================================

import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http'; // Changing to HTTP for local dev
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
import os from 'os';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load Certificates (Ignored for HTTP mode)
const httpsOptions = {};

const app = express();
const httpServer = createServer(app); // Using HTTP for local dev compatibility

const io = new Server(httpServer, {
  cors: {
    origin: ["http://13.60.233.237:3000", "http://localhost:3000", "https://localhost:3000", "https://13.60.233.237:3000"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true
  }
});

app.use(cors({
  origin: ["http://13.60.233.237:3000", "http://localhost:3000", "https://localhost:3000", "https://13.60.233.237:3000"],
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// ============================================================================
// RATE LIMITING
// ============================================================================

// General API rate limit: 100 requests per 15 minutes per IP
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { success: false, error: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict rate limit for wallet endpoints (prevent abuse)
const walletLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: { success: false, error: 'Too many wallet requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// AI chat rate limit: 20 requests per minute per IP
const aiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20,
  message: { success: false, error: 'Too many AI requests, please slow down.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Admin endpoints rate limit: 60 requests per minute
const adminLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  message: { success: false, error: 'Too many admin requests.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Apply rate limiters to routes
app.use('/api/', apiLimiter);
app.use('/api/wallet/', walletLimiter);
app.use('/api/ai/', aiLimiter);
app.use('/api/admin/', adminLimiter);

// ============================================================================
// FILE STORAGE SETUP
// ============================================================================

// Serve static assets (images)
app.use('/assets', express.static(path.join(__dirname, 'assets')));

// Reels: dedicated folder - videos + metadata (admin uploads here, app fetches from here)
const REELS_DIR = path.join(__dirname, 'reels');
const REELS_VIDEOS_DIR = path.join(REELS_DIR, 'videos');
app.use('/reels/videos', express.static(REELS_VIDEOS_DIR));

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
// LOCAL AI SERVICE (Inline)
// ============================================================================

const LocalAIService = {
  config: {
    api_base_url: "http://localhost:1234/v1", // Default: LM Studio local. Override via ai_engine/model_config.json
    model_name: "qwen2.5-1.5b-instruct",
    temperature: 0.7,
    max_tokens: 500
  },
  personalities: { "default": "You are a Vedic Pandit." },
  defaultSystemPrompt: "You are a helpful assistant.",
  history: {},

  loadConfig() {
    try {
      const configPath = path.join(__dirname, '..', 'ai_engine', 'model_config.json');
      if (fs.existsSync(configPath)) {
        this.config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      }
    } catch (e) {
      console.error('Error loading AI config:', e);
    }
  },

  loadPersonalities() {
    try {
      const promptPath = path.join(__dirname, '..', 'ai_engine', 'personalities.json');
      if (fs.existsSync(promptPath)) {
        this.personalities = JSON.parse(fs.readFileSync(promptPath, 'utf8'));
      }
    } catch (e) {
      console.error('Error loading Personalities:', e);
    }
  },

  async generateResponse(userId, userMessage, panditId = 'default', clientHistory = [], targetLanguage = 'en', userProfile = null) {
    try {
      // Language Map
      const languageMap = {
        'en': 'English', 'hi': 'Hindi', 'mr': 'Marathi', 'gu': 'Gujarati',
        'bn': 'Bengali', 'te': 'Telugu', 'ta': 'Tamil', 'kn': 'Kannada',
        'ml': 'Malayalam', 'pa': 'Punjabi', 'or': 'Odia', 'as': 'Assamese',
        'ur': 'Urdu', 'ne': 'Nepali', 'si': 'Sindhi', 'kok': 'Konkani',
        'mni': 'Manipuri', 'doi': 'Dogri', 'brx': 'Bodo', 'sat': 'Santali',
        'mai': 'Maithili', 'sa': 'Sanskrit', 'ks': 'Kashmiri'
      };
      const langName = languageMap[targetLanguage] || 'English';
      console.log(`[LocalAI] Target Language: ${targetLanguage} -> ${langName}`);

      // Select Personality
      let systemPrompt = this.personalities[panditId] || this.personalities['default'] || this.defaultSystemPrompt;

      // Inject User Profile Context
      if (userProfile) {
        let contextStr = `\n\nUSER CONTEXT:\nName: ${userProfile.name || 'User'}`;

        // Add Birth Details if available
        const bd = userProfile.birth_details || userProfile.birthDetails;
        if (bd) {
          const dob = bd.dateOfBirth || bd.date_of_birth;
          const tob = bd.timeOfBirth || bd.time_of_birth;
          const pob = bd.placeOfBirth || bd.place_of_birth;

          let placeName = pob;
          if (typeof pob === 'object' && pob !== null) {
            placeName = pob.name || pob.city || pob.description || JSON.stringify(pob);
          }

          if (dob && tob && placeName) {
            contextStr += `\n\n[IMPORTANT USER DATA - USE THIS FOR KUNDLI GENERATION]
Birth Date: ${dob}
Birth Time: ${tob}
Birth Place: ${placeName}
(You already have this information. DO NOT ask the user for these details again. Proceed directly to the analysis.)`;
          }
        }

        // Add Numerology if available
        const num = userProfile.numerology;
        if (num) {
          contextStr += `\nNumerology: Mulank (Life Path): ${num.calculatedNumber || 'Unknown'}`;
          if (num.bhagyaank) contextStr += `, Bhagyaank (Destiny): ${num.bhagyaank}`;
        }

        systemPrompt += contextStr;
        console.log('[LocalAI] Injected User Profile Context');
      }

      // Inject Fluency/Voice Instructions
      systemPrompt += `\n\nVOICE GUIDELINES:
            - Be super friendly, warm, and casual. Talk like a caring elder brother or a best friend.
            - Avoid stiff, robotic, or overly professional language. Use simple words.
            - You can use emojis occasionally to make it feel alive 🌟.
            - Speak naturally, like a real human chatting on WhatsApp.
            - Don't lecture. Keep it conversational and engaging.
            - If the user starts with "Hi" or "Hello", just say "Hey! How are you doing?" or similar. No need for long "Namaste" every time.`;

      // Inject Language Instruction (Last for highest priority)
      systemPrompt += `\n\nCRITICAL: You MUST reply ONLY in ${langName}. Do not use English unless the user explicitly asks. Translate your thoughts to ${langName} if needed.`;

      // Enforce language in User Message for smaller models
      const enforcedUserMessage = `[INSTRUCTION: Reply in ${langName} only] ${userMessage}`;

      // Build context
      const messages = [
        { role: "system", content: systemPrompt }
      ];

      // Add history
      if (clientHistory && clientHistory.length > 0) {
        const formattedHistory = clientHistory.map(msg => ({
          role: (msg.isUser === 'true' || msg.isUser === true) ? "user" : "assistant",
          content: msg.message
        }));
        messages.push(...formattedHistory.slice(-15));
      } else if (this.history[userId]) {
        const recentHistory = this.history[userId].slice(-10);
        messages.push(...recentHistory);
      }

      // Add current message
      messages.push({ role: "user", content: enforcedUserMessage });

      console.log(`[LocalAI] Sending request to ${this.config.api_base_url} for Pandit: ${panditId}...`);

      const response = await axios.post(`${this.config.api_base_url}/chat/completions`, {
        model: this.config.model_name,
        messages: messages,
        temperature: this.config.temperature,
        max_tokens: this.config.max_tokens,
        stream: false
      });

      const aiMessage = response.data.choices[0].message.content;

      // Update history
      if (!this.history[userId]) this.history[userId] = [];
      this.history[userId].push({ role: "user", content: userMessage });
      this.history[userId].push({ role: "assistant", content: aiMessage });

      return aiMessage;

    } catch (error) {
      console.error('Local AI Error Details:', error.message);
      if (error.response) {
        console.error('Local AI Response Error:', error.response.status, error.response.data);
      }

      if (error.code === 'ECONNREFUSED') {
        return "I apologize, but my spiritual connection (local server) seems to be offline. Please ensure LM Studio is running on Port 1234.";
      }
      return `I sensed a disturbance in the cosmic energy. (Error: ${error.message})`;
    }
  },

  clearHistory(userId) {
    if (this.history[userId]) {
      delete this.history[userId];
    }
  }
};

// Initialize Local AI Config
LocalAIService.loadConfig();
LocalAIService.loadPersonalities();

// ============================================================================
// AI SERVICE (Inline)
// ============================================================================

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
if (!process.env.GEMINI_API_KEY) {
  console.warn('⚠️  GEMINI_API_KEY not set in environment. AI features may not work.');
}
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

  async sendMessage(message, history, panditId, userId = 'guest', targetLanguage = 'en', userProfile = null) {
    try {
      if (process.env.USE_LOCAL_AI === 'true') {
        return await LocalAIService.generateResponse(userId, message, panditId, history, targetLanguage, userProfile);
      }
      if (GEMINI_API_KEY && GEMINI_API_KEY !== 'YOUR_GEMINI_API_KEY_HERE') {
        return await this.sendGeminiMessage(message, history, panditId);
      }
      if (OPENAI_API_KEY && OPENAI_API_KEY !== 'YOUR_OPENAI_API_KEY_HERE') {
        return await this.sendOpenAIMessage(message, history, panditId);
      }

      // Fallback to Local AI if no keys are configured
      console.log('No external AI keys found. Attempting to use Local AI Service (LM Studio)...');
      return await LocalAIService.generateResponse(userId, message, panditId, history, targetLanguage, userProfile);
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
    const room = io.sockets.adapter.rooms.get('live-pooja-room');
    const viewers = room ? room.size : 0;


    // Broadcast updates
    io.to('live-pooja-room').emit('viewer-update', { count: Math.max(0, viewers - 1) });

    // Notify others (Signaling for WebRTC)
    // IMPORTANT: Broadcast to everyone ELSE in the room
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
    try {
      // 1. Deduct Money from Wallet
      // We assume data.senderId is passed along with senderName; 
      // if not, we must rely on socket auth or pass userId from client
      // Looking at `live_pooja_screen.dart`, it only sends `senderName`. 
      // WE NEED USER ID. 
      // Fortunately earlier in `join-pooja`, we might have tracked it? 
      // ACTUALLY: The mobile app code emits:
      // 'giftName', 'giftIcon', 'senderName', 'amount'
      // It DOES NOT send userId. This is a problem.

      // FIX: We need to trust the socket knows the user? 
      // Or safer: Update mobile app to send clientId/userId in the payload.
      // 
      // For now, I'll update the server to EXPECT `userId` in `data`.
      // If it fails, we log it. I will ALSO need to update Mobile App.

      if (!data.userId) {
        throw new Error('User ID missing for gift transaction');
      }

      WalletService.deductMoney(
        data.userId,
        data.amount,
        'gift',
        `Sent gift: ${data.giftName}`
      );

      // 2. Broadcast ONLY if deduction succeeded
      io.to('live-pooja-room').emit('gift-received', {
        ...data,
        timestamp: Date.now()
      });

      console.log(`🎁 Gift: ${data.senderName} sent ${data.giftName} (₹${data.amount})`);

      // 3. Notify Sender of new balance
      const newBalance = WalletService.getBalance(data.userId);
      socket.emit('wallet-update', { balance: newBalance });

    } catch (error) {
      console.error(`❌ Gift Failed: ${error.message}`);
      socket.emit('gift-error', { message: error.message });
    }
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

app.post('/api/ai-pandit/chat', async (req, res) => {
  try {
    const { message, history, panditId, userId, targetLanguage, userProfile } = req.body;
    if (!message || !panditId) {
      return res.status(400).json({ success: false, error: 'Message and panditId are required' });
    }
    const response = await AIService.sendMessage(
      message,
      history || [],
      panditId,
      userId,
      targetLanguage,
      userProfile
    );
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

    const resolvedUserId = req.headers['x-user-id'] || requestData.userId || 'guest';
    const newRequest = {
      id: `request_${Date.now()}`,
      requestId: generateCustomRequestId(),
      userId: resolvedUserId,
      type: requestData.type || 'puja', // puja, havan, homam, etc.
      serviceName: requestData.serviceName,
      description: requestData.description || '',
      preferredDate: requestData.preferredDate,
      preferredTime: requestData.preferredTime,
      duration: requestData.duration || 60, // minutes
      price: requestData.price || 0,
      paymentStatus: 'pending',
      paymentId: requestData.paymentId || null,
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
    const index = requests.findIndex(r =>
      r.id === req.params.id || r.requestId === req.params.id || r.orderId === req.params.id
    );
    if (index === -1) return res.status(404).json({ success: false, error: 'Request not found' });

    const updates = req.body;
    const adminNote = updates.notes || updates.adminNotes || requests[index].adminNotes || requests[index].notes;
    requests[index] = {
      ...requests[index],
      status: updates.status || requests[index].status,
      paymentStatus: updates.paymentStatus || requests[index].paymentStatus,
      price: updates.price ?? requests[index].price,
      notes: adminNote,
      adminNotes: adminNote,
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

// ==================== Local AI Integration ====================
import localAIService from './services/local_ai_service.js';

app.post('/api/ai-pandit/chat', async (req, res) => {
  try {
    const { userId, message, panditId, history, targetLanguage, userProfile } = req.body; // Extract userProfile
    console.log(`[API] Received Chat Request: User=${userId}, Lang=${targetLanguage}, Msg=${message.substring(0, 20)}...`);

    if (!userId || !message) {
      return res.status(400).json({ success: false, error: 'UserId and message required' });
    }

    // Delegate to Qwen 2.5 via LM Studio, passing history and profile
    const response = await localAIService.generateResponse(userId, message, panditId, history, targetLanguage, userProfile);

    res.json({ success: true, data: response });
  } catch (error) {
    console.error('AI Pandit Endpoint Error:', error);
    res.status(500).json({ success: false, error: 'Failed to consult the digital stars.' });
  }
});

app.post('/api/ai-pandit/clear-history', (req, res) => {
  try {
    const { userId } = req.body;
    localAIService.clearHistory(userId);
    res.json({ success: true, message: 'History cleared' });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// ==================== USER PROFILE & NUMEROLOGY ENDPOINTS ====================

// File paths for user profiles
const USER_PROFILES_FILE = path.join(DATA_DIR, 'user_profiles.json');

// Initialize user profiles file
if (!fs.existsSync(USER_PROFILES_FILE)) {
  fs.writeFileSync(USER_PROFILES_FILE, JSON.stringify([], null, 2));
  console.log('📄 Created user_profiles.json');
}

const readUserProfiles = () => readJsonFile(USER_PROFILES_FILE, []);
const writeUserProfiles = (data) => writeJsonFile(USER_PROFILES_FILE, data);

// Numerology calculation helper
const calculateNumerologyNumber = (input) => {
  let sum = 0;
  const digits = input.toString().replace(/\D/g, ''); // Remove non-digits

  for (const digit of digits) {
    sum += parseInt(digit);
  }

  // Reduce to single digit (except master numbers 11, 22, 33)
  while (sum > 9 && sum !== 11 && sum !== 22 && sum !== 33) {
    sum = sum.toString().split('').reduce((a, b) => parseInt(a) + parseInt(b), 0);
  }

  return sum;
};

// GET user profile
app.get('/api/user/profile/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const profiles = readUserProfiles();
    const profile = profiles.find(p => p.userId === userId);

    if (!profile) {
      return res.json({
        success: true,
        data: null,
        message: 'Profile not found'
      });
    }

    res.json({ success: true, data: profile });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST/UPDATE user profile
app.post('/api/user/profile', (req, res) => {
  try {
    const { userId, name, dateOfBirth, timeOfBirth, placeOfBirth, latitude, longitude } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'UserId is required' });
    }

    const profiles = readUserProfiles();
    let profile = profiles.find(p => p.userId === userId);

    if (profile) {
      // Update existing profile
      if (name) profile.name = name;
      if (dateOfBirth) profile.dateOfBirth = dateOfBirth;
      if (timeOfBirth) profile.timeOfBirth = timeOfBirth;
      if (placeOfBirth) profile.placeOfBirth = placeOfBirth;
      if (latitude) profile.latitude = latitude;
      if (longitude) profile.longitude = longitude;
      profile.updatedAt = new Date().toISOString();
    } else {
      // Create new profile
      profile = {
        userId,
        name: name || '',
        dateOfBirth: dateOfBirth || null,
        timeOfBirth: timeOfBirth || null,
        placeOfBirth: placeOfBirth || null,
        latitude: latitude || null,
        longitude: longitude || null,
        numerologyPreference: null,
        numerologyNumber: null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      profiles.push(profile);
    }

    writeUserProfiles(profiles);
    res.json({ success: true, data: profile });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST numerology preferences
app.post('/api/user/numerology', (req, res) => {
  try {
    const { userId, inputType, dayOfBirth, fullDateOfBirth } = req.body;

    if (!userId || !inputType) {
      return res.status(400).json({
        success: false,
        error: 'UserId and inputType are required'
      });
    }

    const profiles = readUserProfiles();
    let profile = profiles.find(p => p.userId === userId);

    if (!profile) {
      // Create new profile if doesn't exist
      profile = {
        userId,
        name: '',
        dateOfBirth: null,
        timeOfBirth: null,
        placeOfBirth: null,
        latitude: null,
        longitude: null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      profiles.push(profile);
    }

    // Calculate numerology number based on input type
    let numerologyNumber;
    if (inputType === 'day_only' && dayOfBirth) {
      numerologyNumber = calculateNumerologyNumber(dayOfBirth);
      profile.numerologyPreference = 'day_only';
      profile.numerologyDayOfBirth = dayOfBirth;
    } else if (inputType === 'full_date' && fullDateOfBirth) {
      // For full date, use DDMMYYYY format
      const date = new Date(fullDateOfBirth);
      const day = date.getDate();
      const month = date.getMonth() + 1;
      const year = date.getFullYear();
      const fullNumber = `${day}${month}${year}`;
      numerologyNumber = calculateNumerologyNumber(fullNumber);
      profile.numerologyPreference = 'full_date';
      profile.numerologyFullDate = fullDateOfBirth;

      // Also update dateOfBirth if not set
      if (!profile.dateOfBirth) {
        profile.dateOfBirth = fullDateOfBirth;
      }
    } else {
      return res.status(400).json({
        success: false,
        error: 'Invalid input type or missing date'
      });
    }

    profile.numerologyNumber = numerologyNumber;
    profile.updatedAt = new Date().toISOString();

    writeUserProfiles(profiles);

    res.json({
      success: true,
      data: {
        numerologyNumber,
        inputType,
        profile
      }
    });
  } catch (error) {
    console.error('Error saving numerology:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET profile completeness check
app.get('/api/user/profile/check/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const profiles = readUserProfiles();
    const profile = profiles.find(p => p.userId === userId);

    const missingFields = [];

    if (!profile) {
      return res.json({
        success: true,
        isComplete: false,
        missingFields: ['All profile data'],
        message: 'Please complete your profile for personalized predictions'
      });
    }

    if (!profile.name) missingFields.push('Name');
    if (!profile.dateOfBirth) missingFields.push('Date of Birth');
    if (!profile.timeOfBirth) missingFields.push('Time of Birth');
    if (!profile.placeOfBirth) missingFields.push('Place of Birth');
    if (!profile.numerologyPreference) missingFields.push('Numerology Preference');

    const isComplete = missingFields.length === 0;

    res.json({
      success: true,
      isComplete,
      missingFields,
      message: isComplete
        ? 'Profile is complete'
        : `Missing: ${missingFields.join(', ')}`
    });
  } catch (error) {
    console.error('Error checking profile:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Enhanced AI chat endpoint with user profile context
app.post('/api/ai-pandit/chat-enhanced', async (req, res) => {
  try {
    const { userId, message, panditId, history, targetLanguage } = req.body;

    if (!userId || !message) {
      return res.status(400).json({
        success: false,
        error: 'UserId and message required'
      });
    }

    // Fetch user profile
    const profiles = readUserProfiles();
    const profile = profiles.find(p => p.userId === userId);

    // Build enhanced context
    let userContext = '';
    if (profile) {
      userContext = '\n\n[USER PROFILE CONTEXT]\n';
      if (profile.name) userContext += `Name: ${profile.name}\n`;
      if (profile.dateOfBirth) {
        const dob = new Date(profile.dateOfBirth);
        userContext += `Date of Birth: ${dob.toLocaleDateString('en-IN')}\n`;
      }
      if (profile.timeOfBirth) userContext += `Time of Birth: ${profile.timeOfBirth}\n`;
      if (profile.placeOfBirth) userContext += `Place of Birth: ${profile.placeOfBirth}\n`;
      if (profile.numerologyNumber) {
        userContext += `Numerology Number (${profile.numerologyPreference === 'day_only' ? 'Mulank' : 'Bhagyaank'}): ${profile.numerologyNumber}\n`;
      }
      userContext += '[END PROFILE CONTEXT]\n\n';
    }

    // Add context to message for AI
    const enhancedMessage = userContext + message;

    // Call local AI service with enhanced context
    const response = await localAIService.generateResponse(
      userId,
      enhancedMessage,
      panditId,
      history,
      targetLanguage
    );

    res.json({ success: true, data: response });
  } catch (error) {
    console.error('Enhanced AI Chat Error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate response'
    });
  }
});

// ==================== Razorpay Payment Endpoints ====================

// Initialize Razorpay
let razorpay = null;
try {
  if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
    console.log('✅ Razorpay initialized');
  } else {
    console.warn('⚠️ Razorpay credentials missing. Payment features will be disabled.');
  }
} catch (error) {
  console.warn('⚠️ Failed to initialize Razorpay:', error.message);
}

// Create Order (Simulated for verification)
app.post('/api/payment/create-order', async (req, res) => {
  try {
    const {
      amount,
      currency = 'INR',
      receipt,
      userId,
      purpose = 'payment',
      description = '',
      metadata = {}
    } = req.body;

    if (!amount) {
      return res.status(400).json({ success: false, error: 'Amount is required' });
    }

    const options = {
      amount: Math.round(amount * 100), // Convert to paise
      currency,
      receipt: receipt || `receipt_${Date.now()}`,
      notes: {
        userId: userId || '',
        purpose,
        description,
        ...metadata
      }
    };

    if (!razorpay) {
      throw new Error('Razorpay is not configured on the server');
    }

    const order = await razorpay.orders.create(options);
    res.json({
      success: true,
      order,
      keyId: process.env.RAZORPAY_KEY_ID
    });
  } catch (error) {
    console.error('Razorpay Order Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Verify Payment
app.post('/api/payment/verify', async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      userId,
      amount,
      purpose
    } = req.body;

    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body.toString())
      .digest('hex');

    if (expectedSignature === razorpay_signature) {
      console.log(`Payment Verified: ${razorpay_payment_id}`);
      let walletResult = null;
      if (purpose === 'wallet_recharge' && userId && amount) {
        walletResult = WalletService.addMoney(
          userId,
          Number(amount),
          'recharge',
          `Wallet recharge via Razorpay (${razorpay_payment_id})`
        );
        io.to(`user-${userId}`).emit('balance-update', {
          userId,
          balance: walletResult.newBalance
        });
      }

      res.json({
        success: true,
        message: 'Payment verified successfully',
        wallet: walletResult
      });
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

// Public: Get currently ACTIVE live session (for Broadcast/Live Pooja)
app.get('/api/live-sessions/active', (req, res) => {
  try {
    const sessions = readLiveSessions();
    // Find the first session that is 'live'
    // Sort by startedAt desc (newest first)
    const activeSession = sessions
      .filter(s => s.status === 'live' && s.isLive === true)
      .sort((a, b) => new Date(b.startedAt) - new Date(a.startedAt))[0];

    if (!activeSession) {
      return res.json({ success: true, active: false, message: 'No active session' });
    }

    res.json({ success: true, active: true, data: activeSession });
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

    // Notify ALL users in live-pooja-room that session is live
    console.log(`🎥 Emitting 'session-live' to 'live-pooja-room' for session: ${sessions[index].id}`);
    const roomSize = io.sockets.adapter.rooms.get('live-pooja-room')?.size || 0;
    console.log(`👥 Current users in live-pooja-room: ${roomSize}`);
    io.to('live-pooja-room').emit('session-live', sessions[index]);
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

    // Notify ALL users in live-pooja-room that session ended
    io.to('live-pooja-room').emit('session-ended', sessions[index]);
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
// REELS FEATURE API
// ============================================================================
// All reels data lives in server/reels/ - videos in reels/videos/, metadata in reels/reels.json

const REELS_FILE = path.join(REELS_DIR, 'reels.json');

if (!fs.existsSync(REELS_DIR)) {
  fs.mkdirSync(REELS_DIR, { recursive: true });
  console.log('📁 Created reels directory');
}
if (!fs.existsSync(REELS_VIDEOS_DIR)) {
  fs.mkdirSync(REELS_VIDEOS_DIR, { recursive: true });
  console.log('📁 Created reels/videos directory');
}
const LEGACY_VIDEOS_DIR = path.join(__dirname, 'assets', 'videos', 'reels');
if (!fs.existsSync(LEGACY_VIDEOS_DIR)) {
  fs.mkdirSync(LEGACY_VIDEOS_DIR, { recursive: true });
}
if (!fs.existsSync(REELS_FILE)) {
  fs.writeFileSync(REELS_FILE, JSON.stringify([], null, 2));
  console.log('📄 Created reels/reels.json');
}

const readReels = () => readJsonFile(REELS_FILE, []);
const writeReels = (data) => writeJsonFile(REELS_FILE, data);

// API: Get Reels Feed (Public/User)
app.get('/api/reels', (req, res) => {
  try {
    const reels = readReels();
    // Sort by newest first
    reels.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json({ success: true, data: reels });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Get All Reels (Detailed)
app.get('/api/admin/reels', (req, res) => {
  try {
    const reels = readReels();
    // Sort by newest first
    reels.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json({ success: true, data: reels });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Upload Reel (Metadata)
app.post('/api/admin/reels', (req, res) => {
  try {
    const reels = readReels();
    const newReel = {
      id: `reel_${Date.now()}`,
      videoUrl: req.body.videoUrl, // URL from upload endpoint
      thumbnailUrl: req.body.thumbnailUrl, // Optional URL
      description: req.body.description || '',
      hashtags: req.body.hashtags || [],
      likes: [], // Array of { userId, email, name, timestamp }
      comments: [], // Array of { id, userId, email, name, text, timestamp }
      shares: 0,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    reels.unshift(newReel);
    writeReels(reels);

    io.emit('reels-update', { action: 'new', reel: newReel });
    res.status(201).json({ success: true, data: newReel });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Delete Reel (removes metadata + video file from reels/videos/)
app.delete('/api/admin/reels/:id', (req, res) => {
  try {
    let reels = readReels();
    const index = reels.findIndex(r => r.id === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Reel not found' });

    const deleted = reels[index];
    const videoUrl = deleted.videoUrl || '';
    const filename = videoUrl.includes('/') ? videoUrl.split('/').pop() : videoUrl;
    if (filename && /^reel_.*\.(mp4|mov|webm|m4v)$/i.test(filename)) {
      const videoPath = path.join(REELS_VIDEOS_DIR, filename);
      if (fs.existsSync(videoPath)) {
        fs.unlinkSync(videoPath);
        console.log('[Reels] Deleted video:', filename);
      }
    }

    reels = reels.filter(r => r.id !== req.params.id);
    writeReels(reels);

    io.emit('reels-update', { action: 'delete', reelId: req.params.id });
    res.json({ success: true, message: 'Reel deleted', data: deleted });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Like/Unlike Reel
app.post('/api/reels/:id/like', (req, res) => {
  try {
    const { userId, email, name } = req.body; // User info required
    if (!userId) return res.status(400).json({ success: false, error: 'UserId required' });

    const reels = readReels();
    const index = reels.findIndex(r => r.id === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Reel not found' });

    const reel = reels[index];
    const likeIndex = reel.likes.findIndex(l => l.userId === userId);

    if (likeIndex === -1) {
      // Like
      reel.likes.push({ userId, email, name, timestamp: new Date().toISOString() });
    } else {
      // Unlike
      reel.likes.splice(likeIndex, 1);
    }

    reels[index] = reel;
    writeReels(reels);

    // Notify via socket for real-time like count updates
    io.emit('reel-interaction', { reelId: reel.id, type: 'like', likesCount: reel.likes.length, userId });

    res.json({ success: true, liked: likeIndex === -1, likesCount: reel.likes.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Admin: Delete comment on reel
app.delete('/api/admin/reels/:reelId/comments/:commentId', (req, res) => {
  try {
    const { reelId, commentId } = req.params;
    const reels = readReels();
    const index = reels.findIndex(r => r.id === reelId);
    if (index === -1) return res.status(404).json({ success: false, error: 'Reel not found' });

    const comments = reels[index].comments || [];
    const commentIndex = comments.findIndex(c => c.id === commentId);
    if (commentIndex === -1) return res.status(404).json({ success: false, error: 'Comment not found' });

    comments.splice(commentIndex, 1);
    reels[index].comments = comments;
    writeReels(reels);

    io.emit('reel-interaction', { reelId, type: 'comment-deleted', commentsCount: comments.length });
    res.json({ success: true, message: 'Comment removed', data: { comments: comments } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// User: Comment on Reel
app.post('/api/reels/:id/comment', (req, res) => {
  try {
    const { userId, email, name, text } = req.body;
    if (!userId || !text) return res.status(400).json({ success: false, error: 'UserId and text required' });

    const reels = readReels();
    const index = reels.findIndex(r => r.id === req.params.id);
    if (index === -1) return res.status(404).json({ success: false, error: 'Reel not found' });

    const newComment = {
      id: `c_${Date.now()}`,
      userId,
      email,
      name,
      text,
      timestamp: new Date().toISOString()
    };

    reels[index].comments.push(newComment);
    writeReels(reels);

    io.emit('reel-interaction', { reelId: reels[index].id, type: 'comment', commentsCount: reels[index].comments.length, comment: newComment });
    res.json({ success: true, data: newComment });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Map video extension to Content-Type for proper playback
const VIDEO_MIME = {
  mp4: 'video/mp4', mov: 'video/quicktime', qt: 'video/quicktime', quicktime: 'video/quicktime',
  webm: 'video/webm', m4v: 'video/x-m4v', '3gp': 'video/3gpp', avi: 'video/x-msvideo',
  mkv: 'video/x-matroska', ogv: 'video/ogg', wmv: 'video/x-ms-wmv'
};

// Video proxy - serves from reels/videos/
app.get('/api/assets/video', (req, res) => {
  try {
    const pathParam = req.query.path;
    if (!pathParam || typeof pathParam !== 'string') {
      return res.status(400).json({ success: false, error: 'Path required' });
    }
    const fileName = path.basename(pathParam.replace(/\.\./g, '').replace(/^\//, ''));
    const filePath = path.join(REELS_VIDEOS_DIR, fileName);
    if (!fs.existsSync(filePath)) {
      console.error('[Video] Not found:', filePath);
      return res.status(404).json({ success: false, error: 'Video not found' });
    }
    const ext = path.extname(fileName).slice(1).toLowerCase();
    const contentType = VIDEO_MIME[ext] || 'video/mp4';
    res.setHeader('Content-Type', contentType);
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Cache-Control', 'public, max-age=86400');
    res.sendFile(filePath, { acceptRanges: true });
  } catch (error) {
    console.error('[Video] Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Video streaming - serves from reels/videos/ or assets/videos/reels/ (fallback)
const ALLOWED_VIDEO_EXT = /\.(mp4|mov|webm|m4v|3gp|avi|mkv|ogv|wmv|qt|quicktime)$/i;
app.get('/api/reels/video/:filename', (req, res) => {
  try {
    const filename = path.basename(req.params.filename).replace(/\.\./g, '').replace(/[^a-zA-Z0-9_.-]/g, '');
    if (!ALLOWED_VIDEO_EXT.test(filename) || filename.length < 5) {
      return res.status(403).json({ success: false, error: 'Invalid filename' });
    }
    let filePath = path.join(REELS_VIDEOS_DIR, filename);
    if (!fs.existsSync(filePath)) {
      filePath = path.join(__dirname, 'assets', 'videos', 'reels', filename);
    }
    if (!fs.existsSync(filePath)) {
      console.error('[Reels Video] Not found:', filename, 'checked:', REELS_VIDEOS_DIR, 'and assets/videos/reels');
      return res.status(404).json({ success: false, error: 'Video not found' });
    }
    const ext = path.extname(filename).slice(1).toLowerCase();
    const contentType = VIDEO_MIME[ext] || 'video/mp4';
    res.setHeader('Content-Type', contentType);
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Cache-Control', 'public, max-age=86400');
    res.sendFile(filePath, { acceptRanges: true });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Video Upload Endpoint
app.post('/api/admin/upload-video', (req, res) => {
  try {
    const { video, name } = req.body; // video is base64 string
    if (!video) return res.status(400).json({ success: false, error: 'No video data provided' });

    const matches = video.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
    if (!matches || matches.length !== 3) {
      return res.status(400).json({ success: false, error: 'Invalid base64 video string' });
    }

    const type = matches[1];
    const buffer = Buffer.from(matches[2], 'base64');
    const mimeSub = (type.split('/')[1] || 'mp4').toLowerCase();
    // Map MIME subtype to standard file extension
    const extMap = { quicktime: 'mov', 'x-m4v': 'm4v', '3gpp': '3gp', 'x-msvideo': 'avi', 'x-matroska': 'mkv', ogg: 'ogv', 'x-ms-wmv': 'wmv' };
    const extension = extMap[mimeSub] || mimeSub;
    const fileName = `reel_${Date.now()}.${extension}`;

    const filePath = path.join(REELS_VIDEOS_DIR, fileName);
    fs.writeFileSync(filePath, buffer);

    const publicUrl = `reels/videos/${fileName}`;
    console.log('[Reels] Saved video:', fileName, 'to reels/videos/');
    res.json({ success: true, url: publicUrl });
  } catch (error) {
    console.error('Video Upload Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== Custom Request Endpoints ====================

// 1a. Create Custom Request (TBD - no payment, price discussed after contact)
app.post('/api/custom-requests/create-tbd', (req, res) => {
  try {
    const { userId, userName, userEmail, userPhone, serviceType, date, timeSlot, requirements } = req.body;

    if (!userId || !serviceType || !date || !timeSlot) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }

    const orderId = `CR_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const order = {
      orderId,
      id: orderId,
      userId,
      userName: userName || 'User',
      userEmail: userEmail || '',
      userPhone: userPhone || '',
      serviceType,
      date,
      timeSlot,
      requirements: requirements || '',
      amount: 'TBD',
      status: 'pending',
      paymentStatus: 'pending',
      razorpayOrderId: null,
      razorpayPaymentId: null,
      joiningLink: null,
      adminNotes: null,
      finalDate: null,
      finalTime: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      acceptedAt: null,
      rejectedAt: null
    };

    const requests = readCustomRequests();
    requests.unshift(order);
    writeCustomRequests(requests);

    io.emit('custom-requests-update', { action: 'new', request: order });

    res.json({
      success: true,
      orderId,
      message: 'Custom request submitted. You will be contacted for pricing.'
    });
  } catch (error) {
    console.error('Create TBD Request Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 1b. Create Custom Request Order (with Razorpay)
app.post('/api/custom-requests/create', async (req, res) => {
  try {
    const { userId, userName, userEmail, userPhone, serviceType, date, timeSlot, requirements, amount } = req.body;

    if (!userId || !serviceType || !date || !timeSlot || !amount) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }

    // Generate unique order ID
    const orderId = `CR_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Create Razorpay order
    // Create Razorpay order
    if (!razorpay) {
      throw new Error('Razorpay is not configured on the server');
    }

    const razorpayOrder = await razorpay.orders.create({
      amount: amount * 100, // Convert to paise
      currency: 'INR',
      receipt: orderId,
      notes: {
        userId,
        serviceType,
        date,
        timeSlot
      }
    });

    // Create order object
    const order = {
      orderId,
      userId,
      userName: userName || 'User',
      userEmail: userEmail || '',
      userPhone: userPhone || '',
      serviceType,
      date,
      timeSlot,
      requirements: requirements || '',
      amount,
      status: 'pending', // pending, accepted, rejected
      paymentStatus: 'pending', // pending, paid, failed
      razorpayOrderId: razorpayOrder.id,
      razorpayPaymentId: null,
      joiningLink: null,
      adminNotes: null,
      finalDate: null, // Admin can set final date/time
      finalTime: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      acceptedAt: null,
      rejectedAt: null
    };

    // Save order
    const requests = readCustomRequests();
    requests.push(order);
    writeCustomRequests(requests);

    res.json({
      success: true,
      orderId,
      razorpayOrderId: razorpayOrder.id,
      amount,
      razorpayKeyId: process.env.RAZORPAY_KEY_ID
    });
  } catch (error) {
    console.error('Create Custom Request Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 2. Verify Payment
app.post('/api/custom-requests/verify-payment', (req, res) => {
  try {
    const { orderId, razorpayPaymentId, razorpayOrderId, razorpaySignature } = req.body;

    if (!orderId || !razorpayPaymentId || !razorpayOrderId || !razorpaySignature) {
      return res.status(400).json({
        success: false,
        error: 'Missing payment verification fields'
      });
    }

    // Verify signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${razorpayOrderId}|${razorpayPaymentId}`)
      .digest('hex');

    if (expectedSignature !== razorpaySignature) {
      return res.status(400).json({
        success: false,
        error: 'Invalid payment signature'
      });
    }

    // Update order
    const requests = readCustomRequests();
    const orderIndex = requests.findIndex(r => r.orderId === orderId);

    if (orderIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    requests[orderIndex].paymentStatus = 'paid';
    requests[orderIndex].razorpayPaymentId = razorpayPaymentId;
    requests[orderIndex].updatedAt = new Date().toISOString();

    writeCustomRequests(requests);

    res.json({
      success: true,
      message: 'Payment verified successfully',
      order: requests[orderIndex]
    });
  } catch (error) {
    console.error('Payment Verification Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. Get User Orders
app.get('/api/custom-requests/user/:userId', (req, res) => {
  try {
    const { userId } = req.params;
    const requests = readCustomRequests();
    const userOrders = requests.filter(r => r.userId === userId);

    // Sort by creation date (newest first)
    userOrders.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    res.json({
      success: true,
      orders: userOrders
    });
  } catch (error) {
    console.error('Get User Orders Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 4. Admin: Get All Custom Requests
app.get('/api/admin/custom-requests', (req, res) => {
  try {
    const requests = readCustomRequests();

    // Sort by creation date (newest first)
    requests.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    res.json({
      success: true,
      requests
    });
  } catch (error) {
    console.error('Get All Requests Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 5. Admin: Update Order Status
app.post('/api/admin/custom-requests/update-status', (req, res) => {
  try {
    const { orderId, status, joiningLink, adminNotes, finalDate, finalTime } = req.body;

    if (!orderId || !status) {
      return res.status(400).json({
        success: false,
        error: 'Order ID and status are required'
      });
    }

    const requests = readCustomRequests();
    const orderIndex = requests.findIndex(r => r.orderId === orderId);

    if (orderIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    // Update order
    requests[orderIndex].status = status;
    requests[orderIndex].updatedAt = new Date().toISOString();

    if (joiningLink) requests[orderIndex].joiningLink = joiningLink;
    if (adminNotes) requests[orderIndex].adminNotes = adminNotes;
    if (finalDate) requests[orderIndex].finalDate = finalDate;
    if (finalTime) requests[orderIndex].finalTime = finalTime;

    if (status === 'accepted') {
      requests[orderIndex].acceptedAt = new Date().toISOString();
    } else if (status === 'rejected') {
      requests[orderIndex].rejectedAt = new Date().toISOString();
    }

    writeCustomRequests(requests);

    res.json({
      success: true,
      message: 'Order updated successfully',
      order: requests[orderIndex]
    });
  } catch (error) {
    console.error('Update Order Status Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================================
// EMAIL NOTIFICATION (SMTP via Nodemailer)
// ============================================================================

// Configure nodemailer transporter from env vars (optional)
const EMAIL_HOST = process.env.EMAIL_HOST || '';
const EMAIL_PORT = parseInt(process.env.EMAIL_PORT || '587');
const EMAIL_USER = process.env.EMAIL_USER || '';
const EMAIL_PASS = process.env.EMAIL_PASS || '';
const EMAIL_FROM = process.env.EMAIL_FROM || 'noreply@vedicmate.com';
const EMAIL_TO = process.env.EMAIL_TO || 'vedicmate2025@gmail.com';

let transporter = null;
if (EMAIL_HOST && EMAIL_USER && EMAIL_PASS) {
  transporter = nodemailer.createTransport({
    host: EMAIL_HOST,
    port: EMAIL_PORT,
    secure: EMAIL_PORT === 465,
    auth: {
      user: EMAIL_USER,
      pass: EMAIL_PASS,
    },
  });
  console.log('📧 Email transporter configured');
} else {
  console.warn('⚠️  Email not configured — set EMAIL_HOST/USER/PASS env vars for order notifications');
}

function sendEmailNotification(subject, htmlBody) {
  if (!transporter) {
    console.log(`📧 Email skipped (no SMTP config): ${subject}`);
    return;
  }
  transporter.sendMail({
    from: EMAIL_FROM,
    to: EMAIL_TO,
    subject: subject,
    html: htmlBody,
  }).then(info => {
    console.log(`📧 Email sent: ${subject} (ID: ${info.messageId})`);
  }).catch(err => {
    console.error(`📧 Email failed: ${subject}`, err.message);
  });
}

// ============================================================================
// START SERVER
// ============================================================================

const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';

// Detect available network interfaces dynamically
const getNetworkIPs = () => {
  const interfaces = os.networkInterfaces();
  const ips = [];
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name] || []) {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push(iface.address);
      }
    }
  }
  return ips;
};

httpServer.listen(PORT, HOST, () => {
  const networkIPs = getNetworkIPs();
  const localURL = `http://localhost:${PORT}`;
  const networkURLs = networkIPs.length > 0
    ? networkIPs.map(ip => `http://${ip}:${PORT}`)
    : ['(No network interface detected)'];

  console.log('');
  console.log('╔══════════════════════════════════════════════════════════════╗');
  console.log('║                 VEDIC MATE BACKEND SERVER                    ║');
  console.log('╠══════════════════════════════════════════════════════════════╣');
  console.log(`║  🚀 Server running on port: ${String(PORT).padEnd(44)}║`);
  console.log(`║  📍 Local:   ${localURL.padEnd(52)}║`);
  networkURLs.forEach((url, i) => {
    const label = i === 0 ? '  🌐 Network:' : '  │           ';
    console.log(`║${label} ${url.padEnd(52)}║`);
  });
  console.log('║                                                              ║');
  console.log('║  📡 WebSocket: Real-time updates enabled                     ║');
  console.log('║  🛒 Orders: /api/orders, /api/admin/orders                   ║');
  console.log('║  📦 Products: /api/products, /api/admin/products             ║');
  console.log('║  💰 Wallet: /api/wallet/balance, /api/wallet/add             ║');
  console.log('║  🙏 Custom Requests: /api/custom-requests                    ║');
  console.log('║  📹 Live Sessions: /api/live-sessions                        ║');
  console.log('║  🤖 AI Chat: /api/ai/chat, /api/ai/welcome                   ║');
  console.log('║                                                              ║');
  console.log(`║  🤖 AI: ${(GEMINI_API_KEY ? 'Gemini' : OPENAI_API_KEY ? 'OpenAI' : 'Fallback Mode').padEnd(55)}║`);
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log('');

  // Also log to stdout in a simple parseable format for pm2/logs
  console.log(`[VedicMate] Server started on PORT=${PORT} HOST=${HOST}`);
  console.log(`[VedicMate] Local: ${localURL}`);
  networkURLs.forEach(url => console.log(`[VedicMate] Network: ${url}`));
});

