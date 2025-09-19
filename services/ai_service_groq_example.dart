// Alternative configuration for Groq AI service
// Replace the constants in ai_service.dart with these if you choose Groq:

/*
static const String _baseUrl = 'https://api.groq.com/openai/v1';
static const String _apiKey = 'gsk-your-groq-api-key-here';

// In _makeAIRequest method, change model to:
'model': 'llama3-70b-8192', // or 'mixtral-8x7b-32768'
*/

// Groq offers:
// - Faster inference (5-10x speed improvement)
// - Lower costs
// - Good quality for question generation
// - API compatible with OpenAI format (no code changes needed)

// Get Groq API key at: https://console.groq.com/
