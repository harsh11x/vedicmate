"""
Astronomy Service - Handles astronomy and Nakshatra queries
"""

from datetime import datetime

class AstronomyService:
    """Service for Astronomy and Nakshatra information"""
    
    def get_celestial_info(self, query: str, date: str = '') -> str:
        """Get celestial information based on query"""
        query_lower = query.lower()
        
        # Nakshatra queries
        nakshatras = self._get_nakshatra_list()
        for nakshatra in nakshatras:
            if nakshatra.replace(' ', '_') in query_lower.replace(' ', '_'):
                return self._get_nakshatra_info(nakshatra)
        
        # Moon phase queries
        if 'moon' in query_lower or 'phase' in query_lower:
            return self._get_moon_phase_info(date)
        
        # Planetary position queries
        planets = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn']
        for planet in planets:
            if planet in query_lower:
                return self._get_planetary_position(planet, date)
        
        return "I can provide information about Nakshatras, moon phases, and planetary positions. What would you like to know?"
    
    def _get_nakshatra_list(self) -> list:
        """Get list of all Nakshatras"""
        return [
            'ashwini', 'bharani', 'krittika', 'rohini', 'mrigashira', 'ardra',
            'punarvasu', 'pushya', 'ashlesha', 'magha', 'purva phalguni', 'uttara phalguni',
            'hasta', 'chitra', 'swati', 'vishakha', 'anuradha', 'jyestha', 'mula',
            'purva ashadha', 'uttara ashadha', 'shravana', 'dhanishta', 'shatabhisha',
            'purva bhadra', 'uttara bhadra', 'revati'
        ]
    
    def _get_nakshatra_info(self, nakshatra: str) -> str:
        """Get Nakshatra information"""
        info = {
            'ashwini': 'Ashwini: Healing, quick action, new beginnings. Ruled by Ketu.',
            'bharani': 'Bharani: Transformation, creativity, fertility. Ruled by Venus.',
            'krittika': 'Krittika: Purification, sharpness, cutting through obstacles. Ruled by Sun.',
            # Add all 27 Nakshatras...
        }
        return info.get(nakshatra.lower(), f"Information about {nakshatra} Nakshatra.")
    
    def _get_moon_phase_info(self, date: str = '') -> str:
        """Get moon phase information"""
        if not date:
            date = datetime.now().strftime('%Y-%m-%d')
        
        return f"""**Moon Phases & Significance**

**New Moon (Amavasya):** Ideal for new beginnings, meditation, and letting go of negative energy.

**Full Moon (Purnima):** Powerful for manifestation, completion, and spiritual practices.

**Waxing Moon:** Good for growth, building, and positive activities.

**Waning Moon:** Ideal for release, cleansing, and removing obstacles.

Current date: {date}"""
    
    def _get_planetary_position(self, planet: str, date: str = '') -> str:
        """Get planetary position information"""
        positions = {
            'sun': 'Sun represents soul, ego, authority, and vitality. Strong Sun brings leadership.',
            'moon': 'Moon represents mind, emotions, and mother. Strong Moon brings emotional stability.',
            'mars': 'Mars represents energy, courage, and action. Strong Mars brings determination.',
            'mercury': 'Mercury represents intellect, communication, and business.',
            'jupiter': 'Jupiter represents wisdom, expansion, and fortune.',
            'venus': 'Venus represents love, beauty, and luxury.',
            'saturn': 'Saturn represents discipline, karma, and structure.'
        }
        return positions.get(planet.lower(), f"Information about {planet}.")

