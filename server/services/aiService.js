// AI Service for Vedic Mate Backend
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

class AIService {
  constructor() {
    // Gemini API Configuration
    this.geminiApiKey = process.env.GEMINI_API_KEY || '';
    this.geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
    
    // OpenAI Configuration (alternative)
    this.openaiApiKey = process.env.OPENAI_API_KEY || '';
    this.openaiBaseUrl = 'https://api.openai.com/v1/chat/completions';
    
    // AI Pandits data (same as Flutter app)
    this.pandits = this.loadPandits();
  }

  loadPandits() {
    // This should match the AIPandits from Flutter app
    // For now, we'll use a simplified version
    return {
      'ai_pandit_1': {
        id: 'ai_pandit_1',
        name: 'Pandit Rajesh Shastri',
        specializations: ['Vedic Astrology', 'Kundli Analysis', 'Marriage Matching'],
        experienceYears: 25,
        gender: 'male',
        bio: 'A renowned Vedic astrologer with 25 years of experience.',
      },
      // Add more pandits as needed
    };
  }

  getPandit(panditId) {
    return this.pandits[panditId] || null;
  }

  getPersonalityPrompt(panditId) {
    const pandit = this.getPandit(panditId);
    if (!pandit) {
      return this.getDefaultPersonality();
    }

    const { name, specializations, experienceYears, gender, bio } = pandit;
    const specList = specializations.join(', ');

    return `You are ${name}, a ${gender} Vedic astrologer and spiritual guide with ${experienceYears} years of experience.

YOUR EXPERTISE:
- Specializations: ${specList}
- Deep knowledge of Vedic astrology, planetary influences, and remedies

YOUR PERSONALITY:
${this.getPersonalityTraits(pandit)}

YOUR SPEAKING STYLE:
${this.getSpeakingStyle(pandit)}

YOUR BACKGROUND:
${bio || 'Experienced Vedic astrologer with deep knowledge of ancient wisdom.'}

IMPORTANT GUIDELINES:
1. Always respond as ${name} would - with your unique personality, expertise, and speaking style
2. Use your specialized knowledge in ${specializations[0]} to provide accurate guidance
3. Be authentic to your personality traits - don't be generic
4. Reference your experience and background naturally in conversations
5. Provide practical, actionable advice based on Vedic wisdom
6. Be empathetic, wise, and helpful while maintaining your unique character
7. Never break character or reveal you're an AI - you are ${name}, a real astrologer
8. If asked about topics outside your expertise, acknowledge it and guide them appropriately
9. Always end responses in a way that reflects your personality and invites further conversation

Remember: You ARE ${name}. Respond with your unique voice, wisdom, and personality.`;
  }

  getPersonalityTraits(pandit) {
    const id = pandit.id.toLowerCase();
    if (id.includes('rajesh') || id.includes('ramesh') || id.includes('ravi')) {
      return '- Traditional and scholarly\n- Deep respect for ancient wisdom\n- Patient teacher\n- Methodical and thorough\n- Calm and composed';
    }
    if (id.includes('priya') || id.includes('meera') || id.includes('anjali')) {
      return '- Compassionate and nurturing\n- Excellent listener\n- Empathetic and understanding\n- Supportive and encouraging\n- Intuitive and sensitive';
    }
    if (id.includes('swami') || id.includes('anand') || id.includes('guru')) {
      return '- Spiritual and enlightened\n- Deep inner peace\n- Philosophical insights\n- Inspirational presence\n- Mystical wisdom';
    }
    return '- Wise and experienced\n- Calm and composed\n- Helpful and supportive\n- Knowledgeable and trustworthy\n- Professional yet friendly';
  }

  getSpeakingStyle(pandit) {
    const id = pandit.id.toLowerCase();
    if (id.includes('rajesh') || id.includes('ramesh') || id.includes('ravi')) {
      return '- Formal and scholarly, uses Sanskrit terms naturally\n- Speaks with authority and deep knowledge\n- Quotes ancient texts when appropriate\n- Professional yet warm\n- Detailed explanations with traditional references';
    }
    if (id.includes('priya') || id.includes('meera') || id.includes('anjali')) {
      return '- Warm, compassionate, and nurturing\n- Empathetic listener\n- Gentle guidance with emotional understanding\n- Uses encouraging and supportive language\n- Focuses on emotional well-being';
    }
    if (id.includes('swami') || id.includes('anand') || id.includes('guru')) {
      return '- Spiritual and profound\n- Uses philosophical insights\n- Speaks with divine wisdom\n- Mystical yet practical\n- Inspirational and uplifting';
    }
    return '- Friendly and approachable\n- Clear and easy to understand\n- Practical and helpful\n- Warm and supportive\n- Professional yet personable';
  }

  getDefaultPersonality() {
    return `You are a wise and experienced Vedic astrologer with deep knowledge of Hindu astrology, numerology, and spiritual practices.

Your speaking style is:
- Warm, empathetic, and respectful
- Uses traditional Vedic terminology appropriately
- Provides practical guidance based on ancient wisdom
- Balances spiritual insights with practical advice
- Speaks in a calm, reassuring manner

You help people with:
- Kundli analysis and birth chart readings
- Life predictions and guidance
- Spiritual counseling
- Remedies and solutions
- General astrological queries

Always respond with wisdom, compassion, and authenticity.`;
  }

  async getWelcomeMessage(panditId) {
    const pandit = this.getPandit(panditId);
    if (!pandit) {
      return 'Namaste! Welcome to Vedic Mate. How may I assist you today? 🙏';
    }

    const { name, specializations } = pandit;
    const id = panditId.toLowerCase();

    if (id.includes('priya') || id.includes('meera')) {
      return `Namaste! I'm ${name}. 🙏 I'm here to help you with ${specializations[0]} and guide you with compassion. How may I assist you today?`;
    }
    if (id.includes('rajesh') || id.includes('ramesh')) {
      return `Pranam! I am ${name}, your guide in ${specializations[0]}. With ${pandit.experienceYears} years of experience, I'm here to help you. What would you like to know?`;
    }
    if (id.includes('swami') || id.includes('anand')) {
      return `Om Namah Shivaya! I am ${name}. Welcome, seeker. I guide you in ${specializations[0]} and spiritual wisdom. How may I serve you?`;
    }

    return `Namaste! I'm ${name}, specializing in ${specializations[0]}. I'm here to help you with Vedic guidance. What can I assist you with today?`;
  }

  async sendMessage(message, history, panditId) {
    try {
      // Try Gemini first
      if (this.geminiApiKey && this.geminiApiKey !== 'YOUR_GEMINI_API_KEY_HERE') {
        return await this.sendGeminiMessage(message, history, panditId);
      }

      // Try OpenAI as fallback
      if (this.openaiApiKey && this.openaiApiKey !== 'YOUR_OPENAI_API_KEY_HERE') {
        return await this.sendOpenAIMessage(message, history, panditId);
      }

      // Fallback to rule-based responses
      return this.getFallbackResponse(message, panditId);
    } catch (error) {
      console.error('AI Service Error:', error);
      return this.getFallbackResponse(message, panditId);
    }
  }

  async sendGeminiMessage(message, history, panditId) {
    const systemPrompt = this.getPersonalityPrompt(panditId);

    // Build conversation context
    const conversationContext = history.map(h => ({
      role: h.isUser === 'true' || h.isUser === true ? 'user' : 'model',
      parts: [{ text: h.message }]
    }));

    // Add current message
    conversationContext.push({
      role: 'user',
      parts: [{ text: message }]
    });

    const requestBody = {
      contents: conversationContext,
      systemInstruction: {
        parts: [{ text: systemPrompt }]
      },
      generationConfig: {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      }
    };

    try {
      const response = await axios.post(
        `${this.geminiBaseUrl}?key=${this.geminiApiKey}`,
        requestBody,
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 30000
        }
      );

      if (response.data.candidates && response.data.candidates.length > 0) {
        const content = response.data.candidates[0].content;
        if (content.parts && content.parts.length > 0) {
          return content.parts[0].text;
        }
      }

      throw new Error('No response from Gemini');
    } catch (error) {
      console.error('Gemini API Error:', error.response?.data || error.message);
      throw error;
    }
  }

  async sendOpenAIMessage(message, history, panditId) {
    const systemPrompt = this.getPersonalityPrompt(panditId);

    // Build conversation context
    const messages = [
      { role: 'system', content: systemPrompt },
      ...history.map(h => ({
        role: h.isUser === 'true' || h.isUser === true ? 'user' : 'assistant',
        content: h.message
      })),
      { role: 'user', content: message }
    ];

    try {
      const response = await axios.post(
        this.openaiBaseUrl,
        {
          model: 'gpt-3.5-turbo',
          messages: messages,
          temperature: 0.7,
          max_tokens: 1024
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.openaiApiKey}`
          },
          timeout: 30000
        }
      );

      if (response.data.choices && response.data.choices.length > 0) {
        return response.data.choices[0].message.content;
      }

      throw new Error('No response from OpenAI');
    } catch (error) {
      console.error('OpenAI API Error:', error.response?.data || error.message);
      throw error;
    }
  }

  getFallbackResponse(message, panditId) {
    const pandit = this.getPandit(panditId);
    const lowerMessage = message.toLowerCase();

    if (!pandit) {
      if (lowerMessage.includes('kundli') || lowerMessage.includes('birth chart')) {
        return 'I can help you with Kundli analysis. Please share your birth details (date, time, place) for a detailed reading.';
      }
      return 'I\'m here to help you with Vedic astrology and spiritual guidance. Please share your birth details so I can provide accurate insights.';
    }

    const { name, specializations } = pandit;

    if (lowerMessage.includes('kundli') || lowerMessage.includes('birth chart')) {
      return `I understand you're asking about Kundli. As an expert in ${specializations[0]}, I can help you understand your birth chart. Please share your birth details (date, time, place) for a detailed analysis.`;
    }

    if (lowerMessage.includes('love') || lowerMessage.includes('relationship') || lowerMessage.includes('marriage')) {
      return `Relationships are important aspects of life. Based on my experience in ${specializations[0]}, I can guide you. Could you share more details about your situation?`;
    }

    if (lowerMessage.includes('career') || lowerMessage.includes('job') || lowerMessage.includes('business')) {
      return `Career guidance is one of my specialties. Let me help you understand the astrological factors affecting your professional life. What specific aspect would you like to know about?`;
    }

    return `Thank you for your question. As ${name}, I specialize in ${specializations[0]}. I'm here to help you with Vedic guidance. Could you provide more details so I can assist you better?`;
  }
}

export default AIService;

