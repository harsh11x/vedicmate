"""
Numerology Service - Handles numerology calculations and analysis
"""

class NumerologyService:
    """Service for Numerology analysis"""
    
    def calculate_life_path(self, birth_date: str, name: str = '') -> dict:
        """Calculate life path number from birth date"""
        try:
            # Parse birth date (format: YYYY-MM-DD or DD/MM/YYYY)
            from datetime import datetime
            
            if '/' in birth_date:
                date_obj = datetime.strptime(birth_date, '%d/%m/%Y')
            else:
                date_obj = datetime.strptime(birth_date, '%Y-%m-%d')
            
            # Calculate life path number
            day = date_obj.day
            month = date_obj.month
            year = date_obj.year
            
            # Reduce to single digit
            life_path = self._reduce_number(day + month + year)
            
            return {
                'life_path_number': life_path,
                'analysis': self._get_life_path_analysis(life_path),
                'lucky_numbers': self._get_lucky_numbers(life_path),
                'compatibility': self._get_compatibility(life_path)
            }
        except Exception as e:
            return {'error': f'Invalid date format: {str(e)}'}
    
    def _reduce_number(self, number: int) -> int:
        """Reduce number to single digit (1-9)"""
        while number > 9 and number not in [11, 22, 33]:  # Master numbers
            number = sum(int(digit) for digit in str(number))
        return number
    
    def _get_life_path_analysis(self, number: int) -> str:
        """Get life path number analysis"""
        analyses = {
            1: "The Leader - Independent, ambitious, innovative",
            2: "The Diplomat - Cooperative, sensitive, intuitive",
            3: "The Communicator - Creative, expressive, optimistic",
            4: "The Builder - Practical, stable, hardworking",
            5: "The Adventurer - Freedom-loving, curious, versatile",
            6: "The Nurturer - Caring, responsible, harmonious",
            7: "The Seeker - Spiritual, analytical, introspective",
            8: "The Achiever - Ambitious, materialistic, powerful",
            9: "The Humanitarian - Compassionate, idealistic, generous"
        }
        return analyses.get(number, "Unknown number")
    
    def _get_lucky_numbers(self, number: int) -> list:
        """Get lucky numbers for life path"""
        lucky_map = {
            1: [1, 8, 17],
            2: [2, 6, 24],
            3: [3, 5, 12],
            4: [4, 8, 10],
            5: [5, 14, 23],
            6: [6, 15, 24],
            7: [7, 16, 25],
            8: [8, 17, 26],
            9: [9, 18, 27]
        }
        return lucky_map.get(number, [])
    
    def _get_compatibility(self, number: int) -> list:
        """Get compatible numbers"""
        compat_map = {
            1: [1, 5, 7],
            2: [2, 4, 8],
            3: [3, 6, 9],
            4: [2, 4, 8],
            5: [1, 5, 7],
            6: [3, 6, 9],
            7: [1, 5, 7],
            8: [2, 4, 8],
            9: [3, 6, 9]
        }
        return compat_map.get(number, [])

