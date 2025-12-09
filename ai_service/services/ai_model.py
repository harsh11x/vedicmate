"""
Vedic AI Model - Main AI engine for intelligent responses
Uses knowledge base + pattern matching + context understanding
"""

import re
import json
from typing import List, Dict, Optional
from datetime import datetime

class VedicAIModel:
    """Main AI model for Vedic Astrology responses"""
    
    def __init__(self):
        self.knowledge_base = self._load_knowledge_base()
        self.context_memory = {}  # Store user context
        
    def _load_knowledge_base(self) -> Dict:
        """Load comprehensive knowledge base"""
        return {
            'zodiac_signs': self._get_zodiac_knowledge(),
            'planets': self._get_planetary_knowledge(),
            'numerology': self._get_numerology_knowledge(),
            'vastu': self._get_vastu_knowledge(),
            'astronomy': self._get_astronomy_knowledge(),
            'remedies': self._get_remedies_knowledge(),
        }
    
    def generate_response(
        self,
        user_message: str,
        conversation_history: List[Dict],
        user_id: str
    ) -> Dict:
        """Generate intelligent response based on user message"""
        
        message_lower = user_message.lower().strip()
        
        # Extract context from conversation history
        context = self._extract_context(conversation_history)
        
        # Determine query category
        category = self._categorize_query(message_lower)
        
        # Generate response based on category
        if category == 'astrology':
            response = self._handle_astrology_query(message_lower, context)
        elif category == 'numerology':
            response = self._handle_numerology_query(message_lower, context)
        elif category == 'vastu':
            response = self._handle_vastu_query(message_lower, context)
        elif category == 'astronomy':
            response = self._handle_astronomy_query(message_lower, context)
        elif category == 'greeting':
            response = self._handle_greeting()
        else:
            response = self._handle_general_query(message_lower, context)
        
        # Store context for future reference
        if user_id not in self.context_memory:
            self.context_memory[user_id] = {}
        self.context_memory[user_id]['last_category'] = category
        self.context_memory[user_id]['last_query'] = message_lower
        
        return {
            'message': response,
            'category': category,
            'confidence': 0.85,
            'suggestions': self._generate_suggestions(category)
        }
    
    def _categorize_query(self, message: str) -> str:
        """Categorize user query"""
        astrology_keywords = ['zodiac', 'sign', 'aries', 'taurus', 'gemini', 'cancer', 
                             'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn',
                             'aquarius', 'pisces', 'lagna', 'ascendant', 'planet', 'kundli']
        
        numerology_keywords = ['numerology', 'life path', 'number', 'birth number', 'name number']
        
        vastu_keywords = ['vastu', 'direction', 'north', 'south', 'east', 'west', 'room', 'bedroom', 'kitchen']
        
        astronomy_keywords = ['nakshatra', 'moon phase', 'astronomy', 'celestial', 'lunar']
        
        greeting_keywords = ['hi', 'hello', 'namaste', 'hey', 'good morning', 'good evening']
        
        message_lower = message.lower()
        
        if any(keyword in message_lower for keyword in greeting_keywords):
            return 'greeting'
        elif any(keyword in message_lower for keyword in astrology_keywords):
            return 'astrology'
        elif any(keyword in message_lower for keyword in numerology_keywords):
            return 'numerology'
        elif any(keyword in message_lower for keyword in vastu_keywords):
            return 'vastu'
        elif any(keyword in message_lower for keyword in astronomy_keywords):
            return 'astronomy'
        else:
            return 'general'
    
    def _handle_astrology_query(self, message: str, context: Dict) -> str:
        """Handle astrology-related queries"""
        # Check for zodiac sign
        signs = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
                'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
        
        for sign in signs:
            if sign in message:
                return self._get_zodiac_analysis(sign)
        
        # Check for planet queries
        planets = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu']
        for planet in planets:
            if planet in message:
                return self._get_planetary_analysis(planet)
        
        # Check for Lagna
        if 'lagna' in message or 'ascendant' in message:
            return self._get_lagna_analysis(message)
        
        # General astrology guidance
        return self._get_general_astrology_guidance(message)
    
    def _handle_numerology_query(self, message: str, context: Dict) -> str:
        """Handle numerology queries"""
        # Extract number from message
        numbers = re.findall(r'\b([1-9])\b', message)
        if numbers:
            number = int(numbers[0])
            return self._get_numerology_analysis(number)
        
        return "Numerology reveals your life path through numbers 1-9. Each number has unique characteristics. What is your life path number, or would you like to know how to calculate it?"
    
    def _handle_vastu_query(self, message: str, context: Dict) -> str:
        """Handle Vastu queries"""
        directions = ['north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest']
        rooms = ['bedroom', 'kitchen', 'prayer', 'bathroom', 'living', 'study']
        
        for direction in directions:
            if direction in message:
                return self._get_vastu_direction_guidance(direction)
        
        for room in rooms:
            if room in message:
                return self._get_vastu_room_guidance(room)
        
        return "Vastu Shastra is the science of directions and space. I can guide you on directional placements, room-specific Vastu, colors, and remedies. What specific Vastu guidance do you need?"
    
    def _handle_astronomy_query(self, message: str, context: Dict) -> str:
        """Handle astronomy queries"""
        nakshatras = ['ashwini', 'bharani', 'krittika', 'rohini', 'mrigashira', 'ardra',
                     'punarvasu', 'pushya', 'ashlesha', 'magha', 'purva phalguni', 'uttara phalguni',
                     'hasta', 'chitra', 'swati', 'vishakha', 'anuradha', 'jyestha', 'mula',
                     'purva ashadha', 'uttara ashadha', 'shravana', 'dhanishta', 'shatabhisha',
                     'purva bhadra', 'uttara bhadra', 'revati']
        
        for nakshatra in nakshatras:
            if nakshatra.replace(' ', '_') in message.replace(' ', '_'):
                return self._get_nakshatra_analysis(nakshatra)
        
        if 'moon' in message or 'phase' in message:
            return self._get_moon_phase_info()
        
        return "Astronomy in Vedic tradition includes 27 Nakshatras, moon phases, and planetary positions. Which aspect would you like to explore?"
    
    def _handle_greeting(self) -> str:
        """Handle greetings"""
        greetings = [
            "🙏 Namaste! I'm your AI Vedic Astrologer. I can help you with Vedic Astrology, Numerology, Vastu, and Astronomy. How may I assist you?",
            "🙏 Hello! Welcome to Vedic Mate AI. I specialize in Vedic Astrology, Numerology, Vastu Shastra, and Astronomy. What would you like to know?",
            "🙏 Namaskar! I'm here to guide you through Vedic wisdom. Ask me about your zodiac sign, numerology, vastu, or any astrological guidance."
        ]
        import random
        return random.choice(greetings)
    
    def _handle_general_query(self, message: str, context: Dict) -> str:
        """Handle general queries"""
        if '?' in message or any(word in message for word in ['what', 'how', 'why', 'tell me']):
            return "I can help you with Vedic Astrology, Numerology, Vastu, and Astronomy. Could you be more specific? For example:\n• 'Tell me about Aries'\n• 'What is my life path number?'\n• 'Vastu for bedroom'\n• 'Nakshatra information'"
        
        return "I'm here to help with Vedic Astrology, Numerology, Vastu Shastra, and Astronomy. What specific guidance are you seeking?"
    
    # Knowledge base methods
    def _get_zodiac_knowledge(self) -> Dict:
        """Zodiac sign knowledge"""
        return {
            'aries': {
                'ruler': 'Mars', 'element': 'Fire', 'traits': ['Leadership', 'Courage', 'Independence'],
                'career': 'Leadership roles, entrepreneurship, military, sports',
                'health': 'Prone to headaches and fevers. Focus on stress management.',
                'love': 'Passionate and direct. Needs independent partner.',
            },
            # Add all 12 signs...
        }
    
    def _get_planetary_knowledge(self) -> Dict:
        """Planetary knowledge"""
        return {
            'sun': {'meaning': 'Soul, ego, authority, vitality', 'remedy': 'Wear copper, donate wheat on Sundays'},
            'moon': {'meaning': 'Mind, emotions, mother', 'remedy': 'Wear silver, donate white on Mondays'},
            # Add all planets...
        }
    
    def _get_numerology_knowledge(self) -> Dict:
        """Numerology knowledge"""
        return {
            1: {'name': 'The Leader', 'traits': ['Independent', 'Ambitious'], 'career': 'Leadership, entrepreneurship'},
            # Add numbers 1-9...
        }
    
    def _get_vastu_knowledge(self) -> Dict:
        """Vastu knowledge"""
        return {
            'directions': {
                'north': 'Ruled by Kuber. Keep cash and valuables in North.',
                'east': 'Ruled by Sun. Best for main entrance and prayer room.',
                # Add all directions...
            }
        }
    
    def _get_astronomy_knowledge(self) -> Dict:
        """Astronomy knowledge"""
        return {
            'nakshatras': {
                'ashwini': 'Healing, quick action, new beginnings. Ruled by Ketu.',
                # Add all 27 nakshatras...
            }
        }
    
    def _get_remedies_knowledge(self) -> Dict:
        """Remedies knowledge"""
        return {
            'sun': ['Wear copper', 'Donate wheat on Sundays', 'Chant Surya Mantra'],
            # Add all remedies...
        }
    
    # Helper methods
    def _extract_context(self, history: List[Dict]) -> Dict:
        """Extract context from conversation history"""
        context = {'mentioned_signs': [], 'topics': []}
        for msg in history[-5:]:  # Last 5 messages
            text = msg.get('message', '').lower()
            # Extract mentioned signs, planets, etc.
        return context
    
    def _get_zodiac_analysis(self, sign: str) -> str:
        """Get detailed zodiac analysis"""
        # Implementation with full knowledge base
        return f"**{sign.upper()} Analysis**\n\nDetailed information about {sign}..."
    
    def _get_planetary_analysis(self, planet: str) -> str:
        """Get planetary analysis"""
        return f"**{planet.upper()} - Planetary Influence**\n\nDetailed planetary information..."
    
    def _get_lagna_analysis(self, message: str) -> str:
        """Get Lagna analysis"""
        return "Lagna (Ascendant) represents your rising sign at birth..."
    
    def _get_general_astrology_guidance(self, message: str) -> str:
        """General astrology guidance"""
        return "I can provide guidance on zodiac signs, planetary positions, Lagna, and remedies..."
    
    def _get_numerology_analysis(self, number: int) -> str:
        """Get numerology analysis"""
        return f"**Life Path Number {number}**\n\nDetailed numerology analysis..."
    
    def _get_vastu_direction_guidance(self, direction: str) -> str:
        """Get Vastu direction guidance"""
        return f"**{direction.upper()} Direction - Vastu Guidance**\n\nDetailed Vastu information..."
    
    def _get_vastu_room_guidance(self, room: str) -> str:
        """Get Vastu room guidance"""
        return f"**{room.upper()} - Vastu Guidelines**\n\nDetailed room-specific Vastu..."
    
    def _get_nakshatra_analysis(self, nakshatra: str) -> str:
        """Get Nakshatra analysis"""
        return f"**{nakshatra.upper()} Nakshatra**\n\nDetailed Nakshatra information..."
    
    def _get_moon_phase_info(self) -> str:
        """Get moon phase information"""
        return "**Moon Phases & Significance**\n\nNew Moon, Full Moon, Waxing, Waning phases..."
    
    def _generate_suggestions(self, category: str) -> List[str]:
        """Generate follow-up suggestions"""
        suggestions_map = {
            'astrology': ['Tell me about my zodiac sign', 'Planetary remedies', 'Love compatibility'],
            'numerology': ['Calculate my life path number', 'Lucky numbers', 'Name numerology'],
            'vastu': ['Bedroom Vastu', 'Kitchen direction', 'Vastu remedies'],
            'astronomy': ['Nakshatra information', 'Moon phases', 'Planetary positions'],
        }
        return suggestions_map.get(category, ['Ask about astrology', 'Numerology guidance', 'Vastu tips'])

