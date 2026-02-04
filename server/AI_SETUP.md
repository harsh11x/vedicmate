# AI Service Setup Guide

## Current Status

The app uses **Local AI** (LM Studio via ngrok) with **Custom AI** fallback:

1. **LocalAIService** (Primary) - Your own AI via ngrok
   - Calls backend → ngrok tunnel → LM Studio / local AI
   - Configure ngrok URL in `server/.env`

2. **CustomAIService** (Fallback) - Rule-based, no setup
   - Used when Local AI is unreachable
   - Works offline

## Configure Ngrok URL (Recommended)

Edit `server/.env` and set your ngrok URL. When ngrok restarts, just update this file—no code changes needed.

```env
# Change when ngrok restarts
AI_NGROK_URL=https://your-id.ngrok-free.app/v1
```

Copy `server/.env.example` to `server/.env` if needed, then set `AI_NGROK_URL` to your current ngrok URL.

## Option 1: Use CustomAIService (Current - No Setup Needed)

✅ **Already working!** The CustomAIService provides intelligent, personality-based responses without any external setup.

**Pros:**
- Works immediately
- No API costs
- No internet dependency for basic responses
- Personality-based responses

**Cons:**
- Rule-based (not true AI)
- Limited conversation depth
- Pre-defined response patterns

## Option 2: Set Up Gemini API (Recommended for Production)

### Step 1: Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### Step 2: Configure in App

1. Open `lib/core/config/gemini_config.dart`
2. Replace `'YOUR_GEMINI_API_KEY_HERE'` with your actual API key:

```dart
static const String apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### Step 3: Test

The app will automatically use Gemini when the API key is configured. If Gemini fails, it falls back to CustomAIService.

**Pros:**
- True AI conversations
- Better context understanding
- More natural responses
- Free tier available (60 requests/minute)

**Cons:**
- Requires internet
- API key setup needed
- Rate limits on free tier

## Option 3: Host Your Own AI on AWS (Advanced)

If you want full control and customization, you can host your own AI service on AWS.

### Architecture

```
Flutter App → AWS API Gateway → AWS Lambda → AI Model (Hugging Face/OpenAI)
```

### Steps

1. **Create AWS Lambda Function**
   - Use Python/Node.js runtime
   - Integrate with AI model (Hugging Face, OpenAI, etc.)
   - Handle personality-based prompts

2. **Set Up API Gateway**
   - Create REST API
   - Connect to Lambda
   - Enable CORS

3. **Update App**
   - Create new `AWSHostedAIService`
   - Update `api_providers.dart` to use it
   - Add API endpoint configuration

### Example Lambda Function (Python)

```python
import json
import requests

def lambda_handler(event, context):
    message = event['message']
    pandit_id = event.get('panditId')
    history = event.get('history', [])
    
    # Get pandit personality
    pandit = get_pandit_by_id(pandit_id)
    system_prompt = build_personality_prompt(pandit)
    
    # Call AI model (e.g., Hugging Face)
    response = call_ai_model(message, system_prompt, history)
    
    return {
        'statusCode': 200,
        'body': json.dumps({'response': response})
    }
```

### Update App Service

Create `lib/services/aws_ai_service.dart`:

```dart
class AWSHostedAIService {
  final String apiEndpoint = 'https://your-api-gateway-url.amazonaws.com/chat';
  
  Future<String> sendMessage(String message, List<dynamic> history, {String? panditId}) async {
    final response = await http.post(
      Uri.parse(apiEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'panditId': panditId,
        'history': history,
      }),
    );
    
    final data = jsonDecode(response.body);
    return data['response'];
  }
}
```

**Pros:**
- Full control
- Customizable
- No rate limits (your infrastructure)
- Can use any AI model

**Cons:**
- More complex setup
- AWS costs
- Requires maintenance
- More development time

## Recommendation

**For Development/Testing:** Use CustomAIService (already working)

**For Production:** Set up Gemini API (easiest, free tier available)

**For Enterprise:** Consider AWS-hosted solution for full control

## Testing

After setup, test the AI by:
1. Opening chat with any AI Pandit
2. Sending a message
3. Check console logs:
   - `📤 Sending to Gemini...` = Using Gemini
   - `⚠️ Gemini failed, switching to fallback...` = Using CustomAIService

## Troubleshooting

### Gemini Not Working

1. Check API key is set correctly
2. Verify internet connection
3. Check API quota/limits
4. Review console logs for errors

### CustomAIService Not Working

1. Check `panditId` is being passed
2. Verify pandit exists in `AIPandits`
3. Check console for errors

## Current Implementation

- ✅ CustomAIService with personality support
- ✅ GeminiService with personality support
- ✅ Automatic fallback mechanism
- ✅ Error handling and logging
- ✅ Per-pandit chat sessions

The AI is now working with personality-based responses! 🎉

