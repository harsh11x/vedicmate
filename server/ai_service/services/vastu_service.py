"""
Vastu Shastra Service - Handles Vastu queries and guidance
"""

class VastuService:
    """Service for Vastu Shastra guidance"""
    
    def get_guidance(self, query: str, direction: str = '', room_type: str = '') -> str:
        """Get Vastu guidance based on query"""
        query_lower = query.lower()
        
        if direction:
            return self._get_direction_guidance(direction)
        
        if room_type:
            return self._get_room_guidance(room_type)
        
        # Auto-detect from query
        directions = ['north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest']
        for dir_name in directions:
            if dir_name in query_lower:
                return self._get_direction_guidance(dir_name)
        
        rooms = ['bedroom', 'kitchen', 'prayer', 'bathroom', 'living', 'study']
        for room in rooms:
            if room in query_lower:
                return self._get_room_guidance(room)
        
        return "I can provide Vastu guidance for directions and rooms. Please specify what you need."
    
    def _get_direction_guidance(self, direction: str) -> str:
        """Get direction-specific Vastu guidance"""
        guidance = {
            'north': 'North is ruled by Kuber (Wealth God). Keep cash, valuables, and safe in North. Best for study room.',
            'south': 'South is ruled by Yama. Avoid bedrooms and main entrance in South. Good for storage.',
            'east': 'East is ruled by Sun. Best for main entrance, prayer room, and living room. Brings prosperity.',
            'west': 'West is good for dining room and children\'s room. Avoid kitchen in West.',
            'northeast': 'Northeast (Ishan) is most auspicious. Best for prayer room, meditation, and water elements.',
            'northwest': 'Northwest (Vayavya) is ruled by Air. Good for guest room and storage.',
            'southeast': 'Southeast (Agneya) is ruled by Fire. Best for kitchen. Avoid prayer room here.',
            'southwest': 'Southwest (Nairutya) is ruled by Earth. Best for master bedroom and heavy furniture.'
        }
        return guidance.get(direction.lower(), f"Vastu guidance for {direction} direction.")
    
    def _get_room_guidance(self, room: str) -> str:
        """Get room-specific Vastu guidance"""
        guidance = {
            'bedroom': 'Bedroom should be in Southwest. Sleep with head towards South or East. Avoid mirrors facing bed.',
            'kitchen': 'Kitchen should be in Southeast. Cook facing East. Keep water in Northeast corner of kitchen.',
            'prayer': 'Prayer room in Northeast. Face East or North while praying. Keep clean and well-lit.',
            'bathroom': 'Bathroom should be in Northwest or Southeast. Keep door closed. Avoid in Northeast.',
            'living': 'Living room in East or North. Main door should face East, North, or Northeast.',
            'study': 'Study room in North or East. Face East while studying. Keep books in Northeast.'
        }
        return guidance.get(room.lower(), f"Vastu guidance for {room}.")

