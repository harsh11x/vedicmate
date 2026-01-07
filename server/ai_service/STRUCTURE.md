# AI Service Structure

## 📁 Directory Structure

```
ai_service/
├── app.py                      # Main Flask application
├── requirements.txt             # Python dependencies
├── Dockerfile                  # Docker configuration
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore rules
├── knowledge_base.json          # Comprehensive knowledge base
├── start.sh                    # Quick start script
├── deploy_aws.sh               # AWS deployment script
│
├── services/                    # Service modules
│   ├── __init__.py
│   ├── ai_model.py            # Main AI engine
│   ├── astrology_service.py   # Vedic Astrology service
│   ├── numerology_service.py  # Numerology service
│   ├── vastu_service.py       # Vastu Shastra service
│   └── astronomy_service.py   # Astronomy service
│
└── docs/                       # Documentation
    ├── README.md              # Main documentation
    ├── QUICK_START.md         # Quick start guide
    ├── AWS_DEPLOYMENT.md      # AWS deployment guide
    └── STRUCTURE.md           # This file
```

## 🔧 Components

### 1. Main Application (`app.py`)
- Flask REST API server
- CORS enabled for Flutter app
- Health check endpoint
- Main chat endpoint: `/api/chat`
- Specialized endpoints for each service

### 2. AI Model (`services/ai_model.py`)
- Intelligent query categorization
- Context understanding
- Response generation
- Knowledge base integration
- Conversation memory

### 3. Service Modules
- **Astrology Service**: Zodiac signs, planets, Lagna analysis
- **Numerology Service**: Life path calculations, number analysis
- **Vastu Service**: Directional guidance, room-specific Vastu
- **Astronomy Service**: Nakshatras, moon phases, planetary positions

### 4. Knowledge Base (`knowledge_base.json`)
- Comprehensive astrological data
- Zodiac sign information
- Planetary remedies
- Vastu guidelines
- Numerology data
- Nakshatra information

## 🚀 Deployment Options

1. **EC2**: Direct server deployment
2. **ECS**: Container-based deployment
3. **Elastic Beanstalk**: Managed deployment
4. **Lambda**: Serverless (with modifications)

## 📡 API Integration

The Flutter app connects to this service via:
- `AWSAIService` class in `lib/services/aws_ai_service.dart`
- Configurable URL in `lib/core/config/env.dart`
- Automatic fallback to local custom AI if AWS fails

## 🔄 Workflow

1. User sends message in Flutter app
2. App calls AWS AI service `/api/chat`
3. AI service categorizes query
4. Appropriate service generates response
5. Response sent back to Flutter app
6. Displayed in chat interface

## 📊 Features

✅ Intelligent query understanding
✅ Context-aware responses
✅ Multi-domain knowledge (Astrology, Numerology, Vastu, Astronomy)
✅ Comprehensive remedies database
✅ Conversation history support
✅ Error handling and fallbacks
✅ Scalable architecture
✅ AWS-ready deployment

## 🎯 Next Steps

1. Deploy to AWS EC2/ECS
2. Update Flutter app with AWS URL
3. Test end-to-end
4. Monitor performance
5. Scale as needed

