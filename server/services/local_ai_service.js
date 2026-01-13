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

    async generateResponse(userId, userMessage, panditId = 'default', clientHistory = []) {
        try {
            // Select Personality
            const systemPrompt = this.personalities[panditId] || this.personalities['default'] || this.defaultSystemPrompt;

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
            messages.push({ role: "user", content: userMessage });

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
            console.error('Local AI Error:', error.message);
            if (error.code === 'ECONNREFUSED') {
                return "I apologize, but my spiritual connection (local server) seems to be offline. Please ensure LM Studio is running.";
            }
            return "I sensed a disturbance in the cosmic energy. Please try again later.";
        }
    }

    clearHistory(userId) {
        if (this.history[userId]) {
            delete this.history[userId];
        }
    }
}

export default new LocalAIService();
