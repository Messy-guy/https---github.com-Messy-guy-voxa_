import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant/key.dart';

class AiService {
  final List<Map<String,String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async{
  try{
   final res = await http.post(Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apikey1',
    },
    body: jsonEncode(
      {
"model": "gpt-3.5-turbo",
"max_tokens": 5,
"temperature": 0,
"messages": [
  {"role": "user", "content":  'Just answer with yes or no. Is the following prompt requesting to generate an image, art, or picture using AI? \"$prompt\"'}]
      }
    )
   );

 print(res.body);
 if(res.statusCode == 200){
    String content = jsonDecode(res.body)["choices"][0]["message"]["content"];
    content = content.trim().toLowerCase();

    if(content.trim().toLowerCase() =='yes'){
      return await ImageGeneratingAPI(prompt);
    }else{
      return await ChatGeneratingAPI(prompt);
    }
 }
    return 'An error occurred';
 

  }catch(e){
    return e.toString();
  }
  }

  Future<String> ChatGeneratingAPI(String prompt) async{
    messages.add({'role': 'user', 'content': prompt});
    
    try{
      final res = await http.post(Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        'Content-Type': 'application/json',
          'Authorization': 'Bearer $apikey1',
      },
      body: jsonEncode({
"model": "gpt-3.5-turbo",
"messages": messages,
      }),
      );
      
      if(res.statusCode == 200){
        String content = jsonDecode(res.body)["choices"][0]["message"]["content"];
        content = content.trim();
        messages.add({'role': 'assistant', 'content': content});
        return content;
  }
 return 'An error occurred';
    }catch(e){
      return e.toString();
    }
  }
  Future<String> ImageGeneratingAPI(String prompt) async{
     try {
    final res = await http.post(
     Uri.parse('https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0'),
      headers: {
        'Authorization': 'Bearer $apikey2',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': prompt,
      }),
    );
    if (res.statusCode == 200) {
      final imageBytes = res.bodyBytes;
      final base64Image = base64Encode(imageBytes);
      return 'data:image/png;base64,$base64Image';
    } else {
      print(res.body);
      return 'Image generation failed: ${res.statusCode}';
    }
  } catch (e) {
    return e.toString();
  }
  }
}
