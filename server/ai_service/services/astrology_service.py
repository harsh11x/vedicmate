"""
Astrology Service - Handles all Vedic Astrology queries
"""

class AstrologyService:
    """Service for Vedic Astrology analysis"""
    
    def __init__(self):
        self.zodiac_data = self._load_zodiac_data()
        self.planetary_data = self._load_planetary_data()
    
    def get_analysis(self, query: str, zodiac_sign: str = '') -> str:
        """Get astrology analysis based on query"""
        query_lower = query.lower()
        
        # Zodiac sign analysis
        if zodiac_sign or any(sign in query_lower for sign in ['aries', 'taurus', 'gemini']):
            sign = zodiac_sign.lower() if zodiac_sign else self._extract_sign(query_lower)
            return self._get_zodiac_analysis(sign)
        
        # Planetary analysis
        planets = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn']
        for planet in planets:
            if planet in query_lower:
                return self._get_planetary_analysis(planet)
        
        return "I can provide detailed Vedic Astrology analysis. Please specify your zodiac sign or ask about planetary influences."
    
    def _load_zodiac_data(self) -> dict:
        """Load zodiac sign data"""
        return {
            'aries': {'ruler': 'Mars', 'element': 'Fire', 'traits': ['Leadership', 'Courage']},
            # Add all signs...
        }
    
    def _load_planetary_data(self) -> dict:
        """Load planetary data"""
        return {
            'sun': {'meaning': 'Soul and authority', 'remedy': 'Wear copper'},
            # Add all planets...
        }
    
    def _extract_sign(self, query: str) -> str:
        """Extract zodiac sign from query"""
        signs = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
                'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
        for sign in signs:
            if sign in query:
                return sign
        return ''
    
    def _get_zodiac_analysis(self, sign: str) -> str:
        """Get zodiac sign analysis"""
        if sign in self.zodiac_data:
            data = self.zodiac_data[sign]
            return f"**{sign.upper()} Analysis**\n\nRuling Planet: {data['ruler']}\nElement: {data['element']}\nTraits: {', '.join(data['traits'])}"
        return "Please specify a valid zodiac sign."
    
    def _get_planetary_analysis(self, planet: str) -> str:
        """Get planetary analysis"""
        if planet in self.planetary_data:
            data = self.planetary_data[planet]
            return f"**{planet.upper()} - Planetary Influence**\n\n{data['meaning']}\n\nRemedy: {data['remedy']}"
        return "Please specify a valid planet."

