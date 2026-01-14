import axios from 'axios';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class LocalAIService {
    constructor() {
        this.config = this._loadConfig();
        this.personalities = this._loadPersonalities();
        this.defaultSystemPrompt = this.personalities['default'] || "You are a helpful assistant.";
        this.history = {}; // Simple in-memory history per session/user
    }

    _loadConfig() {
        try {
            const configPath = path.join(__dirname, '../../ai_engine/model_config.json');
            if (fs.existsSync(configPath)) {
                return JSON.parse(fs.readFileSync(configPath, 'utf8'));
            }
        } catch (e) {
            console.error('Error loading AI config:', e);
        }
        return {
            api_base_url: "http://localhost:1234/v1", // Default fallback
            model_name: "qwen2.5-1.5b-instruct",
            temperature: 0.7,
            max_tokens: 500
        };
    }

    _loadPersonalities() {
        try {
            const promptPath = path.join(__dirname, '../../ai_engine/personalities.json');
            if (fs.existsSync(promptPath)) {
                return JSON.parse(fs.readFileSync(promptPath, 'utf8'));
            }
        } catch (e) {
            console.error('Error loading Personalities:', e);
        }
        return { "default": "You are a Vedic Pandit." };
    }

    async generateResponse(userId, userMessage, panditId = 'default', clientHistory = [], targetLanguage = 'en') {
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

            // Inject Language Instruction
            systemPrompt += `\n\nCRITICAL: You MUST reply ONLY in ${langName}. Ignore previous language context if different.`;

            // Inject Fluency/Voice Instructions
            systemPrompt += `\n\nVOICE GUIDELINES:
            - Be concise and human-like. Avoid long monologues.
            - Use a warm, empathetic, and conversational tone.
            - Speak naturally, like a real Vedic Pandit talking on a phone call.
            - If the user greeting is short, keep your greeting short.
            - Do not start every sentence with "Namaste" or formal greetings if already in conversation.`;

            // Enforce language in User Message for smaller models
            // Prepend instruction to user message so it's fresh in context
            const enforcedUserMessage = `[INSTRUCTION: Reply in ${langName} only] ${userMessage}`;

            // Build context
            const messages = [
                { role: "system", content: systemPrompt }
            ];

            // Add history
            // 1. Prefer Client History (Robust)
            if (clientHistory && clientHistory.length > 0) {
                // Map client history format (isUser/message) to OpenAI format (role/content)
                const formattedHistory = clientHistory.map(msg => ({
                    role: (msg.isUser === 'true' || msg.isUser === true) ? "user" : "assistant",
                    content: msg.message
                }));
                // Keep last 15 messages for context window
                messages.push(...formattedHistory.slice(-15));
            }
            // 2. Fallback to Server Memory (Flaky)
            else if (this.history[userId]) {
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

            // Store original message in history (without instruction tag) to keep it clean
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
    }

    clearHistory(userId) {
        if (this.history[userId]) {
            delete this.history[userId];
        }
    }
}

export default new LocalAIService();
