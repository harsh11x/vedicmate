"""
Vedic Mate AI Service
Flask-based AI service for Vedic Astrology, Numerology, Vastu, and Astronomy
Deploy on AWS EC2, ECS, or Lambda
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_restful import Api, Resource
import os
from dotenv import load_dotenv
import logging

from services.astrology_service import AstrologyService
from services.numerology_service import NumerologyService
from services.vastu_service import VastuService
from services.astronomy_service import AstronomyService
from services.ai_model import VedicAIModel

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app
api = Api(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize AI services
astrology_service = AstrologyService()
numerology_service = NumerologyService()
vastu_service = VastuService()
astronomy_service = AstronomyService()
ai_model = VedicAIModel()

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for AWS load balancer"""
    return jsonify({
        'status': 'healthy',
        'service': 'Vedic Mate AI Service',
        'version': '1.0.0'
    }), 200

# Main AI Chat endpoint
class AIChatResource(Resource):
    """Main AI chat endpoint that handles all queries"""
    
    def post(self):
        try:
            data = request.get_json()
            user_message = data.get('message', '')
            conversation_history = data.get('conversation_history', [])
            user_id = data.get('user_id', 'anonymous')
            
            if not user_message:
                return jsonify({
                    'error': 'Message is required'
                }), 400
            
            logger.info(f"Received message from user {user_id}: {user_message[:50]}...")
            
            # Use AI model to generate response
            response = ai_model.generate_response(
                user_message=user_message,
                conversation_history=conversation_history,
                user_id=user_id
            )
            
            return jsonify({
                'success': True,
                'response': response['message'],
                'category': response.get('category', 'general'),
                'confidence': response.get('confidence', 0.8),
                'suggestions': response.get('suggestions', [])
            }), 200
            
        except Exception as e:
            logger.error(f"Error processing chat request: {str(e)}")
            return jsonify({
                'success': False,
                'error': 'Internal server error',
                'message': str(e)
            }), 500

# Astrology specific endpoint
class AstrologyResource(Resource):
    """Astrology-specific queries"""
    
    def post(self):
        try:
            data = request.get_json()
            query = data.get('query', '')
            zodiac_sign = data.get('zodiac_sign', '')
            
            response = astrology_service.get_analysis(query, zodiac_sign)
            
            return jsonify({
                'success': True,
                'response': response
            }), 200
            
        except Exception as e:
            logger.error(f"Error in astrology service: {str(e)}")
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500

# Numerology endpoint
class NumerologyResource(Resource):
    """Numerology-specific queries"""
    
    def post(self):
        try:
            data = request.get_json()
            birth_date = data.get('birth_date', '')
            name = data.get('name', '')
            
            response = numerology_service.calculate_life_path(birth_date, name)
            
            return jsonify({
                'success': True,
                'response': response
            }), 200
            
        except Exception as e:
            logger.error(f"Error in numerology service: {str(e)}")
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500

# Vastu endpoint
class VastuResource(Resource):
    """Vastu Shastra queries"""
    
    def post(self):
        try:
            data = request.get_json()
            query = data.get('query', '')
            direction = data.get('direction', '')
            room_type = data.get('room_type', '')
            
            response = vastu_service.get_guidance(query, direction, room_type)
            
            return jsonify({
                'success': True,
                'response': response
            }), 200
            
        except Exception as e:
            logger.error(f"Error in vastu service: {str(e)}")
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500

# Astronomy endpoint
class AstronomyResource(Resource):
    """Astronomy and Nakshatra queries"""
    
    def post(self):
        try:
            data = request.get_json()
            query = data.get('query', '')
            date = data.get('date', '')
            
            response = astronomy_service.get_celestial_info(query, date)
            
            return jsonify({
                'success': True,
                'response': response
            }), 200
            
        except Exception as e:
            logger.error(f"Error in astronomy service: {str(e)}")
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500

# Register API resources
api.add_resource(AIChatResource, '/api/chat')
api.add_resource(AstrologyResource, '/api/astrology')
api.add_resource(NumerologyResource, '/api/numerology')
api.add_resource(VastuResource, '/api/vastu')
api.add_resource(AstronomyResource, '/api/astronomy')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    
    logger.info(f"Starting Vedic Mate AI Service on port {port}")
    app.run(host='0.0.0.0', port=port, debug=debug)

